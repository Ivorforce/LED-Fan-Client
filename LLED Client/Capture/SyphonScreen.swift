//
//  SyphonScreen.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 06.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

import OpenGL
import GLKit

@available(*, deprecated, message: "OpenGL deprecated")
class SyphonScreen : ImageCapture, ObservableObject {
    var captureID: String = "" {
        didSet {
            objectWillChange.send()
            _flushCapture()
        }
    }
        
    internal var _currentDescription: [String: Any]?
    
    var syphon: SyphonClient?
    var oglContext: NSOpenGLContext?

    var shader: DefaultShader?
    var fbo: Framebuffer?
    var vertexArrayObject: GLuint = 0
    var vertexBuffer: GLuint = 0

    var textureBuffer: Data = Data()
    var currentTexture: NSImage?
    
    func stop() {
        syphon?.stop()
        syphon = nil
        
        oglContext = nil
        shader = nil
        fbo = nil
        
        vertexArrayObject = 0
        vertexBuffer = 0
        
        currentTexture = nil
    }
    
    func _flushCapture() {
        guard let description = SyphonServerDirectory.shared()?.server(withID: captureID) else {
            stop()
            return
        }
        
        let currentCaptureID = _currentDescription?[SyphonServerDescriptionUUIDKey] as? String
        guard currentCaptureID != captureID else {
            return // No change
        }

        // Clean up, then re-setup
        stop()
        
        let glPFAttributes:[NSOpenGLPixelFormatAttribute] = [
            .init(NSOpenGLPFAOpenGLProfile), .init(NSOpenGLProfileVersion3_2Core),
            .init(NSOpenGLPFAColorSize), .init(24),
            .init(NSOpenGLPFAAlphaSize), .init(8),
            .init(NSOpenGLPFADoubleBuffer),
            .init(NSOpenGLPFAAccelerated),
            .init(NSOpenGLPFANoRecovery),
            .init(0)
        ]
        
        guard let format = NSOpenGLPixelFormat(attributes: glPFAttributes) else {
            print("Failed to set up pixel format")
            stop()
            return
        }
        
        guard let oglContext = NSOpenGLContext(format: format, share: nil) else {
            print("Failed to set up OpenGL context")
            stop()
            return
        }
        
        self.oglContext = oglContext
        oglContext.makeCurrentContext()
        
        syphon = SyphonClient(serverDescription: description, context: oglContext.cglContextObj, options: nil) { syphon in
            self.downloadCurrentTexture()
        }
    }
    
    func drawFullScreenRect() {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer);
        OpenGL.checkErrors(context: "Bind Vertex Buffer")
        glDrawArrays(GLenum(GL_TRIANGLE_FAN), 0, 4);
    }
    
    func setupVertexBuffer() {
        if (vertexArrayObject > 0) {
            glDeleteVertexArrays(1, &vertexArrayObject);
        }
        if (vertexBuffer > 0) {
            glDeleteBuffers(1, &vertexBuffer);
        }
        OpenGL.checkErrors(context: "Vertex Buffer Cleanup")
        
        glGenVertexArrays(1, &vertexArrayObject);
        glBindVertexArray(vertexArrayObject);
        
        glGenBuffers(1, &vertexBuffer);
        OpenGL.checkErrors(context: "Vertex Buffer Generation")
        
        let vertexData: [GLfloat] = [
            -1, -1, 0, 1,
            -1,  1, 0, 1,
            1,  1, 0, 1,
            1, -1, 0, 1
        ]

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), 4 * 8 * MemoryLayout<GLfloat>.size, vertexData, GLenum(GL_STATIC_DRAW))
        OpenGL.checkErrors(context: "Vertex Buffer Upload")
    }
    
    func downloadCurrentTexture() {
        guard let syphon = syphon, let frame = syphon.newFrameImage(), let oglContext = oglContext else {
            currentTexture = nil
            return
        }
        
        let samplesPerPixel = 3
        let width = Int(frame.textureSize.width)
        let height = Int(frame.textureSize.height)

        let expectedBufferSize = width * height * samplesPerPixel
        if textureBuffer.count != expectedBufferSize {
            // Reshape
            textureBuffer.count = expectedBufferSize
        }

        oglContext.makeCurrentContext()
        OpenGL.checkErrors(context: "Enter Context")
        
        if vertexBuffer <= 0 {
            setupVertexBuffer()
        }
        
        if shader == nil {
            shader = DefaultShader()
            do {
                try shader?.compile(vertexResource: "default", fragmentResource: "default")
            }
            catch let exception {
                print(exception)
            }
        }
        guard let shader = shader, shader.programID != nil else {
            print("No shader!")
            return
        }
        
        if fbo == nil {
            let fbo = Framebuffer()
            self.fbo = fbo
            fbo.texture.colorSpace = GL_RGB
        }
        guard let fbo = fbo else { fatalError() }
                
        fbo.size = frame.textureSize
        OpenGL.checkErrors(context: "Setup")

        glActiveTexture(GLenum(GL_TEXTURE0));
        
        fbo.texture.unbind()
        fbo.bind()
        glViewport(0, 0, GLsizei(width), GLsizei(height));
        OpenGL.checkErrors(context: "Viewport")

        glBindTexture(GLenum(GL_TEXTURE_RECTANGLE), frame.textureName);
        glUniform1i(shader.guImage, 0);
        
        guard shader.bind() else {
            print("Failed to bind shader!")
            return
        }

        drawFullScreenRect()

        glBindTexture(GLenum(GL_TEXTURE_RECTANGLE), 0)
        glPixelStorei(GLenum(GL_PACK_ALIGNMENT), 1)
        OpenGL.checkErrors(context: "Draw")

        textureBuffer.withUnsafeMutableBytes { ptr in
            glReadPixels(0, 0, GLsizei(width), GLsizei(height), GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), ptr)
        }

//        [Framebuffer unbind];
//        fbo.texture.bind()
//        glGetTexImage([[fbo texture] mode], 0, GL_RGB8, GL_UNSIGNED_BYTE, textureBuffer.mutableBytes);

        OpenGL.checkErrors(context: "Read")

        guard let dataProvider = CGDataProvider(data: textureBuffer as NSData) else {
            print("Failed to init data provider")
            return
        }
        let bitsPerComponent = 8
                
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerComponent * samplesPerPixel,
            bytesPerRow: samplesPerPixel * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: .init(),
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            print("Failed to create image!")
            return
        }
        
        currentTexture = NSImage(cgImage: cgImage, size: frame.textureSize)
    }
    
    override var name: String { "Capture Syphon" }
    
    override func grab() -> NSImage {
        currentTexture ?? NSImage()
    }
}
