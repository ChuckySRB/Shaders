// DNA Neural Flux - A shader exploring the intersection of biological and artificial intelligence
// Mouse interaction: X controls helix twist, Y controls neural pulse intensity

#define PI 3.14159265359
#define TAU 6.28318530718

// Organic color palette inspired by bioluminescent organisms and neural activity
vec3 palette(float t) {
    vec3 a = vec3(0.15, 0.08, 0.25);
    vec3 b = vec3(0.65, 0.45, 0.85);
    vec3 c = vec3(1.0, 0.95, 0.75);
    vec3 d = vec3(0.0, 0.33, 0.67);
    return a + b * cos(TAU * (c * t + d));
}

// Smooth noise function for organic movement
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float smoothNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// DNA helix structure
float dnaHelix(vec3 p, float twist, float phase) {
    float angle = p.z * twist + phase;
    vec2 helix = vec2(cos(angle), sin(angle)) * 0.3;
    return length(p.xy - helix) - 0.08;
}

// Neural connection lines with pulsing
float neuralConnection(vec2 uv, vec2 start, vec2 end, float time, float pulse) {
    vec2 pa = uv - start;
    vec2 ba = end - start;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    float dist = length(pa - ba * h);
    
    // Pulsing effect traveling along the line
    float travelPulse = sin(h * 10.0 - time * 3.0) * 0.5 + 0.5;
    float intensity = pulse * travelPulse;
    
    return (0.005 + intensity * 0.01) / dist;
}

// Fractal noise field for organic background
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for(int i = 0; i < 5; i++) {
        value += amplitude * smoothNoise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    
    // Mouse interaction
    vec2 mouse = iMouse.xy / iResolution.xy;
    float mouseActive = step(0.001, length(iMouse.xy));
    mouse = mix(vec2(0.5, 0.5), mouse, mouseActive);
    
    float helixTwist = 3.0 + mouse.x * 8.0;
    float neuralPulse = 0.5 + mouse.y * 1.5;
    
    vec3 finalColor = vec3(0.0);
    
    // Organic background field
    float bgNoise = fbm(uv * 2.0 + iTime * 0.1);
    vec3 bgColor = palette(bgNoise * 0.3 + iTime * 0.05) * 0.15;
    finalColor += bgColor;
    
    // Layered DNA helices with different phases
    for(float layer = 0.0; layer < 3.0; layer++) {
        vec2 uvLayer = uv;
        float scale = 1.0 + layer * 0.4;
        uvLayer *= scale;
        
        // Rotation and distortion
        float angle = iTime * 0.2 + layer * TAU / 3.0;
        mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
        uvLayer = rot * uvLayer;
        
        // Add organic warping
        uvLayer.x += sin(uvLayer.y * 3.0 + iTime * 0.5) * 0.1;
        uvLayer.y += cos(uvLayer.x * 3.0 - iTime * 0.3) * 0.1;
        
        // DNA strand pairs
        for(float strand = 0.0; strand < 2.0; strand++) {
            vec3 p = vec3(uvLayer, iTime * 0.5 + layer * 2.0);
            float phase = strand * PI + layer * 0.5;
            
            float d = dnaHelix(p, helixTwist, phase);
            
            // Color based on distance and time
            float colorPhase = length(uv0) * 0.5 + iTime * 0.15 + layer * 0.3;
            vec3 col = palette(colorPhase);
            
            // Glow intensity
            float glow = exp(-abs(d) * 20.0) * 0.5;
            glow += exp(-abs(d) * 5.0) * 0.2;
            
            finalColor += col * glow;
        }
        
        // Connecting base pairs (horizontal connections)
        float basePairZ = mod(iTime * 0.5 + layer * 2.0, 2.0);
        vec3 pBase = vec3(uvLayer, basePairZ);
        
        float angle1 = pBase.z * helixTwist;
        float angle2 = angle1 + PI;
        vec2 point1 = vec2(cos(angle1), sin(angle1)) * 0.3;
        vec2 point2 = vec2(cos(angle2), sin(angle2)) * 0.3;
        
        float connection = neuralConnection(uvLayer, point1, point2, iTime, neuralPulse);
        vec3 connectCol = palette(basePairZ * 0.5 + iTime * 0.1);
        finalColor += connectCol * connection * 0.3;
    }
    
    // Neural network overlay - synaptic connections
    float neuralLayer = sin(iTime * 0.5) * 0.5 + 0.5;
    for(float i = 0.0; i < 8.0; i++) {
        float t = i / 8.0;
        float angle1 = t * TAU + iTime * 0.3;
        float angle2 = (t + 0.3) * TAU - iTime * 0.25;
        
        float radius = 0.8 + sin(iTime * 0.4 + i) * 0.3;
        vec2 node1 = vec2(cos(angle1), sin(angle1)) * radius;
        vec2 node2 = vec2(cos(angle2), sin(angle2)) * radius;
        
        // Pulsing nodes
        float nodeDist1 = length(uv - node1);
        float nodeDist2 = length(uv - node2);
        float nodeGlow = exp(-nodeDist1 * 25.0) + exp(-nodeDist2 * 25.0);
        
        vec3 nodeCol = palette(t + iTime * 0.1);
        finalColor += nodeCol * nodeGlow * neuralLayer * 0.4;
        
        // Connections between nodes
        float conn = neuralConnection(uv, node1, node2, iTime, neuralPulse);
        finalColor += nodeCol * conn * neuralLayer * 0.15;
    }
    
    // Particle system - data packets flowing
    for(float p = 0.0; p < 15.0; p++) {
        float seed = p * 12.345;
        float particleTime = mod(iTime * 0.5 + seed, 4.0);
        float t = particleTime / 4.0;
        
        vec2 path = vec2(
            cos(t * TAU + seed) * (1.2 - t * 0.5),
            sin(t * TAU * 1.3 + seed * 1.5) * (1.2 - t * 0.5)
        );
        
        float particleDist = length(uv - path);
        float particleSize = 0.015 + sin(iTime * 2.0 + seed) * 0.005;
        float particle = smoothstep(particleSize, 0.0, particleDist);
        
        vec3 particleCol = palette(seed * 0.1 + iTime * 0.2);
        finalColor += particleCol * particle * (1.0 - t) * 0.8;
        
        // Particle trail
        float trail = exp(-particleDist * 15.0) * (1.0 - t) * 0.3;
        finalColor += particleCol * trail;
    }
    
    // Vignette for depth
    float vignette = 1.0 - length(uv0) * 0.3;
    finalColor *= vignette;
    
    // Subtle chromatic aberration at edges
    float edgeDist = length(uv0);
    finalColor.r *= 1.0 + edgeDist * 0.05;
    finalColor.b *= 1.0 - edgeDist * 0.05;
    
    // Final color grading - slight saturation boost
    finalColor = pow(finalColor, vec3(0.9));
    finalColor *= 1.1;
    
    fragColor = vec4(finalColor, 1.0);
}