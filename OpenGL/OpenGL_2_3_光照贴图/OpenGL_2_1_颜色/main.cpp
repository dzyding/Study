//
//  main.cpp
//  OpenGL_2_1_颜色
//
//  Created by edz on 2019/9/18.
//  Copyright © 2019 灰s. All rights reserved.
//

#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "Shader/shader_s.cpp"
#include "camera_s.cpp"
#include "Image/stb_image.h"
#include <cmath>

//MAKR: - 声明变量
const float screenWidth = 800.0f;
const float screenHeight = 600.0f;

///当前帧与上一帧的时间差
float deltaTime = 0.0f;
///上一帧的时间
float lastFrame = 0.0f;

// 鼠标的初始位置
float lastX = screenWidth / 2.0f, lastY = screenHeight / 2.0f;
// 初次进入
bool firstMouse = true;
// 摄像机类
Camera camera(glm::vec3(0.0f, 0.0f, 3.0f));

// 光源的位置
glm::vec3 lightPos(1.2f, 1.0f, 2.0f);

//MARK: - 初始化 glfw
void initGLFW() {
    // 初始化 glfw
    glfwInit();
    // MAJOR 主版本号
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    // MINOR 次版本号
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    // 使用的是核心模式(Core-profile)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    //Mac OS X 系统，需要加下面这行代码到初始化代码中这些配置才能起作用
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
}

//MARK: -  窗口大小被调整时的回调函数
void framebuffer_size_callback(GLFWwindow* window, int width, int height) {
    glViewport(0, 0, width, height);
}

//MARK: - 鼠标移动的回调
void mouse_callback(GLFWwindow* window, double xpos, double ypos) {
    // 第一次启动会有一个跳动
    if (firstMouse) {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }
    
    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos; // 注意这里是相反的，因为y坐标是从底部往顶部依次增大的
    lastX = xpos;
    lastY = ypos;
    
    camera.processMouseMovement(xoffset, yoffset);
}

//MARK: - 鼠标滚轴的监测
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset) {
    camera.processMouseScroll(yoffset);
}

//MARK: - 检查输入
void processInput(GLFWwindow * window) {
    // 检查是否有输入 exc
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        camera.processKeyboard(FORWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        camera.processKeyboard(BACKWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        camera.processKeyboard(LEFT, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        camera.processKeyboard(RIGHT, deltaTime);
}

//MARK: - 创建纹理
unsigned int initTexTure(const char* path) {
    // 纹理对象
    unsigned int texture;
    // 第一个参数： 生成纹理的数量
    glGenTextures(1, &texture);
    // 绑定纹理对象，这样之后的操作都是针对当前纹理
    glBindTexture(GL_TEXTURE_2D, texture);
    
    // 为当前绑定的纹理对象设置环绕、过滤方式
    // s、t 对应 x、y 轴
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    // min、mag 对应放大缩小的过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 加载图片数据
    int width, height, nrComponents;
    unsigned char *data = stbi_load(path, &width, &height, &nrComponents, 0);
    if (data){
        GLenum format;
        if (nrComponents == 1)
            format = GL_RED;
        else if (nrComponents == 3)
            format = GL_RGB;
        else if (nrComponents == 4)
            format = GL_RGBA;
        /*
         第一个参数：指定纹理目标（类型？跟绑定纹理对象的操作是关联的）
         第二个参数：为纹理指定多级渐远纹理的级别，如果你希望单独手动设置每个多级渐远纹理的级别的话。
         这里我们填0，也就是基本级别。
         第三个参数：告诉OpenGL我们希望把纹理储存为何种格式
         图像只有RGB值，因此我们也把纹理储存为RGB值。
         第四、五个参数：宽、高
         第六个参数：固定0
         第七、八个参数：定义了源图的格式和数据类型
         使用RGB值加载这个图像，并把它们储存为char(byte)数组
         最后一个参数熟图像数据
         */
        
        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
        
        glGenerateMipmap(GL_TEXTURE_2D);
        
        /*
         当调用glTexImage2D时，当前绑定的纹理对象就会被附加上纹理图像。
         然而，目前只有基本级别(Base-level)的纹理图像被加载了，如果要使用多级渐远纹理，
         我们必须手动设置所有不同的图像（不断递增第二个参数）。
         或者，直接在生成纹理之后调用glGenerateMipmap。
         这会为当前绑定的纹理自动生成所有需要的多级渐远纹理。
         */
    }else {
        std::cout << "Failed to load texture" << std::endl;
    }
    
    // 生成了纹理和相应的多级渐远纹理后，应该释放内存
    stbi_image_free(data);
    return texture;
}

int main(int argc, const char * argv[]) {
    initGLFW();
    
    // 初始化 window
    GLFWwindow * window = glfwCreateWindow(screenWidth, screenHeight, "LearnOpenGL_Dzy", NULL, NULL);
    if (window == NULL) {
        std::cout << "Faild to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);
    // 调整屏幕的回调
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    // 设置鼠标模式，及各种鼠标回调
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    glfwSetCursorPosCallback(window, mouse_callback);
    glfwSetScrollCallback(window, scroll_callback);
    
    // 初始化 glad
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cout << "Faild to initialize Glad" << std::endl;
        return -1;
    }
    
    float vertices[] = {
        // positions          // normals           // texture coords
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
         0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,

        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,
         0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,

        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,

         0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,

        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
         0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,

        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f
    };
    // 初始化着色器
    Shader objectShader("Shader/object_shader.vs", "Shader/object_shader.fs");
    Shader lightShader("Shader/light_shader.vs", "Shader/light_shader.fs");
    
    // 初始化各种对象
    unsigned int VBO;
    unsigned int objectVAO;
    unsigned int lightVAO;
    
    glGenBuffers(1, &VBO);
    glGenVertexArrays(1, &objectVAO);
    glGenVertexArrays(2, &lightVAO);
    
    // 设置第一个VAO (顶点数组对象Vertex Array Object，存储缓冲区和顶点属性状态)
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindVertexArray(objectVAO);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)(sizeof(float) * 3));
    glEnableVertexAttribArray(1);
    
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)(sizeof(float) * 6));
    glEnableVertexAttribArray(2);
    
    // 设置第二个 VAO
    glBindVertexArray(lightVAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    
    // 图片反转的处理
    stbi_set_flip_vertically_on_load(true);
    // 开启更新深度缓冲区的功能
    glEnable(GL_DEPTH_TEST);
    
    unsigned int diffuseMap = initTexTure("Image/box.png");
    unsigned int specularMap = initTexTure("Image/photo.png");
    objectShader.use();
    // 好像是对应 GL_TEXTURE0 里面的这个数字
    objectShader.setInt("material.diffuse", 0);
    objectShader.setInt("material.specular", 1);
    
    while (!glfwWindowShouldClose(window)) {
        float currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        
        processInput(window);
        
        glClearColor(0.2f, 0.3f, 0.3f, 1.0);
        // 每次渲染迭代之前清除 颜色缓冲、深度缓冲
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        objectShader.use();
        objectShader.setVec3("lightColor",  1.0f, 1.0f, 1.0f);
        objectShader.setVec3("viewPos", camera._position);
        objectShader.setVec3("material.specular", 0.5f, 0.5f, 0.5f);
        objectShader.setFloat("material.shininess", 64.0f);
        // 正常配置
        objectShader.setVec3("light.position", lightPos);
        objectShader.setVec3("light.ambient", 0.2f, 0.2f, 0.2f);
        objectShader.setVec3("light.diffuse", 0.5f, 0.5f, 0.5f);
        objectShader.setVec3("light.specular", 1.0f, 1.0f, 1.0f);
        
        glm::mat4 view = camera.getViewMatrix();
        
        glm::mat4 projection = glm::mat4(1.0f);
        projection = glm::perspective(glm::radians(camera._zoom),
                                      screenWidth / screenHeight,
                                      0.1f,
                                      100.0f);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, diffuseMap);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, specularMap);
        
        // 绘制第一个长方体
        glBindVertexArray(objectVAO);
        objectShader.setMat4("view", view);
        objectShader.setMat4("projection", projection);
        
        glm::mat4 model = glm::mat4(1.0f);
        objectShader.setMat4("model", model);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
        // 激活对象，之后每个着色器调用和渲染调用都会使用这个对象对应的着色器。
        lightShader.use();
        // 绘制第二个长方体
        glBindVertexArray(lightVAO);
        
        lightShader.setMat4("view", view);
        lightShader.setMat4("projection", projection);
        
        model = glm::mat4(1.0f);
        model = glm::translate(model, lightPos);
        model = glm::scale(model, glm::vec3(0.2f));
        lightShader.setMat4("model", model);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
        glfwSwapBuffers(window);
        // 检查并调用事件，交换缓冲
        glfwPollEvents();
    }
    
    // 销毁对象
    glDeleteVertexArrays(1, &objectVAO);
    glDeleteVertexArrays(2, &lightVAO);
    glDeleteBuffers(1, &VBO);
    
    // 释放/删除之前的分配的所有资源
    glfwTerminate();
    return 0;
}
