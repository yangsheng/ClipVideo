//
//  FilterBottomView.m
//  ClipVideo
//
//  Created by leeco on 2018/10/31.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "FilterBottomView.h"
#import "FilterModel.h"

static NSString *const cellId = @"filterCollectionViewCell";
#define cellWidth 80
@interface filterCollectionViewCell()
@property(nonatomic, strong) UIImageView * imageView;
@property(nonatomic, strong)UILabel * nameLabel;
@end

@implementation filterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configureUI];
    }
    return self;
}


- (void)configureUI{

    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 0, cellWidth-20, cellWidth-20)];
    [self addSubview:self.imageView];
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame)+5, cellWidth, 20)];
    self.nameLabel.font = [UIFont systemFontOfSize:14];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.nameLabel];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.imageView.layer.cornerRadius = (cellWidth-20)/2;
    self.imageView.layer.masksToBounds = YES;
    
}

- (void)setModel:(FilterModel *)model{
    _model = model;
    self.imageView.image = _model.image;
    self.nameLabel.text = _model.name;
    if (_model.isSelected == NO) {
        self.imageView.layer.borderWidth = 0;
    }else{
        self.imageView.layer.borderWidth = 2;
        self.imageView.layer.borderColor = [UIColor redColor].CGColor;
    }
}

@end


@interface FilterBottomView()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    FilterModel * _selectedModel;
    
}
@property(nonatomic, strong) UICollectionView * collectionView;

@property(nonatomic, strong) UICollectionViewFlowLayout * layout;

@property(nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation FilterBottomView
- (NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        _layout = [[UICollectionViewFlowLayout alloc] init]; // 自定义的布局对象
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [self addSubview:_collectionView];
        
        // 注册cell、sectionHeader、sectionFooter
        [_collectionView registerClass:[filterCollectionViewCell class] forCellWithReuseIdentifier:cellId];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionReusableView"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableView"];
        
    }
    return _collectionView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self cnfigureUI];
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)cnfigureUI{
    self.backgroundColor = RGBACOLOR(24, 24, 24, 1.0);
    self.collectionView.backgroundColor = RGBACOLOR(24, 24, 24, 1.0);
    
    
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, kScreenWidth, 30)];
    title.textColor = [UIColor whiteColor];
    title.text = @"滤镜";
    [self addSubview:title];
    title.font = [UIFont systemFontOfSize:14];
    title.textAlignment = NSTextAlignmentCenter;
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(title.frame), kScreenWidth, self.frameH - CGRectGetMaxY(title.frame));
    
}
#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    filterCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.row];
    
    return cell;
}

#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){cellWidth,cellWidth};
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FilterModel * model = self.dataSource[indexPath.row];
    
    if (_selectedModel != model) {
        
        if ([self.delegate respondsToSelector:@selector(effectImgClickFilter:)]) {
            [self.delegate effectImgClickFilter:model];
        }
        _selectedModel.isSelected = NO;
        _selectedModel = model;
        _selectedModel.isSelected = YES;
        [collectionView reloadData];
    }
}

- (void)addFilter:(FilterModel *)filterModel{
    [self.dataSource addObject:filterModel];
    [self.collectionView reloadData];
}
- (void)addFilterArray:(NSMutableArray *)filterArray{
    self.dataSource = filterArray;
    [self.collectionView reloadData];
}

@end
