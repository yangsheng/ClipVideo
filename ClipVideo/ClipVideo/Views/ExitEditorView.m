//
//  ExitEditorView.m
//  ClipVideo
//
//  Created by leeco on 2018/10/25.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "ExitEditorView.h"

@interface ExitEditorView()

@property(nonatomic, strong) UIView * bgView;

@property(nonatomic, strong) UIView * whiteView;


@property(nonatomic, strong) UIButton * confirmBtn;

@property(nonatomic, strong) UIButton * cancelBtn;

@end


@implementation ExitEditorView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configureUI];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureUI];
    }
    return self;
}
- (void)configureUI{

    self.backgroundColor = [UIColor clearColor];
    
    self.bgView = [[UIView alloc]initWithFrame:self.bounds];
    self.bgView.backgroundColor = [UIColor blackColor];
    self.bgView.alpha = 0.3;
    self.bgView.hidden = YES;
    [self addSubview:self.bgView];
    
    
    self.whiteView = [UIView new];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.whiteView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disappera)];
    tap.numberOfTapsRequired = 1;
    [self.bgView addGestureRecognizer:tap];

    UILabel * titleLabel = [UILabel new];
    titleLabel.text = @"是否退出编辑?";
    [self.whiteView addSubview:titleLabel];
    
    
    self.confirmBtn = [[UIButton alloc]init];
    [self.confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.confirmBtn.layer.borderWidth = 1;
    self.confirmBtn.layer.borderColor = [UIColor greenColor].CGColor;
    [self.whiteView addSubview:self.confirmBtn];
    self.confirmBtn.layer.masksToBounds = YES;
    self.confirmBtn.layer.cornerRadius = 20;
    WeakObj(self)
    [self.confirmBtn bk_addEventHandler:^(id sender) {
        
        if ([selfWeak.delegate respondsToSelector:@selector(exitEditorViewConfirm)]) {
            [selfWeak.delegate exitEditorViewConfirm];
        }
        [selfWeak disappera];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelBtn = [UIButton new];
    [self.cancelBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelBtn.layer.borderWidth = 1;
    self.cancelBtn.layer.borderColor = [UIColor greenColor].CGColor;
    [self.whiteView addSubview:self.cancelBtn];
    self.cancelBtn.layer.masksToBounds = YES;
    self.cancelBtn.layer.cornerRadius = 20;
    
    [self.cancelBtn bk_addEventHandler:^(id sender) {
        
        if ([selfWeak.delegate respondsToSelector:@selector(exitEditorViewCancel)]) {
            [selfWeak.delegate exitEditorViewCancel];
        }
        
        [selfWeak disappera];
        
    } forControlEvents:UIControlEventTouchUpInside];

    
    self.whiteView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 200);
    
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.whiteView).mas_offset(20);
        
    }];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(20);
        make.left.mas_equalTo(self.whiteView).mas_offset(20);
        make.right.mas_equalTo(self.whiteView).mas_offset(-20);
        make.height.mas_equalTo(40);
    }];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.confirmBtn.mas_bottom).mas_offset(20);
        make.left.mas_equalTo(self.whiteView).mas_offset(20);
        make.right.mas_equalTo(self.whiteView).mas_offset(-20);
        make.height.mas_equalTo(40);
    }];

}
- (void)disPlay{
    
    self.frameY = 0;

    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.hidden = NO;
        self.whiteView.frameY = kScreenHeight - self.whiteView.frameH;
    } completion:^(BOOL finished) {

    }];
    
}
- (void)disappera{

    [UIView animateWithDuration:0.3 animations:^{
       
        self.bgView.hidden = YES;
        
        
        self.whiteView.frameY = kScreenHeight;
        
    } completion:^(BOOL finished) {
        
        
        self.frameY = kScreenHeight;
        
    }];
}
@end
