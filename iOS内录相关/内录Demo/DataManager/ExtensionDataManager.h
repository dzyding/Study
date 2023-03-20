//
//  ExtensionDataManager.h
//  aaa
//
//  Created by Dzy on 2023/1/31.
//  Copyright © 2023 EkiSong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExtensionDataManager : NSObject

- (void)startWrite;

- (void)writeData:(NSData *)data;

- (void)endWrite;

- (void)startLoad;

- (void)loadWhenWrite;

- (void)stopLoad;

@end

NS_ASSUME_NONNULL_END
