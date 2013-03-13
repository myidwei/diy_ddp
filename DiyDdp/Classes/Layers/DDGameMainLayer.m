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
        _items = [[NSMutableArray alloc] init];
        //这里根据level计算出应该的行、列和数量
        NSInteger row = 8;
        NSInteger col = 8;
        NSInteger itemCount = 10;
        _gameLevel = [[DDGameLevel alloc] initWithSize:CGSizeMake(row,col) itemCount:itemCount];
        [_gameLevel resetLevel];
        CGFloat startX = (size.width - col*38)/2 + 38/2;
        CGFloat startY = (size.height - row*38)/2 + 38/2;
        _startPoint = CGPointMake(startX,startY);
        [self drawBackground];
        [self drawLevel];
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
    //add background image
    
    for(int col=0;col<_gameLevel.cols;col++){
        for(int row=0;row<_gameLevel.rows;row++){
            CCSprite* bg = [CCSprite spriteWithFile:@"item.png"];
            bg.position = ccp(_startPoint.x + col*38, _startPoint.y + row*38);
            [self addChild:bg];
        }
    }
}

- (void)drawLevel
{
    for(CCSprite* sprite in _items){
        [sprite removeFromParentAndCleanup:YES];
    }
    [_items removeAllObjects];
    NSEnumerator* items = [_gameLevel.data objectEnumerator];
    DDItem* item = nil;
    while((item = items.nextObject)){
        CCSprite* sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"item%d.png",item.tag]];
        sprite.position = CGPointMake(_startPoint.x + item.col * 38,_startPoint.y + item.row*38);
        sprite.scale = 0.8;
        [self addChild:sprite];
        [_items addObject:sprite];
    }
}


@end
