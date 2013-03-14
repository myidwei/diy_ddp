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
    //游戏数据
    DDGameLevel* _gameLevel;
    //要显示的Sprite数据
    NSMutableDictionary* _items;
    //开始位置的坐标
    CGPoint _startPoint;
    //是否动画正在执行（执行过程不能操作）
    BOOL _moving;
    //已选择的Item
    DDItem* _selectedItem;
}

+ (CCScene*)sceneWithLevel:(NSInteger)level;

- (id)initWithLevel:(NSInteger)level;
- (void)startLevel;
- (void)exchangeFromRow:(NSInteger)row andCol:(NSInteger)col toRow:(NSInteger)toRow andCol:(NSInteger)toCol;

@end
