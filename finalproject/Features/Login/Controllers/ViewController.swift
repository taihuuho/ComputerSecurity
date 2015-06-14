//
//  ViewController.swift
//  finalproject
//
//  Created by Tai Huu Ho on 6/11/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

import UIKit

class ViewController: BaseViewController {

    @IBOutlet weak var httpButton: UIButton!
    @IBOutlet weak var httpsButton: UIButton!
    @IBOutlet weak var rsaButton: UIButton!
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        RACObserve(Runtime.sharedInstance, "apiProtocolType").subscribeNext({ (a : AnyObject!) -> Void in
//            
//        })
        
//        /print(Runtime.sharedInstance.valueForKey("apiProtocolType"))
//        RACObserve(Runtime.sharedInstance, "apiProtocolType").subscribeNextAs { (type : ApiProtocolType) -> () in
////            if type == ApiProtocolType.HTTPS{
////                self.httpsButton.selected = true
////                self.httpButton.selected = false
////            }else{
////                self.httpsButton.selected = false
////                self.httpButton.selected = true
////            }
//            
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTouchedOnCheckButton(sender: UIButton) {
        
        sender.selected = !sender.selected
        Runtime.sharedInstance.apiProtocolType = httpsButton.selected ? .HTTPs : .HTTP
        Runtime.sharedInstance.useRSA = rsaButton.selected
        
    }
    
    @IBAction func didTouchedOnSubmitButton(sender: UIButton) {
        view.endEditing(true)
        let user =  User()
        user.userName = userNameTextField.text
        user.password = passwordTextField.text
        
        user.signalLogin().deliverOn(RACScheduler.mainThreadScheduler()).subscribeNext({ (response : AnyObject!) -> Void in
            
            Runtime.sharedInstance.user = user
            self.performSegueWithIdentifier("ProfileViewController", sender: self)
            
            print("Logged in successfully")
            }, error: { (error : NSError!) -> Void in
            print(error.debugDescription)
                let dialog = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
                
                dialog.show()
        })
    }
    
    

}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

