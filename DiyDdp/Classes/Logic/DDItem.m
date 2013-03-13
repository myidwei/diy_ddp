//
//  DDItem.m
//  DiyDdp
//
//  Created by xiaowei on 13-3-12.
//
//

#import "DDItem.h"

@implementation DDItem
@synthesize image = _image;
@synthesize row = _row;
@synthesize col = col;
@synthesize tag = _tag;

+ (DDItem*)emptyItem
{
    DDItem* item = [[[DDItem alloc] initWithTag:-1] autorelease];
    return item;
}

+ (DDItem*)itemWithTag:(NSInteger)tag
{
    DDItem* item = [[[DDItem alloc] initWithTag:tag] autorelease];
    item.tag = tag;
    return item;
}

- (id)initWithTag:(NSInteger)tag
{
    if(self = [super init]){
        if(tag != -1){
            _tag = tag;
        }
    }
    return self;
}

- (void)dealloc
{
    if(_image != nil){
        [_image release];
    }
    [super dealloc];
}


@end
