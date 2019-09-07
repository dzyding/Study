//
//  main.cpp
//  OpenGL_2_三角形
//
//  Created by edz on 2019/9/5.
//  Copyright © 2019 灰s. All rights reserved.
//

#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include "shader_s.cpp"
#include <cmath>

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

//MARK: - 检查输入
void processInput(GLFWwindow * window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

//MARK: - main
int main(int argc, const char * argv[]) {
    //1.  初始化 glfw
    initGLFW();
    
    //2. 创建窗口
    GLFWwindow* window = glfwCreateWindow(800, 600, "LearnOpenGL_Dzy", NULL, NULL);
    if (window == NULL) {
        std::cout << "Faild to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    // 将当前窗口设置为当前线程的主上下文
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    //3. 初始化 glad
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cout << "Faild to initialize Glad" << std::endl;
        return -1;
    }
    
    // 检查可用 顶点属性 数量
    int nrAttributes;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
    std::cout << "Maximum nr of vertex attributes suppported: " << nrAttributes << std::endl;
    
    Shader ourShader("shader.vs", "shader.fs");
    
    // 顶点数据
    float vertices[] = {
        // 位置              //颜色
         0.5f,  0.5f, 0.0f, 1.0f, 0.0f, 0.0f,
        -0.5f,  0.5f, 0.0f, 0.0f, 1.0f, 0.0f,
         0.0f, -0.5f, 0.0f, 0.0f, 0.0f, 1.0f
    };
    
    // 创建 VBO（顶点缓冲） 对象
    unsigned int VBO;
    // 创建 VAO （顶点数组） 对象
    unsigned int VAO;
    glGenBuffers(1, &VBO);
    glGenVertexArrays(1, &VAO);
    
    // 绑定数组对象
    glBindVertexArray(VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    // 从这一刻起，我们使用的任何（在GL_ARRAY_BUFFER目标上的）
    // 缓冲调用都会用来配置当前绑定的缓冲(VBO)
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 第一个参数表示 待配置顶点属性子属性的位置(location)
    // 第二个参数表示 3个
    // 第三个参数表示 类型
    // 第四个参数表示 不去标准化
    // 第五个参数表示 步长-整个顶点属性的长度
    // 第六个参数表示 当前子属性针对顶点属性起始位置的偏移量
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void *)0);
    
    // 顶点属性子属性位置值作为参数，启用顶点属性的指定子属性
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6* sizeof(float), (void *)(3 * sizeof(float)));
    
    glEnableVertexAttribArray(1);
    
    // 在 glVertexAttribPointer 中已经将 vbo 注册为制定的缓冲区对象，
    // 所以这里可以安全的解绑
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    // 相当于解绑 VAO
    glBindVertexArray(0);
    
    ourShader.use();
    
    // 5. 准备引擎
    while (!glfwWindowShouldClose(window)) {
        // 检查是否有输入 exc
        processInput(window);

        glClearColor(0.2f, 0.3f, 0.3f, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // 在glUseProgram函数调用之后，
        // 每个着色器调用和渲染调用都会使用这个程序对象（也就是之前写的着色器)了。
//        ourShader.use();
        
        glBindVertexArray(VAO);
        // 绘制单个三角形
        glDrawArrays(GL_TRIANGLES, 0, 3);

        // 检查并调用事件，交换缓冲
        glfwPollEvents();
        glfwSwapBuffers(window);
    }
    
    // 销毁对象
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    
    // 释放/删除之前的分配的所有资源
    glfwTerminate();
    return 0;
}

