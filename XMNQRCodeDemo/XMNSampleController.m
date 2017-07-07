//
//  XMNSampleController.m
//  XMNQRCodeDemo
//
//  Created by XMFraker on 2017/7/6.
//  Copyright © 2017年 XMFraker. All rights reserved.
//

#import "XMNSampleController.h"

@interface XMNSampleController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *barCodeImageView;


@end

@implementation XMNSampleController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.image = self.image;
    self.barCodeImageView.image = self.barcodeImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
