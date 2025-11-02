// Synaptic Helix Flow - A shader inspired by AI, DNA, and scientific wonder
// Designed for a modern website background with interactive elements.

// Helper function for color palettes - essential for vibrant, evolving looks
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}

// Perlin-like noise function for organic textures (simplified for performance)
// Source: https://www.shadertoy.com/view/XdXBRH - adapted and simplified
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Multi-octave fractal noise (fBm) for richer detail
float fbm(vec2 p) {
    float total = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) { // 4 octaves
        total += noise(p) * amplitude;
        p = p * 2.0; // Increase frequency
        amplitude *= 0.5; // Decrease amplitude
    }
    return total;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Normalized UV coordinates: -0.5 to 0.5, aspect ratio corrected
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    // Time for animation
    float time = iTime * 0.1; // Slower animation

    // Mouse interaction
    // Normalized mouse position: 0 to 1, or -0.5 to 0.5 if centered
    vec2 mouse = iMouse.xy / iResolution.xy;
    if (iMouse.z < 0.0) { // If mouse is not pressed, use center
        mouse = vec2(0.5, 0.5);
    }
    vec2 mouse_uv = (mouse - 0.5) * 2.0; // -1 to 1 range

    // --- Core Pattern Generation ---

    // A base coordinate system that can be distorted
    vec2 p = uv * 2.5; // Scale up the pattern
    
    // Add time-based rotation and distortion
    float angle = time * 0.5 + length(uv) * 0.1;
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    p = rot * p;

    // Mouse influence: distort the coordinates based on mouse position
    // This creates a "pull" or "flow" effect towards the mouse
    p += mouse_uv * 0.3 * fbm(uv * 1.0 + time * 0.5); // Subtle distortion

    // Further complex distortion with fractal noise, giving a "synaptic" feel
    p.x += fbm(p * 0.8 + time * 0.2) * 0.5;
    p.y += fbm(p * 0.9 - time * 0.3) * 0.5;

    // --- Helical / Swirling Pattern ---
    // Use an atan2-like approach for swirling effects
    float spiral = atan(p.y, p.x);
    float r = length(p);

    // Create a repeating "helix" or "DNA strand" pattern
    float pattern = sin(spiral * 5.0 + r * 15.0 + time * 2.0); // Basic helix
    pattern += cos(spiral * 3.0 - r * 10.0 + time * 1.5); // Second layer
    pattern *= fbm(uv * 5.0 + time * 0.1) * 0.8 + 0.2; // Modulate with noise for organic look

    // Smoothstep to create sharper bands with soft edges
    pattern = smoothstep(-0.6, 0.6, pattern);

    // Add more detail with a small-scale noise layer
    pattern += noise(uv * 50.0 + time * 1.5) * 0.1;
    
    // --- Coloring ---
    vec3 finalColor;

    // Define rich, science-inspired palettes
    // Palette 1: Deep blues, purples, and electric greens (AI/Bio-digital)
    vec3 c1 = palette(pattern + time * 0.1,
                      vec3(0.1, 0.1, 0.3),  // Dark base
                      vec3(0.4, 0.6, 0.8),  // Mid tones
                      vec3(1.0, 1.0, 0.5),  // Frequency scale
                      vec3(0.0, 0.1, 0.2)); // Phase offset

    // Palette 2: Warm pinks, oranges, and subtle yellows (DNA/Organic)
    vec3 c2 = palette(pattern + time * 0.1 + 0.5, // Shift phase
                      vec3(0.2, 0.1, 0.1),  // Dark base
                      vec3(0.8, 0.4, 0.6),  // Mid tones
                      vec3(0.5, 0.7, 0.9),  // Frequency scale
                      vec3(0.3, 0.0, 0.1)); // Phase offset

    // Mix palettes based on a noise function and mouse position
    float blendFactor = fbm(uv * 2.0 + time * 0.3 + mouse_uv.x * 0.5) * 0.5 + 0.5;
    blendFactor = smoothstep(0.3, 0.7, blendFactor); // Sharpen blend edges

    finalColor = mix(c1, c2, blendFactor);
    
    // Add a glowing core / central intensity
    float glow = 1.0 / (1.0 + 20.0 * length(uv + mouse_uv * 0.1)); // Mouse slightly pulls the glow
    finalColor += finalColor * glow * 0.5; // Amplify the color in the center

    // Vignette for a subtle artistic touch (darken edges)
    float vignette = smoothstep(0.0, 1.0, length(uv) * 1.5);
    finalColor *= (1.0 - vignette * 0.3); // Adjust intensity of vignette

    // Final output with some post-processing for vibrancy
    // Exposure and contrast
    finalColor = pow(finalColor, vec3(1.2)); // Gamma correction for brightness/contrast
    finalColor *= 1.2; // Overall brightness

    fragColor = vec4(finalColor, 1.0);
}