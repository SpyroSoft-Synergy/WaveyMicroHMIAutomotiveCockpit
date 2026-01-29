
vec2 splat(vec2 base, vec2 velocity, vec2 point, float pressure) {
    vec2 p = INPUT_UV - point;

    float aspectRatio = OUTPUT_SIZE.x/OUTPUT_SIZE.y;
    p.x *= aspectRatio;

    vec2 dye = exp(-dot(p, p) / splatRadius) * pressure * velocity;

    return base + dye;
}

void MAIN()
{
    const int pointCount = 3;
    vec3 point[pointCount]= {point0, point1, point2};
    vec2 velocity[pointCount] = {velocity0, velocity1, velocity2};

    vec2 result = texture(INPUT, INPUT_UV).rg;

    for (int i = 0; i < pointCount; ++i) {
        result = splat(result, velocity[i], point[i].xy, point[i].z);
    }

    FRAGCOLOR = vec4(result, -1., -1);
}
