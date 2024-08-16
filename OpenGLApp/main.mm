#import <Cocoa/Cocoa.h>

#import "AppDelegate.h"
#import "OpenGLView.h"
#include "Superglobals.h"
#include "StopWatch.h"

// This is the NORMAL way to do it, using a XIB. On iOS UIApplicationMain lets you send
// a class name as the last argument, but strangely MacOS doesn't allow that.
int main( int argc, const char *argv[] ) {
  @autoreleasepool {
    // All this will do is follow what the XIB says to do.
    // So it will create a window for us, laid out and with menus as specified in the XIB,
    // Be sure to set "Autoresizes subviews" off in the view in the XIB to make it respect the sizes you set
    return NSApplicationMain( argc, argv );
  }
}
