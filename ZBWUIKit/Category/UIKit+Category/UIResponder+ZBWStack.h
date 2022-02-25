//
//  UIResponder+ZBWStack.h
//  ZBWUIKit
//
//  Created by 朱博文 on 16/12/22.
//  Copyright © 2016年 朱博文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (ZBWStack)

/**
 *  获取页面栈
 *  从当前Responder开始，往【下】获取页面栈。
 *  比如：
 *            [rootViewController]       [rootViewController]     [Push]          [Present]
 *            UIWindow | UINavigationController  | UIViewController | UIViewController |  UIViewController
 *  当前页面栈为：   W   ->         Navi           ->          A      ->          B      ->      C
 *  调用 [C zbw_stackResponders], 返回@(W, Navi, A, B, C)
 *
 *  @return 返回页面栈
 */
- (NSArray *)zbw_stackResponders;


/**
 *  获取页面栈
 *  从当前Responder开始，往【上】获取页面栈。
 *  比如：
 *            [rootViewController]       [rootViewController]     [Push]          [Present]
 *            UIWindow | UINavigationController  | UIViewController | UIViewController |  UIViewController
 *  当前页面栈为：   W   ->         Navi           ->          A      ->          B      ->      C
 *  调用 [W zbw_reverseStackResponders], 返回@(W, Navi, A, B, C)
 *
 *  @return 返回页面栈
 */
- (NSArray *)zbw_reverseStackResponders;


- (UINavigationController *)zbw_topNavigationController;

- (UINavigationController *)zbw_bottomNavigationController;

- (UITabBarController *)zbw_topTabBarController;

- (UITabBarController *)zbw_bottomTabBarController;


- (id)zbw_topVC:(Class)aClass;
- (id)zbw_bottomVC:(Class)aClass;


@end
