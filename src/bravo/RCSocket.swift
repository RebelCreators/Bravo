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

public class RCSocketConnectOperation: RCAsyncOperation {
    override public func execute() {
        if RCSocket.shared.connectionStatus == .connected {
            finish()
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(didConnect), name: Notification.RC.RCSocketDidConnect, object: RCSocket.shared)
        }
    }
    
    func didConnect() {
        finish()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

public class RCSocket: NSObject {
    
    public private(set) var connectionStatus: RCSocketConnectionStatus = .disconnected
    public private(set) var connectionOperation: Operation?
    public private(set) var disconnectionOperation: Operation?
    
    public var debug = false
    private var currentOperation: WebServiceOp?
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
            self.disconnect()
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
    }
    
    public func reconnect() -> Operation {
        let op = WebServiceBlockOp({ operation in
            if self.connectionStatus == .connected {
                operation.finish()
                return
            }
            self.connect(success: {
                self.connectionStatus = .connected
                NotificationCenter.default.post(name: Notification.RC.RCSocketDidConnect, object: self)
                operation.finish()
            }, failure: { error in
                if self.currentReconnections < self.maxReconections && error.code != 401 {
                    self.connectionStatus = .reconnecting
                    self.currentReconnections += 1
                    self.reconnect()
                } else {
                    self.connectionStatus = .disconnected
                    self.currentReconnections = 0
                }
                operation.finish()
            }).exeInBackground()
        })
        
        op.exeInBackground(dependencies: [currentOperation?.asOperation()])
        connectionOperation = op.asOperation()
        currentOperation = op
        
        return op.asOperation()
    }
    
    public func disconnect() -> Operation  {
        let op = WebServiceBlockOp({ operation in
            guard let socket = self.underlyingSocket else {
                operation.finish()
                return
            }
            if (socket.status != .notConnected && socket.status != .disconnected) {
                socket.removeAllHandlers()
                socket.on("disconnect") {[weak self, weak socket] data, ack in
                    self?.connectionStatus = .disconnected
                    
                    socket?.removeAllHandlers()
                    NotificationCenter.default.post(name: Notification.RC.RCSocketDidDisconnect, object: self)
                    operation.finish()
                }
                self.underlyingSocket = nil
                socket.disconnect()
            } else {
                self.underlyingSocket = nil
                self.connectionStatus = .disconnected
                operation.finish()
            }
        })
        
        op.exeInBackground(dependencies: [currentOperation?.asOperation()])
        currentOperation = op
        disconnectionOperation = op.asOperation()
        
        return op.asOperation()
    }
    
    private func connect(success:@escaping () -> Void, failure: @escaping (BravoError) -> Void) -> WebServiceOp {
        let op = WebServiceBlockOp({ operation in
            var succ: (() -> Void)? = success
            var fail: ((BravoError) -> Void)? = failure
            guard let config = Bravo.sdk.config else {
                failure(BravoError.ConditionNotMet(message: "No configuration set"))
                operation.finish()
                return
            }
            
            guard let credential = Bravo.sdk.credential else {
                failure(BravoError.AccessDenied(message: "no credential available"))
                operation.finish()
                return
            }
            let components = NSURLComponents(url: config.baseUrl, resolvingAgainstBaseURL: false)
            components?.port = RCSocket.defaultPortNumber as NSNumber?
            
            guard let url = components?.url else {
                failure(BravoError.ConditionNotMet(message: "Could not resolve URL"))
                operation.finish()
                return
            }
            let deviceToken = RCDevice.currentDevice.deviceToken!
            let configOptions:SocketIOClientConfiguration = [.connectParams(["bearer":"\(credential.accessToken)", "deviceToken": deviceToken]), .reconnects(false), .forceWebsockets(true), .log(self.debug), .forceNew(true)]
            if self.underlyingSocket == nil {
                self.underlyingSocket = SocketIOClient(socketURL:url , config: configOptions)
            }
            
            self.underlyingSocket!.on("error"){data, ack in
                let error = NSError(domain: "RCSocket", code: Int((data.first as? String) ?? "500") ?? 500, userInfo: nil)
                fail?(BravoError.OtherNSError(nsError: error))
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
            
            self.underlyingSocket!.on("com.rebel.creators.message") {data, ack in
                if let dict = data.first as? [String: NSObject] {
                    if let message = try? RCMessage.fromDictionary(dict) {
                        NotificationCenter.default.post(name: Notification.RC.RCDidReceiveMessage, object: self, userInfo: [RCMessageKey: message])
                    }
                }
            }
            
            var socket = self.underlyingSocket
            self.underlyingSocket!.on("disconnect") {[weak socket] data, ack in
                if  (socket != nil) {
                    socket?.removeAllHandlers()
                    self.reconnect()
                }
                if !operation.isFinished && !operation.isCancelled {
                    operation.finish()
                }
            }
            if self.underlyingSocket?.status != .connected && self.underlyingSocket?.status != .connecting {
                self.underlyingSocket!.connect()
            } else {
                operation.finish()
            }
        })
        
        return op
    }
}
