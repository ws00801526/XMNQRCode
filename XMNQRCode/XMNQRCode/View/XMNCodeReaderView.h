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


/** 渲染区域大小  默认 竖屏CGSizeMake(SCREEN_WIDTH-160, SCREEN_WIDTH-160)  横屏 CGSizeMake(SCREEN_HEIGHT-160, SCREEN_HEIGHT - 160)*/
@property (assign, nonatomic) CGSize renderSize;
/** 渲染区域的中间位置偏移量  默认CGPointZero */
@property (assign, nonatomic) CGPoint centerOffsetPoint;

/** 扫描区域 {self.renderCenter,
 self.renderSize} */
@property (assign, nonatomic, readonly) CGRect renderFrame;
/** 扫描区域的中心点 CGPointMake(self.center.x + self.centerOffsetPoint.x, self.center.y + self.centerOffsetPoint.y)*/
@property (assign, nonatomic, readonly) CGPoint renderCenter;



/** 扫描区域的边框颜色  默认红色*/
@property (strong, nonatomic) UIColor *scaningCornerColor;
/** 扫面区域的线条颜色  默认红色*/
@property (strong, nonatomic) UIColor *scaningLineColor;

/**
 *  @brief 初始化方法
 *
 *  @param renderSize 扫描view的大小
 *
 *  @return
 */
- (instancetype)initWithRenderSize:(CGSize)renderSize;

/**
 *  @brief 开始扫描动画
 */
- (void)startAnimation;
/** 
 *  @brief 停止扫描动画
 */
- (void)stopAnimation;

@end
