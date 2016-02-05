//
//  TCSCompatibility.h
//  TCSP2P
//
//  Created by a.v.kiselev on 18.09.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

@interface TCSCompatibility : TCSBaseObject

- (NSString *)releaseNotes;
- (NSString*)releaseNotesTitle;
- (float)leastCompatibleVersion;
- (float)newVersion;
- (NSTimeInterval)newVersionDate;
- (NSURL *)url;

@end
