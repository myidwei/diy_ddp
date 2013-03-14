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
    [scene addChild:mainLayer];
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

- (void)exchangeFromRow:(NSInteger)row andCol:(NSInteger)col toRow:(NSInteger)toRow andCol:(NSInteger)toCol
{
    
    CCSprite* selected = [_items objectForKey:[DDGameLevel keyForRow:_selectedItem.row andCol:_selectedItem.col]];
    if(selected != nil){
        selected.scale = 1;
        [selected stopActionByTag:99];
    }
    _selectedItem = nil;
    
    if((row == toRow && abs(col-toCol) == 1) || (col == toCol && abs(row-toRow) == 1)){
        
        //先交换数据
        [_gameLevel exchangeFromRow:row andCol:col toRow:toRow andCol:toCol];
        NSArray* needRemove = [_gameLevel needRemoveItems];
        if([needRemove count] == 0){
            _moving = YES;
            //交换回来
            [_gameLevel exchangeFromRow:toRow andCol:toCol toRow:row andCol:col];
            
            //动画效果
            CCSprite* from = [_items objectForKey:[DDGameLevel keyForRow:row andCol:col]];
            CCSprite* to = [_items objectForKey:[DDGameLevel keyForRow:toRow andCol:toCol]];
            CGPoint f = from.position;
            CGPoint t = to.position;

            [self reorderChild:from z:1];
            [self reorderChild:to z:2];
            
            CCMoveTo* t1 = [CCMoveTo actionWithDuration:0.3 position:t];
            CCMoveTo* f1 = [CCMoveTo actionWithDuration:0.3 position:f];
            CCCallBlock* c1 = [CCCallBlock actionWithBlock:^(){
                [self reorderChild:from z:2];
                [self reorderChild:to z:1];
            }];
            
            
            CCMoveTo* t2 = [CCMoveTo actionWithDuration:0.3 position:t];
            CCMoveTo* f2 = [CCMoveTo actionWithDuration:0.3 position:f];
            CCCallBlock* c2 = [CCCallBlock actionWithBlock:^(){
                _moving = NO;
                if([_gameLevel needReset]){
                    [self startLevel];
                }
            }];
            CCSequence* seq1 = [CCSequence actions:t1,c1,f1,nil];
            CCSequence* seq2 = [CCSequence actions:f2,t2,c2,nil];
            
            [from runAction:seq1];
            [to runAction:seq2];
            
        }else{
            _moving = YES;
            //动画效果
            CCSprite* from = [_items objectForKey:[DDGameLevel keyForRow:row andCol:col]];
            CCSprite* to = [_items objectForKey:[DDGameLevel keyForRow:toRow andCol:toCol]];
            CGPoint f = from.position;
            CGPoint t = to.position;
            
            CCMoveTo* t1 = [CCMoveTo actionWithDuration:0.3 position:t];
            CCMoveTo* f1 = [CCMoveTo actionWithDuration:0.3 position:f];
            
            CCCallBlock* c2 = [CCCallBlock actionWithBlock:^(){
                //交换Sprite
                [_items setObject:to forKey:[DDGameLevel keyForRow:row andCol:col]];
                [_items setObject:from forKey:[DDGameLevel keyForRow:toRow andCol:toCol]];
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
                }
                [_gameLevel removeItemsIfNeed];
                _moving = NO;
                //消除以后需要继续下落
                if([_gameLevel needReset]){
                    [self startLevel];
                }
            }];
            
            CCSequence* seq1 = [CCSequence actions:t1,nil];
            CCSequence* seq2 = [CCSequence actions:f1,c2,nil];
            
            [from runAction:seq1];
            [to runAction:seq2];
            
        }
    }
}


- (void)startLevel
{
    [_gameLevel resetLevel];
    CGSize size = [[UIScreen mainScreen] bounds].size;
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
        CGPoint position = CGPointMake(_startPoint.x + item.col * ITEM_SIZE,_startPoint.y + item.row*ITEM_SIZE);
        sprite.scale = 0.8;
        [self addChild:sprite];
        [_items setObject:sprite forKey:[DDGameLevel keyForRow:item.row andCol:item.col]];
        //动画效果
        sprite.position = ccp(position.x,position.y + 8 * ITEM_SIZE + (size.height - 8*ITEM_SIZE)/2 );
        
        CCMoveTo* move = [CCMoveTo actionWithDuration:0.5 position:position];
        CCDelayTime* delay = [CCDelayTime actionWithDuration:0.06*item.col + 0.04*item.row];
        CCScaleTo* scale = [CCScaleTo actionWithDuration:0.1 scale:1];
        CCSequence* seq = [CCSequence actions:delay,move,scale,nil];
        CCFadeIn* fadeIn = [CCFadeIn actionWithDuration:0.5+0.06*item.col + 0.04*item.row];
        
        [sprite runAction:seq];
        [sprite runAction:fadeIn];
        counter++;
    }
}

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
        CCScaleTo* zoomOut = [CCScaleTo actionWithDuration:0.01 scale:1.1];
        CCScaleTo* zoomIn = [CCScaleTo actionWithDuration:0.01 scale:0.9];
        CCSequence* seq = [CCSequence actions:zoomOut, zoomIn, nil];
        CCRepeatForever* rep = [CCRepeatForever actionWithAction:seq];
        rep.tag = 99;
        _selectedItem = item;
        CCSprite* selected = [_items objectForKey:[DDGameLevel keyForRow:item.row andCol:item.col]];
        if(selected != nil){
            [selected runAction:rep];
        }
    }else{
        if([_selectedItem isNextToItem:item]){
            [self exchangeFromRow:_selectedItem.row andCol:_selectedItem.col toRow:item.row andCol:item.col];
        }else{
            CCSprite* selected = [_items objectForKey:[DDGameLevel keyForRow:_selectedItem.row andCol:_selectedItem.col]];
            if(selected != nil){
                selected.scale = 1;
                [selected stopActionByTag:99];
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
