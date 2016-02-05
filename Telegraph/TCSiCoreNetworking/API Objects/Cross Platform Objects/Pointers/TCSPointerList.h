//
//  TCSPointerList.h
//  TCSP2P
//
//  Created by a.v.kiselev on 13.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSPointer.h"

@interface TCSPointerList : TCSBaseObject

@property (nonatomic, strong, readonly) NSArray * pointers;
@property (nonatomic, strong, readonly) NSArray * pointersWithoutTCS;
@property (nonatomic, strong, readonly) TCSPointer * pointerTCS;
@property (nonatomic, strong, readonly) NSArray * pointersEmail;
@property (nonatomic, strong, readonly) NSArray * pointersFacebook;
@property (nonatomic, strong, readonly) NSArray * pointersVk;
@property (nonatomic, strong, readonly) NSArray * pointersMobile;

@end
