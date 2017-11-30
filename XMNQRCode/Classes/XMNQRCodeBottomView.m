//
//  XMNQRCodeBottomView.m
//  Pods
//
//  Created by XMFraker on 2017/7/13.
//
//

#import <XMNQRCode/XMNQRCodeBottomView.h>

FOUNDATION_EXTERN NSBundle * kXMNQRCodeBundle;

@interface XMNQRCodeBottomView ()

@property (strong, nonatomic) UIButton *otherButton;
@property (strong, nonatomic) UIButton *scanButton;

@end

@implementation XMNQRCodeBottomView

- (instancetype)init {
    
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    return self;
}

#pragma mark - Override Methods

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self setupUI];
}

#pragma mark - Private Methods

- (void)setupUI {
    
    {/** 初始化otherButton */
        self.otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.otherButton setImage:[UIImage imageNamed:@"scaning_other_button" inBundle:kXMNQRCodeBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.otherButton setImage:[UIImage imageNamed:@"scaning_other_button_highlight" inBundle:kXMNQRCodeBundle compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];
        self.otherButton.contentMode = UIViewContentModeCenter;
        self.otherButton.frame = CGRectMake(0, 0, self.bounds.size.width/2.f, self.bounds.size.height);
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.f].CGColor, (__bridge id)[UIColor colorWithWhite:0 alpha:1.f].CGColor];
        gradientLayer.startPoint = CGPointMake(0.5f, 0.0f);
        gradientLayer.endPoint = CGPointMake(0.5f, 1.0f);
        gradientLayer.frame = self.otherButton.frame;
        [self.layer insertSublayer:gradientLayer atIndex:0];
        
        [self addSubview:self.otherButton];
    }
    
    {/** 初始化scanButton */
        self.scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.scanButton setImage:[UIImage imageNamed:@"scaning_scan_button" inBundle:kXMNQRCodeBundle compatibleWithTraitCollection:nil] forState:UIControlStateDisabled];
        self.scanButton.contentMode = UIViewContentModeCenter;
        self.scanButton.frame = CGRectMake(self.bounds.size.width/2.f, 0, self.bounds.size.width/2.f, self.bounds.size.height);
        self.scanButton.enabled = NO;
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.f green:119.f/255.f blue:187.f/255.f alpha:.0f].CGColor, (__bridge id)[UIColor colorWithRed:0.f green:119.f/255.f blue:187.f/255.f alpha:1.0f].CGColor];
        gradientLayer.startPoint = CGPointMake(0.5f, 0.0f);
        gradientLayer.endPoint = CGPointMake(0.5f, 1.0f);
        gradientLayer.frame = self.scanButton.frame;
        [self.layer insertSublayer:gradientLayer atIndex:0];
        
        [self addSubview:self.scanButton];
    }

    self.backgroundColor = [UIColor clearColor];
}

@end
