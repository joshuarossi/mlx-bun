// Positioned reads for CheckpointFileRead.readRange (Lean core has no seek).
// Trusted host input: compiled with leanc into the runner dylib; check_sound
// assumes the returned bytes are the file bytes at [offset, offset+length).
// Prototypes are declared here because the bundled clang has no libc headers.
#include <lean/lean.h>
extern int open(const char *, int, ...);
extern long pread(int, void *, size_t, long long);
extern int close(int);
LEAN_EXPORT lean_obj_res mlx_bun_read_range(b_lean_obj_arg path, uint64_t offset, size_t length) {
  int fd = open(lean_string_cstr(path), 0);
  if (fd < 0) return lean_io_result_mk_error(lean_mk_io_user_error(lean_mk_string("open failed")));
  lean_object *out = lean_alloc_sarray(1, length, length);
  size_t done = 0;
  while (done < length) {
    long got = pread(fd, lean_sarray_cptr(out) + done, length - done, (long long)(offset + done));
    if (got <= 0) break;
    done += (size_t)got;
  }
  close(fd);
  if (done != length) { lean_dec(out); return lean_io_result_mk_error(lean_mk_io_user_error(lean_mk_string("short read"))); }
  return lean_io_result_mk_ok(out);
}
