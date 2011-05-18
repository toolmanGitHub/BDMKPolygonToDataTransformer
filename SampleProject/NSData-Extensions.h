//
//  NSData-Extensions.h
//  BDKMLToMKPolygon
//
//  Created by Tim Taylor on 5/11/11.
//  Copyright 2011 Big Diggy SW. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <Foundation/Foundation.h>


@interface NSData (Extensions)



// GZIP 
// Courtesy of CocoaDev:  http://www.cocoadev.com/index.pl?NSDataCategory
- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;
@end
