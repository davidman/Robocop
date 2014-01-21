//
//  DHQRReaderViewController.m
//  David Hdz
//
//  Created by David Hdz on 1/9/14.
//  Copyright (c) 2014 David Hernandez. All rights reserved.
//

#import "DHQRReaderViewController.h"
#import "Robocop.h"
#import "DHHighlightLayerAnimator.h"

@interface DHQRReaderViewController ()
@property (strong, nonatomic) Robocop *qrReader;
@property (copy, nonatomic) NSString *qrCodeStr;
@end

@implementation DHQRReaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// Setup a highlight layer for the barcode
	DHHighlightLayerAnimator *layerAnimator = [DHHighlightLayerAnimator sharedAnimator];
	[layerAnimator setContainerView:self.view];
	
	// Setup QR Reader and Start reading
	[[Robocop sharedInstance]
	 startReadingMachineReadableCodeObjects:nil
	 inView:self.view
	 readerHandler:^(NSString *machineCodeString) {
		 if (![machineCodeString isEqualToString:self.qrCodeStr]) {
			[self saveQRCodeRead:machineCodeString];
			[self showReadCode];
		}
	} rectOfInterestHandler:^(CGRect rectOfInterest) {
		NSLog(@"%@", NSStringFromCGRect(rectOfInterest));
		[layerAnimator animateHighlightLayerToFrame:rectOfInterest];
	}];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// Stop reading
	[[Robocop sharedInstance] stop];

	// Nil out last code read
	[self clearLastQRCodeRead];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - QR code handling

- (void)saveQRCodeRead:(NSString *)qrCodeStr
{
	self.qrCodeStr = qrCodeStr;
}

- (void)clearLastQRCodeRead
{
	self.qrCodeStr = nil;
}

#pragma mark - Show Read Code
- (void)showReadCode
{
	[self.codeLabel setText:self.qrCodeStr];
}
@end
