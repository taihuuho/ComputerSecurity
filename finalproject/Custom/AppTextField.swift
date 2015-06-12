//
//  AppTextField.swift
//  finalproject
//
//  Created by Tai Huu Ho on 6/11/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

import UIKit

class AppTextField: UITextField {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGreenColor().CGColor
        
        if var hint = self.placeholder{
            self.attributedPlaceholder = NSAttributedString(string: hint, attributes: [NSForegroundColorAttributeName : UIColor.lightHintGreenColor()])
        }
        
        
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(bounds.origin.x + 10, bounds.origin.y + 8,
            bounds.size.width - 20, bounds.size.height - 16);
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.textRectForBounds(bounds)
    }
    
    override func drawPlaceholderInRect(rect: CGRect) {
        UIColor.lightGreenColor().setFill()
        super.drawPlaceholderInRect(rect)
    }
}
