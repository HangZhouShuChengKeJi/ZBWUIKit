//
//  ZBWLoadingView.m
//  
//
//  Created by Bowen on 15/5/6.
//  Copyright (c) 2015年. All rights reserved.
//

#import "ZBWLoadingView.h"

#define ZBWLoadingView_LineWidth   6
#define ZBWLoadingView_Width       40
#define ZBWLoadingView_Duration    0.5

#define ZBWLoadingView_rotationAngle   70

#define ZBWLoadingView_Color_Light [[UIColor blackColor] colorWithAlphaComponent:0.1]
#define ZBWLoadingView_Color_Dark [[UIColor blackColor] colorWithAlphaComponent:0.1]

#define ZBWLoadingView_DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

/**
 *  自定义Layer
 */
@interface ZBWLoadingLayer : CALayer
@property (nonatomic, assign)float              progress;
@property (nonatomic, assign)float              lineWidth;
@property (nonatomic, assign)CGFloat            rotationAngle;
@property (nonatomic, retain)UIColor            *lineColor;

@end


@implementation ZBWLoadingLayer

@dynamic lineWidth;
@dynamic rotationAngle;
@dynamic lineColor;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

+ (instancetype)layer
{
    ZBWLoadingLayer *layer = [[ZBWLoadingLayer alloc] init];
    return layer;
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGRect rect = self.bounds;
    CGFloat width = CGRectGetWidth(rect);
    float startAngle = (self.rotationAngle - 90) - (_progress * 360) / 2;
    float endAngle = (self.rotationAngle - 90) + (_progress * 360) / 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)) radius:(width - self.lineWidth) / 2 startAngle:ZBWLoadingView_DEGREES_TO_RADIANS(startAngle) endAngle:ZBWLoadingView_DEGREES_TO_RADIANS(endAngle) clockwise:YES];

    CGContextSaveGState(ctx);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetShouldAntialias(ctx,true);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
}


@end



@interface ZBWLoadingView ()

@property (nonatomic, strong)UIBezierPath       *path;
@property (nonatomic, strong)ZBWLoadingLayer       *animationLayer;

@property (nonatomic, strong)CAShapeLayer       *circleLayer1;
@property (nonatomic, strong)CAShapeLayer       *circleLayer2;

@end

@implementation ZBWLoadingView

static UIColor *s_fgColor;
static UIColor *s_bgColor;

+ (ZBWLoadingView *)loadingInView:(UIView *)inView
{
    ZBWLoadingView *loadingView = [ZBWLoadingView loadingView];
    CGRect rect = inView.bounds;
    loadingView.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    [inView addSubview:loadingView];
    [loadingView loading];
    return loadingView;
}

+ (ZBWLoadingView *)loadingView
{
    ZBWLoadingView *loadingView = [[ZBWLoadingView alloc] initWithFrame:CGRectMake(0, 0, ZBWLoadingView_Width, ZBWLoadingView_Width)];
    return loadingView;
}

/**
 设置默认的前景颜色
 */
+ (void)setDefaultFgLineColor:(UIColor *)color {
    s_fgColor = color;
}

/**
 设置默认的背景颜色
 */
+ (void)setDefaultBgLineColor:(UIColor *)color {
    s_bgColor = color;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self initData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initData];
    }
    return self;
}

- (void)initData
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
//    self.fgLineColor = kZBW_Color_Orange;
//    self.bgLineColor = ZBWLoadingView_Color_Light;
    self.lineWidth = ZBWLoadingView_LineWidth;
    self.duration = ZBWLoadingView_Duration;
    self.rotationAngle = ZBWLoadingView_rotationAngle;
}

// 正方形frame
- (void)setFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, MIN(frame.size.width, frame.size.height), MIN(frame.size.width, frame.size.height));
    [super setFrame:rect];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clean];
}

- (void)onAppDidEnterBackground
{
    [self clean];
}

- (void)onAppDidBecomeActive
{
    [self loading];
}

- (void)clean
{
    if (_animationLayer)
    {
        [_animationLayer removeAllAnimations];
        [_animationLayer removeFromSuperlayer];
        _animationLayer = nil;
    }
    if (_circleLayer1)
    {
        [_circleLayer1 removeAllAnimations];
        [_circleLayer1 removeFromSuperlayer];
        _circleLayer1 = nil;
    }
    if (_circleLayer2)
    {
        [_circleLayer2 removeAllAnimations];
        [_circleLayer2 removeFromSuperlayer];
        _circleLayer2 = nil;
    }
    _path = nil;
}

- (void)loading
{
    if (!self.fgLineColor) {
        if (s_fgColor) {
            self.fgLineColor = s_fgColor;
        } else {
            self.fgLineColor = ZBWLoadingView_Color_Dark;
        }
    }
    if (!self.bgLineColor) {
        if (s_bgColor) {
            self.bgLineColor = s_bgColor;
        } else {
            self.bgLineColor = ZBWLoadingView_Color_Light;
        }
    }
    // step1: 清理sublayer
    [self clean];
    
    // 根据当前属性设置，重新定义frame
    CGRect frame = self.frame;
    
    // step3：添加sublayer
    self.backgroundColor = [UIColor clearColor];
    [self.layer addSublayer:self.animationLayer];
    
    self.circleLayer1 = [CAShapeLayer layer];
    self.circleLayer1.backgroundColor = [UIColor clearColor].CGColor;
    self.circleLayer1.bounds = self.animationLayer.bounds;
    self.circleLayer1.position = self.animationLayer.position;
    self.circleLayer1.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((CGRectGetWidth(frame) - self.lineWidth) / 2, 0, self.lineWidth, self.lineWidth)].CGPath;
    self.circleLayer1.fillColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:self.circleLayer1];
    
    
    self.circleLayer2 = [CAShapeLayer layer];
    self.circleLayer2.backgroundColor = [UIColor clearColor].CGColor;
    self.circleLayer2.bounds = self.animationLayer.bounds;
    self.circleLayer2.position = self.animationLayer.position;
    self.circleLayer2.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((CGRectGetWidth(frame) - self.lineWidth) / 2, 0, self.lineWidth, self.lineWidth)].CGPath;
    self.circleLayer2.fillColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:self.circleLayer2];
    
    // step4：为subulayer添加动画
//    self.animationLayer.progress = .5;
    [self.animationLayer setNeedsDisplay];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.repeatCount = INT32_MAX;
    animation.autoreverses = YES;
    animation.duration = self.duration;
//
    [self.animationLayer addAnimation:animation forKey:nil];
    
    
    CABasicAnimation *rotationAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation1.fromValue = [NSNumber numberWithFloat:ZBWLoadingView_DEGREES_TO_RADIANS(self.rotationAngle)];
    rotationAnimation1.toValue = [NSNumber numberWithFloat:ZBWLoadingView_DEGREES_TO_RADIANS(self.rotationAngle - 180)];
    rotationAnimation1.repeatCount = INT32_MAX;
    rotationAnimation1.autoreverses = YES;
    rotationAnimation1.duration = self.duration;
    
    [self.circleLayer1 addAnimation:rotationAnimation1 forKey:nil];
    
    CABasicAnimation *rotationAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation2.fromValue = [NSNumber numberWithFloat:ZBWLoadingView_DEGREES_TO_RADIANS(self.rotationAngle)];
    rotationAnimation2.toValue = [NSNumber numberWithFloat:ZBWLoadingView_DEGREES_TO_RADIANS(self.rotationAngle + 180)];
    rotationAnimation2.repeatCount = INT32_MAX;
    rotationAnimation2.autoreverses = YES;
    rotationAnimation2.duration = self.duration;
    
    [self.circleLayer2 addAnimation:rotationAnimation2 forKey:nil];
}

- (ZBWLoadingLayer *)animationLayer
{
    if (!_animationLayer)
    {
        _animationLayer = [ZBWLoadingLayer layer];
        _animationLayer.bounds = self.bounds;
        _animationLayer.lineWidth = self.lineWidth;
        _animationLayer.rotationAngle = self.rotationAngle;
        _animationLayer.lineColor = self.fgLineColor;
        _animationLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    return _animationLayer;
}

- (UIBezierPath *)path
{
    if (!_path)
    {
        CGRect rect = self.bounds;
        CGFloat width = CGRectGetWidth(rect);
        _path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)) radius:(width - self.lineWidth) / 2 startAngle:ZBWLoadingView_DEGREES_TO_RADIANS(self.rotationAngle - 90) endAngle:ZBWLoadingView_DEGREES_TO_RADIANS(360 + (self.rotationAngle - 90)) clockwise:YES];
    }
    return _path;
}

- (void)drawRect:(CGRect)rect
{
    // 绘制圆圈
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, self.bgLineColor.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    
    CGContextAddPath(context, self.path.CGPath);
    CGContextSetShouldAntialias(context,true);
    CGContextStrokePath(context);
}


@end
