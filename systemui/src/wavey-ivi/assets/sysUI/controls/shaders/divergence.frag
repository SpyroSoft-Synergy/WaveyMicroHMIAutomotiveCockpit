VARYING vec2 vL; // neighbouring texels
VARYING vec2 vR;
VARYING vec2 vT;
VARYING vec2 vB;

void MAIN()
{
    float L = texture(INPUT, vL).x;
    float R = texture(INPUT, vR).x;
    float T = texture(INPUT, vT).y;
    float B = texture(INPUT, vB).y;

    vec2 C = texture(INPUT, INPUT_UV).xy;
    if (vL.x < 0.0) { L = -C.x; }
    if (vR.x > 1.0) { R = -C.x; }
    if (vT.y > 1.0) { T = -C.y; }
    if (vB.y < 0.0) { B = -C.y; }

    float div = 0.5 * (R - L + T - B);
    FRAGCOLOR = vec4(div, -1., -1., -1.);
}
