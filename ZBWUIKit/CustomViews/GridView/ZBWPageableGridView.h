//
//  ZBWPageableGridView.h
//  Orange
//
//  Created by 朱博文 on 2018/11/22.
//  Copyright © 2018年 朱博文. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class ZBWPageableGridView;
@protocol ZBWPageableGridViewDelegate <NSObject>

@required
- (ZBWGridView *)zbwPageableGridView:(ZBWPageableGridView *)pageableGridView atIndex:(NSInteger)index;

- (NSInteger)numberOfPagesInZbwPageableGridView:(ZBWPageableGridView *)pageableGridView;

@end

@interface ZBWPageableGridView : UIView

@property (nonatomic, weak) id<ZBWPageableGridViewDelegate> delegate;

//@property (nonatomic, retain) NSMutableArray    *items;

- (void)setPagePointImage:(UIImage *)image;

- (void)reloadData;

- (ZBWGridView *)dequeueReusableGridView:(NSInteger)index;

- (void)showAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
