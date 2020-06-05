//
//  CaptureSyphon.h
//  LLED Client
//
//  Created by Lukas Tenbrink on 04.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageCapture.h"

NS_ASSUME_NONNULL_BEGIN

@interface CaptureSyphon : ImageCapture

@property (nonatomic, retain) NSString *captureID;



@end

NS_ASSUME_NONNULL_END
