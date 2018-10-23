//
//  LoginViewController.swift
//  Droppin
//
//  Created by Syed Ahmed on 2018-09-28.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit
import FirebaseUI
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, FUIAuthDelegate {
    
    @IBOutlet weak var login_Email: UITextField!
    @IBOutlet weak var login_Password: UITextField!

    @IBOutlet weak var fbLoginBtn: FBSDKLoginButton!
    
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        loginButton.frame.size = CGSize(width: fbLoginBtn.frame.width, height: 100)
        loginButton.delegate = self
        fbLoginBtn = loginButton
        
        if let token = FBSDKAccessToken.current() {
            fetchProfile()
        }
        
        
        let parameters = ["attendants": "4", "dateStart": "Oct 18, 2018", "dateEnd": "Oct 20, 2018", "eventID": "10"]
        Client.addEvent(parameters) { (results:[Any]) in
            if results[0] as? Int == 200 {
                //success
                print("successfully added an event with id \(results[1] as? String)")
            } else {
                //error
                print("successfully added an event")
            }
        }
    }
    
    func fetchProfile() {
        print("fetch profile")
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, result, error) -> Void in
            
            if error != nil {
                print(error!)
                return
            }
            
            if let email = result as? [String:Any] {
                print(email["email"]!)
            }
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print("Successfully logged in to facebook...")
        fetchProfile()
    }

}
