//
//  SGImageAsset.swift
//  Slideshow Generator
//
//  Created by DFA Film D: Scooby on 3/12/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import Foundation
import Quartz
import QuartzCore
import CoreGraphics
import AVFoundation

class SGImage {
    
    let image: NSImage
    private var keyframes: [CGFloat : SGKeyframe] = [0.0 : SGKeyframe()]
    
    
    init (image: NSImage) {
        self.image = image
    }
    
    
    func addKeyframeAtTime(time: CGFloat, _ keyframe: SGKeyframe) {
        keyframes.updateValue(keyframe, forKey: time)
    }
    
    
    func frameAtTime(time: CGFloat) -> SGKeyframe {
        var keyBefore : (time: CGFloat, delta: CGFloat) = (0, -10000)
        var keyAfter : (time: CGFloat, delta: CGFloat) = (10000, 10000)
        
        for keyTime in keyframes.keys {
            if keyTime == time {
                return keyframes[time]!
            }
            let delta = keyTime - time
            var other = keyBefore
            var usesBefore = true
            if delta > 0 {
                other = keyAfter
                usesBefore = false
            }
            if abs(delta) < other.delta {
                if usesBefore { keyBefore = (keyTime, delta) }
                else { keyAfter = (keyTime, delta) }
            }
        }
        
        let percentage = (time - keyBefore.time) / (keyAfter.time - keyBefore.time)
        let keyframe1 = keyframes[keyBefore.time]!
        let keyframe2 = keyframes[keyAfter.time]!
        return keyframe1.interpolateWith(keyframe2, atPercent: percentage)
    }
    
    
    func bufferAtTime(time: CGFloat, videoSize: CGSize) -> CVPixelBuffer {
        let frame = frameAtTime(time)
        var imageRect = frame.makeFrame(videoSize: videoSize)
        let image = self.image.CGImageForProposedRect(&imageRect, context: nil, hints: nil)
        
        let options = NSDictionary(objects: [NSNumber(bool: true), NSNumber(bool: true)], forKeys: [kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferCGImageCompatibilityKey])
        
        var pxbuffer : Unmanaged<CVPixelBuffer>?
        
        let frameHeight : CGFloat = self.image.size.height
        let frameWidth : CGFloat  = self.image.size.width
        
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