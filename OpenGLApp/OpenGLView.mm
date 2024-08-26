#import "OpenGLView.h"
#include <OpenGL/gl3.h>
#import <QuartzCore/CADisplayLink.h>

#include "StopWatch.h"
#import "Shaders.h"

#import <GameController/GCController.h>
#import <GameController/GCPhysicalInputElement.h>
#import <GameController/GCExtendedGamepad.h>
#import <GameController/GCXboxGamepad.h>
#import <GameController/GCControllerButtonInput.h>
#import <GameController/GCControllerDirectionPad.h>
#import <GameController/GCControllerAxisInput.h>

#import <GameController/GCKeyCodes.h>
#import <GameController/GCKeyNames.h>
#import <GameController/GCKeyboard.h>
#import <GameController/GCKeyboardInput.h>

StopWatch sw;

bool GL_OK() {
  GLenum err = glGetError() ;
  if( err != GL_NO_ERROR )
    printf( "GLERROR %d\n", err ) ;
  return err == GL_NO_ERROR ;
}

void log( const char* fmt, ... ) {
  printf( "[%f] ", sw.sec() );
  va_list lp;
  va_start( lp, fmt );
  vprintf( fmt, lp );
  va_end( lp );
  
  puts("");
}

#define info( ... ) log( __VA_ARGS__ )

@implementation OpenGLView

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if( !self )  return self;
  
  // Hook in display link creation immediately after construction
  [self createDisplayLink];
  return self;
}

// Pull profile up from GL 2.1 to GL 4.1
+ (NSOpenGLPixelFormat*) defaultPixelFormat {
  // If you don't override this method the default pixel format you'd get is OpenGL 2.1 and GLSL 1.2
  // Use OpenGL 4.1 and GLSL 4.1
  NSOpenGLPixelFormatAttribute attributes [] = {
    NSOpenGLPFAOpenGLProfile,
    NSOpenGLProfileVersion4_1Core,
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFADepthSize, 32, // 32 bit depth buffer
    NSOpenGLPFAAccelerated,
    0
  };

  return [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
}

- (void) checkKeyboard {
  // https://github.com/manaporkun/gc-input-events/blob/main/GCKeyboardEvents.m
  GCKeyboardInput *input = keyboard.keyboardInput;
  
  //if( input.anyKeyPressed )    puts( "KEY" );
  
  GCControllerButtonInput *A = [input buttonForKeyCode:GCKeyCodeKeyA];
  if( A.pressed ) {
    puts( "A" );
  }
  
  GCControllerButtonInput *B = [input buttonForKeyCode:GCKeyCodeKeyB];
  if( B.pressed ) {
    puts( "B" );
  }
}

- (void) checkController {
  int n = (int)GCController.controllers.count;
  
  if( n ) {
    // there's a controller. poll input.
    // xbox sample here https://github.com/moonlight-stream/moonlight-ios/blob/master/Limelight/Input/ControllerSupport.m
    GCController *controller = GCController.controllers[ 0 ];
    
    //info( "Class type %s", control.extendedGamepad.className.UTF8String );
    if( [controller.extendedGamepad isKindOfClass:[GCXboxGamepad class]] ) {
      //info( "It's an xbox controller" );
      GCXboxGamepad *xboxController = (GCXboxGamepad*)controller.extendedGamepad;
      
      if( xboxController.buttonA.pressed ) {
        info( "you pushed A!" );
      }
      if( xboxController.buttonB.pressed ) {
        info( "you pushed B!" );
      }
      if( xboxController.buttonX.pressed ) {
        info( "you pushed X!" );
      }
      if( xboxController.buttonY.pressed ) {
        info( "you pushed Y!" );
      }
      
      
      leftStick.x = xboxController.leftThumbstick.xAxis.value;
      leftStick.y = xboxController.leftThumbstick.yAxis.value;
      
      rightStick.x = xboxController.rightThumbstick.xAxis.value;
      rightStick.y = xboxController.rightThumbstick.yAxis.value;
      
    }
  }
}

- (void) controllerConnected:(NSNotification*) notification {
  puts( "controllerConnected" );
}
- (void) controllerDisconnected:(NSNotification*) notification {
  puts( "controllerDisconnected" );
}
- (void) keyboardConnected:(NSNotification*) notification {
  puts( "keyboardConnected" );
  keyboard = (GCKeyboard*)notification.object;
}
- (void) keyboardDisconnected:(NSNotification*) notification {
  puts( "keyboardDisconnected" );
}

- (void) initController {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerConnected:) name:GCControllerDidConnectNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDisconnected:) name:GCControllerDidDisconnectNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardConnected:) name:GCKeyboardDidConnectNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDisconnected:) name:GCKeyboardDidDisconnectNotification object:nil];
}

- (void) flushBuffers {

  Vertex verts[] = {
    { -.5f + leftStick.x, -.5f + leftStick.y,  1, 0, 0, 1 }, //LL
    {  .5f + rightStick.x, -.5f + rightStick.y,  0, 1, 0, 1 }, //BR
    { -0.5,  0.5,  0, 0, 1, 1 },
    {  0.5,  0.5,  1, 1, 1, 1 },
  };
  
  glBindBuffer(GL_ARRAY_BUFFER, vbo);  GL_OK();
  glBufferData(GL_ARRAY_BUFFER, 4*sizeof( Vertex ), verts, GL_STATIC_DRAW);  GL_OK();
  
}

- (void) prepareOpenGL {
  [super prepareOpenGL];
  
  // OpenGL ready here.
  const char* glVer = (const char*)glGetString( GL_VERSION );
  const char* glslVer = (const char*)glGetString( GL_SHADING_LANGUAGE_VERSION );
  printf("OpenGL ver=`%s`, glsl ver=`%s`", glVer, glslVer );
  
  [self loadShaders];
  
  glGenVertexArrays(1, &vao);  GL_OK();
  glBindVertexArray(vao);  GL_OK();
  
  glGenBuffers(1, &vbo); GL_OK();
  [self flushBuffers];
  // To render data, we have to specify the vertex format of the data first.
  // The data has position & color attributes
  glEnableVertexAttribArray( positionAttrib );  GL_OK();
  glVertexAttribPointer(
    positionAttrib, // integer attribute index
    2,  // Number of data elements per data entry
    GL_FLOAT,  // Data type of the data entries
    GL_FALSE,  // Should the data be normalized (between 0 & 1 (can be used for integer color specs))
    sizeof( Vertex ),   // Stride (number of bytes to skip, used for interleaved data arrays)
    0  // Data pointer
  );  GL_OK();
  
  
  size_t positionOffset = 2*sizeof(GLfloat);
  // Enable the color vertex attribute
  glEnableVertexAttribArray( colorAttrib );
  glVertexAttribPointer( colorAttrib, 4, GL_FLOAT, GL_FALSE, sizeof( Vertex ), (const void*)(positionOffset) );  GL_OK();
  
  [self initController];
}

- (void) loadShaders {
	puts( "loadShaders" );
	GLuint vertShader = 0, fragShader = 0;
	
  // create shader program
	shaderProgram = glCreateProgram();  GL_OK();
	
	// create and compile vertex shader
	NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"vertexShader" ofType:@"vsh"];
	if (!compileShader(&vertShader, GL_VERTEX_SHADER, 1, vertShaderPathname)) {
		destroyShaders(vertShader, fragShader, shaderProgram);
		return;
	}
	
	// create and compile fragment shader
	NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"fragmentShader" ofType:@"fsh"];
	if (!compileShader(&fragShader, GL_FRAGMENT_SHADER, 1, fragShaderPathname)) {
		destroyShaders(vertShader, fragShader, shaderProgram);
		return;
	}
	
	// attach vertex shader to program
	glAttachShader(shaderProgram, vertShader);  GL_OK();
	
	// attach fragment shader to program
	glAttachShader(shaderProgram, fragShader);  GL_OK();
	
	// link program
	if (!linkProgram(shaderProgram)) {
		destroyShaders(vertShader, fragShader, shaderProgram);
		return;
	}
	
  // Get layout positions, must be done after linking. 
  positionAttrib = glGetAttribLocation(shaderProgram, "position");  GL_OK();
  colorAttrib = glGetAttribLocation(shaderProgram, "color");  GL_OK();
   
	// release vertex and fragment shaders
	if (vertShader) {
		glDeleteShader(vertShader);
		vertShader = 0;
	}
	if (fragShader) {
		glDeleteShader(fragShader);
		fragShader = 0;
	}
	
}

- (void) update:(CADisplayLink*) sender {
  [self checkController];
  [self checkKeyboard];
  [self display];
}

- (void) createDisplayLink {
  displayLink = [self displayLinkWithTarget:self selector:@selector(update:)];
  [displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
  displayLink.preferredFrameRateRange = CAFrameRateRangeMake( 60, 60, 60 );
}

- (void) printFPS {
  static double last = sw.sec();
  double now = sw.sec();
  double diff = now - last;
  //printf( "FPS %f\n", 1/diff );
  last = sw.sec();
}

- (void) drawRect:(NSRect)bounds {
  [[self openGLContext] makeCurrentContext];
  glClearColor( 0, 0, 0, 0 );
  glClear( GL_COLOR_BUFFER_BIT );
  
  //[self printFPS];
  glUseProgram(shaderProgram);
  
  glBindVertexArray( vao );  GL_OK();
  glBindBuffer( GL_ARRAY_BUFFER, vbo );  GL_OK();
  [self flushBuffers];
  
  // Draw the vertex array
  glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );  GL_OK();
  [[self openGLContext] flushBuffer]; //REQUIRED.
}

@end
