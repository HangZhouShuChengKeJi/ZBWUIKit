//
//  UITableView+ZBWAddition.h
//  Orange
//
//  Created by 朱博文 on 2017/5/22.
//  Copyright © 2017年 朱博文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (ZBWAddition)

// 删除多余的分割线
- (void)zbw_disappearMoreSeparator;

// tableview 的cell分割线，左边对齐
- (void)zbw_separatorAlign;

// iOS 11,默认开启self-sizing，导致cell刷新异常。在此关闭；
- (void)zbw_closeSelfSizing;

@end


typedef NS_ENUM(NSInteger, ZBWTableEmptyState) {
    ZBWTableEmptyState_Normal = 0,
    ZBWTableEmptyState_SucceedAndEmpty,
    ZBWTableEmptyState_ErrorAndEmpty,
    ZBWTableEmptyState_Requesting
};

typedef void(^ZBWTableViewEmptyStateChangeBlock)(int oldState, int newState, UIView *emptyView);

@interface UITableView (ZBWAddition_EmptyView)

@property (nonatomic) UIView    *zbw_emptyView;
@property (nonatomic, assign) NSInteger zbw_emptyState;
@property (nonatomic, copy) ZBWTableViewEmptyStateChangeBlock   zbw_emptyStateChangeBlock;

@end
