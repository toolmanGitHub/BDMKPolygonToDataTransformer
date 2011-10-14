//
//  BDMKPolygonToDataTransformer.h
//  BDKMLToMKPolygon
//
//  Created by Tim Taylor on 5/10/11.
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


#import <Foundation/Foundation.h>
/**
 A subclass of NSValueTransformer that transforms an MKPolygon to a zipped NSData object. The creation of the zipped NSData object is done via the NSData-Extensions categorie from CocoaDev 
 
*/ 

@class MKPolygon;
@interface BDMKPolygonToDataTransformer : NSValueTransformer {

}
/** Helper method that, given an NSDictionary object, will convert the polygon's points and any internal polygons into an MKPolygon.  This method will recursively create MKPolygons for the internal polygon.
 
 @return An MKPolygon object
 @param polygonDictionary An NSDictionary object that contains entires for the polygons points and any internal polygons.
 */
-(MKPolygon *)polygonForDictionary:(NSDictionary *)polygonDictionary;

/** Helper method that converts an MKPolygon to an NSDictionary.  The dictionary will then be converted by the transformer to a zipped NSData object.
 
 @return An NSDictionary object that contains entires for the polygons points and any internal polygons.
 @param thePolygon An MKPolygon object.
 */
-(NSDictionary *)dictionaryForPolygon:(MKPolygon *)thePolygon;

@end
