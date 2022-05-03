#import "MillicastFlutterSdkPlugin.h"
#if __has_include(<millicast_flutter_sdk/millicast_flutter_sdk-Swift.h>)
#import <millicast_flutter_sdk/millicast_flutter_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "millicast_flutter_sdk-Swift.h"
#endif

@implementation MillicastFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMillicastFlutterSdkPlugin registerWithRegistrar:registrar];
}
@end
