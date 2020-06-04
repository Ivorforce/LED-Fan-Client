//
//  CaptureScreen.h
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ImageCapture <NSObject>

- (NSImage *) grab;

@end

@interface CaptureScreen : NSObject <ImageCapture>

@end

NS_ASSUME_NONNULL_END
