//
//  SampleProjectViewController.m
//  SampleProject
//
//  Created by Tim Taylor on 5/17/11.
//  Copyright 2011 Big Diggy SW. All rights reserved.
//

/*
 
 The below license is the new BSD license with the OSI recommended personalizations.
 <http://www.opensource.org/licenses/bsd-license.php>
 
 Copyright (C) 2011 Big Diggy SW. All Rights Reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Tim Taylor nor Big Diggy SW 
 may be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY Big Diggy SW "AS IS" AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */


#import "SampleProjectViewController.h"
#import "BDMKPolygonToDataTransformer.h"
@implementation SampleProjectViewController
@synthesize myMapView;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Move the polygon file from the application bundle to the Documents Directory
	[self moveFileToDocDirectory];
	
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	// Load the polygon from the file
	MKPolygon *thePolygon=[self polygonFromFileForName:@"WashingtonSample"];
	
	// Show that the tranformer is working correctly
	BDMKPolygonToDataTransformer *myTransformer=[[BDMKPolygonToDataTransformer alloc] init];
	NSData *theData=[myTransformer transformedValue:thePolygon];
	thePolygon=nil;
	thePolygon=[myTransformer reverseTransformedValue:theData];
    
    
    // Test for performance and leaking of objects
 /*  
  __unsafe_unretained NSData *weakData=theData;
    dispatch_apply(7000, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(size_t indx) {
  
  // this new @autoreleasepool construct rocks.
        @autoreleasepool {
            NSData *strongData=weakData;
            BDMKPolygonToDataTransformer *anotherTransformer=[[BDMKPolygonToDataTransformer alloc] init];
            MKPolygon *anotherPolygon=[anotherTransformer reverseTransformedValue:strongData];
        }
        
    });
	
	*/
	// Add to the mapView	
    [self.myMapView addOverlay:thePolygon];

    [self.myMapView addAnnotation:thePolygon];
	
	[self.myMapView setVisibleMapRect:[thePolygon boundingMapRect] animated:YES];
	
}
- (void)moveFileToDocDirectory{
	//   //NSLog@"createEditableCopyOfDatabaseIfNeeded start");
	BOOL success;
	NSString *writablePath = [[self applicationDocumentDirectory] stringByAppendingPathComponent:@"WashingtonSample.bdl"];

	// First, test for existence.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	success = [fileManager fileExistsAtPath:writablePath];
	if (success) return;
	NSLog(@"creating a copy of the file");
	
	NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"WashingtonSample.bdl"];
	NSLog(@"defaultPath=%@",defaultPath);
	NSError *fileCopyError=nil;
	success = [fileManager copyItemAtPath:defaultPath toPath:writablePath error:&fileCopyError];
	//	//NSLog@"  9");
	if (!success) {
		NSLog(@"couldn't create the writable file");
		NSAssert1(0, @"Failed to create the file with message '%@'.", [fileCopyError localizedDescription]);
	}
	NSLog(@"file copied");
	
   	//	//NSLog@"createEditableCopyOfDatabaseIfNeeded end");
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(MKPolygon *)polygonFromFileForName:(NSString *)fileName{
	NSURL *dataURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.bdl",fileName]];
	NSData *theData=[NSData dataWithContentsOfURL: dataURL];
	BDMKPolygonToDataTransformer *myTransformer=[[BDMKPolygonToDataTransformer alloc] init];
	
	MKPolygon *thePolygon=[myTransformer reverseTransformedValue:theData];
	return thePolygon;
	
}

-(void)writePolygonToFile:(MKPolygonView *)thePolygon withName:(NSString *)fileName{
	NSURL *dataURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.bdl",fileName]];
	
	BDMKPolygonToDataTransformer *myTransformer=[[BDMKPolygonToDataTransformer alloc] init];
	NSData *theData=[myTransformer transformedValue:thePolygon];
	//	NSLog(@"the size of the compressed polygon:  %d",[theData length]);
	
	[theData writeToURL:dataURL atomically:YES];
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)applicationDocumentDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}



#pragma mark -
#pragma mark Mapkit Deletage Methods


// Mapkit

// Monitoring Region Changes
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
	//	NSLog(@"	mapView regionWillChangeAnimated");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
	//	NSLog(@"	mapView regionDidChangeAnimated");
	
}

// Loading the map
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
	//	NSLog(@"	mapView mapViewDidFinishLoadingMap");
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView{
	//	NSLog(@"	mapView mapViewWillStartLoadingMap");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error{
	//	NSLog(@"	mapView mapViewDidFailLoadingMap Error:  %@",[error userInfo]);
}



// Locating the User
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView{
	//	NSLog(@"mapView mapViewWillStartLocatingUser");
}
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView{
	//	NSLog(@"mapView mapViewDidStopLocatingUser");
	
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	//	NSLog(@"mapView didUpdateUserLocation:  %@",[userLocation description]);
	//	self.myMapView.showsUserLocation=NO;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
	
	MKPolygonView *theView=[[MKPolygonView alloc] initWithOverlay:overlay];
	theView.fillColor=[UIColor blueColor];
	theView.strokeColor=[UIColor blackColor];

	theView.alpha=0.35;
	
	//NSLog(@"MultiPolygonView=%@",theView);
	return theView;;
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
	MKPinAnnotationView *pin =	[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
	pin.canShowCallout = YES;
	pin.animatesDrop = YES;
	return pin;
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.myMapView=nil;
}



@end
