//
//  ZBWPageControlView.m
//  Orange
//
//  Created by 朱博文 on 2018/11/22.
//  Copyright © 2018年 朱博文. All rights reserved.
//

#import "ZBWPageControlView.h"
@implementation ZBWPageControlView

- (instancetype)init
{
    if (self=[super init]) {
        if (!self.pointColor) {
            self.pointColor = [ZBWPageControlView appearance].pointColor;
        }
        self.pointImage = [UIImage zbw_createCycleImageWithColor:self.pointColor radius:6];
    }
    return self;
}

- (void)setNumberOfPages:(int)numberOfPages{
    if (numberOfPages == _numberOfPages) {
        return;
    }
    
    _numberOfPages = numberOfPages;
    self.clipsToBounds = NO;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (numberOfPages > 1) {
        float width = 0;
        for (int i = 0; i < numberOfPages; i ++) {
            if (i == 0) {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, 18, 6)];
                btn.tag = 100 + i;
                UIImage *image = self.pointImage;
                image = [image stretchableImageWithLeftCapWidth:3 topCapHeight:0];
                [btn setBackgroundImage:image forState:UIControlStateNormal];
                [self addSubview:btn];
                width += 18+8;
            } else {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(width + 8, 0, 6, 6)];
                btn.tag = 100 + i;
                [btn setBackgroundImage:self.pointImage forState:UIControlStateNormal];
                btn.alpha = .5;
                [self addSubview:btn];
                width += 14;
            }
        }
        self.width = width;
        self.height = 6;
    }
}

- (void)setCurrentPage:(int)currentPage{
    [UIView animateWithDuration:.3 animations:^{
        float width = 0;
        for (int i = 0; i < self.numberOfPages; i ++) {
            UIButton *btn = (UIButton *)[self viewWithTag:100+i];
            UIImage *image = self.pointImage;
            image = [image stretchableImageWithLeftCapWidth:3 topCapHeight:0];
            if (i == currentPage) {
                btn.frame = CGRectMake(width + 8, 0, 18, 6);
                width += 18+8;
                btn.alpha = 1;
            } else {
                btn.frame = CGRectMake(width + 8, 0, 6, 6);
                width += 14;
                btn.alpha = .5;
            }
            [btn setBackgroundImage:image forState:UIControlStateNormal];
        }
    }];
}

@end
