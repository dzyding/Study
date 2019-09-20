#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal; // 法向量

out vec3 Normal;
out vec3 FragPos; // （着色）片段的位置
out vec3 LightPos;  // 转换成观察空间的光线位置，传给片段着色器使用

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// 世界空间 光源位置
uniform vec3 lightPos;

void main()
{
    gl_Position = projection * view * model * vec4(aPos, 1.0f);
    // 逆、转置、然后强制转换为 mat3 舍弃掉不需要的部分，获得 法线矩阵
    // 这个操作一般不应该在 GPU 中执行，应该在 CPU 中计算好，然后通过 uniform 传递过来
    Normal = mat3(transpose(inverse(view * model))) * aNormal;
    // 顶点坐标(局部坐标)乘以模型矩阵、观察矩阵，也就是观察空间中的位置
    FragPos = vec3(view * model * vec4(aPos, 1.0f));
    // 将世界空间的坐标转换成观察空间的坐标
    LightPos = vec3(view * vec4(lightPos, 1.0));
}
