//
//  NTVChooseChannelViewController.m
//  SLNChannelControlDemo
//
//  Created by 乔冬 on 2017/11/28.
//  Copyright © 2017年 XinHuaTV. All rights reserved.
//

#import "NTVChooseChannelController.h"
#import "NTVChannelItem.h"
#import "NTVChannelHeader.h"
static NSString *ntvChannelHeader = @"NTVChannelHeader";
static CGFloat const flowLayoutH = 35;
static CGFloat const cellH = 50;
//菜单列数
static NSInteger ColumnNumber = 4;
//横向和纵向的间距
static CGFloat CellMarginX = 1.0f;
static CGFloat CellMarginY = 1.0f;

@interface NTVChooseChannelController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    //被拖拽的item
    NTVChannelItem *_dragingItem;
    //正在拖拽的indexpath
    NSIndexPath *_dragingIndexPath;
    //目标位置
    NSIndexPath *_targetIndexPath;
    //记录固定的数量
    NSInteger  fixCount ;
}
//记录已选择的数组
@property (nonatomic, strong) NSMutableArray *inUseTitles;
//记录未选择的数组
@property (nonatomic,strong) NSMutableArray *unUseTitles;
@end

@implementation NTVChooseChannelController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _inUseTitles = [NSMutableArray arrayWithObjects:@"1",@"2",@"3", nil];
    _unUseTitles = [NSMutableArray arrayWithObjects:@"4",@"5",@"6", nil];
    [self setUpcollectionViews];
    
}
/**
 *  集合视图
 */
- (void)setUpcollectionViews{
    
    UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollPositionNone;//滚动方向
    flowLayout.minimumLineSpacing = CellMarginX;//行间距(最小值)
    flowLayout.minimumInteritemSpacing = CellMarginY;//item间距(最小值)
    CGFloat cellWidth = (self.view.bounds.size.width - (ColumnNumber + 1) * CellMarginX)/ColumnNumber;
    flowLayout.itemSize = CGSizeMake(cellWidth,cellH);
    
    CGRect rect ;
    rect = self.view.bounds;
    
    //第二个参数是cell的布局
    _collectionView= [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.bounces = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"NTVChannelItem" bundle:nil] forCellWithReuseIdentifier:@"NTVChannelItem"];
    [_collectionView registerClass:[NTVChannelHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ntvChannelHeader];
    flowLayout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width , flowLayoutH);
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
    longPress.minimumPressDuration = 0.3f;
    [_collectionView addGestureRecognizer:longPress];
    
    _dragingItem = [[NTVChannelItem alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellH)];
    _dragingItem.hidden = true;
    _dragingItem.backgroundColor= [UIColor whiteColor];
    [_collectionView addSubview:_dragingItem];
    
}
#pragma mark -
#pragma mark LongPressMethod

-(void)longPressMethod:(UILongPressGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:_collectionView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self dragBegin:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self dragChanged:point];
            break;
        case UIGestureRecognizerStateEnded:
            [self dragEnd];
            break;
        default:
            break;
    }
}

//拖拽开始 找到被拖拽的item
-(void)dragBegin:(CGPoint)point{
    _dragingIndexPath = [self getDragingIndexPathWithPoint:point];
    if (!_dragingIndexPath) {return;}
    [_collectionView bringSubviewToFront:_dragingItem];
    NTVChannelItem *item = (NTVChannelItem*)[_collectionView cellForItemAtIndexPath:_dragingIndexPath];
    item.isMoving = true;
    //更新被拖拽的item
    _dragingItem.hidden = false;
    _dragingItem.frame = item.frame;
    _dragingItem.title = item.title;
    [_dragingItem setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
}

//正在被拖拽、、、
-(void)dragChanged:(CGPoint)point{
    if (!_dragingIndexPath) {return;}
    _dragingItem.center = point;
    _targetIndexPath = [self getTargetIndexPathWithPoint:point];
    //交换位置 如果没有找到_targetIndexPath则不交换位置
    if (_dragingIndexPath && _targetIndexPath) {
        //更新数据源
        [self rearrangeInUseTitles];
        //更新item位置
        [_collectionView moveItemAtIndexPath:_dragingIndexPath toIndexPath:_targetIndexPath];
        _dragingIndexPath = _targetIndexPath;
    }
}

//拖拽结束
-(void)dragEnd{
    if (!_dragingIndexPath) {return;}
    CGRect endFrame = [_collectionView cellForItemAtIndexPath:_dragingIndexPath].frame;
    [_dragingItem setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    [UIView animateWithDuration:0.3 animations:^{
        _dragingItem.frame = endFrame;
    }completion:^(BOOL finished) {
        _dragingItem.hidden = true;
        NTVChannelItem *item = (NTVChannelItem*)[_collectionView cellForItemAtIndexPath:_dragingIndexPath];
        item.isMoving = false;
    }];
}

#pragma mark -
#pragma mark 辅助方法

//获取被拖动IndexPath的方法
-(NSIndexPath*)getDragingIndexPathWithPoint:(CGPoint)point{
    NSIndexPath* dragIndexPath = nil;
    //最后剩一个怎不可以排序
    if ([_collectionView numberOfItemsInSection:0] == 1) {return dragIndexPath;}
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        //下半部分不需要排序
        if (indexPath.section > 0) {continue;}
        //在上半部分中找出相对应的Item
        if (CGRectContainsPoint([_collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            if (indexPath.row >  fixCount) {
                dragIndexPath = indexPath;
            }
            break;
        }
    }
    return dragIndexPath;
}

//获取目标IndexPath的方法
-(NSIndexPath*)getTargetIndexPathWithPoint:(CGPoint)point{
    NSIndexPath *targetIndexPath = nil;
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        //如果是自己不需要排序
        if ([indexPath isEqual:_dragingIndexPath]) {continue;}
        //第二组不需要排序
        if (indexPath.section > 0) {continue;}
        //在第一组中找出将被替换位置的Item
        if (CGRectContainsPoint([_collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            if (indexPath.row >  fixCount) {
                targetIndexPath = indexPath;
            }
        }
    }
    return targetIndexPath;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return section == 0 ? _inUseTitles.count : _unUseTitles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NTVChannelItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NTVChannelItem" forIndexPath:indexPath];
    
    cell.title = indexPath.section == 0 ? _inUseTitles[indexPath.row] : _unUseTitles[indexPath.row];
    cell.icon = indexPath.section == 0 ? @"减去" : @"添加";
    cell.isFixed = indexPath.section == 0 && indexPath.row  <= fixCount;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    NTVChannelHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ntvChannelHeader forIndexPath:indexPath];
    headerView.backgroundColor = [UIColor colorWithRed:240/256.0 green:241/256.0  blue:242/256.0  alpha:1.0];
    if (indexPath.section == 0) {
        headerView.title = @"我的频道";
        headerView.subTitle = @"按住拖动调整排序";
    }else{
        headerView.title = @"点击添加频道";
        headerView.subTitle = @"";
    }
    return headerView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        //只剩一个的时候不可删除
        if ([_collectionView numberOfItemsInSection:0] == 1) {return;}
        //第一个不可删除
        if (indexPath.row  <= fixCount) {return;}
        id obj = [_inUseTitles objectAtIndex:indexPath.row];
        [_inUseTitles removeObject:obj];
        [_unUseTitles insertObject:obj atIndex:0];
        [_collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    }else{
        id obj = [_unUseTitles objectAtIndex:indexPath.row];
        [_unUseTitles removeObject:obj];
        [_inUseTitles addObject:obj];
        [_collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:_inUseTitles.count - 1 inSection:0]];
    }
    [self reloadData];
}

#pragma mark -
#pragma mark 刷新方法
//拖拽排序后需要重新排序数据源
-(void)rearrangeInUseTitles
{
    id obj = [_inUseTitles objectAtIndex:_dragingIndexPath.row];
    [_inUseTitles removeObject:obj];
    [_inUseTitles insertObject:obj atIndex:_targetIndexPath.row];
}

-(void)reloadData
{
    [_collectionView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
