//
//  main.cpp
//  OpenGL_1
//
//  Created by edz on 2019/9/3.
//  Copyright © 2019 灰s. All rights reserved.
//

#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

void initGLFW() {
    // 初始化 glfw
    glfwInit();
    /*
     glfwWindowHint 配置 GLFW 的函数
     第一个参数代表选项名称
     第二个参数
     */
    // 我们需要告诉 GLFW 我们要使用的 OpenGL 版本是3.3，
    // 这样 GLFW 会在创建 OpenGL 上下文时做出适当的调整
    // MAJOR 主版本号
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    // MINOR 次版本号
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    // 使用的是核心模式(Core-profile)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    //Mac OS X 系统，需要加下面这行代码到初始化代码中这些配置才能起作用
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
}

// 窗口大小被调整时的回调函数
void framebuffer_size_callback(GLFWwindow* window, int width, int height) {
    glViewport(0, 0, width, height);
}

void processInput(GLFWwindow * window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

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
    
    //3. 初始化 glad
    /*
     GLAD是用来管理OpenGL的函数指针的，所以在调用任何OpenGL的函数之前我们需要初始化GLAD
     我们给GLAD传入了用来加载系统相关的OpenGL函数指针地址的函数。
     GLFW给我们的是glfwGetProcAddress，它根据我们编译的系统定义了正确的函数。
     */
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cout << "Faild to initialize Glad" << std::endl;
        return -1;
    }
    
    //4. 初始化视口
    /*
     调用glViewport函数来设置窗口的维度(Dimension)
     四个参数对应 frame 的四个值
     我们实际上也可以将视口的维度设置为比GLFW的维度小，
     这样子之后所有的OpenGL渲染将会在一个更小的窗口中显示，
     这样子的话我们也可以将一些其它元素显示在OpenGL视口之外。
     */
    glViewport(0, 0, 800, 600);
    
    //  创建 窗口调整大小 时的回调
    //  创建窗口之后，渲染循环初始化之前注册这些回调函数
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    // 5. 准备引擎
    // 渲染循环(Render Loop)，直到我们让 glfw 退出前，一直循环
    /*
     glfwWindowShouldClose函数
         在我们每次循环的开始前检查一次GLFW是否被要求退出，
         如果是的话该函数返回true然后渲染循环便结束了，之后为我们就可以关闭应用程序了。
     glfwPollEvents函数
         检查有没有触发什么事件（比如键盘输入、鼠标移动等）、更新窗口状态，
         并调用对应的回调函数（可以通过回调方法手动设置）。
     glfwSwapBuffers函数
         会交换颜色缓冲（它是一个储存着GLFW窗口每一个像素颜色值的大缓冲），
         它在这一迭代中被用来绘制，并且将会作为输出显示在屏幕上。
     */
    while (!glfwWindowShouldClose(window)) {
        // 检查是否有输入 exc
        processInput(window);
        
        /*
         我们可以通过调用glClear函数来清空屏幕的颜色缓冲，
         它接受一个缓冲位(Buffer Bit)来指定要清空的缓冲，可能的缓冲位有
             GL_COLOR_BUFFER_BIT，
             GL_DEPTH_BUFFER_BIT，
             GL_STENCIL_BUFFER_BIT。
         由于现在我们只关心颜色值，所以我们只清空颜色缓冲
         
         glClearColor来设置清空屏幕所用的颜色
         
         glClearColor函数是一个状态设置函数，而glClear函数则是一个状态使用的函数
         */
        glClearColor(0.2f, 0.3f, 0.3f, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // 检查并调用事件，交换缓冲
        glfwPollEvents();
        glfwSwapBuffers(window);
    }
    
    // 释放/删除之前的分配的所有资源
    glfwTerminate();
    return 0;
}

