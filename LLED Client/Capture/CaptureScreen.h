//
//  CaptureScreen.h
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageCapture.h"

NS_ASSUME_NONNULL_BEGIN

@interface CaptureScreen : ImageCapture

@property (nonatomic) bool enforceSquare;

@end

NS_ASSUME_NONNULL_END
