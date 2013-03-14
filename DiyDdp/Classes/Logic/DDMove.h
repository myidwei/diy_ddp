//
//  DDMove.h
//  DiyDdp
//
//  Created by xiaowei on 13-3-14.
//
//

#import <Foundation/Foundation.h>

@interface DDMove : NSObject
{
    NSInteger _fromRow;
    NSInteger _toRow;
    NSInteger _fromCol;
    NSInteger _toCol;
}

@property (assign,nonatomic) NSInteger fromRow;
@property (assign,nonatomic) NSInteger fromCol;
@property (assign,nonatomic) NSInteger toRow;
@property (assign,nonatomic) NSInteger toCol;

+ (DDMove*)moveFromRow:(NSInteger)fromRow andCol:(NSInteger)fromCol toRow:(NSInteger)toRow andCol:(NSInteger)toCol;
+ (DDMove*)doNotMove;
- (BOOL)doesMove;
@end
