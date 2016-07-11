//
//  Geotification.m
//  GeoTest2
//
//  Created by Anton Voropaev on 28.05.16.
//  Copyright © 2016 Anton Voropaev. All rights reserved.
//

#import "Geotification.h"

@implementation Geotification

- (instancetype)initWithCoordinates:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius andID:(NSString*)identifier
{
    self = [super init];
    if (self) {
       
        self.coordinate = coordinate;
        self.radius = radius;
        self.identifier = identifier;
        
    }
    return self;
}


- (void)setDistanceFromUserLocation:(CLLocationDistance)distanceFromUserLocation {
    _distanceFromUserLocation = distanceFromUserLocation;
}

@end
