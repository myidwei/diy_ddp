//
//  DDControlLayer.m
//  DiyDdp
//
//  Created by xiaowei on 13-3-14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "DDControlLayer.h"


@implementation DDControlLayer
@synthesize delegate = _delegate;
- (id)init
{
    if(self = [super init]){
        //menu
        CGSize size = [[UIScreen mainScreen] bounds].size;
        CCMenuItemFont* reset = [CCMenuItemFont itemWithString:@"重新开始" target:self selector:@selector(reset)];
        CCMenuItemFont* hinit = [CCMenuItemFont itemWithString:@"给我提示" target:self selector:@selector(hinit)];
        CCMenu* menu = [CCMenu menuWithItems:reset,hinit, nil];
        [menu alignItemsHorizontallyWithPadding:30];
        menu.position = ccp(size.width/2,40);
        [self addChild:menu];
    }
    return self;
}

- (void)reset
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(resetPressed)])
    {
        [_delegate resetPressed];
    }
}

- (void)hinit
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(hinitPressed)]){
        [_delegate hinitPressed];
    }
}


@end
