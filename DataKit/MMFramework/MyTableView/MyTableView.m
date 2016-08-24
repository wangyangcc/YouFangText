//
//  MyTableView.m
//  Cc_TableView
//
//  Created by mmc on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyTableView.h"
#import <objc/runtime.h>

#define CONTENTSETHEIGHT 60.0f //下拉的高度
#define UPDRAGHEIGHT 30.0f //上拉高度

#define DELSTRING @"删除"
#define TABLELOADING @"努力加载中..."
#define TABLEUPDRAGLOADMORE @"上拉加载更多"
#define TABLERELEASEFRESH @"释放刷新"
#define CELLNAMEKEY @"cellString"
#define IDENTIFIER @"identifier"

@interface MyTableView () <UIGestureRecognizerDelegate>
{
    CGPoint beginPoint;
    UIImageView *headerBgShadowImgView;
    UILabel *txtLoadingStatusLabel; //加载更多提示语
}

@property (nonatomic, strong) UILongPressGestureRecognizer *m_longPressGesture;
@property (nonatomic, strong) NSIndexPath *m_longPressIndexPath;

@end

@implementation MyTableView

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

#pragma mark -
#pragma mark - custom method

- (NSMutableArray *)tableData
{
    if (_tableData == nil) {
        _tableData = [NSMutableArray array];
    }
    return _tableData;
}

/*
 功能: 是否下拉刷新
 by : cc
 datetime:2012-8-17
 参数:isFresh 如果是YES,则添加下来刷新，反之则反
 */
- (void) setfreshHeaderView:(BOOL) isFresh
{
    if (isFresh == YES)
    {
        //添加下拉刷新
        if (_refreshHeaderView == nil)
        {
            
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.bounds.size.height, self.frame.size.width, self.bounds.size.height)];
            view.delegate = self;
            [self addSubview:view];
            _refreshHeaderView = view;
        }
        
    }
    self.isFresh = isFresh;
    [self setBackgroundColor:[UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1]];
    
    //阴影效果
    if (self.isEdit == NO)
    {
        headerBgShadowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_shadow"]];
        [headerBgShadowImgView setFrame:CGRectMake(5, -60, 310, 4)];
        [self addSubview:headerBgShadowImgView];
    }
    
    [self setDelegate:self];
    [self setDataSource:self];
    
    _reloading = NO;
    
}

//设置加载更多页面
- (UIView *) footerView:(BOOL) loadingStatus
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    
    if (loadingStatus == YES)
    {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake(40, 15.0f, 20.0f, 20.0f);
        [footerView addSubview:activityView];
        [activityView startAnimating];
    }
    
    txtLoadingStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.frame.size.width, 20)];
    [txtLoadingStatusLabel setTextAlignment:NSTextAlignmentCenter];
    if (loadingStatus == YES)
    {
        txtLoadingStatusLabel.text = TABLELOADING;
    }
    else
    {
        txtLoadingStatusLabel.text = TABLEUPDRAGLOADMORE;
    }
    [txtLoadingStatusLabel setBackgroundColor:[UIColor clearColor]];
    [txtLoadingStatusLabel setFont:[UIFont systemFontOfSize:15]];
    [txtLoadingStatusLabel setTextColor:[UIColor lightGrayColor]];
    [footerView addSubview:txtLoadingStatusLabel];
    
    return footerView;
}

//设置加载状态
- (void) setLoadingStatus:(BOOL) isLoading
{
    self.tableFooterView = [self footerView:isLoading];
}

//是否隐藏加载更多页面
- (void) setFooterViewHidden:(BOOL) hidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        footerViewIsVisible = !hidden;
        hidden == YES?(self.tableFooterView = nil):(self.tableFooterView = [self footerView:NO]);
        if (hidden == YES) {
            self.tableFooterView = [UIView new];
        }
    });
}

//下拉动画
- (void) dragAnimation
{
    //动态下拉
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.contentInset =  UIEdgeInsetsMake(CONTENTSETHEIGHT, 0.0f, 0.0f, 0.0f);
                         self.contentOffset = CGPointMake(0.0f,-CONTENTSETHEIGHT);
                     }
                     completion:^(BOOL finish){
                         //数据请求的状态为风火轮旋转
                         [_refreshHeaderView customSetState:EGOOPullRefreshLoading];
                     }];
    
}

//反射读取对象属性
- (NSArray*)propertyKeys:(id) object
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:outCount];
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [keys addObject:propertyName];
    }
    free(properties);
    return keys;
}

- (void)setOpenLongPressGesture:(BOOL)openLongPressGesture
{
    _openLongPressGesture = openLongPressGesture;
    if (openLongPressGesture) {
        self.m_longPressGesture = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        _m_longPressGesture.minimumPressDuration = 1.0; //seconds
        _m_longPressGesture.delegate = self;
        [self addGestureRecognizer:_m_longPressGesture];
    }
    else
    {
        if (_m_longPressGesture) {
            _m_longPressGesture.delegate = nil;
            [self removeGestureRecognizer:_m_longPressGesture];
            self.m_longPressGesture = nil;
        }
    }
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
}

#pragma mark -
#pragma mark - 表代理函数
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableDelegateObject && [self.tableDelegateObject respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
    {
        return [self.tableDelegateObject tableView:tableView numberOfRowsInSection:section];
    }
    
    return [self.tableData count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableDelegateObject && [self.tableDelegateObject respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        return [self.tableDelegateObject tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    static NSString *identifier = IDENTIFIER;
    
    if (self.cellNameString == nil)
    {
        @try {
            //获取对象
            id object = [self.tableData objectAtIndex:indexPath.row];
            
            //获取对象所有key
            identifier = [object valueForKey:CELLNAMEKEY];
        }
        @catch (NSException *exception) {
            
        }
    }
    else
    {
        identifier = self.cellNameString;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[NSClassFromString(identifier) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    if ([cell respondsToSelector:@selector(setContentWithObject: AtIndexPath:)])
    {
        [cell performSelector:@selector(setContentWithObject: AtIndexPath:) withObject:self.tableData withObject:indexPath];
    }
    
    if ([cell respondsToSelector:@selector(setCellDelegate:)])
    {
        [cell performSelector:@selector(setCellDelegate:) withObject:self.cellDelegateObject];
    }
    
    
#pragma clang diagnostic pop

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0.0f;
    
    if ([self.myTable_delegate respondsToSelector:@selector(myTableRowHeightAtIndex:)])
    {
        rowHeight = [self.myTable_delegate myTableRowHeightAtIndex:indexPath];
    }
    
    return rowHeight;
}

///*
// * 预估高度 用于优化tableview 加载速度
// */
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat rowHeight = 0.0f;
//    
//    if ([self.myTable_delegate respondsToSelector:@selector(myTableRowEstimatedHeightAtIndex:)])
//    {
//        rowHeight = [self.myTable_delegate myTableRowEstimatedHeightAtIndex:indexPath];
//    }
//    
//    return rowHeight;
//}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing == NO)
    {
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    }
    
    //取消长按状态
    if ([self isOpenLongPressGesture] && self.m_longPressIndexPath ) {
        [self.tableDelegateObject tableView:self cancelLongPressAtIndexPath:self.m_longPressIndexPath];
        self.m_longPressIndexPath = nil;
    }
    
    if (self.myTable_delegate != 0 && [self.myTable_delegate respondsToSelector:@selector(myTabledidSelectRowAtIndexPath:)])
    {
        [self.myTable_delegate myTabledidSelectRowAtIndexPath:indexPath];
    }
}

//取消选择
- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing == YES)
    {
        if (self.myTable_delegate != 0 && [self.myTable_delegate respondsToSelector:@selector(myTabledidDeselectRowAtIndexPath:)])
        {
            [self.myTable_delegate myTabledidDeselectRowAtIndexPath:indexPath];
        }
    }
}

//删除
- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.myTable_delegate != nil && [self.myTable_delegate respondsToSelector:@selector(myTableDelBtnTitle)])
    {
        return [self.myTable_delegate myTableDelBtnTitle];
    }
    else
    {
        return DELSTRING;
    }
}

//删除
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (self.myTable_delegate != nil && [self.myTable_delegate respondsToSelector:@selector(myTableCommitDelForRowAtIndexPath:)])
        {
            [self.myTable_delegate myTableCommitDelForRowAtIndexPath:indexPath];
        }
    }
}

//设置此表是否是编辑的
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isEdit;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMultiSelect == YES)
    {
        return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
    }
    else
    {
        return UITableViewCellEditingStyleDelete;
    }
}

#pragma mark -
#pragma mark - <MyTableViewExpandDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.tableDelegateObject && [self.tableDelegateObject respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.tableDelegateObject tableView:tableView heightForHeaderInSection:section];
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.tableDelegateObject && [self.tableDelegateObject respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.tableDelegateObject tableView:tableView viewForHeaderInSection:section];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tableDelegateObject && [self.tableDelegateObject respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        return [self.tableDelegateObject numberOfSectionsInTableView:tableView];
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableDelegateObject && [self.tableDelegateObject respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self.tableDelegateObject tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.tableDelegateObject && [self.tableDelegateObject respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [self.tableDelegateObject tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self];
    
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:p];
    if (indexPath == nil) {
#if DEBUG
        NSLog(@"long press on table view but not on a row");
#endif
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
#if DEBUG
        NSLog(@"long press on table view at row %d", (int)indexPath.row);
#endif
        if (self.tableDelegateObject && [self.tableDelegateObject respondsToSelector:@selector(tableView:didLongPressAtIndexPath:)]) {
            self.m_longPressIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            [self.tableDelegateObject tableView:self didLongPressAtIndexPath:indexPath];
        }
    } else {
#if DEBUG
        NSLog(@"gestureRecognizer.state = %d", (int)gestureRecognizer.state);
#endif
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return NO;
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    beginPoint = scrollView.contentOffset;
}

/*
 功能: 下拉效果
 by : cc
 datetime:2012-8-17
 参数:scrollView 表的父类
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isFresh == YES)
    {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    //取消长按状态
    if ([self isOpenLongPressGesture] && self.m_longPressIndexPath) {
        if (self.tableDelegateObject && [self.tableDelegateObject respondsToSelector:@selector(tableView:cancelLongPressAtIndexPath:)])
        {
#if DEBUG
            NSLog(@"long press cancelLongPressAtIndexPath at %d", (int)self.m_longPressIndexPath.row);
#endif
            [self.tableDelegateObject tableView:self cancelLongPressAtIndexPath:self.m_longPressIndexPath];
        }
        self.m_longPressIndexPath = nil;
    }
    
    //在加载数据时候是不显示的
    if (_reloading == NO)
    {
        if (scrollView.contentSize.height + UPDRAGHEIGHT < (scrollView.contentOffset.y + self.frame.size.height))
        {
            txtLoadingStatusLabel.text = TABLERELEASEFRESH;
        }
        else
        {
            txtLoadingStatusLabel.text = TABLEUPDRAGLOADMORE;
        }
    }
    
    UIImageView *tmpImgView = headerBgShadowImgView;
    tmpImgView.frame = CGRectMake(5, scrollView.contentOffset.y, 310, 4);
    [self bringSubviewToFront:tmpImgView];
    //阴影显示
    if (scrollView.contentOffset.y == 0)
    {
        tmpImgView.hidden = YES;
    }
    else
    {
        tmpImgView.hidden = NO;
    }
    
    if (self.myTable_delegate != 0 && [self.myTable_delegate respondsToSelector:@selector(scrolling)])
    {
        [self.myTable_delegate scrolling];
    }
    
    if (scrollView.contentOffset.y <=  scrollView.contentSize.height - scrollView.frame.size.height)
    {
        if (scrollView.contentOffset.y - beginPoint.y >= 16)
        {
            if (self.myTable_delegate != nil && [self.myTable_delegate respondsToSelector:@selector(scrollUp)])
            {
                [self.myTable_delegate scrollUp];
            }
        }
        
        if (scrollView.contentOffset.y - beginPoint.y <= -10)
        {
            if (self.myTable_delegate != nil && [self.myTable_delegate respondsToSelector:@selector(scrollDown)])
            {
                [self.myTable_delegate scrollDown];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.isFresh == YES)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    if (footerViewIsVisible == YES)
    {
        //上拉加载更多
        if (scrollView.contentSize.height + UPDRAGHEIGHT < (scrollView.contentOffset.y + self.frame.size.height))
        {
            if (_reloading != YES)
            {
                if ([self.myTable_delegate respondsToSelector:@selector(myTableLoadMore)])
                {
                    [self setLoadingStatus:YES];
                    
                    //开始加载数据
                    _reloading = YES;
                    [self.myTable_delegate myTableLoadMore];
                }
            }
        }
    }
    
    if (self.tableDelegateObject && [self.tableDelegateObject respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.tableDelegateObject scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.tableDelegateObject && [self.tableDelegateObject respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.tableDelegateObject scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark -
#pragma mark - custome delegate
/*
 功能: 下拉刷新 重新加载数据
 by : cc
 datetime:2012-8-17
 */
- (void)reloadTableViewDataSource
{
    //加载数据
    _reloading = YES;
    
    //再一次调用数据
    if ([self.myTable_delegate respondsToSelector:@selector(myTableViewLoadDataAgain)])
    {
        [self.myTable_delegate myTableViewLoadDataAgain];
    }
}

/*
 功能: 数据请求过程中
 */
- (void)loadingTableViewData
{
    [self reloadData];
}

/*
 功能: 数据请求完之后
 by : cc
 datetime:2012-8-17
 */
- (void)doneLoadingTableViewData
{
	//  model should call this when its done loading
	_reloading = NO;
    if (self.isFresh == YES)
    {
        [self performSelector:@selector(finishLoading) withObject:nil afterDelay:0.6];
    }
    
    if (footerViewIsVisible == YES)
    {
        [self setLoadingStatus:NO];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

- (void) finishLoading
{
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

@end
