#version 330 core
out vec4 FragColor;
in vec2 texCoord;

/*
 GLSL有一个供纹理对象使用的内建数据类型，叫做采样器(Sampler)，
 它以纹理类型作为后缀，比如sampler1D、sampler3D，或在我们的例子中的sampler2D。
 */
uniform sampler2D texture1;
uniform sampler2D texture2;

void main()
{

    FragColor = mix(texture(texture1, texCoord), texture(texture2, texCoord), 0.2);
}
