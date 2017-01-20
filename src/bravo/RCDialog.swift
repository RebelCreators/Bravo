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

import Foundation

open class RCDialogPermission: RCModel {
    open var read: RCDialogPermissionsEnum = .anyParticipant // enum
    open var write: RCDialogPermissionsEnum = .anyParticipant // enum
    open var update: RCDialogPermissionsEnum = .onlyOwner // enum
    
    open override class func enumAttributeTypes() -> [AnyHashable : Any]! {
        return (super.enumAttributeTypes() ?? [:]) + ["read" : RCDialogPermissionsEnumObject.self,
                                                      "write" : RCDialogPermissionsEnumObject.self,
                                                      "update" : RCDialogPermissionsEnumObject.self]
    }
}

func ==(lhs: RCDialog, rhs: RCDialog) -> Bool {
    return lhs.dialogID == rhs.dialogID && rhs.dialogID != nil
}

fileprivate class RCDialogListener: NSObject {
    weak var object: AnyObject?
    var completion: ((RCMessage) -> Void)?
}

fileprivate var messageListeners = [Int: [RCDialogListener]]()
public class RCDialog: RCModel {
    
    public var dialogID: String?
    public var allUsers = [RCUser]()
    public var creator: RCUser?
    public var currentUsers = [RCUser]()
    public var details: String?
    public var lastMessageTime: Date?
    public var name: String?
    public var numberOfmessages: NSNumber?
    public var permissions: RCDialogPermission = RCDialogPermission()
    
    internal var _currentUsers = [String]()
    fileprivate var onMessageListeners: [RCDialogListener] {
        get {
            return messageListeners[self.hashValue] ?? []
        }
        set {
            messageListeners[self.hashValue] = newValue
        }
    }
    lazy private var registerNotifications: Void = {
        NotificationCenter.default.addObserver(self, selector: #selector(messageReceived(_:)), name: Notification.RC.RCDidReceiveMessage, object: nil)
    }()
    
    public func removeOnMessageListener(context: AnyObject) {
        onMessageListeners.forEach({ obj in
            if let objContext = obj.object, context === objContext {
                obj.object = nil
            }
        })
        onMessageListeners = onMessageListeners.filter({ $0.object != nil })
    }
    
    //context so listener can be deallocated
    public func onMessage(context: AnyObject ,_ completion:@escaping (RCMessage) -> Void) {
        let _ = self.registerNotifications
        let listener = RCDialogListener()
        listener.object = context
        listener.completion = { message in
            completion(message)
        }
        var listeners = onMessageListeners
        listeners.append(listener)
        onMessageListeners = listeners
    }
    
    public static func create(name: String,
                              details: String,
                              participants: Set<RCUser>? = nil,
                              permissions: RCDialogPermission = RCDialogPermission(),
                              success: @escaping (RCDialog) -> Void,
                              failure: @escaping (RCError) -> Void) {
        guard let currentUser = RCUser.currentUser else {
            failure(RCError.ConditionNotMet(message: "user not logged in"))
            
            return
        }
        
        var users: Set<RCUser> = participants ?? []
        users.insert(currentUser)
        let dialog = RCDialog()!
        dialog.details = details
        dialog.name = name
        dialog.allUsers = Array(users)
        dialog.permissions = permissions
        WebService().put(relativePath: "dialog/new", headers: nil, parameters: dialog, success: { (dialog: RCDialog) in
            success(dialog)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func leave(success: @escaping () -> Void, failure: @escaping (RCError) -> Void) {
        guard let dialogID = self.dialogID else {
            failure(RCError.ConditionNotMet(message: "user not logged in"))
            
            return
        }
        WebService().delete(relativePath: "dialog/leave", headers: nil, parameters: ["dialogId": dialogID, "permissions": self.permissions], responseType: .nodata,success: { (dialogs: RCNullModel) in
            success()
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func addUser(userID: String, success: @escaping (RCDialog) -> Void, failure: @escaping (RCError) -> Void) {
        guard let dialogID = self.dialogID else {
            failure(RCError.ConditionNotMet(message: "user not logged in"))
            
            return
        }
        WebService().post(relativePath: "dialog/add", headers: nil, parameters: ["userId": userID, "dialogId": dialogID, "permissions": self.permissions], success: { (dialog: RCDialog) in
            success(dialog)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func removeUser(userID: String, success: @escaping (RCDialog) -> Void, failure: @escaping (RCError) -> Void) {
        guard let dialogID = self.dialogID else {
            failure(RCError.ConditionNotMet(message: "user not logged in"))
            
            return
        }
        WebService().delete(relativePath: "dialog/remove", headers: nil, parameters: ["userId": userID, "dialogId": dialogID, "permissions": self.permissions], success: { (dialog: RCDialog) in
            success(dialog)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func publish(message: RCMessage, success: @escaping (RCMessage) -> Void, failure: @escaping (RCError) -> Void) {
        message.dialogId = self.dialogID
        message.senderId = RCUser.currentUser?.userID
        WebService().put(relativePath: "dialog/message/send", headers: nil, parameters: ["message": message, "dialogId": dialogID, "permissions": self.permissions], success: { (message: RCMessage) in
            success(message)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func messages(offset: Int, limit: Int, success: ([RCMessage]) -> Void, failure: (RCError) -> Void) {
        
    }
    
    public static func dialogWithID(dialogID: String, permissions: RCDialogPermission, success: @escaping (RCDialog) -> Void, failure: @escaping (RCError) -> Void) {
        WebService().get(relativePath: "dialog/:dialogID/id", headers: nil, parameters: ["dialogID": dialogID, "permissions": permissions], success: { (dialogs: RCDialog) in
            success(dialogs)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public static func subscriptions(success: @escaping ([RCDialog]) -> Void, failure: @escaping (RCError) -> Void) {
        WebService().get(relativePath: "dialog/current", headers: nil, parameters: [:], success: { (dialogs: [RCDialog]) in
            success(dialogs)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        messageListeners[self.hashValue] = nil
    }
}

extension RCDialog {
    @objc internal func messageReceived(_ notification: Notification) {
        if let message = notification.userInfo?[RCMessageKey] as? RCMessage {
            if message.dialogId == self.dialogID && self.dialogID != nil {
                for listener in onMessageListeners {
                    if let _ = listener.object {
                        listener.completion?(message)
                    }
                }
                onMessageListeners = onMessageListeners.filter({ $0.object != nil })
            }
        }
    }
    
    open override class func generate(from: Any) -> Any? {
        let model = super.generate(from: from)
        
        if let dialog = model as? RCDialog {
            var userMap = [String: RCUser]()
            for user in dialog.allUsers {
                userMap[user.userID ?? ""] = user
            }
            
            for userID in dialog._currentUsers {
                if let user = userMap[userID] {
                    dialog.currentUsers.append(user)
                }
            }
        }
        
        return model
    }
    
    open override class func ommitKeys() -> [String] {
        return ["currentUsers"]
    }
    
    open override class func attributeMappings() -> [AnyHashable : Any]! {
        var attributes = super.attributeMappings() + ["_currentUsers" : "currentUsers", "dialogID": "_id"]
        return attributes
    }
    
    open override class func listAttributeTypes() -> [AnyHashable : Any]! {
        return (super.listAttributeTypes() ?? [:]) + ["allUsers": RCUser.self]
    }
    
    open override class func mapAttributeTypes() -> [AnyHashable : Any]! {
        return (super.mapAttributeTypes() ?? [:])  + ["creator": RCUser.self, "permissions": RCDialogPermission.self]
    }
}
