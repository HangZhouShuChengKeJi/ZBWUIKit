//
//  GridCell.m
//  iSing
//
//  Created by bwzhu on 13-6-25.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import "ZBWGridCell.h"
#import "ZBWGridCellButton.h"

@interface ZBWGridCell ()

@property (nonatomic) UIView    *placeholderView;

@end

@implementation ZBWGridCell
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _btns = [[NSMutableArray alloc] init];
        _colume = 0;
    }
    return self;
}

- (void)setEdit:(BOOL)isEditing
{
    for (ZBWGridCellButton *btn in _btns)
    {
        [btn setEdit:isEditing];
    }
}

// 按钮点击效果
- (void)onBtnClick:(ZBWGridCellButton *)button
{
    if (button.isEditing)
    {
//        button.isChoosed = !button.isChoosed;
        [button setChoosed:!button.isChoosed];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onSelectItem:dataItem:isSelected:)])
        {
            [_delegate onSelectItem:self dataItem:((ZBWGridViewData *)button.data).data isSelected:button.isChoosed];
        }
    }
    else
    {
        if (_delegate && [_delegate respondsToSelector:@selector(onGridButtonClick:)])
        {
            [_delegate onGridButtonClick:((ZBWGridViewData *)button.data).data];
        }
    }
}

- (void)setDataArray:(NSArray *)items
{
    _colume = _colume == 0 ? items.count : _colume;
    NSInteger remainCount = _btns.count;
    for (int i = 0 ; i < items.count ; i++)
    {
        id item = [items objectAtIndex:i];
        // 如果存在btn
        if (i <= remainCount - 1)
        {
            [(ZBWGridCellButton *)[_btns objectAtIndex:i] setData:item];
        }
        else
        {
            ZBWGridCellButton *btn = [self createButton];
            if (btn)
            {
                btn.data = item;
                [btn addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [_btns addObject:btn];
                [self.contentView addSubview:btn];
            }
        }
    }
    
    // 删除多余的btn
    if (remainCount > items.count)
    {
        NSInteger count = remainCount;
        while (count > items.count)
        {
            id btn = [_btns objectAtIndex:--count];
            [_btns removeObject:btn];
            [btn removeFromSuperview];
        }
    }
}

- (void)setDataArray:(NSArray *)items colume:(NSUInteger)colume
{
    _colume = colume;
    [self setDataArray:items];
}

- (void)setAlign:(ZBWAlign)align
{
    _align = align;
}

- (void)setColume:(NSUInteger)colume
{
    _colume = colume;
}

- (ZBWGridCellButton *)createButton
{
    return nil;
}

// 重新布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentFrame = self.frame;
    CGFloat left = _align.left;
    CGFloat right = _align.right;
    CGFloat top = _align.top;
    CGFloat bottom = _align.bottom;
    CGFloat beteew = _align.between;
    
    // 按钮高度
    CGFloat btnHeight = contentFrame.size.height - top - bottom;
    CGFloat btnWidth = (contentFrame.size.width - left - right - (_colume - 1) * beteew) / _colume;
    
    CGRect btnRect = CGRectMake(left, top, btnWidth, btnHeight);
    for (ZBWGridCellButton *btn in _btns)
    {
        btn.frame = btnRect;
        btnRect.origin.x += btnWidth + beteew;
    }
    
    if (self.spaceAreaColor) {
        [self.contentView addSubview:self.placeholderView];
        self.placeholderView.frame = CGRectMake(btnRect.origin.x, btnRect.origin.y, contentFrame.size.width - btnRect.origin.x, btnHeight);
        self.placeholderView.backgroundColor = self.spaceAreaColor;
    }
    
}

- (UIView *)placeholderView {
    if (!_placeholderView) {
        _placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    return _placeholderView;
}


@end
