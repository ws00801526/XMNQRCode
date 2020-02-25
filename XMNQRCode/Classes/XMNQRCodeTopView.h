//
//  XMNQRCodeTopView.h
//  Pods
//
//  Created by XMFraker on 2017/7/13.
//
//

#import <UIKit/UIKit.h>

#ifndef SCREEN_WIDTH
    #define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#endif

#ifndef SCREEN_HEIGHT
    #define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#endif

#ifndef iPhoneX
    #define iPhoneX (((int)SCREEN_HEIGHT == 812) || ((int)SCREEN_WIDTH == 812) || ((int)SCREEN_HEIGHT == 896) || ((int)SCREEN_WIDTH == 896))
#endif


@interface XMNQRCodeTopView : UIView

@property (strong, nonatomic, readonly) UIButton *backButton;
@property (strong, nonatomic, readonly) UIButton *ablumButton;
@property (copy, nonatomic)   NSString *title;

- (instancetype)initWithTitle:(NSString *)title;

@end
