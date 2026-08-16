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
#define EXPERT_IO_HINT_QUEUE_CAP 4096
#define EXPERT_IO_HINT_STATS 8
typedef struct {
  uint32_t slot, segment_count;
  uint64_t generation;
  uint32_t file_index[EXPERT_IO_MAX_SEGMENTS];
  uint64_t offset[EXPERT_IO_MAX_SEGMENTS];
  uint64_t destination[EXPERT_IO_MAX_SEGMENTS];
  uint64_t length[EXPERT_IO_MAX_SEGMENTS];
} io_job;
typedef struct {
  uint32_t segment_count;
  uint32_t file_index[EXPERT_IO_MAX_SEGMENTS];
  uint64_t offset[EXPERT_IO_MAX_SEGMENTS];
  uint64_t length[EXPERT_IO_MAX_SEGMENTS];
} io_hint_job;
typedef struct {
  void *data;
  uint64_t generation, capacity, length;
  int state, error, cancelled, gpu_lease, wired;
} io_slot;

struct expert_io_pool {
  int stopping;
  int wire_slots;
  uint32_t file_count, slot_count, worker_count, qcap, qhead, qtail, qlen;
  uint32_t hint_qcap, hint_qhead, hint_qtail, hint_qlen, hint_inflight;
  int mu_init, work_init, changed_init, hint_work_init, hint_worker_started;
  int *fds;
  int *hint_fds;
  io_slot *slots;
  io_job *queue;
  io_hint_job *hint_queue;
  pthread_t *workers;
  pthread_t hint_worker;
  pthread_mutex_t mu;
  pthread_cond_t work, changed, hint_work;
  uint64_t hint_submitted, hint_completed, hint_dropped;
  uint64_t hint_operations, hint_bytes, hint_errors;
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

static int advise_willneed(int fd, uint64_t offset, uint64_t length) {
#ifdef __APPLE__
  while (length) {
    int chunk = length > (uint64_t)INT_MAX ? INT_MAX : (int)length;
    struct radvisory advice;
    advice.ra_offset = (off_t)offset;
    advice.ra_count = chunk;
    if (fcntl(fd, F_RDADVISE, &advice) != 0) return errno;
    offset += (uint64_t)chunk;
    length -= (uint64_t)chunk;
  }
  return 0;
#elif defined(POSIX_FADV_WILLNEED)
  int status = posix_fadvise(fd, (off_t)offset, (off_t)length,
                             POSIX_FADV_WILLNEED);
  return status;
#else
  (void)fd; (void)offset; (void)length;
  return 0;
#endif
}

static void *hint_worker_main(void *arg) {
  expert_io_pool *p = arg;
  for (;;) {
    pthread_mutex_lock(&p->mu);
    while (!p->stopping && p->hint_qlen == 0)
      pthread_cond_wait(&p->hint_work, &p->mu);
    if (p->stopping) { pthread_mutex_unlock(&p->mu); return NULL; }
    io_hint_job job = p->hint_queue[p->hint_qhead];
    p->hint_qhead = (p->hint_qhead + 1) % p->hint_qcap;
    p->hint_qlen--;
    p->hint_inflight = 1;
    pthread_mutex_unlock(&p->mu);

    int error = 0;
    for (uint32_t i = 0; i < job.segment_count && !error; i++) {
      error = advise_willneed(
        p->hint_fds[job.file_index[i]], job.offset[i], job.length[i]
      );
    }

    pthread_mutex_lock(&p->mu);
    p->hint_completed++;
    if (error) p->hint_errors++;
    p->hint_inflight = 0;
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
  p->hint_fds = malloc((size_t)file_count * sizeof(*p->hint_fds));
  if (!p->fds || !p->hint_fds) {
    free(p->hint_fds); free(p->fds); free(p); return NULL;
  }
  for (uint32_t i = 0; i < file_count; i++) {
    p->fds[i] = -1;
    p->hint_fds[i] = -1;
  }
  for (uint32_t i = 0; i < file_count; i++) {
    if (!paths[i] || !paths[i][0]) { errno = EINVAL; goto fail; }
    p->fds[i] = open(paths[i], O_RDONLY);
    if (p->fds[i] < 0) goto fail;
    p->hint_fds[i] = open(paths[i], O_RDONLY);
    if (p->hint_fds[i] < 0) goto fail;
#ifdef F_NOCACHE
    if (no_cache && fcntl(p->fds[i], F_NOCACHE, 1) != 0) goto fail;
#else
    (void)no_cache;
#endif
  }
  p->slot_count = slots; p->qcap = slots * 2;
  p->hint_qcap = EXPERT_IO_HINT_QUEUE_CAP;
  p->slots = calloc(slots, sizeof(*p->slots)); p->queue = calloc(p->qcap, sizeof(*p->queue));
  p->hint_queue = calloc(p->hint_qcap, sizeof(*p->hint_queue));
  p->workers = calloc(workers, sizeof(*p->workers));
  if (!p->slots || !p->queue || !p->hint_queue || !p->workers) goto fail;
  if (pthread_mutex_init(&p->mu, NULL)) goto fail; p->mu_init = 1;
  if (pthread_cond_init(&p->work, NULL)) goto fail_started; p->work_init = 1;
  if (pthread_cond_init(&p->changed, NULL)) goto fail_started; p->changed_init = 1;
  if (pthread_cond_init(&p->hint_work, NULL)) goto fail_started; p->hint_work_init = 1;
  for (uint32_t i = 0; i < slots; i++) {
    if (posix_memalign(&p->slots[i].data, (size_t)alignment, (size_t)capacity)) goto fail_started;
    p->slots[i].capacity = capacity;
  }
  for (uint32_t i = 0; i < workers; i++) {
    if (pthread_create(&p->workers[i], NULL, worker_main, p)) goto fail_started;
    p->worker_count++;
  }
  if (pthread_create(&p->hint_worker, NULL, hint_worker_main, p))
    goto fail_started;
  p->hint_worker_started = 1;
  return p;
fail_started:
  if (p->mu_init) {
    pthread_mutex_lock(&p->mu); p->stopping = 1;
    if (p->work_init) pthread_cond_broadcast(&p->work);
    if (p->hint_work_init) pthread_cond_broadcast(&p->hint_work);
    pthread_mutex_unlock(&p->mu);
  }
  for (uint32_t i = 0; i < p->worker_count; i++) pthread_join(p->workers[i], NULL);
  if (p->hint_worker_started) pthread_join(p->hint_worker, NULL);
  if (p->hint_work_init) pthread_cond_destroy(&p->hint_work);
  if (p->changed_init) pthread_cond_destroy(&p->changed);
  if (p->work_init) pthread_cond_destroy(&p->work);
  if (p->mu_init) pthread_mutex_destroy(&p->mu);
fail:
  if (p->slots) for (uint32_t i = 0; i < slots; i++) free(p->slots[i].data);
  free(p->workers); free(p->hint_queue); free(p->queue); free(p->slots);
  if (p->fds) for (uint32_t i = 0; i < file_count; i++) if (p->fds[i] >= 0) close(p->fds[i]);
  if (p->hint_fds) for (uint32_t i = 0; i < file_count; i++) if (p->hint_fds[i] >= 0) close(p->hint_fds[i]);
  free(p->hint_fds); free(p->fds); free(p); return NULL;
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
    if (p->wire_slots && !slot->wired) {
      if (mlock(slot->data, (size_t)slot->capacity) != 0) error = errno;
      else slot->wired = 1;
    }
  }
  if (!error) {
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

int mlx_bun_expert_io_hintv(expert_io_pool *p,
                            const uint32_t *file_index,
                            const uint64_t *offset,
                            const uint64_t *length,
                            uint32_t segment_count) {
  if (!p || !file_index || !offset || !length || !segment_count ||
      segment_count > EXPERT_IO_MAX_SEGMENTS) return EINVAL;
  uint64_t bytes = 0;
  for (uint32_t i = 0; i < segment_count; i++) {
    if (file_index[i] >= p->file_count || !length[i]) return EINVAL;
    if (offset[i] > INT64_MAX || length[i] > (uint64_t)INT64_MAX - offset[i])
      return EOVERFLOW;
    if (bytes > UINT64_MAX - length[i]) return EOVERFLOW;
    bytes += length[i];
  }

  pthread_mutex_lock(&p->mu);
  int error = 0;
  if (p->stopping) error = ECANCELED;
  else if (p->hint_qlen == p->hint_qcap) {
    p->hint_dropped++;
    error = EAGAIN;
  } else {
    io_hint_job *job = &p->hint_queue[p->hint_qtail];
    memset(job, 0, sizeof(*job));
    job->segment_count = segment_count;
    for (uint32_t i = 0; i < segment_count; i++) {
      job->file_index[i] = file_index[i];
      job->offset[i] = offset[i];
      job->length[i] = length[i];
    }
    p->hint_qtail = (p->hint_qtail + 1) % p->hint_qcap;
    p->hint_qlen++;
    p->hint_submitted++;
    p->hint_operations += segment_count;
    p->hint_bytes += bytes;
    pthread_cond_signal(&p->hint_work);
  }
  pthread_mutex_unlock(&p->mu);
  return error;
}

int mlx_bun_expert_io_hint_stats(expert_io_pool *p, uint64_t *out,
                                 uint32_t count) {
  if (!p || !out || count < EXPERT_IO_HINT_STATS) return EINVAL;
  pthread_mutex_lock(&p->mu);
  out[0] = p->hint_submitted;
  out[1] = p->hint_completed;
  out[2] = p->hint_dropped;
  out[3] = p->hint_operations;
  out[4] = p->hint_bytes;
  out[5] = p->hint_errors;
  out[6] = p->hint_qlen;
  out[7] = p->hint_inflight;
  pthread_mutex_unlock(&p->mu);
  return 0;
}

int mlx_bun_expert_io_set_wiring(expert_io_pool *p, int enabled) {
  if (!p) return EINVAL;
  pthread_mutex_lock(&p->mu);
  int error = 0;
  if (p->qlen != 0) error = EBUSY;
  for (uint32_t i = 0; i < p->slot_count && !error; i++) {
    if (p->slots[i].state == SLOT_LOADING ||
        p->slots[i].state == SLOT_LEASED) error = EBUSY;
  }
  if (!error) p->wire_slots = enabled != 0;
  pthread_mutex_unlock(&p->mu);
  return error;
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
  if (!error && s->wired) {
    if (munlock(s->data, (size_t)s->capacity) != 0) error = errno;
    else s->wired = 0;
  }
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

uint64_t mlx_bun_process_compressed(void) {
#ifdef __APPLE__
  task_vm_info_data_t info;
  mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
  kern_return_t status = task_info(
    mach_task_self(), TASK_VM_INFO, (task_info_t)&info, &count
  );
  if (status == KERN_SUCCESS) return (uint64_t)info.compressed;
#endif
  return 0;
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
  pthread_mutex_lock(&p->mu);
  p->stopping = 1;
  pthread_cond_broadcast(&p->work);
  pthread_cond_broadcast(&p->hint_work);
  pthread_mutex_unlock(&p->mu);
  for (uint32_t i = 0; i < p->worker_count; i++) pthread_join(p->workers[i], NULL);
  if (p->hint_worker_started) pthread_join(p->hint_worker, NULL);
  for (uint32_t i = 0; i < p->slot_count; i++) {
    if (p->slots[i].wired)
      (void)munlock(p->slots[i].data, (size_t)p->slots[i].capacity);
    free(p->slots[i].data);
  }
  pthread_cond_destroy(&p->hint_work); pthread_cond_destroy(&p->changed);
  pthread_cond_destroy(&p->work); pthread_mutex_destroy(&p->mu);
  for (uint32_t i = 0; i < p->file_count; i++) close(p->fds[i]);
  for (uint32_t i = 0; i < p->file_count; i++) close(p->hint_fds[i]);
  free(p->hint_fds); free(p->fds); free(p->workers); free(p->hint_queue);
  free(p->queue); free(p->slots); free(p); return 0;
}
