//
//  XMNQRCodeTopView.h
//  Pods
//
//  Created by XMFraker on 2017/7/13.
//
//

#import <UIKit/UIKit.h>

@interface XMNQRCodeTopView : UIView

@property (strong, nonatomic, readonly) UIButton *backButton;
@property (strong, nonatomic, readonly) UIButton *ablumButton;
@property (copy, nonatomic)   NSString *title;

- (instancetype)initWithTitle:(NSString *)title;

@end
