//
//  OpenGL+Texture.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 06.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

import OpenGL

@available(*, deprecated, message: "OpenGL deprecated")
@objc class PingPongFramebuffer: NSObject {
    let buffers: [Framebuffer]

    var targetIndex = 0

    var source: Framebuffer?
    var target: Framebuffer { return buffers[targetIndex] }

    var size: CGSize {
        set {
            buffers.forEach { $0.size = newValue }
        }
        get { return buffers.first!.size }
    }
    
    init(count: Int = 2) {
        buffers = (0 ..< count).map { _ in
            Framebuffer()
        }
    }

    func create() {
        buffers.forEach { $0.create() }
    }

    func start() {
        source?.texture.unbind()

        targetIndex = 0
        source = nil

        target.bind()
    }
    
    func next() {
        source = target
        targetIndex = (targetIndex + 1) % buffers.count
        
        target.bind()
        source!.texture.bind()
    }

    func end(rebind: Bool = false) {
        Framebuffer.unbind()
        source = target
        if rebind { source!.texture.bind() }
        else { source!.texture.unbind() }
    }
}

@available(*, deprecated, message: "OpenGL deprecated")
@objc class Framebuffer: NSObject {
    @objc
    let texture = DynamicTexture()
    @objc
    var framebufferID: GLuint = 0;
    
    @objc
    var size: CGSize {
        set { texture.size = newValue }
        get { return texture.size }
    }
    
    @objc
    class func unbind() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0);
    }
    
    @objc
    static var currentlyBound: GLuint {
        var fboID: GLint = 0
        glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &fboID)
        return GLuint(fboID) // Will always be uint
    }
    
    @objc
    func bind() {
        create()
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebufferID);
    }
    
    @objc
    func create() {
        guard framebufferID == 0 else {
            return
        }
        
        texture.create()
        
        glGenFramebuffers(1, &framebufferID);
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebufferID);
        
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), texture.textureID, 0);
        
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if status != GL_FRAMEBUFFER_COMPLETE {
            print("Invalid framebuffer status: \(status)")
        }
    }
}

@available(*, deprecated, message: "OpenGL deprecated")
@objc class DynamicTexture: NSObject {
    @objc
    var textureID: GLuint = 0
    @objc
    var mode: GLenum
    @objc
    var colorSpace: Int32

    @objc
    init(mode: GLint = GL_TEXTURE_2D, colorSpace: Int32 = GL_RGBA) {
        self.mode = GLenum(mode)
        self.colorSpace = colorSpace
    }
    
    @objc
    var image: CGImage? {
        didSet {
            upload()
        }
    }
    @objc
    var size: CGSize {
        get { return _size }
        set {
            guard _size != newValue else {
                return
            }
            _size = newValue
            if textureID > 0 {
                image = nil
            }
        }
    }
    var _size: CGSize = NSZeroSize

    @objc
    class func active(_ unit: Int, run: () -> Void) {
        glActiveTexture(GLenum(Int(GL_TEXTURE0) + unit))
        run()
        glActiveTexture(GLenum(GL_TEXTURE0))
    }
    
    @objc
    @discardableResult
    func bind() -> Bool {
        create()
        glBindTexture(mode, textureID)
        
        return true
    }
    
    @objc
    func unbind() {
        glBindTexture(mode, 0)
    }
    
    @objc
    func create() {
        guard textureID == 0 else {
            return
        }

        glGenTextures(1, &textureID)
        glBindTexture(mode, textureID)
        
        // Nearest because we don't need to rescale anyway
        glTexParameteri(mode, GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST);
        glTexParameteri(mode, GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST);
        // Clamp because the texture should not need to repeat
        glTexParameteri(mode, GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(mode, GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)

        upload()
    }
    
    @objc
    internal func upload() {
        bind()
        
        guard let image = image else {
            glTexImage2D(mode, 0, colorSpace, GLsizei(size.width), GLsizei(size.height), 0, GLenum(colorSpace), GLenum(GL_FLOAT), nil)
            return
        }
        
        guard let data = image.dataProvider?.data else {
            fatalError("Unsupported image for texture!")
        }
        
        _size = NSSize(width: image.width, height: image.height)
        let samplesPerPixel = colorSpace == GL_RGBA ? 4 : 3

        // Set proper unpacking row length for bitmap.
//            glPixelStorei(GLenum(GL_UNPACK_ROW_LENGTH), GLint(size.width))
        
        // Set byte aligned unpacking (needed for 3 byte per pixel bitmaps).
        glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 1);

        glTexImage2D(mode, 0,
                     samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
                     GLsizei(size.width), GLsizei(size.height),
                     0,
                     GLenum(GL_RGBA),
                     GLenum(GL_UNSIGNED_BYTE),
                     CFDataGetBytePtr(data)
        )
    }
    
    @objc
    func download() -> [UInt8] {
        var bytes: [UInt8] = Array(repeating: 0, count: Int(size.width * size.height * 4))
        bind()
        glGetTexImage(mode, 0, GLenum(colorSpace), GLenum(GL_UNSIGNED_BYTE), &bytes)
        return bytes
    }
}
