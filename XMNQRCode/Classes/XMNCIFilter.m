//
//  XMNCIFilter.m
//  Pods
//
//  Created by XMFraker on 2017/7/6.
//
//

#import <XMNQRCode/XMNCIFilter.h>
#import <CoreImage/CoreImage.h>

@interface XMNCIFilter ()

@property (strong, nonatomic) CIImage *CIImage;

@end

@implementation XMNCIFilter

- (instancetype)init {
    
    return [self initWithCIImage:nil];
}

- (instancetype)initWithCIImage:(CIImage *)image {
    
    if (self = [super init]) {
        self.CIImage = image ? : [CIImage emptyImage];
    }
    return self;
}

#pragma mark - Getter

- (XMNCIFilter *(^)(CGRect cropRect))cropFilter {
    
    __weak typeof(self) wSelf = self;
    return ^id(CGRect cropRect) {
        __strong typeof(wSelf) self = wSelf;
        self.CIImage = [self.CIImage imageByCroppingToRect:cropRect];
        return self;
    };
}

- (XMNCIFilter *(^)(CGSize targetSize))resizeBtimapFilter {
    
    __weak typeof(self) wSelf = self;
    return ^XMNCIFilter *(CGSize targetSize) {
        
        __strong typeof(wSelf) self = wSelf;
        /** 计算放大系数 */
        CGRect extent = CGRectIntegral(self.CIImage.extent);
        CGFloat scale = MIN(targetSize.width/extent.size.width, targetSize.height/extent.size.height);
        NSUInteger width = (int)(extent.size.width * scale);
        NSUInteger height = (int)(extent.size.height * scale);
        
        
        /** 获取对应的颜色绘制上下文 */
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGContextRef contentRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
        
        /** 绘制新图片 */
        CIContext *context = [CIContext context];
        CGImageRef imageRef = [context createCGImage:self.CIImage fromRect:extent];
        CGContextSetInterpolationQuality(contentRef, kCGInterpolationNone);
        CGContextScaleCTM(contentRef, width, height);
        CGContextDrawImage(contentRef, extent, imageRef);
        CGImageRef imageRefResized = CGBitmapContextCreateImage(contentRef);
        
        self.CIImage = [CIImage imageWithCGImage:imageRefResized];
        
        /** 释放内存 */
        CGContextRelease(contentRef);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(imageRef);
        CGImageRelease(imageRefResized);
        
        return self;
    };
}

- (XMNCIFilter *(^)(CGSize targetSize))resizeFilter {
    
    __weak typeof(self) wSelf = self;
    return ^XMNCIFilter *(CGSize targetSize) {
        __strong typeof(wSelf) self = wSelf;
        CGRect extent = CGRectIntegral(self.CIImage.extent);
        CGFloat scale = MIN(targetSize.width/extent.size.width, targetSize.height/extent.size.height);
        self.CIImage = [self.CIImage imageByApplyingTransform:CGAffineTransformMakeScale(scale, scale)];
        return self;
    };
}

- (XMNCIFilter *(^)(UIColor *firstColor, UIColor *secondColor))falseColorFilter {
    
    __weak typeof(self) wSelf = self;
    return ^XMNCIFilter *(UIColor *firstColor, UIColor *secondColor) {
        
        __strong typeof(wSelf) self = wSelf;
        CIFilter *filter = [CIFilter filterWithName:@"CIFalseColor"];
        [filter setDefaults];
        [filter setValuesForKeysWithDictionary:@{
                                                 @"inputImage" : self.CIImage ? : [NSNull null],
                                                 @"inputColor0" : [CIColor colorWithCGColor:firstColor.CGColor],
                                                 @"inputColor1" : [CIColor colorWithCGColor:secondColor.CGColor]
                                                 }];
        self.CIImage = filter.outputImage;
        return self;
    };
}

- (XMNCIFilter *(^)())alphaFilter {
    
    __weak typeof(self) wSelf = self;
    return ^XMNCIFilter *() {
        
        __strong typeof(wSelf) self = wSelf;
        CIFilter *filter = [CIFilter filterWithName:@"CIMaskToAlpha"];
        [filter setDefaults];
        [filter setValuesForKeysWithDictionary:@{@"inputImage" : self.CIImage ? : [NSNull null]}];
        self.CIImage = filter.outputImage;
        return self;
    };
}

- (XMNCIFilter *(^)(CIImage *backgroundImage, CIImage * maskImage))blendFilter {
    
    __weak typeof(self) wSelf = self;
    return ^XMNCIFilter *(CIImage *backgroundImage, CIImage * maskImage) {
        
        __strong typeof(wSelf) self = wSelf;
        CIFilter *filter = [CIFilter filterWithName:@"CIBlendWithAlphaMask"];
        [filter setDefaults];
        [filter setValuesForKeysWithDictionary:@{
                                                 @"inputImage" : self.CIImage ? : [NSNull null],
                                                 @"inputBackgroundImage" : backgroundImage ? : [NSNull null],
                                                 @"inputMaskImage" : maskImage ? : [NSNull null]
                                                 }];
        self.CIImage = filter.outputImage;
        return self;
    };
}

- (XMNCIFilter *(^)(CGAffineTransform transfrom))affineFilter {
    
    __weak typeof(self) wSelf = self;
    return ^XMNCIFilter *(CGAffineTransform transform) {
        
        __strong typeof(wSelf) self = wSelf;
        CIFilter *filter = [CIFilter filterWithName:@"CIAffineTile"];
        [filter setDefaults];
        [filter setValuesForKeysWithDictionary:@{
                                                 @"inputImage" : self.CIImage ? : [NSNull null],
                                                 @"inputTransform" : [NSValue valueWithCGAffineTransform:transform],
                                                 }];
        self.CIImage = filter.outputImage;
        return self;
    };
}

- (XMNCIFilter *(^)(CIImage *backgroundImage))colorBlendFilter {
    
    __weak typeof(self) wSelf = self;
    return ^XMNCIFilter *(CIImage *backgroundImage) {
        
        __strong typeof(wSelf) self = wSelf;
        
        CIFilter *filter = [CIFilter filterWithName:@"CIColorBlendMode"];
        [filter setDefaults];
        [filter setValuesForKeysWithDictionary:@{
                                                 @"inputImage" : self.CIImage ? : [NSNull null],
                                                 @"inputBackgroundImage" : backgroundImage ? : [NSNull null]
                                                 }];
        self.CIImage = filter.outputImage;
        return self;
    };
}

#pragma mark - Class Methods

+ (instancetype)generateConstantColor:(UIColor *)color {
    
    //    NSParameterAssert(color.CIColor);
    CIFilter *filter = [CIFilter filterWithName:@"CIConstantColorGenerator"];
    [filter setDefaults];
    [filter setValuesForKeysWithDictionary:@{@"inputColor" : [CIColor colorWithCGColor:color.CGColor]}];
    return [[XMNCIFilter alloc] initWithCIImage:filter.outputImage];
}

+ (instancetype)generateQRCode:(NSString *)info {
    
    NSData *inputData = [info dataUsingEncoding:NSISOLatin1StringEncoding];
    NSParameterAssert(inputData);
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    [filter setValuesForKeysWithDictionary:@{
                                             @"inputMessage":inputData ? : [NSNull null],
                                             @"inputCorrectionLevel":@"H",
                                             }];
    return [[XMNCIFilter alloc] initWithCIImage:filter.outputImage];
}

+ (instancetype)generateBarCode:(NSString *)info {
    
    // iOS 8.0以上的系统才支持条形码的生成，iOS8.0以下使用第三方控件生成
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 注意生成条形码的编码方式
        NSData *data = [info dataUsingEncoding:NSASCIIStringEncoding];

        CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [filter setDefaults];
        [filter setValuesForKeysWithDictionary:@{
                                                 @"inputMessage": data ? : [NSNull null],
                                                 @"inputQuietSpace" : @1,
                                                 }];
        return [[XMNCIFilter alloc] initWithCIImage:filter.outputImage];
    }else{
        
        return [[XMNCIFilter alloc] init];
    }
}

@end
