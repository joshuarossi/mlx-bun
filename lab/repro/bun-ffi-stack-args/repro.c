#include <stdint.h>
// exact mlx_conv2d shape: (ptr, u64, u64, int×7, u64) -> int
int conv2d_echo(int64_t* res, uint64_t a, uint64_t b, int s0, int s1,
                int p0, int p1, int d0, int d1, int g, uint64_t st) {
  res[0]=(int64_t)a; res[1]=(int64_t)b; res[2]=s0; res[3]=s1; res[4]=p0;
  res[5]=p1; res[6]=d0; res[7]=d1; res[8]=g; res[9]=(int64_t)st;
  return 42;
}

// exact mlx_conv3d shape: (ptr, u64, u64, int×10, u64) -> int
int conv3d_echo(int64_t* res, uint64_t a, uint64_t b,
                int s0, int s1, int s2, int p0, int p1, int p2,
                int d0, int d1, int d2, int g, uint64_t st) {
  res[0]=(int64_t)a; res[1]=(int64_t)b; res[2]=s0; res[3]=s1; res[4]=s2;
  res[5]=p0; res[6]=p1; res[7]=p2; res[8]=d0; res[9]=d1; res[10]=d2;
  res[11]=g; res[12]=(int64_t)st;
  return 43;
}
