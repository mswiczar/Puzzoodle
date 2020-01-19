//
//  NPiece.h
//  Puzzoodle
//
//  Created by macmini on 06/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>  // Needed for animations


@interface NPiece : UIView {
	CGImageRef myMaskedImage;	
	Rect      inViewRect;
 	CGPoint   posxy;
 	CGPoint   posxyFixed;
	NSInteger piecenumber;
	NSInteger orientation;
	NSInteger default_orientation;
	NSInteger pieceClick;
	BOOL      is_ok;
	BOOL      is_okMaster;
	BOOL      is_master;
}

@property (nonatomic) CGPoint   posxy;
@property (nonatomic) NSInteger piecenumber;
@property (nonatomic) NSInteger orientation;
@property (nonatomic) NSInteger default_orientation;
@property (nonatomic) CGPoint   posxyFixed;
@property (nonatomic) NSInteger pieceClick;
@property (nonatomic) CGImageRef myMaskedImage;
@property (nonatomic) BOOL is_ok;
@property (nonatomic) BOOL is_okMaster;
@property (nonatomic) BOOL is_master;





- (void)drawRect:(CGRect)rect;
- (id)initWithFrame:(CGRect)arect;


@end
