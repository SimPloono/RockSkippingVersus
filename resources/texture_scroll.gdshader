shader_type spatial;

uniform sampler2D water_texture : source_color, filter_nearest, repeat_enable;
uniform vec2 scroll_speed = vec2(0.05, 0.03);
uniform float uv_scale = 4.0;

uniform float wave_height = 0.15;
uniform float wave_frequency = 1.5;
uniform float wave_speed = 1.0;

void vertex() {
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    float wave1 = sin(world_pos.x * wave_frequency + TIME * wave_speed);
    float wave2 = sin(world_pos.z * wave_frequency * 0.8 + TIME * wave_speed * 1.3);

    VERTEX.y += (wave1 + wave2) * 0.5 * wave_height;
}

void fragment() {
    vec2 uv = UV * uv_scale;
    uv += TIME * scroll_speed;
    ALBEDO = texture(water_texture, uv).rgb;
}