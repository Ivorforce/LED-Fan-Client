//
//  FrameReader.h
//  LLED Client
//
//  Created by Lukas Tenbrink on 07.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
  
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
 
- (id)initWithOpenGLContext:(NSOpenGLContext*)context pixelsWide:(unsigned)width pixelsHigh:(unsigned)height;
- (BOOL)readScreenAsyncBegin;
- (CVPixelBufferRef)readScreenAsyncFinish;
- (void)readScreenAsyncOnSeparateThread;
- (NSTimeInterval)bufferReadTime;
- (void)setBufferReadTime:(NSTimeInterval)aStartTime;
 
@end
