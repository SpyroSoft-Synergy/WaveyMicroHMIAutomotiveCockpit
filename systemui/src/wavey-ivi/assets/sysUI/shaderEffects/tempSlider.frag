#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D mask;
layout(binding = 2) uniform sampler2D bars;
layout(binding = 3) uniform sampler2D gradient;
layout(binding = 4) uniform sampler2D upGradient;
layout(binding = 5) uniform sampler2D downGradient;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float barsOffset;
    float colorState;
};

vec4 mix3(vec4 min, vec4 center, vec4 max, float value) {
    return clamp(-value, 0., 1.) * min
            + (1. - abs(value)) * center
            + clamp(value, 0., 1.) * max;
}

void main()
{
    float mask = texture(mask, qt_TexCoord0).r;
    float bars = texture(bars, qt_TexCoord0 + vec2(0., barsOffset)).r;
    vec4 color = mix3(texture(downGradient, qt_TexCoord0),
                      texture(gradient, qt_TexCoord0),
                      texture(upGradient, qt_TexCoord0),
                      colorState);

    fragColor = color * (mask*bars*qt_Opacity);
}
