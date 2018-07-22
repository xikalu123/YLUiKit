//
//  UIView+YLFrame.m
//  YLUikit
//
//  Created by 陈宇亮 on 2018/7/21.
//  Copyright © 2018年 陈宇亮. All rights reserved.
//

#import "UIView+YLFrame.h"

@implementation UIView (YLFrame)

- (CGFloat )x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x
{
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

- (CGFloat )y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)Y
{
    self.frame = CGRectMake(self.x, Y, self.width, self.height);
}

- (CGFloat )height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)Height
{
    self.frame = CGRectMake(self.x, self.y, self.width, Height);
}

- (CGFloat )width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)Width
{
    self.frame = CGRectMake(self.x, self.y, Width, self.height);
}

@end
