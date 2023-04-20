#include "include/multi_level_draggable/multi_level_draggable_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "multi_level_draggable_plugin.h"

void MultiLevelDraggablePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  multi_level_draggable::MultiLevelDraggablePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
