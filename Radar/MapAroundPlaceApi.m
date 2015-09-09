//
//  MapAroundPlaceApi.m
//  GaoDeMap
//
//  Created by coder on 15/8/27.
//  Copyright (c) 2015年 coder. All rights reserved.
//

#import "MapAroundPlaceApi.h"

@interface MapAroundPlaceApi()<AMapSearchDelegate>

@property (strong, nonatomic) AMapSearchAPI             *searchApi;
@property (assign, nonatomic) CLLocationCoordinate2D    lastCoordinate;
@property (strong, nonatomic) NSString                  *cityName;

@end
@implementation MapAroundPlaceApi

//初始化
+ (instancetype)shareMapAroundPlaceApi
{
    static MapAroundPlaceApi *mapAroundPlaceApi;
    static dispatch_once_t noceToken;
    dispatch_once(&noceToken, ^{
        mapAroundPlaceApi = [[MapAroundPlaceApi alloc] init];
        mapAroundPlaceApi.convertCoordinate = YES;
    });
    return mapAroundPlaceApi;
}

//设置searchKey
- (void)setSearchKey:(NSString *)searchKey
{
    if (_searchKey != searchKey) {
        _searchKey = searchKey;
        self.searchApi = [[AMapSearchAPI alloc] initWithSearchKey:_searchKey Delegate:self];
    }
}

//查询参数构造并进行查询
- (void)mapPlaceSearchWithPage:(NSInteger)page offset:(NSInteger)offset keyWords:(NSString *)keyWords
{
    if (!_searchApi) {
        NSLog(@"searchKey is null");
    }
    
    //如果已经转过坐标 则不再转 减少开销
    if (self.convertCoordinate && self.lastCoordinate.latitude == 0) {
        [self transformCoordinate];
        self.lastCoordinate = CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude);
    } else {
        if (self.lastCoordinate.latitude == 0) {
            self.coordinate = CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude);
        } else {
            self.coordinate = CLLocationCoordinate2DMake(self.lastCoordinate.latitude, self.lastCoordinate.longitude);
        }
    }
    
    //构造AMapPlaceSearchRequest对象，配置关键字搜索参数
    AMapPlaceSearchRequest *poiRequest = [[AMapPlaceSearchRequest alloc] init];
    poiRequest.searchType = AMapSearchType_PlaceAround;
    poiRequest.location = [AMapGeoPoint locationWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    poiRequest.types = @[@"汽车服务",@"汽车销售",@"汽车维修",@"摩托车服务",@"餐饮服务",@"购物服务",@"生活服务",@"体育休闲服务",@"医疗保健服务",@"住宿服务",@"风景名胜",@"商务住宅",@"政府机构及社会团体",@"科教文化服务",@"交通设施服务",@"金融保险服务",@"公司企业",@"道路附属设施",@"地名地址信息",@"公共设施"];
    
    //关键字查询
    if (keyWords) {
        poiRequest.keywords = keyWords;
    }
    poiRequest.radius = 100;
    poiRequest.page = page;
    poiRequest.offset = offset;
    poiRequest.requireExtension = YES;
    
    //发起POI搜索
    [_searchApi AMapPlaceSearch: poiRequest];
}

#pragma mark -- AMapSearchDelegate

//查询失败回调函数
- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    [self invokFailWithError:error];
}

//实现POI搜索对应的回调函数
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    if(response.pois.count == 0)
    {
        NSLog(@"返回没有任何结果。。。。。。");
    } else {
        AMapPOI *mapPoi = [response.pois firstObject];
        self.cityName = mapPoi.city;
        [self invokeReGeocodeCityName];
    }
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self invokSuccessWithPlaces:response.pois];
    });
}

//将定位到的火星坐标转换成实际坐标
- (void)transformCoordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://restapi.amap.com/v3/assistant/coordinate/convert?locations=%f,%f&coordsys=gps&output=json&key=%@",self.coordinate.longitude,self.coordinate.latitude,self.convertKey];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:10.0];
    
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if (error) {
        [self invokFailWithError:error];
        return;
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error:&error];
    
    if (!error) {
        if ([dic[@"status"] boolValue] && [dic[@"info"] isEqualToString:@"ok"]) {
            
            NSArray *titudes = [dic[@"locations"] componentsSeparatedByString:@","];
            self.coordinate = CLLocationCoordinate2DMake([titudes[1] floatValue], [titudes[0] floatValue]);
        }
    } else {
        [self invokFailWithError:error];
    }
}

- (void)invokSuccessWithPlaces:(NSArray *)pois
{
    if ([self.delegate respondsToSelector:@selector(mapAroundPlaceApiSuccessWithPlaces:)]) {
        [self.delegate mapAroundPlaceApiSuccessWithPlaces:pois];
    }
}

- (void)invokFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(mapAroundPlaceApiFailWithError:)]) {
        [self.delegate mapAroundPlaceApiFailWithError:error];
    }
}

- (void)invokeReGeocodeCityName
{
    if ([self.delegate respondsToSelector:@selector(mapReGeocodeCityName:)]) {
        [self.delegate mapReGeocodeCityName:self.cityName];
    }
}

@end
