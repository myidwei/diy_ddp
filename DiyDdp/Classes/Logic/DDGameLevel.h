//
//  DDGameLevel.h
//  DiyDdp
//
//  Created by xiaowei on 13-3-12.
//
//

#import <Foundation/Foundation.h>
#import "DDItem.h"
#import "DDMove.h"
@interface DDGameLevel : NSObject
{
    NSInteger _level;
    NSInteger _itemCount;
    NSInteger _rows;
    NSInteger _cols;
    NSMutableDictionary* _data;
}

@property (readonly,nonatomic) NSMutableDictionary* data;
@property (assign,nonatomic) NSInteger rows;
@property (assign,nonatomic) NSInteger cols;
@property (assign,nonatomic) NSInteger itemCount;
@property (assign,nonatomic) NSInteger level;

+ (DDGameLevel*)levelWithSize:(CGSize)size itemCount:(NSInteger)itemCount;
+ (NSString*)keyForRow:(NSInteger)row andCol:(NSInteger)col;

- (id)initWithSize:(CGSize)size itemCount:(NSInteger)itemCount;
- (BOOL)canPutOnRow:(NSInteger)row col:(NSInteger)col tag:(NSInteger)tag;
- (void)resetLevel;
- (NSArray*)needRemoveItems;
- (BOOL)needReset;
- (void)removeItemsIfNeed;
- (void)exchangeFromRow:(NSInteger)row andCol:(NSInteger)col toRow:(NSInteger)toRow andCol:(NSInteger)toCol;
- (BOOL)checkRow:(NSInteger)row andCol:(NSInteger)col withTag:(NSInteger)tag;
- (DDMove*)moveDownOnRow:(NSInteger)row andCol:(NSInteger)col;
- (NSArray*)moveDownItemsIfNeed;
- (NSArray*)fillItems;
- (DDItem*)hinit;
@end
