#version 330 core
struct Material {
    /*
     环境光照下的颜色
        材质向量定义了在环境光照下这个物体反射得是什么颜色，通常这是和物体颜色相同的颜色。
     */
    vec3 ambient;
    /*
    漫反射光照下的颜色
        材质向量定义了在漫反射光照下物体的颜色。
        （和环境光照一样）漫反射颜色也要设置为我们需要的物体颜色。
     */
    vec3 diffuse;
    /*
     镜面光照下的颜色
        材质向量设置的是镜面光照对物体的颜色影响（或者甚至可能反射一个物体特定的镜面高光颜色）
     */
    vec3 specular;
    /*
     反光度
        影响镜面高光的散射/半径
     */
    float shininess;
};

/*
 每一种光照分量，对光源的反射比例
 */
struct Light {
    // 光源的位置
    vec3 position;
    
    // 环境光分量
    vec3 ambient;
    // 漫反射分量
    vec3 diffuse;
    // 镜面光分量
    vec3 specular;
};

// 法向量
in vec3 Normal;
// 片段位置
in vec3 FragPos;
// 片段颜色
out vec4 FragColor;

// 材质属性
uniform Material material;
// 光的属性
uniform Light light;
// 相机位置（观察者位置）
uniform vec3 viewPos;

void main()
{
    // 环境光
    vec3 ambient = light.ambient * material.ambient;
    
    // -- 漫反射光照
    // 计算光源和片段位置之间的方向向量
    // 标准化法向量
    vec3 norm = normalize(Normal);
    // 计算方向向量，并标准化
    vec3 lightDir = normalize(light.position - FragPos);
    
    // 对 norm 和 lightDir 进行点乘，计算光源对当前片段实际的漫反射影响
    // 两个向量之间的角度大于90度，点乘的结果就会变成负数，这里是确保漫反射分量不为负
    float diff = max(dot(norm, lightDir), 0.0f);
    // 乘以光的颜色，得到漫反射分量
    vec3 diffuse = light.diffuse * (diff * material.diffuse);
    
    // -- 镜面光照
    // 视线方向向量
    vec3 viewDir = normalize(viewPos - FragPos);
    // 沿着法线轴的反射向量
    /*
     需要注意的是我们对lightDir向量进行了取反。
     reflect函数要求第一个向量是从光源指向片段位置的向量，但是lightDir当前正好相反，
     是从片段指向光源（由先前我们计算lightDir向量时，减法的顺序决定）
     
     norm 是已标准化的法向量
     */
    vec3 reflectDir = reflect(-lightDir, norm);
    
    // 计算镜面分量
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    // 镜面分量
    vec3 specular = light.specular * (spec * material.specular);
    
    vec3 result = ambient + diffuse + specular;
    FragColor = vec4(result, 1.0f);
}
