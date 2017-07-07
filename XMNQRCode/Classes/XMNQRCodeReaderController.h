//
//  XMNQRCodeReaderController.h
//  Pods
//
//  Created by XMFraker on 2017/7/7.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMNQRCodeReaderController : UIViewController

/** 扫描边框颜色 默认RGB(36,159,216) */
@property (strong, nonatomic, nonnull) UIColor *lineColor;
/** 扫描边框颜色 默认RGB(36,159,216) */
@property (strong, nonatomic, nonnull) UIColor *cornerColor;
/** 扫描框大小 默认竖屏self.view.bounds.size.width - 160.f 横屏 self.view.bounds.size.height - 160.f*/
@property (assign, nonatomic) CGSize  centerSize;
/** 扫描框中心点位移, 默认UIOffsetZero */
@property (assign, nonatomic) CGPoint centerOffset;
/** 扫描完成回调block */
@property (copy, nonatomic, nullable)   void(^completionHandler)(NSString *__nullable result);

/**
 初始化方法, 初始化XMNQRCodeReaderController

 @param completionHandler 扫描回调handler
 @return XMNQRCodeReaderController 实例
 */
- (instancetype)initWithCompletionHandler:(nullable void(^)(NSString *__nullable result))completionHandler;


/**
 初始化方法

 @param metadataObjectTypes 支持扫描的类型
 @param completionHandler   扫描回调block
 @return XMNQRCodeReaderController 实例
 */
- (instancetype)initWithMetadataObjectTypes:(NSArray * _Nullable)metadataObjectTypes
                          completionHandler:(nullable void(^)(NSString *__nullable result))completionHandler NS_DESIGNATED_INITIALIZER;

/**
 开始扫描
 */
- (void)startScaning;

/**
 停止扫描
 */
- (void)stopScaning;

@end

NS_ASSUME_NONNULL_END
