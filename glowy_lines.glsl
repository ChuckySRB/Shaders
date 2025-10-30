vec3 palette ( float t, vec3 a, vec3 b, vec3 c, vec3 d){
    return a + b*cos( 6.28318*(c*t +d));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 1.5, 0.3);
    vec3 c = vec3(2.5, 1.5, 0.);
    vec3 e = vec3(0.1, 0.2, 0.1);
      
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);
    
    for (float i = 0.0; i < 4.0; i++){
    
        uv = fract(uv * 1.34842) - 0.5;


        float d = length(uv) * exp(-length(uv0));
        vec3 col = palette(length(uv0) + iTime/4. + i*.4, a, b,c, e);

        d = tan(d*15.0 + iTime)/20.;
        d = abs(d);

        d=  0.01/d;
        
        d = pow(0.01 / d, 1.2);

        finalColor += col*d;
    
    }
    

    fragColor = vec4(finalColor, 1); 
}