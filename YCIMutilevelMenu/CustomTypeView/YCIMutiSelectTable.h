//
//  YCIMutiSelectTable.h
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/10/8.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCIMutiSelectOption.h"

@interface YCIMutiSelectTable : UIView<YCIMenuProtocol>

@property (strong, nonatomic) YCIMutiSelectOption *option;

//@property (nonatomic, weak) id <YCIMenuDelegate> delegate;
//
//@property (      nonatomic) BOOL defaultSelectedFirstRow;

@end
