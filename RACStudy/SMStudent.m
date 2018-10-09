//
//  SMStudent.m
//  YLUikit
//
//  Created by didi on 2018/10/9.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "SMStudent.h"

@interface SMStudent()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) SMStudentGender gender;
@property (nonatomic, assign) NSUInteger number;
@property (nonatomic, assign) NSUInteger credit;
@property (nonatomic, strong) SatisfyActionBlock satisfyBlock;

@end

@implementation SMStudent

+ (SMStudent *)create{
    SMStudent *student = [[self alloc] init];
    return student;
}

- (SMStudent *)name:(NSString *)name{
    self.name = name;
    return self;
}

-(SMStudent *)gender:(SMStudentGender)gender{
    self.gender = gender;
    return self;
}

- (SMStudent *)studentNumber:(NSUInteger)number{
    self.number = number;
    return self;
}

- (SMStudent *)sendCredit:(NSUInteger (^)(NSUInteger))updateCreditBlock{
    if (updateCreditBlock) {
        self.credit = updateCreditBlock(self.credit);
        if (self.satisfyBlock) {
            self.isSatisfyCredit = self.satisfyBlock(self.credit);
            if (self.isSatisfyCredit) {
                NSLog(@"YES");
            }else{
                NSLog(@"NO");
            }
        }
    }
    return self;
}

- (SMStudent *)fillterIsAsatisfyCredit:(SatisfyActionBlock)satisfyBlock{
    if (satisfyBlock) {
        self.satisfyBlock = satisfyBlock;
        self.isSatisfyCredit = self.satisfyBlock(self.credit);
    }
    return self;
}

- (SMCreditStudent *)creditSubject{
    if (!_creditSubject) {
        _creditSubject = [SMCreditStudent create];
    }
    return _creditSubject;
}


@end
