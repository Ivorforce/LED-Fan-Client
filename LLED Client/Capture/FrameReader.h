//
//  FrameReader.h
//  LLED Client
//
//  Created by Lukas Tenbrink on 07.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface FrameReader : NSObject
{
@private
    NSOpenGLContext*            mGlContext;
    unsigned                mWidth, mHeight;
    unsigned long           mTextureName;
 
    CVPixelBufferPoolRef        mBufferPool;
    CVPixelBufferRef            mPixelBuffer;
    unsigned char*          mBaseAddress;
    unsigned                mBufferRowBytes; 
}
 
+ (NSOpenGLContext *)fullScreenOGLContext;

- (id)initWithOpenGLContext:(NSOpenGLContext*)context pixelsWide:(unsigned)width pixelsHigh:(unsigned)height;
- (BOOL)readScreenAsyncBegin;
- (CVPixelBufferRef)readScreenAsyncFinish;
- (void)readScreenAsyncOnSeparateThread;
 
@end

#pragma clang diagnostic pop
