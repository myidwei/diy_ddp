//
//  DDGameMainLayer.m
//  DiyDdp
//
//  Created by xiaowei on 13-3-12.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "DDGameMainLayer.h"


@implementation DDGameMainLayer

+ (CCScene*)sceneWithLevel:(NSInteger)level
{
	CCScene *scene = [CCScene node];
    DDGameMainLayer* mainLayer = [[DDGameMainLayer alloc] initWithLevel:level];
    DDControlLayer* control = [[DDControlLayer alloc] init];
    control.delegate = mainLayer;
    [scene addChild:mainLayer];
    [scene addChild:control];
    [mainLayer release];
    return scene;
}


- (id)initWithLevel:(NSInteger)level
{
    if(self = [super init]){
        CGSize size = [[UIScreen mainScreen] bounds].size;
        _items = [[NSMutableDictionary alloc] init];
        //这里根据level计算出应该的行、列和数量
        NSInteger row = 8;
        NSInteger col = 8;
        NSInteger itemCount = 6;
        _gameLevel = [[DDGameLevel alloc] initWithSize:CGSizeMake(row,col) itemCount:itemCount];
        CGFloat startX = (size.width - col*ITEM_SIZE)/2 + ITEM_SIZE/2;
        CGFloat startY = (size.height - row*ITEM_SIZE)/2 + ITEM_SIZE/2;
        _startPoint = CGPointMake(startX,startY);

        
        [self drawBackground];
        _score = 0;
        _scoreLabel = [CCLabelTTF labelWithString:@"得分：0" fontName:@"Helvetica" fontSize:20];
        _scoreLabel.position=ccp(size.width/2, size.height - 30);
        [self addChild:_scoreLabel];
        
        [self startLevel];
        _moving = NO;
        self.isTouchEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    [_items release];
    [_gameLevel release];
    [super dealloc];
}

#pragma mark - 初始化等操作
//开局
- (void)startLevel
{
    //初始化数据
    _score = 0;
    [self drawScore];
    [_gameLevel resetLevel];
    CGSize size = [[UIScreen mainScreen] bounds].size;
    //清除所有的Item
    NSEnumerator* e = [_items objectEnumerator];
    while(YES){
        CCSprite* sprite = [e nextObject];
        if(sprite != nil){
            [sprite removeFromParentAndCleanup:YES];
        }else{
            break;
        }
    }
    [_items removeAllObjects];
    //将游戏数据加入到界面中
    NSEnumerator* items = [_gameLevel.data objectEnumerator];
    DDItem* item = nil;
    int counter = 0;
    while((item = items.nextObject)){
        if([item isEmpty])
            continue;
        CCSprite* sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"item%d.png",item.tag]];
        CGPoint position = CGPointMake(_startPoint.x + item.col * ITEM_SIZE,_startPoint.y + item.row*ITEM_SIZE);
        sprite.scale = 0.8;
        [self addChild:sprite];
        [_items setObject:sprite forKey:[DDGameLevel keyForRow:item.row andCol:item.col]];
        //动画效果
        sprite.position = ccp(position.x,position.y + 8 * ITEM_SIZE + (size.height - 8*ITEM_SIZE)/2 );
        
        CCMoveTo* move = [CCMoveTo actionWithDuration:0.3 position:position];
        CCDelayTime* delay = [CCDelayTime actionWithDuration:0.06*item.col + 0.04*item.row];
        CCScaleTo* scale = [CCScaleTo actionWithDuration:0.1 scale:1];
        CCSequence* seq = [CCSequence actions:delay,move,scale,nil];
        CCFadeIn* fadeIn = [CCFadeIn actionWithDuration:0.3+0.06*item.col + 0.04*item.row];
        
        [sprite runAction:seq];
        [sprite runAction:fadeIn];
        counter++;
    }
}


- (void)drawLevel
{
    NSEnumerator* e = [_items objectEnumerator];
    while(YES){
        CCSprite* sprite = [e nextObject];
        if(sprite != nil){
            [sprite removeFromParentAndCleanup:YES];
        }else{
            break;
        }
    }
    [_items removeAllObjects];
    NSEnumerator* items = [_gameLevel.data objectEnumerator];
    DDItem* item = nil;
    int counter = 0;
    while((item = items.nextObject)){
        if([item isEmpty])
            continue;
        CCSprite* sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"item%d.png",item.tag]];
        sprite.position = CGPointMake(_startPoint.x + item.col * ITEM_SIZE,_startPoint.y + item.row*ITEM_SIZE);
        [self addChild:sprite];
        [_items setObject:sprite forKey:[DDGameLevel keyForRow:item.row andCol:item.col]];
        counter++;
    }
}



- (void)drawBackground
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    //add background image
    CCSprite* background = [CCSprite spriteWithFile:@"iphone_bg.png"];
    background.position = ccp(size.width/2,size.height/2);
    [self addChild:background];
    for(int col=0;col<_gameLevel.cols;col++){
        for(int row=0;row<_gameLevel.rows;row++){
            CCSprite* bg = [CCSprite spriteWithFile:@"item.png"];
            bg.position = ccp(_startPoint.x + col*ITEM_SIZE, _startPoint.y + row*ITEM_SIZE);
            [self addChild:bg];
        }
    }
}

- (void)drawScore
{
    [_scoreLabel setString:[NSString stringWithFormat:@"得分：%d",_score]];
}

#pragma mark - 控制Layer代理方法
- (void)resetPressed
{
    [self startLevel];
}

- (void)hinitPressed
{
    if(_moving)
        return;
    DDItem* item = [_gameLevel hinit];
    if(item != nil)
    {
        CCSprite* sprite = [_items objectForKey:[DDGameLevel keyForRow:item.row andCol:item.col]];
        if(sprite != nil)
        {
            [self selectItem:item];
        }
    }
}

#pragma mark - 游戏逻辑 主要是交换、消除等效果的实现

- (void)exchangeFromRow:(NSInteger)row andCol:(NSInteger)col toRow:(NSInteger)toRow andCol:(NSInteger)toCol
{
    //取消选择
    CCSprite* selected = [_items objectForKey:[DDGameLevel keyForRow:_selectedItem.row andCol:_selectedItem.col]];
    if(selected != nil){
        selected.scale = 1;
        [selected stopActionByTag:99];
        [selected stopActionByTag:100];
    }
    _selectedItem = nil;
    
    //判断是否可以交换
    if((row == toRow && abs(col-toCol) == 1) || (col == toCol && abs(row-toRow) == 1)){
        _moving = YES;
        //先交换数据
        [_gameLevel exchangeFromRow:row andCol:col toRow:toRow andCol:toCol];
        //交换的动画
        CCSprite* from = [_items objectForKey:[DDGameLevel keyForRow:row andCol:col]];
        CCSprite* to = [_items objectForKey:[DDGameLevel keyForRow:toRow andCol:toCol]];
        [self reorderChild:from z:1];
        [self reorderChild:to z:2];
        CCMoveTo* t1 = [CCMoveTo actionWithDuration:0.3 position:to.position];
        CCMoveTo* f1 = [CCMoveTo actionWithDuration:0.3 position:from.position];
        
        CCCallBlock* c2 = [CCCallBlock actionWithBlock:^(){
            //交换完毕执行
            [self afterExchangeFromRow:row andCol:col toRow:toRow andCol:toCol];
        }];
        
        CCSequence* seq1 = [CCSequence actions:t1,nil];
        CCSequence* seq2 = [CCSequence actions:f1,c2,nil];
        
        [from runAction:seq1];
        [to runAction:seq2];
        
    }
}

- (void)afterExchangeFromRow:(NSInteger)row andCol:(NSInteger)col toRow:(NSInteger)toRow andCol:(NSInteger)toCol
{
    
    //判断是否有需要移除的
    NSArray* needRemove = [_gameLevel needRemoveItems];
    if([needRemove count] == 0){
        //交换回来
        [_gameLevel exchangeFromRow:toRow andCol:toCol toRow:row andCol:col];

        CCSprite* from = [_items objectForKey:[DDGameLevel keyForRow:row andCol:col]];
        CCSprite* to = [_items objectForKey:[DDGameLevel keyForRow:toRow andCol:toCol]];
        //动画效果
        [self reorderChild:from z:2];
        [self reorderChild:to z:1];
        
        CCMoveTo* t1 = [CCMoveTo actionWithDuration:0.3 position:to.position];
        CCMoveTo* f1 = [CCMoveTo actionWithDuration:0.3 position:from.position];
        CCCallBlock* c1 = [CCCallBlock actionWithBlock:^(){
            _moving = NO;
        }];
        CCSequence* seq1 = [CCSequence actions:t1,nil];
        CCSequence* seq2 = [CCSequence actions:f1,c1,nil];
        
        [from runAction:seq1];
        [to runAction:seq2];
        
    }else{
        //交换Sprite
        CCSprite* from = [[_items objectForKey:[DDGameLevel keyForRow:row andCol:col]] retain];
        CCSprite* to = [[_items objectForKey:[DDGameLevel keyForRow:toRow andCol:toCol]] retain];
        [_items setObject:from forKey:[DDGameLevel keyForRow:toRow andCol:toCol]];
        [_items setObject:to forKey:[DDGameLevel keyForRow:row andCol:col]];
        [from release];
        [to release];
        [self clearItems];
    }
}

//消除可以消除的Items
- (void)clearItems
{
    NSArray* needRemove = [_gameLevel needRemoveItems];
    if([needRemove count] > 0)
    {
        for(DDItem* item in needRemove)
        {
            CCSprite* sprite = [_items objectForKey:[DDGameLevel keyForRow:item.row andCol:item.col]];
            CCScaleTo* scale = [CCScaleTo actionWithDuration:0.2 scale:2];
            CCFadeOut* fadeOut = [CCFadeOut actionWithDuration:0.1];
            CCCallBlock* call = [CCCallBlock actionWithBlock:^(){
                [sprite removeFromParentAndCleanup:YES];
                [_items removeObjectForKey:[DDGameLevel keyForRow:item.row andCol:item.col]];
            }];
            CCSequence* seq = [CCSequence actions:scale,call, nil];
            [sprite runAction:seq];
            [sprite runAction:fadeOut];
            [self giveScore:sprite withScore:10];
        }
        [_gameLevel removeItemsIfNeed];
        _moving = NO;
        //消除以后需要继续下落
        [self performSelector:@selector(moveDownItems) withObject:self afterDelay:0.3];
    }else{
        if([_gameLevel needReset]){
            [self startLevel];
        }
    }
}

//得分效果
- (void)giveScore:(CCSprite*)sprite withScore:(NSInteger)score
{
    _score+=10;
    CCLabelTTF* label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%d",score] fontName:@"Thonburi-Bold" fontSize:20];
    label.scale = 0.5;
    [label setColor:ccc3(255, 0, 255)];
    label.position = sprite.position;
    CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:ccp(label.position.x,label.position.y + 100)];
    CCFadeOut* fadeOut = [CCFadeOut actionWithDuration:1];
    CCScaleTo* scacle = [CCScaleTo actionWithDuration:1 scale:1.3];
    CCSpawn* spawn = [CCSpawn actions:move,fadeOut,scacle, nil];
    CCCallBlock* call = [CCCallBlock actionWithBlock:^{
        [self drawScore];
        [label removeFromParentAndCleanup:YES];
    }];
    CCSequence* seq = [CCSequence actions:spawn, call,nil];
    [self addChild:label];
    [label runAction:seq];
}

- (void)moveDownItems
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    NSArray* moves = [_gameLevel moveDownItemsIfNeed];
    NSArray* newItems = [_gameLevel fillItems];
    if(moves)
    {
        //动画
        for(DDMove* move in moves)
        {
            CCSprite* sprite = [_items objectForKey:[DDGameLevel keyForRow:move.fromRow andCol:move.fromCol]];
            CCMoveTo* moveAct = [CCMoveTo actionWithDuration:0.3 position:ccp(sprite.position.x,sprite.position.y - (move.fromRow-move.toRow)*ITEM_SIZE)];
            [sprite runAction:moveAct];
            [_items setObject:sprite forKey:[DDGameLevel keyForRow:move.toRow andCol:move.toCol]];
        }
        for(DDItem* item in newItems)
        {
            CCSprite* sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"item%d.png",item.tag]];
            CGPoint position = CGPointMake(_startPoint.x + item.col * ITEM_SIZE,_startPoint.y + item.row*ITEM_SIZE);
            [self addChild:sprite];
            [_items setObject:sprite forKey:[DDGameLevel keyForRow:item.row andCol:item.col]];
            //动画效果
            sprite.position = ccp(position.x,position.y + 8 * ITEM_SIZE + (size.height - 8*ITEM_SIZE)/2 );
            CCMoveTo* move = [CCMoveTo actionWithDuration:0.3 position:position];
            [sprite runAction:move];
        }
        
        
        CCDelayTime* delay = [CCDelayTime actionWithDuration:0.4];
        CCCallBlock* call = [CCCallBlock actionWithBlock:^(){
            [self clearItems];
        }];
        CCSequence* seq = [CCSequence actions:delay,call, nil];
        [self runAction:seq];
    }else{
        
    }
}

#pragma mark - 触摸、交互

- (DDItem*)touchItem:(UITouch*)touch
{
    CGPoint point = [touch locationInView: [touch view]];
    point = [[CCDirector sharedDirector] convertToGL: point];
    point = ccp(point.x + ITEM_SIZE/2,point.y + ITEM_SIZE/2);
    if(point.x > _startPoint.x && point.x < _startPoint.x + 8 * ITEM_SIZE && point.y > _startPoint.y && point.y < _startPoint.y + 8 * ITEM_SIZE)
    {
        CGPoint obj = ccp((point.x - _startPoint.x)/ITEM_SIZE,(point.y - _startPoint.y)/ITEM_SIZE);
        int row = (int)obj.y;
        int col = (int)obj.x;
        DDItem* item = [_gameLevel.data objectForKey:[DDGameLevel keyForRow:row andCol:col]];
        if(item != nil)
            return item;
    }
    return nil;
}

- (void)selectItem:(DDItem*)item
{
    if(item == _selectedItem || [item isEmpty]){
        return;
    }
    if(_selectedItem == nil){
        CCScaleTo* zoomOut = [CCScaleTo actionWithDuration:0.1 scale:1.1];
        CCScaleTo* zoomIn = [CCScaleTo actionWithDuration:0.1 scale:0.9];
        CCSequence* seq = [CCSequence actions:zoomOut, zoomIn, nil];
        CCRepeatForever* rep = [CCRepeatForever actionWithAction:seq];
        
        CCRotateTo* r1 = [CCRotateTo actionWithDuration:0.2 angle:10];
        CCRotateTo* r2 = [CCRotateTo actionWithDuration:0.2 angle:-10];
        CCSequence* seq2 = [CCSequence actions:r1, r2, nil];
        CCRepeatForever* rep2 = [CCRepeatForever actionWithAction:seq2];
        rep2.tag = 100;
        rep.tag = 99;
        _selectedItem = item;
        CCSprite* selected = [_items objectForKey:[DDGameLevel keyForRow:item.row andCol:item.col]];
        if(selected != nil){
            [selected runAction:rep];
            [selected runAction:rep2];
        }
    }else{
        if([_selectedItem isNextToItem:item]){
            [self exchangeFromRow:_selectedItem.row andCol:_selectedItem.col toRow:item.row andCol:item.col];
        }else{
            CCSprite* selected = [_items objectForKey:[DDGameLevel keyForRow:_selectedItem.row andCol:_selectedItem.col]];
            if(selected != nil){
                selected.scale = 1;
                [selected stopActionByTag:99];
                [selected stopActionByTag:100];
            }
            _selectedItem = nil;
        }
        
    }
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_moving)
        return;
    UITouch* touch = [touches anyObject];
    DDItem* item = [self touchItem:touch];
    if(item == nil)
        return;
    [self selectItem:item];
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_moving)
        return;
    UITouch* touch = [touches anyObject];
    DDItem* item = [self touchItem:touch];
    if(item == nil)
        return;
    [self selectItem:item];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_moving)
        return;
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


@end
