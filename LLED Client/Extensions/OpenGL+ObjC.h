//
//  OpenGL+ObjC.h
//  LLED Client
//
//  Created by Lukas Tenbrink on 06.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGL/OpenGL.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenGLC : NSObject

+ (BOOL)checkCompiled:(GLuint)obj;
+ (BOOL)checkLinked:(GLuint)obj;

@end

NS_ASSUME_NONNULL_END
