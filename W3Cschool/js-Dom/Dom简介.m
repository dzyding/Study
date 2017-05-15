/*
  1. 什么是DOM
 */

  DOM 是W3C (万维网联盟) 的标准
  DOM 定义了访问 HTML 和 XML 文档的标准

  	W3C 文档对象模型(DOM) 是中立于平台的语言的接口，它允许程序和脚本动态的访问和更新文档的内容 结构和样式

  	! DOM 是 Document Object Model (文档对象模型) 的缩写

  HTML DOM 是关于如何获取 修改 添加 或 删除HTML 元素的标准



/*
  2.根据W3C 的HTML DOM 标准，HTML 文档中的所有内容都是节点
 */
   .整个文档是一个文档节点
   .每个HTML 元素是一个元素节点
   .HTML 元素内的文本是文本节点
   .每个HTML 属性是属性节点
   .注释也是注释节点
   //  !!!!  文本  属性   注释 皆为节点

    ! HTML DOM 将HTML 文档视作树结构。 这种结构被称为 节点树
    ! 通过HTML DOM，树中的所有节点均可通过JavaScript 进行访问。所有HTML 元素(节点) 均可被修改，也可以创建或删除节点



/*
  3.节点 父(parent) 子(child) 同胞(sibling)
 */
    !!!! DOM 处理中常见错误是认为 元素节点 和 其中的文本节点为同一个节点。 这里其实是一个元素节点 + 一个文本节点

   .在节点树中，顶端的节点被称为根(root)
   .每个节点都有父节点 除了根 (它没有父节点)
   .一个节点可拥有任意数量的子
   .同胞是拥有相同父节点的节点

   eg:
    <html>
     <head>
      <title>DOM 教程</title>
     </head>
     <body>
      <h1>DOM 第一课  </h1>
      <p>Hello World!</p>
     </body>
    </html>
    
    从上面的HTML 中
     . <html> 节点没有父节点 它是根节点
     . <head> 和 <body> 的父节点是 <html> 节点
     . 文本节点 "Hello World!" 的父节点是 <p> 节点

    
    并且:
     . <html> 节点拥有两个子节点: <head> 和 <body>
     . <head> 节点拥有一个子节点: <title> 节点
     . <title>节点也拥有一个子节点: 文本节点 "DOM 教程"
     . <h1> 和 <p> 节点是同胞节点 同时也是 <body>的子节点


    并且:
     . <head>元素是<html> 元素的首个子节点
     . <body>元素是<html> 元素的最后一个子节点
     . <h1>元素是<body>元素的首个子节点
     . <p>元素是<body>元素的最后一个子节点





/*
  4.常用DOM 对象方法
 */
     .getElementById()        //返回带有指定ID的元素
     .getElementByTagName()   //返回包含带有指定标签名称的所有元素的节点列表
     .getElementByClassName() //返回包含带有指定类名的所有元素的节点列表
     .appendChild()           //把新的子节点添加到指定节点
     .removeChild()           //删除子节点
     .replaceChild()          //替换子节点
     .insertBefore()          //在指定的子节点前面插入新的子节点
     .createAttribute()       //创建属性节点
     .createElement()         //创建元素节点
     .createTextNode()        //创建文本节点
     .getAttribute()          //返回指定的属性值
     .setAttribute()          //把指定属性设置或修改为指定的值


/*
  5.常用的HTML DOM 属性
 */
     .innerHTML  //节点(元素)的文本值
     .parentNode //节点(元素)的父节点
     .childNodes //节点(元素)的子节点
     .attributes //节点(元素)的属性节点





















