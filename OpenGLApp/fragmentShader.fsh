#version 330

in vec4 colorVarying;
out vec4 pixel;

void main() {
	pixel = colorVarying;
}
