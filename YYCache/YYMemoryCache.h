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

#pragma mark - Limit

#pragma mark - Access Methods

- (nullable id)objectForKey:(id)key;

- (void)setObject:(nullable id)object forKey:(id)key;

- (void)removeObjectForKey:(id)key;

- (void)removeAllObjects;

#pragma mark - Trim

- (void)trimToCount:(NSUInteger)count;

- (void)trimToCost:(NSUInteger)cost;

- (void)trimToAge:(NSTimeInterval)age;

@end
