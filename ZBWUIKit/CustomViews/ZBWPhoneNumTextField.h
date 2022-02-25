//
//  ZBWPhoneNumTextField.h
//  ZBWPhoneNumTextField
//
//  Created by Bowen on 14/12/5.
//  Copyright (c) 2014年 Bowen. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * 手机号输入TextField控件
 * 自动按3-4-4分割
 */
@interface ZBWPhoneNumTextField : UITextField

// 有效手机号的最大长度，默认为11
@property(nonatomic, assign)NSUInteger      maxLength;
// 真实的手机号
@property(nonatomic, copy)  NSString        *phoneNum;

@property (nonatomic, weak) id<UITextFieldDelegate> phoneNumTextFieldDelegate;

@end
