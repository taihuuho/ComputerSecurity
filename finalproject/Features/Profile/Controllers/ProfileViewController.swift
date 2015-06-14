//
//  ProfileViewController.swift
//  finalproject
//
//  Created by Tai Huu Ho on 6/12/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {

    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var creditCardLabel: UILabel!
    @IBOutlet weak var ccvLabel: UILabel!
    @IBOutlet weak var ssnLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.firstNameLabel.text = Runtime.sharedInstance.user?.firstName
        self.lastNameLabel.text = Runtime.sharedInstance.user?.lastName
        self.dobLabel.text = Runtime.sharedInstance.user?.dob
        self.creditCardLabel.text = Runtime.sharedInstance.user?.creditCard
        self.ccvLabel.text = Runtime.sharedInstance.user?.CVV
        self.ssnLabel.text = Runtime.sharedInstance.user?.SSN
        self.emailLabel.text = Runtime.sharedInstance.user?.email
        self.phoneLabel.text = Runtime.sharedInstance.user?.phone
        self.addressLabel.text = Runtime.sharedInstance.user?.address
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func didTouchedOnOkButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
