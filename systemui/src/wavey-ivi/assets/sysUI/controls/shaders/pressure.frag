layout(binding=0) uniform sampler2D pressureSampler;
layout(binding=1) uniform sampler2D divergenceSampler;

VARYING vec2 vL; // neighbouring texels
VARYING vec2 vR;
VARYING vec2 vT;
VARYING vec2 vB;

void MAIN () {
    float L = texture(pressureSampler, vL).x;
    float R = texture(pressureSampler, vR).x;
    float T = texture(pressureSampler, vT).x;
    float B = texture(pressureSampler, vB).x;
    float C = texture(pressureSampler, INPUT_UV).x;
    float divergence = texture(divergenceSampler, INPUT_UV).x;
    float pressure = (L + R + B + T - divergence) * 0.25;
    FRAGCOLOR = vec4(pressure, -1., -1., -1.);
}
