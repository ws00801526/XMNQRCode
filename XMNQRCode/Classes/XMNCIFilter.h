//
//  XMNCIFilter.h
//  Pods
//
//  Created by XMFraker on 2017/7/6.
//
//

#import <Foundation/Foundation.h>

@class CIImage;

/**
 XMNCIFilter, 使用CIFilter 提供滤镜功能
 */
@interface XMNCIFilter : NSObject

/** 剪切滤镜 */
@property (copy, nonatomic, readonly)   XMNCIFilter *(^cropFilter)(CGRect cropRect);
/** 缩放滤镜 */
@property (copy, nonatomic, readonly)   XMNCIFilter *(^resizeFilter)(CGSize targetSize);
/** 缩放位图滤镜 */
@property (copy, nonatomic, readonly)   XMNCIFilter *(^resizeBtimapFilter)(CGSize targetSize);
/** 替换前景色, 背景色滤镜 */
@property (copy, nonatomic, readonly)   XMNCIFilter *(^falseColorFilter)(UIColor *firstColor, UIColor *secondColor);
/** 透明度滤镜效果 */
@property (copy, nonatomic, readonly)   XMNCIFilter *(^alphaFilter)();
/** 提供CGAffine滤镜效果 */
@property (copy, nonatomic, readonly)   XMNCIFilter *(^affineFilter)(CGAffineTransform transfrom);
/** 提供替换前景图片, 背景图效果 */
@property (copy, nonatomic, readonly)   XMNCIFilter *(^blendFilter)(CIImage *backgroundImage, CIImage * maskImage);
/** 提供替换背景图效果 */
@property (copy, nonatomic, readonly)   XMNCIFilter *(^colorBlendFilter)(CIImage *backgroundImage);

/** 滤镜过后生成的图片 */
@property (strong, nonatomic, readonly) CIImage *CIImage;

/**
 初始化方法
 
 @param CIImage 默认CIImage图像
 @return XMNCIFilter 实例
 */
- (instancetype)initWithCIImage:(CIImage *)CIImage;

+ (instancetype)generateQRCode:(NSString *)info;
+ (instancetype)generateBarCode:(NSString *)info;
+ (instancetype)generateConstantColor:(UIColor *)color;

@end
