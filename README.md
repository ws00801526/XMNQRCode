# XMNQRCode
基于AVFoundation封装的一个 二维码扫描页面 支持扫描区域修改



### 使用方法

1. 编译XMNQRCode.framework 拖入自己工程使用


```
    XMNCodeReaderController *codeReaderC = [[XMNCodeReaderController alloc] init];
    
    /** renderSize 控制扫描区域大小 */
//    codeReaderC.renderSize = CGSizeMake(200, 200);
    
    /** centerOffsetPoint 控制扫描区域的中心点偏移*/
//    codeReaderC.centerOffsetPoint = CGPointMake(0, 50);
    
    /** 修改扫描线颜色 */
    codeReaderC.scaningLineColor = [UIColor redColor];
    
    /** 修改扫描框颜色 */
    codeReaderC.scaningCornerColor = [UIColor yellowColor];

    [codeReaderC setCompletedBlock:^(NSString *scanResult){
        
        NSLog(@"this is scan result :%@",scanResult);
    }];
    [self.navigationController pushViewController:codeReaderC animated:YES];
```