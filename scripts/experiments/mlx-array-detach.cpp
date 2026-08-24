#include <mlx/array.h>
#include <mlx/c/array.h>

extern "C" int mlx_bun_array_detach(mlx_array value) {
  if (value.ctx == nullptr) return -1;
  auto* array = static_cast<mlx::core::array*>(value.ctx);
  auto outputs = array->outputs();
  for (auto& output : outputs) {
    if (!output.is_available()) return -2;
  }
  for (auto& output : outputs) output.detach();
  return 0;
}
