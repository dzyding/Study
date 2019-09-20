#version 330 core
in vec3 Normal;
in vec3 FragPos;
in vec3 LightPos;
out vec4 FragColor;

// 物体颜色
uniform vec3 objectColor;
// 光颜色
uniform vec3 lightColor;


void main()
{
    // -- 环境光照系数
    float ambientStrength = 0.2f;
    vec3 ambient = ambientStrength * lightColor;
    
    // -- 漫反射光照
    // 计算光源和片段位置之间的方向向量
    // 标准化法向量
    vec3 norm = normalize(Normal);
    // 计算方向向量，并标准化
    vec3 lightDir = normalize(LightPos - FragPos);
    
    // 对 norm 和 lightDir 进行点乘，计算光源对当前片段实际的漫反射影响
    // 两个向量之间的角度大于90度，点乘的结果就会变成负数，这里是确保漫反射分量不为负
    float diff = max(dot(norm, lightDir), 0.0f);
    // 乘以光的颜色，得到漫反射分量
    vec3 diffuse = diff * lightColor;
    
    // -- 镜面光照
    float specularStrength = 0.5f;
    // 视线方向向量
    vec3 viewDir = normalize(-FragPos); //(在观察空间中，观察者的位置始终是 0,0,0 所以方向向量就是片段位置向量取反)
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
    vec3 result = (ambient + diffuse + specular) * objectColor;
    FragColor = vec4(result, 1.0f);
}
