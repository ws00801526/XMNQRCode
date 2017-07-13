//
//  XMNQRCodeReaderView.m
//  XMNQRCode
//
//  Created by XMFraker on 16/8/19.
//  Copyright © 2016年 XMFraker. All rights reserved.
//


#import <XMNQRCode/XMNQRCode.h>
#import <XMNQRCode/XMNQRCodeReaderView.h>

typedef NS_ENUM(NSUInteger, XMNCodeReaderMaskViewType) {
    XMNCodeReaderMaskViewTypeTop,
    XMNCodeReaderMaskViewTypeLeft,
    XMNCodeReaderMaskViewTypeRight,
    XMNCodeReaderMaskViewTypeBottom
};

/**
 *  @brief 扫描区域的蒙版层, 使用黑色半透明背景色
 */
@interface XMNCodeReaderMaskView : UIView

@end

@implementation XMNCodeReaderMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:.6f];
    }
    return self;
}

@end


@interface XMNQRCodeReaderView ()

@property (weak, nonatomic)   UIImageView *lineView;
@property (weak, nonatomic)   UIImageView *cornerImageView;
@property (weak, nonatomic)   UIView *cornerView;

@property (copy, nonatomic)   NSArray<XMNCodeReaderMaskView *> *maskViews;

@end

NSBundle * kXMNQRCodeBundle;

@implementation XMNQRCodeReaderView
@synthesize renderSize = _renderSize;

+ (void)load {
    
    kXMNQRCodeBundle = [NSBundle bundleForClass:[self class]];
}

- (instancetype)initWithRenderSize:(CGSize)renderSize {
    
    if (self = [super initWithFrame:CGRectZero]) {

        self.scaningLineColor = self.scaningCornerColor = [UIColor redColor];
        self.renderSize = renderSize;
        self.renderOffset = UIOffsetMake(3.f, 3.f);
        [self setupOverlayView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    return [self initWithRenderSize:CGSizeZero];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    return [self initWithRenderSize:CGSizeZero];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self.maskViews enumerateObjectsUsingBlock:^(XMNCodeReaderMaskView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        switch (obj.tag) {
            case XMNCodeReaderMaskViewTypeTop:
                obj.frame = CGRectMake(0, 0, self.bounds.size.width, CGRectGetMinY(self.renderFrame) + self.renderOffset.vertical);
                break;
            case XMNCodeReaderMaskViewTypeLeft:
                obj.frame = CGRectMake(0, self.renderFrame.origin.y + self.renderOffset.vertical, self.renderFrame.origin.x + self.renderOffset.horizontal, self.renderFrame.size.height - self.renderOffset.vertical*2);
                break;
            case XMNCodeReaderMaskViewTypeRight:
                obj.frame = CGRectMake(CGRectGetMaxX(self.renderFrame) - self.renderOffset.horizontal, self.renderFrame.origin.y + self.renderOffset.vertical, self.bounds.size.width - CGRectGetMaxX(self.renderFrame) + self.renderOffset.horizontal, self.renderFrame.size.height - self.renderOffset.vertical * 2);
                break;
            case XMNCodeReaderMaskViewTypeBottom:
                obj.frame = CGRectMake(0, CGRectGetMaxY(self.renderFrame) - self.renderOffset.vertical, self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(self.renderFrame) + self.renderOffset.vertical);
                break;
        }
    }];
    
    /** 更新cornerView.frame.size */
    self.cornerView.frame = CGRectMake(0, 0, self.renderSize.width - self.renderOffset.horizontal * 2, self.renderSize.height - self.renderOffset.vertical * 2);
    self.cornerView.center = self.renderCenter;
    
    self.cornerImageView.frame = CGRectMake(0, 0, self.renderSize.width, self.renderSize.height);
    self.cornerImageView.center = self.renderCenter;
    
    self.lineView.frame = CGRectMake(self.renderFrame.origin.x + self.renderOffset.horizontal, self.renderFrame.origin.y + 2, self.renderFrame.size.width - 2 * self.renderOffset.horizontal, self.lineView.frame.size.height);
    
    [self startAnimation];
}

- (void)startScaleAnimation {
    
    self.lineView.hidden = YES;
    self.cornerView.transform = CGAffineTransformMakeScale(.3f, .3f);
    self.cornerImageView.transform = CGAffineTransformMakeScale(.3f, .3f);
    
    [UIView animateWithDuration:.3f animations:^{
       
        self.cornerView.transform = CGAffineTransformIdentity;
        self.cornerImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.lineView.hidden = NO;
    }];
}

#pragma mark - Method

- (void)setupOverlayView {
    
    XMNCodeReaderMaskView *maskTopView = [[XMNCodeReaderMaskView alloc] initWithFrame:CGRectZero];
    maskTopView.tag = XMNCodeReaderMaskViewTypeTop;
    [self addSubview:maskTopView];
    
    XMNCodeReaderMaskView *maskLeftView = [[XMNCodeReaderMaskView alloc] initWithFrame:CGRectZero];
    maskLeftView.tag = XMNCodeReaderMaskViewTypeLeft;
    [self addSubview:maskLeftView];
    
    XMNCodeReaderMaskView *maskRightView = [[XMNCodeReaderMaskView alloc] initWithFrame:CGRectZero];
    maskRightView.tag = XMNCodeReaderMaskViewTypeRight;
    [self addSubview:maskRightView];
    
    XMNCodeReaderMaskView *maskBottomView = [[XMNCodeReaderMaskView alloc] initWithFrame:CGRectZero];
    maskBottomView.tag = XMNCodeReaderMaskViewTypeBottom;
    [self addSubview:maskBottomView];
    
    self.maskViews = @[maskTopView,maskLeftView,maskRightView,maskBottomView];
    
    UIView *cornerView = [[UIView alloc] initWithFrame:CGRectInset(self.renderFrame, 0, 0)];
    cornerView.backgroundColor = [UIColor clearColor];
    cornerView.layer.borderColor = [UIColor whiteColor].CGColor;
    cornerView.layer.borderWidth = CGFLOAT_MIN;
    cornerView.layer.masksToBounds = YES;
    [self addSubview:self.cornerView = cornerView];
    
    NSString *scaningImageName = [NSString stringWithFormat:@"scaning_frame@%dx",(int)[UIScreen mainScreen].scale];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:[kXMNQRCodeBundle pathForResource:scaningImageName ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    imageView.frame = self.renderFrame;
    [self addSubview:self.cornerImageView = imageView];
    
    NSString *lineImageName = [NSString stringWithFormat:@"scaning_line@%dx",(int)[UIScreen mainScreen].scale];
    UIImageView *lineImageView = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:[kXMNQRCodeBundle pathForResource:lineImageName ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [lineImageView sizeToFit];
    lineImageView.frame = CGRectMake(self.renderFrame.origin.x, self.renderFrame.origin.y + 2, self.renderFrame.size.width, lineImageView.frame.size.height);
    [self addSubview:self.lineView = lineImageView];
}

- (void)updateLineViewPosition {
    
    CGRect lineFrame = self.lineView.frame;

    if (lineFrame.size.height + lineFrame.origin.y + 20 >= self.renderFrame.size.height + self.renderFrame.origin.y) {
        lineFrame.origin.y ++ ;
    }else {
        lineFrame.origin.y += 2 ;
    }
    if ((lineFrame.origin.y + 2 + lineFrame.size.height) >= (self.renderFrame.size.height + self.renderFrame.origin.y)) {
        lineFrame.origin.y = self.renderFrame.origin.y + 2;
    }
    self.lineView.frame = lineFrame;
}


- (void)startAnimation {
    
    CABasicAnimation *animation = (CABasicAnimation *)[self.lineView.layer animationForKey:@"linePositionY"];
    int fromY = self.renderFrame.origin.y + 2;
    int toY = self.renderFrame.origin.y - 4  + self.renderFrame.size.height;
    
    if (fromY <= 0 || toY <= 0) {
        return;
    }
    if (animation) {
        if ([animation.fromValue integerValue] == fromY && [animation.toValue integerValue] == toY) {
            return;
        }
        [self.lineView.layer removeAnimationForKey:@"linePositionY"];
    }
    
    animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.duration = 2.f;
    animation.repeatCount = NSUIntegerMax;
    animation.fromValue = @(self.renderFrame.origin.y + 2);
    animation.toValue = @(self.renderFrame.origin.y - 4  + self.renderFrame.size.height);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    animation.autoreverses = NO;
    [self.lineView.layer addAnimation:animation forKey:@"linePositionY"];
    if ([animation.toValue integerValue] - [animation.fromValue integerValue] <= 10) {
        return;
    }
}


- (void)stopAnimation {
    
    [self.lineView.layer removeAllAnimations];
}

#pragma mark - Setter

- (void)setScaningCornerColor:(UIColor *)scaningCornerColor {
    
    _scaningCornerColor = scaningCornerColor;
    self.cornerImageView.tintColor = scaningCornerColor;
    [self.lineView setNeedsDisplay];
}

- (void)setScaningLineColor:(UIColor *)scaningLineColor {
    
    _scaningLineColor = scaningLineColor;
    self.lineView.tintColor = scaningLineColor;
    [self.lineView setNeedsDisplay];
}

- (void)setCenterOffsetPoint:(CGPoint)centerOffsetPoint {
    
    _centerOffsetPoint = centerOffsetPoint;
    [self setNeedsLayout];
}

- (void)setRenderSize:(CGSize)renderSize {
    
    _renderSize = renderSize;
    [self setNeedsLayout];
}

#pragma mark - Getter

- (CGSize)renderSize {
    
    if (CGSizeEqualToSize(_renderSize, CGSizeZero)) {
        if (self.bounds.size.width > self.bounds.size.height) {
            return CGSizeMake(MAX(0, self.bounds.size.height - 160), MAX(0, self.bounds.size.height - 160));
        }else {
            return CGSizeMake(MAX(0, self.bounds.size.width - 160), MAX(0, self.bounds.size.width - 160));
        }
    }
    return _renderSize;
}

- (CGPoint)renderCenter {
    
    return CGPointMake(self.center.x + self.centerOffsetPoint.x, self.center.y + self.centerOffsetPoint.y);
}

- (CGRect)renderFrame {
    
    CGRect renderFrame = {CGPointMake(self.renderCenter.x - self.renderSize.width/2, self.renderCenter.y - self.renderSize.height/2),
        self.renderSize};
    return renderFrame;
}
@end
