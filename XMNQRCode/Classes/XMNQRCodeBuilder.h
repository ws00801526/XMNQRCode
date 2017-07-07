//
//  XMNQRCodeBuilder.h
//  Pods
//
//  Created by XMFraker on 2017/7/6.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XMNQRCodeBuilderPosition) {
    XMNQRCodeBuilderPositionTopLeft,
    XMNQRCodeBuilderPositionTopRight,
    XMNQRCodeBuilderPositionBottomLeft,
    XMNQRCodeBuilderPositionCenter,
    XMNQRCodeBuilderPositionQuietZone
};

typedef NS_ENUM(NSUInteger, XMNQRCodeBuilderCodeMode) {
    XMNQRCodeBuilderCodeModeQRCode,
    XMNQRCodeBuilderCodeModeBarCode
};

NS_ASSUME_NONNULL_BEGIN

@interface XMNQRCodeBuilder : NSObject

/// ======================================== ///
/// @name   以下属性支持BarCode,QRCode
/// ======================================== ///

/** 二维码条形颜色  默认UIColor.black */
@property (strong, nonatomic) UIColor *topColor;
/** 二维码条形内容中间填充色 UIColor.whiter */
@property (strong, nonatomic) UIColor *bottomColor;

/// ======================================== ///
/// @name   以下属性只支持barCode               ///
/// ======================================== ///

/** 是否需要拼接条形码文字 */
@property (assign, nonatomic) BOOL appendBarCodeText;

/** barCodeText 距离条形码位置 */
@property (assign, nonatomic) CGFloat barCodeTextPadding;

/** 条形码文字样式, 默认18号字体, 居中显示, self.topColor */
@property (copy, nonatomic)   NSDictionary *barCodeTextStyle;

/// ======================================== ///
/// @name   以下属性只支持QRCode                ///
/// ======================================== ///

/** 二维码, 条形码背景色, 默认为 UIColor.white */
@property (strong, nonatomic) UIColor *backgroundColor;
/** 是否移除周围空白区域 */
@property (assign, nonatomic) BOOL removeQuietZone;
/** 覆盖物图片, 设置此属性, 会将对应图片覆盖在二维码上方 */
@property (strong, nonatomic, nullable) UIImage *maskImage;
/** 放置于二维码中间图片 */
@property (strong, nonatomic, nullable) UIImage *centerImage;
/** 二维码topLeft,topRight,bottomLeft 3个方形内部方块颜色 */
@property (strong, nonatomic, nullable) UIColor *innerColor;
/** 二维码topLeft,topRight,bottomLeft 3个方块边框方块颜色 */
@property (strong, nonatomic, nullable) UIColor *outerColor;
/** 二维码topLeft,topRight,bottomLeft 3个方形内部方块样式, 支持UIColor,UIImage */
@property (strong, nonatomic, nullable) NSArray<NSDictionary<NSNumber *,id> *> *innerStyle;
/** 二维码topLeft,topRight,bottomLeft 3个方形外部方块样式 */
@property (strong, nonatomic, nullable) NSArray<NSDictionary<NSNumber *,UIImage *> *> *outerStyle;

/** 生成的二维码图片 */
@property (strong, nonatomic, readonly) UIImage *QRCodeImage;
/** 生成的条形码图片 */
@property (strong, nonatomic, readonly) UIImage *barCodeImage;

/**
 初始化方法

 @param info 需要生成条形码,二维码的信息, 条形码只支持ASCII码
 @param size 生成的图片大小
 @return XMNQRCodeBuilder 实例
 */
- (instancetype)initWithInfo:(NSString *)info
                        size:(CGSize)size;

/**
 异步生成条形码,二维码

 @param mode 需要生成的codeImage类型 默认XMNQRCodeBuilderCodeModeQRCode
 @param completionHandler 回调block
 */
- (void)generateCodeImageWithMode:(XMNQRCodeBuilderCodeMode)mode
                completionHandler:(nullable void(^)(UIImage * __nullable image))completionHandler;

@end

@interface XMNQRCodeBuilder (XMNDeprecated)

- (instancetype)init __deprecated_msg("use initWithInfo:size: insteaded");

@end

NS_ASSUME_NONNULL_END
