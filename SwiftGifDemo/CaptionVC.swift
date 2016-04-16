//
//  CaptionVC.swift
//  SwiftGif
//
//  Created by WANG Michael on 4/15/16.
//  Copyright © 2016 Arne Bahlo. All rights reserved.
//

import Foundation
import UIKit

class CaptionVC: UIViewController, UITextFieldDelegate {
    
    var gifData: Gif?
    @IBOutlet weak var captionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captionTextField.becomeFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //MARK: Navigation Button Action
    
    @IBAction func cancelTapped(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    //MARK: UITextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        captionTextField.resignFirstResponder()
        return true
    }
    
    
    
    
    //MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? PreviewVC {
            
            vc.caption = Caption(text: self.captionTextField.text ?? "")
            vc.gifData = self.gifData
        }
        
    }
    
}