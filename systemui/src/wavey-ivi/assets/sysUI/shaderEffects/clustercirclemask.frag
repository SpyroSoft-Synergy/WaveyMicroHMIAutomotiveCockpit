#version 440

layout(location = 0) in vec2 texCoord;
layout(location = 1) in vec2 fragCoord;
layout(location = 0) out vec4 fragColor;

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

layout(binding = 1) uniform sampler2D iSource;
layout(binding = 2) uniform sampler2D secondSource;

layout(binding = 3) uniform sampler2D iSourceBlur1;
layout(binding = 4) uniform sampler2D iSourceBlur2;
layout(binding = 5) uniform sampler2D iSourceBlur3;
layout(binding = 6) uniform sampler2D iSourceBlur4;
layout(binding = 7) uniform sampler2D iSourceBlur5;
layout(binding = 8) uniform sampler2D iSourceBlur6;

#define BLUR_HELPER_MAX_LEVEL 64

layout(location = 2) in vec4 blurWeight1;
layout(location = 3) in vec2 blurWeight2;

#define PI 3.14
#define DRAW_BEGIN_BLUR_BELOW_DIFF 2.0
#define SPLIT_BLUR_MAX_DIFF 4.0
#define SPLIT_SOURCE_MAX_DIFF 1.0

void main() {
    fragColor = texture(iSource, texCoord);
    {
        // Commented for qqem - start
    //    float calcSplitPercent = clockwise ? splitPercent : 1.0 - splitPercent; // TODO calculate in QML
    //    float splitAngle = (toAngle - fromAngle) * calcSplitPercent + fromAngle; // TODO calcualte in QML    
    //    if (!clockwise) { splitAngle = 360.0 - splitAngle; }
        // Commented for qqem - end
        
        // Calculate 
        vec2 uv = texCoord - vec2(0.5) - centerOffset;
        // Invert angle to be clockwise
        float angle = (1.0 - (atan(uv.x, uv.y) + PI) / (PI * 2.)) * 360.0;
        float fromAngleDiff = clockwise ? (fromAngle - angle) : (angle - toAngle);
        bool beginGlowPart = false;
        if (angle < fromAngle || angle > toAngle) {
            // Showing glow at beginnging part
            if (splitPercent > 0.0 && fromAngleDiff < DRAW_BEGIN_BLUR_BELOW_DIFF && fromAngleDiff > 0) {
                beginGlowPart = true;
            } else {
                // Ignore values out of range
                discard;
            }
        }
    
        vec4 blurredColor = texture(iSourceBlur1, texCoord) * blurWeight1[0];
        blurredColor += texture(iSourceBlur2, texCoord) * blurWeight1[1];
    #if (BLUR_HELPER_MAX_LEVEL > 2)
        blurredColor += texture(iSourceBlur3, texCoord) * blurWeight1[2];
    #endif
    #if (BLUR_HELPER_MAX_LEVEL > 8)
        blurredColor += texture(iSourceBlur4, texCoord) * blurWeight1[3];
    #endif
    #if (BLUR_HELPER_MAX_LEVEL > 16)
        blurredColor += texture(iSourceBlur5, texCoord) * blurWeight2[0];
    #endif
    #if (BLUR_HELPER_MAX_LEVEL > 32)
        blurredColor += texture(iSourceBlur6, texCoord) * blurWeight2[1];
    #endif
    
        if (!clockwise) {
            angle = 360.0 - angle;
        }
        
        
    // Uncomment to draw debug part of circle that is visible
        //fragColor += vec4(1.0, 0.0, 0.0, 1.0);
    // Uncomment to draw debug line when split angle is
        //if (angle - splitAngle < 0.1 && angle - splitAngle > -0.2) { fragColor += vec4(1.0, 0.0, 0.0, 1.0); }
        
        if (beginGlowPart) {
            fragColor = blurredColor * ((DRAW_BEGIN_BLUR_BELOW_DIFF - fromAngleDiff) / DRAW_BEGIN_BLUR_BELOW_DIFF);
        }
        else if (angle > splitAngle) {
            bool drawBeginAndEndGlows = splitPercent > 0.0 && splitPercent < 1.0;
            vec4 secondSourceColor = texture(secondSource, texCoord);
            float diff = (angle - splitAngle);
            if (drawBeginAndEndGlows && diff < SPLIT_BLUR_MAX_DIFF) {
                // Showing glow near split part          
                secondSourceColor = mix(secondSourceColor, blurredColor, ((SPLIT_BLUR_MAX_DIFF - diff) / SPLIT_BLUR_MAX_DIFF));
            }
            if (drawBeginAndEndGlows && diff < SPLIT_SOURCE_MAX_DIFF) {
                // Blurring split part          
                secondSourceColor += fragColor * ((SPLIT_SOURCE_MAX_DIFF - diff) / SPLIT_SOURCE_MAX_DIFF);
            }
            fragColor = secondSourceColor;
        } 
        else {
            fragColor = blurredColor + fragColor;
        }
    }
    fragColor = fragColor * qt_Opacity;
}
