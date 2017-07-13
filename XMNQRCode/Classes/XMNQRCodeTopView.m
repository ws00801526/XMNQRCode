//
//  XMNQRCodeTopView.m
//  Pods
//
//  Created by XMFraker on 2017/7/13.
//
//

#import <XMNQRCode/XMNQRCodeTopView.h>

FOUNDATION_EXTERN NSBundle * kXMNQRCodeBundle;

@interface XMNQRCodeTopView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *ablumButton;

@end

@implementation XMNQRCodeTopView
@dynamic title;
- (instancetype)initWithTitle:(NSString *)title {
    
    if (self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64.f)]) {
        
        [self setupUI];
        self.title = title;
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

    {/** 初始化titleLabel */
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.frame = CGRectMake(100, 20, self.bounds.size.width - 200.f, 44.f);
        [self addSubview:self.titleLabel];
    }
    
    {/** 初始化backButton */
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backButton setImage:[UIImage imageNamed:@"scaning_back" inBundle:kXMNQRCodeBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        self.backButton.frame = CGRectMake(0, 20, 40.f, 44.f);
        [self addSubview:self.backButton];
    }
    
    {/** 初始化ablumButton */
     
        self.ablumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.ablumButton setTitle:@"相册" forState:UIControlStateNormal];
        [self.ablumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.ablumButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        self.ablumButton.frame = CGRectMake(self.bounds.size.width - 50.f, 20, 50.f, 44.f);
        [self addSubview:self.ablumButton];
    }
}

#pragma mark - Setter

- (void)setTitle:(NSString *)title {
    
    if (title.length >= 6) {
        self.titleLabel.text = [title substringToIndex:6];
    }else {
        self.titleLabel.text = title;
    }
}

- (NSString *)title {
    
    return self.titleLabel.text;
}

@end

