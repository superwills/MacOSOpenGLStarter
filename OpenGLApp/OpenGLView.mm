#import "OpenGLView.h"
#include <OpenGL/gl3.h>
#import <QuartzCore/CADisplayLink.h>

#include "StopWatch.h"
#import "Shaders.h"

StopWatch sw;

GLuint shaderProgram = 0;

// uniform index
enum {
	UNIFORM_MODELVIEW_PROJECTION_MATRIX,
	NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

bool GL_OK() {
  GLenum err = glGetError() ;
  if( err != GL_NO_ERROR )
    printf( "GLERROR %d\n", err ) ;
  return err == GL_NO_ERROR ;
}

@implementation OpenGLView

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if( !self )  return self;
  
  // Hook in display link creation immediately after construction
  [self createDisplayLink];
  return self;
}

#if 1
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

#endif

- (void) prepareOpenGL {
  [super prepareOpenGL];
  
  // OpenGL ready here.
  const char* glVer = (const char*)glGetString( GL_VERSION );
  const char* glslVer = (const char*)glGetString( GL_SHADING_LANGUAGE_VERSION );
  printf("OpenGL ver=`%s`, glsl ver=`%s`", glVer, glslVer );
  
  [self loadShaders];
  
  struct Vertex {
    float x,y, r,g,b,a;
  };
  const GLfloat verts[] = {
    -0.5, -0.5,  1, 0, 0, 1,
     0.5, -0.5,  0, 1, 0, 1,
    -0.5,  0.5,  0, 0, 1, 1,
     0.5,  0.5,  1, 1, 1, 1,
  };
  
  glGenVertexArrays(1, &vao);  GL_OK();
  glBindVertexArray(vao);  GL_OK();
  
  int vertexSize = 6*sizeof(GLfloat);
  glGenBuffers(1, &vbo); GL_OK();
  glBindBuffer(GL_ARRAY_BUFFER, vbo);  GL_OK();
  glBufferData(GL_ARRAY_BUFFER, 4*vertexSize, verts, GL_STATIC_DRAW);  GL_OK();
  
  // To render data, we have to specify the vertex format of the data first.
  // The data has position & color attributes
  glEnableVertexAttribArray( positionAttrib );  GL_OK();
  glVertexAttribPointer(
    positionAttrib, // integer attribute index
    2,  // Number of data elements per data entry
    GL_FLOAT,  // Data type of the data entries
    GL_FALSE,  // Should the data be normalized (between 0 & 1 (can be used for integer color specs))
    vertexSize,   // Stride (number of bytes to skip, used for interleaved data arrays)
    0  // Data pointer
  );  GL_OK();
  
  
  size_t positionOffset = 2*sizeof(GLfloat);
  // Enable the color vertex attribute
  glEnableVertexAttribArray( colorAttrib );
  glVertexAttribPointer( colorAttrib, 4, GL_FLOAT, GL_FALSE, vertexSize, (const void*)(positionOffset) );  GL_OK();
    
  
  
  

  
  
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
   
	// get uniform locations
	uniforms[UNIFORM_MODELVIEW_PROJECTION_MATRIX] = glGetUniformLocation(shaderProgram, "modelViewProjectionMatrix");  GL_OK();
	
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
  
  // Draw the vertex array
  glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );  GL_OK();
  
  #if 0
  // OpenGL 2.1
  
  glColor3f( 1, .85, .35 );
  
  static float d = 0;
  //d = fabsf( sinf( sw.sec() ) );
  d += .001;
  glBegin(GL_TRIANGLES);
  glVertex3f(  0.0,  0.6, 0.0);
  glVertex3f( -0.2 - d, -0.3, 0.0);
  glVertex3f(  0.2 + d, -0.3 ,0.0);
  glEnd();
  #endif
  
  glFlush();
  [[self openGLContext] flushBuffer]; //REQUIRED.
}


@end
