#pragma once

#import <Cocoa/Cocoa.h>

@interface OpenGLView : NSOpenGLView {
  CADisplayLink *displayLink;
  GLuint vao, vbo;
  GLint positionAttrib, colorAttrib;
}

- (void) createDisplayLink;

@end
