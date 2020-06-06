//
//  CaptureSyphon.m
//  LLED Client
//
//  Created by Lukas Tenbrink on 04.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import "CaptureSyphon.h"
#import "LLED_Client-Swift.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>

@interface CaptureSyphon()

- (void)flushCaptureDescription;
- (void)downloadCurrentTexture;

- (void)setUpVertexBuffer;
- (void)uploadVertices;
- (void)drawFullScreenRect;

@end

@implementation CaptureSyphon

- (NSString *)name {
    return @"Capture Syphon";
}

- (void)setCaptureID:(NSString *)captureID {
    _captureID = captureID;
    [self flushCaptureDescription];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
// We get it, OGL is deprecated
// Syphon uses OGL tho

+ (BOOL)checkGLError:(NSString *)description {
    bool errorless = true;
    GLint error;
    while ((error = glGetError()) != 0) {
        NSLog(@"%@: %d", description, error);
        errorless = false;
    }
    return errorless;
}

+ (BOOL)checkCompiled:(GLuint)obj {
    GLint isCompiled = 0;
    glGetShaderiv(obj, GL_COMPILE_STATUS, &isCompiled);
    if(isCompiled == GL_FALSE)
    {
        GLint maxLength = 0;
        glGetShaderiv(obj, GL_INFO_LOG_LENGTH, &maxLength);
        
        GLchar *log = (GLchar *)malloc(maxLength);
        glGetShaderInfoLog(obj, maxLength, &maxLength, log);
        printf("Shader Compile Error: \n%s\n", log);
        free(log);
        
        glDeleteShader(obj);
        return NO;
    }
    
    return YES;
}

+ (BOOL)checkLinked:(GLuint)obj {
    int maxLength = 0;
    glGetProgramiv(obj, GL_INFO_LOG_LENGTH, &maxLength);
    if (maxLength > 0)
    {
        GLchar *log = (GLchar *)malloc(maxLength);
        glGetProgramInfoLog(obj, maxLength, &maxLength, log);
        printf("Shader Program Error: \n%s\n", log);
        free(log);
        
        return NO;
    }
    
    return YES;
}

-(void) flushCaptureDescription {
    NSDictionary *description = [[SyphonServerDirectory sharedDirectory] serverWithID: _captureID];

    if ([description isEqualToDictionary:currentDescription]) {
        return;
    }
        
    NSString *currentUUID = currentDescription[SyphonServerDescriptionUUIDKey];
    NSString *newUUID = description[SyphonServerDescriptionUUIDKey];
    BOOL uuidChange = newUUID && ![currentUUID isEqualToString:newUUID];
    currentDescription = description;

    if (newUUID && currentUUID && !uuidChange) {
        return;
    }
    
    [_syphon stop];
    
    NSOpenGLPixelFormatAttribute attributes[] =
    {
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize    , 24                           ,
        NSOpenGLPFAAlphaSize    , 8                            ,
        NSOpenGLPFADoubleBuffer ,
        NSOpenGLPFAAccelerated  ,
        NSOpenGLPFANoRecovery   ,
        (NSOpenGLPixelFormatAttribute) 0
    };
    
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes: attributes];
    oglContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];

    [oglContext makeCurrentContext];
    fbo = nil;
    vertexBuffer = 0;
    vertexArrayObject = 0;
    shader = nil;

    [self setSyphon: [[SyphonClient alloc] initWithServerDescription:description
                                                       context:[oglContext CGLContextObj]
                                                       options:nil newFrameHandler:^(SyphonClient *client) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self downloadCurrentTexture];
        }];
    }]];
}

- (void)setUpVertexBuffer {
    if (vertexArrayObject > 0) {
        glDeleteVertexArrays(1, &vertexArrayObject);
    }
    if (vertexBuffer > 0) {
        glDeleteBuffers(1, &vertexBuffer);
    }
    [CaptureSyphon checkGLError:@"Vertex Buffer Cleanup"];
    
    glGenVertexArrays(1, &vertexArrayObject);
    [CaptureSyphon checkGLError:@"Vertex Array Gen"];
    glBindVertexArray(vertexArrayObject);
    
    glGenBuffers(1, &vertexBuffer);
    [CaptureSyphon checkGLError:@"Vertex Buffer Gen"];
    [self uploadVertices];
}

- (void)uploadVertices {
    GLfloat vertexData[]= {
        -1, -1, 0, 1,
        -1,  1, 0, 1,
        1,  1, 0, 1,
        1, -1, 0, 1
    };

    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 4*8*sizeof(GLfloat), vertexData, GL_STATIC_DRAW);
    [CaptureSyphon checkGLError:@"Vertex Buffer Upload"];
}

- (void)drawFullScreenRect {
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    [CaptureSyphon checkGLError:@"Bind Vertex Buffer"];
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

-(void)downloadCurrentTexture {
    SyphonImage *frame = [_syphon newFrameImage];

    int samplesPerPixel = 3;
    int width = frame.textureSize.width;
    int height = frame.textureSize.height;

    NSUInteger expectedBufferSize = width * height * samplesPerPixel;
    if ([textureBuffer length] != expectedBufferSize) {
        textureBuffer = [[NSMutableData alloc] initWithLength: expectedBufferSize];
    }
    
    [oglContext makeCurrentContext];
    
    [CaptureSyphon checkGLError:@"Context"];

    if (vertexBuffer <= 0)
        [self setUpVertexBuffer];
    
    if (shader <= 0) {
        shader = [[DefaultShader alloc] init];
        NSError *error;
        [shader compileWithVertexResource:@"default" ofType:@"vs" fragmentResource:@"default" ofType:@"fs" error:&error];
        if (error)
            NSLog(@"%@", error);
    }
    
    if (fbo == nil) {
        fbo = [[Framebuffer alloc] init];
        [[fbo texture] setColorSpace: GL_RGB];
    }
    [CaptureSyphon checkGLError:@"Setup FBO"];

    glActiveTexture(GL_TEXTURE0);
    [CaptureSyphon checkGLError:@"En1"];

    [CaptureSyphon checkGLError:@"Pre"];

    [fbo setSize: frame.textureSize];
    [CaptureSyphon checkGLError:@"Size"];

    [[fbo texture] unbind];
    [fbo bind];
    glViewport(0,0,width,height);

    [CaptureSyphon checkGLError:@"FBO Bind"];
    glBindTexture(GL_TEXTURE_RECTANGLE, frame.textureName);
    [CaptureSyphon checkGLError:@"Rectangle Bind"];
    glUniform1i(shader.guImage, 0);
    [CaptureSyphon checkGLError:@"Uniform"];
    if (![shader bind]) {
        NSLog(@"Shader bind failure!");
        return;
    }
    [self drawFullScreenRect];
    glBindTexture(GL_TEXTURE_RECTANGLE, 0);
    [CaptureSyphon checkGLError:@"Draw"];
//    [Framebuffer unbind];

    [[fbo texture] bind];
    [CaptureSyphon checkGLError:@"FBO"];
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
//    glGetTexImage([[fbo texture] mode], 0, GL_RGB8, GL_UNSIGNED_BYTE, textureBuffer.mutableBytes);

    // For FBO
    glReadPixels(0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, textureBuffer.mutableBytes);
    
    [CaptureSyphon checkGLError:@"Read"];
    [[fbo texture] unbind];
    
    const char* bytes = (const char*)[textureBuffer bytes];
    NSUInteger i = [textureBuffer length] - 1;
    while (bytes[i] == 0 && i > 0)
        i--;

    NSLog(@"%lu of %lu (%lu)", (unsigned long)i, (unsigned long)expectedBufferSize, [textureBuffer length]);
    NSLog(@"%@", textureBuffer);

    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, [textureBuffer bytes], expectedBufferSize, NULL);
    size_t bitsPerComponent = 8;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

    CGImageRef iref = CGImageCreate(width,
                                    height,
                                    bitsPerComponent,
                                    bitsPerComponent * samplesPerPixel, // bits per pixel
                                    samplesPerPixel * width, // bytes per row
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,   // data provider
                                    NULL,       // decode
                                    YES,        // should interpolate
                                    renderingIntent);

    currentTexture = [[NSImage alloc] initWithCGImage:iref size:frame.textureSize];
}

- (NSImage *)grab {
    return currentTexture;
}

#pragma clang diagnostic pop

@end
