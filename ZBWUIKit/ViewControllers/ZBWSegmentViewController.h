//
//  ZBWSegmentViewController.h
//  ContactDemo
//
//  Created by Bowen on 15/11/17.
//  Copyright © 2015年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBWSegmentView.h"

@interface UIViewController (ZBWSegment)
@property (nonatomic) NSString      *zbw_segmentIdentify;
@property (nonatomic) NSInteger     zbw_segmentIndex;
@end


@class ZBWSegmentViewController;
@class ZBWSegmentItem;
@protocol ZBWSegmentViewControllerPotocol <NSObject>

- (UIViewController *)segmentVC:(ZBWSegmentViewController *)segmentVC vcForIndex:(NSInteger)index;

- (NSArray<ZBWSegmentItem *> *)segmentItems:(ZBWSegmentViewController *)segmentVC;

- (void)segmentVC:(ZBWSegmentViewController *)segmentVC willDisplayVC:(UIViewController *)vc forIndex:(NSInteger)index;
- (void)segmentVC:(ZBWSegmentViewController *)segmentVC didEndDisplayingVC:(UIViewController *)vc forIndex:(NSInteger)index;

@end


@interface ZBWSegmentViewController : UIViewController

@property (nonatomic, assign) float                                 heightOfSegmentView; // segment高度 默认56
@property (nonatomic, assign) ZBWSegmentItemDisplayType             segmentItemDisplayType;
@property (nonatomic) UIColor                                       *selectionIndicatorColor; // 默认[UIColor orangeColor]
@property (nonatomic) UIColor                                       *bgColorOfSegmentView; // 默认 [UIColor whiteColor]
@property (nonatomic, readonly) NSInteger                           currentIndex;
@property (nonatomic, weak, readonly) UIViewController              *currentVc;

@property (nonatomic, readonly) UIScrollView                        *scrollView;

@property (nonatomic, weak) id<ZBWSegmentViewControllerPotocol>      dataSource;


@property (nonatomic, assign) BOOL                                  dontCleanOtherVC; // 划出屏幕不卸载。默认NO：卸载。

// 垂直偏移量
@property (nonatomic, assign) float                                 offsetY; // segmentview 、scrollview整体垂直偏移


- (UIViewController *)dequeueReusableVCWithIdentifier:(NSString *)identifier;


- (void)reloadSegmentView;
- (void)reloadData;
- (void)showViewControllerAtIndex:(NSInteger)index;

- (void)showViewControllerAtIndex:(NSInteger)index animation:(BOOL)animation;

- (void)setOffsetY:(float)offsetY animation:(BOOL)animation;

- (void)setSegmentViewHidden:(BOOL)hidden animated:(BOOL)animated;

@end
