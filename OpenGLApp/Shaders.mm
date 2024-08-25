#import "Shaders.h"

// Create and compile a shader from the provided source(s)
GLint compileShader(GLuint *shader, GLenum type, GLsizei count, NSString *file)
{
	GLint status;
	const GLchar *sources;
	
	// get source code
	sources = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if( !sources )
	{
		puts( "Failed to load vertex shader" ) ;
		return 0;
	}
	
  *shader = glCreateShader( type ) ;				// create shader
  glShaderSource( *shader, 1, &sources, NULL ) ;	// set source code in the shader
  glCompileShader( *shader ) ;					// compile shader
	
	GLint logLength;
  glGetShaderiv( *shader, GL_INFO_LOG_LENGTH, &logLength ) ;
  if (logLength > 0)
  {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetShaderInfoLog(*shader, logLength, &logLength, log);
    NSLog(@"Shader compile log:\n%s", log);
    free(log);
  }
    
  glGetShaderiv( *shader, GL_COMPILE_STATUS, &status ) ;
  if( status == GL_FALSE )
	{
		puts( "Failed to compile shader:" ) ;
		int i;
		for( i = 0; i < count; i++ )
			puts( sources ) ;
	}
	
	return status;
}


/* Link a program with all currently attached shaders */
GLint linkProgram(GLuint prog)
{
	GLint status;
	glLinkProgram( prog ) ;
	
	GLint logLength ;
  glGetProgramiv( prog, GL_INFO_LOG_LENGTH, &logLength ) ;
  if( logLength > 0 )
  {
    GLchar *log = (GLchar *)malloc( logLength ) ;
    glGetProgramInfoLog( prog, logLength, &logLength, log ) ;
    printf( "Program link log:\n%s", log ) ;
    free( log ) ;
  }
    
  glGetProgramiv( prog, GL_LINK_STATUS, &status ) ;
  if( status == GL_FALSE )
	  printf( "Failed to link program %d", prog ) ;
	
	return status;
}


// Validate a program (for i.e. inconsistent samplers)
GLint validateProgram(GLuint prog)
{
	GLint logLength, status;
	
	glValidateProgram(prog);
  glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
  if( logLength > 0 )
  {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(prog, logLength, &logLength, log);
    printf( "Program validate log:\n%s", log ) ;
    free( log ) ;
  }
  
  glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
  if( status == GL_FALSE )
    NSLog(@"Failed to validate program %d", prog);
	
	return status;
}

// delete shader resources
void destroyShaders(GLuint vertShader, GLuint fragShader, GLuint prog)
{	
	if (vertShader)  glDeleteShader(vertShader);
	if (fragShader)  glDeleteShader(fragShader);
	if (prog)  glDeleteProgram(prog);
}
