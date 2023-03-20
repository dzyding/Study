//
//  LocalFileModel.m
//  TingJianApp
//
//  Created by 王东文 on 2019/5/14.
//  Copyright © 2019 zhangyu. All rights reserved.
//

#import "LocalFileModel.h"
@interface LocalFileModel ()

@end

@implementation LocalFileModel







- (BOOL)checkIsDirectory:(NSString *)filePath
{
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    return isDirectory;
}

- (BOOL)isDirectory
{
   return [self checkIsDirectory:self.filePath];
}
@end
