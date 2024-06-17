//
//  TagButton.m
//  Orange
//
//  Created by 朱博文 on 2017/11/1.
//  Copyright © 2017年 朱博文. All rights reserved.
//

#import "ZBWTagItemView.h"
#import <objc/runtime.h>

const void *ZBWTagItemView_Identify_Key = &ZBWTagItemView_Identify_Key;



@interface ZBWTagDeleteView : UIView
@end

@implementation ZBWTagDeleteView

- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = CGRectGetMaxX(rect)/2;
    self.layer.masksToBounds = YES;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillRect(context, rect);
    
//    CGContextAddEllipseInRect(context, rect);
//    CGContextClip(context);
//
//    CGContextclip
//    CGContextAddEllipseInRect(context, rect);
//    CGContextSetFillColorWithColor(context, kZBW_Color_Red.CGColor);
//    CGContextFillPath(context);
    
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextMoveToPoint(context, 0, CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), 0);
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokePath(context);
}

@end


@interface ZBWTagItemView()

@property (nonatomic) CAShapeLayer      *shapeLayer;
@property (nonatomic) UIButton          *contentBtn;
@property (nonatomic) ZBWTagDeleteView      *defaultDeleteView; // 删除

@end

@implementation ZBWTagItemView

- (instancetype)initWithIdentify:(NSString *)identify {
    if (self = [super init]) {
        self.padding = UIEdgeInsetsMake(5, 5, 5, 5);
        self.itemWidth = 0;
        self.itemHeight = 0;
        self.maxWidth = 0 ;
        self.maxTitleCount = 0;
        self.selectedBgColor = [UIColor orangeColor];
        self.selectedTextColor = [UIColor whiteColor];
        self.selectedFont = [UIFont systemFontOfSize:13];
        self.selectedBorderColor = [UIColor orangeColor];
        
        self.normalBgColor = [UIColor whiteColor];
        self.normalTextColor = [UIColor orangeColor];
        self.normalFont = [UIFont systemFontOfSize:13];
        self.normalBorderColor = [UIColor orangeColor];
        
        objc_setAssociatedObject(self, ZBWTagItemView_Identify_Key, identify, OBJC_ASSOCIATION_COPY);
    }
    [self addSubview:self.contentBtn];
    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 40);
    
    self.style = _style;
//    [self updateUI];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBtnClicked)];
    [self addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressed:)];
    longPressGesture.minimumPressDuration = .6;
    [self addGestureRecognizer:longPressGesture];
    
    return self;
}


- (void)didMoveToSuperview {
    if (self.superview) {
//        [self updateUI];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = CGRectMake(self.padding.left, self.padding.top, self.width - self.padding.left - self.padding.right, self.height - self.padding.top - self.padding.bottom);
    
    self.contentBtn.frame = rect;
    _defaultDeleteView.right = self.bounds.size.width;
    self.style = _style;
    
    [self resetLayer];
}

- (void)resetLayer {
    if (_shapeLayer) {
        UIBezierPath *path = nil;
        if (self.style == ZBWTagItemViewStyle_CornerRadius) {
            path = [UIBezierPath bezierPathWithRoundedRect:self.contentBtn.bounds cornerRadius:4];
        } else if (self.style == ZBWTagItemViewStyle_Circular) {
            path = [UIBezierPath bezierPathWithRoundedRect:self.contentBtn.bounds cornerRadius:self.contentBtn.bounds.size.height/2];
        }
        _shapeLayer.path = path.CGPath;
        _shapeLayer.frame = self.contentBtn.bounds;
    }
}

- (NSString *)identify {
    return objc_getAssociatedObject(self, ZBWTagItemView_Identify_Key);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    NSString *displayTitle = title;
    if (self.maxTitleCount > 0 && title.length >self.maxTitleCount) {
        NSRange range = NSMakeRange(0, self.maxTitleCount);
        displayTitle = [NSString stringWithFormat:@"%@..",[title substringWithRange:range]] ;
    }
    [self.contentBtn setTitle:displayTitle forState:UIControlStateNormal];
    
//    [self updateUI];
}

- (void)setStyle:(ZBWTagItemViewStyle)style {
    _style = style;
    switch (style) {
        case ZBWTagItemViewStyle_Default:
        {
            self.contentBtn.layer.cornerRadius = 0;
            self.contentBtn.layer.masksToBounds = NO;
        }
            break;
        case ZBWTagItemViewStyle_CornerRadius:
        {
            self.contentBtn.layer.cornerRadius = 4;
            self.contentBtn.layer.masksToBounds = YES;
        }
            break;
        case ZBWTagItemViewStyle_Circular:
        {
            self.contentBtn.layer.cornerRadius = self.contentBtn.height/2;
            self.contentBtn.layer.masksToBounds = YES;
        }
            break;
            
        default:
            break;
    }
}

- (void)setLineStyle:(ZBWTagItemViewLineStyle)lineStyle {
    _lineStyle = lineStyle;
//    switch (lineStyle) {
//        case ZBWTagItemViewLineStyle_Solid:
//            self.contentBtn.layer.
//            break;
//
//        default:
//            break;
//    }
}

- (void)updateUI {
    if (_isSelected) {
        [self tagItemViewStateSelected];
    } else {
        [self tagItemViewStateNormal];
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    if (_isSelected == isSelected) {
        return;
    }
    _isSelected = isSelected;
//    [self updateUI];
//    self.selectedChangeBlock ? self.selectedChangeBlock(_isSelected, self) : nil;
}

- (void)setIsEditing:(BOOL)isEditing {
    if (!self.shouldEditingBlock || !self.shouldEditingBlock(self)) {
        return;
    }
    if (_isEditing == isEditing) {
        return;
    }
    _isEditing = isEditing;
//    [self updateUI];
}


#pragma mark overrider
- (CGSize)sizeThatFits:(CGSize)size {
//    CGFloat height = [@"全" boundingRectWithSize:CGRectMake(0, 0, 100, 30).size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : kZBW_Font_Small} context:nil].size.height;
    
    CGSize aSize = [self.contentBtn sizeThatFits:[[UIScreen mainScreen] bounds].size];
    aSize.width += 10*2;
    aSize.height += (self.padding.top + self.padding.bottom);
    aSize.width += (self.padding.left + self.padding.right);
    if (self.maxWidth >0 && aSize.width > self.maxWidth) {
        aSize.width = self.maxWidth;
    }
    if (self.itemWidth > 0) {
        aSize.width = self.itemWidth;
    }
    if (self.itemHeight > 0) {
        aSize.height = self.itemHeight;
    }
    return aSize;
}

#pragma mark-
- (void)tagItemViewStateNormal {
    if (self.isEditing) {
        [self addSubview:self.defaultDeleteView];
    } else {
        [_defaultDeleteView removeFromSuperview];
    }
    if (self.lineStyle == ZBWTagItemViewLineStyle_Dashed) {
        self.contentBtn.layer.borderWidth = 0;
        self.shapeLayer.strokeColor = self.normalBorderColor.CGColor;
        [self.contentBtn.layer addSublayer:self.shapeLayer];
    } else {
        [_shapeLayer removeFromSuperlayer];
        self.contentBtn.layer.borderWidth = 1;
    }
    
    self.contentBtn.backgroundColor = self.normalBgColor;
    self.contentBtn.layer.borderColor = self.normalBorderColor.CGColor;
    self.contentBtn.titleLabel.font = self.normalFont;
    [self.contentBtn setTitleColor:self.normalTextColor forState:UIControlStateNormal];
    
    if (self.searchHighlightTextColor && _title.length > 0) {
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:_title];
        if (self.searchHightlightRange.length > 0) {
            [attrStr addAttribute:NSForegroundColorAttributeName value:self.searchHighlightTextColor range:self.searchHightlightRange];
        }
        
        self.contentBtn.titleLabel.attributedText = attrStr;
    }
    
//    if (self.searchHightlightRange.length > 0 && self.searchHighlightTextColor && _title.length > 0) {
//        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:_title];
//        [attrStr addAttribute:NSForegroundColorAttributeName value:self.searchHighlightTextColor range:self.searchHightlightRange];
//        self.contentBtn.titleLabel.attributedText = attrStr;
//    } else {
//        if (self.searchHighlightTextColor) {
//            self.contentBtn.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:_title];
//        }
//    }
}

- (void)tagItemViewStateSelected {
    if (self.isEditing) {
        [self addSubview:self.defaultDeleteView];
    } else {
        [_defaultDeleteView removeFromSuperview];
    }
    self.contentBtn.backgroundColor = self.selectedBgColor;
    if (self.lineStyle == ZBWTagItemViewLineStyle_Dashed) {
        self.contentBtn.layer.borderWidth = 0;
        
        self.shapeLayer.strokeColor = self.selectedBorderColor.CGColor;
        [self.contentBtn.layer addSublayer:self.shapeLayer];
    } else {
        [_shapeLayer removeFromSuperlayer];
        self.contentBtn.layer.borderWidth = 1;
    }

    self.contentBtn.layer.borderColor = self.selectedBorderColor.CGColor;
    self.contentBtn.titleLabel.font = self.selectedFont;
    [self.contentBtn setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
    
    if (self.searchHighlightTextColor) {
        self.contentBtn.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:_title];
//        self.contentBtn.titleLabel.attributedText = nil;
    }
}


#pragma mark- Event

- (void)onBtnClicked {
    if (_isEditing) {
        if (self.shouldEditingBlock && self.shouldEditingBlock(self)) {
            ZBW_SendUpSignal(@"tagItemViewRemoveClicked", self, nil, self);
        }
    } else {
        ZBW_SendUpSignal(@"tagItemViewClicked", self, nil, self);
    }
}

- (void)onLongPressed:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        ZBW_SendUpSignal(@"tagItemViewLongPressed", self, nil, self);
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    NSAssert(NO, @"不允许在外部设置TagItemView的点击事件");
}

#pragma mark- Getter/Setter

- (UIButton *)contentBtn {
//    __weakSelf
    if (!_contentBtn) {
        _contentBtn = [[UIButton alloc] initWithFrame:self.bounds];
        _contentBtn.userInteractionEnabled = NO;
//        _contentBtn.zbwClickCallback = ^{
//            [__weakedSelf onBtnClicked];
//        };
    }
    return _contentBtn;
}

- (ZBWTagDeleteView *)defaultDeleteView {
    if (!_defaultDeleteView) {
        _defaultDeleteView = [[ZBWTagDeleteView alloc] initWithFrame:CGRectMake(self.width - 12, 0, 12, 12)];
    }
    return _defaultDeleteView;
}

-(CAShapeLayer *)shapeLayer{
    
    if (!_shapeLayer) {
        
        _shapeLayer = [CAShapeLayer layer];
        
        _shapeLayer.strokeColor = self.normalBorderColor.CGColor;
        
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        
        UIBezierPath *path = nil;
        if (self.style == ZBWTagItemViewStyle_CornerRadius) {
            path = [UIBezierPath bezierPathWithRoundedRect:self.contentBtn.bounds cornerRadius:4];
        } else if (self.style == ZBWTagItemViewStyle_Circular) {
            path = [UIBezierPath bezierPathWithRoundedRect:self.contentBtn.bounds cornerRadius:self.contentBtn.bounds.size.height/2];
        }
        _shapeLayer.path = path.CGPath;
        
        _shapeLayer.frame = self.contentBtn.bounds;
        
        _shapeLayer.lineWidth = 1;
        
        _shapeLayer.lineCap = @"square";
        
        _shapeLayer.lineDashPattern = @[@3, @3];
        
    }
    
    return _shapeLayer;
    
}

@end
