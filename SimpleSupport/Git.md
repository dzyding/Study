## 1. 初始化
在各大网站上创建仓库，可以选择是否需要初始化。
如果在网站的仓库中不进行初始化，链接远程仓库以后，需手动初始化。
如果仓库已经初始化，则直接克隆使用。 

## 2. 远程仓库相关操作
- 添加远程仓库：$ git remote add [name] [url]	 //这里的name相当于是自己定义一个
- 删除远程仓库：$ git remote rm [name]
- 修改远程仓库：$ git remote set-url --push [name] [newUrl]
- 拉取远程仓库：$ git pull [remoteName] [localBranchName]	 //localBranchName 可以是提交分支
- 推送远程仓库：$ git push [remoteName] [localBranchName]:[remoteRepositoryBranchName]  
  remoteRepositoryBranchName 可以省略，如果省略就是默认提交到 remote 上与 localBranchName 相同名字的 branch


## 3. .gitignore 忽略部分文件
比如.DS_Store

## 4. 更改用户名和邮箱
- $ git config --global user.name "<用户名>"	 //还有个--local关键字
- $ git config --global user.email "<邮箱>"

## 5. 基本操作
- git status                       //查看状态
- git add <文件名>	      	//添加一个文件
- git add -A 	         	//添加全部文件
- git commit -m "备注"   	//提交 上传
- git rm 					//删除某个元素

## 6. 分支
- git branch 				//查看分支
- git checkout -b [分支名] //创建分支并切换
- git checkout [分支名]	//切换分支
- git merge [分支名]		//合并某分支到现有分支

## 7. 回退
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

#### 两者的区别:
  - 上面我们说的如果你已经push到线上代码库, reset 删除指定commit以后,你git push可能导致一大堆冲突.但是revert 并不会.

  - 如果在日后现有分支和历史分支需要合并的时候,reset 恢复部分的代码依然会出现在历史分支里.但是revert 方向提交的commit 并不会出现在历史分支里.

  - reset 是在正常的commit历史中,删除了指定的commit,这时 HEAD 是向后移动了
	 revert 是在正常的commit历史中再commit一次,只不过是反向提交,他的 HEAD 是一直向前的.


## 8. 比较
- 覆盖
 	git diff [分支1] [分支2] >  a.txt 
- 追加
 	git diff [分支1] [分支2] >> a.txt 
- 查看当前版本的改动
	git diff [分支1] > a.txt