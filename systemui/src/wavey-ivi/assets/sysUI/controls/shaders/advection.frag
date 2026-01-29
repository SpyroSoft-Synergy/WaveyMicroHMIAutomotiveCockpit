layout(binding=0) uniform sampler2D velocitySampler;
layout(binding=1) uniform sampler2D sourceSampler;


void MAIN()
{
    vec2 texelSize = 1. / INPUT_SIZE;

    vec2 coord = INPUT_UV - dt * texture(velocitySampler, INPUT_UV).xy * texelSize;
    vec4 result = texture(sourceSampler, coord);

    float decay = 1.0 + dissipation * dt;
    FRAGCOLOR = result / decay;
}
