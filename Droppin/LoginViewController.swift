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
    
    var userList: [String] = []
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.delegate = self
        fbLoginBtn = loginButton
        
        Client.getUsers() { (results:[Any]) in
            if results[0] as? Int == 200 {
                if let theResults = results[1] as? [String:Any] {
                    for (_, value) in theResults{
                        
                        if let userData = value as? [String:Any] {
                            if let email = userData["email"] as? String {
                                self.userList.append(email)
                            }
                        }
                    }
                }
            }
        }
        
        if let token = FBSDKAccessToken.current() {
            fetchProfile()
        }
        
    }
    
    func fetchProfile() {
        print("fetch profile")
        let parameters = ["fields": "email, first_name, last_name"]
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
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        if (login_Email.text!.isEmpty) {
            let alert = UIAlertController(title: "Error", message: "Email Field Empty.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else{
            if (self.userList.contains(login_Email.text!)) {
                UserDefaults.standard.set(login_Email.text, forKey: "email")
                DispatchQueue.main.async { self.performSegue(withIdentifier: "loginBtn", sender: self) }
            } else {
                let alert = UIAlertController(title: "Error", message: "User Not Found.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
}
