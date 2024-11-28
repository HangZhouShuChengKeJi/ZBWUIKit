//
//  ZBWMarqueeView.h
//  ZBWUIKit
//
//  Created by dinghuachao on 2024/11/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBWMarqueeView : UIView
@property (nonatomic, strong) NSString  * title;
+ (instancetype)marqueeBarWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font;
- (void)updateTitle:(NSString *)title;
- (void)updateTitleColor:(UIColor *)titleColor;

- (void)updateTitleFont:(UIFont *)titleFont;

- (void)resume;

@property (nonatomic, assign) BOOL  titleLoop;

@end

NS_ASSUME_NONNULL_END
