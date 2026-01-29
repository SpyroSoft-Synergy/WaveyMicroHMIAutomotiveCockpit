#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float radius;
    float width;
    float height;
};
layout(binding = 1) uniform sampler2D source;


void main() {
    vec2 pos = (abs(qt_TexCoord0 - 0.5) + 0.5) * vec2(width, height);
    vec2 arc_cpt_vec = max(pos - vec2(width, height) + radius + 1, 0.0);
    float alpha = smoothstep( 0.0, 1.0, length(arc_cpt_vec) - radius);
    vec4 tex = texture(source, qt_TexCoord0);
    fragColor = mix(tex,  vec4(0.0), alpha ) * qt_Opacity;
}

