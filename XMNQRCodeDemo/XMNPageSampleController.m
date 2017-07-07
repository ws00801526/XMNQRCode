//
//  XMNPageSampleController.m
//  XMNQRCodeDemo
//
//  Created by XMFraker on 2017/7/7.
//  Copyright © 2017年 XMFraker. All rights reserved.
//

#import "XMNPageSampleController.h"


#import <XMNQRCode/XMNQRCodeBuilder.h>

@interface XMNPageSampleController ()

@property (weak, nonatomic) IBOutlet UIImageView *frameQRCodeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *toastQRCodeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *catQRCodeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *leafQRCodeImageView;


@end

@implementation XMNPageSampleController

#pragma mark - Override Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildFrameQRCode];
    [self buildLeafQRCode];
    [self buildCatQRCode];
    [self buildToastQRCode];
}


#pragma mark - Private Methods

- (void)buildFrameQRCode {
    
    XMNQRCodeBuilder *builder = [[XMNQRCodeBuilder alloc] initWithInfo:@"https://www.baidu.com"
                                                                  size:CGSizeMake(180, 180.f)];
    builder.innerStyle = @[@{@(XMNQRCodeBuilderPositionTopLeft):[UIImage imageNamed:@"Red"]},
                           @{@(XMNQRCodeBuilderPositionTopRight):[UIImage imageNamed:@"Red"]},
                           @{@(XMNQRCodeBuilderPositionBottomLeft):[UIImage imageNamed:@"Blue"]}];
    self.frameQRCodeImageView.image = builder.QRCodeImage;
}

- (void)buildToastQRCode {
    
    XMNQRCodeBuilder *builder = [[XMNQRCodeBuilder alloc] initWithInfo:@"https://www.baidu.com"
                                                                  size:CGSizeMake(180, 180.f)];
    builder.backgroundColor = [UIColor clearColor];
    builder.topColor = [UIColor colorWithRed:219/255.f green:127/255.f blue:60/255.f alpha:.8f];
    builder.centerImage = [UIImage imageNamed:@"Avatar"];
    self.toastQRCodeImageView.image = builder.QRCodeImage;
}

- (void)buildCatQRCode {
    
    XMNQRCodeBuilder *builder = [[XMNQRCodeBuilder alloc] initWithInfo:@"https://www.baidu.com"
                                                                  size:CGSizeMake(180, 180.f)];
    builder.innerStyle = @[@{@(XMNQRCodeBuilderPositionTopLeft):[UIImage imageNamed:@"CatLeft"]},
                           @{@(XMNQRCodeBuilderPositionTopRight):[UIImage imageNamed:@"CatRight"]}];
    builder.topColor = [UIColor colorWithRed:90/255.f green:35/255.f blue:7/255.f alpha:1.f];
    builder.backgroundColor = [UIColor clearColor];
    builder.centerImage = [UIImage imageNamed:@"Avatar"];
    builder.removeQuietZone = YES;
    self.catQRCodeImageView.image = builder.QRCodeImage;
}

- (void)buildLeafQRCode {
    
    XMNQRCodeBuilder *builder = [[XMNQRCodeBuilder alloc] initWithInfo:@"https://www.baidu.com"
                                                                  size:CGSizeMake(180, 180.f)];
    builder.topColor = [UIColor clearColor];
    builder.topColor = [UIColor colorWithWhite:.0f alpha:.6f];
    builder.centerImage = [UIImage imageNamed:@"Avatar"];
    builder.removeQuietZone = YES;
    self.leafQRCodeImageView.image = builder.QRCodeImage;
}

@end
