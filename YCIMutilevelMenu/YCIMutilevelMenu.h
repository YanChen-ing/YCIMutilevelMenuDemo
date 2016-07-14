//
//  YCIMutilevelMenu.h
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/6/30.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCIMenuOption.h"

@protocol YCIMutilevelMenuDelegate;
/**
 *  多级菜单
 *  
 *  @discuss 具有关联效果的多级菜单展开控件,通过选中每级菜单中的选项,展开选项对应的菜单
 */
@interface YCIMutilevelMenu : UIView<YCIMenuDelegate>

/** 通过根选项获取选中信息*/
@property (strong, nonatomic, readonly) YCIMenuOption *rootOption;

@property (nonatomic, weak) id <YCIMutilevelMenuDelegate> delegate;

/** 高级菜单宽度.(1级相对于2级,是高级)*/
@property (      nonatomic) BOOL zoomOutHighLevelMenuWidth;
@property (      nonatomic) BOOL defaultSelectedFirstRow;
@property (      nonatomic) BOOL animated;


/**
 *  若当前显示选项为option,则刷新.否则,不刷新
 */
- (void)reloadOption:(YCIMenuOption *)option;
/** 新增一级,展示option*/
- (void)option:(YCIMenuOption *)highOption showOption:(YCIMenuOption *)lowOption;

- (void)refreshViewsFrame;

- (void)clearAllSelection;

/**
 *  根据option,从缓存队列取出所需菜单视图
 */
- (UIView *)dequeueMenuForOption:(YCIMenuOption *)option;


@end

@protocol YCIMutilevelMenuDelegate <NSObject>

@required
/** 根选项.根选项展开显示为第一级菜单*/
- (YCIMenuOption *)rootOptionForMutilevelMenu:(YCIMutilevelMenu *)mutilevelMenu;

@optional

/**
 *  返回option对应的菜单视图
 */
- (UIView *)mutilevelMenu:(YCIMutilevelMenu *)mutilevelMenu menuForOption:(YCIMenuOption *)option;

- (UIView *)mutilevelMenu:(YCIMutilevelMenu *)mutilevelMenu WillDisplayMenu:(UIView *)menu WithOption:(YCIMenuOption *)option;

- (UIView *)mutilevelMenu:(YCIMutilevelMenu *)mutilevelMenu didEndDisplayingMenu:(UIView *)menu WithOption:(YCIMenuOption *)option;


@end
