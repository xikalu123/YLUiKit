//
//  BaseFrameParser.m
//  YLUikit
//
//  Created by didi on 2018/7/20.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "BaseFrameParser.h"

@implementation BaseFrameParser

+ (NSMutableDictionary *)attributesWithConfig:(BaseFrameParserConfig *)config{
    CGFloat fontSize = config.fontSize;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"AriaMT", fontSize, NULL);
    CGFloat lineSpace = config.lineSpace;
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&lineSpace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&lineSpace}
        
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    UIColor *textColor = config.textColor;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    return dict;
}

+ (CTFrameRef )creatFrameWithFrameSetter:(CTFramesetterRef)framesetter
                                  config:(BaseFrameParserConfig *)config
                                  height:(CGFloat)height
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return  frame;
}

#pragma mark -- return data
+ (BaseCoreTextData *)parseContent:(NSAttributedString *)content config:(BaseFrameParserConfig *)config
{
    NSAttributedString *contentString = content;
    
    //创建framerSetter
    CTFramesetterRef framerSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentString);
    
    //获取要绘制区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framerSetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    //生成CTFrameRef
    CTFrameRef frame = [self creatFrameWithFrameSetter:framerSetter config:config height:textHeight];
    
    BaseCoreTextData *data = [[BaseCoreTextData alloc] init];
    data.ctFrame = frame;
    data.height = textHeight;

    
    CFRelease(frame);
    CFRelease(framerSetter);
    return data;
}

+ (BaseCoreTextData *)parseTemplateFile:(NSString *)path config:(BaseFrameParserConfig *)config{
    NSMutableArray *imageArray = [NSMutableArray new];
    NSAttributedString *content = [self loadTemplateFile:path config:config imageArray:imageArray];
    BaseCoreTextData *data =  [self parseContent:content config:config];
    data.imageArray = imageArray;
    return data;
}

+ (NSAttributedString *)loadTemplateFile:(NSString *)path
                                  config:(BaseFrameParserConfig *)config
                              imageArray:(NSMutableArray *)imageArray
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    
    if (data) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in array) {
                NSString *type = dict[@"type"];
                if ([type isEqualToString:@"txt"]) {
                    NSAttributedString *att = [self parseAttributedContentFromNSDictionary:dict config:config];
                    [result appendAttributedString:att];
                }
                else if ([type isEqualToString:@"img"])
                {
                    CoreTextImageData *imageData = [CoreTextImageData new];
                    imageData.name = dict[@"name"];
                    imageData.position = [result length];
                    [imageArray addObject:imageData];
                    
                    //创建空白占位符并且设置它的CTRunDelegate信息
                    NSAttributedString *as = [self parseImageDataFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                }
            }
        }
    }
    
    return result;
}

+ (NSAttributedString *)parseAttributedContentFromNSDictionary:(NSDictionary *)dict
                                                        config:(BaseFrameParserConfig *)config
{
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    
    UIColor *color = [self colorFromTemplate:dict[@"color"]];
    if (color) {
        attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    }
    
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize > 0) {
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    
    NSString *content = dict[@"content"];
    return [[NSAttributedString alloc] initWithString:content attributes:attributes];
}

+ (UIColor *)colorFromTemplate:(NSString *)name {
    if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    } else if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    } else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    } else {
        return nil;
    }
}

#pragma 增加图片混排,设置RunDelegate

static CGFloat ascentCallback(void *ref){
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void *ref){
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"width"] floatValue];
}

+ (NSAttributedString *)parseImageDataFromNSDictionary:(NSDictionary *)dict
                                                config: (BaseFrameParserConfig *)config
{
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)dict);
    
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSDictionary * attributes = [self attributesWithConfig:config];
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content
                                                                               attributes:attributes];
    
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    
    return space;
    
}

@end
