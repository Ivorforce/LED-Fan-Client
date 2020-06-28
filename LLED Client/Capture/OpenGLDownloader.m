//
//  OpenGLDownloader.m
//  LLED Client
//
//  Created by Lukas Tenbrink on 26.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

#import "OpenGLDownloader.h"
#import "LLED_Client-Swift.h"

@interface OpenGLDownloader ()
@property (readwrite) BOOL needsReshape;
@property (readwrite, retain) NSError *error;

@property NSMutableData *textureData;
@end

@implementation OpenGLDownloader {
    NSSize _imageSize;
    OpenGLShader *shader;
    GLuint _vao;
    GLuint _vbo;
    
    GLuint _fbo;
    GLuint _fboTexture;
}

+ (NSError *)openGLError
{
    return [NSError errorWithDomain:@"info.v002.Syphon.Simple.error"
                               code:-1
                           userInfo:@{NSLocalizedDescriptionKey: @"OpenGL Error"}];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 24,
        NSOpenGLPFAOpenGLProfile,
        NSOpenGLProfileVersion3_2Core,
        0
    };

    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];

    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];

    [self setPixelFormat:pixelFormat];

    [self setOpenGLContext:context];

    self.needsReshape = YES;

    _imageSize = NSMakeSize(0, 0);
}

- (void)dealloc
{
    [shader delete];
    
    if (_vao)
    {
        glDeleteVertexArrays(1, &_vao);
    }
    if (_vbo)
    {
        glDeleteBuffers(1, &_vbo);
    }
}

- (void)prepareOpenGL
{
    [_openGLContext makeCurrentContext];
    const GLint on = 1;
    [[self openGLContext] setValues:&on forParameter:NSOpenGLCPSwapInterval];
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    
    shader = [[OpenGLShader alloc] init];
    [shader compileWithVertexResource:@"default" ofType:@"vs" fragmentResource:@"default" ofType:@"fs" error:nil];

    if ([shader bind])
    {
        GLint tex = glGetUniformLocation([shader programID], "tex");
        glUniform1i(tex, 0);

        glGenVertexArrays(1, &_vao);
        glGenBuffers(1, &_vbo);

        GLint vertCoord = glGetAttribLocation([shader programID], "vertCoord");
        GLint texCoord = glGetAttribLocation([shader programID], "texCoord");

        glBindVertexArray(_vao);
        glBindBuffer(GL_ARRAY_BUFFER, _vbo);

        if (vertCoord != -1 && texCoord != -1)
        {
            glEnableVertexAttribArray(vertCoord);
            glVertexAttribPointer(vertCoord, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), NULL);

            glEnableVertexAttribArray(texCoord);
            glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (GLvoid *)(2 * sizeof(GLfloat)));
        }
        else
        {
            self.error = [[self class] openGLError];
        }

        glGenTextures(1, &_fboTexture);
        glBindTexture(GL_TEXTURE_2D, _fboTexture);

        // Nearest because we don't need to rescale anyway
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        // Clamp because the texture should not need to repeat
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        glGenFramebuffers(1, &_fbo);
        glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
        
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _fboTexture, 0);

        glUseProgram(0);

        _imageSize = NSZeroSize;
        // TODO: maybe some of the above can stay bound
    }
    else
    {
        self.error = [[self class] openGLError];
    }
}

- (void)reshape
{
    self.needsReshape = YES;
}

- (NSSize)renderSize
{
    return self.image.textureSize;
}

- (CGImageRef)downloadImage
{
    [_openGLContext makeCurrentContext];
    SyphonImage *image = self.image;

    BOOL changed = self.needsReshape || !NSEqualSizes(_imageSize, image.textureSize);
    self.needsReshape = changed;

    if (self.needsReshape)
    {
        NSSize frameSize = self.renderSize;

        glViewport(0, 0, frameSize.width, frameSize.height);

        [[self openGLContext] update];

        self.needsReshape = NO;
    }

    if (image && changed)
    {
        _imageSize = image.textureSize;

        NSSize frameSize = self.renderSize;

        NSSize scaled;
        float wr = _imageSize.width / frameSize.width;
        float hr = _imageSize.height / frameSize.height;
        float ratio = (hr < wr ? wr : hr);
        scaled = NSMakeSize(ceilf(_imageSize.width / ratio), ceil(_imageSize.height / ratio));

        // When the view is aspect-restrained, these will always be 1.0
        float width = scaled.width / frameSize.width;
        float height = scaled.height / frameSize.height;

        glBindBuffer(GL_ARRAY_BUFFER, _vbo);

        GLfloat vertices[] = {
            -width, -height,    0.0,                0.0,
            -width,  height,    0.0,                _imageSize.height,
             width, -height,    _imageSize.width,   0.0,
             width,  height,    _imageSize.width,   _imageSize.height
        };

        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        glBindTexture(GL_TEXTURE_2D, _fboTexture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, _imageSize.width, _imageSize.height, 0, GL_RGB, GL_FLOAT, nil);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    if (image)
    {
        [shader bind];
        glBindTexture(GL_TEXTURE_RECTANGLE, image.textureName);

        glBindVertexArray(_vao);

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        {
            glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            
            if (_textureData.length != 3 * _imageSize.width * _imageSize.height) {
                _textureData = [[NSMutableData alloc] initWithLength:3 * _imageSize.width * _imageSize.height];
            }
            glReadPixels(0, 0, _imageSize.width, _imageSize.height, GL_RGB, GL_UNSIGNED_BYTE, [_textureData mutableBytes]);
            glBindFramebuffer(GL_FRAMEBUFFER, 0);

            CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef) _textureData);
            CGImageRef ref = CGImageCreate(_imageSize.width, _imageSize.height, 8, 3 * 8, 3 * _imageSize.width, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault, dataProvider, nil, true, kCGRenderingIntentDefault);
            
            glBindVertexArray(0);
            glBindTexture(GL_TEXTURE_RECTANGLE, 0);
            glUseProgram(0);

            return ref;
        }

        glBindVertexArray(0);
        glBindTexture(GL_TEXTURE_RECTANGLE, 0);
        glUseProgram(0);
    }
    [[self openGLContext] flushBuffer];
    return nil;
}

- (GLuint)compileShader:(const char *)source ofType:(GLenum)type
{
    GLuint shader = glCreateShader(type);

    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);

    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);

    if (status == GL_FALSE)
    {
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

@end
