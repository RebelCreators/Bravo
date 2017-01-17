// Copyright (c) 2016 Rebel Creators
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SocketIO

public enum RCSocketConnectionStatus {
    case connected
    case disconnected
    case reconnecting
}

public class RCSocket: NSObject {
    
    public private(set) var connectionStatus: RCSocketConnectionStatus = .disconnected
    private var previousOp: WebServiceOp?
    static public var defaultPortNumber = 5225
    public static var shared = RCSocket()
    private var maxReconections = 5
    private var currentReconnections = 0
    private var underlyingSocket: SocketIOClient?
    public func intitialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(didSignIn), name: Notification.RC.RCDidSignIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSignOut), name: Notification.RC.RCDidSignOut, object: nil)
    }
    
    public func didSignIn() {
        RCDevice.updateCurrentDevice(success: {
            self.reconnect()
        }, failure: { error in
            if (self.currentReconnections < self.maxReconections && error.code != 401) {
                self.currentReconnections += 1
                self.didSignIn()
            } else {
                self.currentReconnections = 0
            }
        })
    }
    
    public func didSignOut() {
        let op = disconnect()
        op.exeInBackground(dependencies: [previousOp?.asOperation()])
        previousOp = op
    }
    
    private func reconnect() {
        var op = connect(success: {
            self.connectionStatus = .connected
        }, failure: { error in
            if (self.currentReconnections < self.maxReconections && error.code != 401) {
                self.connectionStatus = .reconnecting
                self.currentReconnections += 1
                self.reconnect()
            } else {
                self.connectionStatus = .disconnected
                self.currentReconnections = 0
            }
        })
        
        op.exeInBackground(dependencies: [previousOp?.asOperation()])
        previousOp = op
    }
    
    public func disconnect() -> WebServiceOp  {
        return WebServiceBlockOp({ operation in
            guard let socket = self.underlyingSocket else {
                operation.finish()
                return
            }
            socket.on("disconnect") {data, ack in
                self.connectionStatus = .disconnected
                self.underlyingSocket = nil
                operation.finish()
            }
            socket.disconnect()
        })
    }
    
    public func connect(success:@escaping () -> Void, failure: @escaping (RCError) -> Void) -> WebServiceOp {
        if self.connectionStatus == .connected {
            self.disconnect()
        }
        return WebServiceBlockOp({ operation in
            var succ: (() -> Void)? = success
            var fail: ((RCError) -> Void)? = failure
            guard let config = Bravo.sdk.config else {
                failure(RCError.ConditionNotMet(message: "No configuration set"))
                operation.finish()
                return
            }
            
            guard let credential = Bravo.sdk.credential else {
                failure(RCError.AccessDenied(message: "no credential available"))
                operation.finish()
                return
            }
            let components = NSURLComponents(url: config.baseUrl, resolvingAgainstBaseURL: false)
            components?.port = RCSocket.defaultPortNumber as NSNumber?
            
            guard let url = components?.url else {
                failure(RCError.ConditionNotMet(message: "Could not resolve URL"))
                operation.finish()
                return
            }
            let deviceToken = RCDevice.currentDevice.deviceToken!
            let configOptions:SocketIOClientConfiguration = [.connectParams(["bearer":"\(credential.accessToken)", "deviceToken": deviceToken]), .reconnects(false), ]
            if self.underlyingSocket == nil {
                self.underlyingSocket = SocketIOClient(socketURL:url , config: configOptions)
            }
            
            self.underlyingSocket!.on("error"){data, ack in
                let error = NSError(domain: "RCSocket", code: Int((data.first as? String) ?? "500") ?? 500, userInfo: nil)
                fail?(RCError.OtherNSError(nsError: error))
                succ = nil
                fail = nil
                operation.finish()
            }
            
            self.underlyingSocket!.on("connect") {data, ack in
                succ?()
                succ = nil
                fail = nil
                operation.finish()
            }
            
            self.underlyingSocket!.on("disconnect") {data, ack in
                self.connectionStatus = .disconnected
            }
            self.underlyingSocket!.connect()
        })
    }
}
