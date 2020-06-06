//
//  OpenGL+Shader.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 06.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

@objc(OpenGLShader) class Shader: NSObject {
    var programID: GLuint? = nil

    @objc
    class func unbind() {
        glUseProgram(0)
    }

    @objc
    @discardableResult
    func bind() -> Bool {
        guard let programID = programID else {
            return false
        }
        
        glUseProgram(programID)
        
        return true
    }
    
    enum CompileFailure : Error {
        case load
        case vertexCompile, fragmentCompile
        case link
        case attribute
        case uniform
    }
    
    @objc
    func compile(vertexResource: String, ofType vertexType: String = "vs", fragmentResource: String, ofType fragmentType: String = "fs") throws {
        guard let vertexPath = Bundle.main.path(forResource: vertexResource, ofType: vertexType),
            let fragmentPath = Bundle.main.path(forResource: fragmentResource, ofType: fragmentType),
            let vertex = try? String(contentsOfFile: vertexPath),
            let fragment = try? String(contentsOfFile: fragmentPath)
            else {
                throw CompileFailure.load
        }
        
        try compile(vertex: vertex, fragment: fragment)
    }

    func compile(vertex: String, fragment: String) throws {
        var vss = (vertex as NSString).utf8String
        var fss = (fragment as NSString).utf8String
        
        var vs = glCreateShader(GLenum(GL_VERTEX_SHADER))
        glShaderSource(vs, 1, &vss, nil)
        glCompileShader(vs)
        
        guard CaptureSyphon.checkCompiled(vs) else {
            throw CompileFailure.vertexCompile
        }
        defer { glDeleteShader(vs) }
        
        var fs = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        glShaderSource(fs, 1, &fss, nil)
        glCompileShader(fs)
        
        guard CaptureSyphon.checkCompiled(fs) else {
            throw CompileFailure.fragmentCompile
        }
        defer { glDeleteShader(fs) }
        
        let programID = glCreateProgram()
        self.programID = programID
        glAttachShader(programID, vs)
        glAttachShader(programID, fs)
        glLinkProgram(programID)
        
        guard CaptureSyphon.checkGLError("Shader Link Error"), CaptureSyphon.checkLinked(programID) else {
            throw CompileFailure.link
        }
    }
    
    func checkAttributeError() throws {
        guard CaptureSyphon.checkGLError("Attribute Error") else {
            throw CompileFailure.attribute
        }
    }

    func checkUniformError() throws {
        guard CaptureSyphon.checkGLError("Uniform Error") else {
            throw CompileFailure.uniform
        }
    }

    func find(uniform: String) -> Uniform {
        let val = glGetUniformLocation(programID!, uniform.cString(using: .ascii))
        if val < 0 { print("No such uniform: \(uniform)") }
        return .init(rawValue: val)
    }

    func find(attribute: String) -> Attribute {
        let val = glGetAttribLocation(programID!, attribute.cString(using: .ascii))
        if val < 0 { print("No such attribute: \(attribute)") }
        return .init(rawValue: val)
    }
}

extension Shader {
    class Uniform: RawRepresentable {
        typealias RawValue = GLint
        
        static let none = Uniform(rawValue: -1)
        var rawValue: RawValue
        
        required init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    
    class Attribute: RawRepresentable {
        typealias RawValue = GLint
        
        static let none = Attribute(rawValue: -1)
        var rawValue: RawValue
        
        required init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

@objc
class DefaultShader: Shader {
    var _position: Attribute = .none

    @objc
    var guImage: GLint = 0

    @objc
    override func compile(vertex: String, fragment: String) throws {
        try super.compile(vertex: vertex, fragment: fragment)
        
        _position = find(attribute: "position")
        glEnableVertexAttribArray(GLuint(_position.rawValue))
        CaptureSyphon.checkGLError("Vertex Attrib Array")
        glVertexAttribPointer(GLuint(_position.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 4), nil)
        try checkAttributeError()

        guImage = find(uniform: "image").rawValue

        try checkUniformError()
    }
}