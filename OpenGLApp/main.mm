#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "OpenGLView.h"
#include "Superglobals.h"
#import "WindowDelegate.h"
#include "StopWatch.h"

bool running = 0;

#define USE_XIB 0

OpenGLView *view;
NSWindow *window;

StopWatch sw2;

void createWindow() {
  NSUInteger windowStyle = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable;

  NSRect screenRect = [[NSScreen mainScreen] frame];
  NSRect viewRect = NSMakeRect(0, 0, 1024, 768);
  NSRect windowRect = NSMakeRect(NSMidX(screenRect) - NSMidX(viewRect),
                                 NSMidY(screenRect) - NSMidY(viewRect),
                                 viewRect.size.width,
                                 viewRect.size.height);

  window = [[NSWindow alloc] initWithContentRect:windowRect
    styleMask:windowStyle
    backing:NSBackingStoreBuffered
    defer:NO];

  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

  NSMenu *menubar = [NSMenu new];
  NSMenuItem *appMenuItem = [NSMenuItem new];
  [menubar addItem:appMenuItem];
  [NSApp setMainMenu:menubar];

  // Then we add the quit item to the menu. Fortunately the action is simple since terminate: is
  // already implemented in NSApplication and the NSApplication is always in the responder chain.
  NSMenu *appMenu = [NSMenu new];
  NSString *appName = [[NSProcessInfo processInfo] processName];
  NSString *quitTitle = [@"Quit " stringByAppendingString:appName];
  NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:quitTitle
                      action:@selector(terminate:) keyEquivalent:@"q"];
  [appMenu addItem:quitMenuItem];
  [appMenuItem setSubmenu:appMenu];

  NSWindowController *windowController = [[NSWindowController alloc] initWithWindow:window];
  
  view = [[OpenGLView alloc] initWithFrame:viewRect];
  window.contentView = view;

  WindowDelegate *windowDelegate = [[WindowDelegate alloc] init];
  window.delegate = windowDelegate;
  window.acceptsMouseMovedEvents = YES;
  
  // Set app title
  window.title = appName;

  // Add fullscreen button
  window.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;
  [window makeKeyAndOrderFront:nil];
}

void frame() {
  @autoreleasepool {
    NSEvent* ev;
    do {
      ev = [NSApp nextEventMatchingMask: NSEventMaskAny
                              untilDate: nil
                                 inMode: NSDefaultRunLoopMode
                                dequeue: YES];
      if (ev) {
        // handle events here
        [NSApp sendEvent: ev];
      }
    } while( ev );
  }
}

AppDelegate *appDelegate;
int main( int argc, const char *argv[] ) {
  @autoreleasepool {
    #if USE_XIB
    return NSApplicationMain( argc, argv );
    #else
    NSApplication *application = [NSApplication sharedApplication];
    appDelegate = NSApp.delegate = [[AppDelegate alloc] init];
    running = true;

    [NSApp finishLaunching];
    createWindow();
    
    ///*
    [view createDisplayLink];
    [application run];
    //*/
    
    /*
    // unconstrained framerate
    while( running ) {
      double start = sw2.sec();
      frame();
      //Render();
      //[view setNeedsDisplay:YES];
      [view display];
      
      //double end = sw2.sec();
      //double diff = end - start;
      //printf( "The time was %f fps=%f\n", diff, 1/diff );
    }
    //*/
    #endif
  }
}
