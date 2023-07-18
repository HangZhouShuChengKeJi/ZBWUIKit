//
//  UITableView+ZBWAddition.m
//  Orange
//
//  Created by 朱博文 on 2017/5/22.
//  Copyright © 2017年 朱博文. All rights reserved.
//

#import "UITableView+ZBWAddition.h"
#import <objc/runtime.h>

#import "MJRefreshAutoNormalFooter.h"
#import "MJRefresh.h"
const void *UITableView_ZBWAddition_EmptyView_Key = &UITableView_ZBWAddition_EmptyView_Key;
const void *UITableView_ZBWAddition_EmptyView_EmptyState_Key = &UITableView_ZBWAddition_EmptyView_EmptyState_Key;
const void *UITableView_ZBWAddition_EmptyView_EmptyStateChange_Key = &UITableView_ZBWAddition_EmptyView_EmptyStateChange_Key;


@implementation UITableView (ZBWAddition_EmptyView)

+ (void)load {
//    return;
    // hook reloadData 方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = NSClassFromString(@"UITableView");
        SEL reloadSelector = @selector(reloadData);
        Method reloadMethod = class_getInstanceMethod(aClass, reloadSelector);
        
        Method zbwReloadMethod = class_getInstanceMethod(aClass, @selector(zbw_reloadData));
        method_exchangeImplementations(reloadMethod, zbwReloadMethod);
    });
}

- (void)zbw_reloadData {
//    if (!self.superview) {
//        return;
//    }
    
    [self zbw_reloadData];
    
    @try {
        NSInteger count = self.visibleCells.count;
        self.zbw_emptyView.hidden = count > 0;
        self.mj_footer.hidden = count == 0;
    }
    @catch (NSException *e) {
        
    }
    
//    NSInteger count = 0;
//    BOOL exceptioned = NO;
//    @try {
//        count = self.visibleCells.count;
//    }
//    @catch (NSException *e) {
//        exceptioned = YES;
//    }
//
//    if (exceptioned) {
//
//        @try {
//            exceptioned = NO;
//            NSInteger sections = [self.dataSource numberOfSectionsInTableView:self];
//            for (int i = 0 ; i < sections; i++) {
//                NSInteger rows = [self.dataSource tableView:self numberOfRowsInSection:i];
//                count += rows;
//                if (count > 0) {
//                    break;
//                }
//            }
//        }
//        @catch (NSException *e){
//            exceptioned = YES;
//        }
//    }
//
//    if (!exceptioned) {
//        self.zbw_emptyView.hidden = count > 0;
//    } else {
//        self.zbw_emptyView.hidden = YES;
//    }
}


- (void)setZbw_emptyView:(UIView *)zbw_emptyView {
    objc_setAssociatedObject(self, UITableView_ZBWAddition_EmptyView_Key, zbw_emptyView, OBJC_ASSOCIATION_RETAIN);
    [self addSubview:zbw_emptyView];
}

- (UIView *)zbw_emptyView {
    return objc_getAssociatedObject(self, UITableView_ZBWAddition_EmptyView_Key);
}

- (void)setZbw_emptyState:(NSInteger)zbw_emptyState {
    NSInteger oldState = self.zbw_emptyState;
    objc_setAssociatedObject(self, UITableView_ZBWAddition_EmptyView_EmptyState_Key, @(zbw_emptyState), OBJC_ASSOCIATION_RETAIN);

    UIView *view = self.zbw_emptyView;
    ZBWTableViewEmptyStateChangeBlock block = self.zbw_emptyStateChangeBlock;
    (block && view) ? block(oldState, zbw_emptyState, view) : nil;
}

- (NSInteger)zbw_emptyState {
    NSNumber *value = objc_getAssociatedObject(self, UITableView_ZBWAddition_EmptyView_EmptyState_Key);
    
    return value.integerValue;
}

- (void)setZbw_emptyStateChangeBlock:(ZBWTableViewEmptyStateChangeBlock)zbw_emptyStateChangeBlock {
    objc_setAssociatedObject(self, UITableView_ZBWAddition_EmptyView_EmptyStateChange_Key, zbw_emptyStateChangeBlock, OBJC_ASSOCIATION_COPY);
}

- (ZBWTableViewEmptyStateChangeBlock)zbw_emptyStateChangeBlock {
    return objc_getAssociatedObject(self, UITableView_ZBWAddition_EmptyView_EmptyStateChange_Key);
}

@end


@implementation UITableView (ZBWAddition)

- (void)zbw_disappearMoreSeparator {
    self.tableFooterView = [[UIView alloc] init];
    [self zbw_closeSelfSizing];
}

- (void)zbw_separatorAlign {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]){
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)]){
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)zbw_closeSelfSizing {
    self.estimatedRowHeight =0;
    self.estimatedSectionHeaderHeight =0;
    self.estimatedSectionFooterHeight =0;
}

@end
