//
//  FSQPeopleHereTableViewController.m
//  ios-interview
//
//  Created by Samuel Grossberg on 3/17/16.
//  Copyright © 2016 Foursquare. All rights reserved.
//

#import "FSQPeopleHereTableViewController.h"
#import "ios_interview-Swift.h"

@interface FSQPeopleHereTableViewController ()
@property (nonatomic) FSVenue *venue;
@end

@implementation FSQPeopleHereTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    [self getData];
}

// MARK - Removes possibility legacy Obj-C retain cycles
-(void)dealloc {
    self.tableView.dataSource = nil;
}

#pragma mark - Setup view

-(void)setupView {
    self.tableView.rowHeight = 50.f;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = false;
    [self.tableView registerClass:[FSPeopleHereTableViewCell class] forCellReuseIdentifier:FSPeopleHereTableViewCell.cellReuseId];
}

#pragma mark - Get data for controller

-(void)getData {
    self.venue = [FSVenueToObjC loadVenue];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.venue.visitorsDuringOpenHours.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSPeopleHereTableViewCell *cell = (FSPeopleHereTableViewCell *)[tableView dequeueReusableCellWithIdentifier:FSPeopleHereTableViewCell.cellReuseId forIndexPath:indexPath];

    cell.venueVisitor = self.venue.visitorsDuringOpenHours[indexPath.row];
    return cell;
}

@end
