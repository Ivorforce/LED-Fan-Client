//
//  OpenGLDownloader.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 26.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "OpenGL deprecated")
class DefaultShader: Shader {
    var _position: Attribute = .none
    var _texCoord: Attribute = .none

    var vertexBuffer = DrawVertexBuffer()

    var guImage: GLint = 0

    override func compile(vertex: String, fragment: String) throws {
        try super.compile(vertex: vertex, fragment: fragment)
        let floatSize = GLsizei(MemoryLayout<GLfloat>.size)
        
        _position = find(attribute: "position")
        glEnableVertexAttribArray(GLuint(_position.rawValue))
        glVertexAttribPointer(GLuint(_position.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), floatSize * 4, nil)
        OpenGL.checkErrors(context: "Vertex Attrib Array")

        _texCoord = find(attribute: "texCoord")
        glEnableVertexAttribArray(GLuint(_texCoord.rawValue))
        glVertexAttribPointer(GLuint(_texCoord.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), floatSize * 4, UnsafeRawPointer(bitPattern: Int(floatSize) * 2))
        OpenGL.checkErrors(context: "Vertex Attrib Array")

        guImage = find(uniform: "image").rawValue

        try checkUniformError()
    }
    
    @discardableResult
    func drawFullScreenRect(texture: GLuint, textureSize: NSSize) -> Bool {
        glBindTexture(GLenum(GL_TEXTURE_RECTANGLE), texture);
        glUniform1i(guImage, 0);

        guard bind() else {
            print("Failed to bind shader!")
            return false
        }

        vertexBuffer.textureSize = textureSize
        vertexBuffer.bind()
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4);

        return true
    }
}

@available(*, deprecated, message: "OpenGL deprecated")
class OpenGLDownloader {
    var oglContext: NSOpenGLContext

    var shader: DefaultShader?
    var fbo: Framebuffer?

    var textureBuffer: Data = Data()
    
    static func defaultPixelFormatAttributes() -> [Int] {
        return [
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFADepthSize, 24,
            NSOpenGLPFAOpenGLProfile,
            NSOpenGLProfileVersion3_2Core
        ]
    }
    
    static func createOpenGLContext(attributes: [Int]) -> NSOpenGLContext? {
        let typedAttributes = attributes.map { NSOpenGLPixelFormatAttribute($0) } + [.init(0)]
        
        guard let format = NSOpenGLPixelFormat(attributes: typedAttributes) else {
            print("Failed to set up pixel format")
            return nil
        }
        
        guard let oglContext = NSOpenGLContext(format: format, share: nil) else {
            print("Failed to set up OpenGL context")
            return nil
        }
        
        return oglContext
    }

    init(context: NSOpenGLContext) {
        self.oglContext = context
    }
    
    func downloadTexture(textureID: GLuint, textureSize: NSSize) -> CGImage? {
        let samplesPerPixel = 3
        let width = Int(textureSize.width)
        let height = Int(textureSize.height)

        let expectedBufferSize = width * height * samplesPerPixel
        if textureBuffer.count != expectedBufferSize {
            // Reshape
            textureBuffer.count = expectedBufferSize
        }

        oglContext.makeCurrentContext()
        OpenGL.checkErrors(context: "Enter Context")
                
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
            return nil
        }
        
        if fbo == nil {
            let fbo = Framebuffer()
            self.fbo = fbo
            fbo.texture.colorSpace = GL_RGB
        }
        guard let fbo = fbo else { fatalError() }
                
        fbo.size = textureSize
        OpenGL.checkErrors(context: "Setup")

        glActiveTexture(GLenum(GL_TEXTURE0));
        
        fbo.texture.unbind()
        fbo.bind()
        glViewport(0, 0, GLsizei(width), GLsizei(height));
        OpenGL.checkErrors(context: "Viewport")

        guard shader.drawFullScreenRect(texture: textureID, textureSize: textureSize) else {
            return nil
        }

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
            return nil
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
            return nil
        }

        return cgImage
    }
}
