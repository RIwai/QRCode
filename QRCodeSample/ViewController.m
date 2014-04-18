//
//  ViewController.m
//  QRCodeSample
//
//  Created by Ryota Iwai on 2014/04/16.
//  Copyright (c) 2014年 Ryota Iwai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

- (void)generateQRCode;
- (void)dispQRCodeCapture;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 生成したQRコード画像がぼけない様に
    self.qrCodeImage.layer.magnificationFilter = kCAFilterNearest;
    self.qrCodeImage.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - Action Method

- (IBAction)tapQRCodeReaderButton:(id)sender {
#if TARGET_IPHONE_SIMULATOR

#else
    [self dispQRCodeCapture];
#endif
}

- (IBAction)tapQRCodeCreaterButton:(id)sender {
    // Hide keyboard
    [self.readerTextView resignFirstResponder];
    [self.createrTextView resignFirstResponder];

    [self generateQRCode];
}

- (IBAction)tapReaderCloseButton:(id)sender {
    // Close preview view.
    [self.previewView removeFromSuperview];
    self.previewView = nil;
    self.session = nil;
    self.session = nil;
}

#pragma mark - QR Code Generator
- (void)generateQRCode {
    NSString *codeBaseString = self.createrTextView.text;

    if (codeBaseString == nil || codeBaseString.length == 0) {
        return;
    }

    // QRコード作成用のフィルターを作成・パラメータの初期化
    CIFilter *ciFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [ciFilter setDefaults];

    // 格納する文字列をNSData形式（UTF-8でエンコード）で用意して設定
    NSData *data = [codeBaseString dataUsingEncoding:NSUTF8StringEncoding];
    [ciFilter setValue:data forKey:@"inputMessage"];

    // 誤り訂正レベルを「L（低い）」に設定
    [ciFilter setValue:@"L" forKey:@"inputCorrectionLevel"];

    // Core Imageコンテキストを取得したらCGImage→UIImageと変換して描画
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgimg =
        [ciContext createCGImage:[ciFilter outputImage]
                        fromRect:[[ciFilter outputImage] extent]];
    UIImage *image = [UIImage imageWithCGImage:cgimg scale:1.0f
                                   orientation:UIImageOrientationUp];
    CGImageRelease(cgimg);

    // 画面のUIImageViewに表示
    self.qrCodeImage.image = image;
}

#pragma mark - QR Code Reader

- (void)dispQRCodeCapture {
    // Init text view
    self.readerTextView.text = @"";

    // Capture session init
    self.session = AVCaptureSession.new;

    AVCaptureDevice *backCameraDevice;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionBack) {
            backCameraDevice = device;
            break;
        }
    }

    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCameraDevice
                                                                        error:&error];
    [self.session addInput:input];

    AVCaptureMetadataOutput *output = AVCaptureMetadataOutput.new;
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:output];
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    [self.session startRunning];

    self.previewView = [[UIView alloc] initWithFrame:self.view.frame];
    self.previewView.backgroundColor = [UIColor clearColor];

    AVCaptureVideoPreviewLayer *avCapturePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    avCapturePreviewLayer.frame = self.view.bounds;
    avCapturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.view addSubview:self.previewView];

    [self.previewView.layer addSublayer:avCapturePreviewLayer];

    // Close Button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(tapReaderCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.backgroundColor = [UIColor whiteColor];
    CGRect buttonRect = closeButton.frame;
    buttonRect = CGRectMake(20.0f, 20.0f, 80.0f, 44.0f);
    closeButton.frame = buttonRect;
    [self.previewView addSubview:closeButton];
}

#pragma mark - <AVCaptureMetadataOutputObjectsDelegate>

- (void)       captureOutput:(AVCaptureOutput *)captureOutput
    didOutputMetadataObjects:(NSArray *)metadataObjects
              fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // 複数の QR があっても1度で読み取れている
            NSString *qrcode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            self.readerTextView.text = qrcode;
            [self.previewView removeFromSuperview];
            self.previewView = nil;
            self.session = nil;

            break;
        }
    }
}

@end
