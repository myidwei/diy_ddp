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

//检查某个位置如果放置某个Item是否可以消除
- (BOOL)checkRow:(NSInteger)row andCol:(NSInteger)col withTag:(NSInteger)tag
{
    //两个方向，6个位置，只要有一个颜色与两个连接的相同，就有解
    int h[6][2] = {{2,0},{-3,0},{1,1},{-1,1},{-1,-2},{1,-2}};
    int v[6][2] = {{0,2},{0,-3},{1,-1},{1,1},{-2,-1},{-2,1}};
    //垂直方向
    for(int col=0;col<_cols;col++){
        int current = 0;
        for(int row=0;row<_rows;row++)
        {
            DDItem* item = [_data objectForKey:[DDGameLevel keyForRow:row andCol:col]];
            if([item isEmpty])
                continue;
            if(item.tag == current)
            {
                for(int i=0;i<6;i++){
                    DDItem* checkItem = [_data objectForKey:[DDGameLevel keyForRow:v[i][0] andCol:v[i][1]]];
                    if(checkItem.tag == item.tag){
                        return YES;
                    }
                }
            }else{
                current = tag;
            }
        }
    }
    
    
    //水平方向
    for(int row=0;row<_rows;row++){
        int current = 0;
        for(int col=0;col<_cols;col++)
        {
            DDItem* item = [_data objectForKey:[DDGameLevel keyForRow:row andCol:col]];
            if([item isEmpty])
                continue;
            if(item.tag == current)
            {
                for(int i=0;i<6;i++){
                    DDItem* checkItem = [_data objectForKey:[DDGameLevel keyForRow:h[i][0] andCol:h[i][1]]];
                    if(checkItem.tag == item.tag){
                        return YES;
                    }
                }
            }else{
                current = tag;
            }
        }
    }
    
    return NO;
}

//检查当前数据是否需要重置（即无解的情况）
- (BOOL)needReset
{
    for(int row=_rows-1;row>=0;row--){
        for(int col=0;col<_cols;col++)
        {
            DDItem* item = [_data objectForKey:[DDGameLevel keyForRow:row andCol:col]];
            printf("%2d ",item.tag);
        }
        printf("\n");
    }
    printf("-----------------\n");
    //两个方向，6个位置，只要有一个颜色与两个连接的相同，就有解
    int h[6][2] = {{2,0},{-3,0},{1,1},{-1,1},{-1,-2},{1,-2}};
    int v[6][2] = {{0,2},{0,-3},{1,-1},{1,1},{-2,-1},{-2,1}};
    //垂直方向
    for(int col=0;col<_cols;col++){
        int current = 0;
        for(int row=0;row<_rows;row++)
        {
            DDItem* item = [_data objectForKey:[DDGameLevel keyForRow:row andCol:col]];
            if([item isEmpty])
                continue;
            if(item.tag == current)
            {
                for(int i=0;i<6;i++){
                    DDItem* checkItem = [_data objectForKey:[DDGameLevel keyForRow:item.row + v[i][0] andCol:item.col + v[i][1]]];
                    if(checkItem != nil && checkItem.tag == item.tag){
                        return NO;
                    }
                }
            }else{
                current = item.tag;
            }
        }
    }
    
    
    //水平方向
    for(int row=0;row<_rows;row++){
        int current = 0;
        for(int col=0;col<_cols;col++)
        {
            DDItem* item = [_data objectForKey:[DDGameLevel keyForRow:row andCol:col]];
            if([item isEmpty])
                continue;
            if(item.tag == current)
            {
                for(int i=0;i<6;i++){
                    DDItem* checkItem = [_data objectForKey:[DDGameLevel keyForRow:item.row + h[i][0] andCol:item.col+h[i][1]]];
                    if(checkItem != nil && checkItem.tag == item.tag){
                        return NO;
                    }
                }
            }else{
                current = item.tag;
            }
        }
    }
    
    return YES;

}

//消除需要消除的Item
- (void)removeItemsIfNeed
{
    NSArray* needRemoveItems = [self needRemoveItems];
    for(DDItem* item in needRemoveItems){
        [_data setObject:[DDItem emptyItem] forKey:[DDGameLevel keyForRow:item.row andCol:item.col]];
    }
}

//检查当前数据是否有需要移除（消去）的，返回需要消除的Item
- (NSArray*)needRemoveItems
{
    NSMutableArray* items = [NSMutableArray array];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    for(int row=0;row <_rows;row++){
        for(int col=0;col<_cols;col++){
            //逐个点检查
            DDItem* item = [_data objectForKey:[DDGameLevel keyForRow:row andCol:col]];
            if([item isEmpty]){
                continue;
            }
            //两个方向
            int nowRow = 0;
            int nowCol = 0;
            //left and right
            int total = 1;
            NSMutableArray* temp = [NSMutableArray array];
            [temp addObject:item];
            //left
            nowCol = col - 1;
            while(nowCol >=0 && nowCol < _cols){
                DDItem* it = [_data objectForKey:[DDGameLevel keyForRow:row andCol:nowCol]];
                if(it.tag == item.tag){
                    [temp addObject:it];
                    total++;
                    nowCol--;
                }else{
                    break;
                }
            }
            //right
            nowCol = col + 1;
            while(nowCol >=0 && nowCol < _cols){
                DDItem* it = [_data objectForKey:[DDGameLevel keyForRow:row andCol:nowCol]];
                if(it.tag == item.tag){
                    [temp addObject:it];
                    total++;
                    nowCol++;
                }else{
                    break;
                }
            }
            if(total >= 3){
                [items addObjectsFromArray:temp];
            }
            
            //up and down
            total = 1;
            [temp removeAllObjects];
            [temp addObject:item];
            //left
            nowRow = row - 1;
            while(nowRow >=0 && nowRow < _rows){
                DDItem* it = [_data objectForKey:[DDGameLevel keyForRow:nowRow andCol:col]];
                if(it.tag == item.tag){
                    [temp addObject:it];
                    total++;
                    nowRow--;
                }else{
                    break;
                }
            }
            //right
            nowRow = row + 1;
            while(nowRow >=0 && nowRow < _rows){
                DDItem* it = [_data objectForKey:[DDGameLevel keyForRow:nowRow andCol:col]];
                if(it.tag == item.tag){
                    [temp addObject:it];
                    total++;
                    nowRow++;
                }else{
                    break;
                }
            }
            if(total >= 3){
                [items addObjectsFromArray:temp];
            }
            
        }
    }
    //排重
    for(DDItem* item in items){
        [dict setObject:item forKey:[DDGameLevel keyForRow:item.row andCol:item.col]];
    }
    NSEnumerator* e = [dict objectEnumerator];
    [items removeAllObjects];
    DDItem* item = nil;
    while(item = [e nextObject])
    {
        [items addObject:item];
    }
    return items;
}

//判断在初始化的时候，某个位置是否可以放置某种Item
- (BOOL)canPutOnRow:(NSInteger)row col:(NSInteger)col tag:(NSInteger)tag
{
    
    //Place first
    [_data setObject:[DDItem itemWithTag:tag] forKey:[DDGameLevel keyForRow:row andCol:col]];
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
        if((item != nil && item.tag == tag)){
            total++;
            if(total == 3)
                break;
        }else{
            total = 0;
        }
    }
    if(total >= 3){
        [_data removeObjectForKey:[DDGameLevel keyForRow:row andCol:col]];
        return NO;
    }
    
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
        if((item != nil && item.tag == tag)){
            total++;
            if(total == 3)
                break;
        }else{
            total = 0;
        }
    }
    if(total >= 3){
        [_data removeObjectForKey:[DDGameLevel keyForRow:row andCol:col]];
        return NO;
    }
    
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

- (void)exchangeFromRow:(NSInteger)row andCol:(NSInteger)col toRow:(NSInteger)toRow andCol:(NSInteger)toCol
{
    DDItem* fromItem = [_data objectForKey:[DDGameLevel keyForRow:row andCol:col]];
    DDItem* toItem = [_data objectForKey:[DDGameLevel keyForRow:toRow andCol:toCol]];
    if(fromItem == nil || toItem == nil)
        return;
    if((row == toRow && abs(col-toCol) == 1) || (col == toCol && abs(row-toRow) == 1)){
        [fromItem retain];
        [toItem retain];
        fromItem.row = toRow;
        fromItem.col = toCol;
        toItem.row = row;
        toItem.col = col;
        [_data setObject:fromItem forKey:[DDGameLevel keyForRow:toRow andCol:toCol]];
        [_data setObject:toItem forKey:[DDGameLevel keyForRow:row andCol:col]];
        [fromItem release];
        [toItem release];
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
