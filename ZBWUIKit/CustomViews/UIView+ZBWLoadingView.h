//
//  UIView+ZBWLoadingView.h
//  Orange
//
//  Created by 朱博文 on 2017/5/17.
//  Copyright © 2017年 朱博文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBWLoadingView.h"

@interface UIView (ZBWLoadingView)

@property (nonatomic) UILabel *zbw_lv_tipLabel;
@property (nonatomic, weak) ZBWLoadingView   *zbw_loadingView;
@property (nonatomic) UIView  *zbw_lv_bgView;

- (void)zbw_defaultLoading;

- (void)zbw_defaultLoadingWithTipStr:(NSString *)tipStr;

- (void)zbw_loading;

- (void)zbw_loadingOffetY:(CGFloat)offsetY;

- (void)zbw_loadingWithTipStr:(NSString *)tipStr;

- (void)zbw_loadingWithTipStr:(NSString *)tipStr offsetY:(CGFloat)offsetY;

- (void)zbw_loadingWithTipStr:(NSString *)tipStr offsetY:(CGFloat)offsetY afterTime:(float)afterTime;

- (void)zbw_dismssLoading;

@end
