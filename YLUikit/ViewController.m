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
    [self runtimeTest];
}

- (void)runtimeTest{
    
    MyClass *myclass = [MyClass new];
    unsigned int outCount = 0;
    Class cls = myclass.class;
    
    //类名
    NSLog(@"class name : %s",class_getName(cls));
    NSLog(@"============================================");
    
    //父类
    NSLog(@"class name : %s",class_getName(class_getSuperclass(cls)));
    NSLog(@"============================================");
    
    //是否是元累类
    NSLog(@"Myclass is %@ a meta-class",class_isMetaClass(cls)?@"" : @"not");
    NSLog(@"============================================");
    
    //获取元类
    Class meta_class = objc_getMetaClass(class_getName(cls));
    NSLog(@"%s's meta-class is %s",class_getName(cls),class_getName(meta_class));
    NSLog(@"============================================");
    
    //变量实例大小
    NSLog(@"instance size : %zu",class_getInstanceSize(cls));
    NSLog(@"============================================");

    
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
