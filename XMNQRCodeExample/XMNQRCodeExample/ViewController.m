//
//  ViewController.m
//  XMNQRCodeExample
//
//  Created by XMFraker on 16/8/19.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "ViewController.h"
#import <XMNQRCode/XMNQRCode.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)handleScanAction:(UIButton *)sender {
    
    XMNCodeReaderController *codeReaderC = [[XMNCodeReaderController alloc] init];
    
    /** renderSize 控制扫描区域大小 */
//    codeReaderC.renderSize = CGSizeMake(200, 200);
    
    /** centerOffsetPoint 控制扫描区域的中心点偏移*/
//    codeReaderC.centerOffsetPoint = CGPointMake(0, 50);
    
    /** 修改扫描线颜色 */
    codeReaderC.scaningLineColor = [UIColor redColor];
    
    /** 修改扫描框颜色 */
    codeReaderC.scaningCornerColor = [UIColor yellowColor];

    [codeReaderC setCompletedBlock:^(NSString *scanResult){
        
        NSLog(@"this is scan result :%@",scanResult);
    }];
    [self.navigationController pushViewController:codeReaderC animated:YES];
}

@end
