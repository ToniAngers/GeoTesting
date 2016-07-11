//
//  ViewController.m
//  GeoTest2
//
//  Created by Anton Voropaev on 28.05.16.
//  Copyright © 2016 Anton Voropaev. All rights reserved.
//

#import "ViewController.h"
#import "AVRegionsTableViewController.h"
#import "Geotification.h"


#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>



@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLCircularRegion *region;
@property (strong, nonatomic) MKCircle *mCircle;

@property (strong, nonatomic) NSArray *geoObjects;
@property (weak, nonatomic) UILabel *lable;
@property (assign, nonatomic) NSInteger regionCount;

@property (strong, nonatomic) NSMutableArray *allAddedRegions;
@property (strong, nonatomic) NSArray *sortedRegions;
@property (strong, nonatomic) NSMutableArray *monitoredTwentyRegions;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.allAddedRegions = [NSMutableArray array];
    self.monitoredTwentyRegions = [NSMutableArray array];
    self.regionCount = 1;
    
    /////locationManagerInit
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 10;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    
    for (CLCircularRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region]; // clear manager.monitoredRegions
    }
    
    NSLog(@"Location manager = %@", self.locationManager.monitoredRegions);
    
    
    /////methods calling
    [self makinMapView];
    [self barButtonItems];
    [self gestureRecognizers];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self makeAddress];
    });
    
    
    //////move to another method
   /*
     CLLocationDegrees metroLatitude = 50.004528;
     CLLocationDegrees metroLongitude = 36.233995;
     CLLocationCoordinate2D kMetroCoordinates = { metroLatitude, metroLongitude };
    
     CLLocationDegrees officeLatitude = 50.006501;
     CLLocationDegrees officeLongitude = 36.237039;
     CLLocationCoordinate2D kOfficeCoordinates = { officeLatitude, officeLongitude };
    
    
    Geotification *metroGeo = [[Geotification alloc] initWithCoordinates:kMetroCoordinates withRadius:100 andID:@"metro"];
    Geotification *officeGeo = [[Geotification alloc] initWithCoordinates:kOfficeCoordinates withRadius:50 andID:@"office"];
    ////
    ///////
    /////////
    /////////////....and other geoObjects coordinates
    
    MKCircle *circleMetro =[ MKCircle circleWithCenterCoordinate:kMetroCoordinates radius:100];
    MKCircle *circleOffice = [MKCircle circleWithCenterCoordinate:kOfficeCoordinates radius:50];
    
    [self.mapView addOverlay:circleMetro];
    [self.mapView addOverlay:circleOffice];


    
    self.geoObjects = @[metroGeo, officeGeo];
    
    for (Geotification *geoObject in self.geoObjects) {
        [self startMonitoringGeotification:geoObject]; /// making monitored region for each obj, and give it to locationManager, and now all regions we'r have in self.locationManager.monitoredRegions (NSArray)
     }
    
    */
    
}

#pragma mark - UI

- (void)makinMapView{
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)- 170)];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    [self.view addSubview:mapView];
    self.mapView = mapView;

    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(self.view.bounds)- 150, 250, 60)];
    lable.text = @"Notification";
    lable.font = [UIFont systemFontOfSize:18];
    lable.textColor = [UIColor redColor];
    [self.view addSubview:lable];
    self.lable = lable;
}

- (void)barButtonItems {
    /////first
    MKUserTrackingBarButtonItem *trackItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.leftBarButtonItem = trackItem;
    
    
    UIBarButtonItem *goToRegionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openListOfRegions:)];
    self.navigationItem.rightBarButtonItem = goToRegionItem;
}

#pragma mark - Actions

- (void)openListOfRegions:(UIBarButtonItem*) sender {
    
    NSArray *tempArray = self.locationManager.monitoredRegions.allObjects;
    
    AVRegionsTableViewController *regionsController = [[AVRegionsTableViewController alloc]initWithRegions:tempArray];
    [self.navigationController pushViewController:regionsController animated:YES];
}


#pragma mark - Gestures

- (void)gestureRecognizers {
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleGesture:)];
    lpgr.minimumPressDuration = 1.0;  //user must press for 1 seconds
    [self.mapView addGestureRecognizer:lpgr];
}

- (void)handleGesture:(UITapGestureRecognizer*) sender {
    
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint touchPoint = [sender locationInView:self.mapView];
    CLLocationCoordinate2D coordinateInMap = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    Geotification *geotification = [[Geotification alloc] initWithCoordinates:coordinateInMap withRadius:100 andID:[NSString stringWithFormat:@"Region - %zd", self.regionCount]];
    
    
    MKCircle *myCircle = [MKCircle circleWithCenterCoordinate:coordinateInMap radius:100];
    [myCircle setTitle:[NSString stringWithFormat:@"Circle for region %zd", self.regionCount]];
    [self.mapView addOverlay:myCircle];
    self.mCircle = myCircle;
    
    
    
    [self startMonitoringGeotification:geotification];
    
    [self.allAddedRegions addObject:geotification];
    
    self.regionCount ++;
    
}



#pragma mark - makingRegion

//////////////
- (CLCircularRegion*)makingRegionFromGeo:(Geotification*)geotification {
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:geotification.coordinate radius:geotification.radius identifier:geotification.identifier];
    
    region.notifyOnEntry = YES; ///////!!!!!!!!!!!!!!! change to YES;
    region.notifyOnExit = YES;
   
    
//    self.region = region;
    
    
    return region;
}

- (void)startMonitoringGeotification:(Geotification*)geotification {
    
    CLCircularRegion *region = [self makingRegionFromGeo:geotification];
    [self.locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringregion:(Geotification*)geotification {
    for (CLCircularRegion *region in self.locationManager.monitoredRegions) {
        if (region.identifier == geotification.identifier) {
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
}

//////////////

#pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    
    NSLog(@"didStartMonitoringForRegion name = %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
  
    NSLog(@"USER ENTER REGION %@", region.identifier);
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"Welcome to %@", region.identifier];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    
//    if ([region.identifier isEqualToString:@"metro"]) {
//        
//        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//        localNotification.alertBody = @"Welcome to METRO";
//        localNotification.soundName = UILocalNotificationDefaultSoundName;
//        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//
//    }else if ([region.identifier isEqualToString:@"office"]) {
//        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//        localNotification.alertBody = @"Welcome to OFFICE";
//        localNotification.soundName = UILocalNotificationDefaultSoundName;
//        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//
//    }
    
    self.lable.text = [NSString stringWithFormat:@"User entered region {%@}", region.identifier];
    NSLog(@"User entered region  = %@", region.identifier);
    
    [self updatingLocation];
    

}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    self.lable.text = [NSString stringWithFormat:@"User exit region {%@}", region.identifier];
    

}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
   
    [self updatingLocation];
    
}





- (void)updatingLocation {
    
    [self.monitoredTwentyRegions removeAllObjects];
    NSLog(@"manager didUpdateLocations");
    
    for (CLCircularRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region]; // clear manager.monitoredRegions
    }
    
    NSLog(@"ADDEd regions = %zd", self.allAddedRegions.count);
    if (self.allAddedRegions.count > 0) {
        
        for (Geotification *geoLoc in self.allAddedRegions) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:geoLoc.coordinate.latitude longitude:geoLoc.coordinate.longitude];
            CLLocationDistance meters = [self.locationManager.location distanceFromLocation:location];
            geoLoc.distanceFromUserLocation = meters;
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:@"distanceFromUserLocation" ascending:YES];
        self.sortedRegions = [self.allAddedRegions sortedArrayUsingDescriptors:@[descriptor]];
        
        for (NSInteger i = 0;  i < 20; i ++) {
            Geotification * geotification = [self.sortedRegions objectAtIndex:i];
            [self.monitoredTwentyRegions addObject:geotification];
        }
        
        NSLog(@"Monitored regions = %zd", self.monitoredTwentyRegions.count);
        
        for (Geotification *geoLoc in self.monitoredTwentyRegions) {
            [self startMonitoringGeotification:geoLoc];
        }
    }
    
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id)overlay
{
    
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer* aRenderer = [[MKCircleRenderer
                                        alloc]initWithCircle:(MKCircle *)overlay];
        
        aRenderer.fillColor = [[UIColor magentaColor] colorWithAlphaComponent:0.4];
        aRenderer.strokeColor = [[UIColor magentaColor] colorWithAlphaComponent:1];
        aRenderer.lineWidth = 3;
        aRenderer.alpha = 0.5;
        
        return aRenderer;
    }
    else
    {
        return nil;
    }
}






#pragma mark - MakingAdress


- (void) makeAddress {
    CLLocation *location = self.locationManager.location;
    [self getAddressFromLocation:location];
}


-(NSString*)getAddressFromLocation:(CLLocation *)location {
    
    __block NSString *address;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error)
     
     {
         if(placemarks && placemarks.count > 0)
         {
             CLPlacemark *placemark= [placemarks objectAtIndex:0];
             
             address = [NSString stringWithFormat:@"%@ %@,%@ %@", [placemark subThoroughfare],[placemark thoroughfare],[placemark locality], [placemark administrativeArea]];
             NSLog(@"current addres %@", address);
             
         }
         
     }];
    
    return address;
}





#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
