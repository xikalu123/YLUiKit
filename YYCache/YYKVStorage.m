//
//  YYKVStorage.m
//  YLUikit
//
//  Created by didi on 2018/10/24.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "YYKVStorage.h"

#if __has_include(<sqlite3.h>)
#import <sqlite3.h>
#else
#import "sqlite3.h"
#endif


static const int kPathLengthMax = PATH_MAX - 64;

@implementation YYKVStorage
{
    
}


#pragma mark -- public

- (instancetype)initWithPath:(NSString *)path type:(YYKVStorgeType)type
{
    if (path.length == 0 || path.length > kPathLengthMax ) {
        NSLog(@"YYKVStorage init error: invalid path: [%@].", path);
        return nil;
    }
    if (type > YYKVStorgeTypeMixed) {
        NSLog(@"YYKVStorage init error: invalid path: [%lu].", (unsigned long)type);
        return nil;
    }
    
    self = [super init];
    
}


@end
