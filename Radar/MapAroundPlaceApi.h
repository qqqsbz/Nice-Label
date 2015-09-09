//
//  MapAroundPlaceApi.h
//  GaoDeMap
//
//  Created by coder on 15/8/27.
//  Copyright (c) 2015年 coder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <CoreLocation/CoreLocation.h>
@protocol MapAroundPlaceApiDelegate <NSObject>

- (void)mapAroundPlaceApiFailWithError:(NSError *)error;

- (void)mapAroundPlaceApiSuccessWithPlaces:(NSArray *)places;

- (void)mapReGeocodeCityName:(NSString *)cityName;

@end

@interface MapAroundPlaceApi : NSObject

@property (strong, nonatomic)   NSString                      *searchKey;
@property (assign, nonatomic)   id<MapAroundPlaceApiDelegate> delegate;
@property (assign, nonatomic)   CLLocationCoordinate2D        coordinate;
@property (strong, nonatomic)   NSString                      *convertKey;
@property (assign, nonatomic)   BOOL                          convertCoordinate;

+ (instancetype)shareMapAroundPlaceApi;

- (void)mapPlaceSearchWithPage:(NSInteger)page offset:(NSInteger)offset keyWords:(NSString *)keyWords;


@end

