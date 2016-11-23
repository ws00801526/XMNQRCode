//
//  XMNCodeReaderController.h
//  XMNQRCode
//
//  Created by XMFraker on 16/8/19.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief 实现Code 扫描页面
 */
@interface XMNCodeReaderController : UIViewController

/** 是否进入页面自动开始扫描 默认YES */
@property (assign, nonatomic, getter=isAutoScaning) BOOL autoScaning;

@property (copy, nonatomic, nullable)   void(^completedBlock)(NSString * _Nullable result);

/** 
 *  是否可以切换闪光灯
 *  如果为是 则显示闪光灯切换按钮  默认 NO
 **/
@property (assign, nonatomic) BOOL switchFlashEnabled;

/**
 *  是否可以切换摄像头
 *  如果为是 显示切换摄像头按钮    默认 NO
 **/
@property (assign, nonatomic) BOOL switchCameraEnabled;


/// ========================================
/// @name   扫描区域的相关属性
/// ========================================

/** 扫描区域的边框颜色 默认redColor*/
@property (strong, nonatomic, nonnull) UIColor *scaningCornerColor;
/** 扫面区域的线条颜色 默认redColor*/
@property (strong, nonatomic, nonnull) UIColor *scaningLineColor;

/** 扫描区域下方的描述性文字 设置为nil时,会隐藏tips */
@property (strong, nonatomic, nullable) NSAttributedString *tipsAttrs;


/** 渲染区域大小  默认 竖屏CGSizeMake(SCREEN_WIDTH-160, SCREEN_WIDTH-160)  横屏 CGSizeMake(SCREEN_HEIGHT-160, SCREEN_HEIGHT - 160)*/
@property (assign, nonatomic) CGSize renderSize;
/** 渲染区域的中间位置偏移量  默认CGPointZero */
@property (assign, nonatomic) CGPoint centerOffsetPoint;

/**
 *  @brief 开始扫描
 */
- (void)startScaning;

/**
 *  @brief 结束扫描
 */
- (void)stopScaning;

#pragma mark - Class Method

+ (NSString * __nullable)readQRCodeWithImage:(UIImage * __nonnull)image;

@end
