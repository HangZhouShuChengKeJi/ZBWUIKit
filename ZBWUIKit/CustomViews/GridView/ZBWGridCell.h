//
//  GridCell.h
//  iSing
//
//  Created by bwzhu on 13-6-25.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZBWGridCellButton;
@class ZBWGridCell;
@protocol ZBWGridCellDelegate <NSObject>

- (void)onGridButtonClick:(id)item;

- (void)onSelectItem:(ZBWGridCell *)gridCell dataItem:(id)item isSelected:(BOOL)selected;

@end


// cell中button的间距等信息
struct ZBWAlign
{
    CGFloat left;       // 左间距
    CGFloat top;        // 上间距
    CGFloat right;      // 右间距
    CGFloat bottom;     // 下间距
    CGFloat between;    // 按钮之间的间距
};
typedef struct ZBWAlign ZBWAlign;

// *******************************************
// 格网列表的cell，基类
// *******************************************
@interface ZBWGridCell : UITableViewCell
{
    NSMutableArray              *_btns;             // button数组
    NSUInteger                  _colume;                // 列数
    ZBWAlign                       _align;                 // 按钮边距和间距
}
@property(nonatomic, weak)id<ZBWGridCellDelegate>    delegate;

// 空白区域占位view的颜色。比如一行最多显示3个，但是最后一行只显示了1个，那么后面两个使用占位view。 默认为clear。
@property (nonatomic, retain) UIColor   *spaceAreaColor;

- (void)setEdit:(BOOL)isEditing;

// 功能：设置cell对应的数据，并构造btn
// 参数：［items］数据数组
// 返回值：无
- (void)setDataArray:(NSArray *)items;


// 功能：设置cell对应的数据，并构造btn
// 参数：［items］数据数组  ［colume］最大的列数
// 返回值：无
- (void)setDataArray:(NSArray *)items colume:(NSUInteger)colume;


// --------------------------------
// 子类重写
// --------------------------------

// 功能：创建cell中对应的栏目btn
// 参数：无
// 返回值：返回栏目btn
- (ZBWGridCellButton *)createButton;

- (void)setAlign:(ZBWAlign)align;

@end
