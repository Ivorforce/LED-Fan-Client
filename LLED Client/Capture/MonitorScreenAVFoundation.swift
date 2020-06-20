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
        session.sessionPreset = .low
        
        guard let input = AVCaptureScreenInput(displayID: CGMainDisplayID()) else {
            print("Failed to create AVF screen input!")
            return
        }
        input.minFrameDuration = .init(seconds: delay * 1000, preferredTimescale: 1000)
        input.cropRect = desiredSize.centeredFit(bounds: NSScreen.main!.frame)
        input.scaleFactor = desiredSize.width / input.cropRect.width * 2
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: .main)
        session.addOutput(output)
        
        self.captureSession = session
        session.startRunning()
    }
    
    override func stop() {
        captureSession?.stopRunning()
        captureSession = nil
    }
}

extension MonitorScreenAVFoundation: AVCaptureVideoDataOutputSampleBufferDelegate {
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

        _ = self.imageResource.push(LLCGImage(image: cgImage), force: true)
    }
}
