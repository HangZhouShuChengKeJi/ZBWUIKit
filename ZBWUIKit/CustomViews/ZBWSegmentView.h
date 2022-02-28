//
//  ZBWSegmentView.h
//
//
//  Created by Bowen on 16/4/20.
//  Copyright © 2016年. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ZBWSegmentChangeBlock)(NSInteger index);

/*
 当segmentItem比较少时，如何排列显示。
*/
typedef NS_ENUM(NSInteger, ZBWSegmentItemDisplayType) {
    ZBWSegmentItemDisplayType_FullWidth = 0,        // 宽度填满，平均分配宽度。 默认。
    ZBWSegmentItemDisplayType_Center = 1,           // 宽度不变，居中显示；
    ZBWSegmentItemDisplayType_Left = 2              // 宽度不变，靠左显示；
};

@class ZBWSegmentItem;

@protocol ZBWSegmentItemProtocol <NSObject>

@optional
- (UIView *)customView;

- (void)segmentItem:(ZBWSegmentItem *)item containerFrameChanged:(CGRect)rect;

- (void)segmentItem:(ZBWSegmentItem *)item selectedChanged:(BOOL)isSelected ;

@end


@interface ZBWSegmentItem : NSObject <ZBWSegmentItemProtocol>

@property (nonatomic, retain) UIFont            *normalFont;
@property (nonatomic, retain) UIFont            *selectedFont;
@property (nonatomic, retain) UIColor           *normalColor;
@property (nonatomic, retain) UIColor           *selectedColor;
@property (nonatomic, retain) UIImage           *normalImage;
@property (nonatomic, retain) UIImage           *selectedImage;
@property (nonatomic, retain) UIImage           *bgImage;
@property (nonatomic, copy) NSString          *title;
@property (nonatomic, assign) CGFloat           spaceH;

@end


@interface ZBWSegmentView : UIView

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) ZBWSegmentChangeBlock    indexChangeBlock;
@property (nonatomic, retain) UIColor           *selectionIndicatorColor;
@property (nonatomic, assign) ZBWSegmentItemDisplayType displayType;
@property (nonatomic, copy) NSArray<ZBWSegmentItem *>     *items;

+ (instancetype)initWithFrame:(CGRect)frame
                horizontalMargin:(CGFloat)horizontalMargin
         selectionIndicatorColor:(UIColor *)selectionIndicatorColor
                  displayType:(ZBWSegmentItemDisplayType)displayType
                     segmentItem:(NSArray<ZBWSegmentItem *> *)items;

@end
