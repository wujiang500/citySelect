//
//  LovationViewController.h
//  platform
//
//  Created by wujiang on 15/11/4.
//  Copyright © 2015年 wujiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LovationViewControllerProtocol
- (void) citySelectionUpdate:(NSString*)selectedCity;
@end

@interface LovationViewController : UIViewController

@property (nonatomic, assign) id <LovationViewControllerProtocol> myDelegate;

@end
