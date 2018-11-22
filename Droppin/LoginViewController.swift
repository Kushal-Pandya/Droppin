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
    var passwordList: [String] = []
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "logoutSet")
        
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
                            if let password = userData["password"] as? String {
                                self.passwordList.append(password)
                            }
                        }
                    }
                }
            }
        }
        
        if let token = FBSDKAccessToken.current() {
            fetchProfile()
            DispatchQueue.main.async { self.performSegue(withIdentifier: "loginBtn", sender: self) }
        }
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "loginSet")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let logoutReturn = UserDefaults.standard.object(forKey: "logoutSet") as? Bool {
            if (logoutReturn == true) {
                FBSDKLoginManager().logOut()
                UserDefaults.standard.set(false, forKey: "logoutSet")
            }
        }
        if let loginReturn = UserDefaults.standard.object(forKey: "loginSet") as? Bool {
            if (loginReturn == true) {
                DispatchQueue.main.async { self.performSegue(withIdentifier: "loginBtn", sender: self) }
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
                DispatchQueue.main.async { UserDefaults.standard.set(email["email"]!, forKey: "email") }
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
            if (self.userList.contains(login_Email.text!) && login_Password.text! == passwordList[userList.firstIndex(of: login_Email.text!)!]) {
                UserDefaults.standard.set(login_Email.text, forKey: "email")
                DispatchQueue.main.async { self.performSegue(withIdentifier: "loginBtn", sender: self) }
            } else {
                let alert = UIAlertController(title: "Error", message: "Password or Username is Incorrect.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    // DON'T DELETE, NEEDED FOR SIGNOUT
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
}
