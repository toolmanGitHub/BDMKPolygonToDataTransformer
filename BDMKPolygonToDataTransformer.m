//
//  BDDataToMKPolygonTransformer.m
//  BDKMLToMKPolygon
//
//  Created by Tim Taylor on 5/10/11.
//  Copyright 2011 Big Diggy SW. All rights reserved.//

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


#import "BDMKPolygonToDataTransformer.h"
#import <MapKit/MapKit.h>
#import "NSData-Extensions.h"

@implementation BDMKPolygonToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	
    if (![value isKindOfClass:[MKPolygon class]]) {
        // Throw an exception if the wrong class is used.
        // The class must be MKPolygon.
        [NSException raise:@"BDMKPolygonToDataTransformer Exception" format:@"BDMKPolygonToDataTransformer transformedValue: value passed is not an MKPolygon instance!"];
    }
    
    MKPolygon *thePolygon=(MKPolygon *)value;
	
	NSString *errorString=nil;
	NSData * polygonData = [NSPropertyListSerialization dataFromPropertyList:[self dictionaryForPolygon:thePolygon]
																	  format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorString];  
	NSLog(@"errorString: %@",errorString);
	return [polygonData gzipDeflate];
	
}

-(NSDictionary *)dictionaryForPolygon:(MKPolygon *)thePolygon{
	NSUInteger numberOfCoordinates=thePolygon.pointCount;
	
	NSData *dataPoints=[NSData dataWithBytes:(thePolygon.points) length:sizeof(MKMapPoint)*numberOfCoordinates];
	
	// recursively retrieve the interior polygons
	NSArray *theInteriorPolygons=[thePolygon interiorPolygons];
	
	NSMutableArray *interiorPolygons=[NSMutableArray arrayWithCapacity:[[thePolygon interiorPolygons] count]];
	
	
	__block NSMutableArray *blockArray=interiorPolygons;
	[theInteriorPolygons enumerateObjectsUsingBlock:^(id polygon, NSUInteger iCntr, BOOL *stop){
		[blockArray addObject:[self dictionaryForPolygon:polygon]];
	}];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:dataPoints,@"polygonPoints",interiorPolygons,@"interiorPolygons",nil];
	
	
}

- (id)reverseTransformedValue:(id)value {
    if (![value isKindOfClass:[NSData class]]) {
        // Throw an exception if the wrong class is used.
        // The class must be NSData.
        [NSException raise:@"BDMKPolygonToDataTransformer Exception" format:@"BDMKPolygonToDataTransformer reverseTransformedValue: value passed is not an NSData instance!"];
    }
	NSData *theData=[(NSData *)value gzipInflate];
	NSString *errorString=nil;
	NSDictionary *polygonDictionary=[NSPropertyListSerialization propertyListFromData:theData 
																	 mutabilityOption:NSPropertyListImmutable 
																			   format:NULL 
																	 errorDescription:&errorString];
	MKPolygon *thePolygon=[self polygonForDictionary:polygonDictionary];
	
	
	return thePolygon;
	
	
}


-(MKPolygon *)polygonForDictionary:(NSDictionary *)polygonDictionary{
	NSArray *keys=[polygonDictionary allKeys];
	NSData *dataPoints=nil;
	NSMutableArray *interiorPolygons=nil;
	MKMapPoint *mapPoints=nil;
	NSUInteger pointCount=0;
	
	if (![keys containsObject:@"polygonPoints"]) {
		NSLog(@"BDMKPolygonToDataTransformer->polygonForDictionary: warning: polygonPoints Key not found");
	}else{
		
		dataPoints=[polygonDictionary objectForKey:@"polygonPoints"];
		mapPoints=(MKMapPoint *)[dataPoints bytes];
		pointCount=[dataPoints length]/(sizeof(MKMapPoint));
		
		if (pointCount==0) {
			NSLog(@"BDMKPolygonToDataTransformer->polygonForDictionary: warning: number of polygonPoints is zero");
			
		}else {
			if ([keys containsObject:@"interiorpolygons"]) {
				NSArray *theInteriorPolygons=[polygonDictionary objectForKey:@"interiorPolygons"];
				
				if ([theInteriorPolygons count]>0) {
					
					// Recurse for the interior polygons
					interiorPolygons=[NSMutableArray arrayWithCapacity:[theInteriorPolygons count]];
					__block NSMutableArray *blockArray=interiorPolygons;
					[theInteriorPolygons enumerateObjectsUsingBlock:^(id polygonDict, NSUInteger iCntr, BOOL *stop){
						[blockArray addObject:[self polygonForDictionary:polygonDict]];
					}];
					
				} //if ([theInteriorPolygons count]>0)
			} //if ([keys containsObject:@"interiorpolygons
			
		}//if ([polygonPoints count]==0) 
		
	} //if ([keys containsObject:@"polygonPoints")
	
	
	MKPolygon *thePolygon=[MKPolygon polygonWithPoints:mapPoints count:pointCount interiorPolygons:interiorPolygons];
	return thePolygon;
	
}


@end
