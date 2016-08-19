//
//  XMNCodeReaderController.m
//  XMNQRCode
//
//  Created by XMFraker on 16/8/19.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNCodeReaderController.h"

#import "XMNCodeReader.h"
#import "XMNCodeReaderView.h"

@interface XMNCodeReaderController ()

@property (strong, nonatomic) XMNCodeReader *codeReader;
@property (strong, nonatomic) XMNCodeReaderView *codeReaderView;

/** 控制闪光灯效果的button */
@property (strong, nonatomic)   UIButton *switchFlashButton;
/** 控制摄像头的button */
@property (strong, nonatomic)   UIButton *switchCameraButton;

/** 显示描述性文字 */
@property (strong, nonatomic) UILabel *tipsLabel;


@end

@implementation XMNCodeReaderController

#pragma mark - Life Cycle


- (void)dealloc {
    
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));
    [self.codeReader stopScaning];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupUI];
    
    self.tipsAttrs = [[NSMutableAttributedString alloc] initWithString:@"将二维码放于框内\n即可开始扫描" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f]}];
    self.autoScaning = YES;
    self.scaningLineColor = self.scaningCornerColor = [UIColor greenColor];
    self.swithchCameraEnabled = self.switchFlashEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Override Method

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    NSLog(@"%@ viewWillAppear",NSStringFromClass([self class]));
    if (self.isAutoScaning) {
        [self startScaning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    NSLog(@"%@ viewWillDisappear",NSStringFromClass([self class]));
    [self stopScaning];
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    /** 重设预览界面的大小,避免大小错误 */
    self.codeReaderView.frame = self.codeReader.previewLayer.frame = self.view.bounds;
}

#pragma mark - Method

- (void)setupUI {
    
    self.codeReader = [[XMNCodeReader alloc] init];
    self.codeReaderView = [[XMNCodeReaderView alloc] init];
    
    __weak typeof(*&self) wSelf = self;
    
    [self.codeReader setCompletedBlock:^(NSString * result) {
        
        __strong typeof(*&wSelf) self = wSelf;
        self.completedBlock ? self.completedBlock(result) : nil;
        [self stopScaning];
    }];
    
    [self.view.layer addSublayer:self.codeReader.previewLayer];
    [self.view addSubview:self.codeReaderView];
    [self setupButton];
}

- (void)setupButton {
    
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.switchFlashButton];
    [self.view addSubview:self.switchCameraButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switchCameraButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.f constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switchCameraButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:self.navigationController ? 64 : 84]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_switchFlashButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.switchCameraButton attribute:NSLayoutAttributeRight multiplier:1.f constant:-50]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_switchFlashButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:self.navigationController ? 64 : 84]];

    /** 配置切换 宽高 */
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switchCameraButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:40.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switchCameraButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:40.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_switchFlashButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:40.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_switchFlashButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:40.f]];
    
    /** 配置tipsLabel的自动布局 */
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tipsLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:self.codeReaderView.renderFrame.size.height + self.codeReaderView.renderFrame.origin.y + 20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tipsLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.f constant:-16]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tipsLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.f constant:16]];
}


- (void)orientationChanged:(NSNotification *)notification {
    
    [self.codeReaderView setNeedsDisplay];
    if (_codeReader.previewLayer.connection.isVideoOrientationSupported) {
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        _codeReader.previewLayer.connection.videoOrientation = [XMNCodeReader videoOrientationFromInterfaceOrientation:orientation];
    }
}

- (void)startScaning {
    
    [self.codeReader startScaning];
    [self.codeReaderView startAnimation];
}

- (void)stopScaning {
    
    [self.codeReader stopScaning];
    [self.codeReaderView stopAnimation];
}

- (void)handleSwitchFlash:(UIButton *)button {
    
    button.selected = !button.selected;
    [self.codeReader switchFlash:button.selected];
}

- (void)handleSwitchCamera:(UIButton *)button {
    
    [self.codeReader switchDeviceInput];
}

#pragma mark - Setter

- (void)setTipsAttrs:(NSAttributedString *)tipsAttrs {
    
    self.tipsLabel.attributedText = tipsAttrs;
}

- (void)setSwitchFlashEnabled:(BOOL)switchFlashEnabled {
    
    self.switchFlashButton.hidden = !switchFlashEnabled;
}

- (void)setSwithchCameraEnabled:(BOOL)swithchCameraEnabled {
    
    self.switchCameraButton.hidden = !swithchCameraEnabled;
}

- (void)setScaningLineColor:(UIColor *)scaningLineColor {
    
    self.codeReaderView.scaningLineColor = scaningLineColor;
}

- (void)setScaningCornerColor:(UIColor *)scaningCornerColor {
    
    self.codeReaderView.scaningCornerColor = scaningCornerColor;
}

#pragma mark - Getter

- (UIColor *)scaningCornerColor {
    
    return self.codeReaderView.scaningCornerColor;
}

- (UIColor *)scaningLineColor {
    
    return self.codeReaderView.scaningLineColor;
}

- (NSAttributedString *)tipsAttrs {
    
    return self.tipsLabel.attributedText;
}

- (UIButton *)switchCameraButton {
    
    if (!_switchCameraButton) {
        
        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchCameraButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.XMFraker.XMNQRCode"];
        if (!bundle) {
            bundle = [NSBundle mainBundle];
        }
        NSBundle *resourceBundle = [NSBundle bundleWithPath:[bundle pathForResource:@"XMNQRCode" ofType:@"bundle"]];
        NSString *onImageName = [NSString stringWithFormat:@"camera_switch@2x"];
        
        [_switchCameraButton setImage:[UIImage imageWithContentsOfFile:[resourceBundle pathForResource:onImageName ofType:@"png"]] forState:UIControlStateNormal];
        
        [_switchCameraButton addTarget:self action:@selector(handleSwitchCamera:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _switchCameraButton;
}


- (UIButton *)switchFlashButton {
    
    if (!_switchFlashButton) {
        
        _switchFlashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchFlashButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.XMFraker.XMNQRCode"];
        if (!bundle) {
            bundle = [NSBundle mainBundle];
        }
        NSBundle *resourceBundle = [NSBundle bundleWithPath:[bundle pathForResource:@"XMNQRCode" ofType:@"bundle"]];
        NSString *offImageName = [NSString stringWithFormat:@"camera_flash_off@2x"];
        NSString *onImageName = [NSString stringWithFormat:@"camera_flash_on@2x"];
        
        [_switchFlashButton setImage:[UIImage imageWithContentsOfFile:[resourceBundle pathForResource:onImageName ofType:@"png"]] forState:UIControlStateNormal];
        [_switchFlashButton setImage:[UIImage imageWithContentsOfFile:[resourceBundle pathForResource:offImageName ofType:@"png"]] forState:UIControlStateSelected];
        [_switchFlashButton setImage:[UIImage imageWithContentsOfFile:[resourceBundle pathForResource:offImageName ofType:@"png"]] forState:UIControlStateHighlighted];
        
        [_switchFlashButton addTarget:self action:@selector(handleSwitchFlash:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchFlashButton;
}

- (UILabel *)tipsLabel {
    
    if (!_tipsLabel) {
        
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.numberOfLines = 0;
        _tipsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _tipsLabel;
}

@end

