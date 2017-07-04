//
//  NotificationViewController.m
//  DepartureNotification
//
//  Created by Anteneh Sahledengel on 7/3/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

#import "Notifications.h"
#import "ReittiStringFormatter.h"
#import "ReittiDateHelper.h"

@import MapKit;

@interface NotificationViewController () <UNNotificationContentExtension, MKMapViewDelegate>

@property (strong, nonatomic) DepartureNotification *departureNotification;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UIImageView *stopIcon;
@property (strong, nonatomic) IBOutlet UILabel *transportLabel;
@property (strong, nonatomic) IBOutlet UILabel *destinationLabel;
@property (strong, nonatomic) IBOutlet UILabel *mainDepartureTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;

@property (strong, nonatomic) IBOutlet UILabel *otherTimesTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *firstLaterDepartureLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondLaterDepartureLabel;
@property (strong, nonatomic) IBOutlet UILabel *thirdLaterDepartureLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *spaceToOtherDeparturesConstraint;
@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    
//    self.preferredContentSize = CGSizeMake(1, 226);
    
    self.otherTimesTitleLabel.hidden = YES;
    self.firstLaterDepartureLabel.hidden = YES;
    self.secondLaterDepartureLabel.hidden = YES;
    self.thirdLaterDepartureLabel.hidden = YES;
    
    self.spaceToOtherDeparturesConstraint.active = NO;
}

- (void)didReceiveNotification:(UNNotification *)notification {
    DepartureNotification *deptNotif = [[DepartureNotification alloc] initFromDictionary:notification.request.content.userInfo];
    
    self.departureNotification = deptNotif;
    
    self.stopIcon.image = [UIImage imageNamed:deptNotif.stopIconName];
    self.transportLabel.text = deptNotif.departureLine;
    self.destinationLabel.text = [NSString stringWithFormat:@"➞ %@", deptNotif.departureLineDestination];
    self.detailLabel.text = deptNotif.stopName;
    
    [self setTime:deptNotif.departureTime toLabel:self.mainDepartureTimeLabel useRelative:YES];
    
    if (deptNotif.laterDepartureTimes && deptNotif.laterDepartureTimes.count > 0) {
        self.otherTimesTitleLabel.hidden = NO;
        self.spaceToOtherDeparturesConstraint.active = YES;
        
        [self setTime:deptNotif.laterDepartureTimes[0] toLabel:self.firstLaterDepartureLabel useRelative:NO];
        
        if (deptNotif.laterDepartureTimes.count > 1)
            [self setTime:deptNotif.laterDepartureTimes[1] toLabel:self.secondLaterDepartureLabel useRelative:NO];
        
        if (deptNotif.laterDepartureTimes.count > 2)
            [self setTime:deptNotif.laterDepartureTimes[2] toLabel:self.thirdLaterDepartureLabel useRelative:NO];
    }
    
    [self setupMapView];
}

-(void)setTime:(NSDate *)time toLabel:(UILabel *)label useRelative:(BOOL)useRelative {
    NSTimeInterval timeFromNow = [time timeIntervalSinceNow];
    
    if (timeFromNow > 60 && timeFromNow < 360 && useRelative) {
        NSString *numString = [NSString stringWithFormat:@"%d", (int)timeFromNow/60];
        NSAttributedString *timeString = [ReittiStringFormatter formatAttributedString:numString withUnit:@" min" withFont:label.font andUnitFontSize:14];
        label.attributedText = timeString;
    } else {
        NSString *timeString = [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:time];
        label.text = timeString;
    }
    
    label.hidden = NO;
}

-(void)setupMapView {
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:self.departureNotification.stopCoordString];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.title = nil;
    annotation.subtitle = nil;
    annotation.coordinate = coordinate;
    
    [self.mapView addAnnotation:annotation];
    
    [self centerMapRegionToCoordinate:coordinate];
}

-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coordinate{
    if (coordinate.latitude < 30 || coordinate.latitude > 90 || coordinate.longitude < 0 || coordinate.longitude > 150)
        return NO;
    
    MKCoordinateSpan span = {.latitudeDelta =  0.005, .longitudeDelta =  0.005};
    MKCoordinateRegion region = {coordinate, span};
    
    [self.mapView setRegion:region animated:NO];
    
    return YES;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKAnnotationView* aView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                               reuseIdentifier:@"StopAnnotation"];
        
        aView.image = [UIImage imageNamed:self.departureNotification.stopAnnotationImageName];
        aView.frame = CGRectMake(0, 0, 28, 42);
        aView.centerOffset = CGPointMake(0, -15);
        
        return aView;
    }
    
    return nil;
}

@end
