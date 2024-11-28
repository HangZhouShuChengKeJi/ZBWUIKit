//
//  ZBWTagView.m
//  Orange
//
//  Created by 朱博文 on 2017/10/31.
//  Copyright © 2017年 朱博文. All rights reserved.
//

#import "ZBWTagView.h"
#import "ZBWTagItemView.h"

@interface ZBWTagView ()

// 显示的tag button list
@property (nonatomic) NSMutableArray            *usingtagBtnList;
// reuse复用缓存
@property (nonatomic) NSMutableDictionary       *reuseMap;

@property (nonatomic) UIScrollView              *scrollView;

@property (nonatomic, assign) BOOL                 isEditing;
@end

@implementation ZBWTagView

- (instancetype)init {
    if (self = [super init]) {
        [self initDefaultData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self =[super initWithFrame:frame]) {
        [self initDefaultData];
    }
    return self;
}

- (void)initDefaultData {
    self.showType = ZBWTagView_ShowType_MultiLine;
    self.selectType = ZBWTagView_SelectType_SingleSelect;
    self.edge = UIEdgeInsetsMake(10, 10, 10, 10);
    self.hSpace = 10;
    self.vSpace = 15;
}

- (void)reloadData {
    [self addSubview:self.scrollView];
    // 所有tagItemView加入到reuse缓存中
    [self moveAllTagItemViewToReuseCache];
    
    NSInteger count = self.countOfTagInTagViewCallback(self);
    if (count == 0) {
        // 高度重置
        return;
    }
    
    for (int i = 0; i < count; i++) {
        ZBWTagItemView *tagItemView = self.tagItemViewOfTagViewCallback(self, i);
        tagItemView.isEditing = self.isEditing;
        [tagItemView updateUI];
        NSAssert(tagItemView, @"【TagView】 tagItemView 不能为nil。");
        [tagItemView sizeToFit];
        [self.scrollView addSubview:tagItemView];
        // 加入到正在使用队列，删除对应的reuse缓存
        [self addToUsingList:tagItemView];
    }
    
    [self updateUI];
}

- (void)updateUI {
    if (self.usingtagBtnList.count == 0) {
        return;
    }
    
    //    int line = 0;
    CGFloat originalX = self.edge.left;
    CGFloat x = originalX;
    CGFloat y = self.edge.top;
    CGFloat width = self.width - self.edge.right;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    CGFloat height = self.height;
#pragma clang diagnostic pop
    CGFloat vSpace = self.vSpace;
    CGFloat hSpace = self.hSpace;
    
    CGFloat lastLineHeight = 0;
    
    CGFloat maxWidth = 0;
    
    if (self.showType == ZBWTagView_ShowType_OneLine) {
        for (int i = 0; i < [self.usingtagBtnList count]; i++) {
            ZBWTagItemView *btn = [self.usingtagBtnList objectAtIndex:i];
            
            btn.origin = CGPointMake(x, y);
            x += (btn.width + hSpace);
            lastLineHeight = btn.height;
        }
        
        CGFloat totalWidth = x + self.edge.right - hSpace;
        CGFloat totalHeight = y + lastLineHeight + self.edge.bottom;
        self.scrollView.contentSize = CGSizeMake(totalWidth, totalHeight);
        maxWidth = totalWidth;
    } else if (self.showType == ZBWTagView_ShowType_MultiLine) {
        for (int i = 0; i < [self.usingtagBtnList count]; i++) {
            ZBWTagItemView *btn = [self.usingtagBtnList objectAtIndex:i];
            btn.width = MIN(btn.width, width);
            
            // 当前行不可以放得下
            if (x + btn.width > width) {
                // 换行
                x = originalX;
                y += (lastLineHeight + vSpace);
            }
            
            btn.origin = CGPointMake(x, y);
            x += (btn.width + hSpace);
            lastLineHeight = btn.height;
            
            maxWidth = MAX(maxWidth, x + self.edge.right - hSpace);
        }
        
        CGFloat totalHeight = y + lastLineHeight + self.edge.bottom;
        self.scrollView.contentSize = CGSizeMake(maxWidth, totalHeight);
    }
    
    // self 自动调整大小(高度)
    if (self.autoSizeHeight) {
        self.height = MAX(MIN((self.maxHeight > 0 ? self.maxHeight : self.scrollView.contentSize.height), self.scrollView.contentSize.height), self.minHeight);
    }
    
    if (self.autoSizeWidth) {
        self.width = MAX(MIN(self.maxWidth > 0 ? self.maxWidth : maxWidth, maxWidth), self.minWidth);
    }
    
    // scrollView大小
    self.scrollView.frame = self.bounds;
}

#pragma mark- Public
- (ZBWTagItemView *)reuseTagItemView:(NSString *)identify{
    NSMutableSet *reuseSet = [self reuseSet:identify];
    return [reuseSet anyObject];
}

- (ZBWTagItemView *)tagItemViewOfIndex:(NSInteger)index {
    if (self.usingtagBtnList.count <= index) {
        return nil;
    }
    return self.usingtagBtnList[index];
}
- (NSInteger)indexOfTagItemView:(ZBWTagItemView *)tagItemView {
    return [self.usingtagBtnList indexOfObject:tagItemView];
}


- (void)addToUsingList:(ZBWTagItemView *)btn {
    // 加入到using数组
    [self.usingtagBtnList addObject:btn];
    // 从reuse缓存中删除
    NSMutableSet *reuseSet = [self reuseSet:btn.identify];
    [reuseSet removeObject:btn];
}

// 把所有使用的btn加入到复用缓存
- (void)moveAllTagItemViewToReuseCache {
    for (ZBWTagItemView *tagBtn in self.usingtagBtnList) {
        NSMutableSet *reuseSet = [self reuseSet:tagBtn.identify];
        [reuseSet addObject:tagBtn];
    }
    // 清空using数组，移出页面
    [self.usingtagBtnList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.usingtagBtnList removeAllObjects];
}

- (NSMutableSet *)reuseSet:(NSString *)identify {
    if (!identify) {
        identify = @"__TagView_NULL_identity__";
    }
    NSMutableSet *reuseSet = [self.reuseMap objectForKey:identify];
    if (!reuseSet) {
        reuseSet = [[NSMutableSet alloc] initWithCapacity:5];
        self.reuseMap[identify] = reuseSet;
    }
    return reuseSet;
}

#pragma mark- Event

ZBW_UISignal_Up_Handle(,) {
    if (ZBW_Is_Signal(@"tagItemViewClicked")) {
        signal.arrived = YES;
        if (self.selectType == ZBWTagView_SelectType_CannotSelect) {
            return;
        }
        ZBWTagItemView *tagItemView = signal.object;
        NSInteger index = [self indexOfTagItemView:tagItemView];
        
        if (self.selectType == ZBWTagView_SelectType_SingleSelect) { // 单选
            if (tagItemView.isSelected) {
                return;
            }
            tagItemView.isSelected = YES;
            [tagItemView updateUI];
            
            // 之前已选中的按钮，设置为NO
            for (ZBWTagItemView *btn in self.usingtagBtnList) {
                if (btn != tagItemView && btn.isSelected) { // 之前选中的，设置为未选中
                    btn.isSelected = NO;
                    [btn updateUI];
                    self.tagItemViewSelectedChangedCallback ? self.tagItemViewSelectedChangedCallback(self, NO, [self.usingtagBtnList indexOfObject:btn]) : nil;
                    break;
                }
            }
            self.tagItemViewSelectedChangedCallback ? self.tagItemViewSelectedChangedCallback(self, YES, index) : nil;
        } else if (self.selectType == ZBWTagView_SelectType_MultiSelect) { // 多选
            tagItemView.isSelected = !tagItemView.isSelected;
            [tagItemView updateUI];
            self.tagItemViewSelectedChangedCallback ? self.tagItemViewSelectedChangedCallback(self, tagItemView.isSelected, index) : nil;
        }
    }
}

ZBW_UISignal_Up_Handle(ZBWTagItemView, tagItemViewRemoveClicked) {
    signal.arrived = YES;
    if (!self.isEditing) {
        return;
    }
    ZBWTagItemView *tagItemView = signal.object;
    self.tagItemViewDeleteClickCallback ? self.tagItemViewDeleteClickCallback(self, [self indexOfTagItemView:tagItemView]) : nil;
}

ZBW_UISignal_Up_Handle(ZBWTagItemView, tagItemViewLongPressed) {
    signal.arrived = YES;
    ZBWTagItemView *tagItemView = signal.object;
    self.tagItemViewLongPressCallback ? self.tagItemViewLongPressCallback(self, [self indexOfTagItemView:tagItemView]) : NULL;
}

#pragma mark- Getter/Setter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    }
    return _scrollView;
}

- (NSMutableDictionary *)reuseMap {
    if (!_reuseMap) {
        _reuseMap = [[NSMutableDictionary alloc] init];
    }
    return _reuseMap;
}

- (NSMutableArray *)usingtagBtnList {
    if (!_usingtagBtnList) {
        _usingtagBtnList = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _usingtagBtnList;
}

- (void)setEditing:(BOOL)isEditing {
    if (_isEditing == isEditing) {
        return;
    }
    _isEditing = isEditing;
    [self reloadData];
}

@end
