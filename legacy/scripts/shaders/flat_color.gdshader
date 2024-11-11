shader_type canvas_item;

uniform vec4 fill_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);  // Default to red
uniform float opacity : hint_range(0.0, 1.0) = 1.0;  // Control opacity

void fragment() {
    // Sample the texture using the UV coordinates (built-in)
    vec4 tex_color = texture(TEXTURE, FRAGCOORD.xy / SCREEN_PIXEL_SIZE);

    // Apply the fill color over the texture with opacity control
    COLOR = tex_color * fill_color * opacity;
}
