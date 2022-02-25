//
//  ZBWImageTagItemView.h
//  ZBWUIKit
//
//  Created by 朱博文 on 2021/3/24.
//

#import "ZBWTagItemView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 左图片，右文本的check view
 */
@interface ZBWImageTagItemView : ZBWTagItemView

// 选中状态下的图片
@property (nonatomic) UIImage   *selectImage;
// 未选中状态下的图片
@property (nonatomic) UIImage   *normalImage;

@end

NS_ASSUME_NONNULL_END
