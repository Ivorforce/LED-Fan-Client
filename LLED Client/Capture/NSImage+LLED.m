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
    long expectedSize = [bmp pixelsWide] * [bmp pixelsHigh] * 3;

    if (samplesPerPixel == 3 && [bmp bytesPerRow] == samplesPerPixel * [bmp pixelsWide]) {
        // RGB Already
        return [NSData dataWithBytes:(const void *)data length:sizeof(unsigned char)*expectedSize];
    }

    // Gotta Convert
    
    NSMutableData *pixels = [[NSMutableData alloc] init];

    for (int y = 0; y < bmp.pixelsHigh; y++) {
        unsigned char *rowData = data;
        
        for (int x = 0; x < bmp.pixelsWide; x++) {
            [pixels appendBytes: rowData length: 3];
            rowData += samplesPerPixel;
        }
        
        data += [bmp bytesPerRow];
    }

    return pixels;
}

@end
