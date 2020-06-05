//
//  ImageCapture.h
//  LLED Client
//
//  Created by Lukas Tenbrink on 05.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCapture : NSObject

- (NSString *) name;
- (NSImage *) grab;

@end

NS_ASSUME_NONNULL_END
