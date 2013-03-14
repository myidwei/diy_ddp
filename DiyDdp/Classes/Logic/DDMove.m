//
//  DDMove.m
//  DiyDdp
//
//  Created by xiaowei on 13-3-14.
//
//

#import "DDMove.h"

@implementation DDMove

@synthesize fromCol = _fromCol;
@synthesize fromRow = _fromRow;
@synthesize toCol = _toCol;
@synthesize toRow = _toRow;

+ (DDMove*)moveFromRow:(NSInteger)fromRow andCol:(NSInteger)fromCol toRow:(NSInteger)toRow andCol:(NSInteger)toCol
{
    DDMove* move = [[[DDMove alloc] init] autorelease];
    move.fromRow = fromRow;
    move.fromCol = fromCol;
    move.toRow = toRow;
    move.toCol = toCol;
    return move;
}

+ (DDMove*)doNotMove;
{
    DDMove* move = [[[DDMove alloc] init] autorelease];
    move.fromRow = -1;
    move.fromCol = -1;
    move.toRow = -1;
    move.toCol = -1;
    return move;
}

- (BOOL)doesMove
{
    return _fromRow != -1;
}

@end
