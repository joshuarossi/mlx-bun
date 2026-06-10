// Minimal dylib for bun:ffi f64-arg corruption repro.
// Target function mirrors mlx-c's mlx_arange signature:
//   int mlx_arange(mlx_array* res, double start, double stop, double step,
//                  mlx_dtype dtype, mlx_stream s)
// Here it just echoes its arguments back through `out` so the JS side can
// detect corruption, and returns a bitmask of which doubles arrived as NaN.

#include <stdint.h>
#include <math.h>
#include <stdbool.h>

int32_t echo_f64(double *out, double a, double b, double c, int32_t n, uint64_t s) {
  out[0] = a;
  out[1] = b;
  out[2] = c;
  out[3] = (double)n;
  out[4] = (double)s;
  return (isnan(a) ? 1 : 0) | (isnan(b) ? 2 : 0) | (isnan(c) ? 4 : 0);
}

// Filler symbols with varied signatures, shaped like the rest of an mlx-c
// binding surface (out-ptr + u64 handles + scalar + u64 stream, etc.).
int32_t f_add_i32(int32_t a, int32_t b) { return a + b; }
int64_t f_add_i64(int64_t a, int64_t b) { return a + b; }
double  f_add_f64(double a, double b) { return a + b; }
float   f_mul_f32(float a, float b) { return a * b; }
uint64_t f_xor_u64(uint64_t a, uint64_t b) { return a ^ b; }
int32_t f_unary(void *o, uint64_t h, uint64_t s) { return o && h && s ? 0 : 1; }
int32_t f_binary(void *o, uint64_t a, uint64_t b, uint64_t s) { return 0; }
int32_t f_axis(void *o, uint64_t h, int32_t axis, uint64_t s) { return axis; }
int32_t f_axis_bool(void *o, uint64_t h, int32_t axis, bool keep, uint64_t s) { return keep ? axis : 0; }
int32_t f_scalar_f32(void *o, uint64_t h, float eps, uint64_t s) { return (int32_t)eps; }
int32_t f_cstr(void *o, const char *m, uint64_t s) { return m ? 1 : 0; }
int32_t f_wide(void *o, uint64_t a, uint64_t b, uint64_t c, uint64_t d, bool t,
               uint64_t g, uint64_t bits, const char *mode, uint64_t s) { return t ? 0 : 1; }
void   *f_ptr_id(void *p) { return p; }

// Signature-shape bisect helpers: echo args into out, varied shapes.
int32_t echo_p_f64(double *out, double a) { out[0] = a; return 0; }
int32_t echo_p_i32(double *out, int32_t a) { out[0] = (double)a; return 0; }
int32_t echo_p_u64(double *out, uint64_t a) { out[0] = (double)a; return 0; }
int32_t echo_p_2f64(double *out, double a, double b) { out[0] = a; out[1] = b; return 0; }
int32_t echo_p_f64_u64(double *out, double a, uint64_t s) { out[0] = a; out[1] = (double)s; return 0; }
int32_t echo_p_5i(double *out, int32_t a, int32_t b, int32_t c, int32_t n, int32_t s) {
  out[0] = a; out[1] = b; out[2] = c; out[3] = n; out[4] = s; return 0;
}
int32_t echo_p_5f(double *out, double a, double b, double c, double d, double e) {
  out[0] = a; out[1] = b; out[2] = c; out[3] = d; out[4] = e; return 0;
}
double echo_r_f64(double a) { return a; }

// Truth test: returns the arg (rounded) so staleness can be detected
// without reading memory the native call wrote.
int32_t echo_ret(double *out, double a) { out[0] = a; return (int32_t)a; }
