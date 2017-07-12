//
//  XMNQRCodeReaderController.m
//  Pods
//
//  Created by XMFraker on 2017/7/7.
//
//

#import <XMNQRCode/XMNQRCodeReaderController.h>

#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>

#import <XMNQRCode/XMNQRCodeReaderView.h>
#import <XMNQRCode/XMNQRCodeTorch.h>


@interface XMNQRCodeReaderController ()

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) XMNQRCodeReaderView *codeReaderView;
@property (strong, nonatomic) XMNQRCodeTorch *torch;
@property (strong, nonatomic)   UIActivityIndicatorView *indicatorView;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (assign, nonatomic) BOOL setuped;

@property (copy, nonatomic)   NSArray *metadataObjectTypes;

@end



@interface XMNQRCodeReaderController (XMNQRCodeCaptureUtils)

/**
 *  @brief 切换闪光灯开关状态
 *
 *  @param on 是否打开闪光灯
 */
- (BOOL)switchFlash:(BOOL)on;


/**
 修改对应点的曝光度, 聚焦点

 @param point 触摸点
 */
- (void)focusCameraOnPoint:(CGPoint)point;

@end

@implementation XMNQRCodeReaderController
@dynamic lineColor;
@dynamic cornerColor;
@dynamic centerOffset;
@dynamic centerSize;

#pragma mark - Life Cycle

- (instancetype)init {
    
    return [self initWithMetadataObjectTypes:nil completionHandler:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    return [self initWithMetadataObjectTypes:nil completionHandler:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    return [self initWithMetadataObjectTypes:nil completionHandler:nil];
}

- (instancetype)initWithCompletionHandler:(nullable void(^)(NSString *__nullable result))completionHandler {
    
    
    return [self initWithMetadataObjectTypes:nil completionHandler:completionHandler];
}

- (instancetype)initWithMetadataObjectTypes:(NSArray * _Nullable)metadataObjectTypes
                          completionHandler:(nullable void(^)(NSString *__nullable result))completionHandler {
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        
        self.metadataObjectTypes = metadataObjectTypes ? : @[AVMetadataObjectTypeQRCode,//二维码
                                                             //以下为条形码，如果项目只需要扫描二维码，下面都不要写
                                                             AVMetadataObjectTypeEAN13Code,
                                                             AVMetadataObjectTypeEAN8Code,
                                                             AVMetadataObjectTypeUPCECode,
                                                             AVMetadataObjectTypeCode39Code,
                                                             AVMetadataObjectTypeCode39Mod43Code,
                                                             AVMetadataObjectTypeCode93Code,
                                                             AVMetadataObjectTypeCode128Code,
                                                             AVMetadataObjectTypePDF417Code];
        self.completionHandler = completionHandler;
    }
    return self;
}

- (void)dealloc {
    
#if DEBUG
    NSLog(@"%@ is %@ing", self, NSStringFromSelector(_cmd));
#endif
    [self stopScaning];
    self.completionHandler = nil;
}

#pragma mark - Override Methods

- (void)viewDidLoad {

    [super viewDidLoad];

    [self setup];
    [self setupUI];
    [self setupAVCaptureAuthorization];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    [self updateReaderViewFrame];
    self.torch.frame = CGRectMake(self.codeReaderView.renderFrame.origin.x + self.codeReaderView.renderFrame.size.width/2.f - 20.f, (self.codeReaderView.renderFrame.origin.y + self.codeReaderView.renderFrame.size.height) - 50.f, 50.f, 50.f);
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
#if DEBUG
    NSLog(@"%@ is %@ing", self, NSStringFromSelector(_cmd));
#endif
    if (self.setuped) {
        [self startScaning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
#if DEBUG
    NSLog(@"%@ is %@ing", self, NSStringFromSelector(_cmd));
#endif
    [self stopScaning];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event  {
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    [self focusCameraOnPoint:touchPoint];
}

#pragma mark - Public Methods

- (void)startScaning {
    
    if (self.session.isRunning) {
        return;
    }
    
    if (!self.setuped) {
        [self setupAVCaptureSession];
    }
    
    [self.session startRunning];
    
    if (self.indicatorView) {
        [self.indicatorView stopAnimating];
        [self.indicatorView removeFromSuperview];
    }
    
    self.codeReaderView.hidden = NO;
    [self.codeReaderView startScaleAnimation];
    [self.codeReaderView startAnimation];
}

- (void)stopScaning {
    
    [self.codeReaderView stopAnimation];
    [self.session stopRunning];
}

#pragma mark - EVENTS

- (void)handleOrientationChangedNotification:(NSNotification *)notificaiton {
    
    [self.codeReaderView setNeedsDisplay];
    if (self.previewLayer.connection.isVideoOrientationSupported) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        self.previewLayer.connection.videoOrientation = [XMNQRCodeReaderController videoOrientationFromInterfaceOrientation:orientation];
    }
}

- (void)handleTorchAction {
    
    BOOL on = !self.torch.isOn;
    if ([self switchFlash:on]) {
        self.torch.on = on;
    }else {
#if DEBUG
        NSLog(@"开启闪光灯失败");
#endif
    }
}

#pragma mark - Private Methods

- (void)setup {
    
    self.lineColor = self.cornerColor = [UIColor colorWithRed:36/255.f green:159/255.f blue:216/255.f alpha:1.f];
    switch ([XMNQRCodeReaderController videoOrientationFromInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation]) {
        case AVCaptureVideoOrientationLandscapeLeft:
        case AVCaptureVideoOrientationLandscapeRight:
            self.centerSize = CGSizeMake(self.view.bounds.size.height - 160.f, self.view.bounds.size.height - 160.f);
            break;
        default:
            self.centerSize = CGSizeMake(self.view.bounds.size.width - 160.f, self.view.bounds.size.width - 160.f);
            break;
    }
    self.centerOffset = CGPointZero;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationChangedNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)setupUI {
    
    self.codeReaderView.hidden = YES;
    [self.view addSubview:self.codeReaderView];
    
    self.torch = [[XMNQRCodeTorch alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.torch addTarget:self action:@selector(handleTorchAction) forControlEvents:UIControlEventTouchUpInside];
    self.torch.hidden = YES;
    [self.view addSubview:self.torch];

    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicatorView startAnimating];
    indicatorView.center = self.view.center;
    [self.view addSubview:self.indicatorView = indicatorView];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)setupAVCaptureAuthorization {
    
    __weak typeof(self) wSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                /** 开始启动二维码扫描功能 */
                __strong typeof(wSelf) self = wSelf;
                [self setupAVCaptureSession];
                [self startScaning];
            });
        } else {
            __strong typeof(wSelf) self = wSelf;
            [self showAVAuthorizationAlert];
        }
    }];
}

- (void)setupAVCaptureSession {
    
    if (self.setuped) {
        [self.session stopRunning];
        [self.previewLayer removeFromSuperlayer];
    }
    
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)self queue:dispatch_get_main_queue()];
    
    AVCaptureVideoDataOutput *output2 = [[AVCaptureVideoDataOutput alloc] init];
    [output2 setSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
#if TARGET_IPHONE_SIMULATOR
    
#else
    if (input) {
        [self.session addInput:input];
    }
    if (output) {
        [self.session addOutput:output];
    }
    if (output2) {
        [self.session addOutput:output2];
    }
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = self.metadataObjectTypes;
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:self.previewLayer = layer atIndex:0];
    self.setuped = YES;
#endif
}

- (void)updateReaderViewFrame {
    
    if (!self.codeReaderView || !self.session.isRunning) {
        return;
    }
    /** 重设预览界面的大小,避免大小错误 */
    self.codeReaderView.frame = self.previewLayer.frame = self.view.bounds;
    
    /** 增加设置扫描区域贡呢 */
    CGRect interestRect = [self.previewLayer metadataOutputRectOfInterestForRect:CGRectInset(self.codeReaderView.renderFrame, - 50, - 50)];
    AVCaptureMetadataOutput *output = [[self.session outputs] firstObject];
    output.rectOfInterest = interestRect;
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


#pragma mark - Setter

- (void)setLineColor:(UIColor *)lineColor {
    
    self.codeReaderView.scaningLineColor = lineColor;
}

- (void)setCornerColor:(UIColor *)cornerColor {
    
    self.codeReaderView.scaningCornerColor = cornerColor;
}

- (void)setCenterSize:(CGSize)centerSize {
    
    self.codeReaderView.renderSize = centerSize;
}

- (void)setCenterOffset:(CGPoint)centerOffset {
    
    self.codeReaderView.centerOffsetPoint = centerOffset;
}

#pragma mark - Getter

- (XMNQRCodeReaderView *)codeReaderView {
    
    if (!_codeReaderView) {
        _codeReaderView = [[XMNQRCodeReaderView alloc] init];
    }
    return _codeReaderView;
}

#pragma mark - Class Methods

+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        default:
            return AVCaptureVideoOrientationPortraitUpsideDown;
    }
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
    
    /** 增加识别完成后震动提示 */
    [XMNQRCodeReaderController playingSystemVibrate];

    return result;
}

+ (void)playingSystemVibrate {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0f) {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, NULL);
    }else {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

@end


@implementation XMNQRCodeReaderController (XMNCaptureDelegate)

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray<AVMetadataObject *> *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    
    AVMetadataObject *codeObject = [metadataObjects firstObject];
    if (codeObject && [codeObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]] && [(AVMetadataMachineReadableCodeObject *)codeObject stringValue]) {
        [self stopScaning];

        /** 增加识别完成后震动提示 */
        [XMNQRCodeReaderController playingSystemVibrate];
        self.completionHandler ? self.completionHandler([(AVMetadataMachineReadableCodeObject *)codeObject stringValue]) : nil;
    }else {
        NSLog(@"scan code does not has result");
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] copy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    [self.torch updateBrightnessValue:brightnessValue];
}

@end


@implementation XMNQRCodeReaderController (XMNQRCodeCaptureUtils)

/**
 *  @brief 切换闪光灯开关状态
 *
 *  @param on 是否打开闪光灯
 */
- (BOOL)switchFlash:(BOOL)on {
    
    return [XMNQRCodeReaderController safeUpdateConfigurationForDevice:[[self.session.inputs firstObject] device] forSession:self.session
                                               operationHandler:^(AVCaptureDevice *device) {
                                                   
                                                   [device setTorchMode:on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
                                               }];
}


/**
 改变摄像头曝光状态

 @param point 摄像头聚焦的点
 */
- (void)focusCameraOnPoint:(CGPoint)point {
    
    [XMNQRCodeReaderController safeUpdateConfigurationForDevice:[[self.session.inputs firstObject] device]
                                                     forSession:self.session
     
                                               operationHandler:^(AVCaptureDevice *device) {
                                                  
                                                   if ([device isFocusPointOfInterestSupported]) {
                                                       [device setFocusPointOfInterest:point];
                                                   }
                                                   
                                                   if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
                                                       [device setExposureMode:AVCaptureExposureModeAutoExpose];
                                                   }
                                               }];
}


+ (BOOL)safeUpdateConfigurationForDevice:(AVCaptureDevice *)device
                              forSession:(AVCaptureSession *)session
                        operationHandler:(void(^)(AVCaptureDevice * device))operationHandler {
    
    NSError *error;
    BOOL locked = [device lockForConfiguration:&error];
    if (locked && !error) {
        [session beginConfiguration];
        operationHandler(device);
        [session commitConfiguration];
        [device unlockForConfiguration];
        return YES;
    }else {
#if DEBUG
        NSLog(@"lock device :%@ failed :%@",device, [error localizedDescription]);
#endif
        return NO;
    }
}

@end
