//
//  SGSession.swift
//  Slideshow Generator
//
//  Created by DFA Film D: Scooby on 3/16/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import Foundation
import CoreGraphics
import AVFoundation

class SGSession {
    
    let videoSize : CGSize
    var images : [(image: SGImage, start: CGFloat, duration: CGFloat)] = []
    
    init(videoSize: CGSize) {
        self.videoSize = videoSize
    }
    
    func allImages() -> [SGImage] {
        var images : [SGImage] = []
        for (image, _, _) in self.images {
            images.append(image)
        }
        return images
    }
    
    func addImage(image: SGImage, atTime time: CGFloat, forDuration duration: CGFloat) {
        images.append(image: image, start: time, duration: duration)
    }
    
    func appendImage(image: SGImage, forDuration duration: CGFloat) {
        addImage(image, atTime: totalDuration(), forDuration: duration)
    }
    
    func totalDuration() -> CGFloat {
        var latestEndTime : CGFloat = 0.0
        for (_, start, duration) in images {
            let endTime = start + duration
            if endTime > latestEndTime {
                latestEndTime = endTime
            }
        }
        return latestEndTime
    }
    
    func writeToDisk(file: NSURL) {
        let videoSettings = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey : NSNumber(int: Int32(videoSize.width)), AVVideoHeightKey : NSNumber(int: Int32(videoSize.height))]
        let writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        
        let adaptorSettings = [kCVPixelBufferPixelFormatTypeKey as NSString : NSNumber(unsignedInteger: kCVPixelFormatType_32ARGB), kCVPixelBufferWidthKey : NSNumber(unsignedInt: UInt32(videoSize.height)), kCVPixelBufferHeightKey : NSNumber(unsignedInt: UInt32(videoSize.height))]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: adaptorSettings)
        
        let videoWriter = AVAssetWriter(URL: file, fileType: AVFileTypeQuickTimeMovie, error: nil)
        writerInput.expectsMediaDataInRealTime = true
        videoWriter.addInput(writerInput)
        
        videoWriter.startWriting()
        videoWriter.startSessionAtSourceTime(CMTimeMake(0,30))
        
        var totalTime = kCMTimeZero
        for (image, start, duration) in images {
            for i in 0..<Int(duration * 30) {
                while !writerInput.readyForMoreMediaData { }
                
                let buffer = image.bufferAtTime(CGFloat(i) / 30, videoSize: videoSize)
                adaptor.appendPixelBuffer(buffer, withPresentationTime: totalTime)
                totalTime = CMTimeAdd(totalTime, CMTimeMake(1,30))
            }
        }
        totalTime = CMTimeAdd(totalTime, CMTimeMake(1,30))
        videoWriter.endSessionAtSourceTime(totalTime)
        writerInput.markAsFinished()
        videoWriter.finishWritingWithCompletionHandler({})
    }
    
}