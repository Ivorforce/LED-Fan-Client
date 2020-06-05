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
//        NSOpenGLPFAPixelBuffer,
//        NSOpenGLPFANoRecovery,
//        NSOpenGLPFAAccelerated,
//        NSOpenGLPFADepthSize, 24,
        (NSOpenGLPixelFormatAttribute) 0
    };
    
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes: attributes];
    oglContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];

    [self setSyphon: [[SyphonClient alloc] initWithServerDescription:description
                                                       context:[oglContext CGLContextObj]
                                                       options:nil newFrameHandler:^(SyphonClient *client) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self downloadCurrentTexture];
        }];
    }]];
}

-(void)downloadCurrentTexture {
    SyphonImage *frame = [_syphon newFrameImage];

    int samplesPerPixel = 3;
    int width = frame.textureSize.width;
    int height = frame.textureSize.height;

    NSUInteger expectedBufferSize = width * height * samplesPerPixel;
    if ([textureBuffer length] != expectedBufferSize) {
        textureBuffer = [[NSMutableData alloc] initWithLength: expectedBufferSize];
    }
    
    [oglContext makeCurrentContext];
    glBindTexture(GL_TEXTURE_RECTANGLE, frame.textureName);
    
    glGetTexImage(GL_TEXTURE_RECTANGLE, 0, GL_RGB, GL_UNSIGNED_BYTE, textureBuffer.mutableBytes);
    
    // For FBO
//    glReadPixels(0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, textureBuffer.mutableBytes);
    
    GLenum error = glGetError();
    if (error) {
        NSLog(@"%u", error);
    }
    
    const char* bytes = (const char*)[textureBuffer bytes];
    NSUInteger i = [textureBuffer length] - 1;
    while (bytes[i] == 0)
        i--;

    NSLog(@"%lu of %lu (%lu)", (unsigned long)i, (unsigned long)expectedBufferSize, [textureBuffer length]);
    NSLog(@"%@", textureBuffer);

    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, [textureBuffer bytes], expectedBufferSize, NULL);
    size_t bitsPerComponent = 8;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

    CGImageRef iref = CGImageCreate(width,
                                    height,
                                    bitsPerComponent,
                                    bitsPerComponent * samplesPerPixel, // bits per pixel
                                    samplesPerPixel * width, // bytes per row
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,   // data provider
                                    NULL,       // decode
                                    YES,        // should interpolate
                                    renderingIntent);

    currentTexture = [[NSImage alloc] initWithCGImage:iref size:frame.textureSize];
}

- (NSImage *)grab {
    return currentTexture;
}

#pragma clang diagnostic pop

@end
