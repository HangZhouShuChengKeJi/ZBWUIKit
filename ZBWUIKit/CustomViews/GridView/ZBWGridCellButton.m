//
//  GridCellButton.m
//  iSing
//
//  Created by bwzhu on 13-6-25.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import "ZBWGridCellButton.h"

@implementation ZBWGridViewData

@end



@implementation ZBWGridCellButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.exclusiveTouch = YES;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setData:(id)data
{
    _data = data;
    
    ZBWGridViewData *a = (ZBWGridViewData *)_data;
    [self setChoosed:a.isChoosed];
}

#pragma mark 子类重写
- (void)setEdit:(BOOL)isEditing
{}

- (void)setChoosed:(BOOL)Choosed
{}
@end
