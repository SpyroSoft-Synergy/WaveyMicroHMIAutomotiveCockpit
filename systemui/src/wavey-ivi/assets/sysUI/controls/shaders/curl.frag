VARYING vec2 vL; // neighbouring texels
VARYING vec2 vR;
VARYING vec2 vT;
VARYING vec2 vB;

void MAIN()
{
    float L = texture(INPUT, vL).y;
    float R = texture(INPUT, vR).y;
    float T = texture(INPUT, vT).x;
    float B = texture(INPUT, vB).x;
    float vorticity = R - L - T + B;
    FRAGCOLOR = vec4(0.5 * vorticity, -1., -1., -1.);
}
