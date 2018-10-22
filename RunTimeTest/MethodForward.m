//
//  MethodForward.m
//  YLUikit
//
//  Created by didi on 2018/8/2.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "MethodForward.h"


@implementation MethodReceiver

- (void)method2
{
    NSLog(@"%@,%p",self,_cmd);
}

@end

@interface MethodForward()
{
    MethodReceiver *_receiver;
}

@end

@implementation MethodForward

- (instancetype)init
{
    if (self = [super init]) {
        
        _receiver = [MethodReceiver new];
    }
    
    return self;
}

- (void)testMsgSend
{
    NSLog(@"[self class] ==  %@",NSStringFromClass([self class]));
    
    
    NSLog(@"[Super class] ==  %@",NSStringFromClass([super class]));
}

- (void)testResolveClass
{
    [self performSelector:@selector(foo)];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSString *asel = NSStringFromSelector(sel);
    if ([asel isEqualToString:@"foo"]) {
        IMP imp = class_getMethodImplementation([self class], @selector(addMethod));
        class_addMethod([self class], sel, imp, "v@:");
    }
    return [super resolveInstanceMethod:sel];
}

- (void)addMethod
{
    NSLog(@"哈哈啊  老子是添加的方法");
}


- (void)testForwardTarget
{
    //如果无法处理消息会继续调用下面的方法，同时在这里Runtime系统实际上是给了一个替换消息接收者的机会，但是替换的对象千万不要是self，那样会进入死循环。
    [self performSelector:@selector(method2)];
}

- (void)testForwardInvocation
{
    //这一步是最后机会将消息转发给其它对象，对象会将未处理的消息相关的selector，target和参数都封装在anInvocation中。forwardInvocation:像未知消息分发中心，将未知消息转发给其它对象。注意的是forwardInvocation:方法只有在消息接收对象无法正常响应消息时才被调用。
    //    - (void)forwardInvocation:(NSInvocation *)anInvocation
        //必须重写这个方法，消息转发使用这个方法获得的信息创建NSInvocation对象。
    //    - (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
    [self performSelector:@selector(method2)];
}

//- (id)forwardingTargetForSelector:(SEL)aSelector
//{
//    NSLog(@"forwardingTargetForSelector");
//    NSString *selectorString = NSStringFromSelector(aSelector);
//
//    if ([selectorString isEqualToString:@"method2"]) {
//        return _receiver;
//    }
//    return [super forwardingTargetForSelector:aSelector];
//}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    
    if (!signature) {
        if ([MethodReceiver instancesRespondToSelector:aSelector]) {
            signature = [MethodReceiver instanceMethodSignatureForSelector:aSelector];
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"forwardInvocation");
    if ([MethodReceiver instancesRespondToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:_receiver];
    }
}




@end
