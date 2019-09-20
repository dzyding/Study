#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal; // 法向量

out vec3 lColor;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// 光颜色
uniform vec3 lightColor;
// 世界空间 光源位置
uniform vec3 lightPos;

void main()
{
    gl_Position = projection * view * model * vec4(aPos, 1.0f);
    // 逆、转置、然后强制转换为 mat3 舍弃掉不需要的部分，获得 法线矩阵
    // 这个操作一般不应该在 GPU 中执行，应该在 CPU 中计算好，然后通过 uniform 传递过来
    mat3 normal = mat3(transpose(inverse(view * model))) * aNormal;
    // 顶点坐标(局部坐标)乘以模型矩阵、观察矩阵，也就是观察空间中的位置
    vec3 fragPos = vec3(view * model * vec4(aPos, 1.0f));
    // 将世界空间的坐标转换成观察空间的坐标
    vec3 lightPos = vec3(view * vec4(lightPos, 1.0));
    
    // -- 环境光照系数
    float ambientStrength = 0.2f;
    vec3 ambient = ambientStrength * lightColor;
    
    // -- 漫反射光照
    // 计算光源和片段位置之间的方向向量
    // 标准化法向量
    vec3 norm = normalize(normal);
    // 计算方向向量，并标准化
    vec3 lightDir = normalize(lightPos - fragPos);
    
    // 对 norm 和 lightDir 进行点乘，计算光源对当前片段实际的漫反射影响
    // 两个向量之间的角度大于90度，点乘的结果就会变成负数，这里是确保漫反射分量不为负
    float diff = max(dot(norm, lightDir), 0.0f);
    // 乘以光的颜色，得到漫反射分量
    vec3 diffuse = diff * lightColor;
    
    // -- 镜面光照
    float specularStrength = 1.0f;
    // 视线方向向量
    vec3 viewDir = normalize(-fragPos); //(在观察空间中，观察者的位置始终是 0,0,0 所以方向向量就是片段位置向量取反)
    // 沿着法线轴的反射向量
    /*
     需要注意的是我们对lightDir向量进行了取反。
     reflect函数要求第一个向量是从光源指向片段位置的向量，但是lightDir当前正好相反，
     是从片段指向光源（由先前我们计算lightDir向量时，减法的顺序决定）
     
     norm 是已标准化的法向量
     */
    vec3 reflectDir = reflect(-lightDir, norm);
    
    // 计算镜面分量
    // 32是高光的反光度(Shininess)
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
    // 镜面分量
    vec3 specular = specularStrength * spec * lightColor;
    
    // 3. 环境光分量和漫反射分量，我们把它们相加，然后把结果乘以物体的颜色，来获得片段最后的输出颜色
    lColor = (ambient + diffuse + specular);
    oColor = objectColor;
}
