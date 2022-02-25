//
//  GridCellButton.h
//  iSing
//
//  Created by bwzhu on 13-6-25.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZBWGridViewData : NSObject
@property(nonatomic, retain)id      data;
@property(nonatomic,assign)BOOL     isChoosed;

@property (nonatomic, assign) NSInteger index;

@end

// ********************************************
// 格网按钮的基类
//
// ********************************************
@interface ZBWGridCellButton : UIButton
@property(nonatomic, retain)id  data; // 对应的数据
@property(nonatomic, assign)BOOL    isEditing; // 是否为编辑状态
@property(nonatomic, assign)BOOL    isChoosed;

#pragma mark 子类重写
- (void)setEdit:(BOOL)isEditing;

- (void)setChoosed:(BOOL)Choosed;

@end
