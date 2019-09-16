//
//  main.cpp
//  OpenGL_4_纹理
//
//  Created by edz on 2019/9/9.
//  Copyright © 2019 灰s. All rights reserved.
//

#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "Shader/shader_s.cpp"
#include "Image/stb_image.h"
#include <cmath>

//MARK: - 声明变量
const float screenwidth = 800.0;
const float screenHeight = 600.0;

// 自由移动时定义的变量
glm::vec3 cameraPos     = glm::vec3(0.0f, 0.0f, 3.0f);  //位置
glm::vec3 cameraFront   = glm::vec3(0.0f, 0.0f, -1.0f); //方向
glm::vec3 cameraUp      = glm::vec3(0.0f, 1.0f, 0.0f);  //上量

float deltaTime = 0.0f; //当前帧与上一帧的时间差
float lastFrame = 0.0f; //上一帧的时间

// 鼠标的初始位置
float lastX = 400, lastY = 300;

// 俯仰角，偏航角
float pitch = 0, yaw = -90;

// 初次进入
bool firstMouse = true;

// 默认视野角度
float fov = 45.0f;

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
    
    // 灵敏度，需要适配调整
    float sensitivity = 0.05f;
    xoffset *= sensitivity;
    yoffset *= sensitivity;
    
    yaw += xoffset;
    pitch += yoffset;
    
    if (pitch > 89.0f)
        pitch = 89.0f;
    if (pitch < -89.0f)
        pitch = -89.0f;
    
    glm::vec3 front = glm::vec3(1.0f);
    front.x = cos(glm::radians(yaw)) * cos(glm::radians(pitch));
    front.y = sin(glm::radians(pitch));
    front.z = sin(glm::radians(yaw)) * cos(glm::radians(pitch));
    cameraFront = glm::normalize(front);
}

//MARK: - 鼠标滚轴的监测
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset) {
    if (fov >= 1.0f && fov <= 45.0f)
        fov -= yoffset;
    if (fov <= 1.0f)
        fov = 1.0f;
    if (fov >= 45.0f)
        fov = 45.0f;
}

//MARK: - 检查输入
void processInput(GLFWwindow * window) {
    float cameraSpeed = 2.5f * deltaTime;
    // 检查是否有输入 exc
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        cameraPos += cameraSpeed * cameraFront;
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        cameraPos -= cameraSpeed * cameraFront;
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        cameraPos -= glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        cameraPos += glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
}

//MARK: - 创建纹理
unsigned int initTexTure(const char* path, bool alpha) {
    // 纹理对象
    unsigned int texture;
    // 第一个参数： 生成纹理的数量
    glGenTextures(1, &texture);
    // 绑定纹理对象，这样之后的操作都是针对当前纹理
    glBindTexture(GL_TEXTURE_2D, texture);
    
    // 为当前绑定的纹理对象设置环绕、过滤方式
    // s、t 对应 x、y 轴
    if (alpha) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    }else {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    }
    
    // min、mag 对应放大缩小的过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    // 加载图片数据
    int width, height, nrChannels;
    unsigned char *data = stbi_load(path, &width, &height, &nrChannels, 0);
    if (data){
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
        if (alpha) {
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
        }else {
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
        }
        
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
    //1.  初始化 glfw
    initGLFW();
    
    //2. 创建窗口
    GLFWwindow* window = glfwCreateWindow(screenwidth, screenHeight, "LearnOpenGL_Dzy", NULL, NULL);
    if (window == NULL) {
        std::cout << "Faild to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    // 将当前窗口设置为当前线程的主上下文
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    // 隐藏光标，并捕捉(Capture)它
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    glfwSetCursorPosCallback(window, mouse_callback);
    glfwSetScrollCallback(window, scroll_callback);
    
    //3. 初始化 glad
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cout << "Faild to initialize Glad" << std::endl;
        return -1;
    }
    
    // 检查可用 顶点属性 数量
    int nrAttributes;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
    std::cout << "Maximum nr of vertex attributes suppported: " << nrAttributes << std::endl;
    
    float vertices[] = {
        // ---- 位置 ----      - 纹理坐标 -
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };
    
    glm::vec3 cubePositions[] = {
        glm::vec3( 0.0f,  0.0f,  0.0f),
        glm::vec3( 2.0f,  5.0f, -15.0f),
        glm::vec3(-1.5f, -2.2f, -2.5f),
        glm::vec3(-3.8f, -2.0f, -12.3f),
        glm::vec3( 2.4f, -0.4f, -3.5f),
        glm::vec3(-1.7f,  3.0f, -7.5f),
        glm::vec3( 1.3f, -2.0f, -2.5f),
        glm::vec3( 1.5f,  2.0f, -2.5f),
        glm::vec3( 1.5f,  0.2f, -1.5f),
        glm::vec3(-1.3f,  1.0f, -1.5f)
    };
    
    Shader ourShader("Shader/shader.vs", "Shader/shader.fs");
    
    // 创建 VBO（顶点缓冲） 对象
    unsigned int VBO;
    // 创建 VAO （顶点数组） 对象
    unsigned int VAO;
    
    glGenBuffers(1, &VBO);
    glGenVertexArrays(1, &VAO);
    
    // 绑定数组对象
    glBindVertexArray(VAO);
    /*
     OpenGL有很多缓冲对象类型，顶点缓冲对象的缓冲类型是GL_ARRAY_BUFFER。
     OpenGL允许我们同时绑定多个缓冲，只要它们是不同的缓冲类型。
     */
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    // 从这一刻起，我们使用的任何（在GL_ARRAY_BUFFER目标上的）
    // 缓冲调用都会用来配置当前绑定的缓冲(VBO)
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 8 * sizeof(float) 整个顶点属性的步长
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    
    // 所以这里可以安全的解绑
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    // 相当于解绑 VAO
    glBindVertexArray(0);
    
    stbi_set_flip_vertically_on_load(true);
    glEnable(GL_DEPTH_TEST);
    // 纹理对象
    unsigned int texture1 = initTexTure("Image/container.jpg", false);
    unsigned int texture2 = initTexTure("Image/awesomeface.png", true);
    
    ourShader.use();
    // 两种赋值方式都可以
    ourShader.setInt("texture1", 0);
    ourShader.setInt("texture2", 1);
    
    // 5. 准备引擎
    while (!glfwWindowShouldClose(window)) {
        
        float currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        
        processInput(window);
        
        glClearColor(0.2f, 0.3f, 0.3f, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture1);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture2);
        
        ourShader.use();
        
        /*
         // 自动旋转
        float radius = 10.0f;
        float camX = sin(glfwGetTime()) * radius;
        float camZ = cos(glfwGetTime()) * radius;
        
        glm::mat4 view = glm::mat4(1.0f);
        view = glm::lookAt(
                           glm::vec3(camX, 0.0f, camZ),     //位置
                           glm::vec3(0.0f, 0.0f, 0.0f),     //目标
                           glm::vec3(0.0f, 1.0f, 0.0f));    //上量
         */
        
        // 自由变换
        glm::mat4 view = glm::mat4(1.0f);
        view = glm::lookAt(
                           cameraPos,                   //位置
                           cameraPos + cameraFront,     //目标
                           cameraUp);                   //上量
        
        glm::mat4 projection = glm::mat4(1.0f);
        projection = glm::perspective(glm::radians(fov), screenwidth / screenHeight, 0.1f, 100.0f);

        glBindVertexArray(VAO);
        ourShader.setMat4("view", view);
        ourShader.setMat4("projection", projection);
        
        for (unsigned int i = 0; i < 10; i++) {
            glm::mat4 model = glm::mat4(1.0f);
            model = glm::translate(model, cubePositions[i]);
            float angle = 20.0f * i;
            model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.2f, 0.4f));
            ourShader.setMat4("model", model);
            // 36 是顶点数量
            glDrawArrays(GL_TRIANGLES, 0, 36);
        }
        
        glBindVertexArray(0);
        glfwSwapBuffers(window);
        // 检查并调用事件，交换缓冲
        glfwPollEvents();
    }
    
    // 销毁对象
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    
    // 释放/删除之前的分配的所有资源
    glfwTerminate();
    return 0;
}
