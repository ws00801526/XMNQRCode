# XMNQRCode
XMNQRCode 基于AVFoundation,CoreImage封装的一个二维码,条形码扫描,生成工具



- [x] 二维码扫描功能, 默认支持二维码,条形码扫描功能, 可自行配置
- [x] 二维码,条形码生成功能, 可自行配置生成的二维码图片(包含边角样式,中间图片等), 可配置条形码是否显示文字
- [x] 二维码扫描功能, 可自动识别光线亮度, 显示闪光灯开启功能, 可点击改变曝光度



### 安装方法

1. `pod 'XMNQRCode'` 使用pod方式安装XMNQRCode类库




### 使用示例

1. 唤起二维码扫描界面

```objective-c
     __weak typeof(self) wSelf = self;
     //1. 创建reader实例
    XMNQRCodeReaderController *rederC = [[XMNQRCodeReaderController alloc] initWithCompletionHandler:^(NSString *result) {
    //2. 处理扫描结果
        __strong typeof(wSelf) self = wSelf;
        SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:result]];
        [self.navigationController pushViewController:controller animated:YES];
    }];
    [self.navigationController pushViewController:rederC animated:YES];
```



2. 二维码生成

```objective-c
//1. 创建二维码生成器	
XMNQRCodeBuilder *builder = [[XMNQRCodeBuilder alloc] initWithInfo:@"https://www.baidu.com" size:CGSizeMake(300, 300)];
//2. 配置样式参数
builder.outerColor = [UIColor cyanColor]; 
//3. 生成二维码(二维码只支持lating1 字符集), 条形码(注意条形码只支持ASCII字符集)
// 可参考文档 [Xcode文档](xcdoc://?url=developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP30000136-SW310)
UIImage *image = builder.QRCodeImage;
UIImage *barImage = builder.barCodeImage;

//4. 异步生成二维码
[self.builder generateCodeImageWithMode:XMNQRCodeBuilderCodeModeQRCode
                          completionHandler:^(UIImage * _Nullable image) {
                             //生成的对应条形码或者二维码图片 
                          }];
//更多样式定义 参考demo
```

