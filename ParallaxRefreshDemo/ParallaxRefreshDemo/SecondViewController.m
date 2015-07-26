//
//  SecondViewController.m
//  ParallaxRefreshDemo
//
//  Created by Rannie on 15/7/10.
//  Copyright (c) 2015年 Rannie. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(20, 25, 50, 25);
    [self.view addSubview:button];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
