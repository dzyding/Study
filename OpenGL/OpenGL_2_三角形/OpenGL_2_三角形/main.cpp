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
 1. 我们使用一个顶点缓冲对象将顶点数据初始化至缓冲中，
 2. 建立了一个顶点和一个片段着色器，
 3. 并告诉了OpenGL如何把顶点数据链接到顶点着色器的顶点属性上
 */

//MARK: - 初始化 glfw
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
    
    //  创建窗口调整大小 时的回调
    //  创建窗口之后，渲染循环初始化之前注册这些回调函数
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    // 初始化着色器
    unsigned int shaderProgram = initShaderProgram();
    if (shaderProgram == -1) {
        return -1;
    }
    
    // 顶点数据
    float vertices[] = {
        0.5f, 0.5f, 0.0f,   //  右上角
        0.5f, -0.5f, 0.0f,  //  右下角
        -0.5f, -0.5f, 0.0f, //  左下角
        -0.5f, 0.5f, 0.0f   //  左上角
    };
    
    // 索引数组
    unsigned int indices[] = {
        0, 1, 3,    // 第一个三角形
        1, 2, 3     // 第二个三角形
    };
    
    // 创建 VBO（顶点缓冲） 对象
    unsigned int VBO;
    // 创建 VAO （顶点数组） 对象
    unsigned int VAO;
    // 创建 EBO （索引缓冲） 对象
    unsigned int EBO;
    glGenBuffers(1, &VBO);
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &EBO);
    
    // 绑定数组对象
    glBindVertexArray(VAO);
    /*
     OpenGL有很多缓冲对象类型，顶点缓冲对象的缓冲类型是GL_ARRAY_BUFFER。
     OpenGL允许我们同时绑定多个缓冲，只要它们是不同的缓冲类型。
     */
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    // 从这一刻起，我们使用的任何（在GL_ARRAY_BUFFER目标上的）
    // 缓冲调用都会用来配置当前绑定的缓冲(VBO)
    
    /*
     GL_STATIC_DRAW ：数据不会或几乎不会改变。
     GL_DYNAMIC_DRAW：数据会被改变很多。
     GL_STREAM_DRAW ：数据每次绘制时都会改变。
     
     把之前定义的顶点数据复制到缓冲的内存中
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 先绑定EBO然后用glBufferData把索引复制到缓冲里
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    //现在我们已经把顶点数据储存在显卡的内存中，用VBO这个顶点缓冲对象管理。
    
    /*
     告诉OpenGL该如何解析顶点数据
     
     第一个参数指定我们要配置的顶点属性
     顶点着色器的定义中 layout(location = 0)
     定义了position顶点属性的位置值(Location)吗？
     它可以把顶点属性的位置值设置为0。
     然后第一个参数的 0 就对应的我们所设置的 0，相当于指定。
     第二个参数指定顶点属性的大小，矢量数量 vec[1-4] 中的 [1-4]
     第三个参数指定数据类型 这里是GL_FLOAT(GLSL中vec*都是由浮点数值组成的)
     第四个参数定义我们是否希望数据被标准化(Normalize)。
     如果我们设置为GL_TRUE，所有数据都会被映射到0（对于有符号型signed数据是-1）到1之间。
     第五个参数叫做步长(Stride)。连续的顶点属性组之间的间隔。
     最后一个参数表示位置数据在缓冲中起始位置的偏移量(Offset)。
     由于位置数据在数组的开头，所以这里是0。
     
     每个顶点属性从一个VBO管理的内存中获得它的数据，而具体是从哪个VBO
     （程序中可以有多个VBO）获取则是通过在调用glVertexAttribPointer时
     绑定到GL_ARRAY_BUFFER的VBO决定的。
     由于在调用glVertexAttribPointer之前绑定的是先前定义的VBO对象，
     顶点属性0现在会链接到它的顶点数据。
     */
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
    
    // 顶点属性位置值作为参数，启用顶点属性；顶点属性默认是禁用的。
    glEnableVertexAttribArray(0);
    // 在 glVertexAttribPointer 中已经将 vbo 注册为制定的缓冲区对象，
    // 所以这里可以安全的解绑
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    // 相当于解绑 VAO
    glBindVertexArray(0);
    
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
        
        // 在glUseProgram函数调用之后，
        // 每个着色器调用和渲染调用都会使用这个程序对象（也就是之前写的着色器)了。
        glUseProgram(shaderProgram);
        /*
         现在，我们已经把输入顶点数据发送给了GPU，并指示了GPU如何在顶点和片段着色器中处理它。
         就快要完成了，但还没结束，OpenGL还不知道它该如何解释内存中的顶点数据，
         以及它该如何将顶点数据链接到顶点着色器的属性上。我们需要告诉OpenGL怎么做。
         */
        
        glBindVertexArray(VAO);
        /*
         第一个参数是我们打算绘制的OpenGL图元的类型
         第二个参数指定了顶点数组的起始索引
         最后一个参数指定我们打算绘制多少个顶点，
         这里是3（我们只从我们的数据中渲染一个三角形，它只有3个顶点长）。
         */
//        glDrawArrays(GL_TRIANGLES, 0, 3);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
//        glBindVertexArray(0);
        // 检查并调用事件，交换缓冲
        glfwPollEvents();
        glfwSwapBuffers(window);
    }
    
    // 销毁对象
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteBuffers(1, &EBO);
    
    // 释放/删除之前的分配的所有资源
    glfwTerminate();
    return 0;
}

