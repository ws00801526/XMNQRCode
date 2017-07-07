//
//  XMNCIFilter.h
//  Pods
//
//  Created by XMFraker on 2017/7/6.
//
//

#import <Foundation/Foundation.h>

@class CIImage;
@interface XMNCIFilter : NSObject

@property (copy, nonatomic, readonly)   XMNCIFilter *(^cropFilter)(CGRect cropRect);
@property (copy, nonatomic, readonly)   XMNCIFilter *(^resizeFilter)(CGSize targetSize);
@property (copy, nonatomic, readonly)   XMNCIFilter *(^resizeBtimapFilter)(CGSize targetSize);

@property (copy, nonatomic, readonly)   XMNCIFilter *(^falseColorFilter)(UIColor *firstColor, UIColor *secondColor);
@property (copy, nonatomic, readonly)   XMNCIFilter *(^alphaFilter)();
@property (copy, nonatomic, readonly)   XMNCIFilter *(^affineFilter)(CGAffineTransform transfrom);
@property (copy, nonatomic, readonly)   XMNCIFilter *(^blendFilter)(CIImage *backgroundImage, CIImage * maskImage);
@property (copy, nonatomic, readonly)   XMNCIFilter *(^colorBlendFilter)(CIImage *backgroundImage);


@property (strong, nonatomic, readonly) CIImage *CIImage;

- (instancetype)initWithCIImage:(CIImage *)CIImage;

+ (instancetype)generateQRCode:(NSString *)info;
+ (instancetype)generateBarCode:(NSString *)info;
+ (instancetype)generateConstantColor:(UIColor *)color;

@end
