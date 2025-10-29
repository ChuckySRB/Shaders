

void mainImage( out vec4 fragColor, in vec2 fragCoord ) { 
    vec2 uv = sin(fragCoord / iResolution.xy * iTime) ; // Output to screen 
    fragColor = vec4(0.5*uv.x, 0.3*uv.y, 0.3, 1); 
}