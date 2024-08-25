#version 330

in vec4 position;
in vec4 color;

// Outputs are the position of the vertex and that vertex's color
out vec4 VertexColor;

void main() {
	gl_Position = position;
	VertexColor = color;
}
