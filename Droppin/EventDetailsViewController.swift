//
//  EventDetailsViewController.swift
//  Droppin
//
//  Created by Syed Ahmed on 2018-10-30.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {
    var textTitle:String = ""
    var textDescription:String = ""
    var textDate:String = ""
    var textLocation:String = ""
    var textCategory:String = ""

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventCategory: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    
    
    
    @IBAction func goButton(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventTitle?.text = textTitle
        eventDescription?.text = textDescription
        eventDate?.text = textDate
        eventCategory?.text = textCategory
        eventLocation?.text = textLocation
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
