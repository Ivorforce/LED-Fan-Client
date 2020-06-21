//
//  NSImage+NSImage_LLED.h
//  LLED Client
//
//  Created by Lukas Tenbrink on 04.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (LLEDAdditions)

+ (NSData *) cgImageToRGB: (CGImageRef) image;
- (NSData *) toRGB;

@end

NS_ASSUME_NONNULL_END
