//
//  FiltersViewController.swift
//  Droppin
//
//  Created by Kushal Pandya on 2018-10-26.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var closeModalButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
//        view.backgroundColor = UIColor.white
//        view.isOpaque = false
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
