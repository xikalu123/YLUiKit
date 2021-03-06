//
//  ViewController.m
//  YLUikit
//
//  Created by 陈宇亮 on 2018/7/12.
//  Copyright © 2018年 陈宇亮. All rights reserved.
//

#import "ViewController.h"
#import "BaseCoreTextView.h"
#import "BaseFrameParser.h"
#import "runTimeUnit.h"
#import "MethodForward.h"
#import "UIViewController+Tracking.h"
#import "RACViewController.h"


@interface ViewController ()

@property (nonatomic,strong) BaseCoreTextView *displayView;
@property (nonatomic,strong) UIButton *nextBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    _displayView = [[BaseCoreTextView alloc] initWithFrame:CGRectMake(20, 20, 250, 200)];
//    _displayView.backgroundColor = [UIColor lightGrayColor];
//
//    BaseFrameParserConfig *config = [[BaseFrameParserConfig alloc] init];
//    config.textColor = [UIColor blackColor];
//    config.width = _displayView.width;
//
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"];
//
//    BaseCoreTextData *data = [BaseFrameParser parseTemplateFile:path config:config];
//
//    _displayView.data = data;
//    _displayView.height = data.height;
//    [self.view addSubview:_displayView];
    // Do any additional setup after loading the view, typically from a nib.
    
    //runtime test
    
//    runTimeUnit *runUnit = [runTimeUnit new];
//    [runUnit runTest];
//    [runUnit creatClassAndObject];
//    [runUnit ivarAndProperty];
    
//    MyView *associateView = [[MyView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
//    associateView.backgroundColor = [UIColor redColor];
//    [associateView testAssociate];
//    [self.view addSubview:associateView];
    
    MethodForward *method = [[MethodForward alloc] init];
//    [method testForwardTarget];
    [method testResolveClass];
    
    NSNumber *ss = @(-1000);
    NSLog(@"sdkks===%lu",(unsigned long)ss.unsignedIntegerValue);
    
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn.frame = CGRectMake(20, 20 + self.navigationController.navigationBar.height, 100, 100);
    [_nextBtn setTitle:@"rac学习" forState:UIControlStateNormal];
    _nextBtn.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:_nextBtn];
    [_nextBtn addTarget:self action:@selector(jumpRACPage) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)addMethod
{
    NSLog(@"run sub method 1");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)jumpRACPage
{
    RACViewController *racVC = [[RACViewController alloc] init];
    [self.navigationController pushViewController:racVC animated:YES];
}


@end
