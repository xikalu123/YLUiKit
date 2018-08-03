//
//  MethodForward.h
//  YLUikit
//
//  Created by didi on 2018/8/2.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MethodReceiver : NSObject

- (void)method2;

@end


@interface MethodForward : NSObject

- (void)testMsgSend;

//动态解析方法
- (void)testResolveClass;

//重定向接受者
- (void)testForwardTarget;

//最后进行转发
- (void)testForwardInvocation;

@end
