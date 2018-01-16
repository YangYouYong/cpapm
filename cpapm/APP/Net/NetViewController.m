//
//  NetViewController.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "NetViewController.h"
#import "NetAnt.h"
#import "CFNet.h"

@interface NetViewController ()<NetAntDelegate>

@property (nonatomic, strong) CFNet *cf_net;
@property (nonatomic, strong) UIImageView *preResponseImageView;

@end

@implementation NetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)NetTask:(UIButton *)sender {
    [NetAnt addObserver:self];
    [self btSessionRequestAction];
}
- (IBAction)CFNetTask:(UIButton *)sender {
    if (!self.cf_net) {
        self.cf_net = [CFNet new];
    }
    __weak typeof(self) weakSelf = self;
    [self.cf_net testCFGetClientCompletion:^(NSData *responseData) {
        //        weakSelf.firstImageView.image = [[UIImage alloc] initWithData:responseData];
        [weakSelf appendImage:responseData];
    }];
}
- (IBAction)CFNetTask2:(id)sender {
    if (!self.cf_net) {
        self.cf_net = [CFNet new];
    }
    __weak typeof(self) weakSelf = self;
    [self.cf_net testCFGetClient2Completion:^(NSData *responseData) {
        //        weakSelf.secondImageView.image = [[UIImage alloc] initWithData:responseData];
        [weakSelf appendImage:responseData];
    }];
}
- (IBAction)CFNetBenchmark:(id)sender {
    
    for (int i = 0; i < 10; i ++) {
        if (i % 3 == 0) {
            [self CFNetTask:nil];
        }
        [self CFNetTask2:nil];
    }
}

- (void)btSessionRequestAction{
    
    NSURL *url = [NSURL URLWithString:@"http://www.example.com"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //    config.protocolClasses=@[[NEHTTPEye class]];//在NEURLSessionConfiguration里面注册了，所以不用在这里重复注册了
    
    NSURLSession *urlsession = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *datatask = [urlsession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            NSLog(@"error: %@", error);
        }
        else {
            NSLog(@"Success");
        }
    }];
    [datatask resume];
    
    
    NSURLSessionDataTask *datatask1 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://www.example1.com"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            NSLog(@"error: %@", error);
        }
        else {
            NSLog(@"Success");
        }
    }];
    [datatask1 resume];
    
}



// catch any network based on NSURLProtocol
-(void)netAntDidCatchRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data {
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (obj == nil) {
        obj = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSLog(@"catch_request:%@\nresponse:%@,\ndata:%@",request.URL.absoluteString, response.URL.absoluteString, obj);
}

-(void)appendImage:(NSData *)responseData {
    
    CGFloat screen_widht = [UIScreen mainScreen].bounds.size.width;
    CGFloat width = screen_widht / 6.0;
    
    UIImageView *imageV = [UIImageView new];
    UIImage *image = [[UIImage alloc] initWithData:responseData];
    imageV.backgroundColor = [UIColor lightGrayColor];
    imageV.image = image;
    if (self.preResponseImageView) {
        CGFloat maxX = CGRectGetMaxX(self.preResponseImageView.frame);
        CGFloat maxY = CGRectGetMaxY(self.preResponseImageView.frame);
        CGFloat x = maxX + width >= screen_widht ? 0 : maxX;
        CGFloat y = maxX + width >= screen_widht ? maxY  : maxY - width;
        
        imageV.frame = CGRectMake(x, y, width, width);
    }else{
        imageV.frame = CGRectMake(0 , 500, width, width);
        //        [self.view addSubview:imageV];
        //        self.preResponseImageView = imageV;
    }
    [self.view addSubview:imageV];
    self.preResponseImageView = imageV;
}

@end
