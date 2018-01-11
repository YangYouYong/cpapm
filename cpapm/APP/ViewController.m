//
//  ViewController.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "ViewController.h"
#import "OriginalObjectMethod.h"
#import "OriginalObjectMethod+Swizzle.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)hookCheck:(UIButton *)sender {
    
    OriginalObjectMethod *original = [OriginalObjectMethod new];
    [original checkSwizzledMethod];
}


@end
