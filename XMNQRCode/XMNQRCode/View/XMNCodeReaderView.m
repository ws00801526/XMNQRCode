//
//  XMNCodeReaderView.m
//  XMNQRCode
//
//  Created by XMFraker on 16/8/19.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNCodeReaderView.h"

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
        
        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:.5f];
    }
    return self;
}

@end


@interface XMNCodeReaderView ()

@property (weak, nonatomic)   UIImageView *lineView;
@property (weak, nonatomic)   UIImageView *cornerImageView;
@property (weak, nonatomic)   UIView *cornerView;

@property (copy, nonatomic)   NSArray<XMNCodeReaderMaskView *> *maskViews;

@end

@implementation XMNCodeReaderView
@synthesize renderSize = _renderSize;

static NSBundle *kXMNCodeBundle;

+ (void)load {
    kXMNCodeBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[XMNCodeReaderView class]] pathForResource:@"XMNQRCode" ofType:@"bundle"]];
}

- (instancetype)initWithRenderSize:(CGSize)renderSize {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.scaningLineColor = self.scaningCornerColor = [UIColor redColor];
        self.renderSize = renderSize;
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

- (void)dealloc {
    
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    NSLog(@" this is render frame :%@",NSStringFromCGRect(self.renderFrame));
    [self.maskViews enumerateObjectsUsingBlock:^(XMNCodeReaderMaskView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        switch (obj.tag) {
            case XMNCodeReaderMaskViewTypeTop:
                obj.frame = CGRectMake(0, 0, self.bounds.size.width, CGRectGetMinY(self.renderFrame));
                break;
            case XMNCodeReaderMaskViewTypeLeft:
                obj.frame = CGRectMake(0, self.renderFrame.origin.y, self.renderFrame.origin.x, self.renderFrame.size.height);
                break;
            case XMNCodeReaderMaskViewTypeRight:
                obj.frame = CGRectMake(CGRectGetMaxX(self.renderFrame), self.renderFrame.origin.y, self.bounds.size.width - CGRectGetMaxX(self.renderFrame), self.renderFrame.size.height);
                break;
            case XMNCodeReaderMaskViewTypeBottom:
                obj.frame = CGRectMake(0, CGRectGetMaxY(self.renderFrame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(self.renderFrame));
                break;
        }
    }];
    
    self.cornerView.frame = CGRectInset(CGRectMake(0, 0, self.renderSize.width, self.renderSize.height), 0, 0);
    self.cornerView.center = self.renderCenter;
    self.cornerImageView.frame = CGRectMake(0, 0, self.renderSize.width, self.renderSize.height);
    self.cornerImageView.center = self.renderCenter;
    
    self.lineView.frame = CGRectMake(self.renderFrame.origin.x, self.renderFrame.origin.y + 2, self.renderFrame.size.width, self.lineView.frame.size.height);
    
    [self startAnimation];
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
    
    UIView *cornerView = [[UIView alloc] initWithFrame:CGRectInset(self.renderFrame, 3, 3)];
    cornerView.backgroundColor = [UIColor clearColor];
    cornerView.layer.borderColor = [UIColor whiteColor].CGColor;
    cornerView.layer.borderWidth = 1.f;
    cornerView.layer.masksToBounds = YES;
    [self  addSubview:self.cornerView = cornerView];
    
    NSString *scaningImageName = [NSString stringWithFormat:@"scaning_frame@%dx",(int)[UIScreen mainScreen].scale];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:[kXMNCodeBundle pathForResource:scaningImageName ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    imageView.tintColor = [UIColor redColor];
    imageView.frame = self.renderFrame;
    [self addSubview:self.cornerImageView = imageView];
    
    NSString *lineImageName = [NSString stringWithFormat:@"scaning_line@%dx",(int)[UIScreen mainScreen].scale];
    UIImageView *lineImageView = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:[kXMNCodeBundle pathForResource:lineImageName ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    lineImageView.tintColor = [UIColor redColor];
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
    NSLog(@"this is animation :%@ :%@",animation.fromValue,animation.toValue);
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
