//
//  ViewController.m
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/6/30.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import "ViewController.h"
#import "YCIMutilevelMenu.h"

@interface ViewController ()<YCIMutilevelMenuDelegate>

@property (strong, nonatomic) YCIMutilevelMenu *MLMenu;

@property (strong, nonatomic) UIButton *btn_restore;

@end

@implementation ViewController

#pragma mark - ------- Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"多级菜单";
    [self.view addSubview:self.MLMenu];
    [self.view addSubview:self.btn_restore];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    /**
     * 获取多级菜单的操作信息.
     */
    [self.MLMenu.rootOption.options[0] enumerateObjectsUsingBlock:^(YCIMenuOption *  _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray *selectedOptionLink = [option selectedOptionLink];
        NSLog(@"////%@",selectedOptionLink);
    
        /**
         *  处理操作信息
         */
        
    }];
    
    
}

#pragma mark - ------- YCIMutilevelMenuDelegate
/**
 *  通过该方法,返回根选项,跟选项对应展示为第一级菜单
 */
- (YCIMenuOption *)rootOptionForMutilevelMenu:(YCIMutilevelMenu *)mutilevelMenu{
    
    YCIMenuOption *rootOption = [YCIMenuOption menuOptionWithJsonFile:@"filter.json"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        YCIMenuOption *firstOption = rootOption.options[0][0];
        NSMutableArray *marr = [NSMutableArray array];
        NSMutableArray *section = [NSMutableArray array];
        
        [section addObjectsFromArray:[self requestedOption].options[0]];
        [marr addObject:section];
        
        firstOption.options = marr;
        firstOption.showLoading = NO;
        [self.MLMenu reloadOption:firstOption];
        
    });
    
    return rootOption;
}



#pragma mark - ------- Setter & Getter

- (YCIMutilevelMenu *)MLMenu{
    
    if (!_MLMenu) {
        
        static CGFloat topGap = 64;
        static CGFloat bottomGap = 40;
        
        _MLMenu  = [[YCIMutilevelMenu alloc] initWithFrame:CGRectMake(0, topGap, self.view.bounds.size.width, self.view.bounds.size.height -topGap -bottomGap)];
        _MLMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _MLMenu.delegate  = self;
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
    return _MLMenu;
}

- (YCIMenuOption *)requestedOption{
    
    NSDictionary *dic = @{
                          @"title":@"aa",
                          
                          @"options":@[
                                  
                                  @{
                                      @"title":@"小李子",
                                      @"type":@(3),
                                      @"topSection":@[
                                              @{
                                                  @"title":@"全部销售",
                                                  },
                                              ],
                                      @"options":@[
                                              @{
                                                  @"title":@"小小",
                                                  },
                                              @{
                                                  @"title":@"丽丽",
                                                  
                                                  },
                                              ]
                                      },
                                  ]
                          };
    
    return [YCIMenuOption menuOptionWithDictionary:dic];

}

- (UIButton *)btn_restore{
    
    if (!_btn_restore) {
        
        CGSize size = self.view.bounds.size;
        
        _btn_restore = [UIButton buttonWithType:UIButtonTypeSystem];
        
        _btn_restore.frame = CGRectMake(0, size.height -40, size.width, 40);
        _btn_restore.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        [_btn_restore setBackgroundColor:[UIColor whiteColor]];
        
        [_btn_restore setTitle:@"恢复默认筛选条件" forState:UIControlStateNormal];
        [_btn_restore setTitleColor:YCI_ColorFromRGB(0x5A8BE7) forState:UIControlStateNormal];
        _btn_restore.titleLabel.font = [UIFont systemFontOfSize:12];
        
        [_btn_restore addTarget:self.MLMenu action:@selector(clearAllSelection) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, 1)];
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        separator.backgroundColor = YCI_ColorFromRGB(0xEEEEEE);
        
        [_btn_restore addSubview:separator];
        
    }
    return _btn_restore;
}

@end
