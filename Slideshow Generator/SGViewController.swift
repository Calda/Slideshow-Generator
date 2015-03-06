//
//  ViewController.swift
//  Slideshow Generator
//
//  Created by DFA Film 9: K-9 on 3/5/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import Cocoa
import AVFoundation
import Quartz
import QuartzCore
import CoreGraphics

class SGViewController: NSViewController {

    let fileManager = NSFileManager.defaultManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func generatePressed(sender: NSButton) {
        
        let root = fileRoot()
        let enumerator = fileManager.enumeratorAtPath(root.path!)
        
        var images : [NSImage] = []
        
        while let file = enumerator?.nextObject() as? String {
            let image = NSImage(byReferencingURL: fileFromRoot(file)!)
            images.append(image)
        }
        
        let buffer = pixelBufferFromImage(images[0])
        //println(buffer)
        
        println("NOTHING'S WRONG!")
        println("FUCK THIS")

        let videoSettings = [AVVideoCodecH264 : AVVideoCodecKey, NSNumber(int: 1920) : AVVideoWidthKey, NSNumber(int: 1080) : AVVideoHeightKey]
        let writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
        
        let videoWriter = AVAssetWriter(URL: fileFromRoot("test.mp4"), fileType: AVFileTypeMPEG4, error: nil)
        writerInput.expectsMediaDataInRealTime = true
        videoWriter.addInput(writerInput)
    }
    
    
    func fileRoot() -> NSURL {
        let documentsPath : [String]? = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]?
        let path = documentsPath![0].stringByAppendingPathComponent("/14-15 Student Storage/ Cal Stephens/Slideshow")
        return NSURL(fileURLWithPath: path, isDirectory: true)!
    }
    
    func fileFromRoot(relative: String) -> NSURL? {
        let root = fileRoot()
        let path = root.path!.stringByAppendingPathComponent(relative)
        return NSURL(fileURLWithPath: path)
    }
    
    
    func pixelBufferFromImage(nsImage: NSImage) -> CVPixelBuffer {
        var imageRect: CGRect = CGRectMake(0, 0, nsImage.size.width, nsImage.size.height)
        let image = nsImage.CGImageForProposedRect(&imageRect, context: nil, hints: nil)
        
        let options = NSDictionary(objects: [NSNumber(bool: true), NSNumber(bool: true)], forKeys: [kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferCGImageCompatibilityKey])
        
        var pxbuffer : Unmanaged<CVPixelBuffer>?
        
        let frameHeight : CGFloat = 1080.0
        let frameWidth : CGFloat  = 1920.0
        
        var status = CVPixelBufferCreate(kCFAllocatorDefault, 1920, 1080, OSType(kCVPixelFormatType_32ARGB), options, &pxbuffer)
        
        let buffer = pxbuffer!.takeUnretainedValue()
        
        CVPixelBufferLockBaseAddress(buffer, CVOptionFlags(0))
        var pxdata = CVPixelBufferGetBaseAddress(buffer)
        
        let color = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo : CGBitmapInfo = CGBitmapInfo(CGImageAlphaInfo.NoneSkipFirst.rawValue)
        //kCGImageAlphaNoneSkipFirst?
        let context = CGBitmapContextCreate(pxdata, 1020, 1920, 8, 4 * 1920, color, bitmapInfo)
        
        CGContextConcatCTM(context, CGAffineTransformIdentity)
        CGContextDrawImage(context, imageRect, image!.takeRetainedValue())
        CVPixelBufferUnlockBaseAddress(buffer, CVOptionFlags(0))
        
        return buffer
    }
    
    
}