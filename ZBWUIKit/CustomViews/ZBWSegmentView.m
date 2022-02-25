//
//  ZBWSegmentView.m
//  
//
//  Created by Bowen on 16/4/20.
//  Copyright © 2016年. All rights reserved.
//

#import "ZBWSegmentView.h"

@interface ZBWSegmentItem ()

@property (nonatomic) UIButton            *itemView;
@property (nonatomic) CGFloat           offsetX;
@property (nonatomic) CGFloat           width;
@property (nonatomic) CGFloat           contentWidth;


@property (nonatomic) NSInteger         index;
@property (nonatomic) BOOL              isSelected;


@property (nonatomic, copy) dispatch_block_t  clickBlock;

@end

@implementation ZBWSegmentItem

- (instancetype)init
{
    if (self = [super init]) {
        self.normalColor = [UIColor blackColor];
        self.normalFont = [UIFont systemFontOfSize:14];
        self.selectedFont = [UIFont systemFontOfSize:16];
        self.selectedColor = [UIColor orangeColor];
        self.spaceH = 10;
    }
    return self;
}

- (UIButton *)itemView
{
    if (!_itemView) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        [btn addTarget:self action:@selector(onBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *customView = nil;
        if ([self respondsToSelector:@selector(customView)]) {
            customView = [self customView];
        }
        
        _itemView = btn;
        
        if (customView) {
            [_itemView addSubview:customView];
            
            self.width = customView.width + 2*self.spaceH;
        } else {
            if (self.bgImage) {
                [btn setBackgroundImage:self.bgImage forState:UIControlStateNormal];
            }
            if (self.normalImage && self.selectedImage) {
                [btn setImage:self.normalImage forState:UIControlStateNormal];
                [btn setImage:self.selectedImage forState:UIControlStateHighlighted];
                [btn setImage:self.selectedImage forState:UIControlStateSelected];
                self.contentWidth = self.selectedImage.size.width;
            }
            else if (self.title) {
                [btn setTitle:self.title forState:UIControlStateNormal];
                [btn setTitleColor:self.normalColor forState:UIControlStateNormal];
                [btn setTitleColor:self.selectedColor forState:UIControlStateHighlighted];
                [btn setTitleColor:self.selectedColor forState:UIControlStateSelected];
                btn.titleLabel.font = self.normalFont;
                
                self.contentWidth = [self.title boundingRectWithSize:CGSizeMake( 200, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.selectedFont} context:nil].size.width;
            }
            
            [_itemView sizeToFit];
            self.width = _itemView.frame.size.width + 2*self.spaceH;
        }
        
    }
    return _itemView;
}

- (void)onBtnClick
{
    self.clickBlock ? self.clickBlock() : nil;
}

#pragma mark-

#pragma mark- Setter

- (void)setIsSelected:(BOOL)isSelected
{
    if (_isSelected == isSelected) {
        return;
    }
    _isSelected = isSelected;
    
    if (_isSelected) {
        self.itemView.titleLabel.font = self.selectedFont ?: self.normalFont;
    } else {
        self.itemView.titleLabel.font = self.normalFont;
    }
    self.itemView.selected = isSelected;
    
    if ([self respondsToSelector:@selector(segmentItem:selectedChanged:)]) {
        [self segmentItem:self selectedChanged:isSelected];
    }
}

- (void)setWidth:(CGFloat)width
{
    _width = width;
    CGRect rect = self.itemView.frame;
    rect.size.width = width;
    self.itemView.frame = rect;
    
    if ([self respondsToSelector:@selector(segmentItem:containerFrameChanged:)]) {
        [self segmentItem:self containerFrameChanged:rect];
    }
}

- (void)setOffsetX:(CGFloat)offsetX
{
    _offsetX = offsetX;
    CGRect rect = self.itemView.frame;
    rect.origin.x = _offsetX;
    self.itemView.frame = rect;
}

- (void)setNormalFont:(UIFont *)normalFont
{
    if (!normalFont) {
        return;
    }
    
    _normalFont = normalFont;
}

- (void)setSelectedFont:(UIFont *)selectedFont
{
    if (!selectedFont) {
        return;
    }
    
    _selectedFont = selectedFont;
}

- (void)setNormalColor:(UIColor *)normalColor
{
    if (!normalColor) {
        return;
    }
    
    _normalColor = normalColor;
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    if (!selectedColor) {
        return;
    }
    
    _selectedColor = selectedColor;
}

@end

@interface ZBWSegmentView ()

@property (nonatomic, assign) CGFloat   horizontalMargin;
@property (nonatomic) UIScrollView      *scrollView;
@property (nonatomic) UIView            *selectionIndicatorView;

@end

@implementation ZBWSegmentView

+ (instancetype)initWithFrame:(CGRect)frame
                horizontalMargin:(CGFloat)horizontalMargin
         selectionIndicatorColor:(UIColor *)selectionIndicatorColor
                  displayType:(ZBWSegmentItemDisplayType)displayType
                     segmentItem:(NSArray<ZBWSegmentItem *> *)items
{
    ZBWSegmentView *segmentView = [[ZBWSegmentView alloc] initWithFrame:frame];
    segmentView.horizontalMargin = horizontalMargin;
    segmentView.selectionIndicatorColor = selectionIndicatorColor;
    segmentView.displayType = displayType;
    segmentView.items = items;

    return segmentView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initData];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

- (void)initData
{
    _selectedIndex = -1;
    self.horizontalMargin = 10;
    self.selectionIndicatorColor = [UIColor orangeColor];
    [self addSubview:self.scrollView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateUI];
}

- (void)updateUI
{
    self.scrollView.frame = self.bounds;
    
    NSInteger scrollWidth = self.scrollView.frame.size.width;
    NSInteger count = _items.count;
    CGFloat offsetX = self.horizontalMargin;
    for (int i = 0; i < count; i++) {
        ZBWSegmentItem *item = _items[i];
        __weak typeof(self) weakSelf = self;
        item.clickBlock = ^{
            weakSelf.selectedIndex = i;
            // 回调上层
            weakSelf.indexChangeBlock ? weakSelf.indexChangeBlock(i) : nil;
        };
        item.offsetX = offsetX;
        UIView *view = item.itemView;
        CGRect rect = view.frame;
        rect.size.height = CGRectGetHeight(self.bounds);
        view.frame = rect;
        
        offsetX += item.width;
        [self.scrollView addSubview:view];
    }
    offsetX += self.horizontalMargin;
    
    // 如果没有填充满，要填充满
    if (count > 0 && offsetX < scrollWidth) {
        switch (self.displayType) {
            case ZBWSegmentItemDisplayType_Center:
            {
                CGFloat addOffsetX = (scrollWidth - offsetX)/2;
                for (int i = 0 ; i < self.items.count; i++) {
                    ZBWSegmentItem *item = self.items[i];
                    item.offsetX += addOffsetX;
                }
            }
                break;
            case ZBWSegmentItemDisplayType_FullWidth:
            {
                CGFloat addWidth = (scrollWidth - offsetX)/count;
                for (int i = 0 ; i < self.items.count; i++) {
                    ZBWSegmentItem *item = self.items[i];
                    item.width += addWidth;
                    item.offsetX += addWidth * i;
                }
            }
            default:
                break;
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(offsetX, CGRectGetHeight(self.bounds));
    
    [self.scrollView addSubview:self.selectionIndicatorView];
    CGRect rect = self.selectionIndicatorView.frame;
    rect.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(rect);
    self.selectionIndicatorView.frame = rect;
}

- (void)setItems:(NSArray<ZBWSegmentItem *> *)items
{
    _items = items;
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self updateUI];
}

#pragma mark- Setter

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (self.items.count <= selectedIndex) {
        return;
    }
//    if (_selectedIndex == selectedIndex) {
//        return;
//    }
    
    // 之前的选中item，修改成未选中
    if (_selectedIndex >= 0 && _selectedIndex < self.items.count) {
        ZBWSegmentItem *lastSelecteItem = self.items[_selectedIndex];
        lastSelecteItem.isSelected = NO;
    }
    
    _selectedIndex = selectedIndex;
    ZBWSegmentItem *selectedItem = self.items[selectedIndex];
    selectedItem.isSelected = YES;
    
    // 选中标记view，动画
    CGRect rect = self.selectionIndicatorView.frame;
//    rect.origin.x = selectedItem.offsetX;
//    rect.size.width = selectedItem.width;
    rect.origin.x = selectedItem.offsetX + (selectedItem.width - selectedItem.contentWidth)/2;
    rect.size.width = selectedItem.contentWidth;
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.selectionIndicatorView.frame = rect;
    } completion:nil];
    
    // scroll 到中间
    CGRect visibleRect = self.scrollView.bounds;
    visibleRect.origin.x = ((selectedItem.offsetX + selectedItem.width/2) - CGRectGetWidth(visibleRect)/2);
    [self.scrollView scrollRectToVisible:visibleRect animated:YES];
}

- (void)setSelectionIndicatorColor:(UIColor *)selectionIndicatorColor
{
    if (!selectionIndicatorColor) {
        return;
    }
    _selectionIndicatorColor = selectionIndicatorColor;
    
    _selectionIndicatorView.backgroundColor = selectionIndicatorColor;
}

#pragma mark- Getter

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)selectionIndicatorView
{
    if (!_selectionIndicatorView) {
        _selectionIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
        _selectionIndicatorView.userInteractionEnabled = NO;
        _selectionIndicatorView.backgroundColor = self.selectionIndicatorColor;
    }
    
    return _selectionIndicatorView;
}

@end
