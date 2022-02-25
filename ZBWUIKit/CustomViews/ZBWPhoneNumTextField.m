//
//  ZBWPhoneNumTextField.m
//  ZBWPhoneNumTextField
//
//  Created by Bowen on 14/12/5.
//  Copyright (c) 2014年 Bowen. All rights reserved.
//

#import "ZBWPhoneNumTextField.h"
#import <CoreText/CoreText.h>

#define MaxLength_Of_PhoneNum       11


/**
 *  由于iOS7.1系统中，UITextField的delegate如果设置成UITextField自身，会出现卡死，cup占用100%，因此使用次类来中转
 */
@interface ZBWDelegateProxy : NSObject<UITextFieldDelegate>

@property (nonatomic, weak) id<UITextFieldDelegate> phoneNumTextFieldDelegate;

@end

@implementation ZBWDelegateProxy

#pragma mark- <UITextFieldDelegate>
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    ZBWPhoneNumTextField *_self = (ZBWPhoneNumTextField *)textField;
    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
        return [_phoneNumTextFieldDelegate textField:_self shouldChangeCharactersInRange:range replacementString:string];
    }
    
    // 输入字符不能包括"0123456789 -"以外的字符
    if ([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789 -"].invertedSet options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return NO;
    }
    
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    // 删除符
//    if ([string isEqualToString:@""])
//    {
//        NSString *phoneNum = _self.phoneNum;
//        if (phoneNum.length >= 1)
//        {
//            NSString *text = _self.text;
//            NSString *replaceStr = [text substringWithRange:range];
//            if ([replaceStr isEqualToString:@" "]) {
//                text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location - 1, 1) withString:string];
//            }
//            else
//            {
//                text = [text stringByReplacingCharactersInRange:range withString:string];
//            }
//            _self.phoneNum = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
//        }
//        return NO;
//    }
    NSString *oldStr = textField.text;
    NSString *newStr = [oldStr stringByReplacingCharactersInRange:range withString:string];
    NSString *truePhoneNum = [[newStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];

    
    // 有效数值过大, 不允许输入
    if (truePhoneNum.length > _self.maxLength)
    {
        return NO;
    }
    else
    {
        _self.phoneNum = truePhoneNum;
        
        NSString *startStr = [[NSString stringWithFormat:@"%@%@",[oldStr substringToIndex:range.location],string] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSInteger length = startStr.length;
        
        UITextPosition* beginning = _self.beginningOfDocument;
        
        range.length = 0; range.location = length > 7 ? length + 2 : (length > 3 ? length + 1 : length);
        UITextPosition* startPosition = [_self positionFromPosition:beginning offset:range.location];
        UITextPosition* endPosition = [_self positionFromPosition:beginning offset:range.location + range.length];
        UITextRange* selectionRange = [_self textRangeFromPosition:startPosition toPosition:endPosition];
        
        [_self setSelectedTextRange:selectionRange];
        
        return NO;
    }
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
        return [_phoneNumTextFieldDelegate textFieldShouldBeginEditing:textField];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
        return [_phoneNumTextFieldDelegate textFieldDidBeginEditing:textField];
    }
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
        return [_phoneNumTextFieldDelegate textFieldShouldEndEditing:textField];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
        return [_phoneNumTextFieldDelegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
        return [_phoneNumTextFieldDelegate textFieldShouldClear:textField];
    }
    ((ZBWPhoneNumTextField *)textField).phoneNum = @"";
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
        return [_phoneNumTextFieldDelegate textFieldShouldReturn:textField];
    }
    return YES;
}


@end


@interface ZBWPhoneNumTextField ()

@property (nonatomic) ZBWDelegateProxy     *proxy;

@property (nonatomic) NSAttributedString    *attributedPlaceholderForIOS7;  // ios7.1 非常奇怪，attributedPlaceholder设置后，font无法修改，与text的font始终一致。

@end

@implementation ZBWPhoneNumTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initData];
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
    self.proxy = [[ZBWDelegateProxy alloc] init];
    super.delegate = self.proxy;
    self.maxLength = MaxLength_Of_PhoneNum;
    self.keyboardType = UIKeyboardTypeNumberPad;
    
#if 0
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    UIBarButtonItem *spaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *okBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(resignFirstResponder)];
    toolBar.items = @[spaceBarButtonItem, okBarButtonItem];
    
    self.inputAccessoryView = toolBar;
#endif
}

// 重写delegate，避免外部错误设置
- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    super.delegate = self.proxy;
}

- (void)setPhoneNumTextFieldDelegate:(id<UITextFieldDelegate>)phoneNumTextFieldDelegate
{
    self.proxy.phoneNumTextFieldDelegate = phoneNumTextFieldDelegate;
}

// 重写键盘，避免外部错误设置
- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    super.keyboardType = UIKeyboardTypePhonePad;
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    if ([[UIDevice currentDevice] systemVersion].floatValue < 8.0) {
        self.attributedPlaceholderForIOS7 = attributedPlaceholder;
    }
    
    super.attributedPlaceholder = attributedPlaceholder;
}

// 获取真实手机号
- (NSString *)phoneNum
{
    return [[self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

// 设置手机号
- (void)setPhoneNum:(NSString *)phoneNum
{
    phoneNum = [phoneNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSUInteger length = phoneNum.length;
    if (length > self.maxLength)
    {
        return;
    }
    
    // 3-4-4
    if (length >= 8)
    {
        self.text = [NSString stringWithFormat:@"%@ %@ %@", [phoneNum substringToIndex:3], [phoneNum substringWithRange:NSMakeRange(3, 4)], [phoneNum substringFromIndex:7]];
    }
    else if (length >= 4)
    {
        self.text = [NSString stringWithFormat:@"%@ %@", [phoneNum substringToIndex:3], [phoneNum substringFromIndex:3]];
    }
    else
    {
        self.text = phoneNum;
    }
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGRect rect = [super placeholderRectForBounds:bounds];
    return CGRectOffset(rect, 0, 0);
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    if (!self.attributedPlaceholderForIOS7) {
        [super drawPlaceholderInRect:rect];
        return;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    
    CTLineRef lineRef = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedPlaceholderForIOS7);
    CGContextTranslateCTM(context,
                          0,
                          -CGRectGetHeight(rect)+ (CGRectGetHeight(rect) - CTLineGetBoundsWithOptions(lineRef, kCTLineBoundsUseGlyphPathBounds).size.height)/2 +3);
    CTLineDraw(lineRef, context);
    CFRelease(lineRef);
}

@end


//@interface ZBWPhoneNumTextField ()<UITextFieldDelegate>
//@end
//
//@implementation ZBWPhoneNumTextField
//
//- (void)awakeFromNib
//{
//    [self initData];
//}
//
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame])
//    {
//        [self initData];
//    }
//    return self;
//}
//
//- (void)initData
//{
//    super.delegate = self;
//    self.maxLength = MaxLength_Of_PhoneNum;
//    self.keyboardType = UIKeyboardTypeNumberPad;
//}
//
//// 重写delegate，避免外部错误设置
//- (void)setDelegate:(id<UITextFieldDelegate>)delegate
//{
//    super.delegate = self;
//}
//
//// 重写键盘，避免外部错误设置
//- (void)setKeyboardType:(UIKeyboardType)keyboardType
//{
//    super.keyboardType = UIKeyboardTypePhonePad;
//}
//
//// 获取真实手机号
//- (NSString *)phoneNum
//{
//    return [[self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
//}
//
//// 设置手机号
//- (void)setPhoneNum:(NSString *)phoneNum
//{
//    phoneNum = [phoneNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSUInteger length = phoneNum.length;
//    if (length > self.maxLength)
//    {
//        return;
//    }
//    
//    // 3-4-4
//    if (length >= 8)
//    {
//        self.text = [NSString stringWithFormat:@"%@ %@ %@", [phoneNum substringToIndex:3], [phoneNum substringWithRange:NSMakeRange(3, 4)], [phoneNum substringFromIndex:7]];
//    }
//    else if (length >= 4)
//    {
//        self.text = [NSString stringWithFormat:@"%@ %@", [phoneNum substringToIndex:3], [phoneNum substringFromIndex:3]];
//    }
//    else
//    {
//        self.text = phoneNum;
//    }
//}
//
////- (CGRect)placeholderRectForBounds:(CGRect)bounds
////{
////    CGRect rect = [super placeholderRectForBounds:bounds];
////    return CGRectOffset(rect, 0, 3);
////}
//
//#pragma mark- <UITextFieldDelegate>
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
//        return [_phoneNumTextFieldDelegate textField:self shouldChangeCharactersInRange:range replacementString:string];
//    }
//    
//    if ([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789 -"].invertedSet options:NSCaseInsensitiveSearch].location != NSNotFound) {
//        return NO;
//    }
//    
//    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    
//    // 删除符
//    if ([string isEqualToString:@""])
//    {
//        NSString *phoneNum = self.phoneNum;
//        if (phoneNum.length >= 1)
//        {
//            self.phoneNum = [phoneNum substringToIndex:phoneNum.length - 1];
//        }
//        return NO;
//    }
//    NSString *oldStr = textField.text;
//    NSString *newStr = [oldStr stringByReplacingCharactersInRange:range withString:string];
//    NSString *truePhoneNum = [[newStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
//    // 有效数值过大, 不允许输入
//    if (truePhoneNum.length > self.maxLength)
//    {
//        return NO;
//    }
//    else
//    {
//        self.phoneNum = truePhoneNum;
//        return NO;
//    }
//}
//
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
//        return [_phoneNumTextFieldDelegate textFieldShouldBeginEditing:self];
//    }
//    return YES;
//}
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
//        return [_phoneNumTextFieldDelegate textFieldDidBeginEditing:self];
//    }
//}
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
//        return [_phoneNumTextFieldDelegate textFieldShouldEndEditing:self];
//    }
//    return YES;
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
//        return [_phoneNumTextFieldDelegate textFieldDidEndEditing:self];
//    }
//}
//
//- (BOOL)textFieldShouldClear:(UITextField *)textField
//{
//    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
//        return [_phoneNumTextFieldDelegate textFieldShouldClear:self];
//    }
//    self.phoneNum = @"";
//    return YES;
//}
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    if (_phoneNumTextFieldDelegate && [_phoneNumTextFieldDelegate respondsToSelector:_cmd]) {
//        return [_phoneNumTextFieldDelegate textFieldShouldReturn:self];
//    }
//    return YES;
//}
//
//@end
