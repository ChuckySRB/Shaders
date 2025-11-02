// DNA Neural Quantum Field
// A unique shader combining AI, DNA, and quantum computing themes

vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 6; i++) {
        value += amplitude * noise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

vec4 helixField(vec2 uv, float time, vec2 mouse, int layer) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.0, 0.33, 0.67);
    
    // Mouse influence
    vec2 mousePos = (mouse * 2.0 - 1.0) * 2.0;
    uv += mousePos * 0.1;
    
    // DNA helix structure
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    
    // Double helix parameters
    float helix1 = sin(angle * 6.0 + time + float(layer) * 1.57) * 0.1;
    float helix2 = cos(angle * 6.0 + time + float(layer) * 1.57 + 3.14159) * 0.1;
    
    // Neural network connections
    vec2 neuralUV = uv * 3.0 + time * 0.5;
    float neuralPattern = fbm(neuralUV + float(layer) * 5.0);
    
    // Quantum probability field
    vec2 quantumUV = uv * 2.0 + time * 0.3;
    float quantumField = sin(quantumUV.x * 8.0 + time) * cos(quantumUV.y * 8.0 + time);
    
    // Combine elements
    float dnaPattern = helix1 + helix2;
    float combined = dnaPattern * 0.6 + neuralPattern * 0.3 + quantumField * 0.1;
    
    // Create flowing energy along the structure
    float energyFlow = sin(radius * 15.0 - time * 3.0 + float(layer) * 2.0) * 0.5 + 0.5;
    
    // Color based on layer and patterns
    vec3 baseColor = palette(float(layer) * 0.3 + time * 0.1 + combined, a, b, c, d);
    vec3 energyColor = palette(energyFlow + time * 0.2, a, b, c, d);
    
    // Create the main structure with glow
    float structure = smoothstep(0.1, 0.15, abs(radius - 0.5 - combined * 0.2));
    structure = 1.0 - structure;
    
    // Add neural connection points
    float neurons = smoothstep(0.02, 0.03, abs(neuralPattern - 0.5));
    neurons = 1.0 - neurons;
    
    // Combine all elements
    float finalAlpha = max(structure, neurons * 0.7);
    vec3 finalColor = mix(baseColor, energyColor, energyFlow) * finalAlpha;
    
    return vec4(finalColor, finalAlpha);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 mouseUV = iMouse.xy / iResolution.xy;
    
    // Modern color palette with biotech feel
    vec3 a1 = vec3(0.5, 0.5, 0.5);
    vec3 b1 = vec3(0.8, 0.3, 0.6); // Magenta/Pink for DNA
    vec3 c1 = vec3(0.2, 0.8, 0.8); // Cyan for AI/Neural
    vec3 d1 = vec3(0.0, 0.2, 0.5);
    
    vec3 a2 = vec3(0.5, 0.5, 0.5);
    vec3 b2 = vec3(0.3, 0.6, 0.8); // Blue for quantum
    vec3 c2 = vec3(0.8, 0.8, 0.2); // Yellow for energy
    vec3 d2 = vec3(0.1, 0.3, 0.2);
    
    vec4 finalColor = vec4(0.0);
    
    // Create multiple layers for depth and complexity
    for (int i = 0; i < 4; i++) {
        float scale = 1.0 + float(i) * 0.3;
        vec2 layerUV = uv * scale;
        
        // Alternate between two color schemes
        if (i % 2 == 0) {
            vec3 layerColor = palette(float(i) * 0.25 + iTime * 0.1, a1, b1, c1, d1);
            vec4 layer = helixField(layerUV, iTime * (1.0 + float(i) * 0.2), mouseUV, i);
            finalColor.rgb += layer.rgb * layerColor * (1.0 - finalColor.a);
            finalColor.a += layer.a * (1.0 - finalColor.a);
        } else {
            vec3 layerColor = palette(float(i) * 0.25 + iTime * 0.15, a2, b2, c2, d2);
            vec4 layer = helixField(layerUV, iTime * (1.0 + float(i) * 0.3), mouseUV, i);
            finalColor.rgb += layer.rgb * layerColor * (1.0 - finalColor.a);
            finalColor.a += layer.a * (1.0 - finalColor.a);
        }
    }
    
    // Add quantum fluctuation effects
    vec2 quantumUV = uv * 5.0 + iTime * 0.5;
    float quantumNoise = fbm(quantumUV) * 0.1;
    finalColor.rgb += quantumNoise;
    
    // Mouse interaction - create ripple effect
    vec2 mouseDir = uv - (mouseUV * 2.0 - 1.0) * 2.0;
    float mouseDist = length(mouseDir);
    float ripple = sin(mouseDist * 20.0 - iTime * 5.0) * exp(-mouseDist * 3.0) * 0.3;
    finalColor.rgb += ripple * vec3(0.8, 0.9, 1.0);
    
    // Ensure alpha is 1.0 for web background use
    fragColor = vec4(finalColor.rgb, 1.0);
}