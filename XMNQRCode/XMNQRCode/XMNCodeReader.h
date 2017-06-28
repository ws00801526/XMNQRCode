//
//  XMNCodeReader.h
//  XMNQRCode
//
//  Created by XMFraker on 16/8/19.
//  Copyright © 2016年 XMFraker. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface XMNCodeReader : NSObject

/** 显示摄像头获取的页面信息 */
@property (strong, nonatomic, readonly, nonnull) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic, readonly, nonnull) AVCaptureMetadataOutput    *metadataOutput;

/** 当前codeReader检测的 code类型 具体参考 <AVFoundation/AVMetadataObject> */
@property (copy, nonatomic, readonly, nonnull)   NSArray *metadataObjectTypes;

/** 判断是否正在运行中 */
@property (assign, nonatomic, readonly, getter=isRunning) BOOL running;
/** 判断是否有前置摄像头 */
@property (assign, nonatomic, readonly) BOOL hasFrontDevice;

/** 回调block */
@property (copy, nonatomic, nullable)   void(^completedBlock)(NSString * _Nullable result);


#pragma mark - Life Cycle

/**
 *  @brief 初始化方法
 *
 *
 *  @param metadataObjectTypes 设置扫描的code类型
 *  @warning 默认支持QRCode
 *  @return XMNCodeReader实例
 */
- (instancetype _Nullable)initWithMetadataObjectTypes:(NSArray * _Nullable)metadataObjectTypes NS_DESIGNATED_INITIALIZER;

+ (instancetype _Nullable)readerWithMetadataObjectTypes:(NSArray * _Nullable)metadataObjectTypes;


#pragma mark - Method

- (void)startScaning;
- (void)stopScaning;

/**
 *  @brief 切换输入设备
 *  @warning  如果有前置摄像头  后置 -> 前置 -> 后置
 */
- (void)switchDeviceInput;

/**
 *  @brief 切换闪光灯开关状态
 *
 *  @param on 是否打开闪光灯
 */
- (void)switchFlash:(BOOL)on;

#pragma mark - Class Method

+ (BOOL)isAvaliable;

/**
 *  @brief 检测当前设备是否支持扫描对应类型的Code
 *
 *  @param metadataObjectType 需要扫描的code类型
 *  @warning 如果不传metadataObjectType  默认判断是否支持AVMetadataObjectTypeQRCode
 *  @return YES or NO
 */
+ (BOOL)supportsMetadataObjectType:(NSString * _Nullable)metadataObjectType;

/**
 *  @brief 将设备屏幕方向转化为对应的AVCaptureVideoOrientation
 *
 *  @param interfaceOrientation 设备方向
 *
 *  @return AVCaptureVideoOrientation
 */
+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end
