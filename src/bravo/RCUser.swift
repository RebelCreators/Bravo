// Copyright (c) 2017 Rebel Creators
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

import RCModel

func ==(lhs: RCUser, rhs: RCUser) -> Bool {
    return lhs.isEqual(rhs)
}

public class PNGPhoto: RCFile {
    public init(photoID: String) {
        super.init(fileID: photoID, contentType: "image/png")
    }
}

@objc public class RCUser: RCModel {
    
    static public private(set) var authOperation: WebServiceOp?
    public fileprivate(set) static var currentUser: RCUser?
    @objc public var firstName: String?
    @objc public var lastName: String?
    @objc public var userID: String?
    @objc public var userName: String?
    @objc public var password: String?
    @objc public var avatar: String?
    @objc public var extras: [String: String]?
    @objc public var gender: RCGenderEnum = .none
    private var uuid: String = {
        return UUID().uuidString
    }()
    
    public func profileImage(success:@escaping ((Data?) -> Void), failure:@escaping ((BravoError)->Void)) {
        guard userID != nil else {
            failure(.ConditionNotMet(message: "No userID"))
            return
        }
        guard let file = profileImageFile() else {
            success(nil)
            return
        }
        
        file.downloadData(success: { data in
            success(data)
        }, failure: { error in
            failure(error)
        }).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func profileImageFile() -> PNGPhoto? {
        guard let avatar = self.avatar else {
            return nil
        }
        
        return PNGPhoto(photoID: avatar)
    }
    
    public func setProfileImage(pngData:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     Data?, success:@escaping ((RCUser) -> Void), failure:@escaping ((BravoError)->Void)) {
        guard userID != nil else {
            failure(.ConditionNotMet(message: "No userID"))
            return
        }
        let user = self.copy() as! RCUser
        user.avatar = nil
        let onFinish = {
            user.updateUser(success: { user in
                self.avatar = user.avatar
                success(self)
            }, failure: failure)
        }
        
        guard let imageData = pngData else {
            onFinish()
            return
        }
        
        let file = RCFile(data: imageData, contentType: "image/png")
        file.upload(success: {
            user.avatar = file.fileID
            onFinish()
        }, failure: failure).exeInBackground(dependencies: [RCUser.authOperation?.asOperation()])
    }
    
    public func updateUser(success:@escaping ((RCUser) -> Void), failure:@escaping ((BravoError)->Void)) {
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
    
    public func register(success:@escaping ((RCUser) -> Void), failure:@escaping ((BravoError)->Void)) {
        WebService().post(relativePath: "users/register", requiresAuth: false, headers: nil, parameters: self, success: { (user : RCUser) in
            success(user)
        }) { error in
            failure(error)
            }.exeInBackground()
    }
    
    public static func login(credential: URLCredential, success:@escaping ((RCUser) -> Void), failure: @escaping ((BravoError) -> Void)) {
        login(credential: credential, saveToken: false, success: success, failure: failure)
    }
    
    public static func login(credential: URLCredential, saveToken: Bool, success:@escaping ((RCUser) -> Void), failure: @escaping ((BravoError) -> Void)) {
        if let op = self.authOperation {
            WebServiceBlockOp({ operation in
                guard let user = RCUser.currentUser else {
                    failure(BravoError.AccessDenied(message: "could not log in"))
                    
                    operation.finish()
                    return
                }
                
                success(user)
                operation.finish()
            }).exeInBackground(dependencies: [op.asOperation()])
            
            return
        }
        let loginBlock = {
            var rcUser: RCUser?
            var rcCredential: RCAuthCredential?
            let authOperation = WebServiceBlockOp({ operation in
                WebService().authenticate(relativePath: "oauth/token", parameters: ["username": credential.user!, "password": credential.password!, "grant_type": "password"], success: { (credential: RCAuthCredential) in
                    
                    Bravo.sdk.credential = credential
                    rcCredential = credential
                    WebService().get(relativePath: "users/current", headers: nil, parameters: [:], success: { (user: RCUser) in
                        RCUser.currentUser = user
                        rcUser = user
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
                
                guard let user = rcUser, let credential = rcCredential else {
                    return
                }
                
                RCDevice.updateCurrentDevice(success: {
                    credential.updateExpiry()
                    if (saveToken) {
                        let _ = credential.save()
                    }
                    
                    NotificationCenter.default.post(name: Notification.RC.RCDidSignIn, object: self, userInfo: nil)
                    success(user)
                }, failure: { error in
                    RCUser.currentUser = nil
                    RCAuthCredential.removeToken()
                    failure(error)
                })
                }.exeInBackground()
        }
        
        if currentUser != nil {
            logout(success: {
                loginBlock()
            }, failure: { (error) in
                failure(error)
            })
        } else {
            loginBlock()
        }
    }
    
    public static func canRefresh() -> Bool {
        return RCAuthCredential.savedToken() != nil || Bravo.sdk.credential?.refreshToken != nil
    }
    
    public static func resume(success:@escaping ((RCUser) -> Void), failure: @escaping ((BravoError) -> Void)) {
        if let op = self.authOperation {
            WebServiceBlockOp({ operation in
                guard let user = RCUser.currentUser else {
                    failure(BravoError.AccessDenied(message: "could not resume"))
                    
                    operation.finish()
                    return
                }
                
                success(user)
                operation.finish()
            }).exeInBackground(dependencies: [op.asOperation()])
            
            return
        }
        
        guard let credential = (RCAuthCredential.savedToken() ?? Bravo.sdk.credential) else {
            failure(BravoError.InvalidParameter(message: "Token Not Found"))
            return
        }
        
        var rcUser: RCUser?
        var rcCredential: RCAuthCredential?
        let authOperation = WebServiceBlockOp({ operation in
            WebService().authenticate(relativePath: "oauth/token", parameters: ["refresh_token": credential.refreshToken, "grant_type": "refresh_token"], success: { (credential: RCAuthCredential) in
                Bravo.sdk.credential = credential
                rcCredential = credential
                WebService().get(relativePath: "users/current", headers: nil, parameters: [:], success: { (user: RCUser) in
                    RCUser.currentUser = user
                    rcUser = user
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
            guard let user = rcUser, let credential = rcCredential  else {
                return
            }
            
            RCDevice.updateCurrentDevice(success: {
                credential.updateExpiry()
                let _ = credential.save()
                NotificationCenter.default.post(name: Notification.RC.RCDidSignIn, object: self, userInfo: nil)
                success(user)
            }, failure: { error in
                RCUser.currentUser = nil
                RCAuthCredential.removeToken()
                failure(error)
            })
            }.exeInBackground()
    }
    
    public static func userById(userID: String, success:@escaping ((RCUser) -> Void), failure: @escaping ((BravoError) -> Void)) {
        WebService().get(relativePath: "users/:userID/id", headers: nil, parameters: ["userID": userID], success: { (user: RCUser) in
            success(user)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [self.authOperation?.asOperation()])
    }
    
    public static func userByIds(userIDs: [String], success:@escaping (([RCUser]) -> Void), failure: @escaping ((BravoError) -> Void)) {
        WebService().get(relativePath: "users/id", headers: nil, parameters: ["userIDs": userIDs], success: { (user: [RCUser]) in
            success(user)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [self.authOperation?.asOperation()])
    }
    
    public static func userByUserNames(userNames: [String], success:@escaping (([RCUser]) -> Void), failure: @escaping ((BravoError) -> Void)) {
        WebService().get(relativePath: "users/username", headers: nil, parameters: ["userNames": userNames], success: { (user: [RCUser]) in
            success(user)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [self.authOperation?.asOperation()])
    }
    
    public static func userByUserName(userName: String, success:@escaping ((RCUser) -> Void), failure: @escaping ((BravoError) -> Void)) {
        WebService().get(relativePath: "users/:userName/username", headers: nil, parameters: ["userName": userName], success: { (user: RCUser) in
            success(user)
        }, failure: { (error) in
            failure(error)
        }).exeInBackground(dependencies: [self.authOperation?.asOperation()])
    }
    
    public static func logout(success:(() -> Void)?, failure: ((BravoError) -> Void)?) {
        RCDevice.deleteCurrentDevice(success: {
            WebService().delete(relativePath: "oauth/logout", headers: nil, parameters: [:], success: {
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
        }, failure: { error in
            failure?(error)
        })
    }
    
    open override var hashValue: Int {
        guard let mID = userID else {
            return uuid.hashValue
        }
        return mID.hashValue
    }
}

extension RCUser {
    
    open override func isEqual(_ object: Any!) -> Bool {
        guard let model = object as? RCUser else {
            return false
        }
        return hashValue == model.hashValue
    }
    
    open override class func propertyMappings() -> [String : RCPropertyKey] {
        return super.propertyMappings() + ["userID" : "_id"]
    }
    
    open override class func enumClasses() -> [String : RCEnumMappable.Type] {
        return super.enumClasses() + ["gender" : RCGenderEnumMapper.self]
    }
}
