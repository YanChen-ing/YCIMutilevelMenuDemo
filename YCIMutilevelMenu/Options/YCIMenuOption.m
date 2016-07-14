//
//  YCIMenuOption.m
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/6/30.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import "YCIMenuOption.h"
#import "UIKit/UIDevice.h"

static NSArray *typeKeys;
static NSDictionary *configs;

static NSString *const optionTypeKey      = @"type";
static NSString *const optionOptionsKey   = @"options";

@implementation YCIMenuOption

#pragma mark - ------- Init

+ (void)initialize{
    [super initialize];
    
    typeKeys= @[
                @"YCIMenuTypeDefault",
                @"YCIMenuTypeDefaultRequest",
                @"YCIMenuTypeDateRange",
                @"YCIMenuTypeLetterIndexTable"
                ];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"YCIMenuOptionConfig" ofType:@"plist"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *deviceModel = [[UIDevice currentDevice] model];
    
    configs = dic[deviceModel];
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _menuClassName = @"YCIMenuDefaultTable";
        _cellClassName = @"YCIMenuDefaultTableCell";
        _cellHeight = 44;
        _autoBackgroundColor = YES;
    }
    return self;
}

+ (instancetype)menuOptionWithMenuType:(YCIMenuType)type{
    
    NSAssert(type < typeKeys.count, @"must have typeKey for type");
    
    //alloc option class with type
    NSDictionary *optionConfig = [configs valueForKey:typeKeys[type]];
    
    NSString *className = optionConfig[optionClassNameKey];
    
    if (!className) {
        className = @"YCIMenuOption";
    }
    
    Class optionClass = NSClassFromString(className);
    
    //config option
    
    YCIMenuOption *option = [[optionClass alloc] init];
    
    option.type = type;
    
    [option configOptionWithDictionary:optionConfig];
    
    return option;
}

+ (instancetype)menuOptionWithJsonFile:(NSString *)fileName{
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    
    NSString *json = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    id obj = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    
    NSAssert([obj isKindOfClass:[NSDictionary class]],@"json for mutilevelMenu format is error");
    
    return [YCIMenuOption menuOptionWithDictionary:obj];
    
}

#pragma mark - ------- Recursive Init

+ (instancetype)menuOptionWithDictionary:(NSDictionary *)config{
    
    YCIMenuType type = [[config valueForKey:optionTypeKey] integerValue];
    
    YCIMenuOption *option = [YCIMenuOption menuOptionWithMenuType:type];
    
    [option configOptionWithDictionary:config];
    
    return option;
}

- (void)configOptionWithDictionary:(NSDictionary *)config{
    
    [config enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([key isEqualToString:optionOptionsKey]) {
            //options 递归
            NSAssert([obj isKindOfClass:[NSArray class]], @"json for mutilevelMenu format is error");
            
            //转为二维数组
            if ([obj[0] isKindOfClass:[NSDictionary class]]) {
                obj = [NSArray arrayWithObject:obj];
            }
            
            NSMutableArray *sections = [NSMutableArray array];
            
            [obj enumerateObjectsUsingBlock:^(NSArray * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSMutableArray *options = [NSMutableArray array];
                
                [section enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull config, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSAssert([config isKindOfClass:[NSDictionary class]], @"json for mutilevelMenu format is error");
                    
                    [options addObject:[YCIMenuOption menuOptionWithDictionary:config]];
                    
                }];
                
                [sections addObject:options];
            }];
            
            obj = sections;
        }
        
        [self setValue:obj forKey:key];
        
    }];
}

- (NSArray *)selectedOptionLink{
    
    if (!self.selectedIndexPath || self.options.count == 0) {
        return nil;
    }
    
    NSMutableArray *link = [NSMutableArray array];
    
    [self addSelectedOptionToMutableArray:link];
    
    return link;
}

- (void)addSelectedOptionToMutableArray:(NSMutableArray *)arr{
    
    if (!self.selectedIndexPath || self.options.count == 0) {
        return;
    }
    
    NSInteger section = [self.selectedIndexPath indexAtPosition:0];
    NSInteger row     = [self.selectedIndexPath indexAtPosition:1];
    
    YCIMenuOption *selectedOption = self.options[section][row];
    
    if (!selectedOption) {
        return;
    }
    
    [arr addObject:selectedOption];
    
    [selectedOption addSelectedOptionToMutableArray:arr];
    
}

#pragma mark - ------- Logic

- (void)clearUserOperation{
    
    switch (self.type) {
        case YCIMenuTypeDefault:
        case YCIMenuTypeDefaultRequest:
        {
            if (_selectedIndexPath) {
                YCIMenuOption *option = [self optionForIndexPathInOptions:self.selectedIndexPath];
                
                [option clearUserOperation];
                
                self.selectedIndexPath = nil;
            }
        }
            break;
            
        default:
            break;
    }
    
}

//- (BOOL)hasRightDetailData{
//    
//    switch (self.type) {
//        case YCIMenuTypeDefaultRequest:
//        {
//            if (self.options) {
//                return YES;
//            }
//        }
//            break;
//            
//        default:
//            return YES;
//    }
//    return NO;
//}

- (YCIMenuOption *)optionForIndexPathInOptions:(NSIndexPath *)indexPath{
    
    NSAssert(self.selectedIndexPath.length == 2, @"selectedIndexPath length must is 2");
    
    NSInteger section = [self.selectedIndexPath indexAtPosition:0];
    NSInteger row     = [self.selectedIndexPath indexAtPosition:1];
    
    YCIMenuOption *option = self.options[section][row];
    
    return option;
}

- (NSString *)pinyinForString:(NSString *)originalStr{
    
    NSMutableString *mStr = [originalStr mutableCopy];
    
    if (CFStringTransform((__bridge CFMutableStringRef)mStr, 0, kCFStringTransformMandarinLatin, NO)) {
        
        if(CFStringTransform((__bridge CFMutableStringRef)mStr, 0, kCFStringTransformStripDiacritics, NO)){
            return mStr;
        }
    }
    
    return nil;
}

#pragma mark - ------- setter & getter

- (void)setOptions:(NSArray *)options{
    
    _canShowDetail = options && options.count > 0;
    _options = options;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"YCIMenuOption undefinedKey:%@,",key);
}

- (NSString *)titlePinyin{
    
    if (!_titlePinyin) {
        _titlePinyin = [self pinyinForString:self.title];
    }
    return _titlePinyin;
}

- (void)setTopSection:(NSArray *)topSection{
    
    if (_topSection == topSection) {
        return;
    }
    
    _topSection = topSection;
    
    if (topSection.count == 0) {
        return;
    }
    
    id value = _topSection[0];
    if ([value isKindOfClass:[YCIMenuOption class]]) {
        // is converted
        return;
    }
    
    //convert to options
    __block NSMutableArray *options = [NSMutableArray array];
    [_topSection enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSAssert([obj isKindOfClass:[NSDictionary class]], @"top Section data invalid");
        
        [options addObject:[YCIMenuOption menuOptionWithDictionary:obj]];
        
    }];
    
    _topSection = options;
    if (options.count > 0) {
        _hasDefaultTopSection = YES;
    }else{
        _hasDefaultTopSection = NO;
        _topSection = nil;
    }
}


@end
