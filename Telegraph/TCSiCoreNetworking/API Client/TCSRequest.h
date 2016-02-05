//
//  TCSP2PRequest.h
//  TCSP2P
//
//  Created by Alexey Voitenko on 14.02.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSRequest : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *requestKey;
@property (nonatomic, strong) NSMutableDictionary *parameters; // TODO: make it immutable

	// TODO: make this properties publicly readonly with readwrite attribute inside the framework
@property (nonatomic, strong) id responseObject;

@property (nonatomic, strong) id payload;
@property (nonatomic, strong) NSError *error;

@end
