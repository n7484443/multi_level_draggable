//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <multi_level_draggable/multi_level_draggable_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) multi_level_draggable_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "MultiLevelDraggablePlugin");
  multi_level_draggable_plugin_register_with_registrar(multi_level_draggable_registrar);
}
