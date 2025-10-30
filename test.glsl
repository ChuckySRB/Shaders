

void mainImage( out vec4 fragColor, in vec2 fragCoord ) { 
    vec2 uv = fragCoord / iResolution * 2.0 - 1.0;

    float d =length(uv);

    fragColor = vec4(0.5*uv.x, 0.3*uv.y, 0.3, 1); 
}