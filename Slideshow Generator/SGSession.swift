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
    
    func addImage(image: SGImage, atTime time: CGFloat, forDuration duration: CGFloat) {
        images.append(image: image, start: time, duration: duration)
    }
    
    func writeToDisk(file: NSURL) {
        let videoSettings = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey : NSNumber(int: Int32(videoSize.width)), AVVideoHeightKey : NSNumber(int: Int32(videoSize.height))]
        let writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        
        let adaptorSettings = [kCVPixelBufferPixelFormatTypeKey as NSString : NSNumber(unsignedInteger: kCVPixelFormatType_32ARGB), kCVPixelBufferWidthKey : NSNumber(unsignedInt: UInt32(videoSize.height)), kCVPixelBufferHeightKey : NSNumber(unsignedInt: UInt32(videoSize.height))]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: adaptorSettings)
        
        let videoWriter = AVAssetWriter(URL: file, fileType: AVFileTypeQuickTimeMovie, error: nil)
        writerInput.expectsMediaDataInRealTime = false
        videoWriter.addInput(writerInput)
        
        videoWriter.startWriting()
        videoWriter.startSessionAtSourceTime(kCMTimeZero)
        
        var totalTime = kCMTimeZero
        for (image, start, duration) in images {
            for i in 0..<Int(duration * 30) {
                //write video here
            }
        }
    }
    
}


/*
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
*/