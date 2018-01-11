//
//  NetViewController.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "NetViewController.h"
#import "NetAnt.h"

@interface NetViewController ()<NetAntDelegate>

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

@end
