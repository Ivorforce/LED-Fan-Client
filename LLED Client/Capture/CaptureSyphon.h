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

NS_ASSUME_NONNULL_BEGIN

@interface CaptureSyphon : ImageCapture {
    NSDictionary *currentDescription;
    NSMutableData *textureBuffer;

    NSImage *currentTexture;
}

@property (nonatomic, retain) NSString *captureID;

@property (nonatomic, retain) SyphonClient *syphon;

@end

NS_ASSUME_NONNULL_END
