//
//  ViewController.m
//  XMNQRCodeDemo
//
//  Created by XMFraker on 2017/7/6.
//  Copyright © 2017年 XMFraker. All rights reserved.
//

#import "ViewController.h"
#import "XMNSampleController.h"
#import "XMNPageSampleController.h"

#import <XMNQRCode/XMNQRCode.h>
#import <XMNQRCode/XMNQRCodeReaderController.h>

#import <SafariServices/SafariServices.h>

@interface ViewController () <XMNQRCodeReaderControllerDelegate>

@property (strong, nonatomic) XMNQRCodeBuilder *builder;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"扫描" style:UIBarButtonItemStylePlain target:self action:@selector(handleScanQRCodeAction)];
}

- (void)handleScanQRCodeAction {
    
    __weak typeof(self) wSelf = self;
    XMNQRCodeReaderController *controller = [[XMNQRCodeReaderController alloc] initWithCompletionHandler:^(NSString *result) {
        __strong typeof(wSelf) self = wSelf;
//        if (![result hasPrefix:@"http"]) {
//            [self.navigationController popViewControllerAnimated:YES];
//        } else {
//            SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:result]];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
    }];
    controller.reportAvailable = NO;
    controller.albumAvailable = NO;
    controller.delegate = self;
    controller.bottomAvailable = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
#if DEBUG
    NSLog(@"%@ is %@ing", self, NSStringFromSelector(_cmd));
#endif
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - XMNQRCodeReaderControllerDelegate

- (void)codeReaderControllerShowReportController:(XMNQRCodeReaderController *)controller completionHandler:(void (^)(void))completionHandler {
    NSLog(@"need report code unavailable");
}

#pragma mark - Private Methods

- (void)configQRCodeConfigurationAtIndexPath:(NSIndexPath *)indexPath {
    
    self.builder = [[XMNQRCodeBuilder alloc] initWithInfo:@"https://www.baidu.com" size:CGSizeMake(300, 300)];
    switch (indexPath.row) {
        case 0:
            break;
        case 1:
            self.builder.outerColor = [UIColor greenColor];
            break;
        case 2:
            self.builder.innerColor = [UIColor redColor];
            break;
        case 3:
            self.builder.outerStyle = @[@{@(XMNQRCodeBuilderPositionTopLeft):[UIImage imageNamed:@"OuterPosition"]},@{@(XMNQRCodeBuilderPositionTopRight):[UIImage imageNamed:@"OuterPosition"]}];
            self.builder.topColor = [UIColor colorWithRed:100/255.f green:145/255.f blue:193/255.f alpha:1.f];
            break;
        case 4:
            self.builder.outerColor = [UIColor brownColor];
            self.builder.innerStyle = @[
                                        @{@(XMNQRCodeBuilderPositionTopLeft):[UIImage imageNamed:@"Polygon"]},
                                        @{@(XMNQRCodeBuilderPositionTopRight):[UIImage imageNamed:@"Polygon"]},
                                        @{@(XMNQRCodeBuilderPositionBottomLeft):[UIColor grayColor]}
                                            ];
            break;
        case 5:
            self.builder.centerImage = [UIImage imageNamed:@"Avatar"];
            break;
        case 6:
            self.builder.removeQuietZone = YES;
            self.builder.backgroundColor = [UIColor yellowColor];
            break;
        case 7:
            self.builder.topColor = [UIColor cyanColor];
            break;
        case 8:
            self.builder.maskImage = [UIImage imageNamed:@"Top"];
            break;
        case 9:
        {
            self.builder = [[XMNQRCodeBuilder alloc] initWithInfo:@"20202020200019201" size:CGSizeMake(315, 80)];
            self.builder.appendBarCodeText = YES;
            self.builder.barCodeTextPadding = 10.f;
//            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//            style.alignment = NSTextAlignmentCenter;
//            style.lineBreakMode = NSLineBreakByWordWrapping;
//            self.builder.barCodeTextStyle = @{NSFontAttributeName : [UIFont systemFontOfSize:12.f],
//                                              NSForegroundColorAttributeName : [UIColor blueColor],
//                                              NSParagraphStyleAttributeName : style};
        }
//            self.builder.topColor = [UIColor colorWithWhite:1.f alpha:.8f];
            self.builder.bottomColor = [UIColor colorWithWhite:1.f alpha:.8f];
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate & UITableViewSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self samples] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [[self samples] objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [self samples].count - 1) {
        
        /** 跳转到page view controller */
        XMNPageSampleController *sampleC = [self.storyboard instantiateViewControllerWithIdentifier:@"XMNPageSampleController"];
        [self.navigationController pushViewController:sampleC animated:YES];
        return;
    }
    
    [self configQRCodeConfigurationAtIndexPath:indexPath];
    
    XMNSampleController *sampleC = [self.storyboard instantiateViewControllerWithIdentifier:@"XMNSampleController"];
    sampleC.image = self.builder.QRCodeImage;
    sampleC.barcodeImage = self.builder.barCodeImage;
//    __weak typeof(self) wSelf = self;
//    NSTimer *timer = [NSTimer timerWithTimeInterval:2.f repeats:YES block:^(NSTimer * _Nonnull timer) {
//        __strong typeof(wSelf) self = wSelf;
//        self.builder = [[XMNQRCodeBuilder alloc] initWithInfo:@"20202020200019201" size:CGSizeMake(315, 80)];
//        [self.builder generateCodeImageWithMode:XMNQRCodeBuilderCodeModeQRCode completionHandler:^(UIImage * _Nullable image) {
//            
//            NSLog(@"create success ? :%@", image);
//        }];
//    }];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//    [timer fire];
    [self.navigationController pushViewController:sampleC animated:YES];
}

#pragma mark - Getter

- (NSArray<NSString *> *)samples {
    
    return @[@"Default", @"Outer Color", @"Inner Color", @"Outer Style", @"Inner Style", @"Center Image", @"Bottom Color", @"Top Color", @"Top Image", @"bar code", @"Examples"];
}

@end
