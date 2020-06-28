//
//  OpenGL+VertexBuffer.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 23.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "OpenGL deprecated")
class VertexBuffer {
    var vertexArrayObject: GLuint = 0
    var vertexBuffer: GLuint = 0
    
    var contents: [GLfloat] = [] {
        didSet {
            if contents != oldValue {
                _update()
            }
        }
    }
    
    func _update() {
        guard vertexArrayObject > 0 && vertexBuffer > 0 else {
            return
        }
        
        glBindVertexArray(vertexArrayObject);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), contents.count * MemoryLayout<GLfloat>.size, contents, GLenum(GL_STATIC_DRAW))
        OpenGL.checkErrors(context: "Vertex Buffer Upload")
    }
    
    func bind() {
        create()
        glBindVertexArray(vertexArrayObject);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer);
    }
    
    func create() {
        guard vertexArrayObject <= 0 || vertexBuffer <= 0 else {
            return
        }

        glGenVertexArrays(1, &vertexArrayObject);
        glBindVertexArray(vertexArrayObject);
        
        glGenBuffers(1, &vertexBuffer);
        OpenGL.checkErrors(context: "Vertex Buffer Generation")

        _update()
    }
    
    func delete() {
        if (vertexArrayObject > 0) {
            glDeleteVertexArrays(1, &vertexArrayObject);
        }
        if (vertexBuffer > 0) {
            glDeleteBuffers(1, &vertexBuffer);
        }
        OpenGL.checkErrors(context: "Vertex Buffer Cleanup")
    }
}

@available(*, deprecated, message: "OpenGL deprecated")
class DrawVertexBuffer: VertexBuffer {
    var drawSize = NSSize(width: 1, height: 1) {
        didSet {
            if oldValue != drawSize {
                _flushContents()
            }
        }
    }
    var textureSize = NSSize(width: 1, height: 1) {
        didSet {
            if oldValue != textureSize {
                _flushContents()
            }
        }
    }
    
    func _flushContents() {
        let width = GLfloat(drawSize.width)
        let height = GLfloat(drawSize.height)
        
        let texWidth = GLfloat(textureSize.width)
        let texHeight = GLfloat(textureSize.width)

        contents = [
            -width, -height, 0.0,      0.0,
            -width,  height, 0.0,      texHeight,
             width,  height, texWidth, texHeight,
             width, -height, texWidth, 0.0
        ]
    }
}
