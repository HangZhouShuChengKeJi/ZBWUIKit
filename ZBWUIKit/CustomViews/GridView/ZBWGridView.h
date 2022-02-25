//
//  GridView.h
//  iSing
//
//  Created by bwzhu on 13-6-25.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PullTableView.h"
#import "ZBWGridCell.h"
@class ZBWGridView;
/**
 *  格网控件的代理
 */
@protocol ZBWGridViewDelegate <NSObject>

// 点击格网按钮
- (void)onClickGridBtn:(ZBWGridView *)gridView data:(id)data;

// 设置格网的列数
- (NSInteger)numOfColumns:(ZBWGridView *)gridView ;

// 设置格网行高
- (float)heightOfRow:(ZBWGridView *)gridView;

// 设置格网按钮间距
- (ZBWAlign)alignOfCellBtn:(ZBWGridView *)gridView;

@optional
- (void)onChange:(ZBWGridView *)gridView;   //modified by chester.lee 外面要知道里面的数据变化

// 下拉，刷新格网
- (void)onGridViewRefresh:(ZBWGridView *)gridView;

// 上拉，加载更多
- (void)onGridViewLoadMore:(ZBWGridView *)gridView;

@end

@interface ZBWGridView : UIView<UITableViewDelegate, UITableViewDataSource, ZBWGridCellDelegate>
{
    UITableView         *_tableView;            // 列表
    NSMutableArray      *_items;
    
    BOOL                _isEditing;             // 是否为编辑状态
    NSMutableArray      *_selectedArray;
    
}
@property(nonatomic, weak)id<ZBWGridViewDelegate>         delegate;
@property(nonatomic, retain)NSMutableArray              *items;
@property(nonatomic, retain)NSMutableArray      *selectedArray;
@property(nonatomic, readonly) UITableView      *tableView;
@property(nonatomic) Class                      cellClazz;

// 空白区域占位view的颜色。比如一行最多显示3个，但是最后一行只显示了1个，那么后面两个使用占位view。 默认为clear。
@property(nonatomic, retain) UIColor            *spaceAreaColor;


- (void)setEdit:(BOOL)isEdit;

// 用于定制cell
- (Class)cellClass;

- (CGRect)getTableViewFrame:(CGRect)bounds;

- (void)reloadData;

- (void)setHasNext:(BOOL)hasNext;

- (const NSMutableArray *)getSelectedItems;
@end
