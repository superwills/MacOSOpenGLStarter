#import "AppDelegate.h"
#import "OpenGLView.h"
#include "Superglobals.h"

#include <OpenGL/gl3.h>

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void) applicationDidFinishLaunching:(NSNotification*)aNotification {
  // Insert code here to initialize your application
  
  glView = (OpenGLView*)self.window.contentView;

}

- (void) applicationWillTerminate:(NSNotification*)aNotification {
  // Insert code here to tear down your application
}

- (BOOL) applicationSupportsSecureRestorableState:(NSApplication*)app {
  return YES;
}


@end
