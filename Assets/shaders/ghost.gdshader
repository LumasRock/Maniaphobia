shader_type canvas_item;

uniform float speed = 2.0;
uniform float amplitude = 10.0;


void vertex() {
	VERTEX.y += sin(TIME * speed) * amplitude;
}