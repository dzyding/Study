//
//  LocalFileModel.h
//  TingJianApp
//
//  Created by 王东文 on 2019/5/14.
//  Copyright © 2019 zhangyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalFileModel : NSObject
@property (nonatomic,copy)NSString                          *fileName;
@property (nonatomic,copy)NSString                          *filePath;
@property (nonatomic,assign,readonly)BOOL                   isDirectory;///<是否是文件夹
@end

