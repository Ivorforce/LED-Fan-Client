#version 150

uniform sampler2DRect tex;
in vec2 fragTexCoord;

out vec4 color;

void main() {
    color = texture(tex, fragTexCoord);
    color.r = 1;
}
