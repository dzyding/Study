#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal; // 法向量
layout (location = 2) in vec2 aTexCoords;

out vec3 Normal;
out vec3 FragPos; // （着色）片段的位置
out vec2 TexCoords;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    gl_Position = projection * view * model * vec4(aPos, 1.0f);
    // 逆、转置、然后强制转换为 mat3 舍弃掉不需要的部分，获得 法线矩阵
    // 这个操作一般不应该在 GPU 中执行，应该在 CPU 中计算好，然后通过 uniform 传递过来
    Normal = mat3(transpose(inverse(model))) * aNormal;
    // 顶点坐标乘以模型空间，也就是世界空间中的位置
    FragPos = vec3(model * vec4(aPos, 1.0f));
    
    TexCoords = aTexCoords;
}
