#pragma once

#import <Cocoa/Cocoa.h>

#include <OpenGL/gl3.h>
#include <OpenGL/gl3ext.h>

GLint compileShader(GLuint *shader, GLenum type, GLsizei count, NSString *file);
GLint linkProgram(GLuint prog);
GLint validateProgram(GLuint prog);
void destroyShaders(GLuint vertShader, GLuint fragShader, GLuint prog);

