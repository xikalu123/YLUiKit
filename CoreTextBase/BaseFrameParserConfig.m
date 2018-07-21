//
//  BaseFrameParserConfig.m
//  YLUikit
//
//  Created by didi on 2018/7/20.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "BaseFrameParserConfig.h"

@implementation BaseFrameParserConfig

- (instancetype)init
{
    if (self = [super init]) {
        _width = 200.f;
        _fontSize = 16.0f;
        _lineSpace = 8.0f;
        _textColor = [UIColor redColor];
    }
    return self;
}

@end
