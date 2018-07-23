//
//  TouchCheckUtils.h
//  YLUikit
//
//  Created by 陈宇亮 on 2018/7/23.
//  Copyright © 2018年 陈宇亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseCoreTextData;
@class CoreTextLinkData;

@interface TouchCheckUtils : NSObject

+ (CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint )point data:(BaseCoreTextData *)data;

@end
