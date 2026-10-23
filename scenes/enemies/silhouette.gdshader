shader_type canvas_item;
// Paints the sprite as a flat-colour silhouette (used for the elite's golden outline).

uniform vec4 color : source_color = vec4(1.0, 0.79, 0.24, 1.0);

void fragment() {
	COLOR = vec4(color.rgb, texture(TEXTURE, UV).a * color.a);
}
