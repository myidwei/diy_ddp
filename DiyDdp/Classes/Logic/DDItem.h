//
//  DDItem.h
//  DiyDdp
//
//  Created by xiaowei on 13-3-12.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface DDItem : NSObject
{
    //标记
    NSInteger _tag;//tag = 0表示未设定
    //在游戏中的位置(行,列)，从0开始，左下角开始
    NSInteger _row;
    NSInteger _col;
    //图片
    NSString* _image;
}

@property (assign,nonatomic) NSInteger tag;
@property (assign,nonatomic) NSInteger row;
@property (assign,nonatomic) NSInteger col;
@property (copy,nonatomic) NSString*   image;

+ (DDItem*)emptyItem;
+ (DDItem*)itemWithTag:(NSInteger)tag;

- (BOOL)isEmpty;
- (id)initWithTag:(NSInteger)tag;
- (BOOL)isNextToItem:(DDItem*)item;
@end
