//
//  ZBWLoadingView.h
//  
//
//  Created by Bowen on 15/5/6.
//  Copyright (c) 2015年. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  加载view
 */
@interface ZBWLoadingView : UIView

// 前景色
@property (nonatomic, retain)UIColor            *fgLineColor UI_APPEARANCE_SELECTOR;
// 背景色
@property (nonatomic, retain)UIColor            *bgLineColor UI_APPEARANCE_SELECTOR;
// 圆的线宽，默认6
@property (nonatomic, assign)CGFloat            lineWidth;
// 一次动画的时间，默认0.5
@property (nonatomic, assign)NSTimeInterval     duration;
// 旋转角度，默认70
@property (nonatomic, assign)CGFloat            rotationAngle;

+ (ZBWLoadingView *)loadingView;

+ (ZBWLoadingView *)loadingInView:(UIView *)inView;

/**
 UI_APPEARANCE_SELECTOR 无法完全解决。 当inView还未加载的时候，UI_APPEARANCE_SELECTOR的值不会生效。
 设置默认的前景颜色
 */
+ (void)setDefaultFgLineColor:(UIColor *)color;

/**
 设置默认的背景颜色
 */
+ (void)setDefaultBgLineColor:(UIColor *)color;


/**
 *  动画。 修改上面的属性后，一定要调用loading，才会更新页面。
 */
- (void)loading;

@end

/*  example
 
 1、
LoadingView *view1 = [LoadingView loadingView];
[self.view addSubview:view1];
[view1 loading];
view1.center = CGPointMake(100, 200);

 2、
LoadingView *view2 = [LoadingView loadingInView:self.view];
view2.center = CGPointMake(100, 300);

 3、
LoadingView *view3 = [LoadingView loadingInView:self.view];
view3.frame = CGRectMake(200, 200, 100, 100);
view3.lineWidth = 10;
view3.fgLineColor = [UIColor redColor];
view3.bgLineColor = [UIColor greenColor];
view3.duration = 1;
[view3 loading];

 4、
LoadingView *view4 = [LoadingView loadingInView:self.view];
view4.frame = CGRectMake(200, 400, 60, 100);
view4.lineWidth = 10;
view4.fgLineColor = [UIColor redColor];
view4.duration = .5;
view4.rotationAngle = 30;
[view4 loading];
 
 */
