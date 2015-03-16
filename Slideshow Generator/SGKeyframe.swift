//
//  SGKeyframe.swift
//  Slideshow Generator
//
//  Created by DFA Film D: Scooby on 3/12/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import Foundation

class SGKeyframe : Printable {
    
    var scale : CGFloat
    var origin : CGPoint
    
    var description: String {
        get {
            return "SGKeyframe[scale:\(scale), origin:\(origin)]"
        }
    }
    
    init (scale : CGFloat = 1.0, origin: CGPoint = CGPointMake(0, 0)) {
        self.scale = scale
        self.origin = origin
    }
    
    
    func interpolateWith(other: SGKeyframe, atPercent percent: CGFloat) -> SGKeyframe {
        
        func interpolate(start: CGFloat, end: CGFloat, percent: CGFloat) -> CGFloat {
            let diff = end - start
            return start + (diff * percent)
        }
        
        let scale = interpolate(self.scale, other.scale, percent)
        let x = interpolate(self.origin.x, other.origin.x, percent)
        let y = interpolate(self.origin.y, other.origin.y, percent)
        let origin = CGPointMake(x, y)
        
        return SGKeyframe(scale: scale, origin: origin)
    }
    
    
    func makeFrame(#videoSize: CGSize) -> CGRect {
        let size = CGSizeMake(videoSize.width * scale, videoSize.height * scale)
        return CGRect(origin: origin, size: size)
    }
    
}