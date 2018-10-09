//
//  RACViewController.m
//  YLUikit
//
//  Created by didi on 2018/10/9.
//  Copyright © 2018 陈宇亮. All rights reserved.
//

#import "RACViewController.h"
#import "SMStudent.h"

@interface RACViewController ()
@property (nonatomic, strong) SMStudent *student;
@property (nonatomic, strong) UIButton *testButton;
@property (nonatomic, strong) UILabel *currentCreditLabel;
@property (nonatomic, strong) UILabel *isSatisfyLabel;

@end

@implementation RACViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self testButton];
    [self currentCreditLabel];
    [self isSatisfyLabel];
    // Do any additional setup after loading the view.
    
    self.student = [[[[[SMStudent create]
                       name:@"chenyuliang"]
                      gender:SMStudentGenderMale]
                     studentNumber:345]
                    fillterIsAsatisfyCredit:^BOOL(NSUInteger credit) {
                        if (credit >= 70) {
                            self.isSatisfyLabel.text = @"合格";
                            self.isSatisfyLabel.textColor = [UIColor redColor];
                            return YES;
                        } else {
                            self.isSatisfyLabel.text = @"不合格";
                            return NO;
                        }
                    }];
    
    [self.student.creditSubject subscribeNext:^(NSUInteger credit) {
        self.currentCreditLabel.text = [NSString stringWithFormat:@"%lu",credit];
        if (credit < 30) {
            self.currentCreditLabel.textColor = [UIColor lightGrayColor];
        } else if(credit < 70) {
            self.currentCreditLabel.textColor = [UIColor purpleColor];
        } else {
            self.currentCreditLabel.textColor = [UIColor redColor];
        }
    }];
    
    [self.student.creditSubject subscribeNext:^(NSUInteger credit) {
        NSLog(@"第二个订阅的credit处理积分%lu",credit);
        if (!(credit > 0)) {
            self.currentCreditLabel.text = @"0";
            self.isSatisfyLabel.text = @"未设置";
        }
    }];
}


- (void)addFivePoint{
    [self.student sendCredit:^NSUInteger(NSUInteger credit) {
        credit += 5;
        NSLog(@"current credit %lu",credit);
        [self.student.creditSubject sendNext:credit];
        return credit;
    }];
}


#pragma mark - setter and Getter
- (UIButton *)testButton {
    if (!_testButton) {
        _testButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_testButton setTitle:@"增加5个积分" forState:UIControlStateNormal];
        [_testButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _testButton.backgroundColor = [UIColor brownColor];
        _testButton.titleLabel.font = [UIFont systemFontOfSize:10];
        _testButton.frame = CGRectMake(20, 100, 70, 30);
        [_testButton addTarget:self action:@selector(addFivePoint) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_testButton];
    }
    return _testButton;
}
- (UILabel *)currentCreditLabel {
    if (!_currentCreditLabel) {
        _currentCreditLabel = [[UILabel alloc] init];
        _currentCreditLabel.textAlignment = NSTextAlignmentCenter;
        _currentCreditLabel.textColor = [UIColor lightGrayColor];
        _currentCreditLabel.backgroundColor = [UIColor brownColor];
        _currentCreditLabel.font = [UIFont systemFontOfSize:10];
        _currentCreditLabel.frame = CGRectMake(100, 100, 70, 40);
        [self.view addSubview:_currentCreditLabel];
    }
    return _currentCreditLabel;
}
- (UILabel *)isSatisfyLabel {
    if (!_isSatisfyLabel) {
        _isSatisfyLabel = [[UILabel alloc] init];
        _isSatisfyLabel.textAlignment = NSTextAlignmentCenter;
        _isSatisfyLabel.textColor = [UIColor lightGrayColor];
        _isSatisfyLabel.backgroundColor = [UIColor brownColor];
        _isSatisfyLabel.font = [UIFont systemFontOfSize:10];
        _isSatisfyLabel.frame = CGRectMake(100, 160, 70, 40);
        [self.view addSubview:_isSatisfyLabel];
        
    }
    return _isSatisfyLabel;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
