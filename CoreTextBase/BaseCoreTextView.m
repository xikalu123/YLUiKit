//
//  BaseCoreTextView.m
//  YLUikit
//
//  Created by didi on 2018/7/20.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "BaseCoreTextView.h"
#import "CoreText/CoreText.h"

@implementation BaseCoreTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, self.bounds);
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"Hello World 数据库等级埃里克森建档立卡时间到了框架流口水的记录反馈时间了开发技术的李开复开了房间数量的看法就凉快圣诞节福利as建档立卡就是离开多久了开始就哭了辣椒水大立科技阿拉山口多久爱离开时间来看拉卡技术的框架阿拉山口建档立卡时间考虑到"];
    CTFramesetterRef framerSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef frame = CTFramesetterCreateFrame(framerSetter, CFRangeMake(0, attString.length), path, NULL);
    
    CTFrameDraw(frame, context);
    
    CFRelease(frame);
    CFRelease(framerSetter);
    CFRelease(path);
}

@end
