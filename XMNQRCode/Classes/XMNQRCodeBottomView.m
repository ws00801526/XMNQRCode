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
        self.otherButton.contentMode = UIViewContentModeCenter;
        self.otherButton.frame = CGRectMake(0, 0, self.bounds.size.width/2.f, self.bounds.size.height);
        [self addSubview:self.otherButton];
    }
    
    {/** 初始化scanButton */
        self.scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.scanButton setImage:[UIImage imageNamed:@"scaning_scan_button" inBundle:kXMNQRCodeBundle compatibleWithTraitCollection:nil] forState:UIControlStateDisabled];
        self.scanButton.contentMode = UIViewContentModeCenter;
        self.scanButton.frame = CGRectMake(self.bounds.size.width/2.f, 0, self.bounds.size.width/2.f, self.bounds.size.height);
        self.scanButton.enabled = NO;
        [self addSubview:self.scanButton];
    }

    self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:.5f];
}

@end
