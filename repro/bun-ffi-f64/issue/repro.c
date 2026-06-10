// cc -O2 -shared -o librepro.dylib repro.c
#include <stdint.h>

// Writes `a` into out[0]; returns (int32_t)b so the caller can verify the
// arguments arrived intact without reading memory.
int32_t write_and_check(double *out, double a, double b, double c, int32_t n, uint64_t s) {
  out[0] = a;
  return (int32_t)b;
}

// Ground truth: what does the memory at `out` actually contain right now?
double read_mem(double *out) { return out[0]; }
