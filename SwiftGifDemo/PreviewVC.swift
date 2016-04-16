//
//  PreviewVC.swift
//  SwiftGif
//
//  Created by WANG Michael on 4/15/16.
//  Copyright © 2016 Arne Bahlo. All rights reserved.
//

import Foundation
import UIKit

class PreviewVC: UIViewController {
 
    var caption: Caption!
    var gifData: Gif?
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let finalPreviewURL = UIImage.createImage(gifData, caption: caption)
        let finalImage = UIImage.gifWithNSURL(finalPreviewURL)

        previewImageView.image = finalImage
    }
    
    
    
    //MARK: UINavigation Item functions
    
    @IBAction func doneTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}