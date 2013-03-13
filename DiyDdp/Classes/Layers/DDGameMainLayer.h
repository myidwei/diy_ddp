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

@interface DDGameMainLayer : CCLayer {
    NSInteger _level;
    DDGameLevel* _gameLevel;
    NSMutableArray* _items;
    CGPoint _startPoint;
}

+ (CCScene*)sceneWithLevel:(NSInteger)level;

- (id)initWithLevel:(NSInteger)level;

- (void)drawLevel;

@end
