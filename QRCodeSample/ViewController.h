//
//  ViewController.h
//  QRCodeSample
//
//  Created by Ryota Iwai on 2014/04/16.
//  Copyright (c) 2014年 Ryota Iwai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

- (IBAction)tapQRCodeReaderButton:(id)sender;
- (IBAction)tapQRCodeCreaterButton:(id)sender;

@property (nonatomic, weak) IBOutlet UITextView *readerTextView;
@property (nonatomic, weak) IBOutlet UITextView *createrTextView;
@property (nonatomic, weak) IBOutlet UIImageView *qrCodeImage;

@property (nonatomic, strong) AVCaptureSession *session;
//@property (nonatomic, strong) AVCaptureVideoPreviewLayer *avCapturePreviewLayer;
@property (nonatomic, strong) UIView *previewView;

@end
