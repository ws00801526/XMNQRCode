//
//  XMNQRCodeTorch.m
//  Pods
//
//  Created by XMFraker on 2017/7/7.
//
//

#import <XMNQRCode/XMNQRCodeTorch.h>
#import <XMNQRCode/XMNQRCode.h>

@interface XMNQRCodeTorch ()

@property (strong, nonatomic) UIImageView *torchView;
@property (strong, nonatomic) UILabel     *tipsLabel;

@property (assign, nonatomic) CGFloat brightness;
@property (assign, nonatomic, getter=isFirst) BOOL first;


@end

@implementation XMNQRCodeTorch
@synthesize on = _on;
@synthesize brightness = _brightness;

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

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    self.torchView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f, CGRectGetHeight(self.torchView.bounds) / 2.f);
    self.tipsLabel.frame = CGRectMake(0, self.torchView.frame.origin.y + self.torchView.frame.size.height + 4.f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.tipsLabel.bounds));
}

#pragma mark - Public Methods

- (void)updateBrightnessValue:(CGFloat)brightnessValue {
    
    if (ABS((brightnessValue - self.brightness)) < .5f) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateBrightnessInternal:) object:nil];
    [self performSelector:@selector(updateBrightnessInternal:) withObject:@(brightnessValue) afterDelay:.1f];
}

#pragma mark - Private Methods

- (void)updateBrightnessInternal:(NSNumber *)brightnessValue {
    
    self.brightness = [brightnessValue floatValue];
}

- (void)setupUI {

    self.torchView = [[UIImageView alloc] init];
    self.torchView.contentMode = UIViewContentModeCenter;
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.font = [UIFont systemFontOfSize:10.f];
    self.tipsLabel.textColor = [UIColor whiteColor];
    
    [self addSubview:self.tipsLabel];
    [self addSubview:self.torchView];
    
    self.first = YES;
    self.on = NO;
    
    [self.torchView sizeToFit];
    [self.tipsLabel sizeToFit];

    self.showTips = YES;
}

- (void)showTrochView:(BOOL)animated {
    
    if (self.hidden == NO) {
        return;
    }

    self.alpha = .0f;
    self.hidden = NO;
    [UIView animateWithDuration:animated ? .2f : CGFLOAT_MIN animations:^{

        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        if (finished) {
            [self showFirstDisplayAnimation];
        }
    }];
}

- (void)showFirstDisplayAnimation {
    
    if (self.isFirst) {
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue = [NSNumber numberWithFloat:1.f];
        opacityAnim.toValue = [NSNumber numberWithFloat:.3f];
        opacityAnim.autoreverses = YES;
        opacityAnim.duration = .3f;
        opacityAnim.repeatCount = 3.f;
        [self.torchView.layer  addAnimation:opacityAnim forKey:@"alpha"];
        self.first = NO;
    }
}

- (void)dismissTorchView:(BOOL)animated {
    
    if (self.hidden || self.on) {
        return;
    }
    
    [UIView animateWithDuration:animated ? .4f : CGFLOAT_MIN animations:^{
       
        self.alpha = .0f;
    } completion:^(BOOL finished) {
        self.hidden = finished;
    }];
}

#pragma mark - Setter

- (void)setOn:(BOOL)on {
    
    _on = on;
    self.tipsLabel.text = on ? @"轻触关闭" : @"轻触照亮";
    self.torchView.image = on ? [self onImage] : [self offImage];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setBrightness:(CGFloat)brightness {
    
    _brightness = brightness;
    if (_brightness <= -1.5f) {
        [self showTrochView:YES];
    }else {
        [self dismissTorchView:YES];
    }
}

- (void)setShowTips:(BOOL)showTips {
    
    _showTips = showTips;
    self.torchView.image = self.isOn ? [self onImage] : [self offImage];
    self.torchView.contentMode = showTips ? UIViewContentModeCenter : UIViewContentModeBottom;
    if (showTips) {
        self.tipsLabel.hidden = NO;
        self.torchView.frame = CGRectMake(0, 0, self.torchView.image.size.width, self.torchView.image.size.height);
    }else {
        self.tipsLabel.hidden = YES;
        self.torchView.frame = self.bounds;
    }
}

#pragma mark - Getter

- (BOOL)isOn {
    
    return _on;
}

- (BOOL)isFirst {
 
    return _first;
}

- (UIImage *)onImage {
    
    return [UIImage imageNamed:self.showTips ? @"scaning_torch_on" : @"scaning_torch_on2" inBundle:kXMNQRCodeBundle compatibleWithTraitCollection:nil];
}

- (UIImage *)offImage {
    
    return [UIImage imageNamed:self.showTips ? @"scaning_torch_off" : @"scaning_torch_off2" inBundle:kXMNQRCodeBundle compatibleWithTraitCollection:nil];
}

@end
