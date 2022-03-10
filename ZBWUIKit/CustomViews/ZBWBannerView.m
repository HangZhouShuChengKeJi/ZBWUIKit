//
//  HomePageBannerView.m
//  
//
//  Created by limengqiang on 15/7/31.
//
//

#import "ZBWBannerView.h"
#import "ZBWPageControlView.h"


#define ADAPTIVE_SCALE      floorf(([[UIScreen mainScreen] bounds].size.width/320.0) * 100)/100

@implementation ZBWBannerItemInfo

+ (instancetype)bannerItemInfo:(NSString *)imageUrl object:(id)object
{
    ZBWBannerItemInfo *info = [[ZBWBannerItemInfo alloc] init];
    info.imageUrl = imageUrl;
    info.object = object;
    
    return info;
}

@end

@interface ZBWBannerView()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
    UIImageView *_imageViewLeft;
    UIImageView *_imageViewCurrent;
    UIImageView *_imageViewRight;
    int _currentIndex;
    
    ZBWPageControlView *_pageControlView;
    BOOL _isStop;
}

@property (nonatomic, strong) NSTimer       *scrollTimer;

@end

@implementation ZBWBannerView

- (id)initWithFrame:(CGRect)frame
{
//    NSLog(@"%s", __func__);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _currentIndex = 0;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollsToTop = NO;
        [self addSubview:_scrollView];
        
        UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        left.clipsToBounds = YES;
        [_scrollView addSubview:left];
        
        _imageViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageViewLeft.zbw_identify = @"BannerImageView";
        [left addSubview:_imageViewLeft];
        
        
        UIView *current = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)];
        current.clipsToBounds = YES;
        [_scrollView addSubview:current];
        
        _imageViewCurrent = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageViewCurrent.zbw_identify = @"BannerImageView";
        [current addSubview:_imageViewCurrent];
        
        UIView *right = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width * 2, 0, frame.size.width, frame.size.height)];
        right.clipsToBounds = YES;
        [_scrollView addSubview:right];
        
        _imageViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageViewRight.zbw_identify = @"BannerImageView";
        [right addSubview:_imageViewRight];
        
        UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tapGestureRecognize];
        
//        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 16 * ADAPTIVE_SCALE, self.width, 10 * ADAPTIVE_SCALE)];
//        _pageControl.userInteractionEnabled = NO;
//        _pageControl.numberOfPages = 1;
//        _pageControl.currentPage = 0;
//        _pageControl.hidesForSinglePage = YES;
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
//            _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.0 alpha:0.3];
//            _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexColorString:@"f53e7b"];
//        }
//        [self addSubview:_pageControl];
        
        _pageControlView = [[ZBWPageControlView alloc] init];
        _pageControlView.numberOfPages = 1;
        _pageControlView.currentPage = 0;
        [self addSubview:_pageControlView];
        
    }
    return self;
}

- (void)setItemArray:(NSArray *)itemArray {
    _itemArray = itemArray;
    if (self.itemArray == nil || [self.itemArray count] == 0) {
        return;
    }
    _currentIndex = 0;
    _pageControlView.numberOfPages = (int)_itemArray.count;
    [_pageControlView setFrame:CGRectMake(2, (int)(self.height - _pageControlView.height - 6 * ADAPTIVE_SCALE), _pageControlView.width, _pageControlView.height)];
    _pageControlView.centerX = self.width/2;

    _isStop = NO;
    
    [self restoreScrollView];
    
    if (self.itemArray != nil && [self.itemArray count] == 1) {
        _scrollView.scrollEnabled = NO;
    } else {
        _scrollView.scrollEnabled = YES;
    }
}

- (void)begin
{
    if (self.itemArray != nil && [self.itemArray count] == 1) {
        [self stopTimer];
    } else {
        [self startTimer];
    }
}

#pragma mark UIScrollViewDelegate;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float scrollViewOffset = scrollView.contentOffset.x - scrollView.width;
    if (scrollViewOffset > 0) {
        float proportion = scrollViewOffset / scrollView.width;
        float imageViewOffset = (scrollView.width) / 2 * proportion;
        _imageViewCurrent.left = imageViewOffset;
        _imageViewRight.left = imageViewOffset - (scrollView.width) / 2;
    }else{
        float proportion = - scrollViewOffset / scrollView.width;
        float imageViewOffset = (scrollView.width) / 2 * proportion;
        _imageViewCurrent.left = - imageViewOffset;
        _imageViewLeft.left = - imageViewOffset + (scrollView.width) / 2;
    }
    if (scrollView.contentOffset.x >= _scrollView.width * 2) {
        [self addCurrentIndex:YES];
        [self restoreScrollView];
    }else if (scrollView.contentOffset.x <= 0){
        [self addCurrentIndex:NO];
        [self restoreScrollView];
    }
}

////  定时右滑滑动结束后执行。(该滚动需要代码触发且Animation:YES)
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
//    if (scrollView.contentOffset.x == _scrollView.width * 2) {
//        [self addCurrentIndex:YES];
//    }
//    [self restoreScrollView];
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

//scrollView 停止滚动执行。（该滚动需要是手指触发的滚动）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self begin];
}

 
//scrollView 定时右滑
- (void)timeScroll{
    if ([self zbw_outsideWithScreen]) {
//        [self stopTimer];
        return;
    }
    if (_scrollView.contentOffset.x == _scrollView.width) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.width * 2, 0) animated:YES];
    }
}

//scrollView 复位
- (void)restoreScrollView{
    
//    _pageControl.currentPage = _currentIndex;
    if (_isStop) {
        return;
    }
    _pageControlView.currentPage = _currentIndex;
    
//    ZBW_SendUpSignal(@"currentItem", @(_currentIndex), nil, self);
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.width, 0) animated:NO];
    _imageViewLeft.left = _scrollView.width / 2;
    _imageViewCurrent.left = 0;
    _imageViewRight.left = - _scrollView.width / 2;
    
    int leftIndex = _currentIndex - 1;
    if (leftIndex < 0) {
        leftIndex = (int)[self.itemArray count] - 1;
    }
    
    int rightIndex = _currentIndex + 1;
    if (rightIndex >= [self.itemArray count]) {
        rightIndex = 0;
    }
    
    ZBWBannerItemInfo *leftItem = [self.itemArray objectAtIndex:leftIndex];
//    [_imageViewLeft imageLoabBridge:leftItem.imageUrl];
    [_imageViewLeft zbw_loadImage:leftItem.imageUrl];
    ZBWBannerItemInfo *currentItem = [self.itemArray objectAtIndex:_currentIndex];
    [_imageViewCurrent zbw_loadImage:currentItem.imageUrl];
    ZBWBannerItemInfo *rightItem = [self.itemArray objectAtIndex:rightIndex];
    [_imageViewRight zbw_loadImage:rightItem.imageUrl];
}

- (void)addCurrentIndex:(BOOL)isAdd{
    if (isAdd) {
        _currentIndex ++;
        if (_currentIndex >= [self.itemArray count]) {
            _currentIndex = 0;
        }
    }else{
        _currentIndex --;
        if (_currentIndex < 0) {
            _currentIndex = (int)[self.itemArray count] - 1;
        }
    }
//    NSLog(@"showCurrentIndex----%d",_currentIndex);
}


- (void)startTimer {
    if (!_scrollTimer) {
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeSecond target:self selector:@selector(timeScroll) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:_scrollTimer forMode:NSRunLoopCommonModes];
        [_scrollTimer fire];
    }
}

- (void)stopTimer {
    if (_scrollTimer && [_scrollTimer isValid]) {
        [_scrollTimer invalidate];
    }
    _scrollTimer = NULL;
}

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    ZBWBannerItemInfo *info = [self.itemArray objectAtIndex:_currentIndex];
    ZBW_SendUpSignal(@"click", info.object, nil, self);
}

@end
