//
//  TraceViewController.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "TraceViewController.h"
#import "ANT.h"

@interface TraceViewController ()<ANTDelegate>
@property (nonatomic, strong) ANT *ant;
@property (nonatomic, strong) UIButton *traceTest;
@end

@implementation TraceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)ANTTask:(UIButton *)sender {
    self.ant = [ANT new];
    self.ant.delegate = self;
    [self.ant openWithThreadhold:0.35];
    [self blockFoo];
    [self globalBlockFoo];
    NSLog(@"invoke");
}


-(void)blockFoo {
    NSString *s = @"1";
    
    for (int i = 0; i <999; i++) {
        for (int j =0 ; j < 999; j ++) {
            s = [s stringByAppendingString:@"1"];
        }
    }
}

-(void)globalBlockFoo {
    __block NSInteger pp = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <999; i++) {
            for (int j =0 ; j < 999; j ++) {
                pp += 1;
            }
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)ANT:(ANT *)ant catchWithThreadHold:(double)threadHold mainThreadBacktrace:(NSString *)mainBacktrace allThreadBacktrace:(NSString *)allBacktrace {
    NSLog(@"----mainTrace----");
    NSLog(@"%@",mainBacktrace);
    NSLog(@"----allTrace----");
    NSLog(@"%@",allBacktrace);
}

@end
