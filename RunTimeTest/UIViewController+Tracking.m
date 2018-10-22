//
//  UIViewController+Tracking.m
//  YLUikit
//
//  Created by 陈宇亮 on 2018/8/12.
//  Copyright © 2018年 陈宇亮. All rights reserved.
//

#import "UIViewController+Tracking.h"

@implementation UIViewController (Tracking)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(xxx_viewWillAppear:);
        
        Method originMethod = class_getInstanceMethod([self class], originalSelector);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
        
        BOOL didAddMethod = class_addMethod([self class], originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod([self class], swizzledSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        }else{
            method_exchangeImplementations(originMethod, swizzledMethod);
        }
    });
    
    
}


#pragma mark _ Method Swizzling

- (void)xxx_viewWillAppear:(BOOL )animated{
    [self xxx_viewWillAppear:animated];
    NSLog(@"viewWillAppear: %@",self);
}

@end
