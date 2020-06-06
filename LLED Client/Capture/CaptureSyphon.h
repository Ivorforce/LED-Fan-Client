//
//  CaptureSyphon.h
//  LLED Client
//
//  Created by Lukas Tenbrink on 04.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Syphon/Syphon.h>
#import "ImageCapture.h"

@class Framebuffer;
@class DefaultShader;

NS_ASSUME_NONNULL_BEGIN

@interface CaptureSyphon : ImageCapture {
    NSDictionary *currentDescription;

    NSOpenGLContext *oglContext;

    DefaultShader *shader;
    Framebuffer *fbo;
    GLuint vertexArrayObject;
    GLuint vertexBuffer;

    NSMutableData *textureBuffer;
    NSImage *currentTexture;
}

+ (BOOL)checkGLError:(NSString *)description;
+ (BOOL)checkCompiled:(GLuint)obj;
+ (BOOL)checkLinked:(GLuint)obj;

@property (nonatomic, retain) NSString *captureID;

@property (nonatomic, retain) SyphonClient *syphon;

@end

NS_ASSUME_NONNULL_END
