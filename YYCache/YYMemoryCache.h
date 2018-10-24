//
//  YYMemoryCache.h
//  YLUikit
//
//  Created by 陈宇亮 on 2018/10/8.
//  Copyright © 2018年 陈宇亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYMemoryCache : NSObject

#pragma mark - Attribute

@property (nullable,copy) NSString *name;

@property (readonly) NSUInteger totalCount;

@property (readonly) NSUInteger totalCost;

@property NSUInteger countLimit;

@property NSUInteger costLimit;

@property NSTimeInterval ageLimit;

@property NSTimeInterval autoTrimInterval;

@property BOOL shouldRemoveAllObjectsOnMemoryWarning;

@property BOOL shouldRemoveAllObjectsWhenEnteringBackground;

@property BOOL releaseAsynchronously;

@property BOOL releaseOnMainThread;

@property (nonatomic, copy) void (^didReciveMemoryWarningBlock)(YYMemoryCache *cache);

@property (nonatomic, copy) void (^didEnterBackgroundBlock)(YYMemoryCache *cache);

#pragma mark - Limit

#pragma mark - Access Methods

- (BOOL)containsObjectForKey:(id)key;

- (nullable id)objectForKey:(id)key;

- (void)setObject:(nullable id)object forKey:(id)key;

- (void)setObject:(nullable id)object forKey:(id)key withCost:(NSUInteger)cost;

- (void)removeObjectForKey:(id)key;

- (void)removeAllObjects;

#pragma mark - Trim

- (void)trimToCount:(NSUInteger)count;

- (void)trimToCost:(NSUInteger)cost;

- (void)trimToAge:(NSTimeInterval)age;

@end
