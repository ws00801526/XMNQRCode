//
//  XMNCodeReader.m
//  XMNQRCode
//
//  Created by XMFraker on 16/8/19.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNCodeReader.h"


@interface XMNCodeReader () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureDevice            *defaultDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *defaultDeviceInput;
@property (strong, nonatomic) AVCaptureDevice            *frontDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *frontDeviceInput;
@property (strong, nonatomic) AVCaptureMetadataOutput    *metadataOutput;
@property (strong, nonatomic) AVCaptureSession           *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation XMNCodeReader

#pragma mark - Life Cycle

- (instancetype)init {
    
    return [self initWithMetadataObjectTypes:nil];
}

- (instancetype)initWithMetadataObjectTypes:(NSArray *)metadataObjectTypes {
    
    if (self = [super init]) {
        
        _metadataObjectTypes = metadataObjectTypes  ? [metadataObjectTypes copy] : @[AVMetadataObjectTypeQRCode];
        [self setupAVComponents];
    }
    return self;
}


+ (instancetype)readerWithMetadataObjectTypes:(NSArray *)metadataObjectTypes {
    
    return [[[self class] alloc] initWithMetadataObjectTypes:metadataObjectTypes];
}


#pragma mark - Method

/**
 *  @brief 初始化AV设备
 *  获取默认输入设备,前置输入设备
 *  metadata输出设备
 */
- (void)setupAVComponents {

    /** 获取默认的摄像头捕捉设备 */
    self.defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (self.defaultDevice) {
        self.defaultDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.defaultDevice error:nil];
        self.metadataOutput     = [[AVCaptureMetadataOutput alloc] init];
        self.session            = [[AVCaptureSession alloc] init];
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];

        for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            /** 获取前置输入设备 */
            if (device.position == AVCaptureDevicePositionFront) {
                self.frontDevice = device;
                self.frontDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.frontDevice error:nil];
            }
        }
        [self.session addOutput:self.metadataOutput];
        [self.session addInput:self.defaultDeviceInput];
        
        [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.metadataOutput setMetadataObjectTypes:self.metadataObjectTypes];
    }
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}


/// ========================================
/// @name   Public Method
/// ========================================

- (void)startScaning {
    
    if (!self.isRunning) {
        [self.session startRunning];
    }
}

- (void)stopScaning {
    
    if (self.isRunning) {
        [self.session stopRunning];
    }
}


- (void)switchDeviceInput {
    
    if (self.hasFrontDevice) {
        [self.session beginConfiguration];
        
        /** 移除当前输入设备 */
        AVCaptureDeviceInput *currentInput = [self.session.inputs firstObject];
        [self.session removeInput:currentInput];
        
        /** 重新添加输入设备 */
        AVCaptureDeviceInput *newDeviceInput = (currentInput.device.position == AVCaptureDevicePositionFront) ? self.self.defaultDeviceInput : self.frontDeviceInput;
        [self.session addInput:newDeviceInput];
        
        [self.session commitConfiguration];
    }
}


/**
 *  @brief 切换闪光灯开关状态
 *
 *  @param on 是否打开闪光灯
 */
- (void)switchFlash:(BOOL)on {
    
    [self.session beginConfiguration];
    AVCaptureDeviceInput *currentInput = [self.session.inputs firstObject];
    AVCaptureDevice *currentDevice = (currentInput == self.defaultDeviceInput ? self.defaultDevice : self.frontDevice);
    [currentDevice lockForConfiguration:nil];
    [currentDevice setFlashMode:on ? AVCaptureFlashModeOn : AVCaptureFlashModeOff];
    [currentDevice setTorchMode:on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
    [currentDevice unlockForConfiguration];
    [self.session commitConfiguration];
}

#pragma mark - Getter

- (BOOL)hasFrontDevice {
    
    return self.frontDevice != nil;
}

- (BOOL)isRunning {
    
    return self.session.isRunning;
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    
    /** 获取扫描结果 */
    for (AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]
            && [_metadataObjectTypes containsObject:current.type]) {
            
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            self.completedBlock ? self.completedBlock(scannedResult) : nil;
        }
    }
}

#pragma mark - Class Methods

+ (BOOL)isAvaliable {
    
    @autoreleasepool {
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (!captureDevice) {
            return NO;
        }
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        
        if (!deviceInput || error) {
            return NO;
        }
        return YES;
    }
}

+ (BOOL)supportsMetadataObjectType:(NSString *)metadataObjectType {
    
    if (![self isAvaliable]) {
        return NO;
    }
    
    @autoreleasepool {
        // Setup components
        AVCaptureDevice *captureDevice    = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
        AVCaptureMetadataOutput *output   = [[AVCaptureMetadataOutput alloc] init];
        AVCaptureSession *session         = [[AVCaptureSession alloc] init];
        
        [session addInput:deviceInput];
        [session addOutput:output];
        
        if (metadataObjectType == nil || metadataObjectType.length == 0) {
            metadataObjectType = AVMetadataObjectTypeQRCode;
        }
        return [output.availableMetadataObjectTypes containsObject:metadataObjectType];
    }
    return NO;
}


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

@end


