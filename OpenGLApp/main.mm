#import <Cocoa/Cocoa.h>

#import "AppDelegate.h"
#import "OpenGLView.h"
#include "Superglobals.h"
#include "StopWatch.h"
#import "WindowDelegate.h"

bool running = 0;
NSRect viewRect = NSMakeRect(0, 0, 1024, 768);

#define USE_XIB 1



#define MANUAL_WINDOW 0

#if !MANUAL_WINDOW

// This is the NORMAL way to do it, using a XIB. On iOS UIApplicationMain lets you send
// a class name as the last argument, but strangely MacOS doesn't allow that.
int main( int argc, const char *argv[] ) {
  @autoreleasepool {
    // All this will do is follow what the XIB says to do.
    // So it will create a window for us, laid out and with menus as specified in the XIB,
    // then it will
    return NSApplicationMain( argc, argv );
  }
}

#else
#include "ManualWindow.h"

AppDelegate *appDelegate;
OpenGLView *view;
NSWindow *window;
StopWatch sw2;

int main( int argc, const char *argv[] ) {
  @autoreleasepool {
    NSApplication *application = [NSApplication sharedApplication];
    appDelegate = NSApp.delegate = [[AppDelegate alloc] init];
    running = true;

    [NSApp finishLaunching];
    window = createWindow();
    
    view = [[OpenGLView alloc] initWithFrame:viewRect];
    window.contentView = view;

  
    
    /*
    // Manual startup with a more "normal" run loop.
    [view createDisplayLink];
    [application run];
    //*/
    
    ///*
    // unconstrained framerate
    while( running ) {
      double start = sw2.sec();
      frame();
      //Render();
      view.needsDisplay = YES;
      //[view display];
      
      //double end = sw2.sec();
      //double diff = end - start;
      //printf( "The time was %f fps=%f\n", diff, 1/diff );
    }
    //*/
  }
}
#endif
