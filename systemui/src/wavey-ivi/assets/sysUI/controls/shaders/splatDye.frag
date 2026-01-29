
vec4 splat(vec4 base, vec4 color, vec2 point, float pressure) {
    vec2 p = INPUT_UV - point;

    float aspectRatio = OUTPUT_SIZE.x/OUTPUT_SIZE.y;
    p.x *= aspectRatio;

    color.rgb *= color.a;

    vec4 dye = exp(-dot(p, p) / splatRadius) * pressure * color;

    base *= (1. - dye.a);

    return base + dye;
}

void MAIN()
{
    const int pointCount = 3;
    vec3 point[pointCount]= {point0, point1, point2};

    vec4 result = texture(INPUT, INPUT_UV);

    for (int i = 0; i < pointCount; ++i) {
        result = splat(result, color, point[i].xy, point[i].z);
    }

    FRAGCOLOR = result;
}
