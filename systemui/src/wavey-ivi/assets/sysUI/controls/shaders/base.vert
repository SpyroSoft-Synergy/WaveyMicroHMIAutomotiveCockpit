VARYING vec2 vL; // neighbouring texels
VARYING vec2 vR;
VARYING vec2 vT;
VARYING vec2 vB;

void MAIN()
{
    vec2 texelSize = 1. / INPUT_SIZE;
    vL = INPUT_UV - vec2(texelSize.x, 0.0);
    vR = INPUT_UV + vec2(texelSize.x, 0.0);
    vT = INPUT_UV + vec2(0.0, texelSize.y);
    vB = INPUT_UV - vec2(0.0, texelSize.y);
}
