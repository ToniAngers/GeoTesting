//
//  Geotification.h
//  GeoTest2
//
//  Created by Anton Voropaev on 28.05.16.
//  Copyright © 2016 Anton Voropaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface Geotification : NSObject
@property (assign, nonatomic)CLLocationCoordinate2D coordinate;
@property (assign, nonatomic)CLLocationDistance radius;
@property (strong, nonatomic) NSString *identifier;
@property (assign, nonatomic) CLLocationDistance distanceFromUserLocation;


- (instancetype)initWithCoordinates:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius andID:(NSString*)identifier;

@end
