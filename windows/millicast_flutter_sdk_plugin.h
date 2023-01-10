#ifndef FLUTTER_PLUGIN_MILLICAST_FLUTTER_SDK_PLUGIN_H_
#define FLUTTER_PLUGIN_MILLICAST_FLUTTER_SDK_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace millicast_flutter_sdk {

class MillicastFlutterSdkPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  MillicastFlutterSdkPlugin();

  virtual ~MillicastFlutterSdkPlugin();

  // Disallow copy and assign.
  MillicastFlutterSdkPlugin(const MillicastFlutterSdkPlugin&) = delete;
  MillicastFlutterSdkPlugin& operator=(const MillicastFlutterSdkPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace millicast_flutter_sdk

#endif  // FLUTTER_PLUGIN_MILLICAST_FLUTTER_SDK_PLUGIN_H_
