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

- (NSData *) toRGB;

@end

@implementation NSImage(LLEDAdditions)

- (NSData *) toRGB {
    NSImageRep *rep = [[self representations] objectAtIndex: 0];
    
    if (![rep isKindOfClass: [NSBitmapImageRep class]]) {
        return nil;
    }
    
    NSBitmapImageRep *bmp = (NSBitmapImageRep *)rep;
    int samplesPerPixel = [bmp samplesPerPixel];
    
    if (samplesPerPixel == 3) {
        // RGB Already
        int size = [bmp pixelsWide] * [bmp pixelsHigh] * 3;
        return [NSData dataWithBytes:(const void *)[bmp bitmapData] length:sizeof(unsigned char)*size];
    }

    // Gotta Convert
    
    unsigned char *data = [bmp bitmapData];
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

NS_ASSUME_NONNULL_END
