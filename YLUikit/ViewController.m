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

@interface ViewController ()

@property (nonatomic,strong) BaseCoreTextView *displayView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    runTimeUnit *runUnit = [runTimeUnit new];
//    [runUnit runTest];
//    [runUnit creatClassAndObject];
    [runUnit ivarAndProperty];
    
}

- (void)addMethod
{
    NSLog(@"run sub method 1");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
