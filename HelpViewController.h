//
//  HelpViewController.h
//  Puzzoodle
//
//  Created by macmini on 06/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController {
	IBOutlet UIButton* backbutton;
	UIImage* Aimage;
	UIImageView* AimageView;
	
}
@property (nonatomic,assign) UIImageView* AimageView;
@property (nonatomic,assign) UIImage* Aimage;

-(void)show;
@end
