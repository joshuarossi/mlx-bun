#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <unistd.h>
#ifdef __APPLE__
#include <mach/mach.h>
#endif

typedef struct expert_io_pool expert_io_pool;
#define EXPERT_IO_MAX_SEGMENTS 8
typedef struct {
  uint32_t slot, segment_count;
  uint64_t generation;
  uint32_t file_index[EXPERT_IO_MAX_SEGMENTS];
  uint64_t offset[EXPERT_IO_MAX_SEGMENTS];
  uint64_t destination[EXPERT_IO_MAX_SEGMENTS];
  uint64_t length[EXPERT_IO_MAX_SEGMENTS];
} io_job;
typedef struct { void *data; uint64_t generation, capacity, length; int state, error, cancelled, gpu_lease; } io_slot;

struct expert_io_pool {
  int stopping;
  uint32_t file_count, slot_count, worker_count, qcap, qhead, qtail, qlen;
  int mu_init, work_init, changed_init;
  int *fds;
  io_slot *slots;
  io_job *queue;
  pthread_t *workers;
  pthread_mutex_t mu;
  pthread_cond_t work, changed;
};

enum { SLOT_IDLE = 0, SLOT_LOADING = 1, SLOT_READY = 2, SLOT_LEASED = 3 };

static int pread_full(int fd, void *dst, uint64_t length, uint64_t offset) {
  uint8_t *p = dst;
  while (length) {
    size_t ask = length > (uint64_t)SSIZE_MAX ? (size_t)SSIZE_MAX : (size_t)length;
    ssize_t n = pread(fd, p, ask, (off_t)offset);
    if (n < 0 && errno == EINTR) continue;
    if (n < 0) return errno;
    if (n == 0) return ENODATA;
    p += n; offset += (uint64_t)n; length -= (uint64_t)n;
  }
  return 0;
}

static void *worker_main(void *arg) {
  expert_io_pool *p = arg;
  for (;;) {
    pthread_mutex_lock(&p->mu);
    while (!p->stopping && p->qlen == 0) pthread_cond_wait(&p->work, &p->mu);
    if (p->stopping && p->qlen == 0) { pthread_mutex_unlock(&p->mu); return NULL; }
    io_job job = p->queue[p->qhead];
    p->qhead = (p->qhead + 1) % p->qcap; p->qlen--;
    io_slot *slot = &p->slots[job.slot];
    pthread_mutex_unlock(&p->mu);
    int error = 0;
    uint64_t extent = 0;
    for (uint32_t i = 0; i < job.segment_count && !error; i++) {
      error = pread_full(
        p->fds[job.file_index[i]],
        (uint8_t *)slot->data + job.destination[i],
        job.length[i],
        job.offset[i]
      );
      uint64_t end = job.destination[i] + job.length[i];
      if (end > extent) extent = end;
    }
    pthread_mutex_lock(&p->mu);
    if (slot->generation == job.generation && slot->state == SLOT_LOADING) {
      slot->error = slot->cancelled ? ECANCELED : error;
      slot->length = slot->error ? 0 : extent; slot->state = SLOT_READY;
    }
    pthread_cond_broadcast(&p->changed);
    pthread_mutex_unlock(&p->mu);
  }
}

static expert_io_pool *open_pool(const char *const *paths, uint32_t file_count,
                                 uint32_t slots, uint64_t capacity,
                                 uint64_t alignment, uint32_t workers, int no_cache) {
  if (!paths || !file_count || !slots || slots > UINT32_MAX / 2 || !capacity ||
      !workers || workers > 64 || alignment < sizeof(void *) ||
      (alignment & (alignment - 1))) { errno = EINVAL; return NULL; }
  expert_io_pool *p = calloc(1, sizeof(*p));
  if (!p) return NULL;
  p->file_count = file_count;
  p->fds = malloc((size_t)file_count * sizeof(*p->fds));
  if (!p->fds) { free(p); return NULL; }
  for (uint32_t i = 0; i < file_count; i++) p->fds[i] = -1;
  for (uint32_t i = 0; i < file_count; i++) {
    if (!paths[i] || !paths[i][0]) { errno = EINVAL; goto fail; }
    p->fds[i] = open(paths[i], O_RDONLY);
    if (p->fds[i] < 0) goto fail;
#ifdef F_NOCACHE
    if (no_cache && fcntl(p->fds[i], F_NOCACHE, 1) != 0) goto fail;
#else
    (void)no_cache;
#endif
  }
  p->slot_count = slots; p->qcap = slots * 2;
  p->slots = calloc(slots, sizeof(*p->slots)); p->queue = calloc(p->qcap, sizeof(*p->queue));
  p->workers = calloc(workers, sizeof(*p->workers));
  if (!p->slots || !p->queue || !p->workers) goto fail;
  if (pthread_mutex_init(&p->mu, NULL)) goto fail; p->mu_init = 1;
  if (pthread_cond_init(&p->work, NULL)) goto fail_started; p->work_init = 1;
  if (pthread_cond_init(&p->changed, NULL)) goto fail_started; p->changed_init = 1;
  for (uint32_t i = 0; i < slots; i++) {
    if (posix_memalign(&p->slots[i].data, (size_t)alignment, (size_t)capacity)) goto fail_started;
    p->slots[i].capacity = capacity;
  }
  for (uint32_t i = 0; i < workers; i++) {
    if (pthread_create(&p->workers[i], NULL, worker_main, p)) goto fail_started;
    p->worker_count++;
  }
  return p;
fail_started:
  if (p->mu_init) {
    pthread_mutex_lock(&p->mu); p->stopping = 1;
    if (p->work_init) pthread_cond_broadcast(&p->work);
    pthread_mutex_unlock(&p->mu);
  }
  for (uint32_t i = 0; i < p->worker_count; i++) pthread_join(p->workers[i], NULL);
  if (p->changed_init) pthread_cond_destroy(&p->changed);
  if (p->work_init) pthread_cond_destroy(&p->work);
  if (p->mu_init) pthread_mutex_destroy(&p->mu);
fail:
  if (p->slots) for (uint32_t i = 0; i < slots; i++) free(p->slots[i].data);
  free(p->workers); free(p->queue); free(p->slots);
  if (p->fds) for (uint32_t i = 0; i < file_count; i++) if (p->fds[i] >= 0) close(p->fds[i]);
  free(p->fds); free(p); return NULL;
}

expert_io_pool *mlx_bun_expert_io_open(const char *path, uint32_t slots, uint64_t capacity,
                                        uint64_t alignment, uint32_t workers, int no_cache) {
  const char *paths[1] = {path};
  return open_pool(paths, 1, slots, capacity, alignment, workers, no_cache);
}

expert_io_pool *mlx_bun_expert_io_open_many(const char *path_blob, uint64_t path_blob_length,
                                             uint32_t file_count, uint32_t slots,
                                             uint64_t capacity, uint64_t alignment,
                                             uint32_t workers, int no_cache) {
  if (!path_blob || !path_blob_length || !file_count ||
      path_blob_length > (uint64_t)SIZE_MAX) { errno = EINVAL; return NULL; }
  const char **paths = calloc(file_count, sizeof(*paths));
  if (!paths) return NULL;
  uint64_t cursor = 0;
  int valid = 1;
  for (uint32_t i = 0; i < file_count; i++) {
    if (cursor >= path_blob_length) { valid = 0; break; }
    paths[i] = path_blob + cursor;
    size_t remaining = (size_t)(path_blob_length - cursor);
    size_t length = strnlen(paths[i], remaining);
    if (length == 0 || length == remaining) { valid = 0; break; }
    cursor += (uint64_t)length + 1;
  }
  if (cursor != path_blob_length) valid = 0;
  expert_io_pool *pool = valid
    ? open_pool(paths, file_count, slots, capacity, alignment, workers, no_cache)
    : NULL;
  free(paths);
  if (!valid) errno = EINVAL;
  return pool;
}

int mlx_bun_expert_io_submitv(expert_io_pool *p, uint32_t slot_id, uint64_t generation,
                              const uint32_t *file_index, const uint64_t *offset,
                              const uint64_t *destination, const uint64_t *length,
                              uint32_t segment_count) {
  if (!p || slot_id >= p->slot_count || !generation || !file_index || !offset ||
      !destination || !length || !segment_count ||
      segment_count > EXPERT_IO_MAX_SEGMENTS) return EINVAL;
  uint64_t extent = 0;
  for (uint32_t i = 0; i < segment_count; i++) {
    if (file_index[i] >= p->file_count || !length[i]) return EINVAL;
    if (offset[i] > INT64_MAX || length[i] > (uint64_t)INT64_MAX - offset[i])
      return EOVERFLOW;
    if (destination[i] > p->slots[slot_id].capacity ||
        length[i] > p->slots[slot_id].capacity - destination[i]) return EBUSY;
    uint64_t end = destination[i] + length[i];
    if (end > extent) extent = end;
    for (uint32_t prior = 0; prior < i; prior++) {
      uint64_t prior_end = destination[prior] + length[prior];
      if (destination[i] < prior_end && destination[prior] < end) return EINVAL;
    }
  }
  pthread_mutex_lock(&p->mu);
  io_slot *slot = &p->slots[slot_id];
  int error = 0;
  if (extent > slot->capacity || slot->state == SLOT_LOADING || slot->state == SLOT_LEASED) error = EBUSY;
  else if (p->qlen == p->qcap) error = EAGAIN;
  else {
    slot->generation = generation; slot->length = 0; slot->error = 0; slot->cancelled = 0; slot->state = SLOT_LOADING;
    io_job *job = &p->queue[p->qtail];
    memset(job, 0, sizeof(*job));
    job->slot = slot_id; job->generation = generation; job->segment_count = segment_count;
    for (uint32_t i = 0; i < segment_count; i++) {
      job->file_index[i] = file_index[i];
      job->offset[i] = offset[i];
      job->destination[i] = destination[i];
      job->length[i] = length[i];
    }
    p->qtail = (p->qtail + 1) % p->qcap; p->qlen++;
    pthread_cond_signal(&p->work);
  }
  pthread_mutex_unlock(&p->mu); return error;
}

int mlx_bun_expert_io_submit(expert_io_pool *p, uint32_t slot_id, uint64_t generation,
                             uint64_t offset, uint64_t length) {
  const uint32_t file_index[1] = {0};
  const uint64_t destination[1] = {0};
  return mlx_bun_expert_io_submitv(
    p, slot_id, generation, file_index, &offset, destination, &length, 1
  );
}

int mlx_bun_expert_io_cancel(expert_io_pool *p, uint32_t slot_id, uint64_t generation) {
  if (!p || slot_id >= p->slot_count) return EINVAL;
  pthread_mutex_lock(&p->mu); io_slot *s = &p->slots[slot_id];
  int error = s->generation != generation ? ESTALE : 0;
  if (!error && s->state == SLOT_LOADING) s->cancelled = 1;
  else if (!error && s->state == SLOT_READY) { s->error = ECANCELED; s->length = 0; }
  else if (!error) error = EBUSY;
  pthread_mutex_unlock(&p->mu); return error;
}

int mlx_bun_expert_io_wait(expert_io_pool *p, uint32_t slot_id, uint64_t generation) {
  if (!p || slot_id >= p->slot_count) return EINVAL;
  pthread_mutex_lock(&p->mu); io_slot *slot = &p->slots[slot_id];
  while (slot->generation == generation && slot->state == SLOT_LOADING) pthread_cond_wait(&p->changed, &p->mu);
  int error = slot->generation != generation ? ESTALE : slot->error;
  pthread_mutex_unlock(&p->mu); return error;
}

int mlx_bun_expert_io_poll(expert_io_pool *p, uint32_t slot_id, uint64_t generation) {
  if (!p || slot_id >= p->slot_count) return EINVAL;
  pthread_mutex_lock(&p->mu); io_slot *slot = &p->slots[slot_id];
  int result = slot->generation != generation ? ESTALE : slot->state == SLOT_LOADING ? EAGAIN : slot->error;
  pthread_mutex_unlock(&p->mu); return result;
}

int mlx_bun_expert_io_lease(expert_io_pool *p, uint32_t slot_id, uint64_t generation, int gpu) {
  if (!p || slot_id >= p->slot_count) return EINVAL;
  pthread_mutex_lock(&p->mu); io_slot *s = &p->slots[slot_id];
  int error = s->generation != generation ? ESTALE : s->state != SLOT_READY || s->error ? EBUSY : 0;
  if (!error) { s->state = SLOT_LEASED; s->gpu_lease = gpu != 0; }
  pthread_mutex_unlock(&p->mu); return error;
}

int mlx_bun_expert_io_release(expert_io_pool *p, uint32_t slot_id, uint64_t generation, int gpu_fenced) {
  if (!p || slot_id >= p->slot_count) return EINVAL;
  pthread_mutex_lock(&p->mu); io_slot *s = &p->slots[slot_id];
  int error = s->generation != generation ? ESTALE : s->state != SLOT_LEASED ? EINVAL :
              s->gpu_lease && !gpu_fenced ? EBUSY : 0;
  if (!error) { s->state = SLOT_READY; s->gpu_lease = 0; }
  pthread_mutex_unlock(&p->mu); return error;
}

int mlx_bun_expert_io_discard(expert_io_pool *p, uint32_t slot_id, uint64_t generation) {
  if (!p || slot_id >= p->slot_count || !generation) return EINVAL;
  pthread_mutex_lock(&p->mu); io_slot *s = &p->slots[slot_id];
  int error = s->generation != generation ? ESTALE :
              s->state != SLOT_READY ? EBUSY : 0;
  if (!error && madvise(s->data, (size_t)s->capacity, MADV_DONTNEED) != 0)
    error = errno;
  if (!error) {
    s->state = SLOT_IDLE;
    s->length = 0;
    s->error = 0;
    s->cancelled = 0;
    s->gpu_lease = 0;
  }
  pthread_mutex_unlock(&p->mu); return error;
}

uint64_t mlx_bun_process_phys_footprint(void) {
#ifdef __APPLE__
  task_vm_info_data_t info;
  mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
  kern_return_t status = task_info(
    mach_task_self(), TASK_VM_INFO, (task_info_t)&info, &count
  );
  if (status == KERN_SUCCESS) return (uint64_t)info.phys_footprint;
#endif
  struct rusage usage;
  if (getrusage(RUSAGE_SELF, &usage) != 0) return 0;
#ifdef __APPLE__
  return (uint64_t)usage.ru_maxrss;
#else
  return (uint64_t)usage.ru_maxrss * 1024;
#endif
}

void *mlx_bun_expert_io_ptr(expert_io_pool *p, uint32_t slot_id, uint64_t generation) {
  if (!p || slot_id >= p->slot_count) return NULL;
  pthread_mutex_lock(&p->mu); io_slot *s = &p->slots[slot_id];
  void *result = s->state == SLOT_LEASED && s->generation == generation ? s->data : NULL;
  pthread_mutex_unlock(&p->mu); return result;
}
uint64_t mlx_bun_expert_io_length(expert_io_pool *p, uint32_t slot_id, uint64_t generation) {
  if (!p || slot_id >= p->slot_count) return 0;
  pthread_mutex_lock(&p->mu); io_slot *s = &p->slots[slot_id];
  uint64_t result = s->state == SLOT_LEASED && s->generation == generation ? s->length : 0;
  pthread_mutex_unlock(&p->mu); return result;
}

int mlx_bun_expert_io_close(expert_io_pool *p) {
  if (!p) return 0;
  pthread_mutex_lock(&p->mu);
  for (uint32_t i = 0; i < p->slot_count; i++) if (p->slots[i].state == SLOT_LEASED) {
    pthread_mutex_unlock(&p->mu); return EBUSY;
  }
  pthread_mutex_unlock(&p->mu);
  pthread_mutex_lock(&p->mu); p->stopping = 1; pthread_cond_broadcast(&p->work); pthread_mutex_unlock(&p->mu);
  for (uint32_t i = 0; i < p->worker_count; i++) pthread_join(p->workers[i], NULL);
  for (uint32_t i = 0; i < p->slot_count; i++) free(p->slots[i].data);
  pthread_cond_destroy(&p->changed); pthread_cond_destroy(&p->work); pthread_mutex_destroy(&p->mu);
  for (uint32_t i = 0; i < p->file_count; i++) close(p->fds[i]);
  free(p->fds); free(p->workers); free(p->queue); free(p->slots); free(p); return 0;
}
