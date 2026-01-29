#version 440

layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;
layout(location = 0) out vec2 texCoord;
layout(location = 1) out vec2 fragCoord;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float splitPercent;
    float fromAngle;
    float toAngle;
    vec2 centerOffset;
    float fastBlurAmount;
    float radius;
    bool clockwise;
    float splitAngle;
    float blurHelperBlurMultiplier;
};

out gl_PerVertex { vec4 gl_Position; };

#define BLUR_HELPER_MAX_LEVEL 64

layout(location = 2) out vec4 blurWeight1;
layout(location = 3) out vec2 blurWeight2;

float blurWeight(float v) {
    return max(0.0, min(1.0, 1.0 - v * 2.0));
}


#define PI 3.14

void main() {
    texCoord = qt_MultiTexCoord0;
    fragCoord = qt_Vertex.xy;
    vec2 vertCoord = qt_Vertex.xy;
    {
        float blurLod = sqrt(fastBlurAmount * (BLUR_HELPER_MAX_LEVEL / 64.0) * 1.8) * 1.2 - 0.2;
        float bw1 = blurWeight(abs(blurLod - 0.1));
        float bw2 = blurWeight(abs(blurLod - 0.3));
        float bw3 = blurWeight(abs(blurLod - 0.5));
        float bw4 = blurWeight(abs(blurLod - 0.7));
        float bw5 = blurWeight(abs(blurLod - 0.9));
        float bw6 = blurWeight(abs(blurLod - 1.1));
    
        float bsum = bw1 + bw2 + bw3 + bw4 + bw5 + bw6;
        blurWeight1 = vec4(bw1 / bsum, bw2 / bsum, bw3 / bsum, bw4 / bsum);
        blurWeight2 = vec2(bw5 / bsum, bw6 / bsum) * radius;
    }
    gl_Position = qt_Matrix * vec4(vertCoord, 0.0, 1.0);
}
