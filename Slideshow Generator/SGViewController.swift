//
//  ViewController.swift
//  Slideshow Generator
//
//  Created by DFA Film 9: K-9 on 3/5/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import AVFoundation
import Quartz
import QuartzCore
import CoreGraphics

class SGViewController: NSViewController {

    let fileManager = NSFileManager.defaultManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let root = fileRoot()
        let enumerator = fileManager.enumeratorAtPath(root.path!)
        
        var images : [SGImage] = []
        
        while let file = enumerator?.nextObject() as? String {
            if !file.lastPathComponent.hasSuffix("png") { continue }
            let image = NSImage(byReferencingURL: fileFromRoot(file)!)
            images.append(SGImage(image: image))
        }
        
        let image = images[0]
        image.addKeyframeAtTime(0.0, SGKeyframe(scale: 0.5))
        image.addKeyframeAtTime(1.0, SGKeyframe(scale: 1.0))
        
        println(image.frameAtTime(0.0))
        println(image.frameAtTime(0.25))
        println(image.frameAtTime(0.5))
        println(image.frameAtTime(0.75))
        println(image.frameAtTime(1))
        
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
            if !file.lastPathComponent.hasSuffix("png") { continue }
            let image = NSImage(byReferencingURL: fileFromRoot(file)!)
            images.append(image)
        }

        let videoSettings = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey : NSNumber(int: 1920), AVVideoHeightKey : NSNumber(int: 1080)]
        let writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        
        let adaptorSettings = [kCVPixelBufferPixelFormatTypeKey as NSString : NSNumber(unsignedInteger: kCVPixelFormatType_32ARGB), kCVPixelBufferWidthKey : NSNumber(unsignedInt: 1920), kCVPixelBufferHeightKey : NSNumber(unsignedInt: 1080)]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: adaptorSettings)
        
        let videoWriter = AVAssetWriter(URL: fileFromRoot("test.mov"), fileType: AVFileTypeQuickTimeMovie, error: nil)
        writerInput.expectsMediaDataInRealTime = false
        videoWriter.addInput(writerInput)
        
        videoWriter.startWriting()
        videoWriter.startSessionAtSourceTime(kCMTimeZero)
        
        var totalTime = kCMTimeZero
        for image in images {
            println(CMTimeGetSeconds(totalTime))
            adaptor.appendPixelBuffer(pixelBufferFromImage(image), withPresentationTime: totalTime)
            totalTime = CMTimeAdd(totalTime, CMTimeMake(1,1))
        }
        
        //var result = adaptor.appendPixelBuffer(pixelBufferFromImage(images[1]), withPresentationTime: kCMTimeZero)
        
        //result = adaptor.appendPixelBuffer(pixelBufferFromImage(images[3]), withPresentationTime: CMTimeMake(1,1))
        
        videoWriter.endSessionAtSourceTime(CMTimeAdd(totalTime, CMTimeMake(1,1)))
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
        var imageRect: CGRect = CGRectMake(0, 0, 1920, 1080)
        let image = nsImage.CGImageForProposedRect(&imageRect, context: nil, hints: nil)
        
        let options = NSDictionary(objects: [NSNumber(bool: true), NSNumber(bool: true)], forKeys: [kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferCGImageCompatibilityKey])
        
        var pxbuffer : Unmanaged<CVPixelBuffer>?
        
        let frameHeight : CGFloat = nsImage.size.height
        let frameWidth : CGFloat  = nsImage.size.width
        
        var status = CVPixelBufferCreate(kCFAllocatorDefault, 1920, 1080, OSType(kCVPixelFormatType_32ARGB), options, &pxbuffer)
        
        let buffer = pxbuffer!.takeRetainedValue()
        
        CVPixelBufferLockBaseAddress(buffer, CVOptionFlags(0))
        var pxdata = CVPixelBufferGetBaseAddress(buffer)
        
        let color = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo : CGBitmapInfo = CGBitmapInfo(CGImageAlphaInfo.NoneSkipFirst.rawValue)
        //kCGImageAlphaNoneSkipFirst?
        let context = CGBitmapContextCreate(pxdata, 1920, 1080, 8, 4 * 1920, color, bitmapInfo)
        
        CGContextConcatCTM(context, CGAffineTransformIdentity)
        CGContextDrawImage(context, imageRect, image?.takeUnretainedValue())
        CVPixelBufferUnlockBaseAddress(buffer, CVOptionFlags(0))
        
        return buffer
    }
    
    
}