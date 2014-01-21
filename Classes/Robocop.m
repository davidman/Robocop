//
//  Robocop.m
//  Robocop
//
//  Created by David Hdz on 1/10/14.
//  Copyright (c) 2014 David Hernandez. All rights reserved.
//

#import "Robocop.h"

@interface Robocop () <AVCaptureMetadataOutputObjectsDelegate>

@property (copy,	nonatomic) RobocopCodeReaderHandler machineReadbleCodeReaderHandler;
@property (copy,	nonatomic) RobocopRectOfInterestHandler readerRectOfInterestHandler;
@property (strong,	nonatomic) NSArray *selectedMetadataObjectTypes;

@property (strong,	nonatomic) AVCaptureDevice *device;
@property (strong,	nonatomic) AVCaptureDeviceInput *input;
@property (strong,	nonatomic) AVCaptureMetadataOutput *output;
@property (strong,	nonatomic) AVCaptureSession *session;
@property (strong,	nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation Robocop

static Robocop * _sharedInstance = nil;

+ (instancetype)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// Instantiate the reader
		_sharedInstance = [[Robocop alloc] init];
		
		// Instantiate the Reader components
		[_sharedInstance initCaptureSession];
		[_sharedInstance initDeviceWithVideoMediaType];
		[_sharedInstance initCaptureMetadataOutput];
		[_sharedInstance initDeviceInput];
	});
	return _sharedInstance;
}

- (void)startReadingInView:(UIView *)preview
			readerHandler:(RobocopCodeReaderHandler)readerHandler
	rectOfInterestHandler:(RobocopRectOfInterestHandler)rectOfIntesetHandler
{
	[self startReadingMachineReadableCodeObjects:@[AVMetadataObjectTypeQRCode]
											 inView:preview
									  readerHandler:readerHandler
							  rectOfInterestHandler:rectOfIntesetHandler];
}

- (void)startReadingMachineReadableCodeObjects:(NSArray *)codeObjects
										   inView:(UIView *)preview
									readerHandler:(RobocopCodeReaderHandler)readerHandler
							rectOfInterestHandler:(RobocopRectOfInterestHandler)rectOfIntesetHandler
{
	// Setup Reader components
	[self setupSessionInput];
	[self setupReaderOutputWithMetadataObjectTypes:codeObjects readerDelegate:self];
	[self setupReaderPreviewInView:preview];
	[self setupMachineReadableCodeReaderHandlerBlock:readerHandler];
	
	// Setup Reader Rect of Interest Handler
	[self setReaderRectOfInterestHandler:rectOfIntesetHandler];
	
	// Start to capture
	[self start];
}


#pragma mark - Init Reader Components 

- (void)initCaptureSession
{
	if (!self.session) {
		self.session = [[AVCaptureSession alloc] init];
	}
}

- (void)initDeviceWithVideoMediaType
{
	if (!self.device) {
		self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	}
}

- (void)initCaptureMetadataOutput
{
	if (!self.output) {
		self.output = [[AVCaptureMetadataOutput alloc] init];
	}
}

- (void)initDeviceInput
{
	if (!self.input) {
		NSError *error = nil;
		self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
	}
}


#pragma mark - Setup Reader Components

- (void)setupSessionInput
{
	if (self.input && ![[self.session inputs] containsObject:self.input])
		[self.session addInput:self.input];
	else {
		NSLog(@"Unable to set input: %@\nCurrent session inputs: %@", self.input, [self.session inputs]);
	}
}

- (void)setupSessionOutput
{
	if (self.output && ![[self.session outputs] containsObject:self.output])
		[self.session addOutput:self.output];
	else {
		NSLog(@"Unable to set output: %@\nCurrent session outputs: %@", self.output, [self.session outputs]);
	}
}

- (void)setupReaderOutputWithMetadataObjectTypes:(NSArray *)metadataObjectTypes
								  readerDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)readerDelegate
{
	[self setupSessionOutput];
	[self.output setMetadataObjectsDelegate:readerDelegate queue:dispatch_get_main_queue()];
	self.selectedMetadataObjectTypes = [self defaultMetadataObjectTypesIfUserMetadataObjectTypesArrayIsEmpty:metadataObjectTypes];
	[self.output setMetadataObjectTypes:self.selectedMetadataObjectTypes];
}

- (void)setupReaderPreviewInView:(UIView *)preview
{
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = preview.bounds;
    [preview.layer insertSublayer:self.previewLayer atIndex:0];
}

- (void)setupMachineReadableCodeReaderHandlerBlock:(RobocopCodeReaderHandler)readerBlock
{
	self.machineReadbleCodeReaderHandler = readerBlock;
}


#pragma mark - MetadataObject to Read

- (NSArray *)defaultMetadataObjectTypesIfUserMetadataObjectTypesArrayIsEmpty:(NSArray *)userMetadataObjectTypes
{
	if ([userMetadataObjectTypes count] == 0) {
		return [self.output availableMetadataObjectTypes];
	}
	return userMetadataObjectTypes;
}


#pragma mark - Reader Control Actions

- (void)start
{
	[self.session startRunning];
}

- (void)stop
{
	[self.session stopRunning];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
	AVMetadataMachineReadableCodeObject *machineCodeObject = nil;
	
	for (AVMetadataObject *metadata in metadataObjects) {
		if ([self.selectedMetadataObjectTypes containsObject:metadata.type]) {
			machineCodeObject = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:metadata];
			
			// Call Rect of interest Handler
			[self callRectOfInterestHandlerWithRect:[machineCodeObject bounds]];
			
			// Call Code Reader Handler
			[self callCodeReaderHandlerWithMetadataObject:metadata];
		}
	}
}

#pragma mark - Block Handlers

- (void)callRectOfInterestHandlerWithRect:(CGRect)codeRect
{
	if (self.readerRectOfInterestHandler) {
		self.readerRectOfInterestHandler(codeRect);
	}
}

- (void)callCodeReaderHandlerWithMetadataObject:(AVMetadataObject *)metadata
{
	// Call Code Reader Handler
	NSString *machineCodeStr;
	if ([metadata respondsToSelector:@selector(stringValue)]) {
		machineCodeStr = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
		if (self.machineReadbleCodeReaderHandler) {
			self.machineReadbleCodeReaderHandler(machineCodeStr);
		}
	}
}

@end
