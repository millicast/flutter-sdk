#include "include/millicast_flutter_sdk/millicast_flutter_sdk_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "millicast_flutter_sdk_plugin.h"

void MillicastFlutterSdkPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  millicast_flutter_sdk::MillicastFlutterSdkPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
