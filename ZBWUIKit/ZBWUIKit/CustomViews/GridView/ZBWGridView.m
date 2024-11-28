//
//  GridView.m
//  iSing
//
//  Created by bwzhu on 13-6-25.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import "ZBWGridView.h"
#import "ZBWGridCell.h"
#import "ZBWGridCellButton.h"
@implementation ZBWGridView

@synthesize delegate = _delegate, items = _items;
@synthesize selectedArray = _selectedArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initSubViews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    _tableView.frame = [self getTableViewFrame:self.bounds];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _tableView.frame = [self getTableViewFrame:self.bounds];
}

- (void)initSubViews {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[self getTableViewFrame:self.bounds]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //        _tableView.pullDelegate = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:_tableView];
    }
}

#pragma mark 外部调用

- (UITableView *)tableView
{
    return _tableView;
}

- (const NSMutableArray *)getSelectedItems
{
    if (_isEditing)
    {
        return _selectedArray;
    }
    return nil;
}

- (void)reloadData
{
    [_tableView reloadData];
//    _tableView.pullTableIsRefreshing = NO;
//    _tableView.pullTableIsLoadingMore = NO;
}

- (void)setHasNext:(BOOL)hasNext
{
//    [_tableView setHasNext:hasNext];
}

- (void)setEdit:(BOOL)isEdit
{
    if (_isEditing == isEdit)
    {
        return;
    }
    _isEditing = isEdit;
    _selectedArray = nil;
    [self reloadData];
}

#pragma 子类重写

- (Class)cellClass
{
    return [ZBWGridCell class];
}

- (CGRect)getTableViewFrame:(CGRect)bounds
{
    return bounds;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegate heightOfRow:self];
}

#pragma mark 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = _items.count;
    NSInteger column = [_delegate numOfColumns:self];
    if (count == 0)
    {
        return 0;
    }
    if (column != 0)
    {
        if (count % column == 0)
        {
            return count / column;
        }
        else
        {
            return count / column + 1;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"gridView";
    ZBWGridCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        Class cellClass = self.cellClazz;
        if (!cellClass) {
            cellClass = [self cellClass];
        }
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.spaceAreaColor = self.spaceAreaColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setAlign:[_delegate alignOfCellBtn:self]];
        cell.delegate = self;
    }
    // 获取cell对应的数据
    NSInteger index = indexPath.row;
    NSInteger columnCount = [_delegate numOfColumns:self];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:columnCount];
    for (NSInteger i = index * columnCount; i < _items.count; i++)
    {
        ZBWGridViewData *data = [[ZBWGridViewData alloc] init];
        data.index = i;
        data.data = [_items objectAtIndex:i];
        data.isChoosed = [_selectedArray containsObject:data.data];
        [items addObject:data];
        if (items.count == columnCount)
        {
            break;
        }
    }
    // 设置cell对应的数据
    [cell setDataArray:items colume:columnCount];
    [cell setEdit:_isEditing];
    return cell;
}

#pragma mark GridCellDelegate

- (void)onGridButtonClick:(id)item
{
    if (_delegate && [_delegate respondsToSelector:@selector(onClickGridBtn:data:)]) {
        [_delegate onClickGridBtn:self data:item];
    }
}

- (void)onSelectItem:(ZBWGridCell *)gridCell dataItem:(id)item isSelected:(BOOL)selected
{
    if (!_selectedArray)
    {
        _selectedArray = [[NSMutableArray alloc] init];
    }
    if (selected)
    {
        if (![_selectedArray containsObject:item])
        {
            [_selectedArray addObject:item];
        }
    }
    else
    {
        if ([_selectedArray containsObject:item])
        {
            [_selectedArray removeObject:item];
        }
}
    
    
    // added by chester.lee 2013-1-20,外部要清楚里面的变化
    if (_delegate && [_delegate respondsToSelector:@selector(onChange:)]) {
        [_delegate onChange:self];
    }
    
}

- (void)onDoNothing
{
    [_tableView reloadData];
//    _tableView.pullTableIsLoadingMore = NO;
//    _tableView.pullTableIsRefreshing = NO;
}

//#pragma mark PullTableViewDelegate
//- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView
//{
//    if (_delegate && [_delegate respondsToSelector:@selector(onGridViewRefresh:)])
//    {
//        [_delegate onGridViewRefresh:self];
//    }
//    else
//    {
//        [self performSelector:@selector(onDoNothing) withObject:nil afterDelay:0.2];
//    }
//}
//
//- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
//{
//    if (_delegate && [_delegate respondsToSelector:@selector(onGridViewLoadMore:)])
//    {
//        [_delegate onGridViewLoadMore:self];
//    }
//    else
//    {
//        [self performSelector:@selector(onDoNothing) withObject:nil afterDelay:0.2];
//    }
//}

@end
