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
    
    var enforceSquare: Bool = true
    
    var captureSession: AVCaptureSession?
        
    override init() {
        
    }
    
    override func start() {
        let session = AVCaptureSession()
        session.sessionPreset = .low
        
        guard let input = AVCaptureScreenInput(displayID: CGMainDisplayID()) else {
            print("Failed to create AVF screen input!")
            return
        }
        input.minFrameDuration = .init(seconds: 1, preferredTimescale: 30)
        if enforceSquare {
            input.cropRect = NSScreen.main!.frame.centeredSquare()
        }
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
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetWidth(pixelBuffer)

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
            print("Failed to create image frm image buffer!")
            return
        }

        let image = NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
        _ = self.imageResource.push(image, force: true)
    }
}
