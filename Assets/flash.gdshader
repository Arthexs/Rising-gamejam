shader_type canvas_item;

instance uniform vec4 color: source_color = vec4(1, 1, 1, 1);
instance uniform float t = 0.0;
instance uniform float depth = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 current_pixel = texture(TEXTURE, UV);
	
	COLOR.rgb = mix(current_pixel.rgb, color.rgb, depth*sin(t*PI));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
