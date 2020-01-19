//
//  NGame.h
//  Puzzoodle
//
//  Created by macmini on 12/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "/usr/include/sqlite3.h"


@interface NGame : NSObject {
	sqlite3 *database;
	NSInteger primaryKey;
	NSString  *gameName;
	NSInteger  pictureId;
	NSInteger status;
	UIImage   *ImageGame;
	UIImage   *Thubmnail;
	UIImage   *ImageShowMini;
	UIImage   *ImageGameaux;
	BOOL orientation;
}

@property (nonatomic)        NSInteger primaryKey;
@property (nonatomic,assign) NSString  *gameName;
@property (nonatomic)        NSInteger  pictureId;
@property (nonatomic)        NSInteger status;
@property (nonatomic,retain) UIImage   *ImageGame;
@property (nonatomic,retain) UIImage   *Thubmnail;
@property (nonatomic,retain) UIImage   *ImageShowMini;
@property (nonatomic)        BOOL orientation;


+ (void)finalizeStatements;
+(NSInteger) createGameindatabase:(sqlite3 *)db picture:(NSString*)lapicture;
+(BOOL)is_photorrollSelected:(sqlite3 *)db;

- (void)deleteGame;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
-(void) CommitChanges;
-(void) saveMainPiece:(NSInteger)idpiece status:(NSInteger)status;
-(BOOL) IsGameInProgress;
- (UIImage *)fixImageOrientationExport:(UIImage *)img;


@end
