shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float grayscale_amount : hint_range(0.0, 1.0);

void fragment() {
    vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(color, vec3(gray), grayscale_amount);
    COLOR = vec4(color, 1.0);
}
