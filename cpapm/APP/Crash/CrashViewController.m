//
//  CrashViewController.m
//  cpapm
//
//  Created by yangyouyong on 2018/1/3.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import "CrashViewController.h"
#import "EVGView.h"

typedef struct CrashSize
{
    int a;
    int b;
}CrashSize;

@interface CrashViewController ()

@end

@implementation CrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)stackCrash:(UIButton *)sender {
    NSArray *arr = @[@1];
    
    NSNumber *a = arr[2];
}

- (IBAction)signalSEVGCrash:(UIButton *)sender {
    EVGView *view = [[EVGView alloc] init];
}

- (IBAction)signalBRTCrash:(UIButton *)sender {
    CrashSize *size = {2,3};
    free(size); //导致SIGABRT的错误，因为内存中根本就没有这个空间，哪来的free，就在栈中的对象而已
    size->a = 10;
}

- (IBAction)signalBUSCrash:(UIButton *)sender {
    //SIGBUS，内存地址未对齐
    //EXC_BAD_ACCESS(code=1,address=0x1000dba58)
//    char *a = "123456789";
//    *a = 'H';
    NSString *a = @"234";
    a = @[@"1"];
}

@end
