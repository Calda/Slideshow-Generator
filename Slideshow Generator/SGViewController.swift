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
            let image = NSImage(byReferencingURL: fileFromRoot(file))
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
        
        var session : SGSession = SGSession(videoSize: CGSizeMake(1920,1080))
        
        while let file = enumerator?.nextObject() as? String {
            if !file.lastPathComponent.hasSuffix("png") { continue }
            let nsImage = NSImage(byReferencingURL: fileFromRoot(file))
            let image = SGImage(image: nsImage)
            session.appendImage(image, forDuration: 1.0)
            image.addKeyframeAtTime(CGFloat(0.0), SGKeyframe(scale: 0.1, origin: CGPointMake(300, 400)))
            image.addKeyframeAtTime(CGFloat(1.0), SGKeyframe(scale: 0.2, origin: CGPointMake(1000, 500)))
        }
        
        session.writeToDisk(fileFromRoot("export.mov"))
        
    }
    
    
    func fileRoot() -> NSURL {
        let documentsPath : [String]? = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]?
        let path = documentsPath![0].stringByAppendingPathComponent("/14-15 Student Storage/ Cal Stephens/Slideshow")
        return NSURL(fileURLWithPath: path, isDirectory: true)!
    }
    
    func fileFromRoot(relative: String) -> NSURL {
        let root = fileRoot()
        let path = root.path!.stringByAppendingPathComponent(relative)
        return NSURL(fileURLWithPath: path)!
    }
    
}