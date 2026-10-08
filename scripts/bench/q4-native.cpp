// Standalone lab probe, not linked into the shipped runtime. See build script.
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <random>
#include "mlx/mlx.h"
#include "mlx/primitives.h"
#include "mlx/backend/metal/device.h"

namespace mx = mlx::core;
static std::string library_dir;
static MTL::Library* library(mx::metal::Device& d) {
  return std::filesystem::is_regular_file(library_dir)
    ? d.get_library("q4_native_source", mx::CompileOptions{}, [] {
        std::ifstream source(library_dir);
        return std::string(std::istreambuf_iterator<char>(source), {});
      })
    : d.get_library("q4_native", library_dir);
}
class OperandProbe final : public mx::Primitive {
 public:
  explicit OperandProbe(mx::Stream s) : Primitive(s) {}
  const char* name() const override { return "LabExactOperands"; }
  void eval_cpu(const std::vector<mx::array>&, std::vector<mx::array>&) override { throw std::runtime_error("Metal required"); }
  void eval_gpu(const std::vector<mx::array>&, std::vector<mx::array>& out) override {
    out[0].set_data(mx::allocator::malloc(out[0].nbytes()));
    auto& d = mx::metal::device(stream().device);
    auto& enc = mx::metal::get_command_encoder(stream());
    enc.set_compute_pipeline_state(d.get_kernel("exact_operands", library(d)));
    enc.set_output_array(out[0], 0);
    enc.dispatch_threads(MTL::Size(65536, 1, 1), MTL::Size(256, 1, 1));
  }
};
class Q4Verify final : public mx::Primitive {
  bool matrix_;
 public:
  explicit Q4Verify(mx::Stream stream, bool matrix) : Primitive(stream), matrix_(matrix) {}
  const char* name() const override { return "LabQ4Verify"; }
  bool is_equivalent(const mx::Primitive& other) const override {
    return matrix_ == static_cast<const Q4Verify&>(other).matrix_;
  }
  std::vector<mx::Shape> output_shapes(const std::vector<mx::array>& a) override {
    return {{a[0].shape(0), a[1].shape(0)}};
  }
  void eval_cpu(const std::vector<mx::array>&, std::vector<mx::array>&) override {
    throw std::runtime_error("Q4Verify requires Metal");
  }
  void eval_gpu(const std::vector<mx::array>& a, std::vector<mx::array>& out) override {
    for (const auto& input : a)
      if (!input.flags().row_contiguous) throw std::runtime_error("probe requires contiguous inputs; no implicit copies");
    auto& y = out[0]; y.set_data(mx::allocator::malloc(y.nbytes()));
    auto& d = mx::metal::device(stream().device);
    int rows = 1; while (rows < a[0].shape(0)) rows *= 2;
    auto kernel = d.get_kernel(matrix_ ? "q4_mma" : "q4_rows" + std::to_string(rows), library(d));
    auto& enc = mx::metal::get_command_encoder(stream());
    enc.set_compute_pipeline_state(kernel);
    for (int i = 0; i < 4; ++i) enc.set_input_array(a[i], i);
    enc.set_output_array(y, 4);
    // Metal uint3 occupies 16 bytes.
    uint32_t shape[4] = {uint32_t(a[0].shape(0)), uint32_t(a[1].shape(0)), uint32_t(a[0].shape(1)), 0};
    enc.set_bytes(shape, sizeof(shape), 5);
    enc.dispatch_threads(matrix_
      ? MTL::Size(32 * ((a[1].shape(0) + 7) / 8), (a[0].shape(0) + 7) / 8, 1)
      : MTL::Size(32 * a[1].shape(0), 1, 1), MTL::Size(32, 1, 1));
  }
};
static mx::array native_q4(const std::vector<mx::array>& a, bool matrix) {
  if (a.size() != 4 || a[0].ndim() != 2 || a[1].ndim() != 2 ||
      a[0].shape(0) < 1 || a[0].shape(0) > 16 || a[0].shape(1) % 256 ||
      a[1].shape(1) * 8 != a[0].shape(1) || a[0].dtype() != mx::bfloat16 ||
      a[1].dtype() != mx::uint32 || a[2].dtype() != mx::bfloat16 || a[3].dtype() != mx::bfloat16 ||
      a[2].shape() != mx::Shape{a[1].shape(0), a[0].shape(1) / 64} || a[3].shape() != a[2].shape())
    throw std::runtime_error("expected BF16 [M<=16,K%256=0], Q4 [N,K/8], BF16 scale/bias [N,K/64]");
  return mx::array({a[0].shape(0), a[1].shape(0)}, mx::bfloat16,
    std::make_shared<Q4Verify>(mx::default_stream(mx::Device::gpu), matrix), a);
}
template <class F> static double measure(F fn) {
  for (int i = 0; i < 5; ++i) mx::eval(fn());
  std::vector<double> times;
  for (int i = 0; i < 21; ++i) {
    auto start = std::chrono::steady_clock::now(); mx::eval(fn());
    times.push_back(std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - start).count());
  }
  std::sort(times.begin(), times.end()); return times[times.size() / 2];
}
int main(int argc, char** argv) {
  try {
    if (argc != 4 && argc != 5) throw std::runtime_error("usage: q4-native /metallib/directory-or-source.metal K N [mma]");
    const bool matrix = argc == 5 && std::string(argv[4]) == "mma";
    if (argc == 5 && !matrix) throw std::runtime_error("unknown kernel option");
    library_dir = argv[1]; const int K = std::stoi(argv[2]), N = std::stoi(argv[3]);
    std::cout << std::setprecision(9);
    if (K <= 0 || N <= 0 || K % 256) throw std::runtime_error("positive N, K divisible by 256 required");
    auto operands = mx::array({65536, 2}, mx::float32,
      std::make_shared<OperandProbe>(mx::default_stream(mx::Device::gpu)), {});
    mx::eval(operands);
    const float* values = operands.data<float>();
    for (uint32_t i = 0; i < 65536; ++i) {
      uint32_t widened; std::memcpy(&widened, values + 2 * i + 1, sizeof(widened));
      if (values[2 * i] != float(i & 15) || ((i & 0x7f80) != 0x7f80 && widened != (i << 16)))
        throw std::runtime_error("exact operand conversion failed");
    }
    std::cout << "{\"exactQ4Nibbles\":16,\"exactFiniteBf16Patterns\":65280,\"compileMode\":\""
      << (std::filesystem::is_regular_file(library_dir) ? "native-runtime" : "offline-metallib")
      << "\",\"kernel\":\"" << (matrix ? "mma" : "simd") << "\"}" << std::endl;
    std::mt19937 rng(42); std::normal_distribution<float> normal(0, 0.1f);
    std::vector<float> host(size_t(N) * K); for (auto& x : host) x = normal(rng);
    auto q = mx::quantize(mx::astype(mx::array(host.data(), {N, K}), mx::bfloat16), 64, 4);
    mx::eval(q);
    int traces = 0;
    auto compiled = mx::compile(std::function<std::vector<mx::array>(const std::vector<mx::array>&)>(
      [&](const auto& a) { ++traces; return std::vector<mx::array>{native_q4(a, matrix)}; }), true);
    for (int M : {1, 3, 5, 9, 3}) {
      std::vector<float> input(size_t(M) * K); for (auto& x : input) x = normal(rng);
      auto x = mx::astype(mx::array(input.data(), {M, K}), mx::bfloat16); mx::eval(x);
      std::vector<mx::array> a{x, q[0], q[1], q[2]};
      auto ref = [&] { return mx::quantized_matmul(x, q[0], q[1], q[2], true, 64, 4); };
      auto candidate = [&] { return compiled(a)[0]; };
      auto y = candidate(), r = ref(); mx::eval({y, r});
      auto diff = mx::abs(mx::subtract(mx::astype(y, mx::float32), mx::astype(r, mx::float32)));
      float error = mx::max(diff).item<float>();
      bool exact = std::memcmp(y.data<char>(), r.data<char>(), y.nbytes()) == 0;
      // Alternate order per shape. These cache-warm projection microbenchmarks
      // are diagnostic; only full-model paired measurements can establish a win.
      double native_ms, mlx_ms;
      if (M % 4 == 1) { native_ms = measure(candidate); mlx_ms = measure(ref); }
      else { mlx_ms = measure(ref); native_ms = measure(candidate); }
      std::cout << "{\"M\":" << M << ",\"N\":" << N << ",\"K\":" << K
        << ",\"nativeMs\":" << native_ms << ",\"mlxMs\":" << mlx_ms
        << ",\"maxAbsError\":" << error << ",\"bitExact\":" << (exact ? "true" : "false")
        << ",\"shapelessTraces\":" << traces << "}" << std::endl;
      if (!std::isfinite(error) || traces != 1) throw std::runtime_error("nonfinite result or shapeless retracing");
    }
  } catch (const std::exception& e) { std::cerr << e.what() << std::endl; return 1; }
}
