//
//  SMStudent.h
//  YLUikit
//
//  Created by didi on 2018/10/9.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMCreditStudent.h"

typedef NS_ENUM(NSUInteger, SMStudentGender){
    SMStudentGenderMale,
    SMStudentGenderFemale
};

typedef BOOL(^SatisfyActionBlock)(NSUInteger credit);

NS_ASSUME_NONNULL_BEGIN

@interface SMStudent : NSObject

@property (nonatomic, strong) SMCreditStudent *creditSubject;

@property (nonatomic, assign) BOOL isSatisfyCredit;

+ (SMStudent *)create;

- (SMStudent *)name:(NSString *)name;

- (SMStudent *)gender:(SMStudentGender)gender;

- (SMStudent *)studentNumber:(NSUInteger)number;

//积分相关
- (SMStudent *)sendCredit:(NSUInteger (^)(NSUInteger credit))updateCreditBlock;
- (SMStudent *)fillterIsAsatisfyCredit:(SatisfyActionBlock)satisfyBlock;

@end

NS_ASSUME_NONNULL_END
