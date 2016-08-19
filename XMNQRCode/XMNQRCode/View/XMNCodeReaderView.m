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

@property (assign, nonatomic) XMNCodeReaderMaskViewType maskType;

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

@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic)   UIImageView *lineView;
@property (weak, nonatomic)   UIImageView *cornerImageView;
@property (weak, nonatomic)   UIView *cornerView;


@property (copy, nonatomic)   NSArray<XMNCodeReaderMaskView *> *maskViews;


@end

@implementation XMNCodeReaderView

- (instancetype)init {
    
    return [self initWithRenderFrame:CGRectMake(60, 180, SCREEN_WIDTH - 120, SCREEN_WIDTH - 120)];
}

- (instancetype)initWithRenderFrame:(CGRect)renderFrame {
    
    if (self = [super init]) {
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:.01f target:self selector:@selector(updateLineViewPosition) userInfo:nil repeats:YES];
        self.renderFrame = renderFrame;
        [self setupOverlayView];
    }
    return self;
}


- (void)dealloc {
    
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));

    if (self.timer) {
        [self.timer invalidate];
    }
}
#pragma mark - Method

- (void)setupOverlayView {
    
    XMNCodeReaderMaskView *maskTopView = [[XMNCodeReaderMaskView alloc] initWithFrame:CGRectMake(self.renderFrame.origin.x, 0, SCREEN_WIDTH - self.renderFrame.origin.x * 2, self.renderFrame.origin.y)];
    maskTopView.maskType = XMNCodeReaderMaskViewTypeTop;
    [self addSubview:maskTopView];
    
    XMNCodeReaderMaskView *maskLeftView = [[XMNCodeReaderMaskView alloc] initWithFrame:CGRectMake(0, 0, self.renderFrame.origin.x, SCREEN_HEIGHT)];
    maskLeftView.maskType = XMNCodeReaderMaskViewTypeLeft;
    [self addSubview:maskLeftView];
    
    XMNCodeReaderMaskView *maskRightView = [[XMNCodeReaderMaskView alloc] initWithFrame:CGRectMake(self.renderFrame.origin.x + self.renderFrame.size.width, 0, self.renderFrame.origin.x, SCREEN_HEIGHT)];
    maskRightView.maskType = XMNCodeReaderMaskViewTypeRight;
    [self addSubview:maskRightView];
    
    XMNCodeReaderMaskView *maskBottomView = [[XMNCodeReaderMaskView alloc] initWithFrame:CGRectMake(self.renderFrame.origin.x, self.renderFrame.origin.y + self.renderFrame.size.height, SCREEN_WIDTH - self.renderFrame.origin.x * 2, SCREEN_HEIGHT - self.renderFrame.origin.y - self.renderFrame.size.height)];
    maskBottomView.maskType = XMNCodeReaderMaskViewTypeBottom;
    [self addSubview:maskBottomView];
    
    self.maskViews = @[maskTopView,maskLeftView,maskRightView,maskBottomView];
    
    UIView *cornerView = [[UIView alloc] initWithFrame:CGRectInset(self.renderFrame, 3, 3)];
    cornerView.backgroundColor = [UIColor clearColor];
    cornerView.layer.borderColor = [UIColor whiteColor].CGColor;
    cornerView.layer.borderWidth = 1.f;
    cornerView.layer.masksToBounds = YES;
    [self  addSubview:self.cornerView = cornerView];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.XMFraker.XMNQRCode"];
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    NSBundle *resourceBundle = [NSBundle bundleWithPath:[bundle pathForResource:@"XMNQRCode" ofType:@"bundle"]];
    NSString *scaningImageName = [NSString stringWithFormat:@"scaning_frame@%dx",(int)[UIScreen mainScreen].scale];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:[resourceBundle pathForResource:scaningImageName ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    imageView.tintColor = [UIColor redColor];
    imageView.frame = self.renderFrame;
    [self addSubview:self.cornerImageView = imageView];
    
    NSString *lineImageName = [NSString stringWithFormat:@"scaning_line@%dx",(int)[UIScreen mainScreen].scale];
    UIImageView *lineImageView = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:[resourceBundle pathForResource:lineImageName ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    lineImageView.tintColor = [UIColor redColor];
    [lineImageView sizeToFit];
    lineImageView.frame = CGRectMake(self.renderFrame.origin.x, self.renderFrame.origin.y + 2, self.renderFrame.size.width, lineImageView.frame.size.height);
    [self addSubview:self.lineView = lineImageView];
}

- (void)updateLineViewPosition {
    
    CGRect lineFrame = self.lineView.frame;
    lineFrame.origin.y ++ ;
    if ((lineFrame.origin.y + 2 + lineFrame.size.height) >= (self.renderFrame.size.height + self.renderFrame.origin.y)) {
        lineFrame.origin.y = self.renderFrame.origin.y + 2;
    }
    self.lineView.frame = lineFrame;
}


- (void)startAnimation {
    
    [self.timer setFireDate:[NSDate date]];
}


- (void)stopAnimation {
    
    [self.timer setFireDate:[NSDate distantFuture]];
}

#pragma mark - Setter

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    NSLog(@"setFrame :%@",NSStringFromCGRect(frame));
    
    if (frame.size.width < frame.size.height) {
        
        /** 竖屏状态 */
        [self.maskViews enumerateObjectsUsingBlock:^(XMNCodeReaderMaskView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            switch (obj.maskType) {
                case XMNCodeReaderMaskViewTypeTop:
                    obj.frame = CGRectMake(self.renderFrame.origin.x, 0, self.bounds.size.width - self.renderFrame.origin.x * 2, self.renderFrame.origin.y);
                    break;
                case XMNCodeReaderMaskViewTypeLeft:
                    obj.frame = CGRectMake(0, 0, self.renderFrame.origin.x, self.bounds.size.height);
                    break;
                case XMNCodeReaderMaskViewTypeRight:
                    obj.frame = CGRectMake(self.renderFrame.origin.x + self.renderFrame.size.width, 0, self.renderFrame.origin.x, self.bounds.size.height);
                    break;
                case XMNCodeReaderMaskViewTypeBottom:
                    obj.frame = CGRectMake(self.renderFrame.origin.x, self.renderFrame.origin.y + self.renderFrame.size.height, self.bounds.size.width - self.renderFrame.origin.x * 2, self.bounds.size.height - self.renderFrame.origin.y - self.renderFrame.size.height);
                    break;
            }
        }];

        self.cornerImageView.frame = self.renderFrame;
        self.cornerView.frame = CGRectInset(self.cornerImageView.frame, 3, 3);
        self.lineView.frame = CGRectMake(self.renderFrame.origin.x, self.renderFrame.origin.y + 2, self.renderFrame.size.width, self.lineView.frame.size.height);
    }else {
        
        /** 横屏状态 */
        [self.maskViews enumerateObjectsUsingBlock:^(XMNCodeReaderMaskView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            switch (obj.maskType) {
                case XMNCodeReaderMaskViewTypeTop:
                    obj.frame = CGRectMake(self.renderFrame.origin.y, 0, self.bounds.size.width -  2*self.renderFrame.origin.y, self.renderFrame.origin.x);
                    break;
                case XMNCodeReaderMaskViewTypeLeft:
                    obj.frame = CGRectMake(0, 0, self.renderFrame.origin.x, self.bounds.size.height);
                    break;
                case XMNCodeReaderMaskViewTypeRight:
                    obj.frame = CGRectMake(self.renderFrame.origin.x + self.renderFrame.size.width, 0, self.renderFrame.origin.x, self.bounds.size.height);
                    break;
                case XMNCodeReaderMaskViewTypeBottom:
                    obj.frame = CGRectMake(self.renderFrame.origin.x, self.renderFrame.origin.y + self.renderFrame.size.height, self.bounds.size.width - self.renderFrame.origin.x * 2, self.bounds.size.height - self.renderFrame.origin.y - self.renderFrame.size.height);
                    break;
            }
        }];
        
        self.cornerImageView.frame = CGRectMake(self.renderFrame.origin.y , self.renderFrame.origin.x, self.renderFrame.size.width, self.renderFrame.size.height);
        self.cornerView.frame = CGRectInset(self.cornerImageView.frame, 3, 3);
        self.lineView.frame = CGRectMake(self.renderFrame.origin.y, self.renderFrame.origin.x + 2, self.renderFrame.size.height, self.lineView.frame.size.height);
    }
}

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

@end
