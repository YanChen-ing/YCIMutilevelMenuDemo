//
//  YCIMutilevelMenu.m
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/6/30.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import "YCIMutilevelMenu.h"
#import "objc/runtime.h"

static NSInteger  menuMinWidth  = 80;
static NSInteger const indicatorTag = 4000;

@interface YCIMutilevelMenu()

/** 根选项.展开显示为第一级菜单*/
@property (strong, nonatomic) YCIMenuOption *rootOption;

@property (strong, nonatomic) NSMutableArray *displayingOptions;
@property (strong, nonatomic) NSMutableArray *displayingMenus;


@property (strong, nonatomic) NSMutableArray *reuseMenus;
@property (copy  , nonatomic) NSMutableArray *removeMenus;

@end

@implementation YCIMutilevelMenu

#pragma mark - ------- Init

+ (void)initialize{
    [super initialize];
    
    //init data
    NSString *deviceModel = [[UIDevice currentDevice] model];

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"YCIMenuConfig" ofType:@"plist"];
    NSDictionary *menuConfigs = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSDictionary *config = menuConfigs[deviceModel];
    
    
    if (config) {
        
        NSInteger value = [[config valueForKey:@"menuMinWidth"] integerValue];
        
        if (value) {
            menuMinWidth = value;
        }
    
    }
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configData];
    }
    return self;
}

#pragma mark - ------- Life Cycle

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willMoveToSuperview:(nullable UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    self.backgroundColor = YCI_SeparatorColor;
    
    _rootOption = [self.delegate rootOptionForMutilevelMenu:self];
    
    [self addOption:_rootOption];
    [self refreshViewsFrame];
}

- (void)deviceOrientationDidChange{
    [self refreshViewsFrame];
}

- (void)configData{
    
    _displayingOptions = [NSMutableArray array];
    _displayingMenus   = [NSMutableArray array];
    _reuseMenus        = [NSMutableArray array];
    _removeMenus       = [NSMutableArray array];
    
    _animated = YES;
    _defaultSelectedFirstRow = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

#pragma mark - ------- Public
/**
 *  show lowOption from highOption
 *
 *  @param highOption which will show next option
 *  @param lowOption  which will displayed . if nil , means not show lowOption.
 */
- (void)option:(YCIMenuOption *)highOption showOption:(YCIMenuOption *)lowOption{
    
    NSInteger level = [_displayingOptions indexOfObject:highOption];
    if (level == NSNotFound) {
        return;
    }
    
    //is displaying highOption
    
    level ++;     //next level
    
    if (level < _displayingOptions.count) {
        
        if (_displayingOptions[level] == lowOption) {
            //is displaying lowOption
            return;
        }
        
        [self removeOption:_displayingOptions[level]];
    }
    
    //show lowOption
    [self addOption:lowOption];
    
    [self refreshViewsFrame];
    
}

- (void)clearAllSelection{
    
    [_rootOption.options enumerateObjectsUsingBlock:^(NSArray * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [section enumerateObjectsUsingBlock:^(YCIMenuOption *  _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [option clearUserOperation];
            
        }];
        
    }];
    
    //topSection
    if (_rootOption.topSection) {
        
        [_rootOption.topSection enumerateObjectsUsingBlock:^(YCIMenuOption *  _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSAssert([option isKindOfClass:[YCIMenuOption class]], @"topSection items must be YCIMenuOption Class");
            
            [option clearUserOperation];
            
        }];
    }
    
    [_rootOption clearUserOperation];
    
    [self reloadOption:_rootOption];
}

#pragma mark - ------- Option Update

//=============================
//
//    option match menu
//
//=============================

- (void)addOption:(YCIMenuOption *)option{
    
    if (!option) {
        return;
    }
    
    [_displayingOptions addObject:option];
    UIView *menu = [self menuForOption:option];
    
    [_displayingMenus addObject:menu];
    [self addSubview:menu];
    
    //调用代理(多参数)
    SEL aSelector = @selector(mutilevelMenu:WillDisplayMenu:WithOption:);
    
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    
    if(signature){
        //创建方法调用方法
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        //设置方法调用类
        [invocation setTarget:self];
        
        //设置方法
        [invocation setSelector:aSelector];
        
        [invocation setArgument:&self atIndex:0];
        [invocation setArgument:&menu atIndex:1];
        [invocation setArgument:&option atIndex:2];
    }
    
}

- (void)removeOption:(YCIMenuOption *)option{
    
    NSInteger level = [_displayingOptions indexOfObject:option];
    if (level == NSNotFound) {
        return;
    }
    
    for (NSInteger i = _displayingMenus.count -1; i >= level; i--) {
        
        YCIMenuOption *menuOption = _displayingOptions[i];
        
        UIView *menu = _displayingMenus[i];
        
        [_displayingOptions removeObjectAtIndex:i];
        [_displayingMenus   removeObjectAtIndex:i];
        
        [_removeMenus addObject:menu];
        
//        if (self.animated) {
//            
//            __weak __typeof(self) weakSelf = self;
//            [UIView animateWithDuration:YCI_animateDuration delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                
//                CGRect targetFrame = menu.frame;
//                targetFrame.origin.x = self.bounds.size.width;
//                menu.frame = targetFrame;
//                
//            }completion:^(BOOL finished) {
//                [menu removeFromSuperview];
//                [weakSelf.reuseMenus addObject:menu];
//            }];
//            
//        }else{
//            [menu removeFromSuperview];
//            [_reuseMenus addObject:menu];
//        }
        
        SEL aSelector = @selector(mutilevelMenu:didEndDisplayingMenu:WithOption:);
        
        if ([self.delegate respondsToSelector:aSelector]) {
            [self.delegate mutilevelMenu:self didEndDisplayingMenu:menu WithOption:menuOption];
        }
    }
}

- (void)reloadOption:(YCIMenuOption *)option{
    
    NSInteger level = [_displayingOptions indexOfObject:option];
    if (level == NSNotFound) {
        return;
    }
    
    if (level + 1< _displayingOptions.count) {
        [self removeOption:_displayingOptions[level +1]];
    }
    
    UIView *menu = _displayingMenus[level];
    
    if ([menu conformsToProtocol:NSProtocolFromString(@"YCIMenuProtocol")]) {
        [menu performSelector:@selector(reloadData)];
    }
    
    if (option.showLoading == NO) {
        [self dismissIndicatorViewInView:menu];
    }
    
}

#pragma mark - ------- Menu

- (UIView *)menuForOption:(YCIMenuOption *)option{
    
    UIView *menu = [self dequeueMenuForOption:option];
    
    if (!menu) {
        menu = [self createMenuForOption:option];
    }
    
    NSAssert(menu, @"must have menu match option Type");
    
    [self configMenuData:menu WithOption:option];
    
    menu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    menu.tag = option.type;
    
    if (option == self.rootOption) {
        menu.frame = self.bounds;
    }else{
        menu.frame = CGRectMake(self.bounds.size.width, 0, 0, self.bounds.size.height);
    }
    
    return menu;
}
- (UIView *)dequeueMenuForOption:(YCIMenuOption *)option{
    
    UIView *retMenu;
    
    for (UIView *menu in self.reuseMenus) {
        
        if (menu.tag == option.type) {
            retMenu = menu;
            [self.reuseMenus removeObject:menu];
            break;
        }
    }
    return retMenu;
}

- (UIView *)createMenuForOption:(YCIMenuOption *)option{
    
    UIView *menu;
    
    NSString *className = option.menuClassName;
    if (!className) {
        className = @"YCIMenuDefaultTable";
    }
    
    Class menuClass = NSClassFromString(option.menuClassName);
    
    NSAssert(menuClass, @"must have class to match option");
    
    menu = [[menuClass alloc] initWithFrame:self.bounds];
    
    return menu;
}

- (void)configMenuData:(UIView *)menu WithOption:(YCIMenuOption *)option{
    
    NSDictionary *params =@{
                            @"option":option,
                            @"delegate":self,
                            @"defaultSelectedFirstRow":@(self.defaultSelectedFirstRow)
                            };
    
    NSArray *keys = [params allKeys];
    
    NSSet *allowdKeys = [self allowedPropertyNamesFromNames:keys InClass:[menu class]];
    
    [allowdKeys enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        
        id value = [params valueForKey:obj];
        if (value) {
            [menu setValue:value forKey:obj];
        }
    }];
    
    if (option.showLoading == YES) {
        [self showIndicatorViewInView:menu];
    }else{
        [self dismissIndicatorViewInView:menu];
    }
    
}

/**
 *  get valid property keys from names ,in a class
 */
- (NSSet *)allowedPropertyNamesFromNames:(NSArray *)names InClass:(Class)aClass{
    
    NSMutableSet *namesSet = [NSMutableSet setWithArray:names];
    
    NSMutableSet *allowedNamesSet = [NSMutableSet set];
    
    //get aClass property list
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(aClass, &count);
    for(int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [allowedNamesSet addObject:name];
        
    }  
    free(properties);
    
    [namesSet intersectSet:allowedNamesSet];
    
   return namesSet;
}


- (void)refreshViewsFrame{
    
    NSInteger num = self.displayingMenus.count;
    
    CGFloat width  = (self.bounds.size.width -(num -1))/num;
    CGFloat height = self.bounds.size.height;
    
    if (self.zoomOutHighLevelMenuWidth) {
        width = menuMinWidth;
    }
    
    void (^updateFrames)() = ^{
        
        //displaying views frame
        for (int i = 0; i < num; i++) {
            
            CGRect targetFrame = CGRectMake(i *(width+1), 0, width, height);
            
            if (i == num -1) {
                //last Menu
                targetFrame.origin.x   = (width + 1)*(num -1);
                targetFrame.size.width = self.bounds.size.width - targetFrame.origin.x;
            }
            
            UIView *menu = self.displayingMenus[i];
            
            menu.frame = targetFrame;
            
            YCIMenuOption *option = self.displayingOptions[i];
            
            if (option.autoBackgroundColor) {
                menu.backgroundColor = [self backgroundColorWithLevel:i];
            }
        }
        
        //dismiss views frame
            
    
        for (UIView *menu in self.removeMenus) {
            CGRect targetFrame = menu.frame;
            targetFrame.origin.x = self.bounds.size.width;
            menu.frame = targetFrame;
        }
    
    };
    
    void (^completion)(BOOL finished) = ^(BOOL finished){
        
        for (NSInteger i = self.removeMenus.count -1; i >= 0; i--) {
            
            UIView *menu = self.removeMenus[i];
            
            [menu removeFromSuperview];
            [self.reuseMenus addObject:menu];
            [self.removeMenus removeObject:menu];
        }
    };
    

    if (self.animated) {
        [UIView animateWithDuration:YCI_animateDuration delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:updateFrames completion:completion];
        
    }else{
        updateFrames();
        completion(YES);
    }
    
    
}

#pragma mark - ------- Indicator

- (void)showIndicatorViewInView:(UIView *)view{
    
    UIActivityIndicatorView *indicator = [view viewWithTag:indicatorTag];
    
    if (indicator) {
        [indicator startAnimating];
        return;
    }
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    indicator.center = view.center;
    indicator.tag = indicatorTag;
    
    [indicator startAnimating];
    
    [view addSubview:indicator];
    [view bringSubviewToFront:indicator];
}

- (void)dismissIndicatorViewInView:(UIView *)view{
    
    UIActivityIndicatorView *indicator = [view viewWithTag:indicatorTag];
    [indicator removeFromSuperview];
}

#pragma mark - -------

- (YCIMenuOption *)optionForMenu:(UIView *)menu{
    
    NSInteger level = [_displayingMenus indexOfObject:menu];
    if (level == NSNotFound) {
        return nil;
    }
    
    YCIMenuOption *option = _displayingOptions[level];
    return option;
}

- (UIColor *)backgroundColorWithLevel:(NSUInteger)level{
    
    CGFloat num = (245 +5*level)/255.0f;
    if (num > 1) {
        num = 2 -num;
    }
    return [UIColor colorWithRed:num green:num blue:num alpha:1.0f];
}

@end
