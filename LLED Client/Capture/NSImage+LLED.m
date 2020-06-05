//
//  NSImage+LLED.m
//  LLED Client
//
//  Created by Lukas Tenbrink on 05.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSImage+LLED.h"

@implementation NSImage(LLEDAdditions)

- (NSData *) toRGB {
    NSImageRep *rep = [[self representations] objectAtIndex: 0];

    if (![rep isKindOfClass: [NSBitmapImageRep class]]) {
        return nil;
    }
    
    NSBitmapImageRep *bmp = (NSBitmapImageRep *)rep;
    long samplesPerPixel = [bmp samplesPerPixel];
    
    unsigned char *data = [bmp bitmapData];

    if (samplesPerPixel == 3) {
        // RGB Already
        long size = [bmp pixelsWide] * [bmp pixelsHigh] * 3;
        return [NSData dataWithBytes:(const void *)data length:sizeof(unsigned char)*size];
    }

    // Gotta Convert
    
    NSMutableData *pixels = [[NSMutableData alloc] init];

    for (int x = 0; x < bmp.pixelsWide; x++) {
        for (int y = 0; y < bmp.pixelsHigh; y++) {
            [pixels appendBytes: data length: 3];
            data += samplesPerPixel;
        }
    }

    return pixels;
}

@end
