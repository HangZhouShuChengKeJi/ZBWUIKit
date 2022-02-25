//
//  ZBWPageableGridView.m
//  Orange
//
//  Created by 朱博文 on 2018/11/22.
//  Copyright © 2018年 朱博文. All rights reserved.
//

#import "ZBWPageableGridView.h"
#import "ZBWPageControlView.h"


#define kZBWPageableGridView_PageViewHeight 20

@interface ZBWPageableGridView ()<UIScrollViewDelegate>

//
@property (nonatomic, strong) UIScrollView      *scrollView;
// 翻页控件
@property (nonatomic, retain) UIView            *pageView;
@property (nonatomic, retain) ZBWPageControlView *pageControlView;
@property (nonatomic, retain) NSMutableArray    *reusableGridViewList;
@property (nonatomic, retain) NSMutableDictionary   *usingGridViewMap;

// 当前页码
@property (nonatomic, assign) NSInteger         currentPageIndex;
// 总页数
@property (nonatomic, assign) NSInteger         totalPages;

@property (nonatomic, retain) NSArray           *showIndexs;

@end

@implementation ZBWPageableGridView

- (instancetype)init {
    if (self = [super init]) {
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self addSubview:self.scrollView];
    [self addSubview:self.pageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    self.pageView.frame = CGRectMake(0, self.height - kZBWPageableGridView_PageViewHeight, self.width, kZBWPageableGridView_PageViewHeight);
    self.pageControlView.centerX = self.pageView.width/2;
    self.pageControlView.centerY = self.pageView.height/2;
}

- (void)setPagePointImage:(UIImage *)image {
    self.pageControlView.pointImage = image;
}

- (void)showAtIndex:(NSInteger)index {
    if (index >= self.totalPages) {
        return;
    }
    self.currentPageIndex = index;
    
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
    self.scrollView.contentOffset = CGPointMake(index*width, 0);
}

- (ZBWGridView *)dequeueReusableGridView:(NSInteger)index {
    ZBWGridView *gridView = self.usingGridViewMap[@(index)];
    if (!gridView) {
        gridView = self.reusableGridViewList.lastObject;
        if (gridView) {
            [self.reusableGridViewList removeObject:gridView];
        }
    }
    
    NSLog(@"pageableGridView 获取复用队列数据 %ld , %p", (long)index, gridView);
    return gridView;
}

- (void)reloadData {
    // 将items进行分组
    if ([self.delegate respondsToSelector:@selector(numberOfPagesInZbwPageableGridView:)]) {
        self.totalPages = [self.delegate numberOfPagesInZbwPageableGridView:self];
    } else {
        self.totalPages = 1;
    }
    
    // 如果之前停留的页面比当前最大页面还大，则当前停留在最后一页
    if (self.totalPages > 0 && self.currentPageIndex > self.totalPages - 1) {
        self.currentPageIndex = self.totalPages - 1;
    } else {
        self.currentPageIndex = MAX(self.currentPageIndex, 0);
    }
    
    NSArray *reloadIndex = nil;
    if (!self.showIndexs) {
        reloadIndex = @[@(0)];
    } else {
        if ([(NSNumber *)self.showIndexs.lastObject integerValue] < self.totalPages) {
            reloadIndex = self.showIndexs;
        } else {
            reloadIndex = @[@(self.totalPages - 1)];
        }
    }
    
    // 刷新当前显示的页面
    [self showIndexs:self.showIndexs ?: @[@(0)] force:YES];
}

- (ZBWGridView *)gridViewAtIndex:(NSInteger)index {
    ZBWGridView *gridView = [self.delegate zbwPageableGridView:self atIndex:index];
    gridView.frame = CGRectMake(index * self.scrollView.width, 0, self.scrollView.width, self.scrollView.height);
    return gridView;
}

- (void)setGridView:(ZBWGridView *)gridView atIndex:(NSInteger)index {
    if (!gridView) {
        return;
    }
    [self.scrollView addSubview:gridView];
    gridView.left = index * self.scrollView.width;
    self.usingGridViewMap[@(index)] = gridView;
}

- (void)addToReuseList:(ZBWGridView *)gridView index:(NSInteger)index{
    [gridView removeFromSuperview];
    [self.reusableGridViewList addObject:gridView];
    [self.usingGridViewMap removeObjectForKey:@(index)];
    
    NSLog(@"pageableGridView 加入到复用队列 %ld , %p", (long)index, gridView);
}

- (void)showIndexs:(NSArray *)indexs force:(BOOL)isForce {
    if (!isForce) {
        if (self.showIndexs && indexs && [[self.showIndexs componentsJoinedByString:@"|"] isEqualToString:[indexs componentsJoinedByString:@"|"]]) {
            return;
        }
    }
    self.showIndexs = indexs;
    // 回收不需要显示的gridview
    NSArray *useringKeys = self.usingGridViewMap.allKeys;
    for (int i = 0 ; i < useringKeys.count; i++) {
        NSNumber *key = useringKeys[i];
        if (![indexs containsObject:key]) {
            [self addToReuseList:self.usingGridViewMap[key] index:key.integerValue];
        }
    }
    
    // 显示需要的gridView
    [indexs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *indexNum = obj;
        ZBWGridView *gridView = [self gridViewAtIndex:indexNum.integerValue];

        [self setGridView:gridView atIndex:indexNum.integerValue];
        [gridView reloadData];
    }];
}

#pragma mark- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = scrollView.bounds.size.width;
    
    NSMutableArray *showIndexArray = [NSMutableArray arrayWithCapacity:2];
    NSInteger index = offsetX / width;
    CGFloat x = offsetX - index * width;
    
    [showIndexArray addObject:@(index)];
    if (x > 0 && index + 1 < self.totalPages) {
        [showIndexArray addObject:@(index + 1)];
    }
    
    [self showIndexs:showIndexArray force:NO];
    
    self.currentPageIndex = MAX(MIN((offsetX + width/2) /width, self.totalPages), 0);
}


#pragma mark - Getter / Setter

- (void)setTotalPages:(NSInteger)totalPages {
    _totalPages = totalPages;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * totalPages, self.scrollView.height);
    self.pageControlView.numberOfPages = (int)totalPages;
    self.pageControlView.centerX = self.pageView.width/2;
    self.pageControlView.centerY = self.pageView.height/2;
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    _currentPageIndex = currentPageIndex;
    self.pageControlView.currentPage = (int)currentPageIndex;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = YES;
    }
    return _scrollView;
}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kZBWPageableGridView_PageViewHeight, self.width, kZBWPageableGridView_PageViewHeight)];
        _pageView.backgroundColor = kZBW_Color_Clear;
        
        [_pageView addSubview:self.pageControlView];
    }
    return _pageView;
}

- (ZBWPageControlView *)pageControlView {
    if (!_pageControlView) {
        _pageControlView = [[ZBWPageControlView alloc] init];
    }
    return _pageControlView;
}

- (NSMutableArray *)reusableGridViewList {
    if (!_reusableGridViewList) {
        _reusableGridViewList = [NSMutableArray arrayWithCapacity:5];
    }
    return _reusableGridViewList;
}

- (NSMutableDictionary *)usingGridViewMap {
    if (!_usingGridViewMap) {
        _usingGridViewMap = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _usingGridViewMap;
}

@end
