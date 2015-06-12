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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTouchedOnCheckButton(sender: UIButton) {
        
        sender.selected = !sender.selected
        
    }
    
    @IBAction func didTouchedOnSubmitButton(sender: UIButton) {
        view.endEditing(true)
        ApiClient.sharedInstance.login(account: userNameTextField.text, password: passwordTextField.text).subscribeNext({ (response : AnyObject!) -> Void in
            
            if let responseDict = response as? NSDictionary{
                
            }
            
            }, error: { (error : NSError!) -> Void in
            
        })
    }
    
    

}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

