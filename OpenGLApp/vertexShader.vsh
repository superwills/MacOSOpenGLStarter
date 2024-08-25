#version 330

in vec4 position;
in vec4 color;

uniform mat4 modelViewProjectionMatrix;

out vec4 colorVarying;

void main() {
	gl_Position = modelViewProjectionMatrix * position;
	colorVarying = color;
}
