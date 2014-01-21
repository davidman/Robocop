//
//  Robocop.h
//  Robocop
//
//  Created by David Hdz on 1/10/14.
//  Copyright (c) 2014 David Hernandez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^RobocopCodeReaderHandler)(NSString *machineCodeString);
typedef void (^RobocopRectOfInterestHandler)(CGRect rectOfInterest);

@interface Robocop : NSObject

+ (instancetype)sharedInstance;

- (void)startReadingInView:(UIView *)preview
			readerHandler:(RobocopCodeReaderHandler)readerHandler
	rectOfInterestHandler:(RobocopRectOfInterestHandler)rectOfIntesetHandler;

- (void)startReadingMachineReadableCodeObjects:(NSArray *)codeObjects
										inView:(UIView *)preview
								 readerHandler:(RobocopCodeReaderHandler)readerHandler
						 rectOfInterestHandler:(RobocopRectOfInterestHandler)rectOfIntesetHandler;
- (void)stop;

@end

