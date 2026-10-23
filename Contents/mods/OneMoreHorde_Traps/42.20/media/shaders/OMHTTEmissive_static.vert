#version 330
layout(location = 0) in vec4 vertex;
layout(location = 2) in vec2 uv;
out vec2 texCoords;
uniform mat4 ModelViewProjection;
uniform mat4 transform;
uniform vec2 UVScale;
uniform float FinalScale = 1.0;
uniform float HighResDepthMultiplier = 0.0;
uniform float targetDepth = 0.5;
void main() {
    vec4 worldPosition = transform * vec4(vertex.xyz, 1.0);
    worldPosition.xyz *= FinalScale;
    vec4 projected = ModelViewProjection * worldPosition;
    vec4 origin = ModelViewProjection * vec4(0.0, 0.0, 0.0, 1.0);
    projected.z = mix(projected.z, origin.z, HighResDepthMultiplier);
    projected.z += 2.0 * (targetDepth - 0.5);
    texCoords = uv * UVScale;
    gl_Position = projected;
}
