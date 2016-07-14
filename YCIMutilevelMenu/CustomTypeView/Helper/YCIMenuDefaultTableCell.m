//
//  YCIMenuDefaultTableCell.m
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/6/30.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import "YCIMenuDefaultTableCell.h"

@interface YCIMenuDefaultTableCell ()

@property (strong, nonatomic) UILabel *lb_title;

@end

@implementation YCIMenuDefaultTableCell

+ (void)initialize{
    [super initialize];
    
    //init Data
    NSString *deviceModel = [[UIDevice currentDevice] model];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"YCIMenuConfig" ofType:@"plist"];
    NSDictionary *menuConfigs = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSDictionary *config = menuConfigs[deviceModel];
    
    NSNumber *value = [config valueForKey:@"fontSize"];
    
    fontSize = value ?:@(16);
    
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.lb_title];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height -1,self.frame.size.width,1)];
    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin;
    separator.backgroundColor = YCI_SeparatorColor;
    
    [self.contentView addSubview:separator];
}

- (void)bindDataWithModel:(YCIMenuOption *)model{
    _lb_title.text = model.title;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.backgroundColor = [UIColor whiteColor];
        self.lb_title.textColor = YCI_TextSelectedColor;
    }else{
        self.backgroundColor = [UIColor clearColor];
        self.lb_title.textColor = YCI_TextColor;
    }
    
}

#pragma mark - ------- setter & getter

- (UILabel *)lb_title{
    
    if (!_lb_title) {
        
        CGRect frame = self.bounds;
        frame.origin.x = 10;
        frame.size.width -= 20;
        
        _lb_title = [[UILabel alloc] initWithFrame:frame];
        _lb_title.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        _lb_title.textColor = YCI_TextColor;
        _lb_title.font = [UIFont systemFontOfSize:[fontSize floatValue]];
        _lb_title.backgroundColor = [UIColor clearColor];
    }
    return _lb_title;
}

@end
