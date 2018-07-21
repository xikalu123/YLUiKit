//
//  BaseFrameParser.h
//  YLUikit
//
//  Created by didi on 2018/7/20.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseFrameParserConfig.h"
#import "BaseCoreTextData.h"

@interface BaseFrameParser : NSObject

+ (BaseCoreTextData *)parseContent:(NSString *)content config:(BaseFrameParserConfig *)config;

@end
