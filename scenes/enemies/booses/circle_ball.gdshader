shader_type canvas_item;

void fragment() {
    float dist = distance(UV, vec2(0.5));
    COLOR.a = step(dist, 0.5) * COLOR.a;
}