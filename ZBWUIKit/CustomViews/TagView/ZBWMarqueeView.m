//
//  ZBWMarqueeView.m
//  ZBWUIKit
//
//  Created by dinghuachao on 2024/11/27.
//

#import "ZBWMarqueeView.h"

@interface ZBWMarqueeView ()

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UILabel *firstLabel;
@property (nonatomic, strong) UILabel *secondLabel;
@property (nonatomic, strong) NSMutableArray *labelArray;

@property (nonatomic, strong) UIFont  * font;

@end

@implementation ZBWMarqueeView
+ (instancetype)marqueeBarWithFrame:(CGRect)frame title:(NSString*)title font:(UIFont *)font{
    ZBWMarqueeView * marqueeBar = [[ZBWMarqueeView alloc] initWithFrame:frame];
    marqueeBar.font = font;
    marqueeBar.title = title;
    return marqueeBar;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.firstLabel];
        [self addSubview:self.secondLabel];
        
        [self.labelArray addObject:_firstLabel];
        [self.labelArray addObject:_secondLabel];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    BOOL isNeedRaceAnimate = [self isNeedRaceAnimate];
    
    NSString *raceStr = isNeedRaceAnimate ? [NSString stringWithFormat:@"%@        ",title]:title;
    self.firstLabel.text = raceStr;
    self.secondLabel.text = raceStr;
    
    self.firstLabel.font = self.font;
    self.secondLabel.font = self.font;

    CGFloat raceStrWidth = [self getStringWidth:raceStr];
    if (!isNeedRaceAnimate && raceStrWidth > self.bounds.size.width) {
        raceStrWidth = self.bounds.size.width;
    }
    
    self.firstLabel.frame = CGRectMake(0, 0, raceStrWidth, self.frame.size.height);
    self.secondLabel.frame = CGRectMake(self.firstLabel.frame.origin.x + self.firstLabel.bounds.size.width, self.firstLabel.frame.origin.y, self.firstLabel.bounds.size.width, self.firstLabel.bounds.size.height);
    self.secondLabel.hidden = !isNeedRaceAnimate;
    if (isNeedRaceAnimate) {
        [self startAnimation];
    }else{
        self.firstLabel.left = (self.bounds.size.width - raceStrWidth)/2.0;
        [self stopAnimation];
    }
}

- (void)updateTitle:(NSString *)title{
    self.title = title;
}
- (void)updateTitleColor:(UIColor *)titleColor{
    self.firstLabel.textColor = titleColor;
    self.secondLabel.textColor = titleColor;

}
- (void)updateTitleFont:(UIFont *)titleFont{
    self.firstLabel.font = titleFont;
    self.secondLabel.font = titleFont;
}
-(void)setTitleLoop:(BOOL)titleLoop{
    _titleLoop = titleLoop;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    BOOL isNeedRaceAnimate = [self isNeedRaceAnimate];
    
    NSString *raceStr = isNeedRaceAnimate ? [NSString stringWithFormat:@"%@        ",self.title]:self.title;
    self.firstLabel.text = raceStr;
    self.secondLabel.text = raceStr;
    
    self.firstLabel.font = self.font;
    self.secondLabel.font = self.font;

    CGFloat raceStrWidth = [self getStringWidth:raceStr];
    if (!isNeedRaceAnimate && raceStrWidth > self.bounds.size.width) {
        raceStrWidth = self.bounds.size.width;
    }
    self.firstLabel.frame = CGRectMake(0, 0, raceStrWidth, self.frame.size.height);
    self.secondLabel.frame = CGRectMake(self.firstLabel.frame.origin.x + self.firstLabel.bounds.size.width, self.firstLabel.frame.origin.y, self.firstLabel.bounds.size.width, self.firstLabel.bounds.size.height);
    self.secondLabel.hidden = !isNeedRaceAnimate;
    if (isNeedRaceAnimate) {
        [self startAnimation];
    }else{
        self.firstLabel.left = (self.bounds.size.width - raceStrWidth)/2.0;
        [self stopAnimation];
    }
}
- (BOOL)isNeedRaceAnimate{
    if (!self.titleLoop) {
        return NO;
    }
    CGFloat w = [self getStringWidth:_title];
    
    return w > self.bounds.size.width;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.firstLabel && self.secondLabel) {
//        self.firstLabel.frame = CGRectMake(50, 0, self.firstLabel.bounds.size.width, self.bounds.size.height);
//        self.secondLabel.frame = CGRectMake(self.firstLabel.frame.origin.x + self.firstLabel.bounds.size.width, self.firstLabel.frame.origin.y, self.firstLabel.bounds.size.width, self.firstLabel.bounds.size.height);
        BOOL isNeedRaceAnimate = [self isNeedRaceAnimate];
        NSString *raceStr = isNeedRaceAnimate ? [NSString stringWithFormat:@"%@        ",self.title]:self.title;
        CGFloat raceStrWidth = [self getStringWidth:raceStr];
        if (!isNeedRaceAnimate && raceStrWidth > self.bounds.size.width) {
            raceStrWidth = self.bounds.size.width;
        }
        self.firstLabel.frame = CGRectMake(0, 0, raceStrWidth, self.frame.size.height);
        self.secondLabel.frame = CGRectMake(self.firstLabel.frame.origin.x + self.firstLabel.bounds.size.width, self.firstLabel.frame.origin.y, self.firstLabel.bounds.size.width, self.firstLabel.bounds.size.height);
    }
    self.secondLabel.hidden = ![self isNeedRaceAnimate];
    if (![self isNeedRaceAnimate]) {
        self.firstLabel.left = (self.bounds.size.width - self.firstLabel.bounds.size.width)/2.0;
        [self stopAnimation];
    }
}


- (void)startAnimation
{
    //1.0 / 60 控制文字速度
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60 target:self selector:@selector(raceLabelFrameChanged:) userInfo:nil repeats:YES];
    [self.timer fire];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation {
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = NULL;
}

- (void)raceLabelFrameChanged:(NSTimer *)timer
{
    UILabel *firstLabel = [self.labelArray firstObject];
    UILabel *secondLabel = [self.labelArray lastObject];
    CGRect frameOne = firstLabel.frame;
    CGRect frameTwo = secondLabel.frame;
    CGFloat firstX = firstLabel.frame.origin.x;
    CGFloat secondX = secondLabel.frame.origin.x;
    firstX -= 0.5;
    secondX -= 0.5;
    if (ABS(firstX) >= firstLabel.bounds.size.width) {
        firstX = secondX + firstLabel.bounds.size.width;
        [self.labelArray exchangeObjectAtIndex:0 withObjectAtIndex:1];
    }
    frameOne.origin.x = firstX;
    frameTwo.origin.x = secondX;
    firstLabel.frame = frameOne;
    secondLabel.frame = frameTwo;
}

- (void)resume
{
    [self resumeAndStart:NO];
}

- (void)resumeAndStart
{
    [self resumeAndStart:YES];
}

- (void)resumeAndStart:(BOOL)start
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.firstLabel.frame = CGRectMake(50, 0, _firstLabel.bounds.size.width, self.bounds.size.height);
    self.secondLabel.frame = CGRectMake(self.firstLabel.frame.origin.x + self.firstLabel.bounds.size.width, self.firstLabel.frame.origin.y, self.firstLabel.bounds.size.width, self.firstLabel.bounds.size.height);
    if (start) {
        [self startAnimation];
    }
}



#pragma mark - Properties
- (UILabel *)firstLabel
{
    if (!_firstLabel) {
        _firstLabel = [[UILabel alloc] init];
        _firstLabel.font = self.font;
        _firstLabel.textColor =  [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1.0];//RGB(102, 102, 102);
        _firstLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _firstLabel;
}

- (UILabel *)secondLabel
{
    if (!_secondLabel) {
        _secondLabel = [[UILabel alloc] init];
        _secondLabel.font = self.font;
        _secondLabel.textColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1.0];//RGB(102, 102, 102);
        _secondLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _secondLabel;
}

- (NSMutableArray *)labelArray
{
    if (!_labelArray) {
        _labelArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _labelArray;
}


- (CGFloat)getStringWidth:(NSString *)string
{
    if (string) {
        CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                           options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |
                       NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName:self.font}
                                           context:nil];
        return rect.size.width;
    }
    return 0.f;
}

- (UIFont *)font{
    if (!_font) {
        _font = [UIFont systemFontOfSize:12];
    }
    return _font;
}

-(void)dealloc{
    [self stopAnimation];
}
@end
