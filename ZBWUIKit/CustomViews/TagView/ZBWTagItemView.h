//
//  TagButton.h
//  Orange
//
//  Created by 朱博文 on 2017/11/1.
//  Copyright © 2017年 朱博文. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const void *ZBWTagItemView_Identify_Key;

@class ZBWTagItemView;
typedef void(^ZBWTagItemViewSelectedChangedBlock)(BOOL isSelected, ZBWTagItemView *tagItemView);
typedef void(^ZBWTagItemViewDeleteClickBlock)(ZBWTagItemView *tagItemView);
typedef BOOL(^ZBWTagItemViewShouldEditingBlock)(ZBWTagItemView *tagItemView);

typedef NS_ENUM(NSInteger, ZBWTagItemViewStyle) {
    ZBWTagItemViewStyle_Default = 0,         // 无样式
    ZBWTagItemViewStyle_CornerRadius = 1,    // 圆角，半径=4
    ZBWTagItemViewStyle_Circular = 2         // 半径=高度/2
};

typedef NS_ENUM(NSInteger, ZBWTagItemViewLineStyle) {
    ZBWTagItemViewLineStyle_Solid = 0,             // 实线
    ZBWTagItemViewLineStyle_Dashed                 // 虚线
};


@protocol ZBWTagItemViewUIProtocol <NSObject>

@optional
- (void)tagItemViewStateNormal;

- (void)tagItemViewStateSelected;

- (void)tagItemViewStateEditing;

@end

@interface ZBWTagItemView : UIView <ZBWTagItemViewUIProtocol>

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isEditing;

- (instancetype)initWithIdentify:(NSString *)identify ;

@property (nonatomic, readonly) NSString    *identify;  // reuse identify

// 样式
@property (nonatomic, assign)ZBWTagItemViewStyle style;
@property (nonatomic, assign) ZBWTagItemViewLineStyle lineStyle;
@property (nonatomic) UIColor               *selectedBgColor;
@property (nonatomic) UIColor               *selectedBorderColor;
@property (nonatomic) UIColor               *normalBgColor;
@property (nonatomic) UIColor               *normalBorderColor;

@property (nonatomic) UIColor               *selectedTextColor;
@property (nonatomic) UIColor               *normalTextColor;
@property (nonatomic) UIFont                *selectedFont;
@property (nonatomic) UIFont                *normalFont;

@property (nonatomic) UIColor               *searchHighlightTextColor;
@property (nonatomic, assign) NSRange       searchHightlightRange;

@property (nonatomic, copy) NSString              *title;
@property (nonatomic, assign) UIEdgeInsets  padding;

// 状态回调
//@property (nonatomic, copy) ZBWTagItemViewSelectedChangedBlock selectedChangeBlock;
@property (nonatomic, copy) ZBWTagItemViewShouldEditingBlock   shouldEditingBlock;

- (void)updateUI;

@end
