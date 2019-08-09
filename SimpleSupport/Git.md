# 常用命令行介绍
```
// 拷贝
cp [目标文件] [当前路径下的存储名]  
cp -r .....(-r 表示递归拷贝) 
```

# 使用的最小配置
```
$git config --global user.name 'your_name'  
$git config --global user.email 'your_email@domain.com'  
```

```
// 修改
git config --local user.name `suling` 

// 查询
git config --local user.name  
```

```
--local		//只针对一个仓库  
--global	//当前用户的所有仓库  
--system	//对系统所有登陆的用户有效  
```

```
显示 config 的配置, 加 --list  
$git config --list --local  
```

# 认识工作区和暂存区
`git add [name] [name]`  
add 完了就到“暂存区”了

`git commit -m"123"`  
commit 之后就到版本历史里面了  

`git log`  查看日志  

# git 重命名
正常的本地修改文件名，然后通过 add [新] 及 del[旧] 提交到暂存区，相当于把重命名弄成了两步。  

// 清除暂存区的所有修改  
`git reset --hard`  

// 重命名 最合适的方法  
`git mv [旧文件名] [新文件名]`  

# Git log

// 简洁 log 列表  
`git log --oneline`   

// 简洁 log 的前两个  
`git log -n2 --oneline`    

// 当前分支的 log  
`git log`   

// 所有分支的信息  
`git log --all`   

// 图表形式  
`git log --all --graph`    

// 查看详细的文档（web形式）  
`git help [--web] log`     

# gitk 

```
默认用不了是因为是使用 Apple 发行的 Git，所以你需要先安装一下 Homebrew：
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
接着升级并安装最新版 Git：
brew update
brew install git
然后设置一下：
export PATH=/usr/local/bin:$PATH
再输入 gitk 见可以使用了
```

# .git目录

 - HEAD  
	是一个当前仓库的引用  
 
 - config  
 	配置文件 

 - refs  
 	引用（包含 tags(标签)，heads(分支)) 

 - objects  
    对象  

```
	...
	drwxr-xr-x   3 dzy  staff   96 11 11  2018 1c
	drwxr-xr-x   3 dzy  staff   96 11 11  2018 1f
	...

	//用文件夹名字的两个字母拼上文件夹中的内容，查看文件，比如 1c

	DzyMac:objects dzy$ cd 1c/
	DzyMac:1c dzy$ ls -al
	total 8
	drwxr-xr-x   3 dzy  staff   96 11 11  2018 .
	drwxr-xr-x  14 dzy  staff  448 11 26  2018 ..
	-r--r--r--   1 dzy  staff  131 11 11  2018 4abbcff8abaa7a5842b6f96b8b15a7a9d607d0

	DzyMac:1c dzy$ git cat-file -t 1c4abbcff8abaa7a5842b6f96b8b15a7a9d607d0
	tree

	DzyMac:1c dzy$ git cat-file -p 1c4abbcff8abaa7a5842b6f96b8b15a7a9d607d0
	100755 blob 27c4df0443754c2a97ae22c289953767ab34be6d	
	"primer_c++_\344\270\200\343\200\201\344\272\214_\351\232\217\347\254\224.md"

	100755 blob 36fbc7771b20617abd3da84a1ba72888bc8e253f	
	"primer_c++_\344\270\211_\345\255\227\347\254\246\344\270\262\343\200\201\346\225\260\347\273\204\343\200\201\345\220\221\351\207\217.md"
```

指令介绍
```
cat [文件名] //查看文件
cat-file-t [hash] // 查看文件类型
cat-file-p [hash] // 查看对象
```

# commit、tree、blob 三个对象之间的关系

```
commit 提交
tree 关系
blob 文件
```

# 分离头指针

```
// 分离头指针创建一个临时的"分支"，进行修改以后
// 如果觉得没用，就不保存直接切回原来的分支，如果有用，就根据当前的"分支"，创建一个真实分支
git checkout [log的hash值]
```

```
// 不用 add .，直接生成 commit 
git commit -am'注解'
```

# 进一步理解 HEAD 和 branch

```
// 创建分支，并立即切换过去
git checkout -b [新分支名字] [所基于的分支]
```

HEAD 最终是落脚于 `commit`，比如切换分支操作以后就是指着当前分支的最新 `commit`

1. 一个节点，可以包含多个子节点(checkout 出多个分支)  
2. 一个节点，可以有多个父节点(多个分支合并)  

```
^和~都是父节点，区别是跟随数字的时候，^2 是第二个父节点，~2 是父节点的父节点

// 对比 HEAD 和他的 父亲
git diff HEAD HEAD^  
git diff HEAD HEAD~1

// 对比 HEAD 和他 父亲的父亲
git diff HEAD HEAD^^
git diff HEAD HEAD~2

// 对比 HEAD 和他的第二个父节点
git diff HEAD HEAD^2
```

# 更改最新的 commit 的信息

```
git commit --amend
```

# 更改老旧的 commit 信息

``` 
git rebase -i [被变log父亲的hash值]
```

```
pick   // 采用 commit 
reword // 更改 commit 信息
```

# 将多个连续的 commit 合并成一个

``` 
git rebase -i [被变log父亲的hash值]
```

```
pick 
squash // 将当前 commit 合并到前一个`
```

# 将多个不连续的 commit 合并成一个

``` 
git rebase -i [被变log父亲的hash值]  // 若已经是头，则用自己的 hash 值
```

```
pick 
squash // 将当前 commit 合并到前一个`
```

eg: 现在有 3 个 commit，我要合并 1 和 3

```
pick 3
squash 1
pick 2
```

这里操作完了，不会直接弹出第二个更改 commit 信息的界面，需要敲代码 `git rebase --continue`，敲 `git status` 时会提示

# 怎么比较暂存区和 HEAD 所含文件的差异

```
// 比较暂存区 和 HEAD (暂存区就是执行过 add 操作，还未 commit 的)
git diff --cached
```

# 比较工作区和暂存区所含文件的差异

```
git diff  //整体工作区和暂存区的比较 (工作区就是还未执行 add 操作的)
git diff -- readme.md //工作区的 readme.md 和 暂存区的 readme.md 比较
```

# 如何让暂存区恢复成和 HEAD 一样的

```
// 就是撤销 add 操作?
git reset HEAD
```

```
工作区: 我们实时更改的文件的地方
HEAD: 指向最近的一次 commit  所以 工作区 > HEAD (更新一些)
暂存区: 工作区进行了 add 操作，还未执行 commit 操作。

eg: 所以若是执行了 commit 操作 
		HEAD
			工作区
			暂存区
	
	这时如果执行 git reset HEAD 操作 (即有文件改动，但是还未执行 add 或者 commit)
		HEAD
			工作区
		暂存区

	这时如果执行 git checkout -- [文件名] 恢复了改动 (即没有文件被改动)
		HEAD
		工作区
		暂存区

```

## 回退

- git log
  查看commit 的唯一代码  
  
- git reset  
    - git reset --mixed 
      默认的方式 --mixed可以省略
      会保留源码,只是将git commit和index 信息回退到了某个版本

    - git reset --soft
      保留源码,只回退到commit 信息到某个版本.不涉及index的回退,如果还需要提交,直接commit即可. (不太明白)

    - git reset --head
      不保留源码 回退到某个版本  

- git revert  
  revert 用于反转提交，commit之后好像就是覆盖之前的某个log记录 

### 两者的区别:
  - 上面我们说的如果你已经push到线上代码库, reset 删除指定commit以后,你git push可能导致一大堆冲突.但是revert 并不会.

  - 如果在日后现有分支和历史分支需要合并的时候,reset 恢复部分的代码依然会出现在历史分支里.但是revert 方向提交的commit 并不会出现在历史分支里.

  - reset 是在正常的commit历史中,删除了指定的commit,这时 HEAD 是向后移动了
	 revert 是在正常的commit历史中再commit一次,只不过是反向提交,他的 HEAD 是一直向前的.


# 如何让工作区的文件恢复为和暂存区一样

``` 
//总结
暂存区与HEAD比较：git diff --cached

暂存区与工作区比较: git diff

暂存区恢复成HEAD : git reset HEAD

暂存区覆盖工作区修改：git checkout -- [文件名] //可以同时处理多个文件 [文件名] [文件名]
```

# 取消暂存区部分文件的更改

```
git reset HEAD -- [文件名] //可以同时处理多个文件 [文件名] [文件名]
```

# 消除最近的几条 commit 

```
// HEAD 指向该 commit，暂存区 和 工作区 都恢复成该 commit 的样子。
git reset --hard [对应 commit 的 hash 值]
```

# 对比不同 commit 之间的差别

```
// 比较两个分支的全部文件
git diff temp master

// 比较两个分支中的某个文件 (这里的分支名 temp master 本质就是对应分支中最新的 commit)
git diff temp master -- [文件名]

// 比较两个 commit 
git diff [hash值] [hash值] -- [文件名]
```

# 正确删除文件的方法

```
git rm [文件名]
```

# 开发中临时加塞了任务怎么办

```
/// 暂存
git stash 

/// 查看暂存列表
git stash list

/// 将暂存的东西放入工作区，并保存 git stash list 中的信息。（可重复使用）
git stash apply

/// 将暂存的东西放入工作区，并删除 git stash list 中的信息。
git stash pop
```

# 创建 GitHub 账户

```
// 切换到 ssh 目录，如有有文件，就是已经生成过了
cd ~/.ssh
ls -al
```

# 本地仓库同步到 github

```
// 新增一个远端的仓库 （fetch 拉） （push 推） （origin 为默认缺省的地址，这里指定了名字 github）
git remote add github [ssh地址]

// 推送所有的分支
git push github --all 

// pull 就是 fetch + merge
git fetch github master
git checkout master
// 普通的合并，这里因为 master 和 github 属于独立的两个分支(no fast forwad)，所以会报错
git merge github/master
// 合并两个互相独立的分支
git merge --allow-unrelated-histories github/master 
// push
git push github master

// 查看本地有多少分支
git branch -v 

// 查看本地和远端有多少分支
git branch -va
```

# 不同人修改了不同文件怎么办

```
// 创建另一个文件夹，模拟两人操作
git clone [ssh] [自定义文件夹名字]

git config --add --local user.name '[name]'

git config --add --local user.email '[email]'

git config --local -l

// 基于远端的一个分支，创建一个新的分支
git checkout -b feature/add_git_commands origin/feature/add_git_commands

// 执行完 add commit 执行 push 时，因为创建的时候就将其与远端的分支关联了，所有可以省略后面执行操作的两个分支名
git push 

```

```
如果在进行git push之前发现远程又有了更新，比较好的做法应该是，将本地的提交回退掉，避免掉无用的远程merge本地分支的提交记录，可以使用如下命令：
1.git reset HEAD~
2.git pull
然后重新进行新的提交，这样就可以避免掉远程与本地分支的merge提交记录，让git的提交历史更加干净
```

# 不同人修改了相同文件的不同区域

```
// [git add .] + [git commit -m]
git commit -am'[msg]'
```

# 不同人修改了相同文件的同区域

```
// 恢复成 merge 之前的状态
git merge --abort 

// 唤起git设置的冲突解决可视化界面
git mergetool
```

# 同时更变了文件名和文件内容如何处理

可以自动匹配被变更文件名的文件，并且自动完成 merge，而不会出现冲突  

# 把同一个文件改成了不同的文件名

merge 完成以后，会把两个文件都留存，而不做任何处理

# 禁止向集成分支执行 push -f

```
// 强烈禁止！！！
git reset --hard [hash值] 		// 将 HEAD 会退到指定 commit
git push -f [远端仓库] [本地分支]  // 强制修改，忽略警告
```

```
可以使用 git reflog 命令查找历史，然后利用 git reset --hard HAED@{n} 的方式恢复。
```