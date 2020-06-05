//
//  CaptureScreen.m
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import "CaptureScreen.h"

@implementation CaptureScreen

- (NSString *)name {
    return @"Capture Screen";
}

- (NSImage *)grab {
    NSRect screenRect = [[NSScreen mainScreen] frame];
    
    CGImageRef cgImage = CGWindowListCreateImage(screenRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:rep];
    
    return image;
}

@end
