#version 330
in vec2 texCoords;
out vec4 fragColor;
uniform sampler2D Texture;
uniform float Alpha;
void main() {
    vec4 sampleColor = texture(Texture, texCoords);
    float opacity = sampleColor.a * Alpha;
    if (opacity < 0.004) discard;
    fragColor = vec4(sampleColor.rgb * opacity, opacity);
}
