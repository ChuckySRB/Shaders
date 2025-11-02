// "Genesis Field" — by ChatGPT (for Časlav, 2025)
// A shader about synthetic life awakening — the birth of digital DNA.
// Move mouse: alter the curvature of thought space.
// Time and motion generate emergent living geometry.

#define TAU 6.2831853

// Hash and noise helpers
float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f*f*(3.0 - 2.0*f);
    float n = mix(
        mix(hash21(i + vec2(0,0)), hash21(i + vec2(1,0)), f.x),
        mix(hash21(i + vec2(0,1)), hash21(i + vec2(1,1)), f.x),
        f.y
    );
    return n;
}

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c,-s,s,c);
}

// Chromatic interference palette
vec3 chroma(float t) {
    return 0.6 + 0.4*cos(TAU*(vec3(0.1,0.2,0.3)*t + vec3(0.0,0.33,0.67)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec2 mouse = (iMouse.xy / iResolution.xy - 0.5) * 2.0;
    float time = iTime * 0.25;
    
    // "Curvature" of digital thought field controlled by mouse
    float curvature = 0.5 + 1.5 * length(mouse);
    
    // Warp space — fold coordinates in recursive swirl
    vec2 p = uv;
    float accum = 0.0;
    vec3 color = vec3(0.0);

    for (float i = 0.0; i < 5.0; i++) {
        p *= rot(0.4 + 0.2*sin(time*0.5 + i));
        p += vec2(sin(p.y*3. + time), cos(p.x*2. + time*0.5)) * 0.3;
        float d = length(p);
        float ring = sin(8.0*d - time*3.0 + i*1.2);
        float layer = exp(-2.0*abs(ring)) / (0.5 + 2.0*d);
        vec3 c = chroma(i*0.15 + time + curvature*0.2*sin(i + time*0.3));
        color += c * layer;
        accum += layer;
    }

    color /= accum + 0.001;

    // Digital “neurons” flicker through high-frequency noise
    float neuron = smoothstep(0.8, 1.0, sin(30.0*(uv.x + uv.y) + time*8.0 + noise(uv*10.0)));
    color += 0.05*vec3(0.3,0.5,1.0)*neuron;

    // DNA interference bands — faint lattice overlay
    float dna = sin(uv.y*40.0 + sin(uv.x*6.0 + time*2.0)*3.0 + time*4.0);
    color += 0.03*vec3(0.6,0.2,1.0)*dna;

    // Final glow and tonemapping
    color = pow(color, vec3(0.8));
    color += 0.02*length(uv);

    fragColor = vec4(color,1.0);
}
