//
//  DDItemSprite.h
//  DiyDdp
//
//  Created by xiaowei on 13-3-12.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DDItem.h"
@interface DDItemSprite : CCSprite {
    DDItem* _item;
}

- (id)initWithItem:(DDItem*)item;

@end
