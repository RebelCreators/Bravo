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
    open var postPermissions: RCDialogPermissionsEnum = .anyParticipant // enum
    open var invitationPermissions: RCDialogPermissionsEnum = .anyParticipant // enum
    open var updatePermissions: RCDialogPermissionsEnum = .onlyOwner // enum
    
    open override class func enumAttributeTypes() -> [AnyHashable : Any]! {
        return (super.enumAttributeTypes() ?? [:]) + ["postPermissions" : RCDialogPermissionsEnumObject.self,
                                                      "invitationPermissions" : RCDialogPermissionsEnumObject.self,
                                                      "updatePermissions" : RCDialogPermissionsEnumObject.self]
    }
}

func ==(lhs: RCDialog, rhs: RCDialog) -> Bool {
    return lhs.dialogID == rhs.dialogID && rhs.dialogID != nil
}

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
    
    public func publish(message: RCMessage, success: () -> Void, failure: (RCError) -> Void) {
        
    }
    
    public func messages(offset: Int, limit: Int, success: ([RCMessage]) -> Void, failure: (RCError) -> Void) {
        
    }
    
    public static func subscriptions(success: @escaping ([RCDialog]) -> Void, failure: @escaping (RCError) -> Void) {
        WebService().get(relativePath: "dialog/current", headers: nil, parameters: [:], success: { (dialogs: [RCDialog]) in
            success(dialogs)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
}
