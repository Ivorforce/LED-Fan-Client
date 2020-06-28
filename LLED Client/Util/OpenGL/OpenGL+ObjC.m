//
//  OpenGL+ObjC.m
//  LLED Client
//
//  Created by Lukas Tenbrink on 06.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import "OpenGL+ObjC.h"

#import <OpenGL/gl3.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation OpenGLC

+ (BOOL)checkCompiled:(GLuint)obj {
    GLint isCompiled = 0;
    glGetShaderiv(obj, GL_COMPILE_STATUS, &isCompiled);
    if(isCompiled == GL_FALSE)
    {
        GLint maxLength = 0;
        glGetShaderiv(obj, GL_INFO_LOG_LENGTH, &maxLength);
        
        GLchar *log = (GLchar *)malloc(maxLength);
        glGetShaderInfoLog(obj, maxLength, &maxLength, log);
        printf("Shader Compile Error: \n%s\n", log);
        free(log);
        
        glDeleteShader(obj);
        return NO;
    }
    
    return YES;
}

+ (BOOL)checkLinked:(GLuint)obj {
    int maxLength = 0;
    glGetProgramiv(obj, GL_INFO_LOG_LENGTH, &maxLength);
    if (maxLength > 0)
    {
        GLchar *log = (GLchar *)malloc(maxLength);
        glGetProgramInfoLog(obj, maxLength, &maxLength, log);
        printf("Shader Program Error: \n%s\n", log);
        free(log);
        
        return NO;
    }
    
    return YES;
}

@end

#pragma clang diagnostic pop
