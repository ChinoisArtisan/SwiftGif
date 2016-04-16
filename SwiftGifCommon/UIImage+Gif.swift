//
//  Gif.swift
//  SwiftGif
//
//  Created by Arne Bahlo on 07.06.14.
//  Copyright (c) 2014 Arne Bahlo. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

extension UIImage {

    
    class func extractGifDataWithName(name: String) -> Gif? {
        // Create source from data
        guard let bundleURL = NSBundle.mainBundle()
            .URLForResource(name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        
        // Validate data
        guard let data = NSData(contentsOfURL: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }
        
        return extractData(source)
    }
    
    
    public class func gifWithData(data: NSData) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gifWithURL(gifUrl:String) -> UIImage? {
        // Validate URL
        guard let bundleURL:NSURL? = NSURL(string: gifUrl)
            else {
                print("SwiftGif: This image named \"\(gifUrl)\" does not exist")
                return nil
        }

        // Validate data
        guard let imageData = NSData(contentsOfURL: bundleURL!) else {
            print("SwiftGif: Cannot turn image named \"\(gifUrl)\" into NSData")
            return nil
        }

        return gifWithData(imageData)
    }
    
    public class func gifWithNSURL(gifUrl:NSURL?) -> UIImage? {
        // Validate URL
        guard let bundleURL = gifUrl
            else {
                print("SwiftGif: This image named \"\(gifUrl)\" does not exist")
                return nil
        }
        
        // Validate data
        guard let imageData = NSData(contentsOfURL: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifWithData(imageData)
    }

    public class func gifWithName(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = NSBundle.mainBundle()
          .URLForResource(name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = NSData(contentsOfURL: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gifWithData(imageData)
    }

    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionaryRef = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                unsafeAddressOf(kCGImagePropertyGIFDictionary)),
            CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                unsafeAddressOf(kCGImagePropertyGIFUnclampedDelayTime)),
            AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                unsafeAddressOf(kCGImagePropertyGIFDelayTime)), AnyObject.self)
        }

        delay = delayObject as! Double

        if delay < 0.1 {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }

    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }

        // Swap for modulo
        if a < b {
            let c = a
            a = b
            b = c
        }

        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!

            if rest == 0 {
                return b! // Found it
            } else {
                a = b
                b = rest
            }
        }
    }

    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }
    
    class func extractData(source: CGImageSource) -> Gif? {
        
        let gifObject = Gif()

        let count = CGImageSourceGetCount(source)
        var images = [UIImage]()
        var delays = [Double]()
        
        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(CGImage: image))
            }
            
            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(delaySeconds)
        }
        
        gifObject.delays = delays
        gifObject.frames = images
        
        return gifObject
    }

    class func animatedImageWithSource(source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImageRef]()
        var delays = [Int]()

        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }

            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        // Calculate full duration
        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
            }()

        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(CGImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        // Heyhey
        let animation = UIImage.animatedImageWithImages(frames,
            duration: Double(duration) / 1000.0)

        return animation
    }
    
    
    
    class func createImage (gif: Gif?, caption: Caption) -> NSURL? {
        
        guard let gif = gif else {
            return nil
        }
        
        
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String:         NSNumber(integer: 0)]]
        var frameProperties: NSDictionary = [:]
        
        do {
            let directoryURL = try NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
            let fileURL = directoryURL.URLByAppendingPathComponent("mygif.gif")
            
            
            guard let destination = CGImageDestinationCreateWithURL(fileURL, kUTTypeGIF, gif.frames.count, nil) else {
                return nil
            }
            CGImageDestinationSetProperties(destination, fileProperties as CFDictionaryRef)
            
            
            for i in 0..<gif.frames.count {
                
                let delay: NSNumber = NSNumber(integer: Int(gif.delays[i]))
                frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: delay]]
                
                let modifyFrame = getImageWithCaption(gif.frames[i], caption: caption)
                CGImageDestinationAddImage(destination, modifyFrame.CGImage!, frameProperties as CFDictionaryRef)
            }
            
            
            if (!CGImageDestinationFinalize(destination)) {
                print("Error creating the final GIF")
            }
            else {
                print("Successfully creating the final GIF")
            }
            
            return fileURL
            
        }
        catch {
            return nil
        }
    }
    
    
    class func getImageWithCaption (image: UIImage, caption: Caption) -> UIImage {
        
        //Start creating one frame
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)

        //Draw the image
        image.drawInRect(CGRect(origin: CGPointZero, size: image.size))
        
        //Set the text
        let textFontAttributes = [
            NSFontAttributeName: UIFont(name: "Avenir", size: 20)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        
        caption.text.drawInRect(CGRectMake(0, (image.size.height / 3) * 2, image.size.width, image.size.height / 3), withAttributes: textFontAttributes)
        
        
        //Get the image
        let final = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return final
    }

}
