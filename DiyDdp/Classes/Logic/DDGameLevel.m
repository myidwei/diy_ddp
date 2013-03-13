//
//  DDGameLevel.m
//  DiyDdp
//
//  Created by xiaowei on 13-3-12.
//
//

#import "DDGameLevel.h"

@implementation DDGameLevel
@synthesize data = _data;
@synthesize rows = _rows;
@synthesize cols = _cols;
@synthesize itemCount = _itemCount;
@synthesize level = _level;

- (id)initWithSize:(CGSize)size itemCount:(NSInteger)itemCount
{
    if(self = [super init]){
        _data = [[NSMutableDictionary alloc] init];
        _rows = size.width;
        _cols = size.height;
        _itemCount = itemCount;
    }
    return self;
}

- (void)dealloc
{
    [_data release];
    [super dealloc];
}

//判断在初始化的时候，某个位置是否可以放置某种Item
- (BOOL)canPutOnRow:(NSInteger)row col:(NSInteger)col tag:(NSInteger)tag
{
    //判断横竖
    //横方向
    NSInteger start = col - 2;
    NSInteger end = col + 2;
    if(start < 0)
        start = 0;
    if(end >= _cols){
        end = _cols - 1;
    }
    NSInteger total = 0;
    for(int i=start;i<=end;i++){
        DDItem* item = [_data objectForKey:[DDGameLevel keyForRow:row andCol:i]];
        if(item != nil && item.tag == tag){
            total++;
        }else{
            total = 0;
        }
    }
    if(total >= 3)
        return NO;
    
    //竖方向
    start = row - 2;
    end = row + 2;
    if(start < 0)
        start = 0;
    if(end >= _rows){
        end = _rows - 1;
    }
    total = 0;
    for(int i=start;i<=end;i++){
        DDItem* item = [_data objectForKey:[DDGameLevel keyForRow:i andCol:col]];
        if(item != nil && item.tag == tag){
            total++;
        }else{
            total = 0;
        }
    }
    if(total >= 3)
        return NO;
    
    return YES;
}


- (void)resetLevel
{
    //初始化数据
    for(int col=0;col<_cols;col++){
        for(int row=0;row<_rows;row++){
            [_data setObject:[DDItem emptyItem] forKey:[DDGameLevel keyForRow:row andCol:col]];
        }
    }
    //随机设置数据
    for(int col=0;col<_cols;col++){
        for(int row=0;row<_rows;row++){
            NSInteger itemTag = arc4random()%_itemCount + 1;
            while (![self canPutOnRow:row col:col tag:itemTag]){
                itemTag = arc4random()%_itemCount + 1;
            }
            DDItem* item = [DDItem itemWithTag:itemTag];
            item.row = row;
            item.col = col;
            [_data setObject:item forKey:[DDGameLevel keyForRow:row andCol:col]];
        }
    }
}

+ (NSString*)keyForRow:(NSInteger)row andCol:(NSInteger)col
{
    NSString* str = [NSString stringWithFormat:@"%d_%d",row,col];
    return str;
}

+ (DDGameLevel*)levelWithSize:(CGSize)size itemCount:(NSInteger)itemCount
{
    DDGameLevel* lv = [[[DDGameLevel alloc] initWithSize:size itemCount:itemCount] autorelease];
    return lv;
}
@end
