//
//  EventDetailsViewController.swift
//  Droppin
//
//  Created by Syed Ahmed on 2018-10-30.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

class EventDetailsViewController: UIViewController {
    var textTitle:String = ""
    var textDescription:String = ""
    var textDate:String = ""
    var textLocation:String = ""
    var textCategory:String = ""
    var invites:String = ""
    var accepted:[String] = [""]

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventCategory: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventInvitees: UILabel!
    @IBOutlet weak var eventAttendees: UILabel!
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventTitle?.text = textTitle
        eventDescription?.text = textDescription
        eventInvitees?.text = "ajgnfakf alkfj aflkja faklfjnafjklnafjkafjakfnajkflajfasflkjanfjka faff fajf ajhf afhj afhja fhjabfajklfnasfkjfnafjk sfasjhfbakfjasjknfjakfnasjkfnajfknakjfnjkfnsjfkansfjkadlnfkjafn ckajfnajklf"
        eventAttendees?.text = "ajgnfakf alkfj aflkja faklfjnafjklnafjkafjakfnajkflajfasflkjanfjka faff fajf ajhf afhj afhja fhjabfajklfnasfkjfnafjk sfasjhfbakfjasjknfjakfnasjkfnajfknakjfnjkfnsjfkansfjkadlnfkjafn ckajfnajklf"
        
        // MMM d, EEEE, h:mm a
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE, MMM d, h:mm a"
        
        if let date = dateFormatterGet.date(from: textDate) {
            eventDate?.text = dateFormatterPrint.string(from: date)
            print(dateFormatterPrint.string(from: date))
        } else {
            print("There was an error decoding the string")
        }
        
        eventCategory?.text = textCategory
        eventLocation?.text = textLocation
    }
    
}
