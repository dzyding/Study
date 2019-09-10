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

//MARK: - 着色器的定义

/*
 in 输入类型
 out 输出类型
 */

// MARK: - 1. 两个着色器之间传递属性
/*
 顶点着色器源码
 
 layout 为顶点着色器的特殊关键字，用来指定输入变量的“位置”

 预定义的gl_Position变量，它在幕后是vec4类型的
 */
//const char *vertexShaderSource = "#version 330 core\n"
//"layout (location = 0) in vec3 aPos;\n"
//"out vec4 vertexColor\n;"
//"void main()\n"
//"{\n"
//"   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
//"   vertexColor = vec4(0.5, 0.0, 0.0, 1.0);"
//"}\n\0";
//
///*
// 片段着色器源码
//
// 片段着色器，它需要一个vec4颜色输出变量
// */
//const char *fragmentShaderSource = "#version 330 core\n"
//"in vec4 vertexColor;\n"
//"out vec4 FragColor;\n"
//"void main()\n"
//"{\n"
//"   FragColor = vertexColor;\n"
//"}\n\0";

// MARK: - 2.uniform 关键字
const char *vertexShaderSource = "#version 330 core\n"
"layout (location = 0) in vec3 aPos;\n"
"uniform float padding;\n"
"out vec4 loColor;\n"
"void main()\n"
"{\n"
"   gl_Position = vec4(aPos.x + padding, -aPos.y, aPos.z, 1.0);\n"
"   loColor = gl_Position;\n"
"}\n\0";

/*
 片段着色器源码
 
 片段着色器，它需要一个vec4颜色输出变量
 */
const char *fragmentShaderSource = "#version 330 core\n"
"uniform vec4 ourColor;\n"
"in vec4 loColor;\n"
"out vec4 FragColor;\n"
"void main()\n"
"{\n"
"   FragColor = loColor;\n"
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

unsigned int initFragmentShader() {
    unsigned int fragmentShader;
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
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
unsigned int initShaderProgram() {
    unsigned int shaderProgram;
    shaderProgram = glCreateProgram();
    
    unsigned int vertexShader = initVertexShader();
    unsigned int fragmentShader = initFragmentShader();
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
    
    // 使用线条的方式绘制
//    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    // 填充的模式 (默认的)
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    
    // 初始化着色器
    unsigned int shaderProgram = initShaderProgram();
    if (shaderProgram == -1) {
        return -1;
    }
    
    // 顶点数据
    float vertices[] = {
        0.5f, 0.5f, 0.0f,
        -0.5f, 0.5f, 0.0f,
        0.0f, -0.5f, 0.0f
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
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
    
    // 顶点属性位置值作为参数，启用顶点属性；顶点属性默认是禁用的。
    glEnableVertexAttribArray(0);
    // 在 glVertexAttribPointer 中已经将 vbo 注册为制定的缓冲区对象，
    // 所以这里可以安全的解绑
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    // 相当于解绑 VAO
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
        
        float padding = glGetUniformLocation(shaderProgram, "padding");
        glUniform1f(padding, 0.2f);
        
        float timeValue = glfwGetTime();
        float greenValue = sin(timeValue) / 2.0f + 0.5f;
        int vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");
        glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f);
        
        glBindVertexArray(VAO);
        // 绘制单个三角形
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glBindVertexArray(0);
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

