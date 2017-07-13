//
//  XMNQRCodeTorch.h
//  Pods
//
//  Created by XMFraker on 2017/7/7.
//
//

#import <UIKit/UIKit.h>

/**
 配置手电筒是否显示
 */
@interface XMNQRCodeTorch : UIControl

/** 当前手电筒是否处于打开状态 */
@property (assign, nonatomic, getter=isOn) BOOL on;
/** 当前光亮度 */
@property (assign, nonatomic, readonly) CGFloat brightness;
/** 是否显示tips 默认NO */
@property (assign, nonatomic) BOOL showTips;

/**
 更新brightnessValue
 between -5.f ~ 5.f
 
 @param brightnessValue 新的光亮度
 */
- (void)updateBrightnessValue:(CGFloat)brightnessValue;

@end
