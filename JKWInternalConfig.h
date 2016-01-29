//
//  JKWInternalConfig.h
//  LibSafariViewController
//
//  Created by jinkai on 16/1/26.
//  Copyright © 2016年 jinkai. All rights reserved.
//

#ifndef JKWInternalConfig_h
#define JKWInternalConfig_h

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

const static int barBackgroundViewHeight = 44;
const static int itemHeight = 30;
const static int yPos = (barBackgroundViewHeight-itemHeight)/2 ;

#endif /* JKWInternalConfig_h */
