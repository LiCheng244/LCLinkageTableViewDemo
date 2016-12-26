//
//  ViewController.m
//  两级联动的 tableView 列表
//
//  Created by LiCheng on 2016/12/23.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "ViewController.h"


#define LCScreenHeight [UIScreen mainScreen].bounds.size.height
#define LCBScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

/** 左边的tableView */
@property (nonatomic, strong) UITableView *leftView;
/** 右边的 tableView */
@property (nonatomic, strong) UITableView *rightView;

/** 分区头数据 */
@property (nonatomic, strong)  NSMutableArray *headrDates;

/** 用来保存当前 左边 tableView 选中的行 */
@property (nonatomic, strong) NSIndexPath *currentSelectIndexPath;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化 tableView
    [self setupTableViews];
}


#pragma mark - <初始化操作>
/**
 *  初始化分区数据
 */
-(NSArray *)headrDates{
    if (!_headrDates) {
        _headrDates = [NSMutableArray array];
        for (NSInteger i = 0; i< 20; i++) {
            [_headrDates addObject:[NSString stringWithFormat:@"第%zd分区", i+1]];
        }
    }
    return _headrDates;
}

/**
 *  初始化 tableView
 */
-(void)setupTableViews{
    
    // 左侧 tableView
    self.leftView = [[UITableView alloc] initWithFrame:(CGRectMake(0, 0, LCBScreenWidth * 0.3f, LCScreenHeight-64))];
    self.leftView.delegate = self;
    self.leftView.dataSource = self;
    self.leftView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.leftView];
    
    // 右侧 tableView
    self.rightView = [[UITableView alloc] initWithFrame:CGRectMake(self.leftView.frame.size.width + self.leftView.frame.origin.x, 64, LCBScreenWidth- self.leftView.frame.size.width, LCScreenHeight-64) style:(UITableViewStyleGrouped)];
    self.rightView.delegate = self;
    self.rightView.dataSource = self;
    [self.view addSubview:self.rightView];

    // 设置默认选中的行
    [self.leftView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self.rightView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:(UITableViewScrollPositionTop)];
    /**
     *      [NSIndexPath indexPathForRow:0 inSection:0]
     *
     *  类方法， 作用是通过一个 row 和 section 初始化一个 NSIndexPath 对象， 用来代表某个分区的某一行
     
     
     *      [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop]
     *  
     *  类方法， 作用是设置 tableView 的选中行 
     *  scrollPosition: 设置 tableView 的滚动位置， top:顶部 bottom:底部  等等
     */
}


#pragma mark - <UITableViewDataSource>
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.leftView) {
        return 1;
    }else{
        return self.headrDates.count;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.leftView) {
        return self.headrDates.count;
    }else{
        return 10;
    }
}
/**
 *  设置 tableview 的分区头
 */
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.leftView) {
        return nil;
    }else{
        return self.headrDates[section];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"CELL";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellId];
    }
    
    if (tableView == self.leftView) {
        cell.textLabel.text = self.headrDates[indexPath.row];
        cell.backgroundColor = [UIColor brownColor];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"第%zd行", indexPath.row+1];
        cell.backgroundColor = [UIColor grayColor];
    }
    return cell;
}



#pragma mark - <UITableViewDelegate>
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.rightView) { // 右边 tableView
        NSLog(@"点击了右侧 tableView 的第%ld行", indexPath.row+1);
        
    }else{ // 左边 tableView
        
        // 改变右侧 tableView 选中的分区和行号
        [self.rightView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] animated:YES scrollPosition:(UITableViewScrollPositionTop)];
        // 保存当前点击的行
        self.currentSelectIndexPath = indexPath;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (tableView == self.rightView) {
        return 30;
    }
    return 0;
}


#pragma mark - <UIScrollViewDelegate>
/**
 *  监听 tableView 的滚动
 */
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.currentSelectIndexPath) {
        return;
    }
    
    if (scrollView == self.leftView) { // 左边 tableView 不做处理
        
        
    }else{ // 右边 tableView
        
        // 获取当前屏幕上显示的所有 cell 中的第一个 cell 的 section
        NSInteger currentFirstSection = self.rightView.indexPathsForVisibleRows.firstObject.section;
        // 设置左边 tableView 的选中行
        [self.leftView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentFirstSection inSection:0] animated:NO scrollPosition:(UITableViewScrollPositionMiddle)];
        
        /**
         *      indexPathsForVisibleRows 属性
         *  作用是: 返回屏幕上可见 cell 的 indexPath 数组， 利用这个属性可以找到某个 cell所在的分区, cell 的行号等等
         
         *      animated:NO
         *  将动画设置为 NO， 滚动右边 tableView 时，左边的 view 不会有阴影的滚动效果
         *
         */
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (self.currentSelectIndexPath) {
        self.currentSelectIndexPath = nil;
    }
}

@end
