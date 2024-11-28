//
//  ZBWTagView.h
//  Orange
//
//  Created by 朱博文 on 2017/10/31.
//  Copyright © 2017年 朱博文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBWTagItemView.h"

typedef NS_ENUM(NSInteger, ZBWTagView_ShowType) {
    ZBWTagView_ShowType_OneLine = 0,       // 单行显示，左右滚动
    ZBWTagView_ShowType_MultiLine = 1      // 多行显示，上下滚动
};

typedef NS_ENUM(NSInteger, ZBWTagView_SelectType) {
    ZBWTagView_SelectType_CannotSelect = 0, // 不可选
    ZBWTagView_SelectType_SingleSelect = 1, // 单选
    ZBWTagView_SelectType_MultiSelect = 2   // 多选
};

@class ZBWTagView;

typedef NSInteger (^CountOfTagInTagViewCallback)(ZBWTagView *tagView);
typedef ZBWTagItemView *(^TagItemViewOfTagViewCallback)(ZBWTagView *tagView, NSInteger index);
typedef void(^TagItemViewSelectedChangedCallback)(ZBWTagView *tagView, BOOL isSelected, NSInteger index);
typedef void(^TagItemViewDeleteClickCallback)(ZBWTagView *tagView, NSInteger index);
typedef void(^TagItemViewLongPressCallback)(ZBWTagView *tagView, NSInteger index);

@interface ZBWTagView : UIView

// 显示类型
@property (nonatomic, assign) ZBWTagView_ShowType showType; // 默认 TagView_ShowType_MultiLine
// 选择类型
@property (nonatomic, assign) ZBWTagView_SelectType selectType;    // 默认TagView_SelectType_SingleSelect

// 边距 内边距
@property (nonatomic, assign) UIEdgeInsets      edge;   // 默认UIEdgeInsetsMake(10, 10, 10, 10)
// 水平间距 TagItemView 水平间距
@property (nonatomic, assign) CGFloat           hSpace; // 默认10
// 垂直间距 TagItemView 垂直间距
@property (nonatomic, assign) CGFloat           vSpace; // 默认15

// 是否自动调整高度，让内容完全显示。与maxHeight配合使用，最高不超过maxHeight。
@property (nonatomic, assign) BOOL              autoSizeHeight; // 默认 NO
@property (nonatomic, assign) CGFloat           minHeight;  // 默认0
@property (nonatomic, assign) CGFloat           maxHeight; // 默认0

// 宽度自适应
@property (nonatomic, assign) BOOL              autoSizeWidth; // 默认 NO
@property (nonatomic, assign) CGFloat           minWidth;  // 默认0
@property (nonatomic, assign) CGFloat           maxWidth; // 默认0



#pragma mark= Datasource callback
@property (nonatomic, copy) CountOfTagInTagViewCallback countOfTagInTagViewCallback;
@property (nonatomic, copy) TagItemViewOfTagViewCallback  tagItemViewOfTagViewCallback;

#pragma mark- Event callback
@property (nonatomic, copy) TagItemViewSelectedChangedCallback  tagItemViewSelectedChangedCallback;
@property (nonatomic, copy) TagItemViewDeleteClickCallback  tagItemViewDeleteClickCallback;
@property (nonatomic, copy) TagItemViewLongPressCallback    tagItemViewLongPressCallback;

@property (nonatomic, assign, readonly) BOOL     isEditing;


- (void)setEditing:(BOOL)isEditing;

- (void)reloadData;

- (ZBWTagItemView *)reuseTagItemView:(NSString *)identify;

- (ZBWTagItemView *)tagItemViewOfIndex:(NSInteger)index;
- (NSInteger)indexOfTagItemView:(ZBWTagItemView *)tagItemView;


@end
