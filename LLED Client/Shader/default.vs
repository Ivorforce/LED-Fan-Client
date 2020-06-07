#version 150

in vec2 position;

out vec2 texCoord;

void main (void)
{
    gl_Position = vec4(position, 0, 1);
    texCoord = (position + 1) / 2;
}
