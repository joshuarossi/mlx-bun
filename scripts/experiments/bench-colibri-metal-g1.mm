// Pinned Colibri Metal side of the G1 quiet kernel matrix.
//
// This harness is compiled together with the read-only exact-pin
// c/backend_metal.mm. It uses production GLM-5.2 dimensions, Colibri's native
// offset-binary Q4 layout, deterministic inputs, CPU-reference spot checks,
// warmups, and repeated wall-clock samples. Absolute timings are quotable only
// when the caller has established the workflow's quiet-machine precondition.

#include "backend_metal.h"
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <functional>
#include <string>
#include <vector>

#ifndef COLIBRI_PIN
#define COLIBRI_PIN "unknown"
#endif
#ifndef COLIBRI_METAL_SHA256
#define COLIBRI_METAL_SHA256 "unknown"
#endif
#ifndef COLIBRI_HEADER_SHA256
#define COLIBRI_HEADER_SHA256 "unknown"
#endif
#ifndef HARNESS_SHA256
#define HARNESS_SHA256 "unknown"
#endif

namespace {

constexpr int Q4 = 2;
constexpr size_t PAGE = 16384;
constexpr int D = 6144;
constexpr int M = 2048;
constexpr int HEADS = 64;
constexpr int QLORA = 2048;
constexpr int KVL = 512;
constexpr int ROPE = 64;
constexpr int NOPE = 192;
constexpr int VH = 256;
constexpr int QH = 256;
constexpr int KVROWS = 448;

struct Rng {
  uint32_t state;
  explicit Rng(uint32_t seed) : state(seed) {}
  uint32_t next() {
    uint32_t x = state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    return state = x;
  }
  float activation() {
    return (static_cast<int>(next() % 2001) - 1000) / 1000.0f;
  }
  float scale() {
    return 0.005f + static_cast<float>(next() % 501) / 50000.0f;
  }
};

size_t align_page(size_t value) {
  return (value + PAGE - 1) & ~(PAGE - 1);
}

struct Allocation {
  void *data = nullptr;
  size_t bytes = 0;
  Allocation() = default;
  explicit Allocation(size_t requested) : bytes(align_page(requested)) {
    if (posix_memalign(&data, PAGE, bytes) != 0 || !data)
      throw std::bad_alloc();
    std::memset(data, 0, bytes);
  }
  Allocation(const Allocation &) = delete;
  Allocation &operator=(const Allocation &) = delete;
  Allocation(Allocation &&other) noexcept
      : data(other.data), bytes(other.bytes) {
    other.data = nullptr;
    other.bytes = 0;
  }
  ~Allocation() { std::free(data); }
};

struct Q4Matrix {
  int output;
  int input;
  Allocation packed;
  Allocation scales;
  Q4Matrix(int output_, int input_, Rng &rng)
      : output(output_), input(input_),
        packed(static_cast<size_t>(output_) * ((input_ + 1) / 2)),
        scales(static_cast<size_t>(output_) * sizeof(float)) {
    auto *weight = static_cast<uint8_t *>(packed.data);
    auto *scale = static_cast<float *>(scales.data);
    const size_t used =
        static_cast<size_t>(output) * ((input + 1) / 2);
    for (size_t index = 0; index < used; ++index)
      weight[index] = static_cast<uint8_t>(rng.next());
    for (int row = 0; row < output; ++row) scale[row] = rng.scale();
    coli_metal_register(packed.data, packed.bytes);
    coli_metal_register(scales.data, scales.bytes);
  }
  ~Q4Matrix() {
    coli_metal_unregister(packed.data);
    coli_metal_unregister(scales.data);
  }
  const uint8_t *w() const {
    return static_cast<const uint8_t *>(packed.data);
  }
  const float *s() const {
    return static_cast<const float *>(scales.data);
  }
  float dequant(int row, int column) const {
    const int row_bytes = (input + 1) / 2;
    const uint8_t byte =
        w()[static_cast<size_t>(row) * row_bytes + (column >> 1)];
    const int q = (column & 1) ? (byte >> 4) : (byte & 15);
    return static_cast<float>(q - 8) * s()[row];
  }
  float dot(int row, const float *x) const {
    float accumulator = 0.0f;
    for (int column = 0; column < input; ++column)
      accumulator += dequant(row, column) * x[column];
    return accumulator;
  }
};

struct Error {
  double max_abs = 0;
  double max_reference = 0;
  size_t checked = 0;
  double normalized() const {
    return max_abs / (max_reference + 1e-12);
  }
  void add(float actual, float expected) {
    max_abs = std::max(max_abs,
                       static_cast<double>(std::fabs(actual - expected)));
    max_reference =
        std::max(max_reference, static_cast<double>(std::fabs(expected)));
    ++checked;
  }
};

struct Result {
  std::string name;
  std::string operation;
  std::string shape;
  Error error;
  double tolerance = 0;
  std::vector<double> samples_ms;
  double median_ms = 0;
};

double median(std::vector<double> values) {
  std::sort(values.begin(), values.end());
  const size_t middle = values.size() / 2;
  if (values.size() & 1) return values[middle];
  return (values[middle - 1] + values[middle]) / 2.0;
}

std::vector<double> benchmark(
    int warmups, int repeats, const std::function<bool()> &call) {
  for (int index = 0; index < warmups; ++index)
    if (!call()) throw std::runtime_error("Metal warmup returned fallback");
  std::vector<double> samples;
  for (int index = 0; index < repeats; ++index) {
    const auto begin = std::chrono::steady_clock::now();
    if (!call()) throw std::runtime_error("Metal sample returned fallback");
    const auto end = std::chrono::steady_clock::now();
    samples.push_back(
        std::chrono::duration<double, std::milli>(end - begin).count());
  }
  return samples;
}

Result dense_cell(
    const char *name, int rows, bool large_batch,
    int warmups, int repeats, uint32_t seed) {
  Rng rng(seed);
  Q4Matrix weight(M, D, rng);
  std::vector<float> x(static_cast<size_t>(rows) * D);
  std::vector<float> output(static_cast<size_t>(rows) * M);
  for (float &value : x) value = rng.activation();
  ColiMetalTensor *tensor = nullptr;
  auto call = [&]() {
    if (large_batch)
      return coli_metal_gemm(
          output.data(), x.data(), weight.w(), weight.s(),
          Q4, rows, D, M) != 0;
    return coli_metal_matmul(
        &tensor, output.data(), x.data(), weight.w(), weight.s(),
        Q4, rows, D, M) != 0;
  };
  if (!call()) throw std::runtime_error("dense correctness call fell back");
  Error error;
  const int sample_rows[] = {0, rows / 2, rows - 1};
  const int sample_columns[] = {0, 1, 31, M / 2, M - 1};
  for (const int row : sample_rows) {
    for (const int column : sample_columns) {
      const float expected =
          weight.dot(column, x.data() + static_cast<size_t>(row) * D);
      error.add(output[static_cast<size_t>(row) * M + column], expected);
    }
  }
  const double tolerance = 1e-4;
  if (error.normalized() > tolerance)
    throw std::runtime_error(std::string(name) + " correctness mismatch");
  auto samples = benchmark(warmups, repeats, call);
  if (tensor) coli_metal_tensor_free(tensor);
  return {
    name,
    large_batch ? "coli_metal_gemm" : "coli_metal_matmul",
    "Q4 S=" + std::to_string(rows) + " I=6144 O=2048",
    error,
    tolerance,
    samples,
    median(samples),
  };
}

struct Expert {
  Q4Matrix gate;
  Q4Matrix up;
  Q4Matrix down;
  Expert(Rng &rng) : gate(M, D, rng), up(M, D, rng), down(D, M, rng) {}
};

float silu(float value) {
  return value / (1.0f + std::exp(-value));
}

Result moe_cell(
    const char *name, const std::vector<int> &counts, int output_rows,
    bool top8_rows, int warmups, int repeats, uint32_t seed) {
  Rng rng(seed);
  const int experts = static_cast<int>(counts.size());
  std::vector<Expert *> owned;
  for (int expert = 0; expert < experts; ++expert)
    owned.push_back(new Expert(rng));
  std::vector<const void *> gate(experts), up(experts), down(experts);
  std::vector<const float *> gate_scale(experts), up_scale(experts),
      down_scale(experts);
  std::vector<int> offsets(experts), rows_per_expert(counts);
  int total_rows = 0;
  for (int expert = 0; expert < experts; ++expert) {
    offsets[expert] = total_rows;
    total_rows += counts[expert];
    gate[expert] = owned[expert]->gate.w();
    up[expert] = owned[expert]->up.w();
    down[expert] = owned[expert]->down.w();
    gate_scale[expert] = owned[expert]->gate.s();
    up_scale[expert] = owned[expert]->up.s();
    down_scale[expert] = owned[expert]->down.s();
  }
  std::vector<float> x(static_cast<size_t>(total_rows) * D);
  std::vector<int> rows(total_rows);
  std::vector<float> route_weight(total_rows);
  for (float &value : x) value = rng.activation();
  for (int expert = 0; expert < experts; ++expert) {
    for (int local = 0; local < counts[expert]; ++local) {
      const int packed_row = offsets[expert] + local;
      rows[packed_row] =
          top8_rows ? local % output_rows : packed_row % output_rows;
      route_weight[packed_row] =
          0.1f + static_cast<float>(rng.next() % 101) / 100.0f;
    }
  }
  std::vector<float> output(static_cast<size_t>(output_rows) * D);
  auto call = [&]() {
    std::fill(output.begin(), output.end(), 0.0f);
    return coli_metal_moe_block(
        experts, D, M, Q4,
        gate.data(), up.data(), down.data(),
        gate_scale.data(), up_scale.data(), down_scale.data(),
        x.data(), offsets.data(), rows_per_expert.data(),
        rows.data(), route_weight.data(), output.data(), output_rows) != 0;
  };
  if (!call()) throw std::runtime_error("MoE correctness call fell back");

  // Reference one complete output row at representative hidden coordinates.
  // Gate/up are evaluated in full for every contribution to that row; only the
  // final down coordinates are sampled.
  const int reference_row = 0;
  const int sample_columns[] = {0, 1, 31, D / 2, D - 1};
  std::vector<float> expected(sizeof(sample_columns) / sizeof(int), 0.0f);
  std::vector<float> hidden(M);
  for (int expert = 0; expert < experts; ++expert) {
    for (int local = 0; local < counts[expert]; ++local) {
      const int packed_row = offsets[expert] + local;
      if (rows[packed_row] != reference_row) continue;
      const float *input = x.data() + static_cast<size_t>(packed_row) * D;
      for (int intermediate = 0; intermediate < M; ++intermediate) {
        const float gate_value = owned[expert]->gate.dot(intermediate, input);
        const float up_value = owned[expert]->up.dot(intermediate, input);
        hidden[intermediate] = silu(gate_value) * up_value;
      }
      for (size_t index = 0;
           index < sizeof(sample_columns) / sizeof(int); ++index) {
        expected[index] += route_weight[packed_row] *
            owned[expert]->down.dot(sample_columns[index], hidden.data());
      }
    }
  }
  Error error;
  for (size_t index = 0;
       index < sizeof(sample_columns) / sizeof(int); ++index) {
    error.add(
        output[static_cast<size_t>(reference_row) * D +
               sample_columns[index]],
        expected[index]);
  }
  const double tolerance = 2e-4;
  if (error.normalized() > tolerance)
    throw std::runtime_error(std::string(name) + " correctness mismatch");
  auto samples = benchmark(warmups, repeats, call);
  for (Expert *expert : owned) delete expert;
  return {
    name,
    "coli_metal_moe_block",
    "Q4 nb=" + std::to_string(experts) +
        " R=" + std::to_string(total_rows) +
        " S=" + std::to_string(output_rows) + " D=6144 M=2048",
    error,
    tolerance,
    samples,
    median(samples),
  };
}

void rmsnorm(
    float *output, const float *input, const float *weight,
    int width, float epsilon) {
  double square = 0.0;
  for (int index = 0; index < width; ++index)
    square += static_cast<double>(input[index]) * input[index];
  const float inverse =
      1.0f / std::sqrt(static_cast<float>(square / width) + epsilon);
  for (int index = 0; index < width; ++index)
    output[index] = input[index] * inverse * weight[index];
}

void rope(float *value, int position, float theta) {
  float input[ROPE];
  std::memcpy(input, value, sizeof(input));
  for (int index = 0; index < ROPE / 2; ++index) {
    const float inverse =
        std::pow(theta, -2.0f * index / static_cast<float>(ROPE));
    const float angle = position * inverse;
    const float a = input[2 * index];
    const float b = input[2 * index + 1];
    value[index] = a * std::cos(angle) - b * std::sin(angle);
    value[ROPE / 2 + index] =
        b * std::cos(angle) + a * std::sin(angle);
  }
}

Result mla_cell(
    int position, int warmups, int repeats, uint32_t seed) {
  Rng rng(seed);
  Q4Matrix qa(QLORA, D, rng);
  Q4Matrix qb(HEADS * QH, QLORA, rng);
  Q4Matrix kva(KVL + ROPE, D, rng);
  Q4Matrix kvb(HEADS * KVROWS, KVL, rng);
  Q4Matrix out_weight(D, HEADS * VH, rng);
  std::vector<float> qa_norm(QLORA), kva_norm(KVL);
  for (float &value : qa_norm) value = 0.5f + 0.5f * rng.activation();
  for (float &value : kva_norm) value = 0.5f + 0.5f * rng.activation();

  const int sequence = position + 1;
  Allocation latent_bytes(
      static_cast<size_t>(sequence) * KVL * sizeof(float));
  Allocation rope_bytes(
      static_cast<size_t>(sequence) * ROPE * sizeof(float));
  auto *latent = static_cast<float *>(latent_bytes.data);
  auto *rope_cache = static_cast<float *>(rope_bytes.data);
  for (int token = 0; token < position; ++token) {
    for (int index = 0; index < KVL; ++index)
      latent[static_cast<size_t>(token) * KVL + index] = rng.activation();
    for (int index = 0; index < ROPE; ++index)
      rope_cache[static_cast<size_t>(token) * ROPE + index] =
          rng.activation();
  }
  coli_metal_register(latent_bytes.data, latent_bytes.bytes);
  coli_metal_register(rope_bytes.data, rope_bytes.bytes);
  std::vector<float> input(D), output(D);
  for (float &value : input) value = rng.activation();

  // Exact CPU reference for the one-row absorbed MLA path.
  const float epsilon = 1e-5f;
  const float theta = 10000.0f;
  const float attention_scale = 1.0f / 16.0f;
  std::vector<float> query_low(QLORA), query(HEADS * QH),
      compressed(KVL + ROPE);
  for (int row = 0; row < QLORA; ++row)
    query_low[row] = qa.dot(row, input.data());
  rmsnorm(query_low.data(), query_low.data(), qa_norm.data(), QLORA, epsilon);
  for (int row = 0; row < HEADS * QH; ++row)
    query[row] = qb.dot(row, query_low.data());
  for (int head = 0; head < HEADS; ++head)
    rope(query.data() + head * QH + NOPE, position, theta);
  for (int row = 0; row < KVL + ROPE; ++row)
    compressed[row] = kva.dot(row, input.data());
  rmsnorm(
      latent + static_cast<size_t>(position) * KVL,
      compressed.data(), kva_norm.data(), KVL, epsilon);
  std::memcpy(
      rope_cache + static_cast<size_t>(position) * ROPE,
      compressed.data() + KVL, ROPE * sizeof(float));
  rope(
      rope_cache + static_cast<size_t>(position) * ROPE,
      position, theta);

  std::vector<float> context(HEADS * VH);
  for (int head = 0; head < HEADS; ++head) {
    std::vector<float> absorbed(KVL, 0.0f);
    const float *head_query = query.data() + head * QH;
    for (int dimension = 0; dimension < NOPE; ++dimension) {
      const int row = head * KVROWS + dimension;
      const float q = head_query[dimension];
      for (int index = 0; index < KVL; ++index)
        absorbed[index] += q * kvb.dequant(row, index);
    }
    std::vector<float> score(sequence);
    for (int token = 0; token < sequence; ++token) {
      float value = 0.0f;
      const float *token_latent =
          latent + static_cast<size_t>(token) * KVL;
      const float *token_rope =
          rope_cache + static_cast<size_t>(token) * ROPE;
      for (int index = 0; index < KVL; ++index)
        value += absorbed[index] * token_latent[index];
      for (int index = 0; index < ROPE; ++index)
        value += head_query[NOPE + index] * token_rope[index];
      score[token] = value * attention_scale;
    }
    const float maximum = *std::max_element(score.begin(), score.end());
    float total = 0.0f;
    for (float &value : score) {
      value = std::exp(value - maximum);
      total += value;
    }
    for (float &value : score) value /= total;
    std::vector<float> attended(KVL, 0.0f);
    for (int token = 0; token < sequence; ++token) {
      const float *token_latent =
          latent + static_cast<size_t>(token) * KVL;
      for (int index = 0; index < KVL; ++index)
        attended[index] += score[token] * token_latent[index];
    }
    for (int dimension = 0; dimension < VH; ++dimension)
      context[head * VH + dimension] =
          kvb.dot(head * KVROWS + NOPE + dimension, attended.data());
  }
  std::vector<float> reference(D);
  for (int row = 0; row < D; ++row)
    reference[row] = out_weight.dot(row, context.data());

  auto call = [&]() {
    return coli_metal_attn_decode(
        input.data(),
        qa.w(), qa.s(), Q4, qa_norm.data(),
        qb.w(), qb.s(), Q4,
        kva.w(), kva.s(), Q4, kva_norm.data(),
        kvb.w(), kvb.s(), Q4,
        out_weight.w(), out_weight.s(), Q4,
        latent, rope_cache, 1, position, 0,
        epsilon, theta, attention_scale, output.data()) != 0;
  };
  if (!call()) throw std::runtime_error("MLA correctness call fell back");
  Error error;
  for (int index = 0; index < D; ++index)
    error.add(output[index], reference[index]);
  const double tolerance = 2e-4;
  if (error.normalized() > tolerance)
    throw std::runtime_error("MLA decode correctness mismatch");
  auto samples = benchmark(warmups, repeats, call);
  coli_metal_unregister(latent_bytes.data);
  coli_metal_unregister(rope_bytes.data);
  return {
    "mla_decode_pos128",
    "coli_metal_attn_decode",
    "Q4 S=1 pos=" + std::to_string(position) +
        " hidden=6144 heads=64 kv_lora=512",
    error,
    tolerance,
    samples,
    median(samples),
  };
}

std::string escape(const std::string &value) {
  std::string out;
  for (const char character : value) {
    if (character == '\\' || character == '"') out.push_back('\\');
    out.push_back(character);
  }
  return out;
}

void write_report(
    const std::string &path, int warmups, int repeats,
    const std::vector<Result> &results) {
  size_t metal_used = 0, metal_limit = 0;
  coli_metal_mem_info(&metal_used, &metal_limit);
  std::ofstream output(path);
  if (!output) throw std::runtime_error("cannot open report output");
  output << "{\n"
         << "  \"schema_version\": 1,\n"
         << "  \"kind\": \"colibri_metal_g1_quiet_matrix\",\n"
         << "  \"performance_claim\": false,\n"
         << "  \"provenance\": {\n"
         << "    \"colibri_commit\": \"" << COLIBRI_PIN << "\",\n"
         << "    \"backend_metal_sha256\": \"" << COLIBRI_METAL_SHA256
         << "\",\n"
         << "    \"backend_header_sha256\": \"" << COLIBRI_HEADER_SHA256
         << "\",\n"
         << "    \"harness_sha256\": \"" << HARNESS_SHA256 << "\",\n"
         << "    \"compiler\": \"" << escape(__VERSION__) << "\"\n"
         << "  },\n"
         << "  \"method\": {\"warmups\": " << warmups
         << ", \"repeats\": " << repeats
         << ", \"statistic\": \"median_wall_ms\", "
            "\"inputs\": \"deterministic_xorshift32_colibri_q4\"},\n"
         << "  \"metal\": {\"current_allocated_bytes\": " << metal_used
         << ", \"recommended_working_set_bytes\": " << metal_limit << "},\n"
         << "  \"cells\": [\n";
  for (size_t index = 0; index < results.size(); ++index) {
    const Result &result = results[index];
    output << "    {\n"
           << "      \"name\": \"" << result.name << "\",\n"
           << "      \"operation\": \"" << result.operation << "\",\n"
           << "      \"shape\": \"" << result.shape << "\",\n"
           << "      \"correctness\": {\"checked\": " << result.error.checked
           << ", \"max_abs\": " << result.error.max_abs
           << ", \"max_reference\": " << result.error.max_reference
           << ", \"normalized_max_abs\": " << result.error.normalized()
           << ", \"tolerance\": " << result.tolerance << "},\n"
           << "      \"samples_ms\": [";
    for (size_t sample = 0; sample < result.samples_ms.size(); ++sample) {
      if (sample) output << ", ";
      output << result.samples_ms[sample];
    }
    output << "],\n"
           << "      \"median_ms\": " << result.median_ms << "\n"
           << "    }" << (index + 1 == results.size() ? "\n" : ",\n");
  }
  output << "  ],\n"
         << "  \"result\": \"pass\"\n"
         << "}\n";
}

int integer_arg(int argc, char **argv, const char *name, int fallback) {
  for (int index = 1; index + 1 < argc; ++index)
    if (std::strcmp(argv[index], name) == 0)
      return std::atoi(argv[index + 1]);
  return fallback;
}

std::string string_arg(
    int argc, char **argv, const char *name, const char *fallback) {
  for (int index = 1; index + 1 < argc; ++index)
    if (std::strcmp(argv[index], name) == 0) return argv[index + 1];
  return fallback;
}

}  // namespace

int main(int argc, char **argv) {
  const int warmups = integer_arg(argc, argv, "--warmups", 3);
  const int repeats = integer_arg(argc, argv, "--repeats", 11);
  const std::string output =
      string_arg(argc, argv, "--output", "colibri-metal-g1.json");
  if (warmups < 0 || repeats < 1) {
    std::fprintf(stderr, "warmups must be >=0 and repeats must be >=1\n");
    return 2;
  }
  try {
    if (!coli_metal_init()) throw std::runtime_error("Metal unavailable");
    std::vector<Result> results;
    results.push_back(
        dense_cell("dense_q4_decode", 1, false, warmups, repeats, 0x101u));
    results.push_back(
        dense_cell("dense_q4_prefill32", 32, true, warmups, repeats, 0x102u));
    results.push_back(moe_cell(
        "routed_swiglu_decode_top8",
        {1, 1, 1, 1, 1, 1, 1, 1}, 1, true,
        warmups, repeats, 0x201u));
    results.push_back(moe_cell(
        "routed_swiglu_ragged",
        {3, 1, 4, 2, 1, 5}, 8, false,
        warmups, repeats, 0x202u));
    results.push_back(moe_cell(
        "routed_swiglu_prefill8_top8",
        {8, 8, 8, 8, 8, 8, 8, 8}, 8, true,
        warmups, repeats, 0x203u));
    results.push_back(mla_cell(128, warmups, repeats, 0x301u));
    write_report(output, warmups, repeats, results);
    for (const Result &result : results)
      std::printf(
          "%-34s median=%9.3f ms nerr=%.3e\n",
          result.name.c_str(), result.median_ms,
          result.error.normalized());
    std::printf("report: %s\n", output.c_str());
    coli_metal_shutdown();
    return 0;
  } catch (const std::exception &error) {
    std::fprintf(stderr, "colibri Metal G1 matrix failed: %s\n", error.what());
    coli_metal_shutdown();
    return 1;
  }
}
