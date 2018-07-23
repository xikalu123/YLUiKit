//
//  TouchCheckUtils.m
//  YLUikit
//
//  Created by 陈宇亮 on 2018/7/23.
//  Copyright © 2018年 陈宇亮. All rights reserved.
//

#import "TouchCheckUtils.h"
#import "BaseCoreTextData.h"

@implementation TouchCheckUtils

+ (CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint )point data:(BaseCoreTextData *)data
{
    CTFrameRef textFrame = data.ctFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return  nil;
    }
    CFIndex count = CFArrayGetCount(lines);
    CoreTextLinkData *foundLink = nil;
    
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, view.height);
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
    
    for (int i  = 0; i< count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        //获取每一行的CGRect信息
        CGRect lineCoreRect = [self getLineBounds:line point:linePoint];
        CGRect lineUIKitRect = CGRectApplyAffineTransform(lineCoreRect, transform);
        
        if (CGRectContainsPoint(lineUIKitRect, point)) {
            //将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x - CGRectGetMinX(lineUIKitRect), point.y - CGRectGetMinY(lineUIKitRect));
            
            //获得当前点击坐标对应的字符串偏移
            CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
            foundLink = [self linkAtIndex:idx linkArray:data.linkArray];
        }
        
    }
    return foundLink;
}

+ (CGRect )getLineBounds:(CTLineRef )line point:(CGPoint )point{
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

+ (CoreTextLinkData *)linkAtIndex:(CFIndex )i linkArray:(NSArray *)linkArray{
    CoreTextLinkData *link = nil;
    for (CoreTextLinkData *data in linkArray) {
        if (NSLocationInRange(i, data.range)) {
            link = data;
            break;
        }
    }
    return link;
}

@end
