//
//  OpenGLDownloader.h
//  LLED Client
//
//  Created by Lukas Tenbrink on 26.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>
#import <Syphon/Syphon.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenGLDownloader : NSObject
@property (readwrite, strong) SyphonImage *image;
@property (readonly) NSSize renderSize;
@property (readonly) NSError *error;

@property NSOpenGLContext *openGLContext;
@property NSOpenGLPixelFormat *pixelFormat;

- (void)prepareOpenGL;
- (_Nullable CGImageRef)downloadImage;

@end

NS_ASSUME_NONNULL_END
