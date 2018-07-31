//
//  MyClass.h
//  YLUikit
//
//  Created by 陈宇亮 on 2018/7/30.
//  Copyright © 2018年 陈宇亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyClass : NSObject <NSCopying,NSCoding>

@property (nonatomic,copy) NSArray *array;
@property (nonatomic,copy) NSString *string;

- (void)method1;
- (void)method2;
+ (void)classMewthod1;

@end
