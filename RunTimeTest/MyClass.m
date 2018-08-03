//
//  MyClass.m
//  YLUikit
//
//  Created by 陈宇亮 on 2018/7/30.
//  Copyright © 2018年 陈宇亮. All rights reserved.
//

#import "MyClass.h"

@interface MyClass() <NSCopying>
{
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

- (void)speak
{
    unsigned int numberofIvars = 0;
    Ivar *ivars = class_copyIvarList([self class], &numberofIvars);
    for (const Ivar *p = ivars; p< ivars + numberofIvars; p++) {
        Ivar const ivar = *p;
        ptrdiff_t offset = ivar_getOffset(ivar);
        const char *name = ivar_getName(ivar);
        NSLog(@"Sark ivar name = %s, offset = %td",name,offset);
    }
    NSLog(@"my name is %p", &_string);
    NSLog(@"my name is %@", *(&_string));
    
}

- (void)method2
{
    
}

- (void)method3withArg1:(NSInteger)arg1 arg2:(NSString *)arg2
{
    NSLog(@"arg1 : %ld , arg2 : %@",arg1,arg2);
}

@end

@interface Test()

@end

@implementation Test

- (instancetype)init
{
    if (self = [super init]) {
        NSLog(@"Test instance = %@", self);
        void *self2 = (__bridge void *)self ;
        NSLog(@"Test instance pointer = %p", &self2);
        id cls = [MyClass alloc];
        NSLog(@"Class instance address = %p", cls);
        void *obj = (__bridge void *)(cls);
         NSLog(@"Void *obj = %@", obj);
        [(__bridge id)obj speak];
    }
    return self;
}

@end

