//
//  BaseCoreTextView.m
//  YLUikit
//
//  Created by didi on 2018/7/20.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "BaseCoreTextView.h"
#import "TouchCheckUtils.h"


@implementation BaseCoreTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        [self addGestureRecognizer:tapGes];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if (self.data) {
        CTFrameDraw(self.data.ctFrame, context);
    }
    
    for (CoreTextImageData *imageData in self.data.imageArray) {
        UIImage *image = [UIImage imageNamed:imageData.name];
        if (image) {
            CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
        }
    }
    
}

- (void)tapGes:(UITapGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationInView:self];
    CoreTextLinkData *link = [TouchCheckUtils touchLinkInView:self atPoint:point data:self.data];
    if (link) {
        NSLog(@"hint ==== %@",link.url);
        return ;
    }
}

@end
