//
//  MyView.m
//  YLUikit
//
//  Created by didi on 2018/8/2.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "MyView.h"

static NSString  *const kDTActionHandlerTapGestureKey = @"kDTActionHandlerTapGestureKey";
static NSString  *const kDTActionHandlerTapBlockKey = @"kDTActionHandlerTapBlockKey";


@implementation MyView

{
    // 设置关联对象
//    void objc_setAssociatedObject ( id object, const void *key, id value, objc_AssociationPolicy policy );
    // 获取关联对象
//    id objc_getAssociatedObject ( id object, const void *key );
    // 移除关联对象
//    void objc_removeAssociatedObjects ( id object );
    //上面方法以键值对的形式动态的向对象添加，获取或者删除关联值。其中关联政策是一组枚举常量。这些常量对应着引用关联值机制，也就是Objc内存管理的引用计数机制。
//    enum {
//        OBJC_ASSOCIATION_ASSIGN = 0,
//        OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,
//        OBJC_ASSOCIATION_COPY_NONATOMIC = 3,
//        OBJC_ASSOCIATION_RETAIN = 01401,
//        OBJC_ASSOCIATION_COPY = 01403
//    };
    
    
    //属性的操作
    // 获取属性名
//    const char * property_getName ( objc_property_t property );
    // 获取属性特性描述字符串
//    const char * property_getAttributes ( objc_property_t property );
    // 获取属性中指定的特性
//    char * property_copyAttributeValue ( objc_property_t property, const char *attributeName );
    // 获取属性的特性列表
//    objc_property_attribute_t * property_copyAttributeList ( objc_property_t property, unsigned int *outCount );
    
    
    //实例属性
    
}

- (void)testAssociate
{
    [self setTapActionWithBlock:^{
        NSLog(@"哈哈哈  添加点击事件成功");
    }];
}

- (void)setTapActionWithBlock:(void (^)(void))block{
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &kDTActionHandlerTapGestureKey);
    if (!gesture) {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        
        objc_setAssociatedObject(self, &kDTActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &kDTActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}

//手势识别对象的target和action
- (void)__handleActionForTapGesture:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        
        void(^action)(void) = objc_getAssociatedObject(self, &kDTActionHandlerTapBlockKey);
        if (action)
        {
            action();
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
