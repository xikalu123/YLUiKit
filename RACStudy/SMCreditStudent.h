//
//  SMCreditStudent.h
//  YLUikit
//
//  Created by didi on 2018/10/9.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SubscribeNextActionBlock)(NSUInteger credit);

@interface SMCreditStudent : NSObject

+ (SMCreditStudent *)create;

- (SMCreditStudent *)sendNext:(NSUInteger)credit;
- (SMCreditStudent *)subscribeNext:(SubscribeNextActionBlock)block;

@end

NS_ASSUME_NONNULL_END
