#pragma once

#import <Cocoa/Cocoa.h>

@class OpenGLView;
@interface AppDelegate : NSObject <NSApplicationDelegate> {
  OpenGLView *glView;
}
@end

