//
//  YCIDateRangePicker.h
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/5/27.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCIMenuDateRangeOption.h"


static NSString *const kStartDate = @"startDate";
static NSString *const kEndDate   = @"endDate";

@interface YCIDateRangePicker : UIView<YCIMenuProtocol>

@property (strong, nonatomic) YCIMenuDateRangeOption *option;

@property (strong, nonatomic) NSMutableDictionary *infoDic;

@end
