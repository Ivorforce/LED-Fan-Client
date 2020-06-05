//
//  CaptureScreen.m
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import "CaptureScreen.h"

@implementation CaptureScreen

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enforceSquare = YES;
    }
    return self;
}

- (NSString *)name {
    return @"Capture Screen";
}

- (NSImage *)grab {
    NSRect screenRect = [[NSScreen mainScreen] frame];
    
    if (self.enforceSquare) {
        CGFloat size = MIN(screenRect.size.width, screenRect.size.height);
        screenRect = NSMakeRect(
            screenRect.origin.x + (screenRect.size.width - size) / 2,
            screenRect.origin.y + (screenRect.size.height - size) / 2,
            size,
            size
        );
    }
    
    CGImageRef cgImage = CGWindowListCreateImage(screenRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:rep];
    
    return image;
}

@end
