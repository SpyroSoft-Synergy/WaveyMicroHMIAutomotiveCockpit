layout(binding=0) uniform sampler2D pressureSampler;
layout(binding=1) uniform sampler2D velocitySampler;

VARYING vec2 vL; // neighbouring texels
VARYING vec2 vR;
VARYING vec2 vT;
VARYING vec2 vB;

void MAIN () {
    float L = texture(pressureSampler, vL).x;
    float R = texture(pressureSampler, vR).x;
    float T = texture(pressureSampler, vT).x;
    float B = texture(pressureSampler, vB).x;
    vec2 velocity = texture(velocitySampler, INPUT_UV).xy;
    velocity.xy -= vec2(R - L, T - B);
    FRAGCOLOR = vec4(velocity, 0.0, 1.0);
}
