//
//  TCSMBiOSLabel.h
//  TCSMBiOS
//
//  Created by Max Zhdanov on 23.10.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

@interface TCSMBiOSLabel : UILabel
{
	CAGradientLayer *_gradientLayer;
    CALayer *_layerWithoutGradient;
	CGSize		attributedTextSize;
}

@end
