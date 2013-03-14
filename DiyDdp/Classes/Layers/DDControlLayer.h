//
//  DDControlLayer.h
//  DiyDdp
//
//  Created by xiaowei on 13-3-14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol DDControlLayerDelegate <NSObject>

- (void)resetPressed;
- (void)hinitPressed;

@end

@interface DDControlLayer : CCLayer {
    id<DDControlLayerDelegate> _delegate;
}

@property (assign,nonatomic) id<DDControlLayerDelegate> delegate;

@end
