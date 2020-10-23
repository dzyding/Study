//
//  AliyunVideoSDKInfo.h
//  QUSDK
//
//  Created by Worthy on 2017/5/23.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
// BUILD INFO
// AliyunAlivcCommitId:ed3b3ce78
// AliyunMediaCoreCommitId:47c8b99f
// AliyunVideoSDKCommitId:f7f4fd71
// AliyunVideoSDKBuildId:3453800

#import <Foundation/Foundation.h>

@interface AliyunVideoSDKInfo : NSObject

+ (NSString *)version;

+ (NSString *)alivcCommitId;

+ (NSString *)mediaCoreCommitId;

+ (NSString *)videoSDKCommitId;

+ (NSString *)videoSDKBuildId;

+ (void)printSDKInfo;
@end
