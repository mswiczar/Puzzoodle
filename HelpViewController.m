//
//  HelpViewController.m
//  Puzzoodle
//
//  Created by macmini on 06/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"

#define PI_OVER_2  1.57079632679489661923f
#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}
	

@implementation HelpViewController
@synthesize AimageView;
@synthesize Aimage;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		AimageView=nil;
	}
	return self;
}


- (UIImage *)fixImageOrientation:(UIImage *)img
{
	CGSize size = [img size];
	
	UIImageOrientation imageOrientation = [img imageOrientation];
	//	NSLog(@"Image orientation : %d", imageOrientation);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	CGImageRef imageRef = [img CGImage];
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												size.width,
												size.height,
												CGImageGetBitsPerComponent(imageRef),
												4*size.width,
												CGImageGetColorSpace(imageRef),
												CGImageGetBitmapInfo(imageRef));
	
	CGContextTranslateCTM( bitmap, size.width, size.height );
	
	switch (imageOrientation) {
	    case UIImageOrientationUp:
			transform = CGAffineTransformMakeTranslation(0.0, size.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			CGContextRotateCTM( bitmap, radians(-180) );
			CGContextConcatCTM(bitmap,transform);
			
			break;
		case UIImageOrientationDown:
			// rotate 180 degees CCW
			CGContextRotateCTM( bitmap, radians(180.) );
			break;
		case UIImageOrientationLeft:
			// rotate 90 degrees CW
			CGContextRotateCTM( bitmap, radians(90.) );
			break;
		case UIImageOrientationRight:
			// rotate 90 degrees CCW
			CGContextRotateCTM( bitmap, radians(-90.) );
			break;
		default:
			break;
	}
	
	CGContextDrawImage( bitmap, CGRectMake(0,0,size.width,size.height), imageRef );
	
	CGImageRef ref = CGBitmapContextCreateImage( bitmap );	
	CGContextRelease( bitmap );
	UIImage *oimg = [UIImage imageWithCGImage:ref];
	CGImageRelease( ref );
	
	return oimg;
}


-(void)show
{
	if (AimageView !=nil)
	{
		[AimageView release];
	}
	Aimage = [self fixImageOrientation:Aimage];
	AimageView = [[UIImageView alloc] initWithImage:Aimage];
	CGAffineTransform transform = CGAffineTransformMakeRotation(PI_OVER_2 * 1);
	AimageView.transform = transform;

	[self.view addSubview:AimageView];
	CGPoint apoint;
	apoint.x = 159;
	apoint.y = 242;
	AimageView.center = apoint; 
	
	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}


- (void)dealloc {
	[super dealloc];
}

-(void)backpress:aid
{
	[self.navigationController popViewControllerAnimated:NO];
}

@end
