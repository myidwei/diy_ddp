//
//  DDItemSprite.m
//  DiyDdp
//
//  Created by xiaowei on 13-3-12.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "DDItemSprite.h"


@implementation DDItemSprite

- (id)initWithItem:(DDItem*)item
{
    if(self = [super init]){
        _item = [item retain];
        CCSprite* background = [CCSprite spriteWithFile:@"item.png"];
        [self addChild:background];
        
    }
    return self;
}

- (void)dealloc
{
    [_item release];
    [super dealloc];
}

@end
