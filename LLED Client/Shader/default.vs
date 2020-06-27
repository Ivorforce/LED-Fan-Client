#version 150

in vec2 vertCoord;
in vec2 texCoord;

out vec2 fragTexCoord;

void main() {
    fragTexCoord = texCoord;
    gl_Position = vec4(vertCoord, 1.0, 1.0);
}
