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

        let videoSettings = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey : NSNumber(int: 1920), AVVideoHeightKey : NSNumber(int: 1080)]
        let writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        
        let adaptorSettings = [kCVPixelBufferPixelFormatTypeKey as NSString : NSNumber(unsignedInteger: kCVPixelFormatType_32ARGB), kCVPixelBufferWidthKey : NSNumber(unsignedInt: 1920), kCVPixelBufferHeightKey : NSNumber(unsignedInt: 1080)]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: adaptorSettings)
        
        println(fileFromRoot("test.mov"))
        let videoWriter = AVAssetWriter(URL: fileFromRoot("test.mov"), fileType: AVFileTypeQuickTimeMovie, error: nil)
        writerInput.expectsMediaDataInRealTime = false
        videoWriter.addInput(writerInput)
        
        println(videoWriter.status.rawValue)
        videoWriter.startWriting()
        println(videoWriter.status.rawValue)
        videoWriter.startSessionAtSourceTime(kCMTimeZero)
        
        
        var buffer = pixelBufferFromImage(images[0])
        var result = adaptor.appendPixelBuffer(buffer, withPresentationTime: kCMTimeZero)
        println(result)
        
        buffer = pixelBufferFromImage(images[1])
        result = adaptor.appendPixelBuffer(buffer, withPresentationTime: CMTimeMake(1,1))
        println(result)
        
        videoWriter.endSessionAtSourceTime(CMTimeMake(2,1))
        writerInput.markAsFinished()
        videoWriter.finishWritingWithCompletionHandler({})
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
        var imageRect: CGRect = CGRectMake(500, 500, nsImage.size.width, nsImage.size.height)
        let image = nsImage.CGImageForProposedRect(&imageRect, context: nil, hints: nil)
        
        let options = NSDictionary(objects: [NSNumber(bool: true), NSNumber(bool: true)], forKeys: [kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferCGImageCompatibilityKey])
        
        var pxbuffer : Unmanaged<CVPixelBuffer>?
        
        let frameHeight : CGFloat = nsImage.size.height
        let frameWidth : CGFloat  = nsImage.size.width
        
        var status = CVPixelBufferCreate(kCFAllocatorDefault, 1920, 1080, OSType(kCVPixelFormatType_32ARGB), options, &pxbuffer)
        
        let buffer = pxbuffer!.takeUnretainedValue()
        
        CVPixelBufferLockBaseAddress(buffer, CVOptionFlags(0))
        var pxdata = CVPixelBufferGetBaseAddress(buffer)
        
        let color = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo : CGBitmapInfo = CGBitmapInfo(CGImageAlphaInfo.NoneSkipFirst.rawValue)
        //kCGImageAlphaNoneSkipFirst?
        let context = CGBitmapContextCreate(pxdata, 1020, 1920, 8, 4 * 1920, color, bitmapInfo)
        
        CGContextConcatCTM(context, CGAffineTransformIdentity)
        CGContextDrawImage(context, imageRect, image?.takeUnretainedValue())
        CVPixelBufferUnlockBaseAddress(buffer, CVOptionFlags(0))
        
        return buffer
    }
    
    
}