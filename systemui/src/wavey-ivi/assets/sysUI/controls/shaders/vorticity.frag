layout(binding=0) uniform sampler2D velocitySampler;
layout(binding=1) uniform sampler2D curlSampler;

VARYING vec2 vL; // neighbouring texels
VARYING vec2 vR;
VARYING vec2 vT;
VARYING vec2 vB;

void MAIN()
{
    float L = texture(curlSampler, vL).x;
    float R = texture(curlSampler, vR).x;
    float T = texture(curlSampler, vT).x;
    float B = texture(curlSampler, vB).x;
    float C = texture(curlSampler, INPUT_UV).x;

    vec2 force = 0.5 * vec2(abs(T) - abs(B), abs(R) - abs(L));
    force /= length(force) + 0.0001;
    force *= curl * C;
    force.y *= -1.0;

    vec4 velocity = texture(velocitySampler, INPUT_UV);
    velocity.xy += force * dt;
    velocity.xy = clamp(velocity.xy, -1000.0, 1000.0);
    FRAGCOLOR = velocity;
}
