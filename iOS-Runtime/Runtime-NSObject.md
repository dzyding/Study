本打算自己看 [objc4](https://github.com/opensource-apple/objc4) 源码，奈何大致翻了一下发现完全没什么头绪，不知从何看起。真的很佩服那些通读源码的大佬。  

之后仔细阅读了几篇质量很棒的文章，读完以后对 `NSObject` 有了一个大致的了解，特来写这篇笔记。  

原文：  

1. [神经病院Objective-C Runtime入院第一天——isa和Class](https://www.jianshu.com/p/9d649ce6d0b8)  

2. [从 NSObject 的初始化了解 isa](https://github.com/Draveness/analyze/blob/master/contents/objc/从%20NSObject%20的初始化了解%20isa.md#shiftcls)  

3. [深入解析 ObjC 中方法的结构](https://github.com/Draveness/analyze/blob/master/contents/objc/深入解析%20ObjC%20中方法的结构.md#深入解析-objc-中方法的结构)  

## 笔记正文
首先需要说明一下，三篇文章里面并不是只讲了 `NSObject` 的结构，但是我这篇文章只谈 `NSObject` 的结构，如果之后对别的知识点有了更系统的了解，会重新开篇来写。  

```
typedef struct objc_class *Class;
typedef struct objc_object *id;

@interface Object { 
    Class isa; 
}

@interface NSObject <NSObject> {
    Class isa  OBJC_ISA_AVAILABILITY;
}

struct objc_object {
private:
    isa_t isa;

    ...
}

struct objc_class : objc_object {

    Class superclass;  

    cache_t cache;             // formerly cache pointer and vtable

    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags

    ...
}

union isa_t 
{
    isa_t() { }
    isa_t(uintptr_t value) : bits(value) { }

    //指向类信息
    Class cls;

    //对应 isa_t 的完整信息
    uintptr_t bits;

    ...
}
``` 

以上代码为 objc4 源码的片段，`NSObject` 的内部只有一个变量 `Class isa` ，其实就是一个指向 `objc_class` 的指针。`objc_class` 又是 `objc_object` 的子结构体。  

`NSObject` 的结构，伪代码：  

```
@interface NSObject <NSObject> {
    //isa 指向元类的指针
    isa_t isa;

    //当前类的父类
    Class superclass;  

    //方法缓存
    cache_t cache;             // formerly cache pointer and vtable

    //存储类的方法、属性和遵循的协议等信息的地方
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
}
```  

## 一、isa
在这里你需要了解 元类 (meta-class) 的概念，如果你还不清楚，可以自行搜索或者查看这篇文章 [What is a meta-class in Objective-C?](http://www.cocoawithlove.com/2010/01/what-is-meta-class-in-objective-c.html)。  

- 对象的 isa 指针，指向类对象。  
- 类对象的 isa 指针，指向元类。  

![](https://github.com/dzyding/Study/blob/master/iOS-Runtime/images/1-1.png)  

![](https://github.com/dzyding/Study/blob/master/iOS-Runtime/images/1-2.png)  

图中实线是 `super_class` 指针，虚线是 `isa` 指针。  

1. 每个 Instance (对象) 都有一个 `isa` 指向 Class。

2. 每个 Class (类对象) 都有一个 `isa` 指针指向唯一的 Meta class。 

3. Root class(class) 其实就是 `NSObject` ，`NSObject` 是没有超类的，所以Root class(class) 的 `superclass` 指向 nil。  

4. Root class(meta) 的 `superclass` 指向 Root class(class) ，也就是 `NSObject` ，形成一个回路。 

5. 每个 Meta class 的 `isa` 指针都指向 Root class(meta)。  

**这里有一个特殊情况，Tagged Pointer 是没有 isa 指针的，因为它不是真正的对象。  
具体的可以参考：[深入理解Tagged Pointer](http://blog.devtang.com/2014/05/30/understand-tagged-pointer/)**

### isa_t 的具体实现
isa_t 的具体实现在 32位 和 64位 系统上有点不一样。  

**32位：**  
```
union isa_t {
    isa_t() { }
    isa_t(uintptr_t value) : bits(value) { }

    Class cls;
    uintptr_t bits;
};
```

**64位：**  
```
union isa_t {
    isa_t() { }
    isa_t(uintptr_t value) : bits(value) { }

    Class cls;
    uintptr_t bits;
    
    //这里为只显示了 ARM64 的情况
#   define ISA_MASK        0x0000000ffffffff8ULL
#   define ISA_MAGIC_MASK  0x000003f000000001ULL
#   define ISA_MAGIC_VALUE 0x000001a000000001ULL
    struct {
        uintptr_t nonpointer        : 1;
        uintptr_t has_assoc         : 1;
        uintptr_t has_cxx_dtor      : 1;
        uintptr_t shiftcls          : 33;
        uintptr_t magic             : 6;
        uintptr_t weakly_referenced : 1;
        uintptr_t deallocating      : 1;
        uintptr_t has_sidetable_rc  : 1;
        uintptr_t extra_rc          : 19;
    };
};
```

二者的区别在于放 `cls` 的位置不同，对应初始化方法来看：  

```
inline void
objc_object::initInstanceIsa(Class cls, bool hasCxxDtor)
{
    initIsa(cls, true, hasCxxDtor);
}

inline void
objc_object::initIsa(Class cls, bool indexed, bool hasCxxDtor)
{
    if (!indexed) {
        // Class 信息放在 "外面"
        isa.cls = cls;
    } else {
        isa.bits = ISA_MAGIC_VALUE;
        isa.has_cxx_dtor = hasCxxDtor;
        // Class 信息放在 "里面"
        isa.shiftcls = (uintptr_t)cls >> 3;
    }
}
```  

会出现这种问题的原因是：**使用整个指针大小的内存来存储 isa 指针有些浪费，尤其在 64 位的 CPU 上。在 ARM64 运行的 iOS 只使用了 33 位作为类的指针，而剩下的 31 位用于其它目的。因为类的指针会根据字节对齐，每一个类指针的地址都能够被 8 整除，也就是使最后 3 bits 为 0，所以在 64位 系统上最终为 isa 留下 34 位用于性能的优化。**  

我这篇文章只介绍 64位 系统的情况。  

`isa_t` 是一个 union 类型的结构体，对 union 不熟悉的读者可以看这个 stackoverflow 上的 [回答](https://stackoverflow.com/questions/252552/why-do-we-need-c-unions)。也就是说其中的 `isa_t`、`cls`、 `bits` 还有结构体共用同一块地址空间。而 `isa_t` 总共会占据 64 位的内存空间（决定于其中的结构体）  

![](https://github.com/dzyding/Study/blob/master/iOS-Runtime/images/1-3.png)  

### indexed 和 magic
初始化方法中的赋值是这样的：
```
isa.bits = ISA_MAGIC_VALUE;
isa.has_cxx_dtor = hasCxxDtor;
isa.shiftcls = (uintptr_t)cls >> 3;
```
对整个 `isa` 的值 `bits` 进行设置，传入 `ISA_MAGIC_VALUE`：  

```
#define ISA_MAGIC_VALUE 0x001d800000000001ULL
```

我们可以把它转换成二进制的数据，然后看一下哪些属性对应的位被这行代码初始化了（标记为红色）：  

![](https://github.com/dzyding/Study/blob/master/iOS-Runtime/images/1-4.png)  

从图中了解到，在使用 `ISA_MAGIC_VALUE` 初始化 `isa_t` 结构体之后，实际上只是设置了 `indexed` 以及 `magic` 这两部分的值。  

- 其中 `indexed` 表示 `isa_t` 的类型  
    - 0 表示 `raw isa`，也就是没有结构体的部分，访问对象的 `isa` 就是指向 `cls` 的指针。(对应的 32位 系统)  
    
    - 1 表示当前 `isa` 不是指针，但是其中也有 `cls` 的信息，只是其中关于类的指针都是保存在 `shiftcls` 中。  

- `magic` 的值为二进制的 `110111`，十六进制的 `0x3b` 用于调试器判断当前对象是真的对象还是没有初始化的空间  


### has_cxx_dtor
在设置 `indexed` 和 `magic` 值之后，会设置 `isa` 的 `has_cxx_dtor`，这一位表示当前对象有 C++ 或者 ObjC 的析构器(destructor)，如果没有析构器就会快速释放内存。  

```
isa.has_cxx_dtor = hasCxxDtor;
```

![](https://github.com/dzyding/Study/blob/master/iOS-Runtime/images/1-5.png)

### shiftcls
在为 `indexed`、 `magic` 和 `has_cxx_dtor` 设置之后，我们就要将当前对象对应的类指针存入 `isa` 结构体中了。  

```
isa.shiftcls = (uintptr_t)cls >> 3;
```

> 将当前地址右移三位的主要原因是用于将 Class 指针中无用的后三位清除减小内存的消耗，因为类的指针要按照字节（8 bits）对齐内存，其指针后三位都是没有意义的 0。  
> 
> 绝大多数机器的架构都是 byte-addressable 的，但是对象的内存地址必须对齐到字节的倍数，这样可以提高代码运行的性能，在 iPhone5s 中虚拟地址为 33 位，所以用于对齐的最后三位比特为 000，我们只会用其中的 30 位来表示对象的地址。  

更详细的信息可以查阅这篇文章：[从 NSObject 的初始化了解 isa](https://github.com/Draveness/analyze/blob/master/contents/objc/从%20NSObject%20的初始化了解%20isa.md#shiftcls)

### 其他 bits
在 `isa_t` 中，我们还有一些没有介绍的其它 bits，在这个小结就简单介绍下这些 bits 的作用  

- has_assoc
    对象含有或者曾经含有关联引用，没有关联引用的可以更快地释放内存  

- weakly_referenced  
    对象被指向或者曾经指向一个 ARC 的弱变量，没有弱引用的对象可以更快释放  

- deallocating  
    对象正在释放内存  

- has_sidetable_rc  
    对象的引用计数太大了，存不下  

- extra_rc  
    对象的引用计数超过 1，会存在这个这个里面，如果引用计数为 10，extra_rc 的值就为 9  

## 二、cache

```
struct cache_t {
    struct bucket_t *_buckets;
    mask_t _mask;
    mask_t _occupied;
}

typedef unsigned int uint32_t;
typedef uint32_t mask_t;  // x86_64 & arm64 asm are less efficient with 16-bits

typedef unsigned long  uintptr_t;
typedef uintptr_t cache_key_t;

struct bucket_t {
private:
    cache_key_t _key;
    IMP _imp;
}
```

![](https://github.com/dzyding/Study/blob/master/iOS-Runtime/images/1-6.png)  

- mask  
    分配用来缓存bucket的总数。
- occupied  
    表明目前实际占用的缓存bucket的个数。

- buckets  
    其实就是一个散列表，用来存储 Method 的链表。`bucket_t` 的结构体中存储了一个 `unsigned long` 和一个 `IMP`。`IMP`是一个函数指针，指向了一个方法的具体实现。

`cache` 的作用主要是为了优化方法调用的性能。当对象 receiver 调用方法 message 时，首先根据对象 receiver 的 `isa` 指针查找到它对应的类，然后在类的 `methodLists` 中搜索方法，如果没有找到，就使用 `super_class` 指针到父类中的 `methodLists` 查找，一旦找到就调用方法。如果没有找到，有可能消息转发，也可能忽略它。  

但这样查找方式效率太低，因为往往一个类大概只有 20% 的方法经常被调用，占总调用次数的 80%。所以使用 `cache` 来缓存经常调用的方法，当调用方法时，优先在 `cache` 查找，如果没有找到，再到 `methodLists` 查找。  


## 三、class_data_bits_t bits
它就是存储类的方法、属性和遵循的协议等信息的地方，实例方法被调用时，会通过其持有 `isa` 指针寻找对应的类，然后在其中的 `class_data_bits_t` 中查找对应的方法。  

### class_data_bits_t 结构体
下面就是 ObjC 中 `class_data_bits_t` 的结构体，其中只含有一个 64 位的 bits 用于存储与类有关的信息：  

![](https://github.com/dzyding/Study/blob/master/iOS-Runtime/images/1-7.png)

在 `objc_class` 结构体中的注释写到 `class_data_bits_t` 相当于 `class_rw_t` 指针加上 rr/alloc 的标志。  

```
class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
```

它为我们提供了便捷方法用于返回其中的 `class_rw_t *` 指针：  

```
class_rw_t* data() {
   return (class_rw_t *)(bits & FAST_DATA_MASK);
}
```  

将 `bits` 与 `FAST_DATA_MASK` 进行位运算，只取其中的 [3, 47] 位转换成 `class_rw_t *` 返回。  

> 在 x86_64 架构上，Mac OS 只使用了其中的 47 位来为对象分配地址。而且由于地址要按字节在内存中按字节对齐，所以掩码的后三位都是 0。  

因为 `class_rw_t *` 指针只存于第 [3, 47] 位，所以可以使用最后三位来存储关于当前类的其他信息：  

![](https://github.com/dzyding/Study/blob/master/iOS-Runtime/images/1-8.png)  

```
#define FAST_IS_SWIFT           (1UL<<0)
#define FAST_HAS_DEFAULT_RR     (1UL<<1)
#define FAST_REQUIRES_RAW_ISA   (1UL<<2)
#define FAST_DATA_MASK          0x00007ffffffffff8UL
```  

- isSwift()  
    `FAST_IS_SWIFT` 用于判断 Swift 类  

- hasDefaultRR()  
    `FAST_HAS_DEFAULT_RR` 当前类或者父类含有默认的 `retain/release/autorelease/retainCount/_tryRetain/_isDeallocating/retainWeakReference/allowsWeakReference` 方法  

- requiresRawIsa()  
    `FAST_REQUIRES_RAW_ISA` 当前类的实例需要 `raw isa`  

执行 `class_data_bits_t` 结构体中的 `data()` 方法或者调用 `objc_class` 中的 `data()` 方法会返回同一个 `class_rw_t *` 指针，因为 `objc_class` 中的方法只是对 `class_data_bits_t` 中对应方法的封装。  

```
// objc_class 中的 data() 方法
class_data_bits_t bits;

class_rw_t *data() { 
   return bits.data();
}

// class_data_bits_t 中的 data() 方法
uintptr_t bits;

class_rw_t* data() {
   return (class_rw_t *)(bits & FAST_DATA_MASK);
}
```  

### class_rw_t 和 class_ro_t
ObjC 类中的属性、方法还有遵循的协议等信息都保存在 `class_rw_t` 中：  

```
struct class_rw_t {
    uint32_t flags;
    uint32_t version;

    const class_ro_t *ro;

    method_array_t methods;
    property_array_t properties;
    protocol_array_t protocols;

    Class firstSubclass;
    Class nextSiblingClass;
};
```

其中还有一个指向常量的指针 ro，其中存储了当前类在 **编译期就已经确定的属性、方法以及遵循的协议**。  

```
struct class_ro_t {
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
    uint32_t reserved;

    const uint8_t * ivarLayout;
    
    const char * name;
    method_list_t * baseMethodList;
    protocol_list_t * baseProtocols;
    const ivar_list_t * ivars;

    const uint8_t * weakIvarLayout;
    property_list_t *baseProperties;
};
```

在 **编译期间** 类的结构中的 `class_data_bits_t *bits` 指向的是一个 `class_ro_t *` 指针：  

![](https://github.com/dzyding/Study/blob/master/iOS-Runtime/images/1-9.png)  

然后在加载 ObjC 运行时的时候调用 `realizeClass` 方法：  

1. 从 class_data_bits_t 调用 data 方法，将结果从 class_rw_t 强制转换为 class_ro_t 指针  

2. 初始化一个 class_rw_t 结构体  

3. 设置结构体 ro 的值以及 flag  

4. 最后设置正确的 data。  

```
const class_ro_t *ro = (const class_ro_t *)cls->data();
class_rw_t *rw = (class_rw_t *)calloc(sizeof(class_rw_t), 1);
rw->ro = ro;
rw->flags = RW_REALIZED|RW_REALIZING;
cls->setData(rw);
```  

下图是 `realizeClass` 方法执行过后的类所占用内存的布局，你可以与上面调用方法前的内存布局对比以下，看有哪些更改：  

![](https://github.com/dzyding/Study/blob/master/iOS-Runtime/images/1-10.png)  

但是，在这段代码运行之后 `class_rw_t` 中的方法，属性以及协议列表均为空。这时需要 realizeClass 调用 `methodizeClass` 方法来 **将类自己实现的方法（包括分类）、属性和遵循的协议加载到 methods、 properties 和 protocols 列表中。**  

更详细的信息可以查阅这篇文章：[深入解析 ObjC 中方法的结构](https://github.com/Draveness/analyze/blob/master/contents/objc/深入解析%20ObjC%20中方法的结构.md#深入解析-objc-中方法的结构)  