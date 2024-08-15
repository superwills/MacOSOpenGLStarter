#import "AppDelegate.h"
#import "MyOpenGLView.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void) applicationDidFinishLaunching:(NSNotification*)aNotification {
  // Insert code here to initialize your application
  MyOpenGLView *view = (MyOpenGLView*)self.window.contentView;
  [view createDisplayLink];
}


- (void) applicationWillTerminate:(NSNotification*)aNotification {
  // Insert code here to tear down your application
}


- (BOOL) applicationSupportsSecureRestorableState:(NSApplication*)app {
  return YES;
}


@end
