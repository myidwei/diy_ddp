//
//  DDGameMainLayer.h
//  DiyDdp
//
//  Created by xiaowei on 13-3-12.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DDGameLevel.h"
#import "DDItem.h"
#define ITEM_SIZE 40

@interface DDGameMainLayer : CCLayer {
    NSInteger _level;
    DDGameLevel* _gameLevel;
    NSMutableDictionary* _items;
    CGPoint _startPoint;
    BOOL _moving;
    DDItem* _selectedItem;
}

+ (CCScene*)sceneWithLevel:(NSInteger)level;

- (id)initWithLevel:(NSInteger)level;
- (void)startLevel;
- (void)exchangeFromRow:(NSInteger)row andCol:(NSInteger)col toRow:(NSInteger)toRow andCol:(NSInteger)toCol;

@end
