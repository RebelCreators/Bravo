//
//  ViewController.swift
//  HottHelpersSDK
//
//  Created by Lorenzo Stanton on 10/23/16.
//  Copyright © 2016 Lorenzo Stanton. All rights reserved.
//

import UIKit
import Bravo

class ViewController: UIViewController {
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var logoutBtn: UIButton!
    @IBOutlet var status: UILabel!
    @IBOutlet var userLbl: UILabel!
    @IBOutlet var userBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        status.text = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout), name: Notification.RC.RCDidSignOut, object: nil)
        resume()
        
        //        let user = RCUser()
        //        user.userName = "BoB"
        //        user.firstName = "bob2"
        //        user.lastName = "Sam"
        //        user.password = "gogogo"
        //        user.register(success: { user in
        //            let cred = URLCredential(user: user.userName!, password: user.password!, persistence: .none)
        //            self.loginBtn.isHidden = true
        //            self.logoutBtn.isHidden = true
        //            self.status.text = "Loggin in"
        //            RCUser.login(credential: cred, saveToken: true, success: { user in
        //                self.status.text = "Logged In"
        //                self.logoutBtn.isHidden = false
        //                //self.sendImage()
        //                self.test()
        //                }, failure: { error in
        //                    self.loginBtn.isHidden = false
        //                    self.status.text = error.localizedDescription
        //            })
        //            }) { error in
        //                if error.code == 409 {
        //                  if RCUser.canRefresh() {
        //                    self.resume()
        //                  } else {
        //                    let cred = URLCredential(user: user.userName!, password: user.password!, persistence: .none)
        //                    self.loginBtn.isHidden = true
        //                    self.logoutBtn.isHidden = true
        //                    self.status.text = "Loggin in"
        //                    RCUser.login(credential: cred, saveToken: true, success: { user in
        //                        self.status.text = "Logged In"
        //                        self.logoutBtn.isHidden = false
        //                        //self.sendImage()
        //                        self.test()
        //                        }, failure: { error in
        //                            self.loginBtn.isHidden = false
        //                            self.status.text = error.localizedDescription
        //                    })
        //                    }
        //                }
        //        }
    }
    
    func resume() {
        
        if RCUser.canRefresh() {
            loginBtn.isHidden = true
            logoutBtn.isHidden = true
            status.text = "Resuming"
            RCUser.resume(success: { user in
                self.status.text = "Resumed Session"
                self.logoutBtn.isHidden = false
                // self.sendImage()
                self.test()
                }, failure: { error in
                    self.loginBtn.isHidden = false
                    self.status.text = error.localizedDescription
            })
        } else {
            loginBtn.isHidden = false
            logoutBtn.isHidden = true
        }
    }
    
    func test() {
        //        let user = RCUser.currentUser!
        //
        //        user.firstName = "john"
        //        user.lastName = "smith"
        //
        //        user.updateUser(success: { user in
        //
        //            }, failure: { error in
        //
        //        })
        //       let image = UIImage(named: "IMG_2275")!
        ////        let data = UIImagePNGRepresentation(image)!
        ////        RCUser.currentUser?.setProfileImage(pngData: data, success: { user in
        ////
        ////            }, failure: { error in
        ////
        ////        })
        //        RCUser.currentUser?.profileImage(success: { data in
        //            guard let data = data else {
        //                return
        //            }
        //            let image = UIImage(data: data)
        //
        //            }, failure: { error in
        //
        //        })
        
    }
    
    func sendImage() {
        let image = UIImage(named: "IMG_2275")!
        let data = UIImagePNGRepresentation(image)!
        let file = RCFile(data: data, contentType: "image/png")
        file.uploadData(success: {
            print("file Uploaded \(file.fileID ?? "")")
            let newFile = RCFile(fileID: file.fileID!, contentType: "image/png")
            newFile.downloadData(success: { data in
                let image = UIImage(data: data)
                
                }, failure: { error in
                    
            })
            }, failure: { error in
                
        })
    }
    
    @IBAction func login(sender: UIButton) {
        let cred = URLCredential(user: "bob", password: "gogogo", persistence: .none)
        loginBtn.isHidden = true
        logoutBtn.isHidden = true
        status.text = "Logging in"
        RCUser.login(credential: cred, saveToken: true, success: { user in
            self.status.text = "Logged In"
            self.logoutBtn.isHidden = false
            //self.sendImage()
            self.test()
            }, failure: { error in
                self.loginBtn.isHidden = false
                self.status.text = error.localizedDescription
        })
    }
    
    @IBAction func fetchUser() {
        self.userLbl.text = ""
        RCUser.userById(userID: RCUser.currentUser!.userID!, success: { user in
            self.userLbl.text = user.description
            }, failure: { error in
                self.userLbl.text = ""
        })
    }
    
    func didLogout() {
        loginBtn.isHidden = false
        logoutBtn.isHidden = true
    }
    
    @IBAction func logout(sender: UIButton) {
        loginBtn.isHidden = false
        logoutBtn.isHidden = true
        status.text = "Logged out"
        
        RCUser.logout(success: nil, failure: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

