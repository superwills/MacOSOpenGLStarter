#import "WindowDelegate.h"

#include "Superglobals.h"

@implementation WindowDelegate

- (BOOL) windowShouldClose:(id)sender {
  running = false;
  return YES;
}

-(void)windowWillClose:(NSNotification *)notification {
  if( running ) {
    running = false;
    [NSApp terminate:self];
  }
}

@end

