#pragma once

#import <Cocoa/Cocoa.h>

@interface MyOpenGLView : NSOpenGLView {
}

- (void) createDisplayLink;
- (void) drawRect:(NSRect)bounds;

@end
