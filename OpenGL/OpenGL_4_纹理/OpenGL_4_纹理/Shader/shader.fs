#version 330 core
out vec4 FragColor;

in vec3 ourColor;
in vec2 texCoord;

/*
 GLSL有一个供纹理对象使用的内建数据类型，叫做采样器(Sampler)，
 它以纹理类型作为后缀，比如sampler1D、sampler3D，或在我们的例子中的sampler2D。
 */
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform float x;

void main()
{
//    1. 单纯的使用纹理图片
//    FragColor = texture(ourTexture, texCoord);
    
    // 2. 使用纹理颜色与顶点颜色混合
//    FragColor = texture(ourTexture, texCoord) * vec4(ourColor, 1.0);
    
    // 3. 两个纹理
    FragColor = mix(texture(texture1, texCoord), texture(texture2, texCoord), x);
    
    // 4. 第二个纹理反过来
//    FragColor = mix(texture(texture1, texCoord), texture(texture2, vec2(1.0 - texCoord.x, texCoord.y)), 0.2);
    
//    FragColor = mix(texture(texture1, texCoord), texture(texture2, vec2(texCoord.x * 4.0, texCoord.y * 4.0)), 0.2);
}
