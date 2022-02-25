//
//  ZBWPageControlView.h
//  Orange
//
//  Created by 朱博文 on 2018/11/22.
//  Copyright © 2018年 朱博文. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBWPageControlView : UIView

@property (nonatomic, assign) int numberOfPages;
@property (nonatomic, assign) int currentPage;

@property (nonatomic) UIColor       *pointColor UI_APPEARANCE_SELECTOR; 
@property (nonatomic) UIImage       *pointImage;

@end

NS_ASSUME_NONNULL_END
