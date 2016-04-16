//
//  RootViewController.swift
//  SwiftGif
//
//  Created by Arne Bahlo on 10.06.14.
//  Copyright (c) 2014 Arne Bahlo. All rights reserved.
//

import Foundation
import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet weak var gifImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let jeremyGif = UIImage.gifWithName("jeremy")
        gifImageView.image = jeremyGif
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let destinationVC = segue.destinationViewController as! CaptionVC
        destinationVC.gifData = UIImage.extractGifDataWithName("jeremy")
    }
    
}
