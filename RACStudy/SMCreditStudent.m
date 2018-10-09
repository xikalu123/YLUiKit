//
//  SMCreditStudent.m
//  YLUikit
//
//  Created by didi on 2018/10/9.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "SMCreditStudent.h"

@interface SMCreditStudent()

@property (nonatomic, assign) NSUInteger credit;
@property (nonatomic, strong) SubscribeNextActionBlock subscribeNextBlock;
@property (nonatomic, strong) NSMutableArray *blockArray;


@end

@implementation SMCreditStudent

+ (SMCreditStudent *)create{
    SMCreditStudent *subject = [[self alloc] init];
    return subject;
}

- (SMCreditStudent *)sendNext:(NSUInteger)credit{
    self.credit = credit;
    if (self.blockArray.count) {
        for (SubscribeNextActionBlock block in self.blockArray) {
            block(self.credit);
        }
    }
    return self;
}

- (SMCreditStudent *)subscribeNext:(SubscribeNextActionBlock)block{
    if (block) {
        block(self.credit);
    }
    [self.blockArray addObject:block];
    return self;
}

- (NSMutableArray *)blockArray{
    if (!_blockArray) {
        _blockArray = [NSMutableArray array];
    }
    return _blockArray;
}

@end
