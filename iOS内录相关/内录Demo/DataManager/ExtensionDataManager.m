//
//  ExtensionDataManager.m
//  aaa
//
//  Created by Dzy on 2023/1/31.
//  Copyright © 2023 EkiSong. All rights reserved.
//

#import "ExtensionDataManager.h"

@interface ExtensionDataManager()

/// 共享的 path
@property (nonatomic, strong)NSString *sharePath;
/// 本地的 path
@property (nonatomic, strong)NSString *localPath;
@property (nonatomic, strong)NSFileHandle *writeHandle;
@property (nonatomic, strong)NSFileHandle *readHandle;
@property (nonatomic, strong)dispatch_queue_t writeQueue;

@property (nonatomic, assign)BOOL stopRead;

@end

@implementation ExtensionDataManager

- (void)startWrite {
    self.writeQueue = dispatch_queue_create("ExtensionDataManagerWriteQueue", DISPATCH_QUEUE_SERIAL);
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:self.sharePath]) {
        [fileMgr removeItemAtPath:self.sharePath error:nil];
    }
    // 先创建文件
    [fileMgr createFileAtPath:self.sharePath contents:nil attributes:nil];
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:self.sharePath];
}

- (void)writeData:(NSData *)data {
    if (self.writeHandle == nil) {return;}
    dispatch_sync(self.writeQueue, ^{
        NSError *error;
//        unsigned long long offset = 0;
//        [self.handle seekToEndReturningOffset:&offset error:&error];
//        if (error == nil) {
//            NSLog(@"seekToEndSuccess");
//        }else {
//            NSLog(@"seekToEndFail - %@", error);
//        }
//        error = nil;
        [self.writeHandle writeData:data error:&error];
        if (error == nil) {
            NSLog(@"writeSuccess, dataLength - %lu", data.length);
        }else {
            NSLog(@"writeFail - %@", error);
        }
    });
}

- (void)endWrite {
    NSError *error;
    [self.writeHandle closeAndReturnError:&error];
    if (error == nil) {
        NSLog(@"closeFileSuccess");
    }else {
        NSLog(@"closeFileFail - %@", error);
    }
    self.writeHandle = nil;
}

- (void)startLoad {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.localPath]) {
        NSError *error;
        [fileManager removeItemAtPath:self.localPath error:&error];
        if (error != nil) {
            NSLog(@"delete localFile Fail - %@", error);
            error = nil;
            return;
        }
    }
    [fileManager createFileAtPath:self.localPath contents:nil attributes:nil];
    // 读共享空间的，写入到本地
    if (self.readHandle == nil) {
        self.readHandle = [NSFileHandle fileHandleForReadingAtPath:self.sharePath];
    }
    if (self.writeHandle == nil) {
        self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:self.localPath];
    }
}

- (void)loadWhenWrite {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.sharePath]) {return;}
    if (self.readHandle == nil || self.writeHandle == nil) {return;}
        
    NSLog(@"offsetInFile - %llu", self.readHandle.offsetInFile);
    NSError *error = nil;
    NSData *data = [self.readHandle readDataToEndOfFileAndReturnError:&error];
    if (error != nil) {
        NSLog(@"readDataFail - %@", error);
    }else {
        NSLog(@"readDataSuccess Length - %lu", data.length);
        [self.writeHandle writeData:data error:&error];
        if (error != nil) {
            NSLog(@"writeDataFail - %@", error);
        }else {
            NSLog(@"writeDataSuccess");
        }
    }
    if (!self.stopRead) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadWhenWrite];
        });
    }else {
        [self.readHandle closeFile];
        [self.writeHandle closeFile];
        self.readHandle = nil;
        self.writeHandle = nil;
    }
}

- (void)stopLoad {
    self.stopRead = true;
}

- (NSString *)sharePath {
    if (!_sharePath) {
        _sharePath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.GcadShare"] path] stringByAppendingPathComponent:@"groupAudio"];
    }
    return _sharePath;
}

- (NSString *)localPath {
    if (!_localPath) {
        _localPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.pcm"];
    }
    return _localPath;
}

@end
