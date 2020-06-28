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

+ (NSData *)cgImageToRGB:(CGImageRef)image {
    size_t width  = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);

    size_t bytesPerRow = CGImageGetBytesPerRow(image);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(image);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(image);
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;

    CGDataProviderRef provider = CGImageGetDataProvider(image);
    NSData* nsData = CFBridgingRelease(CGDataProviderCopyData(provider));
    long expectedSize = width * height * 3;

    if (bytesPerPixel == 3 && bytesPerRow == bytesPerPixel * width) {
        // RGB Already
        return nsData;
    }

    // Gotta Convert
    const unsigned char* data = [nsData bytes];
    NSMutableData *pixels = [[NSMutableData alloc] initWithCapacity:expectedSize];

    for (int y = 0; y < height; y++) {
        const unsigned char *rowData = data;
        
        if (bytesPerPixel == 3) {
            [pixels appendBytes: rowData length: 3 * width];
        }
        else {
            for (int x = 0; x < width; x++) {
                [pixels appendBytes: rowData length: 3];
                rowData += bytesPerPixel;
            }
        }
        
        data += bytesPerRow;
    }

    return pixels;
}

- (NSData *) toRGB {
    NSImageRep *rep = [[self representations] objectAtIndex: 0];

    if (![rep isKindOfClass: [NSBitmapImageRep class]]) {
        NSLog(@"Unsupported Image Format for RGB!");
        return nil;
    }
    
    NSBitmapImageRep *bmp = (NSBitmapImageRep *)rep;
    long bytesPerPixel = [bmp samplesPerPixel];
    
    unsigned char *data = [bmp bitmapData];
    long expectedSize = [bmp pixelsWide] * [bmp pixelsHigh] * 3;

    if (bytesPerPixel == 3 && [bmp bytesPerRow] == bytesPerPixel * [bmp pixelsWide]) {
        // RGB Already
        return [NSData dataWithBytes:(const void *)data length:sizeof(unsigned char)*expectedSize];
    }

    // Gotta Convert
    
    NSMutableData *pixels = [[NSMutableData alloc] initWithLength:expectedSize];

    for (int y = 0; y < bmp.pixelsHigh; y++) {
        unsigned char *rowData = data;
        
        if (bytesPerPixel == 3) {
            [pixels appendBytes: rowData length: 3 * [bmp pixelsWide]];
        }
        else {
            for (int x = 0; x < bmp.pixelsWide; x++) {
                [pixels appendBytes: rowData length: 3];
                rowData += bytesPerPixel;
            }
        }
        
        data += [bmp bytesPerRow];
    }

    return pixels;
}

@end
