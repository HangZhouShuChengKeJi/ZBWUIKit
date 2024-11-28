//
//  UIView+LoadingView.m
//  Orange
//
//  Created by 朱博文 on 2017/5/17.
//  Copyright © 2017年 朱博文. All rights reserved.
//

#import "UIView+ZBWLoadingView.h"
#import <objc/runtime.h>

static const void *UIView$ZBWLoadingView_Key                         = &UIView$ZBWLoadingView_Key;
static const void *UIView$ZBWLVTipLabel_Key                            = &UIView$ZBWLVTipLabel_Key;
static const void *UIView$ZBWLVBgView_Key                              = &UIView$ZBWLVBgView_Key;

static const void *UIView$ZBWLVNSOperation_Key                         = &UIView$ZBWLVNSOperation_Key;

#define LV_DefaultOffsetY       50

@implementation UIView (ZBWLoadingView)

- (NSOperation *)zbwDelayOperation {
    return objc_getAssociatedObject(self, UIView$ZBWLVNSOperation_Key);
}

- (void)setZbwDelayOperation:(NSOperation *) operation{
    objc_setAssociatedObject(self, UIView$ZBWLVNSOperation_Key, operation, OBJC_ASSOCIATION_RETAIN);
}

- (void)zbw_defaultLoading
{
    [self zbw_loadingOffetY:LV_DefaultOffsetY];
}

- (void)zbw_defaultLoadingWithTipStr:(NSString *)tipStr
{
    [self zbw_loadingWithTipStr:tipStr offsetY:LV_DefaultOffsetY];
}


- (void)zbw_loading
{
    [self zbw_loadingOffetY:0];
}

- (void)zbw_loadingOffetY:(CGFloat)offsetY
{
    [self zbw_loadingWithTipStr:nil offsetY:offsetY];
}

- (void)zbw_loadingWithTipStr:(NSString *)tipStr
{
    [self zbw_loadingWithTipStr:tipStr offsetY:0];
}

- (void)zbw_loadingWithTipStr:(NSString *)tipStr offsetY:(CGFloat)offsetY
{
    if (!self.zbw_loadingView)
    {
        self.zbw_loadingView = [ZBWLoadingView loadingInView:self];
        [self.zbw_loadingView loading];
    }
    [self bringSubviewToFront:self.zbw_loadingView];
    self.zbw_loadingView.center = CGPointMake(self.zbw_loadingView.center.x, self.zbw_loadingView.center.y + offsetY);
    
    if (tipStr)
    {
        if (!self.zbw_lv_tipLabel)
        {
            self.zbw_lv_tipLabel = [[UILabel alloc] init];
            self.zbw_lv_tipLabel.numberOfLines = 0;
            self.zbw_lv_tipLabel.textAlignment = NSTextAlignmentCenter;
            self.zbw_lv_tipLabel.font = [UIFont systemFontOfSize:16];
            self.zbw_lv_tipLabel.textColor = [UIColor whiteColor];
            self.zbw_lv_tipLabel.backgroundColor = [UIColor clearColor];
        }
        self.zbw_lv_tipLabel.text = tipStr;
        
        self.zbw_lv_tipLabel.frame = CGRectMake(0, 0, self.frame.size.width - 40, 100);
        [self.zbw_lv_tipLabel sizeToFit];
        
        if (!self.zbw_lv_bgView) {
            self.zbw_lv_bgView = [[UIView alloc] init];
            self.zbw_lv_bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
            self.zbw_lv_bgView.layer.cornerRadius = 6;
            self.zbw_lv_bgView.layer.masksToBounds = YES;
            
            [self addSubview:self.zbw_lv_bgView];
        }
        CGFloat lv_bgH = self.zbw_loadingView.height + self.zbw_lv_tipLabel.height + 10*3;
        CGFloat lv_bgW = MAX(self.zbw_loadingView.width, self.zbw_lv_tipLabel.width) + 10*2;
        self.zbw_lv_bgView.frame = CGRectMake((self.width - lv_bgW)/2, (self.height - lv_bgH)/2, lv_bgW, lv_bgH);
        
        [self.zbw_lv_bgView addSubview:self.zbw_loadingView];
        [self.zbw_lv_bgView addSubview:self.zbw_lv_tipLabel];
        self.zbw_loadingView.centerX = self.zbw_lv_tipLabel.centerX = lv_bgW/2;
        self.zbw_loadingView.top = 10;
        self.zbw_lv_tipLabel.top = self.zbw_loadingView.bottom + 10;
    }
    else
    {
        [self.zbw_lv_tipLabel removeFromSuperview];
        self.zbw_lv_tipLabel = nil;
        
        [self.zbw_lv_bgView removeFromSuperview];
        self.zbw_lv_bgView = nil;
    }
    
}

//- (void)loadingWithTipStr:(NSString *)tipStr offsetY:(CGFloat)offsetY
//{
//    if (!self.lv_loadingView)
//    {
//        self.lv_loadingView = [LoadingView loadingInView:self];
//        [self.lv_loadingView loading];
//    }
//    [self bringSubviewToFront:self.lv_loadingView];
//    self.lv_loadingView.center = CGPointMake(self.lv_loadingView.center.x, self.lv_loadingView.center.y + offsetY);
////    [self.lv_loadingView loading];
//
//    CGRect loadingViewFrame = self.lv_loadingView.frame;
//
//    if (tipStr)
//    {
//        if (!self.lv_tipLabel)
//        {
//            self.lv_tipLabel = [[UILabel alloc] init];
//            self.lv_tipLabel.numberOfLines = 0;
//            self.lv_tipLabel.textAlignment = NSTextAlignmentCenter;
//            self.lv_tipLabel.font = kZBW_Font_Mid_2;
//            self.lv_tipLabel.textColor = kZBW_Color_White;
//            self.lv_tipLabel.backgroundColor = [UIColor clearColor];
//            [self addSubview:self.lv_tipLabel];
//        }
//        self.lv_tipLabel.text = tipStr;
//
//        self.lv_tipLabel.frame = CGRectMake(0, 0, self.frame.size.width - 40, 100);
//        [self.lv_tipLabel sizeToFit];
//        CGRect rect = self.lv_tipLabel.frame;
//        rect.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(rect)) / 2;
//        rect.origin.y = CGRectGetHeight(loadingViewFrame) + loadingViewFrame.origin.y + 10;
//
//        self.lv_tipLabel.frame = rect;
//        [self bringSubviewToFront:self.lv_tipLabel];
//
//        if (!self.lv_bgView) {
//            self.lv_bgView = [[UIView alloc] init];
//            self.lv_bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
//            self.lv_bgView.layer.cornerRadius = 6;
//            self.lv_bgView.layer.masksToBounds = YES;
//
//
//            CGFloat lv_bgX = MIN(self.lv_tipLabel.frame.origin.x, self.lv_loadingView.frame.origin.x);
//            CGFloat lv_bgY = MIN(self.lv_loadingView.frame.origin.y, self.lv_tipLabel.frame.origin.y);
//            CGFloat lv_bgW = MAX(CGRectGetMaxX(self.lv_tipLabel.frame), CGRectGetMaxX(self.lv_loadingView.frame)) - lv_bgX;
//            CGFloat lv_bgH = MAX(CGRectGetMaxY(self.lv_tipLabel.frame), CGRectGetMaxY(self.lv_loadingView.frame)) -lv_bgY;
//            CGRect lv_frame = CGRectMake(lv_bgX, lv_bgY, lv_bgW, lv_bgH);
//            self.lv_bgView.frame = CGRectInset(lv_frame, -10, -10);
//
//            [self insertSubview:self.lv_bgView belowSubview:self.lv_loadingView];
//        }
//    }
//    else
//    {
//        [self.lv_tipLabel removeFromSuperview];
//        self.lv_tipLabel = nil;
//
//        [self.lv_bgView removeFromSuperview];
//        self.lv_bgView = nil;
//    }
//
//}

- (void)zbw_loadingWithTipStr:(NSString *)tipStr offsetY:(CGFloat)offsetY afterTime:(float)afterTime {
    NSBlockOperation *delayShowOperation = [NSBlockOperation blockOperationWithBlock:^{
        
    }];
    
    [self setZbwDelayOperation:delayShowOperation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
        if (delayShowOperation.isCancelled) {
            return ;
        }
        [self zbw_loadingWithTipStr:tipStr offsetY:offsetY];
    });
}

- (void)zbw_dismssLoading
{
    [[self zbwDelayOperation] cancel];
    [self setZbwDelayOperation:nil];
    
    [self.zbw_loadingView removeFromSuperview];
    self.zbw_loadingView = nil;
    
    [self.zbw_lv_tipLabel removeFromSuperview];
    self.zbw_lv_tipLabel = nil;
    
    [self.zbw_lv_bgView removeFromSuperview];
    self.zbw_lv_bgView = nil;
}

- (void)setZbw_loadingView:(ZBWLoadingView *)zbw_loadingView
{
    objc_setAssociatedObject(self, UIView$ZBWLoadingView_Key, zbw_loadingView, OBJC_ASSOCIATION_RETAIN);
}

- (ZBWLoadingView *)zbw_loadingView
{
    return objc_getAssociatedObject(self, UIView$ZBWLoadingView_Key);
}


- (void)setZbw_lv_tipLabel:(UILabel *)zbw_lv_tipLabel
{
    objc_setAssociatedObject(self, UIView$ZBWLVTipLabel_Key, zbw_lv_tipLabel, OBJC_ASSOCIATION_RETAIN);
}

- (UILabel *)zbw_lv_tipLabel
{
    return objc_getAssociatedObject(self, UIView$ZBWLVTipLabel_Key);
}

- (void)setZbw_lv_bgView:(UIView *)zbw_lv_bgView {
    objc_setAssociatedObject(self, UIView$ZBWLVBgView_Key, zbw_lv_bgView, OBJC_ASSOCIATION_RETAIN);
}

- (UIView *)zbw_lv_bgView {
    return objc_getAssociatedObject(self, UIView$ZBWLVBgView_Key);
}

@end
