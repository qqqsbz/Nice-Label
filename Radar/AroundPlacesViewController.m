//
//  AroundPlacesViewController.m
//  GaoDeMap
//
//  Created by coder on 15/8/27.
//  Copyright (c) 2015年 coder. All rights reserved.
//

#import "AroundPlacesViewController.h"
#import "MapAroundPlaceApi.h"
#import "UIColor+Util.h"
#import <AMapSearchKit/AMapSearchAPI.h>
@interface AroundPlacesViewController ()<AMapSearchDelegate,MapAroundPlaceApiDelegate,UISearchBarDelegate,CLLocationManagerDelegate>
{
    BOOL                    loadingMore;
    BOOL                    showCityName;
    NSInteger               prestrainCount;
    NSString                *keyWords;
    NSInteger               pageIndex;
    NSInteger               pageCount;
    NSMutableArray          *datas;
    NSMutableArray          *indexPaths;
    UIView                  *footerView;
    UILabel                 *descLabel;
    UIButton                *canleBtn;
    UISearchBar             *placeSearchBar;
    UIBarButtonItem         *rightBtn;
    CLLocationManager       *locationManager;
    MapAroundPlaceApi       *placeApi;
    UIActivityIndicatorView *indicatorView;
}
@end

static NSString * reuseIdentifier = @"cell";
static NSString * reuseIdentifierTop = @"topCell";
static const CGFloat threshold = -70;

@implementation AroundPlacesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    prestrainCount = 2;
    
    [self initialization];
    
    [self openLocation];
    
}

- (void)initialization
{
    datas       = [NSMutableArray array];
    indexPaths  = [NSMutableArray array];
    pageCount   = 20;
    pageIndex   = 0;
    
    [self buildUnKnowLocation];
    [self buildHeaderView];
    [self buildFooterView];
    footerView.hidden = NO;

}

- (void)openLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter  = 1.f;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate        = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
}

#pragma mark -- CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation) {
        [locationManager stopUpdatingLocation];
        placeApi = [MapAroundPlaceApi shareMapAroundPlaceApi];
        placeApi.delegate   = self;
        placeApi.coordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        [placeApi mapPlaceSearchWithPage:pageIndex offset:pageCount  keyWords:keyWords];
    }
}


//构建"不显示位置"的cell值
- (void)buildUnKnowLocation
{
    if (self.indexPath) {
        [indexPaths addObject:self.indexPath];
    } else {
        [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    AMapPOI *mapPoi = [[AMapPOI alloc] init];
    mapPoi.name     = @"不显示位置";
    [datas addObject:mapPoi];
}

#pragma mark -- MapAroundPlaceApiDelegate
//搜索所在的城市
- (void)mapReGeocodeCityName:(NSString *)cityName
{
    
    if (showCityName) {
        return;
    }
    
    AMapPOI *mapPoi = [[AMapPOI alloc] init];
    mapPoi.name     = cityName;
    [datas addObject:mapPoi];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    showCityName = !showCityName;
}

//搜索附近的位置失败
- (void)mapAroundPlaceApiFailWithError:(NSError *)error
{
    NSLog(@"搜索附近的位置失败  %@",error);
    [self UIPrepareLoadFail:error.localizedDescription];
}
//搜索附近的位置成功并返回数据
- (void)mapAroundPlaceApiSuccessWithPlaces:(NSArray *)places
{
    if (places.count > 0) {
        if (keyWords) {
            [indexPaths removeAllObjects];
            [datas removeAllObjects];
            [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        } else {
            [datas addObjectsFromArray:places];
        }
        [datas addObjectsFromArray:places];
        [self.tableView reloadData];
        [self UIPrepareLoadSuccess];
        self.tableView.tableFooterView = [[UIView alloc] init];
        return;
    }
    
    [indicatorView stopAnimating];
    descLabel.text = NSLocalizedString(@"NoMoreAroundPlaces", @"NoMoreAroundPlaces");
    loadingMore = YES;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.row < prestrainCount) {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierTop];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    }
    
    if (indexPath.row < prestrainCount && !cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifierTop];
    } else  {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    AMapPOI *poi = datas[indexPath.row];
    if (indexPath.row < prestrainCount ) {
        cell.textLabel.text = poi.name;
    } else {
        cell.textLabel.text = poi.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%@%@",poi.province,poi.city,poi.district,poi.address];
    }
    
    if ([indexPaths containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMapPOI *mapPoi = datas[indexPath.row];
    NSString *name  = mapPoi.name;//(mapPoi.name && mapPoi.city) ? [NSString stringWithFormat:@"%@~%@",mapPoi.city,mapPoi.name] : mapPoi.name;
    AMapGeoPoint *location  = mapPoi.location ? mapPoi.location : [AMapGeoPoint locationWithLatitude:0 longitude:0];
    
    NSDictionary *userInfo = @{@"name":name,
                               @"location":location,
                               @"indexPath":indexPath
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kAROUNDPLACE"
                                          object:nil
                                          userInfo:userInfo];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//上拉更新
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height <= self.view.bounds.size.height) {
        return;
    }
    if (!loadingMore) {
        CGFloat distanceToBottom = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.frame.size.height) + self.tabBarController.tabBar.frame.size.height;
        if (distanceToBottom < threshold) {
            [self UIPrepareLoading];
            [indicatorView startAnimating];
            self.tableView.tableFooterView = footerView;
            loadingMore = YES;
            pageIndex ++;
            [self reloadData];
        }
    }
}

//构建搜索附近位置的按钮
- (void)buildHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44.f)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"#EBEBF1"];
    self.tableView.tableHeaderView = headerView;
    
    UIButton *btn   = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame       = CGRectMake(10, 7, headerView.frame.size.width - 20 , CGRectGetHeight(headerView.frame) - 14);
    
    btn.center                      = headerView.center;
    btn.titleEdgeInsets             = UIEdgeInsetsMake(0, 15, 3, 0);
    btn.backgroundColor             = [UIColor whiteColor];
    btn.layer.masksToBounds         = YES;
    btn.layer.cornerRadius          = 5.f;
    btn.titleLabel.textAlignment    = NSTextAlignmentCenter;
    
    [btn setImage:[UIImage imageNamed:@"search-icon"] forState:UIControlStateNormal];
    [btn setTitle:NSLocalizedString(@"AroundPlaces", @"AroundPlaces") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
    [btn addTarget:self action:@selector(showSearchBar) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btn];
    
}

//构建加载更多
- (void)buildFooterView
{
    footerView = [[UIView alloc] initWithFrame:self.tableView.tableHeaderView.bounds];
    self.tableView.tableFooterView = footerView;
    
    CGFloat width   = 30;
    CGFloat height  = 30;
    indicatorView   = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    indicatorView.center = CGPointMake(CGRectGetWidth(footerView.frame) / 3, CGRectGetHeight(footerView.frame) / 2);
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [indicatorView startAnimating];
    [footerView addSubview:indicatorView];
    
    descLabel = [[UILabel alloc] initWithFrame:CGRectMake(indicatorView.center.x + 15, indicatorView.frame.origin.y, (CGRectGetWidth(footerView.frame ) * 2 ) / 3, height)];
    descLabel.text          = NSLocalizedString(@"AroundPlacesLoading", @"AroundPlacesLoading");
    descLabel.textAlignment = NSTextAlignmentLeft;
    descLabel.font          = [UIFont systemFontOfSize:14.f];
    [footerView addSubview:descLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadData)];
    [footerView addGestureRecognizer:tapGesture];
}

//重新加载数据
- (void)reloadData
{
    if (!indicatorView.isAnimating) {
        [self UIPrepareLoading];
    }
    [placeApi mapPlaceSearchWithPage:pageIndex offset:pageCount  keyWords:keyWords];
}

//显示搜索bar
- (void)showSearchBar
{
    if (!placeSearchBar) {
        placeSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
        placeSearchBar.delegate         = self;
        placeSearchBar.placeholder      = NSLocalizedString(@"AroundPlaces", @"AroundPlaces");
        self.navigationItem.titleView   = placeSearchBar;
        
        rightBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancle", @"Cancle") style:UIBarButtonItemStyleDone target:self action:@selector(cancleSearch)];
        
        canleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        canleBtn.frame = self.view.frame;
        canleBtn.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.65f];
        [canleBtn addTarget:self action:@selector(cancleSearch) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:canleBtn];
    }
    
    canleBtn.hidden         = NO;
    placeSearchBar.hidden   = NO;
    self.navigationItem.hidesBackButton     = YES;
    self.navigationItem.rightBarButtonItem  = rightBtn;
    [placeSearchBar becomeFirstResponder];
    
}
//取消搜索 重设相关属性
- (void)cancleSearch
{
    canleBtn.hidden         = YES;
    placeSearchBar.hidden   = YES;
    self.navigationItem.hidesBackButton     = NO;
    self.navigationItem.rightBarButtonItem  = nil;
    [placeSearchBar resignFirstResponder];
}

#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    pageIndex = 0;
    keyWords  = searchBar.text;
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)UIPrepareLoading
{
    descLabel.hidden = NO;
    descLabel.text   = NSLocalizedString(@"AroundPlacesLoading", @"AroundPlacesLoading");
    [indicatorView startAnimating];
    self.tableView.tableFooterView = footerView;
}

//加载成功显示的ui
- (void)UIPrepareLoadSuccess
{
    loadingMore = NO;
}
//加载失败显示的ui
- (void)UIPrepareLoadFail:(NSString *)errorMsg
{
    [indicatorView stopAnimating];
    descLabel.text = errorMsg ? [NSString stringWithFormat:NSLocalizedString(@"AroundPlacesErrorReLoad", @"AroundPlacesErrorReLoad"),errorMsg] : NSLocalizedString(@"AroundPlacesError", @"AroundPlacesError");
}
@end
