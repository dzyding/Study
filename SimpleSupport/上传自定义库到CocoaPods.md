## 创建仓库，并提交代码
除了常见的 `add、commit、push` 操作，还需要添加 `tag`，`.podspec` 文件中 `s.version` 值需要包含在已存在的 `tag` 值之中。  
```
git tag 1.0.0
// 上传 1.0.0
git push origin 1.0.0 
// 上传所有 tag
git push [origin] --tags
```

## 打包图片为 bundle
这一步应该是在提交代码之前，随代码一起提交. 

- 创建 macOS bunle 项目。  
- 删除 `Info.plist` 文件，`Build Settings -> Packaging -> Info.plist File -> 空`。  
- `Build Settings -> Architectures -> Base SDK -> iOS`。  
- `Build Settings -> User-Defined -> COMBINE_HIDPI_IMAGES -> NO`，若不改动该属性，bundle 里面的 `png` 文件会默认为 `tiff` 格式。  
- 编译 `Command + B`，右键点击 `***.bundle` `Show in Finder`，直接复制出来使用。  

在项目中使用该 bundle 中的图片。  

```swift
let bundle = Bundle(url: Bundle(for: [AnyClass].self).url(forResource: [BundleName], withExtension: "bundle")!)
let image = UIImage(contentsOfFile: bundle?.path(forResource: [ImageName], ofType: "png") ?? "")
```

并不是只有这种方式，可以自己搜一下。

## 创建并修改 podspec 文件

创建文件  

```
pod spec create [文件名]
```

修改文件，可根据创建出来  

```
Pod::Spec.new do |s|

 s.name         = 'DzyImagePicker'

 s.version      = '1.0.5'

 s.summary      = 'image picker'

 s.description  = <<-DESC
                  仿微信制作的图片编辑控件，欢迎各位大佬提 pr
                   DESC

 s.homepage     = 'https://github.com/dzyding/ImagePicker'

 s.license      = { :type => 'MIT', :file => 'LICENSE' }

 s.author       = '灰s'

 s.platform     = :ios, '9.0'

 s.source        = { :git => 'https://github.com/dzyding/ImagePicker.git', :tag => '1.0.5' }

 s.source_files  = 'Source/*.swift'

 s.resources     = 'Resources/*.*'  

 s.swift_version = '4.2'

 s.dependency 'SnapKit', '~> 4.2.0'

end

```

## 登录 cocoaPods 并提交

检查是否注册  
```
pod trunk me
```

若没有注册，进行注册  
```
pod trunk register [注册github时填的邮箱] [github账号名称]
```

验证  
```
pod lib lint
```

提交  
```
pod trunk push [***.podspec]
```

我提交的项目的时候，正好 CocoaPods 有个关于 `s.swift_version` 的 bug，提示 warning 导致提交不上去，临时解决办法是在提交的代码后面加上 `--allow-warnings`。

## 注意事项
也许你跟我这个小白一样，第一次提交成功，正开心的时候，发现 `pod install` 以后，虽然可以导入头文件了，但是为什么找不到类，或者创建了类居然各种莫名其妙的问题，项目根本走不通，还各种 `baidu、google` 却依旧无果。其实原因很简单，纯粹是编程习惯不好。原因是 `访问控制` 问题。拿 Swift 来举例，就是 `open、public、internal、fileprivate、private`。默认为 `internal`，当做成框架以后，就会访问不到。  

简单修改就是全部改成 `public` 然后通过 `extension` 遵守协议以后，实现的协议方法全部用 `open`。具体的可以自行查阅。




