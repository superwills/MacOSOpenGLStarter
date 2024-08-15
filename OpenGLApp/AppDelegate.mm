#import "AppDelegate.h"
#import "OpenGLView.h"
#include "Superglobals.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void) applicationDidFinishLaunching:(NSNotification*)aNotification {
  // Insert code here to initialize your application
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
  // Cocoa will kill your app on the spot if you don't stop it
  // So if you want to do anything beyond your main loop then include this method.
  running = false;
  return NSTerminateCancel;
}

- (void) applicationWillTerminate:(NSNotification*)aNotification {
  // Insert code here to tear down your application
}

- (BOOL) applicationSupportsSecureRestorableState:(NSApplication*)app {
  return YES;
}


@end
