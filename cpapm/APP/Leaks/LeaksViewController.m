//
//  LeaksViewController.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "LeaksViewController.h"

@interface LeaksViewController ()

@property (nonatomic, strong) LeaksView *leaksView;

@end

@implementation LeaksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leaksView = [LeaksView new];
    [self.view addSubview:self.leaksView];
    self.leaksView.backgroundColor = [UIColor brownColor];
    self.leaksView.delegate = self;
}

-(void)dealloc {
    NSLog(@"----dealloc--%@", [self class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation LeaksView

@end
