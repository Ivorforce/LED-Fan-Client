#version 150

in vec2 position;
in vec2 texCoord;

out vec2 fragTexCoord;

void main (void)
{
    gl_Position = vec4(position, 0, 1);
    fragTexCoord = texCoord;
}
