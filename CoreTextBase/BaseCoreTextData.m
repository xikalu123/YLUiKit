//
//  BaseCoreTextData.m
//  YLUikit
//
//  Created by didi on 2018/7/20.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "BaseCoreTextData.h"

@implementation CoreTextImageData


@end

@implementation BaseCoreTextData

-(void)setCtFrame:(CTFrameRef)ctFrame
{
    if (_ctFrame != ctFrame) {
        if (_ctFrame) {
            CFRelease(_ctFrame);
        }
        CFRetain(ctFrame);
        _ctFrame = ctFrame;
    }
}

- (void)dealloc
{
    if (_ctFrame) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}

- (void)setImageArray:(NSArray<__kindof CoreTextImageData *> *)imageArray
{
    _imageArray = imageArray;
    [self fillImagePosition];
    
}

- (void)fillImagePosition{
    if (self.imageArray.count == 0) {
        return ;
    }
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);  //获取CTFrmae的所有Line
    int lineCount = lines.count;
    CGPoint lineOrigins[lineCount];
    
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins); //获取每个Line的origin坐标
    int imgIndex = 0;
    CoreTextImageData *imageData = self.imageArray[0];
    
    for (int i = 0 ; i< lineCount; i++) {
        if (imageData == nil) {
            break ;
        }
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);//便利每个LIne的每个Run
        
        for (id runObj in runObjArray) {
            CTRunRef run = (__bridge CTRunRef)runObj; //获取Run
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run); //获取Run的Attributes
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName]; //获取Run的CTRunDelegateRef
            if (delegate == nil) {
                continue ;
            }
            NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate); //获取一个run delegate的refcon的值,获取到的对象里面存粗了这个run的宽度和高度.
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue ;
            }
            
            CGRect runBounds; //runBounds在CoreText中的坐标位移.
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //获取run 的 bound
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); //获得run在该line行之中的x偏移量.
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;    //到目前为止获得了run在CTFrame中的坐标
            
            CGPathRef pathRef = CTFrameGetPath(self.ctFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);   //获取run在绘制view中的坐标.
            
            imageData.imagePosition = delegateBounds;
            
            imgIndex ++;
            if (imgIndex == self.imageArray.count) {
                imageData = nil;
                break ;
            }
            else{
                imageData = self.imageArray[imgIndex];
            }
        }
    }
    
}
@end
