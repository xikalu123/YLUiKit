//
//  YYKVStorage.h
//  YLUikit
//
//  Created by didi on 2018/10/24.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YYKVStorageItem : NSObject



@end

typedef NS_ENUM(NSUInteger, YYKVStorgeType){
    YYKVStorgeTypeFile = 0,
    YYKVStorgeTypeSQLite = 1,
    YYKVStorgeTypeMixed = 2,
};

@interface YYKVStorage : NSObject

@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) YYKVStorgeType type;
@property (nonatomic) BOOL errorLogsEnabled;

#pragma mark - init

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (nullable instancetype)initWithPath:(NSString *)path type:(YYKVStorgeType )type NS_DESIGNATED_INITIALIZER;

- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
               fileName:(nullable NSString *)fileName
           extendedData:(nullable NSData *)extendedData;


- (BOOL)removeItemForKey:(NSString *)key;

- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys;

- (BOOL)removeAllItems;

- (nullable YYKVStorageItem *)getItemForKey:(NSString *)key;

- (nullable YYKVStorageItem *)getItemInfoForKey:(NSString *)key;

- (nullable NSData *)getItemValueForKey:(NSString *)key;

- (nullable NSArray<YYKVStorageItem *> *)getItemForKeys:(NSArray<NSString *> *)keys;

- (nullable NSArray<YYKVStorageItem *> *)getItemInfoForKeys:(NSArray<NSString *> *)keys;

- (BOOL)itemExistsForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
