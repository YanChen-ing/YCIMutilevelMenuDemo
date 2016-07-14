
![image](https://github.com/YanChen-ing/YCIMutilevelMenuDemo/blob/master/preview.gif)

# YCIMutilevelMenu
控件名: **_多级菜单_**  
继承: UIView
  
## 概述
---
依据上级菜单选中项,展示下级菜单.具有良好的可扩展性,并支持请求加载,默认选中,置顶选项等功能.

## 设计
---
### 基本原理

多级菜单视图,包含两种基本元素: 

* 选项 (option)
	
	保存展开菜单的信息的模型.
	
* 菜单 (menu)
	
	选项展开后,对应的样式.
	

多级菜单中,持有显示数组(`displayingOptions` `displayingMenus`).通过改变数组元素,并调用`- refreshViewsFrame`刷新界面显示.


### 解耦

为使多级菜单具有良好的可扩展性.通过以下方式解耦:

**多级菜单 -- 选项**

`YCIMenuOptionConfig.plist`保存对应type信息.

通过type,使用option工厂方法创建option.

**多级菜单 -- 菜单**

通过option的属性`menuClassName` 获得,并创建对应menu.

`@protocol YCIMenuDelegate `:菜单调用多级菜单的方法

`@protocol YCIMenuProtocol `:多级菜单调用菜单的方法

## 用法
---

### 使用

#### 0.准备
对于使用多级菜单,一般为较多且复杂的选项组.因此建议使用json文件存储选项内容.通过option的方法`+ menuOptionWithJsonFile:`生成选项.

#### 1.引入头文件

```
#import "YCIMutilevelMenu.h"
```

#### 2.创建多级菜单

```
- (YCIMutilevelMenu *)MLMenu{
    
    if (!_MLMenu) {
        
        static CGFloat topGap = 64;
        
        _MLMenu  = [[YCIMutilevelMenu alloc] initWithFrame:CGRectMake(0, topGap, self.view.bounds.size.width, self.view.bounds.size.height -topGap)];
        _MLMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _MLMenu.delegate  = self;
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
    return _MLMenu;
}
```
#### 3.遵守协议

```
@interface ViewController ()<YCIMutilevelMenuDelegate>
```
#### 4.实现代理方法

```
/**
 *  通过该方法,返回根选项,跟选项对应展示为第一级菜单
 */
- (YCIMenuOption *)rootOptionForMutilevelMenu:(YCIMutilevelMenu *)mutilevelMenu{
    
    YCIMenuOption *rootOption = [YCIMenuOption menuOptionWithJsonFile:@"filter.json"];
    
    return rootOption;
}
```

#### 5.获取操作信息

```
    /**
     * 获取多级菜单的操作信息.
     */
    [self.MLMenu.rootOption.options[0] enumerateObjectsUsingBlock:^(YCIMenuOption *  _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray *selectedOptionLink = [option selectedOptionLink];
    
        /**
         *  处理操作信息
         */
        
    }];
    
```
`selectedOptionLink`: 对应选项的选中链,例如:A->B->C.

#### 6.完成

### 扩展

当目前菜单样式不满足时.通过以下步骤,实现对样式的扩展.

#### 1.定义新选项类型

`YCIMenuDefinement.h`

```
/**
 *  每级子菜单类型
 */
typedef NS_ENUM(NSUInteger, YCIMenuType) {

    YCIMenuTypeDefault,
    /** 默认样式,需要请求网络数据*/
    YCIMenuTypeDefaultRequest,
    /** 日期区间选择 */
    YCIMenuTypeDateRange,
    /** 字母索引列表 */
    YCIMenuTypeLetterIndexTable,
    
};

```
并将其添加到typeKeys中,作为配置字典的key

`YCIMenuOption.m`

```
+ (void)initialize{
    [super initialize];
    
    typeKeys= @[
                @"YCIMenuTypeDefault",
                @"YCIMenuTypeDefaultRequest",
                @"YCIMenuTypeDateRange",
                @"YCIMenuTypeLetterIndexTable"
                ];
              ....
```


#### 2.创建新Option模型(可省略)

如有必要,继承`YCIMenuOption`,创建一个新选项模型.添加需要的属性及方法等.
示例:

```
#import "YCIMenuOption.h"

@interface YCIMenuLetterIndexOption : YCIMenuOption

@property (strong, nonatomic) NSMutableArray *marr_index;

@property (      nonatomic) BOOL hasSectionModels;

@property (strong, nonatomic) NSString *topSectionIndexTitle;

@end

```

#### 3.配置模型默认数据(可省略)

`YCIMenuOptionConfig.plist`文件中,添加该新选项分类名作为key.在字典中保存初始信息.具体参考文件内其他type.如无对应配置信息,则使用默认设置.

#### 4.创建对应视图,声明属性
目前多级菜单向菜单传值,仅支持三个属性:

```
@property (strong, nonatomic) YCIMenuOption *option;

@property (nonatomic, weak) id <YCIMenuDelegate> delegate;

@property (      nonatomic) BOOL defaultSelectedFirstRow;
```

**请根据需要,在视图中重新声明.(option必选)**

```
@protocol YCIMenuDelegate <NSObject>
@required
- (void)option:(YCIMenuOption *)highOption showOption:(YCIMenuOption *)lowOption;
- (void)addOption:(YCIMenuOption *)option;
- (void)refreshViewsFrame;

@end
```
多级菜单已实现协议`YCIMenuDelegate`.如有需要.即可声明属性`delegate`

#### 5.遵守并实现协议`<YCIMenuProtocol>`

```
@interface YCILetterIndexTable : UIView<YCIMenuProtocol>

```

**请不要在内部调用`-reloadData`,防止出现刷新问题**

#### 6.完成


### 注意事项

* 建议每个type都在plist中有对应初始值字典
* 自定义Menu内部,不要使用`-reloadData`方法.

## 改进
---

## 版本历史
---

Date         | Notes
------------ | -------------
2016.07.11   | 新建说明文档  


