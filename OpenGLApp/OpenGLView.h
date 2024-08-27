#pragma once

#import <Cocoa/Cocoa.h>

@class GCKeyboard;

struct V2f { float x=0, y=0; };
struct Vertex {
  float x,y, r,g,b,a;
};

@interface OpenGLView : NSOpenGLView {
  CADisplayLink *displayLink;
  GLuint vao, vbo, shaderProgram;
  GLint positionAttrib, colorAttrib;
  
  GCKeyboard *keyboard;
  V2f leftStick, rightStick;
  V2f lastMouse, diffMouse;
  
  bool leftDown, middleDown, rightDown;
}

- (void) createDisplayLink;

@end
