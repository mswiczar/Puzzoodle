//
//  NPiece.m
//  Puzzoodle
//
//  Created by macmini on 06/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NPiece.h"
#define PI_OVER_2  1.57079632679489661923f

@implementation NPiece

@synthesize posxy;
@synthesize posxyFixed;
@synthesize piecenumber;
@synthesize orientation;
@synthesize default_orientation;
@synthesize myMaskedImage;
@synthesize pieceClick;
@synthesize is_ok;
@synthesize is_okMaster;
@synthesize is_master;

- (id)initWithFrame:(CGRect)arect
{
	if (self=[super initWithFrame:arect])
	{
		default_orientation=3;
		self.opaque=NO;
		self.autoresizingMask= UIViewAutoresizingNone;
		self.contentMode=UIViewContentModeCenter;
	}
	return self;
}
- (void)dealloc
{
	CGImageRelease(myMaskedImage);
	[super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	if (is_master)
	{
		CGContextRef context =  UIGraphicsGetCurrentContext();
		CGContextSaveGState(context);
		CGContextDrawImage (context, rect, myMaskedImage);
		CGContextRestoreGState(context);
	}
	else
	{
		CGContextRef context =  UIGraphicsGetCurrentContext();
	    CGContextSaveGState(context);
		CGSize myShadowOffset;
		if (!is_ok)
		{
			myShadowOffset = CGSizeMake (3,  3);
			CGContextSetShadow(context,myShadowOffset,4);

/*			switch (orientation)
			{
				case 0:
					myShadowOffset = CGSizeMake (1,  1);
					CGContextSetShadow(context,myShadowOffset,6);
					break;
				case 1:
					myShadowOffset = CGSizeMake (1,  1);
					CGContextSetShadow(context,myShadowOffset,6);
					break;
				case 2:
					myShadowOffset = CGSizeMake (1,  1);
					CGContextSetShadow(context,myShadowOffset,6);
					break;
				case 3:
					myShadowOffset = CGSizeMake (1,  1);
					CGContextSetShadow(context,myShadowOffset,6);
					break;
			}
*/

		}
		CGContextDrawImage (context, rect, myMaskedImage);
		CGContextRestoreGState(context);
	}
};


@end
