//
//  BaseCoreTextData.h
//  YLUikit
//
//  Created by didi on 2018/7/20.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreTextImageData : NSObject

@property (strong, nonatomic) NSString * name;
@property (nonatomic) int position;

// 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
@property (nonatomic) CGRect imagePosition;

@end

@interface BaseCoreTextData : NSObject

@property (assign,nonatomic) CTFrameRef ctFrame;
@property (assign) CGFloat height;

@property (nonatomic, strong) NSArray<__kindof CoreTextImageData *> *imageArray;

@end
