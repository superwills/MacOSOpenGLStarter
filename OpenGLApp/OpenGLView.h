#pragma once

#import <Cocoa/Cocoa.h>

@class GCController;
@class GCKeyboard;
@class GCMouse;

@protocol GCDevice;

struct V2f { float x=0, y=0; };
struct Vertex {
  float x,y, r,g,b,a;
};

@interface Listener<ObjectType> : NSObject {
@public
  ObjectType object;
}

@property (readonly) id<GCDevice> device;

- (void) connected:(NSNotification*) notification;
- (void) disconnected:(NSNotification*) notification;
- (void) becameCurrent:(NSNotification*) notification;
- (void) stoppedBeingCurrent:(NSNotification*) notification;
@end

@interface OpenGLView : NSOpenGLView {
  CADisplayLink *displayLink;
  GLuint vao, vbo, shaderProgram;
  GLint positionAttrib, colorAttrib;
  
  // These listener objects are NOT necessary,
  // because you can+should use the GCKeyboard.coaleasedKeyboard, GCMouse.mice, GCController.controllers collections instead.
  Listener<GCKeyboard*> *keyboardListener;
  Listener<GCMouse*> *mouseListener;
  Listener<GCController*> *gamepadListener;
}

- (void) createDisplayLink;

@end
