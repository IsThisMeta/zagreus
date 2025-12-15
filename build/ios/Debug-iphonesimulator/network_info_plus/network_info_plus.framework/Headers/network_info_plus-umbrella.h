#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FPPCaptiveNetworkInfoProvider.h"
#import "FPPHotspotNetworkInfoProvider.h"
#import "FPPNetworkInfo.h"
#import "FPPNetworkInfoPlusPlugin.h"
#import "FPPNetworkInfoProvider.h"
#import "getgateway.h"
#import "route.h"

FOUNDATION_EXPORT double network_info_plusVersionNumber;
FOUNDATION_EXPORT const unsigned char network_info_plusVersionString[];

