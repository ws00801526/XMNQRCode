//
//  XMNQRCodeBuilder.m
//  Pods
//
//  Created by XMFraker on 2017/7/6.
//
//

#import <XMNQRCode/XMNQRCodeBuilder.h>
#import <XMNQRCode/XMNCIFilter.h>

@interface XMNQRCodeBuilder ()
{
    BOOL _needsUpdate;
}
/** 需要生成对应二维码,条形码的信息 */
@property (copy, nonatomic)   NSString *info;
/** 生成的二维码大小 */
@property (assign, nonatomic) CGSize size;
/** 当前QRCode的version */
@property (assign, nonatomic, readonly) NSInteger version;
/** 生成的二维码图片 */
@property (strong, nonatomic) UIImage *QRCodeImage;
/** 生成的条形码图片 */
@property (strong, nonatomic) UIImage *barCodeImage;


@end

@implementation XMNQRCodeBuilder (XMNQRCodeBuilderPrivate)

- (void)setNeedsUpdate {
    
    _needsUpdate = YES;
}

- (NSInteger)QRCodeVersion {
        
    CIImage *originImage = [XMNCIFilter generateQRCode:self.info].CIImage;
    return (NSInteger)((originImage.extent.size.width - 23.f) / 4.f  + 1);
}

- (CIImage *)generateAlphaQRCode {
    
    return [XMNCIFilter generateQRCode:self.info].resizeFilter(self.size).falseColorFilter([UIColor blackColor], [UIColor whiteColor]).alphaFilter().CIImage;
}

- (CIImage *)generateReverseAlphaQRCode {

    return [XMNCIFilter generateQRCode:self.info].resizeFilter(self.size).falseColorFilter([UIColor whiteColor], [UIColor blackColor]).alphaFilter().CIImage;
}

- (void)updateOuterPositionColor:(UIColor *)color
                        position:(XMNQRCodeBuilderPosition)position {
    
    UIBezierPath *path = [XMNQRCodeBuilder outerPositionPathWithOriginSize:self.size
                                                                   version:self.version
                                                                  position:position];
    [color setStroke];
    [path stroke];
}

- (void)updateOuterPositionStyle:(UIImage *)image
                        position:(XMNQRCodeBuilderPosition)position {
    
    CGRect rect = [XMNQRCodeBuilder outerPositionRectWithOriginSize:self.size
                                                            version:self.version
                                                           position:position];
    [image drawInRect:rect];
}

- (void)updateInnerPositionStyle:(UIImage *)image
                        position:(XMNQRCodeBuilderPosition)position {

    CGRect rect = [XMNQRCodeBuilder innerPositionRectWithOriginSize:self.size
                                                            version:self.version
                                                           position:position];
    [image drawInRect:rect];
}

- (void)clearInnerPositionStyles:(NSArray<NSDictionary<NSNumber *,UIImage *> *> *)styles {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSParameterAssert(context);
    for (NSDictionary *style in styles) {
        
        CGRect rect = [XMNQRCodeBuilder innerPositionRectWithOriginSize:self.size
                                                                version:self.version
                                                               position:[[[style allKeys] firstObject] integerValue]];
        CGContextAddRect(context, rect);
    }
    
    CGContextClip(context);
    CGContextClearRect(context, CGRectMake(0, 0, self.size.width, self.size.height));
}


- (void)clearOuterPositionStyles:(NSArray<NSDictionary<NSNumber *,UIImage *> *> *)styles {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSParameterAssert(context);
    for (NSDictionary *style in styles) {
        
        CGRect rect = [XMNQRCodeBuilder outerPositionRectWithOriginSize:self.size
                                                                version:self.version
                                                               position:[[[style allKeys] firstObject] integerValue]];
        CGContextAddRect(context, rect);
    }
    
    CGContextClip(context);
    CGContextClearRect(context, CGRectMake(0, 0, self.size.width, self.size.height));
}

+ (CGRect)innerPositionRectWithOriginSize:(CGSize)size
                                  version:(NSInteger)version
                                 position:(XMNQRCodeBuilderPosition)position {

    CGFloat leftMargin = (size.width * 3 / (CGFloat)((version - 1) * 4 + 23));
    CGFloat centerImageWidth = size.width * 7 / (CGFloat)((version - 1) * 4 + 23);
    CGRect rect = CGRectInset(CGRectIntegral(CGRectMake(leftMargin, leftMargin, leftMargin, leftMargin)), -1.f, -1.f);

    switch (position) {
        case XMNQRCodeBuilderPositionTopLeft:
            return rect;
        case XMNQRCodeBuilderPositionTopRight:
            return CGRectOffset(rect, (size.width - leftMargin * 3), .0f);
        case XMNQRCodeBuilderPositionBottomLeft:
            return CGRectOffset(rect, 0.f, (size.width - leftMargin * 3));
        case XMNQRCodeBuilderPositionCenter:
            return CGRectOffset(CGRectMake(0, 0, centerImageWidth, centerImageWidth), (size.width/2 - centerImageWidth/2), (size.width/2 - centerImageWidth/2));
        default:
            return CGRectZero;
    }
}

+ (CGRect)outerPositionRectWithOriginSize:(CGSize)size
                                  version:(NSInteger)version
                                 position:(XMNQRCodeBuilderPosition)position {

    CGFloat pathWidth = (size.width / (CGFloat)((version - 1) * 4 + 23));
    CGFloat outerPositionWidth = pathWidth * 7.f;
    CGRect rect = CGRectInset(CGRectIntegral(CGRectMake(pathWidth, pathWidth, outerPositionWidth, outerPositionWidth)), -1.f, -1.f);
    
    switch (position) {
        case XMNQRCodeBuilderPositionTopLeft:
            return rect;
        case XMNQRCodeBuilderPositionTopRight:
            return CGRectOffset(rect, (size.width - outerPositionWidth - pathWidth * 2), 0.f);
        case XMNQRCodeBuilderPositionBottomLeft:
            return CGRectOffset(rect, 0.f, (size.width - outerPositionWidth - pathWidth * 2));
        default:
            return CGRectZero;
    }
}

+ (UIBezierPath *)outerPositionPathWithOriginSize:(CGSize)size
                                          version:(NSInteger)version
                                         position:(XMNQRCodeBuilderPosition)position {
    
    CGFloat pathWidth = (size.width / (CGFloat)((version - 1) * 4 + 23));
    CGFloat outerPositionWidth = pathWidth * 6.f;
    CGRect rect = CGRectInset(CGRectIntegral(CGRectMake(pathWidth * 1.5f, pathWidth * 1.5f, outerPositionWidth, outerPositionWidth)), -1.f, -1.f);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    switch (position) {
        case XMNQRCodeBuilderPositionTopLeft:
            path = [XMNQRCodeBuilder bezierPathWithOriginRect:rect];
            break;
        case XMNQRCodeBuilderPositionTopRight:
            rect = CGRectOffset(rect, (size.width - outerPositionWidth - pathWidth * 1.5f * 2.f), .0f);
            path = [XMNQRCodeBuilder bezierPathWithOriginRect:rect];
            break;
        case XMNQRCodeBuilderPositionBottomLeft:
            rect = CGRectOffset(rect, .0f, (size.width - outerPositionWidth - pathWidth * 1.5f * 2.f));
            path = [XMNQRCodeBuilder bezierPathWithOriginRect:rect];
            break;
        case XMNQRCodeBuilderPositionQuietZone:
            path = [XMNQRCodeBuilder bezierPathWithOriginRect:CGRectMake(pathWidth * .5f, pathWidth * .5f, size.width - pathWidth, size.height - pathWidth)];
            path.lineWidth = pathWidth + [UIScreen mainScreen].scale;
            break;
        default:
            break;
    }
    path.lineWidth = path.lineWidth > 1.f ? path.lineWidth : (pathWidth + 3.f);
    path.lineCapStyle = kCGLineCapSquare;
    return path;
}

+ (UIBezierPath *)bezierPathWithOriginRect:(CGRect)rect {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:rect.origin];
    [path addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)];
    [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
    [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    [path addLineToPoint:rect.origin];
    return path;
}

@end


@implementation XMNQRCodeBuilder
@synthesize barCodeTextStyle = _barCodeTextStyle;

#pragma mark - Life Cycle

- (instancetype)initWithInfo:(NSString *)info
                        size:(CGSize)size {
    
    if (self = [super init]) {
        
        self.info = [info copy];
        self.size = size;
        
        self.topColor = [UIColor blackColor];
        self.backgroundColor = self.bottomColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Public Methods

- (void)generateCodeImageWithMode:(XMNQRCodeBuilderCodeMode)mode
                completionHandler:(nullable void(^)(UIImage * __nullable image))completionHandler {
    
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(wSelf) self = wSelf;
        UIImage *ret = mode == XMNQRCodeBuilderCodeModeBarCode ? self.barCodeImage : self.QRCodeImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler ? completionHandler(ret) : nil;
        });
    });
}

#pragma mark - Setter

- (void)setTopColor:(UIColor *)topColor {
    
    _topColor = topColor;
    [self setNeedsUpdate];
}

- (void)setBottomColor:(UIColor *)bottomColor {
    
    _bottomColor = bottomColor;
    [self setNeedsUpdate];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    
    _backgroundColor = backgroundColor;
    [self setNeedsUpdate];
}

- (void)setInnerColor:(UIColor *)innerColor {
    
    _innerColor = innerColor;
    [self setNeedsUpdate];
}

- (void)setOuterColor:(UIColor *)outerColor {
    
    _outerColor = outerColor;
    [self setNeedsUpdate];
}

- (void)setInnerStyle:(NSArray<NSDictionary<NSNumber *,id> *> *)innerStyle {
    
    _innerStyle = [innerStyle copy];
    [self setNeedsUpdate];
}

- (void)setOuterStyle:(NSArray<NSDictionary<NSNumber *,id> *> *)outerStyle {
    
    _outerStyle = [outerStyle copy];
    [self setNeedsUpdate];
}

- (void)setCenterImage:(UIImage *)centerImage {
    
    _centerImage = centerImage;
    [self setNeedsUpdate];
}

- (void)setMaskImage:(UIImage *)maskImage {
    
    _maskImage = maskImage;
    [self setNeedsUpdate];
}

- (void)setAppendBarCodeText:(BOOL)appendBarCodeText {
    
    _appendBarCodeText = appendBarCodeText;
    [self setNeedsUpdate];
}

- (void)setBarCodeTextStyle:(NSDictionary *)barCodeTextStyle {
    
    _barCodeTextStyle = barCodeTextStyle;
    [self setNeedsUpdate];
}

- (void)setBarCodeTextPadding:(CGFloat)barCodeTextPadding {
    
    _barCodeTextPadding = barCodeTextPadding;
    [self setNeedsUpdate];
}

#pragma mark - Getter

- (NSInteger)version {
    
    return [self QRCodeVersion];
}

- (UIImage *)QRCodeImage {
    
    if (!_QRCodeImage || _needsUpdate) {
        
        XMNCIFilter *filter;
        
        if (self.maskImage) {
            
            filter = [[XMNCIFilter alloc] initWithCIImage:[CIImage imageWithCGImage:self.maskImage.CGImage]].resizeFilter(self.size).blendFilter(filter.CIImage, [self generateAlphaQRCode]);
        }else {
            
            filter = [XMNCIFilter generateQRCode:self.info].resizeFilter(self.size).falseColorFilter(self.topColor, self.bottomColor);
        }
        
        UIImage *ret = [UIImage imageWithCIImage:filter.CIImage ? : [CIImage emptyImage]];
        
        UIGraphicsBeginImageContextWithOptions(ret.size, NO, [UIScreen mainScreen].scale);
        [ret drawInRect:CGRectMake(0, 0, ret.size.width, ret.size.height)];
        
        if (self.centerImage) {
            
            [self updateInnerPositionStyle:self.centerImage position:XMNQRCodeBuilderPositionCenter];
        }
        
        {/** 配置二维码四周的圆圈外圈颜色, 样式 */
            
            if (self.outerColor && (!self.outerStyle || !self.outerStyle.count)) {
                
                [self updateOuterPositionColor:self.outerColor position:XMNQRCodeBuilderPositionTopLeft];
                [self updateOuterPositionColor:self.outerColor position:XMNQRCodeBuilderPositionTopRight];
                [self updateOuterPositionColor:self.outerColor position:XMNQRCodeBuilderPositionBottomLeft];
            }else if (self.outerStyle && self.outerStyle.count) {
                
                [self clearOuterPositionStyles:self.outerStyle];
                for (NSDictionary *style in self.outerStyle) {
                    NSParameterAssert([[[style allKeys] firstObject] respondsToSelector:@selector(integerValue)]);
                    NSParameterAssert([[[style allValues] firstObject] isKindOfClass:[UIImage class]]);
                    XMNQRCodeBuilderPosition position = [[[style allKeys] firstObject] integerValue];
                    id styleValue = [[style allValues] firstObject];
                    if ([styleValue isKindOfClass:[UIImage class]]) {
                        [self updateOuterPositionStyle:styleValue position:position];
                    }
                }
            }
        }
        
        {/** 配置二维码四周的圆圈内圈颜色或者样式 */
            if (self.innerColor && (!self.innerStyle || !self.innerStyle.count)) {
                
                CIImage *innerCIImage = [XMNCIFilter generateConstantColor:self.innerColor].cropFilter(CGRectMake(0, 0, 2.f, 2.f)).CIImage;
                UIImage *innerImage = [UIImage imageWithCIImage:innerCIImage];
                
                [self updateInnerPositionStyle:innerImage position:XMNQRCodeBuilderPositionTopLeft];
                [self updateInnerPositionStyle:innerImage position:XMNQRCodeBuilderPositionTopRight];
                [self updateInnerPositionStyle:innerImage position:XMNQRCodeBuilderPositionBottomLeft];
            }
            
            if (self.innerStyle && self.innerStyle.count) {
                
                [self clearInnerPositionStyles:self.innerStyle];
                
                for (NSDictionary *style in self.innerStyle) {
                    
                    NSParameterAssert([[[style allKeys] firstObject] respondsToSelector:@selector(integerValue)]);
                    NSParameterAssert([[[style allValues] firstObject] isKindOfClass:[UIImage class]] || [[[style allValues] firstObject] isKindOfClass:[UIColor class]]);
                    
                    XMNQRCodeBuilderPosition position = [[[style allKeys] firstObject] integerValue];
                    id styleValue = [[style allValues] firstObject];
                    if ([styleValue isKindOfClass:[UIImage class]]) {
                        [self updateInnerPositionStyle:styleValue position:position];
                    }else if ([styleValue isKindOfClass:[UIColor class]]) {
                        CIImage *innerCIImage = [XMNCIFilter generateConstantColor:styleValue].cropFilter(CGRectMake(0, 0, 2.f, 2.f)).CIImage;
                        UIImage *innerImage = [UIImage imageWithCIImage:innerCIImage];
                        [self updateInnerPositionStyle:innerImage position:position];
                    }
                }
            }
        }
        
        if (self.backgroundColor != [UIColor whiteColor]) {
            
            [self updateOuterPositionColor:self.backgroundColor position:XMNQRCodeBuilderPositionQuietZone];
        }
        
        ret = UIGraphicsGetImageFromCurrentImageContext();
        
        if (self.removeQuietZone) {
            
            CGFloat offset = self.size.width / (CGFloat)((self.version - 1) * 4 + 23);
            CGRect rect = CGRectInset(CGRectMake(0, 0, self.size.width, self.size.height), offset, offset);
            CGRect scaleRect = CGRectMake(rect.origin.x * ret.scale, rect.origin.y * ret.scale, rect.size.width * ret.scale, rect.size.height * ret.scale);
            ret = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(ret.CGImage, scaleRect) scale:ret.scale orientation:ret.imageOrientation];
        }
        UIGraphicsEndImageContext();
        
        _QRCodeImage = ret;
        _needsUpdate = NO;
    }
    return _QRCodeImage;
}

- (UIImage *)barCodeImage {
 
    if (!_barCodeImage || _needsUpdate) {
        
        XMNCIFilter *filter = [XMNCIFilter generateBarCode:self.info].resizeFilter(self.size).falseColorFilter(self.topColor, self.bottomColor);

        if (self.appendBarCodeText) {
            
            UIImage *image = [UIImage imageWithCIImage:filter.CIImage ? : [CIImage emptyImage]];
            
            CGFloat textHeight = [self.info sizeWithAttributes:self.barCodeTextStyle].height + 5.f;
            
            CGSize size = CGSizeMake(image.size.width, image.size.height + textHeight + self.barCodeTextPadding);
            UIGraphicsBeginImageContextWithOptions(size, false, [UIScreen mainScreen].scale);
            [image drawAtPoint:CGPointZero];
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextDrawPath(context, kCGPathStroke);
            [self.info drawInRect:CGRectMake(0, image.size.height + self.barCodeTextPadding, size.width, textHeight) withAttributes:self.barCodeTextStyle];

            _barCodeImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }else {
            _barCodeImage = [UIImage imageWithCIImage:filter.CIImage ? : [CIImage emptyImage]];
        }
        _needsUpdate = NO;
    }
    return _barCodeImage;
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

- (NSDictionary *)barCodeTextStyle {
    
    if (!_barCodeTextStyle) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        _barCodeTextStyle = @{NSFontAttributeName : [UIFont systemFontOfSize:18.f],
                              NSForegroundColorAttributeName : self.topColor,
                              NSParagraphStyleAttributeName : [style copy]};
    }
    return _barCodeTextStyle;
}

@end
