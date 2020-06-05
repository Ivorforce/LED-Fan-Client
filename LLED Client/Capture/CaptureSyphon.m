//
//  CaptureSyphon.m
//  LLED Client
//
//  Created by Lukas Tenbrink on 04.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import "CaptureSyphon.h"
#import "LLED_Client-Swift.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>

@interface CaptureSyphon()

- (void)flushCaptureDescription;
- (void)downloadCurrentTexture;

@end

@implementation CaptureSyphon

- (NSString *)name {
    return @"Capture Syphon";
}

- (void)setCaptureID:(NSString *)captureID {
    _captureID = captureID;
    [self flushCaptureDescription];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
// We get it, OGL is deprecated
// Syphon uses OGL tho

-(void) flushCaptureDescription {
    NSDictionary *description = [[SyphonServerDirectory sharedDirectory] serverWithID: _captureID];

    if ([description isEqualToDictionary:currentDescription]) {
        return;
    }
        
    NSString *currentUUID = currentDescription[SyphonServerDescriptionUUIDKey];
    NSString *newUUID = description[SyphonServerDescriptionUUIDKey];
    BOOL uuidChange = newUUID && ![currentUUID isEqualToString:newUUID];
    currentDescription = description;

    if (newUUID && currentUUID && !uuidChange) {
        return;
    }
    
    [_syphon stop];
    
    NSOpenGLPixelFormatAttribute attributes[] =
    {
        NSOpenGLPFAPixelBuffer,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADepthSize, 24,
        (NSOpenGLPixelFormatAttribute) 0
    };
    
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes: attributes];
    NSOpenGLContext *context = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];

    [self setSyphon: [[SyphonClient alloc] initWithServerDescription:description
                                                       context:[context CGLContextObj]
                                                       options:nil newFrameHandler:^(SyphonClient *client) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self downloadCurrentTexture];
        }];
    }]];
}

-(void)downloadCurrentTexture {
    SyphonImage *frame = [_syphon newFrameImage];
    NSSize imageSize = frame.textureSize;

    int samplesPerPixel = 3;
    int width = imageSize.width;
    int height = imageSize.height;

    NSUInteger expectedBufferSize = width * height * samplesPerPixel;
    if ([textureBuffer length] != expectedBufferSize) {
        textureBuffer = [[NSMutableData alloc] initWithLength: expectedBufferSize];
    }
    
    glReadPixels(0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, textureBuffer.mutableBytes);
    GLenum error = glGetError();
    if (error) {
        NSLog(@"%u", error);
    }

    NSLog(@"%@", textureBuffer);
    currentTexture = [[NSImage alloc] initWithData: textureBuffer];
}

- (NSImage *)grab {
    return currentTexture;
}

#pragma clang diagnostic pop

@end
