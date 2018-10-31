//
//  SettingsViewController.swift
//  Droppin
//
//  Created by Syed Ahmed on 2018-09-28.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Are you sure you want to sign out?",
            message: "You will need to login again to continue using Droppin",
            preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {(alert: UIAlertAction!) in
            self.performSegue(withIdentifier: "unwindToLoginViewController", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
