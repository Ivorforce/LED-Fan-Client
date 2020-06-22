//
//  MonitorScreenAVFoundation.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 11.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation
import AVFoundation
import VideoToolbox

class MonitorScreenAVFoundation : ImageCapture {
    override var name: String { "Capture Screen" }
    
    var captureSession: AVCaptureSession?

    var imageSize = NSSize()
    
    override init() {
        
    }
    
    override func start(delay: TimeInterval, desiredSize: NSSize) {
        imageSize = desiredSize
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        if session.canSetSessionPreset(.medium) {
            session.sessionPreset = .medium
        }
        else {
            print("Preset not supported!")
        }
        
        // ------------ Input -----------------

        guard let input = AVCaptureScreenInput(displayID: CGMainDisplayID()) else {
            print("Failed to create AVF screen input!")
            return
        }
        input.minFrameDuration = CMTimeMake(value: 1, timescale: Int32(1.0 / delay))
        input.cropRect = desiredSize.centeredFit(bounds: NSScreen.main!.frame)
        input.scaleFactor = desiredSize.width / input.cropRect.width * 4
        
        guard session.canAddInput(input) else {
            print("Failed to add input!")
            return
        }
        session.addInput(input)
        
        // ------------ Output -----------------
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: .lled(label: "screencapture"))
        output.videoSettings = [:]
        
        guard session.canAddOutput(output) else {
            print("Failed to add output!")
            return
        }
        session.addOutput(output)
        
        // ------------ Start -----------------

        NotificationCenter.default.addObserver(forName: .AVCaptureSessionRuntimeError, object: nil, queue: nil) { notification in
            print(notification)
        }
        self.captureSession = session
        session.commitConfiguration()
        
        session.startRunning()
    }
    
    override func stop() {
        captureSession?.stopRunning()
        captureSession = nil
    }
}

extension MonitorScreenAVFoundation: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Drop it like it's hot")
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to find image buffer!")
            return
        }

//        CVOpenGLTextureRef texture;
//        CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, &texture);
//        CVOpenGLTextureCacheFlush(_textureCache, 0);
//
//        // Manipulate and draw the texture however you want...
//        const GLenum target = CVOpenGLTextureGetTarget(texture);
//        const GLuint name = CVOpenGLTextureGetName(texture);
//
//        // ...
//
//        glEnable(target);
//        glBindTexture(target, name);
//
//        CVOpenGLTextureRelease(texture);

        var cgImageO: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImageO)
        guard let cgImage = cgImageO else {
            print("Failed to create image from image buffer!")
            return
        }

        // TODO instead of resizing on the queue, retain
        //  the buffer and release when used
        guard let resized = LLCGImage(image: cgImage).resized(to: imageSize) else {
            print("Failed to resize!")
            return
        }
        _ = self.imageResource.push(resized)
    }
}
