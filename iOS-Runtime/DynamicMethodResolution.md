
与大多数语言不同，在 Objective-C 中，`[object foo]` 语法并不会立即执行 `foo` 这个方法的代码。它是在运行时给 `object` 发送一条叫 `foo` 的消息。这个消息，也许会由 `object` 来处理，也许会被转发给另一个对象，或者不予理睬假装没收到这个消息。多条不同的消息也可以对应同一个方法实现。这些都是在程序运行的时候决定的。  

如果 `foo` 没有找到会发生什么？通常情况下，程序会在运行时挂掉并抛出 `unrecognized selector sent to …` 异常。但在异常抛出前，Objective-C 的运行时会给你三次拯救程序的机会：  

- Method resolution  

- Fast forwarding  

- Normal forwarding  

# Method resolution
首先，Objective-C 运行时会调用 `+resolveInstanceMethod:` 或者 `+resolveClassMethod:` (取决于你调用的是实例方法还是类方法)，让你有机会提供一个函数实现。如果你添加了函数并返回 YES， 那运行时系统就会重新启动一次消息发送的过程。  

请看下面的例子：  
```
// One.h 文件
@interface One : NSObject

//在 .h 文件中声明了 play 方法，但是并没有在 .m 文件中实现
- (void)play;

@end

```

```
// One.m 文件
@implementation One

void playMethod() {
    NSLog(@"play");
}

+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
    if (aSEL == @selector(play)) {
        class_addMethod([self class], aSEL, (IMP)playMethod, "v@");
        return YES;
    }
    return [super resolveInstanceMethod:aSEL];
}

/*
	//创建 IMP 的方法也可以这样直接使用 block，以避免单独定义一个方法
    IMP playImp = imp_implementationWithBlock(^(){
        NSLog(@"play");
    });
    class_addMethod([self class], aSEL, playImp, "v@");
 */

@end

```

**关于后面的那个 C 字符串 "v@"，它就是代表方法的类型，包括返回值，参数之类的，具体的可以看 [这篇文章](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1)，我这里就不详细说明了**

执行：
```
    One * object = [One new];
    [object play];
```

并不会像正常情况那样直接崩溃，而是会得到正确的执行结果： 

```
2018-09-29 17:27:48.753075+0800 180928_SendMessage[9228:313296] play
```

# Fast forwarding
如果目标对象没有实现 `+resolveInstanceMethod` 方法，但是实现了 `-forwardingTargetForSelector:` ，Runtime 这时就会调用这个方法，给你 **把这个消息转发给其他对象的机会**。  

只要这个方法返回的不是 `nil` 和 `self`，整个消息发送的过程就会被 **重启**，当然发送的对象会变成你返回的那个对象。否则，就会继续 Normal Fowarding 。

请看下面的例子：  
```
// One.h 文件
@interface One : NSObject

//在 .h 文件中声明了 play 方法，但是并没有在 .m 文件中实现
- (void)play;

@end

```

```
// One.m 文件
@interface One ()

@property (nonatomic, strong)Two * another;

@end

@implementation One

- (instancetype)init {
    self = [super init];
    if (self) {
        _another = [Two new];
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (aSelector == @selector(play)) {
    	// 这里只要是一个发送消息时存在的对象就行
        return _another;
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end
```

```
// Two.h
@interface Two : NSObject

@end
```

```
// Two.m
@implementation Two

- (void)play {
    NSLog(@"Two play");
}

@end
```

执行：
```
	One * object = [One new];
    [object play];
```

执行结果：
```
2018-09-29 17:47:40.512778+0800 180928_SendMessage[9624:326309] Two play
```

# Normal forwarding
这一步是 Runtime 最后一次给你挽救的机会。首先它会发送 `-methodSignatureForSelector:` 消息获得函数的参数和返回值类型。如果 `-methodSignatureForSelector:` 返回 `nil` ，Runtime 则会发出 `-doesNotRecognizeSelector:` 消息，程序这时也就挂掉了。  

如果返回了一个函数签名，Runtime 就会创建一个 `NSInvocation` 对象，并将其作为 `-forwardInvocation:` 方法的参数，发送消息给目标对象。  

`NSInvocation` 实际上就是对一个消息的描述，包括 `selector` 以及参数等信息。所以你可以在 `-forwardInvocation:` 里修改传进来的 `NSInvocation` 对象，并通过它的实例方法 `-invokeWithTarget:` 将消息传递一个新的目标。  

请看下面的例子 (这里为会写两个例子，顺便展示一下方法 type 字符串的用法)： 

### 例 1
```
// One.h
@interface One : NSObject

//在 .h 文件中声明了 play 方法，但是并没有在 .m 文件中实现
- (void)play:(NSInteger)num;

@end
```

```
// One.m

@interface One ()

@property (nonatomic, strong)Two * another;

@end

@implementation One

- (instancetype)init {
    self = [super init];
    if (self) {
        _another = [Two new];
    }
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	// "v@:l" 对应的就是返回值 void 并且有一个 long 类型的参数
    return [NSMethodSignature signatureWithObjCTypes:"v@:l"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	SEL sel = anInvocation.selector;
    if ([_another respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:_another];
    }else {
        [self doesNotRecognizeSelector:sel];
    }
}

@end

```

```
// Two.h
@interface Two : NSObject

@end
```

```
// Two.m
@implementation Two

- (void)play:(NSInteger)num {
    NSString * str = [NSString stringWithFormat:@"play %@",@(num).stringValue];
    NSLog(@"%@",str);
}

@end
```

执行：
```
    One * object = [One new];
    [object play: 5];
```

执行结果：
```
2018-09-29 18:05:38.890996+0800 180928_SendMessage[9931:337144] play 5
```

**在这个例子中 `methodSignatureForSelector` `forwardInvocation` 方法里面，我并没有对方法对象 `anInvocation` 进行更改，而在 Two 中正好有相同类型及名字的方法，所以就可以直接执行成功**

### 例 2
```
// One.h
@interface One : NSObject

//在 .h 文件中声明了 play 方法，但是并没有在 .m 文件中实现
- (void)play:(NSInteger)num;

@end
``` 

```
// One.m

@interface One ()

@property (nonatomic, strong)Two * another;

@end

@implementation One

- (instancetype)init {
    self = [super init];
    if (self) {
        _another = [Two new];
    }
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	// "v@:@@" 对应的就是返回值 void 并且有两个对象作为参数 的方法
    return [NSMethodSignature signatureWithObjCTypes:"v@:@@"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = @selector(anotherPlay:str:);
    NSNumber * num = @100;
    NSString * str = @"poi";

	//对应 objc_msgSend(id self, SEL op, ...) 方法 
	//第一参数为消息的接收者，第二个参数为方法名，其余的对应方法的参数
    //0 不用设是因为下面的方法会设置 target

    //设置方法名
    [anInvocation setArgument:&sel atIndex:1]; 
    //第一个参数是 index 2
    [anInvocation setArgument:&num atIndex:2]; 
    //第二个参数是 index 3
    [anInvocation setArgument:&str atIndex:3];

    if ([_another respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:_another];
    }else {
        [self doesNotRecognizeSelector:sel];
    }
}

@end

```

```
// Two.h
@interface Two : NSObject

@end
```

```
// Two.m
@implementation Two

- (void)anotherPlay: (NSNumber *) num str:(NSString *)s {
    NSString * str = [NSString stringWithFormat:@"another play %@ and %@",num.stringValue, s];
    NSLog(@"%@",str);
}

@end
```

执行：
```
    One * object = [One new];
    [object play: 5];
```

执行结果：
```
2018-09-30 09:17:31.242035+0800 180928_SendMessage[901:15033] another play 100 and poi
```

**在这个例子中 `methodSignatureForSelector` `forwardInvocation` 方法里面，我对方法对象 `anInvocation` 进行了更改，从而执行了一个与调用皆然不同的方法。**  

参考文章：  
[Objective-C Runtime](https://tech.glowing.com/cn/objective-c-runtime/)

