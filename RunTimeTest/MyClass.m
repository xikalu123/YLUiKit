//
//  MyClass.m
//  YLUikit
//
//  Created by 陈宇亮 on 2018/7/30.
//  Copyright © 2018年 陈宇亮. All rights reserved.
//

#import "MyClass.h"

@interface MyClass(){
    NSInteger _instance1;
    NSString *_instance2;
}

@property (nonatomic, assign) NSUInteger integer;

- (void)method3withArg1:(NSInteger)arg1 arg2:(NSString *)arg2;
@end

@implementation MyClass

+ (void)classMewthod1
{
    
}

 - (void)method1
{
    NSLog(@"call method method1");
}

- (void)method2
{
    
}

- (void)method3withArg1:(NSInteger)arg1 arg2:(NSString *)arg2
{
    NSLog(@"arg1 : %ld , arg2 : %@",arg1,arg2);
}

@end
