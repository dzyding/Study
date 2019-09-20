#version 330 core

// 物体颜色
uniform vec3 objectColor;

in vec3 lColor;

void main()
{
    vec3 result = lColor * objectColor;
    FragColor = vec4(result, 1.0f);
}
