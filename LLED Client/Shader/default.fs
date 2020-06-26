#version 150

in vec2 fragTexCoord;

uniform sampler2DRect image;

out vec4 fragColour;

void main(void)
{
    fragColour = texture(image, fragTexCoord);
}
