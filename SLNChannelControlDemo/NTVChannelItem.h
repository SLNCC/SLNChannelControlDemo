//
//  NTVChannelItem.h
//  SLNChannelControlDemo
//
//  Created by 乔冬 on 2017/11/27.
//  Copyright © 2017年 XinHuaTV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTVChannelItem : UICollectionViewCell
//标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic,copy) NSString *icon;

//是否正在移动状态
@property (nonatomic, assign) BOOL isMoving;

//是否被固定
@property (nonatomic, assign) BOOL isFixed;
@end
