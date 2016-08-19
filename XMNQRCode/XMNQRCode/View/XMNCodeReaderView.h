//
//  XMNCodeReaderView.h
//  XMNQRCode
//
//  Created by XMFraker on 16/8/19.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

/// ========================================
/// @name   相关尺寸宏
/// ========================================

#ifndef SCREEN_WIDTH
    #define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#endif

#ifndef SCREEN_HEIGHT
    #define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#endif


@interface XMNCodeReaderView : UIView


/** 扫描区域 默认 CGRectMake(60,180,SCREEN_WIDTH-160,SCREEN_WIDTH-160) */
@property (assign, nonatomic) CGRect renderFrame;

/** 扫描区域的边框颜色 */
@property (strong, nonatomic) UIColor *scaningCornerColor;
/** 扫面区域的线条颜色 */
@property (strong, nonatomic) UIColor *scaningLineColor;

/**
 *  @brief 初始化方法
 *
 *  @param renderFrame 扫描view的页面
 *
 *  @return
 */
- (instancetype)initWithRenderFrame:(CGRect)renderFrame;

/**
 *  @brief 开始扫描动画
 */
- (void)startAnimation;
/** 
 *  @brief 停止扫描动画
 */
- (void)stopAnimation;

@end
