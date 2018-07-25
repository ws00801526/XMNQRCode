//
//  XMNQRCodeReaderController.h
//  Pods
//
//  Created by XMFraker on 2017/7/7.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^XMNQRCodeReaderCompletionHandler)(NSString *__nullable result);

@class XMNQRCodeReaderController;
@protocol XMNQRCodeReaderControllerDelegate <NSObject>

- (void)codeReaderControllerShowAblumController:(XMNQRCodeReaderController *)controller completionHandler:(void(^)(UIImage *image))completionHandler;
- (void)codeReaderControllerShowReportController:(XMNQRCodeReaderController *)controller completionHandler:(void(^)(void))completionHandler;
- (void)codeReaderControllerShowOtherController:(XMNQRCodeReaderController *)controller completionHandler:(void(^)(void))completionHandler;

@end

@interface XMNQRCodeReaderController : UIViewController

/** 二维码扫描界面相关代理, 处理选择相册, 付款码等功能 */
@property (assign, nonatomic, nullable) id<XMNQRCodeReaderControllerDelegate> delegate;
/** 二维码界面标题文字 最多6个汉字*/
@property (copy, nonatomic)   NSString *title;
/** 扫描边框颜色 默认RGB(36,159,216) */
@property (strong, nonatomic) UIColor *lineColor;
/** 扫描边框颜色 默认RGB(36,159,216) */
@property (strong, nonatomic) UIColor *cornerColor;
/** 扫描框大小 默认竖屏self.view.bounds.size.width - 160.f 横屏 self.view.bounds.size.height - 160.f*/
@property (assign, nonatomic) CGSize  centerSize;
/** 扫描框中心点位移, 默认UIOffsetZero */
@property (assign, nonatomic) CGPoint centerOffset;
/** 是否显示album按钮 */
@property (assign, nonatomic, getter=isAlbumAvailable) BOOL albumAvailable;
/** 是否显示report提示 */
@property (assign, nonatomic, getter=isReportAvailable) BOOL reportAvailable;
/** 是否使用bottomView功能 */
@property (assign, nonatomic, getter=isBottomAvailable) BOOL bottomAvailable;

/** 扫描完成回调block */
@property (copy, nonatomic, nullable) XMNQRCodeReaderCompletionHandler completionHandler;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 初始化方法, 初始化XMNQRCodeReaderController

 @param completionHandler 扫描回调handler
 @return XMNQRCodeReaderController 实例
 */
- (instancetype)initWithCompletionHandler:(nullable XMNQRCodeReaderCompletionHandler)completionHandler;


/**
 初始化方法

 @param metadataObjectTypes 支持扫描的类型
 @param completionHandler   扫描回调block
 @return XMNQRCodeReaderController 实例
 */
- (instancetype)initWithMetadataObjectTypes:(NSArray * _Nullable)metadataObjectTypes
                          completionHandler:(nullable XMNQRCodeReaderCompletionHandler)completionHandler NS_DESIGNATED_INITIALIZER;

/**
 开始扫描
 */
- (void)startScaning;

/**
 停止扫描
 */
- (void)stopScaning;

/**
 识别图片中的二维码,并返回对应二维码数据
 
 @param image 需要识别的二维码图片
 @return 识别后的二维码数据
 */
+ (NSString * __nullable)readQRCodeWithImage:(UIImage * __nonnull)image;
+ (NSString * __nullable)readQRCodeWithImage:(UIImage * __nonnull)image shakable:(BOOL)shakable;
@end

NS_ASSUME_NONNULL_END
