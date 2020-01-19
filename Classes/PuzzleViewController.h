#import <UIKit/UIKit.h>
#import "HelpViewController.h"
#import "NGame.h"
#import "NPiece.h"

#import "/usr/include/sqlite3.h"

@interface PuzzleViewController : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate>
{
	NSInteger moovingNumber;
	NSMutableArray * thearray;
	NSMutableArray * thearray2;
	
	BOOL piecesOnTop;  // Keeps track of whether or not two or more pieces are on top of each other
	BOOL mustRotate;
	CGPoint startTouchPosition; 
	HelpViewController* ahelpcontroller;
	sqlite3 *database;
	UIImage * aimagePuzzle;
	CGImageRef ahelperImageSource;
	UIImage* helpimage;
	IBOutlet UIImageView *panel;
	IBOutlet UIImageView *board;
	IBOutlet UIView *amain;
	IBOutlet UIView *amenu;
	IBOutlet UIButton *buttonNext;

	CGPoint startPoint;
	NGame * agame;
	NPiece* Minipiece;
	NSInteger atagint;
	BOOL saved;
	NSMutableArray * thearrayMaster;
	NSInteger actual;
	
	

}
@property (nonatomic,assign) 	NGame * agame;
@property (nonatomic,assign) 	NPiece* Minipiece;
@property (nonatomic,assign) 	NSMutableArray* thearrayMaster;


@property (nonatomic) 	CGPoint startPoint;
@property (nonatomic) 	BOOL saved;
@property (nonatomic) 	NSInteger actual;


-(void)BeginwithImage:(UIImage*)imagename;
-(void)ClearAll;
-(BOOL)isok;
-(void) SavePiecesPosition;

@end

