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

func ==(lhs: RCUser, rhs: RCUser) -> Bool {
    return lhs.userID == rhs.userID
}

@objc(RCUser)
public class RCUser: RCModel {
    
    static public private(set) var authOperation: WebServiceOp?
    public fileprivate(set) static var currentUser: RCUser?
    public var firstName: String?
    public var lastName: String?
    public var userID: String?
    public var userName: String?
    public var password: String?
    public var avatar: String?
    public var extras: [String: String]?
    public var gender: RCGenderEnum = .none
    
    open override class func attributeMappings() -> [AnyHashable : Any]! {
        return super.attributeMappings() + ["userID" : "_id"]
    }
    
    open override class func enumAttributeTypes() -> [AnyHashable : Any]! {
        return (super.enumAttributeTypes() ?? [:]) + ["gender" : RCGenderEnumObject.self]
    }
    
    public func profileImage(success:@escaping ((Data?) -> Void), failure:@escaping ((RCError)->Void)) {
        guard userID != nil else {
            failure(.ConditionNotMet(message: "No userID"))
            return
        }
        guard let avatar = self.avatar else {
            success(nil)
            return
        }
        let file = RCFile(fileID: avatar, contentType: "image/png")
        file.downloadData(success: { data in
            success(data)
        }, failure: { error in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func setProfileImage(pngData:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     Data, success:@escaping ((RCUser) -> Void), failure:@escaping ((RCError)->Void)) {
        guard userID != nil else {
            failure(.ConditionNotMet(message: "No userID"))
            return
        }
        let file = RCFile(data: pngData, contentType: "image/png")
        file.upload(success: {
            let user = self.copy() as! RCUser
            user.avatar = file.fileID
            user.updateUser(success: { user in
                self.avatar = user.avatar
                success(user)
            }, failure: failure)
        }, failure: failure).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func updateUser(success:@escaping ((RCUser) -> Void), failure:@escaping ((RCError)->Void)) {
        guard userID != nil else {
            failure(.ConditionNotMet(message: "No userID"))
            return
        }
        WebService().put(relativePath: "users/update", headers: nil, parameters: self, success: { (user: RCUser) in
            success(user)
        }) { error in
            failure(error)
            }.exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func register(success:@escaping ((RCUser) -> Void), failure:@escaping ((RCError)->Void)) {
        WebService().post(relativePath: "users/register", requiresAuth: false, headers: nil, parameters: self, success: { (user : RCUser) in
            success(user)
        }) { error in
            failure(error)
            }.exeInBackground()
    }
    
    public static func login(credential: URLCredential, success:@escaping ((RCUser) -> Void), failure: @escaping ((RCError) -> Void)) {
        login(credential: credential, saveToken: false, success: success, failure: failure)
    }
    
    public static func login(credential: URLCredential, saveToken: Bool, success:@escaping ((RCUser) -> Void), failure: @escaping ((RCError) -> Void)) {
        if let op = self.authOperation {
            WebServiceBlockOp({ operation in
                guard let user = RCUser.currentUser else {
                    failure(RCError.AccessDenied(message: "could not log in"))
                    
                    operation.finish()
                    return
                }
             
                success(user)
                operation.finish()
            }).exeInBackground(dependencies: [op.asOperation()])
            
            return
        }
        
        let authOperation = WebServiceBlockOp({ operation in
            WebService().authenticate(relativePath: "oauth/token", parameters: ["username": credential.user!, "password": credential.password!, "grant_type": "password"], success: { (credential: RCAuthCredential) in
                
                Bravo.sdk.credential = credential
                
                WebService().get(relativePath: "users/current", headers: nil, parameters: [:], success: { (user: RCUser) in
                    credential.updateExpiry()
                    if (saveToken) {
                        let _ = credential.save()
                    }
                    
                    RCUser.currentUser = user
                    NotificationCenter.default.post(name: Notification.RC.RCDidSignIn, object: self, userInfo: nil)
                    success(user)
                    operation.finish()
                }, failure: { (error) in
                    failure(error)
                    operation.finish()
                }).exeInBackground()
            }, failure: { error in
                failure(error)
                operation.finish()
            }).exeInBackground()
        })
        
        self.authOperation = authOperation
        authOperation.onFinished {
            self.authOperation = nil
            }.exeInBackground()
    }
    
    public static func canRefresh() -> Bool {
        return RCAuthCredential.savedToken() != nil || Bravo.sdk.credential?.refreshToken != nil
    }
    
    public static func resume(success:@escaping ((RCUser) -> Void), failure: @escaping ((RCError) -> Void)) {
        if let op = self.authOperation {
            WebServiceBlockOp({ operation in
                guard let user = RCUser.currentUser else {
                    failure(RCError.AccessDenied(message: "could not resume"))
                    
                    operation.finish()
                    return
                }
                
                success(user)
                operation.finish()
            }).exeInBackground(dependencies: [op.asOperation()])
            
            return
        }
        
        guard let credential = (RCAuthCredential.savedToken() ?? Bravo.sdk.credential) else {
            failure(RCError.InvalidParameter(message: "Token Not Found"))
            return
        }
        
        let authOperation = WebServiceBlockOp({ operation in
            WebService().authenticate(relativePath: "oauth/token", parameters: ["refresh_token": credential.refreshToken, "grant_type": "refresh_token"], success: { (credential: RCAuthCredential) in
                Bravo.sdk.credential = credential
                
                WebService().get(relativePath: "users/current", headers: nil, parameters: [:], success: { (user: RCUser) in
                    credential.updateExpiry()
                    let _ = credential.save()
                    
                    RCUser.currentUser = user
                    NotificationCenter.default.post(name: Notification.RC.RCDidSignIn, object: self, userInfo: nil)
                    success(user)
                    operation.finish()
                }, failure: { (error) in
                    RCAuthCredential.removeToken()
                    failure(error)
                    operation.finish()
                }).exeInBackground()
            }, failure: { error in
                RCAuthCredential.removeToken()
                failure(error)
                operation.finish()
            }).exeInBackground()
        })
        
        self.authOperation = authOperation
        authOperation.onFinished {
            self.authOperation = nil
            }.exeInBackground()
    }
    
    public static func userById(userID: String, success:@escaping ((RCUser) -> Void), failure: @escaping ((RCError) -> Void)) {
        WebService().get(relativePath: "users/:userID/id", headers: nil, parameters: ["userID": userID], success: { (user: RCUser) in
            success(user)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [self.authOperation?.asOperation()])
    }
    
    public static func userByIds(userIDs: [String], success:@escaping (([RCUser]) -> Void), failure: @escaping ((RCError) -> Void)) {
        WebService().get(relativePath: "users/id", headers: nil, parameters: ["userIDs": userIDs], success: { (user: [RCUser]) in
            success(user)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [self.authOperation?.asOperation()])
    }
    
    public static func userByUserNames(userNames: [String], success:@escaping (([RCUser]) -> Void), failure: @escaping ((RCError) -> Void)) {
        WebService().get(relativePath: "users/username", headers: nil, parameters: ["userNames": userNames], success: { (user: [RCUser]) in
            success(user)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [self.authOperation?.asOperation()])
    }
    
    public static func userByUserName(userName: String, success:@escaping ((RCUser) -> Void), failure: @escaping ((RCError) -> Void)) {
        WebService().get(relativePath: "users/:userName/username", headers: nil, parameters: ["userName": userName], success: { (user: RCUser) in
            success(user)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [self.authOperation?.asOperation()])
    }
    
    public static func logout(success:(() -> Void)?, failure: ((RCError) -> Void)?) {
        WebService().delete(relativePath: "oauth/logout", headers: nil, parameters: [:], responseType: .nodata, success: { (_: RCNullModel) in
            success?()
        }, failure: { (error) in
            failure?(error)
        }).onFinished {
            self.authOperation = nil
            RCAuthCredential.removeToken()
            Bravo.sdk.credential = nil
            currentUser = nil
            NotificationCenter.default.post(name: Notification.RC.RCDidSignOut, object: self, userInfo: nil)
            }.exeInBackground(dependencies: [self.authOperation?.asOperation()])
    }
    
    static func register(user: RCUser, success:((RCUser) -> Void), failure:((RCError) -> Void)) {
        
    }
}
