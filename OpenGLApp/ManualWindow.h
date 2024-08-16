#pragma once

// This is really a code dump. Doing a manual window is not a good idea at all,
// because I just don't feel completely comfortable not invoking NSApplicationMain
// Something WILL go wrong if you don't. Probably.
NSWindow* createWindow() {
  NSUInteger windowStyle = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable;

  NSRect screenRect = [[NSScreen mainScreen] frame];
  NSRect windowRect = NSMakeRect(NSMidX(screenRect) - NSMidX(viewRect),
                                 NSMidY(screenRect) - NSMidY(viewRect),
                                 viewRect.size.width,
                                 viewRect.size.height);

  NSWindow *window = [[NSWindow alloc] initWithContentRect:windowRect
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
  
  WindowDelegate *windowDelegate = [[WindowDelegate alloc] init];
  window.delegate = windowDelegate;
  window.acceptsMouseMovedEvents = YES;
  
  // Set app title
  window.title = appName;

  // Add fullscreen button
  window.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;
  [window makeKeyAndOrderFront:nil];
  
  return window;
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
