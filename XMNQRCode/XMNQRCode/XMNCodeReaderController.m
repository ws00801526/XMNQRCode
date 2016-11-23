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

@property (weak, nonatomic)   NSLayoutConstraint *tipsTConstraint;



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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    NSLog(@"viewdidload over");
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

    /** 增加设置扫描区域贡呢 */
    CGRect intertRect = [self.codeReader.previewLayer metadataOutputRectOfInterestForRect:self.codeReaderView.renderFrame];
    self.codeReader.metadataOutput.rectOfInterest = intertRect;
    
    if ([self.view.constraints containsObject:self.tipsTConstraint]) {
        [self.view removeConstraint:self.tipsTConstraint];
    }
    if (self.tipsLabel.superview) {
        [self.view addConstraint:self.tipsTConstraint = [NSLayoutConstraint constraintWithItem:self.tipsLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:self.codeReaderView.renderFrame.size.height + self.codeReaderView.renderFrame.origin.y + 20]];
    }
}

#pragma mark - Method

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    /** 用户未开启相机授权, 不进行codeReader授权 */
    if (![self hasAVAuthorization]) {
        return;
    }
    
    self.codeReader = [[XMNCodeReader alloc] init];
    self.codeReaderView = [[XMNCodeReaderView alloc] init];
    self.codeReaderView.scaningLineColor = self.scaningLineColor;
    self.codeReaderView.scaningCornerColor = self.scaningCornerColor;
    self.codeReaderView.renderSize = self.renderSize;
    self.codeReaderView.centerOffsetPoint = self.centerOffsetPoint;
    
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

/**
 *  @brief 判断用户是否授权了相机访问
 *  并且提示用户去授权访问
 *  @return YES or NO
 */
- (BOOL)hasAVAuthorization {
    
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            __weak typeof(*&self) wSelf = self;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                __strong typeof(*&wSelf) self = wSelf;
                if (granted) {
                    [self setupUI];
                }else {
                    if (self.presentingViewController) {
                        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                    }else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }];
            return NO;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showAVAuthorizationAlert];
            });
            return NO;
        }
        default:
            return YES;
    }
}

- (void)showAVAuthorizationAlert {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"未开启应用相机权限,请在设置中启用" preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(*&self) wSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"稍后开启" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
        __strong typeof(*&wSelf) self = wSelf;
        if (self.presentingViewController) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        if (self.presentingViewController) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [alertC addAction:cancelAction];
    [alertC addAction:confirmAction];
    [self showDetailViewController:alertC sender:self];
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
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switchFlashButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:40.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switchFlashButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:40.f]];
    
    /** 配置tipsLabel的自动布局 */
    [self.view addConstraint:self.tipsTConstraint = [NSLayoutConstraint constraintWithItem:self.tipsLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:self.codeReaderView.renderFrame.size.height + self.codeReaderView.renderFrame.origin.y + 20]];
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
    
    _switchFlashEnabled = switchFlashEnabled;
    self.switchFlashButton.hidden = !switchFlashEnabled;
}

- (void)setSwitchCameraEnabled:(BOOL)switchCameraEnabled {
    
    _switchCameraEnabled = switchCameraEnabled;
    self.switchCameraButton.hidden = !switchCameraEnabled;
}

#pragma mark - Getter

- (UIColor *)scaningCornerColor {
    
    return _scaningCornerColor ? : self.codeReaderView.scaningCornerColor;
}

- (UIColor *)scaningLineColor {
    
    return _scaningLineColor ? : self.codeReaderView.scaningLineColor;
}

- (NSAttributedString *)tipsAttrs {
    
    return self.tipsLabel.attributedText;
}

- (UIButton *)switchCameraButton {
    
    if (!_switchCameraButton) {
        
        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchCameraButton.hidden = YES;
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
        _switchFlashButton.hidden = YES;
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


#pragma mark - Class Method

+ (NSString *)readQRCodeWithImage:(UIImage * __nonnull)image {
    
    if (!image) {
        
        return nil;
    }
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:ciImage];
    CIQRCodeFeature *feature = [features firstObject];
    NSString *result = feature.messageString;
    return result;
}

@end

