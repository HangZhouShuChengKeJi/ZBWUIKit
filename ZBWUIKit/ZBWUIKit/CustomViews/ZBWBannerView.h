//
//  HomePageBannerView.h
//  
//
//  Created by limengqiang on 15/7/31.
//
//

#import <UIKit/UIKit.h>


@interface ZBWBannerItemInfo : NSObject

@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic) id    object;

+ (instancetype)bannerItemInfo:(NSString *)imageUrl object:(id)object;

@end

@interface ZBWBannerView : UIView
@property (nonatomic, assign) float timeSecond;
- (void)begin;
- (void)stopTimer;
@property (nonatomic, retain) NSArray *itemArray;

@end
