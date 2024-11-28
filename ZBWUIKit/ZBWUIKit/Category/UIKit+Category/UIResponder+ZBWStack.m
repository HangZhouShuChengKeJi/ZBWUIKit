//
//  UIResponder+ZBWStack.m
//  ZBWUIKit
//
//  Created by 朱博文 on 16/12/22.
//  Copyright © 2016年 朱博文. All rights reserved.
//

#import "UIResponder+ZBWStack.h"

@implementation UIResponder (ZBWStack)

- (NSArray *)zbw_stackResponders
{
    NSMutableArray *stackArray = [NSMutableArray arrayWithCapacity:5];
    if ([self isKindOfClass:[UIWindow class]])
    {
        [stackArray insertObject:self atIndex:0];
        NSArray *array = [self.nextResponder zbw_stackResponders];
        if (array.count > 0)
        {
            [stackArray insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)]];
        }
    }
    else if([self isKindOfClass:[UIView class]])
    {
        NSArray *array = [self.nextResponder zbw_stackResponders];
        if (array.count > 0)
        {
            [stackArray insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)]];
        }
    }
    else if([self isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)self;
        UIViewController *selectedVC = tabBarController.selectedViewController;
        NSArray *array = [selectedVC zbw_stackResponders];
        if (array.count > 0)
        {
            [stackArray insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)]];
        }
        [stackArray insertObject:tabBarController atIndex:0];
    }
    else if([self isKindOfClass:[UINavigationController class]])
    {
        NSArray *vcsOfNav = [(UINavigationController *)self viewControllers];
        [stackArray insertObjects:vcsOfNav atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, vcsOfNav.count)]];
        [stackArray insertObject:self atIndex:0];
        
        //
        NSArray *array = [self.nextResponder zbw_stackResponders];
        if (array.count > 0)
        {
            [stackArray insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)]];
        }
    }
    else if([self isKindOfClass:[UIViewController class]])
    {
        UIViewController *vc = (UIViewController *)self;
        if (vc.navigationController)
        {
            NSArray *array = [vc.navigationController zbw_stackResponders];
            if (array.count > 0)
            {
                [stackArray insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)]];
            }
        }
        else
        {
            [stackArray insertObject:self atIndex:0];
            NSArray *array = [self.nextResponder zbw_stackResponders];
            if (array.count > 0)
            {
                [stackArray insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)]];
            }
        }
        
    }
    
    return [stackArray copy];

}

- (NSArray *)zbw_reverseStackResponders
{
    NSMutableArray *stackArray = [NSMutableArray arrayWithCapacity:5];
    
    if ([self isKindOfClass:[UIWindow class]])
    {
        UIWindow *window = (UIWindow *)self;
        [stackArray insertObject:self atIndex:0];
        
        if (window.rootViewController)
        {
            [stackArray addObjectsFromArray:[window.rootViewController zbw_reverseStackResponders]];
        }
    }
    else if([self isKindOfClass:[UIView class]])
    {
    }
    else if([self isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)self;
        [stackArray addObject:tabBarController];
        
        if (tabBarController.presentedViewController) {
            [stackArray addObject:[tabBarController.presentedViewController zbw_reverseStackResponders]];
        } else {
            UIViewController *selectedVC = tabBarController.selectedViewController;
            [stackArray addObjectsFromArray:[selectedVC zbw_reverseStackResponders]];
        }
    }
    else if([self isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navVC = (UINavigationController *)self;
        //        NSArray *vcsOfNav = [(UINavigationController *)self viewControllers];
        
        [stackArray addObject:self];
//        [stackArray addObjectsFromArray:navVC.viewControllers];
        
        if (navVC.presentedViewController)
        {
            [stackArray addObjectsFromArray:[navVC.presentedViewController zbw_reverseStackResponders]];
        } else {
//            [stackArray removeObject:navVC.topViewController];
            [stackArray addObjectsFromArray:[navVC.topViewController zbw_reverseStackResponders]];
        }
    }
    else if([self isKindOfClass:[UIViewController class]])
    {
        UIViewController *vc = (UIViewController *)self;
        
//        if (vc.navigationController)
//        {
//            [stackArray addObjectsFromArray:[vc.navigationController zbw_reverseStackResponders]];
//        }
//        else
//        {
            [stackArray addObject:vc];
            if (vc.presentedViewController)
            {
                [stackArray addObjectsFromArray:[vc.presentedViewController zbw_reverseStackResponders]];
            } else {
                [vc.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (![obj.view zbw_outsideWithView:vc.view]) {
                        [stackArray addObjectsFromArray:[obj zbw_reverseStackResponders]];
                    }
                }];
//                [stackArray addObjectsFromArray:vc.childViewControllers];
            }
//        }
    }
    
    return [stackArray copy];
}


- (id)zbw_topVC:(Class)aClass
{
    NSArray *topArray = [self zbw_reverseStackResponders];
    __block id returnObj = nil;
    [topArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:aClass]) {
            returnObj = obj;
            *stop = YES;
        }
    }];
    
    if (returnObj) {
        return returnObj;
    }
    
    NSArray *bototomArray = [self zbw_stackResponders];
    [bototomArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:aClass]) {
            returnObj = obj;
            *stop = YES;
        }
    }];
    return returnObj;
}

- (id)zbw_bottomVC:(Class)aClass
{
    __block id returnObj = nil;
    
    NSArray *bototomArray = [self zbw_stackResponders];
    [bototomArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj class] == aClass) {
            returnObj = obj;
            *stop = YES;
        }
    }];
    
    if (returnObj) {
        return returnObj;
    }
    
    NSArray *topArray = [self zbw_reverseStackResponders];
    [topArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj class] == aClass) {
            returnObj = obj;
            *stop = YES;
        }
    }];
    
    return returnObj;
}

- (UINavigationController *)zbw_topNavigationController
{
    return [self zbw_topVC:[UINavigationController class]];
}

- (UINavigationController *)zbw_bottomNavigationController
{
    return [self zbw_bottomVC:[UINavigationController class]];
}

- (UITabBarController *)zbw_topTabBarController
{
    return [self zbw_topVC:[UITabBarController class]];
}

- (UITabBarController *)zbw_bottomTabBarController
{
    return [self zbw_bottomVC:[UITabBarController class]];
}


@end
