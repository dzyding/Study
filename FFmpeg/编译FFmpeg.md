## 导航

1. <a href="#1">关于 curl 命令</a> 
2. <a href="#2">Mac 安装 yasm（汇编编译工具）</a>  
3. <a href="#3">编译安装 SDL (ffplay 工具需要)</a> 
4. <a href="#4">编译安装 FFmpeg</a> 

## <a id="1">关于 curl 命令</a>

curl 是一款实用的URL命令行网络通讯工具/库,使用curl 命令可以执行常用的http,https 操作

```
下载文件 ‘http://baidu.com’ 是文件的url 地址，‘> baidu.html’ 表示下载的数据写入文件baidu.html
curl http://baidu.com > baidu.html

也可以这样写：
curl -o baidu.html  http://baidu.com

比如: 
1> cd  /Users/yang/Desktop/abc
2> curl https://www.baidu.com/img/bd_logo1.png > logo.png
表示将图片资源下载到/Users/yang/Desktop/abc 路径,并另存为 logo.png
```

## <a id="2">Mac 安装 yasm（汇编编译工具）</a>

```
1、下载 安装包
curl http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz >yasm.tar.gz

2、解压文件
tar xzvf yasm.tar.gz

3  切换目录
cd yasm-1.2.0

4、运行
./configure --prefix=/usr/local/yasm
//configure脚本会寻找最合适的C编译器，并生成相应的makefile文件

5、编译文件
make

6、安装软件
sudo make install


说明:
(1) 多个终端命令也可以连写,命令与命令之间采用 && 来连接,这样多个命令就会顺序执行了
比如: ./configure && make  && sudo make install
(2) 其实很多 xxx.tar.gz 文件的安装方法都是3大步:
 第一步:  ./configure   主要是生成makefile文件
 第二步:   make 编译生成二进制安装文件
 第三步: sudo make install 或 make install 安装.
```

## <a id="3">编译安装 SDL (ffplay 工具需要)</a>

> 始终无法把 ffplay 工具编译安装出来，不知道为什么，后来直接下载了一个 ffplay 的可执行文件放到了 bin 目录

1. 下载代码

安装 1.2 和 2.0 版本

`https://www.libsdl.org/download-2.0.php`

`https://www.libsdl.org/download-1.2.php`

mac 下载 tar.gz 的版本

2. 切换到目录，运行 congifure 配置

`./configure --prefix=/usr/local/SDL`

3. 编译安装

`sudo make -j 4`

`sudo make install`

## <a id="4">编译安装 FFmpeg</a>

> 这个安装版本好像是没有 ffplay 的，可以去 https://evermeet.cx/ffmpeg/ 单独下载一个，直接放到 /usr/local/ffmpeg/bin 里面

1. 下载代码 （这个是国内的镜像）

`git clone https://gitee.com/mirrors/ffmpeg.git`

2. 切换到目录，运行 configure 配置

> --prefix=/usr/local/ffmpeg 安装目录
> --enable-debug=3 开启 debug
> // 可以查询对应的所有配置项
> ./configure --help | grep static 

`./configure --prefix=/usr/local/ffmpeg --enable-debug=3 --enable-ffplay`

./configure --enable-shared  --enable-debug=3  --enable-ffplay --prefix=/usr/local/ffmpeg 


3. 编译

> -j 4 的意思是增加4个内核进行编译

`make -j 4`

4. 安装

`sudo make install`

5. 清理

`make clean`

清除上次的make命令所产生的object文件（后缀为“.o”的文件）及可执行文件。

`make distclean`

类似make clean，但同时也将configure生成的文件全部删除掉，包括Makefile












