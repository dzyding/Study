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

/*
 没注释的地方可以去看看第一篇文章
 
 1. 我们使用一个顶点缓冲对象将顶点数据初始化至缓冲中，
 2. 建立了一个顶点和一个片段着色器，
 3. 并告诉了OpenGL如何把顶点数据链接到顶点着色器的顶点属性上
 */

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

//MARK: - 着色器的定义
/*
 顶点着色器源码
 
 首先是一个版本声明
 in 在顶点着色器中声明所有的输入顶点属性(Input Vertex Attribute)
 vec[1-4] 代表包含[1-4]个分量的向量类型
 通过layout (location = 0)设定了输入变量的位置值(Location) 暂时没解释为什么
 
 预定义的gl_Position变量，它在幕后是vec4类型的
 */
const char *vertexShaderSource = "#version 330 core\n"
"layout (location = 0) in vec3 aPos;\n"
"void main()\n"
"{\n"
"   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
"}\n\0";

/*
 片段着色器源码
 
 vec4(1.0f, 0.5f, 0.2f, 1.0f) 后面对应的是 RGBA，这里是拥有4个分量的向量类型
 用out关键字声明输出变量
 */
const char *fragmentShaderSource = "#version 330 core\n"
"out vec4 FragColor;\n"
"void main()\n"
"{\n"
"   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
"}\n\0";

const char *fragmentShaderSource_Y = "#version 330 core\n"
"out vec4 FragColor;\n"
"void main()\n"
"{\n"
"   FragColor = vec4(1.0f, 1.0f, 0.2f, 1.0f);\n"
"}\n\0";

//MARK: - 编译着色器
unsigned int initVertexShader() {
    // GL_VERTEX_SHADER 着色器类型
    unsigned int vertexShader;
    vertexShader = glCreateShader(GL_VERTEX_SHADER);
    
    /*
     第一个参数为要编译的着色器对象
     第二个参数指定了传递的源码字符串数量
     第三个参数是顶点着色器真正的源码
     */
    glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
    glCompileShader(vertexShader);
    
    // 检测编译结果
    int success;
    char infoLog[512];
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
    
    // 如果失败，打印编译结果
    if (!success) {
        glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
        std::cout << "ERROR::SHADER::VERTEX::COMPILATION\n" << infoLog << std::endl;
        return -1;
    }else {
        std::cout << "VertexShader::COMPILATION::SUCCESS\n" << std::endl;
        return vertexShader;
    }
}

unsigned int initFragmentShader(bool isYellow) {
    unsigned int fragmentShader;
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    if (isYellow) {
        glShaderSource(fragmentShader, 1, &fragmentShaderSource_Y, NULL);
    }else {
        glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
    }
    glCompileShader(fragmentShader);
    
    int success;
    char infoLog[512];
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
    
    if (!success) {
        glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
        std::cout << "FragmentShader::Compilation::Fail\n" << infoLog << std::endl;
        return -1;
    }else {
        std::cout << "FragmentShader::Compiliation::Success\n" << std::endl;
        return fragmentShader;
    }
}

//MARK: - 创建着色器程序对象
unsigned int initShaderProgram(bool isYellow) {
    unsigned int shaderProgram;
    shaderProgram = glCreateProgram();
    
    unsigned int vertexShader = initVertexShader();
    unsigned int fragmentShader = initFragmentShader(isYellow);
    if (vertexShader == -1 || fragmentShader == -1) {
        return -1;
    }
    // 附加
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    //链接
    glLinkProgram(shaderProgram);
    
    int success;
    char infoLog[512];
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if (!success) {
        glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
        std::cout << "ShaderProgram::Link::Fail\n" << infoLog << std::endl;
        return -1;
    }else {
        std::cout << "ShaderProgram::Link::Success\n" << std::endl;
        // 在把着色器对象链接到程序对象以后，记得删除着色器对象
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
        return shaderProgram;
    }
}


//MARK: - main
int main(int argc, const char * argv[]) {
    //1.  初始化 glfw
    initGLFW();
    
    //2. 创建窗口
    // 宽、高 名称
    GLFWwindow* window = glfwCreateWindow(800, 600, "LearnOpenGL_Dzy", NULL, NULL);
    if (window == NULL) {
        std::cout << "Faild to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    // 将当前窗口设置为当前线程的主上下文
    glfwMakeContextCurrent(window);
    //  创建窗口调整大小 时的回调
    //  创建窗口之后，渲染循环初始化之前注册这些回调函数
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    //3. 初始化 glad
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cout << "Faild to initialize Glad" << std::endl;
        return -1;
    }
    
    // 使用线条的方式绘制
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    // 填充的模式 (默认的)
//    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    
    // 初始化着色器
    unsigned int shaderProgram = initShaderProgram(false);
    unsigned int shaderProgram_Y = initShaderProgram(true);
    if (shaderProgram == -1 || shaderProgram_Y == -1) {
        return -1;
    }
    
    // 顶点数据
    float vertices1[] = {
        -0.5f, 0.0f, 0.0f,
        0.5f, 0.0f, 0.0f,
        0.0f, 0.5f, 0.0f
    };
    
    float vertices2[] = {
        -0.5f, 0.0f, 0.0f,
        0.5f, 0.0f, 0.0f,
        0.0f, -0.5f, 0.0f
    };
    
    // 创建 VBO（顶点缓冲） 对象
    unsigned int VBOs[2];
    // 创建 VAO （顶点数组） 对象
    unsigned int VAOs[2];
    
    glGenBuffers(2, VBOs);
    glGenVertexArrays(2, VAOs);
    
    // 绑定数组对象
    glBindVertexArray(VAOs[0]);

    glBindBuffer(GL_ARRAY_BUFFER, VBOs[0]);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices1), vertices1, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
    
    glEnableVertexAttribArray(0);
    
    // 制作第二个 vbo
    // 绑定数组对象
    glBindVertexArray(VAOs[1]);
    
    glBindBuffer(GL_ARRAY_BUFFER, VBOs[1]);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices2), vertices2, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
    
    glEnableVertexAttribArray(0);
    
    glBindVertexArray(0);
    // 5. 准备引擎
    while (!glfwWindowShouldClose(window)) {
        // 检查是否有输入 exc
        processInput(window);

        glClearColor(0.2f, 0.3f, 0.3f, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // 在glUseProgram函数调用之后，
        // 每个着色器调用和渲染调用都会使用这个程序对象（也就是之前写的着色器)了。
        glUseProgram(shaderProgram);
        glBindVertexArray(VAOs[0]);
        // 绘制单个三角形
        glDrawArrays(GL_TRIANGLES, 0, 3);
        
        glUseProgram(shaderProgram_Y);
        glBindVertexArray(VAOs[1]);
        // 绘制单个三角形
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glBindVertexArray(0);
        // 检查并调用事件，交换缓冲
        glfwPollEvents();
        glfwSwapBuffers(window);
    }
    
    // 销毁对象
    glDeleteVertexArrays(2, VAOs);
    glDeleteBuffers(2, VBOs);
    
    // 释放/删除之前的分配的所有资源
    glfwTerminate();
    return 0;
}

