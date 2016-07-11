//
//  AVRegionsTableViewController.m
//  GeoTest2
//
//  Created by Anton Voropaev on 02.06.16.
//  Copyright © 2016 Anton Voropaev. All rights reserved.
//

#import "AVRegionsTableViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface AVRegionsTableViewController ()
@property (strong, nonatomic) NSArray *monitoredRegions;


@end

@implementation AVRegionsTableViewController

- (instancetype)initWithRegions:(NSArray*)regions
{
    self = [super init];
    if (self) {
        
        
        self.navigationItem.title = @"List of monitored regions";
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"identifier" ascending:YES];
        NSArray *sortedArray = [regions sortedArrayUsingDescriptors:@[descriptor]];
        self.monitoredRegions = sortedArray;
        
        
       
    }
    
    
    return self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.monitoredRegions count];
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    CLCircularRegion *region = [self.monitoredRegions objectAtIndex:indexPath.row];
    cell.textLabel.text = region.identifier;
    
    return cell;
}




@end
