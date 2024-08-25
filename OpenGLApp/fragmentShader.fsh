#version 330

in vec4 VertexColor;
out vec4 PixelColor;

void main() {
	PixelColor = VertexColor;
}
