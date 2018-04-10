//
//  NTVChannelItem.m
//  SLNChannelControlDemo
//
//  Created by 乔冬 on 2017/11/27.
//  Copyright © 2017年 XinHuaTV. All rights reserved.
//

#import "NTVChannelItem.h"

@interface NTVChannelItem()
{
    CAShapeLayer * _borderLayer;
}
@property (weak, nonatomic) IBOutlet UILabel *slnTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *slnButton;
@end

@implementation NTVChannelItem

-(void)awakeFromNib{
    [super awakeFromNib];
}
#pragma mark -
#pragma mark 配置方法

-(UIColor*)backgroundColor{
    return [UIColor colorWithRed:241/255.0f green:241/255.0f blue:241/255.0f alpha:1];
}

-(UIColor*)textColor{
    return [UIColor colorWithRed:48/255.0f green:46/255.0f blue:255/255.0f alpha:1];
}

-(UIColor*)lightTextColor{
    return [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1];
}
#pragma mark -
#pragma mark Setter

-(void)setTitle:(NSString *)title
{
    _title = title;
    self.slnTextLabel.text = title;
}
-(void)setIcon:(NSString *)icon{
    _icon = icon;
    [_slnButton setImage:[UIImage imageNamed:_icon] forState:UIControlStateNormal];
}
-(void)setIsMoving:(BOOL)isMoving
{
    _isMoving = isMoving;
    if (_isMoving) {
        
//        self.backgroundColor = [UIColor clearColor];
    }else{
//        self.backgroundColor = [UIColor redColor];
    }
}

-(void)setIsFixed:(BOOL)isFixed{
    _isFixed = isFixed;
    if (isFixed) {
        [self setIcon:@""];
        _slnTextLabel.textColor = [self lightTextColor];
    }else{
        _slnTextLabel.textColor = [self textColor];
    }
}

@end
