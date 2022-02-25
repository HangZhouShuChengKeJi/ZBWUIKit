//
//  ZBWImageTagItemView.m
//  ZBWUIKit
//
//  Created by 朱博文 on 2021/3/24.
//

#import "ZBWImageTagItemView.h"
#import <objc/runtime.h>

@interface ZBWImageTagItemView ()

@property (nonatomic) UIImageView   *imageView;
@property (nonatomic) UILabel       *titleLabel;

@end

@implementation ZBWImageTagItemView

- (instancetype)initWithIdentify:(NSString *)identify {
    if (self = [super init]) {
        self.padding = UIEdgeInsetsMake(5, 5, 5, 5);
        self.selectedBgColor = kZBW_Color_Orange;
        self.selectedTextColor = kZBW_Color_White;
        self.selectedFont = kZBW_Font_Micro;
        self.selectedBorderColor = kZBW_Color_Orange;
        
        self.normalBgColor = kZBW_Color_White;
        self.normalTextColor = kZBW_Color_Orange;
        self.normalFont = kZBW_Font_Micro;
        self.normalBorderColor = kZBW_Color_Orange;
        
        objc_setAssociatedObject(self, ZBWTagItemView_Identify_Key, identify, OBJC_ASSOCIATION_COPY);
    }
    self.frame = CGRectMake(0, 0, kZBW_SCREEN_WIDTH, 40);
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBtnClicked)];
    [self addGestureRecognizer:tapGesture];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.imageView.left = self.padding.left;
    self.imageView.centerY = self.height / 2;
    
    self.titleLabel.left = self.imageView.right + 5;
    self.titleLabel.centerY = self.height / 2;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}


- (void)updateUI {
    if (self.isSelected) {
        [self tagItemViewStateSelected];
    } else {
        [self tagItemViewStateNormal];
    }
}

#pragma mark overrider
- (CGSize)sizeThatFits:(CGSize)size {
//    CGFloat height = [@"全" boundingRectWithSize:CGRectMake(0, 0, 100, 30).size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : kZBW_Font_Small} context:nil].size.height;
    // |-padding-imageview-间隔-title label-padding-|
    [self.titleLabel sizeToFit];
    CGFloat width = self.imageView.width + 5 + self.titleLabel.width;
    CGFloat height = 15;
    width += 10*2;
    height += (self.padding.top + self.padding.bottom);
    width += (self.padding.left + self.padding.right);
    
    return CGSizeMake(width, height);
}

#pragma mark-
- (void)tagItemViewStateNormal {
    self.imageView.image = self.normalImage;
    self.titleLabel.textColor = self.normalTextColor;
    self.titleLabel.font = self.normalFont;
}

- (void)tagItemViewStateSelected {
    self.imageView.image = self.selectImage;
    self.titleLabel.textColor = self.selectedTextColor;
    self.titleLabel.font = self.selectedFont;
}

#pragma mark- Getter / Setter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(23, 0, 60, 25)];
    }
    
    return _titleLabel;
}

@end
