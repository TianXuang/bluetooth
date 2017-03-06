//
//  ViewController.m
//  bluetooth
//
//  Created by VeLink on 17/1/11.
//  Copyright © 2017年 VeLink. All rights reserved.
//

#import "ViewController.h"
#import "CenterViewController.h"
#import "PeripheralManagerViewController.h"
#import "CenterManagerViewController.h"
@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *but=[UIButton buttonWithType:UIButtonTypeCustom];
    but.frame=CGRectMake(100, 100, 200, 40);
    but.backgroundColor=[UIColor orangeColor];
    [but setTitle:@"中心设备" forState:UIControlStateNormal];
    [but addTarget:self action:@selector(butClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
    
    UIButton *but1=[UIButton buttonWithType:UIButtonTypeCustom];
    but1.frame=CGRectMake(100, 300, 200, 40);
    but1.backgroundColor=[UIColor orangeColor];
    [but1 setTitle:@"外围设备" forState:UIControlStateNormal];
    [but1 addTarget:self action:@selector(butClickq) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but1];

}
-(void)butClick
{
//    CenterViewController *center=[[CenterViewController alloc]init];
//    [self presentViewController:center animated:NSLayoutAttributeCenterYWithinMargins completion:^{
//        
//    }];
        CenterManagerViewController *center=[[CenterManagerViewController alloc]init];
        [self presentViewController:center animated:NSLayoutAttributeCenterYWithinMargins completion:^{
    
        }];
}
-(void)butClickq
{
    PeripheralManagerViewController *center=[[PeripheralManagerViewController alloc]init];
    [self presentViewController:center animated:NSLayoutAttributeCenterYWithinMargins completion:^{
        
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
