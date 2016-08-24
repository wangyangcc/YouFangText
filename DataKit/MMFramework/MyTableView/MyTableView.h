//
//  MyTableView.h
//  Cc_TableView
//
//  Created by mmc on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

//下拉重新加载调用的数据协议
@protocol MyTableViewDelegate <NSObject>

@optional

/**
 *  是否是加载更多
 */
@property (nonatomic, assign) BOOL isLoadMore;

//加载数据
- (void) myTableViewLoadDataAgain;
//加载行高
- (CGFloat) myTableRowHeightAtIndex:(NSIndexPath *)indexPath;
//预估的行高 iOS7以后
- (CGFloat) myTableRowEstimatedHeightAtIndex:(NSIndexPath *)indexPath;
//点击代理事件
- (void) myTabledidSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//取消选择
- (void) myTabledidDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
//加载更多
- (void) myTableLoadMore;
//上滚动
- (void) scrollUp;
//下滚动
- (void) scrollDown;
//滚动中
- (void) scrolling;
//编辑删除
- (NSString *) myTableDelBtnTitle;
//提交删除
- (void) myTableCommitDelForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol MyTableViewExpandDelegate <NSObject>

@optional
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (void)tableView:(UITableView *)tableView didLongPressAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView cancelLongPressAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end

@interface MyTableView : UITableView<EGORefreshTableHeaderDelegate,UITableViewDelegate,UITableViewDataSource>
{
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    
    //控制加载更多是否显示
    BOOL footerViewIsVisible;
}

//是否显示下拉刷新
@property (nonatomic) BOOL isFresh;
//将单击事件传出来
@property (weak) id<MyTableViewDelegate> myTable_delegate;
//数据源
@property (nonatomic, retain) NSMutableArray *tableData;
//记录表的cell
@property (nonatomic, retain) NSString *cellNameString;
//用于传递代理方法
@property (nonatomic,weak) id cellDelegateObject;
@property (nonatomic,weak) id<MyTableViewExpandDelegate> tableDelegateObject;//用于传递额外的除了MyTableViewDelegate里面的tTableViewDelegate方法

//编辑
@property (nonatomic) BOOL isEdit;
//编辑类型
@property (nonatomic) BOOL isMultiSelect;

//长按手势
@property (nonatomic, getter=isOpenLongPressGesture) BOOL openLongPressGesture;

/**
 *  数据加载过程中刷新表格
 */
- (void) loadingTableViewData;
//数据加载完成
- (void) doneLoadingTableViewData;
//是否有下拉刷新
- (void) setfreshHeaderView:(BOOL) isFresh;
//下拉动画
- (void) dragAnimation;
//重新加载数据
- (void) reloadTableViewDataSource;
//设置加载更多的状态
- (void) setLoadingStatus:(BOOL) isLoading;
//设置加载更多是否显示
- (void) setFooterViewHidden:(BOOL) hidden;

@end

