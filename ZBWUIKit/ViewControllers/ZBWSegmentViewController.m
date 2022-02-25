//
//  ZBWSegmentViewController.m
//  ContactDemo
//
//  Created by Bowen on 15/11/17.
//  Copyright © 2015年. All rights reserved.
//

#import "ZBWSegmentViewController.h"
#import <objc/runtime.h>

const void *UIViewController_ZBWSegmentIdentify_Key = &UIViewController_ZBWSegmentIdentify_Key;
const void *UIViewController_ZBWSegmentIndex_Key = &UIViewController_ZBWSegmentIndex_Key;
@implementation UIViewController (ZBWSegment)

- (void)setZbw_segmentIdentify:(NSString *)zbw_segmentIdentify
{
    objc_setAssociatedObject(self, UIViewController_ZBWSegmentIdentify_Key, zbw_segmentIdentify, OBJC_ASSOCIATION_COPY);
}

- (NSString *)zbw_segmentIdentify
{
    return objc_getAssociatedObject(self, UIViewController_ZBWSegmentIdentify_Key);
}

- (void)setZbw_segmentIndex:(NSInteger)zbw_segmentIndex
{
    objc_setAssociatedObject(self, UIViewController_ZBWSegmentIndex_Key, @(zbw_segmentIndex), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)zbw_segmentIndex
{
    NSNumber *indexNum = objc_getAssociatedObject(self, UIViewController_ZBWSegmentIndex_Key);
    return indexNum ? indexNum.integerValue : -1;
}

@end



#define kTX_Segment_Y               ((self.navigationController && self.navigationController == self.parentViewController && self.navigationController.navigationBar && !self.navigationController.navigationBar.hidden) ? 64 : 0)
#define kTX_SegmentHeight          56

#define kZBWSegmentVC_No_Reuse_Identify  @"com.haihu.ZBWSegmentVC_No_Reuse_Identify"

@interface ZBWSegmentViewController ()<UIScrollViewDelegate>

@property (nonatomic) UIScrollView      *scrollView;
@property (nonatomic) ZBWSegmentView         *segmentControl;

@property (nonatomic) NSInteger         defaultIndex;

@property (nonatomic, assign) NSInteger     count;

@property (nonatomic) NSMutableDictionary   *reusableVCMap;
@property (nonatomic) NSMutableDictionary   *usingVCMap;

@property (nonatomic) NSInteger                                     currentIndex;
@property (nonatomic, weak) UIViewController                        *currentVc;

@end

@implementation ZBWSegmentViewController

- (void)reloadSegmentView
{
    // 设置segmentView
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(segmentItems:)]) {
        NSArray *items = [self.dataSource segmentItems:self];
        self.segmentControl.items = items;
        self.count = items.count;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * self.count, self.scrollView.bounds.size.height);
        self.segmentControl.selectedIndex = self.currentIndex;
    }
}

- (void)reloadData
{
    // 加入到复用
    [self.usingVCMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self addToReusableMap:obj];
    }];
    
    // 设置segmentView
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(segmentItems:)]) {
        NSArray *items = [self.dataSource segmentItems:self];
        self.segmentControl.items = items;
        self.count = items.count;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * self.count, self.scrollView.bounds.size.height);
        self.segmentControl.selectedIndex = self.currentIndex;
    }
    
    // 加载VC
    if (self.count > 0 && self.currentIndex >=0 && self.currentIndex < self.count && self.dataSource && [self.dataSource respondsToSelector:@selector(segmentVC:vcForIndex:)]) {
        UIViewController *vc = [self.dataSource segmentVC:self vcForIndex:self.currentIndex];
        [self setViewController:vc atIndex:self.currentIndex];
        self.currentVc = vc;
    }
}


- (UIViewController *)dequeueReusableVCWithIdentifier:(NSString *)identifier
{
    if (!identifier) {
        return nil;
    }
    NSLog(@"获取复用VC, identify [ %@ ]", identifier);
    return [[self reusableVCSet:identifier] anyObject];
}

- (void)showViewControllerAtIndex:(NSInteger)index {
    if (index >= self.count) {
        return;
    }
    self.currentIndex = index;
    
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
    self.scrollView.contentOffset = CGPointMake(index*width, 0);
}

- (void)showViewControllerAtIndex:(NSInteger)index animation:(BOOL)animation {
    if (index >= self.count) {
        return;
    }
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
    [self.scrollView scrollRectToVisible:CGRectMake(index*width, 0, self.scrollView.width, self.scrollView.height) animated:animation];
}

#pragma mark- 缓存
- (NSMutableSet *)reusableVCSet:(NSString *)identify
{
    NSMutableSet *set = self.reusableVCMap[identify];
    if (!set) {
        set = [NSMutableSet setWithCapacity:2];
        self.reusableVCMap[identify] = set;
    }
    return set;
}

#pragma mark 载入载出
- (void)setViewController:(UIViewController *)vc atIndex:(NSInteger)index
{
    NSLog(@"添加vc到UI, index: [ %ld ], identify: [ %@ ]", (long)index, vc.zbw_segmentIdentify);
    if (!vc.parentViewController) {
        [self addChildViewController:vc];
        [self.scrollView addSubview:vc.view];
        
        [vc didMoveToParentViewController:self];
        vc.zbw_segmentIndex = index;
        
//        vc.view.backgroundColor = [UIColor colorWithRed:(random()%255)/255.0 green:(random()%255)/255.0 blue:(random()%255)/255.0 alpha:1.0];
    }
    CGRect rect = self.scrollView.frame;
    vc.view.frame = CGRectMake(CGRectGetWidth(rect) * index, 0, CGRectGetWidth(rect), CGRectGetHeight(rect));
    
    if ([self.dataSource respondsToSelector:@selector(segmentVC:willDisplayVC:forIndex:)]) {
        [self.dataSource segmentVC:self willDisplayVC:vc forIndex:index];
    }
    [self addToUsingMap:vc];
}

- (void)removeViewController:(UIViewController *)vc
{
    if (vc.parentViewController) {
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
}

#pragma mark- life cycle

- (instancetype)init
{
    if (self = [super init]) {
        _currentIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加一个空的view，解决iOS7后，scrollview 偏移
    [self.view addSubview:[[UIView alloc] init]];
    [self.view addSubview:self.segmentControl];
    [self.view insertSubview:self.scrollView belowSubview:self.segmentControl];
    self.currentIndex = 0;
    [self reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setOffsetY:(float)offsetY animation:(BOOL)animation {
    self.offsetY = offsetY;
    
    __weak typeof(self) __weakedSelf = self;
    if (animation) {
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [__weakedSelf updateUI];
        } completion:nil];
    } else {
        [self updateUI];
    }
}

- (void)updateUI {
    self.segmentControl.frame = CGRectMake(0, kTX_Segment_Y + self.offsetY, CGRectGetWidth(self.view.bounds), self.heightOfSegmentView);
    UIView *lineView = [self.segmentControl viewWithTag:1234];
    if (lineView) {
        CGRect rect = lineView.frame;
        rect = CGRectMake(0, self.heightOfSegmentView - rect.size.height, CGRectGetWidth(self.view.bounds), rect.size.height);
        lineView.frame = rect;
    }
    
    self.scrollView.frame = CGRectMake(0,
                                       kTX_Segment_Y  + self.offsetY + (self.segmentControl.hidden ? 0 : self.heightOfSegmentView),
                                       CGRectGetWidth(self.view.bounds),
                                       CGRectGetHeight(self.view.bounds) - kTX_Segment_Y - self.offsetY - (self.segmentControl.hidden ? 0 : self.heightOfSegmentView));
    
    [self.usingVCMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        UIViewController *vc = obj;
        CGRect rect = vc.view.frame;
        rect.size.height = CGRectGetHeight(self.scrollView.bounds);
        vc.view.frame = rect;
    }];
    self.scrollView.contentSize = CGSizeMake(self.count * CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
}

- (void)setSegmentViewHidden:(BOOL)hidden animated:(BOOL)animated {
    self.segmentControl.hidden = hidden;
    
    if (animated) {
        [UIView animateWithDuration:.5 animations:^{
            [self updateUI];
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        [self updateUI];
    }
}

- (UIViewController *)vcAtIndex:(NSInteger)index
{
    NSLog(@"获取VC, index [ %ld ]", (long)index);
    UIViewController *vc = self.usingVCMap[@(index)];
    if (!vc) {
        vc = [self.dataSource segmentVC:self vcForIndex:index];
        vc.zbw_segmentIndex = index;
        NSAssert(vc, @"segmentVC:vcForIndex: 不能返回nil");
        self.usingVCMap[@(index)] = vc;
    }
    return vc;
}

- (void)addToReusableMap:(UIViewController *)vc
{
    // 添加到“复用”缓存中
    NSString *identify = vc.zbw_segmentIdentify;
    NSLog(@"加入到 复用 Map中，index [ %ld ] identify [ %@ ]", (long)vc.zbw_segmentIndex, identify);
    if (identify) {
        [[self reusableVCSet:identify] addObject:vc];
    }
    // 从“正在使用”中删除
    [self.usingVCMap removeObjectForKey:@(vc.zbw_segmentIndex)];
    
    if ([self.dataSource respondsToSelector:@selector(segmentVC:didEndDisplayingVC:forIndex:)]) {
        [self.dataSource segmentVC:self didEndDisplayingVC:vc forIndex:vc.zbw_segmentIndex];
    }
    
    if (!identify) {
        [self removeViewController:vc];
    }
}

- (void)addToUsingMap:(UIViewController *)vc
{
    NSString *identify = vc.zbw_segmentIdentify;
    NSLog(@"加入到using Map中，index [ %ld ] identify [ %@ ]", (long)vc.zbw_segmentIndex, identify);
    // 添加的到“正在使用”
    self.usingVCMap[@(vc.zbw_segmentIndex)] = vc;
    // 从“复用”中删除
    if (identify) {
        [[self reusableVCSet:identify] removeObject:vc];
    }
}

- (void)showIndexs:(NSArray *)indexs
{
    NSLog(@"showIndexs : %@", indexs);
    if (!self.dontCleanOtherVC) {
        // 清理正在显示的VC
        [self.usingVCMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            // 不需要显示, 加入到复用
            if (![indexs containsObject:key]) {
                [self addToReusableMap:obj];
            }
        }];
    }
    
    [indexs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *indexNum = obj;
        // 不存在
        if (!self.usingVCMap[indexNum] && indexNum.integerValue < self.count && indexNum.integerValue >= 0) {
            UIViewController *vc = [self vcAtIndex:indexNum.integerValue];
            [self setViewController:vc atIndex:indexNum.integerValue];
        }
    }];
}

#pragma mark- Getter 属性
- (NSMutableDictionary *)reusableVCMap
{
    if (!_reusableVCMap) {
        _reusableVCMap = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return _reusableVCMap;
}

- (NSMutableDictionary *)usingVCMap
{
    if (!_usingVCMap) {
        _usingVCMap = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return _usingVCMap;
}

- (ZBWSegmentView *)segmentControl
{
    if (!_segmentControl) {
        _segmentControl = [[ZBWSegmentView alloc] initWithFrame:CGRectMake(0, kTX_Segment_Y + self.offsetY, CGRectGetWidth(self.view.bounds), self.heightOfSegmentView)];
        _segmentControl.backgroundColor = self.bgColorOfSegmentView ? : [UIColor whiteColor];
        _segmentControl.selectionIndicatorColor = self.selectionIndicatorColor;
        _segmentControl.displayType = self.segmentItemDisplayType;

        // 添加阴影遮罩
        CGFloat height = 1;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.heightOfSegmentView - height, CGRectGetWidth(self.segmentControl.frame), height)];
        view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.2];
        view.tag = 1234;
        [_segmentControl addSubview:view];

        __weak typeof(self) _self = self;
        [_segmentControl setIndexChangeBlock:^(NSInteger index) {
//            _self.currentIndex = index;
            
                CGFloat width = CGRectGetWidth(_self.scrollView.bounds);
//                CGRect rect = CGRectMake(index*width, 0, width, CGRectGetHeight(_self.scrollView.bounds));
//                [self.scrollView scrollRectToVisible:rect animated:YES];
                _self.scrollView.contentOffset = CGPointMake(index*width, 0);
            
        }];
//        if (self.titles.count <= 1) {
//            _segmentControl.hidden = YES;
//        }
    }
    return _segmentControl;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kTX_Segment_Y + self.offsetY + (self.segmentControl.hidden ? 0 : self.heightOfSegmentView), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kTX_Segment_Y - self.offsetY - self.heightOfSegmentView)];
//        _scrollView.contentSize = CGSizeMake(self.viewControllers.count * CGRectGetWidth(self.view.bounds), 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (float)heightOfSegmentView
{
    return _heightOfSegmentView == 0 ? kTX_SegmentHeight : _heightOfSegmentView;
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
    if (x > 0) {
        [showIndexArray addObject:@(index + 1)];
    }
    
    [self showIndexs:showIndexArray];
    
    self.currentIndex = MAX(MIN((offsetX + width/2) /width, self.count), 0);
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    CGFloat offsetX = scrollView.contentOffset.x;
//    float x = offsetX/scrollView.bounds.size.width;
//    self.currentIndex = ceilf(x);
//}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    self.currentVc = self.usingVCMap[@(currentIndex)];
    if (_currentIndex == currentIndex) {
        return;
    }
    _currentIndex = currentIndex;
    [self.segmentControl setSelectedIndex:_currentIndex];
}

@end
