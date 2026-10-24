import metal.Group
import metal.kernels.DownFold

namespace Metal.Group.Tests
open Core Inference.Contracts.Mlx

/-! # SIMD-group, threadgroup and launch lemmas on concrete launches

Down-fold's launch (grid 40960, threadgroup 256): its SIMD-groups, lanes and
bounds, and its GPU theorem through `gpu_execute`. The launch shapes of
residual-rms-norm (1024 by 1024, two threadgroup arrays), gated-delta
((32, 128, 48) by (32, 4, 1)) and affine-row ((32, 1280, 1) by (32, 16, 1)).
A small kernel, a shuffle then a barrier, through every level. -/

variable (C : M1Max.Contract)

/-! ## Down-fold -/

theorem fold_tiles (P O : ByteMemory.Bytes) : (Kernels.DownFold.launch P O).Tiles 256 1 1 160 1 1 8 :=
  ⟨rfl, rfl, rfl, by decide⟩

example (P O : ByteMemory.Bytes) : (Kernels.DownFold.launch P O).groups = (160, 1, 1) := (fold_tiles P O).groups

/-- Down-fold's `Lane` from the generic coordinates. -/
example (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (g : Nat) (hg : g < 160) (s : Fin 8) (l : Fin 32) :
    Kernels.DownFold.Lane ((Kernels.DownFold.launch P O).ctxAt fuse g 0 0 (32 * s + l)) l s g :=
  ⟨Launch.ctxAt_lane _ fuse g 0 0 s l, Launch.ctxAt_simd _ fuse g 0 0 s l,
    Launch.ctxAt_threadgroupPositionInGrid _ fuse g 0 0 _, l.isLt, s.isLt, hg⟩

/-- Down-fold's SIMD-groups are the generic lanes. -/
example (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (g : Nat) (hg : g < 160) :
    (List.ofFn fun s : Fin 8 => List.ofFn (Kernels.DownFold.start (Kernels.DownFold.ctxs P O fuse g hg s))) =
      List.ofFn fun s : Fin 8 => List.ofFn ((Kernels.DownFold.launch P O).lanes fuse g 0 0 s) := by
  rw [← Kernels.DownFold.chunks_eq, (fold_tiles P O).chunks fuse hg (by decide) (by decide)]

example (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (g l : Nat) :
    ((Kernels.DownFold.launch P O).ctxAt fuse g 0 0 l).thread = g * 256 + l := by
  rw [(fold_tiles P O).thread]; ring

example (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (g : Nat) (hg : g < 160) :
    ((Kernels.DownFold.launch P O).threads fuse g 0 0).length = 256 :=
  (fold_tiles P O).threads_length fuse hg (by decide) (by decide)

/-- The down-fold run with larger bounds. -/
example (P O : ByteMemory.Bytes) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ r, runLaunch C fuse (Kernels.DownFold.launch P O) garbage 100 9 4 = some r := by
  obtain ⟨r, hr, -⟩ := Kernels.DownFold.launch_run C P O fuse garbage
  exact ⟨r, runLaunch_mono C fuse _ garbage (by decide) (by decide) (by decide) hr⟩

/-- `runSimd_sum` from `runSimd_collective_ofFn` and `resolve_sum`. -/
example (fuel r : Nat) (lanes : List Thread) (T : Fin 32 → Thread) (sh sh' : Shared) (site slot d : Nat)
    (x : Fin 32 → Float32) (hrun : (lanes.mapM (runThread C fuel)).run sh = some (List.ofFn T, sh'))
    (hst : ∀ i, (T i).status = .collective site slot .sum .f32 (.f32 (x i)) d) :
    (runSimd C fuel (r + 1) lanes).run sh = (runSimd C fuel r ((List.ofFn T).map fun t =>
      { t with status := .running }.set slot (.f32 (C.simdSum x)))).run sh' := by
  rw [runSimd_collective_ofFn C fuel r lanes T sh sh' site slot .sum .f32 d _ _ hrun hst (resolve_sum C d x),
    List.map_ofFn]
  rfl

/-- Down-fold's GPU theorem through `gpu_execute`. -/
example (G : Gpu C) (hmax : 256 ≤ G.maxThreads Elab.Tests.downFoldText) (P : ByteMemory.Bytes) :
    G.execute Elab.Tests.downFoldText (40960, 1, 1) (256, 1, 1) [⟨.device, 655360, 16, P⟩] [10240] =
      some (clip [10240] fun _ => Kernels.DownFold.expected C P) := by
  apply gpu_execute C G _ Kernels.DownFold.compile_eq (by simpa using hmax)
  intro initial garbage
  obtain ⟨r, hr, hlog, hout⟩ := Kernels.DownFold.launch_run C P (initial 0) (G.fusion Elab.Tests.downFoldText) garbage
  have hL : (⟨Kernels.DownFold.core, (40960, 1, 1), (256, 1, 1),
      buffers [⟨.device, 655360, 16, P⟩] [10240] 16 initial⟩ : Launch) = Kernels.DownFold.launch P (initial 0) := rfl
  refine ⟨11, 5, 1, r, by rw [hL]; exact hr, by rw [hL]; exact Kernels.DownFold.race_free P (initial 0) r hlog, ?_⟩
  intro i hi b hb
  obtain rfl : i = 0 := by simp at hi; omega
  have hb' : b < 10240 := by simpa using hb
  show r.buffers 1 b = Kernels.DownFold.expected C P b
  have := hout (b / 2) (by omega) (b % 2) (by omega)
  rw [show 2 * (b / 2) + b % 2 = b by omega] at this
  rw [this]
  unfold Kernels.DownFold.expected
  rw [ite_eq_left hb']

/-! ## Residual-rms-norm's shape: grid 1024, threadgroup 1024, `sums[32]` and `inv[1]` -/

def residualKernel : Kernel := ⟨5, [(.scalar .f32, 32), (.scalar .f32, 1)], [], []⟩

def residual (x u w : ByteMemory.Bytes) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨residualKernel, (1024, 1, 1), (1024, 1, 1),
    buffers [⟨.device, 10240, 16, x⟩, ⟨.device, 10240, 16, u⟩, ⟨.device, 10240, 16, w⟩] [10240, 10240] 16 initial⟩

section
variable (x u w : ByteMemory.Bytes) (initial : Nat → ByteMemory.Bytes) (garbage : Garbage) (fuse : Nat → Bool)

theorem residual_tiles : (residual x u w initial).Tiles 1024 1 1 1 1 1 32 := ⟨rfl, rfl, rfl, by decide⟩

theorem residual_buffers : (residual x u w initial).buffers =
    buffers [⟨.device, 10240, 16, x⟩, ⟨.device, 10240, 16, u⟩, ⟨.device, 10240, 16, w⟩] [10240, 10240] 16 initial :=
  rfl

example : (residual x u w initial).regions 5 = some ⟨.threadgroup, 128, 4⟩ :=
  Launch.regions_groupArray _ 0 (.scalar .f32) 32 rfl

example : (residual x u w initial).regions 6 = some ⟨.threadgroup, 4, 4⟩ :=
  Launch.regions_groupArray _ 1 (.scalar .f32) 1 rfl

example : (residual x u w initial).regions 1 = some ⟨.device, 10240, 16⟩ :=
  regions_input (residual_buffers x u w initial) 1 (by simp)

example : (residual x u w initial).regions 4 = some ⟨.device, 10240, 16⟩ :=
  regions_output (residual_buffers x u w initial) 1 (by simp)

example : ((residual x u w initial).initial garbage).bytes 2 = w :=
  initial_input (residual_buffers x u w initial) garbage 2 (by simp)

example : ((residual x u w initial).initial garbage).bytes 3 = initial 0 :=
  initial_output (residual_buffers x u w initial) garbage 0 (by simp)

example : ((residual x u w initial).initial garbage).bytes 6 = garbage.group 0 1 :=
  Launch.initial_groupArray _ garbage 1 (show 1 < 2 by decide)

example (g : Nat) (bytes : Nat → ByteMemory.Bytes) :
    (residual x u w initial).resetGroup garbage g bytes 5 = garbage.group g 0 :=
  Launch.resetGroup_groupArray _ garbage g bytes 0 (show 0 < 2 by decide)

example (g : Nat) (bytes : Nat → ByteMemory.Bytes) : (residual x u w initial).resetGroup garbage g bytes 4 = bytes 4 :=
  Launch.resetGroup_buffer _ garbage g bytes 4 (show 4 < 5 by decide)

example : Launch.chunks 32 ((residual x u w initial).threads fuse 0 0 0) =
    List.ofFn fun s : Fin 32 => List.ofFn ((residual x u w initial).lanes fuse 0 0 0 s) :=
  (residual_tiles x u w initial).chunks fuse (by decide) (by decide) (by decide)

/-- Lane `i` of SIMD-group `s` is thread `32 s + i`, at `(32 s + i, 0, 0)`. -/
example (s i : Fin 32) : ((residual x u w initial).ctxAt fuse 0 0 0 (32 * s + i)).coord .threadPositionInThreadgroup =
    u32x3 (32 * s + i) 0 0 := by
  rw [(residual_tiles x u w initial).threadPositionInThreadgroup]
  have := s.isLt; have := i.isLt
  congr 1 <;> omega

example (s i : Fin 32) : ((residual x u w initial).ctxAt fuse 0 0 0 (32 * s + i)).thread = 32 * s + i := by
  rw [(residual_tiles x u w initial).thread]; omega

example (l : Nat) : ((residual x u w initial).ctxAt fuse 0 0 0 l).coord .simdgroupsPerThreadgroup = u32 32 :=
  (residual_tiles x u w initial).simdgroupsPerThreadgroup fuse 0 0 0 l

example (l j : Nat) : ((residual x u w initial).ctxAt fuse 0 0 0 l).groupArray j = 5 + j :=
  Launch.ctxAt_groupArray _ fuse 0 0 0 l j

/-- An owner's write to an output byte, and to a threadgroup byte. -/
example (ctx : Ctx) (sh : Shared) (hc : ctx.thread = 7) (hg : ctx.group = 0) (he : sh.deviceEpoch = 0) :
    Owned (residual x u w initial) (fun r _ => if r = 3 then some ⟨7, 0, 0⟩ else none) (fun _ _ _ _ => none)
      (entry ctx sh 3 12 true) :=
  owned_device _ _ _ ctx sh 3 12 ⟨.device, 10240, 16⟩
    (regions_output (residual_buffers x u w initial) 0 (by simp)) true (by decide) ⟨7, 0, 0⟩ rfl hc hg (by omega)

example (ctx : Ctx) (sh : Shared) :
    Owned (residual x u w initial) (fun _ _ => none) (fun _ _ _ _ => some ctx.thread) (entry ctx sh 5 0 true) :=
  owned_group _ _ _ ctx sh 5 0 _ (Launch.regions_groupArray _ 0 (.scalar .f32) 32 rfl) true rfl rfl

/-- Reads of an unowned input byte by two threads are race-free. -/
example (c c' : Ctx) (sh : Shared) (r : Result)
    (hr : r.log = [entry c sh 0 4 false, entry c' sh 0 4 false]) : RaceFree (residual x u w initial) r := by
  apply raceFree_of_owned _ (fun _ _ => none) (fun _ _ _ _ => none)
  rw [hr]
  intro a ha
  simp only [List.mem_cons, List.mem_nil_iff, or_false] at ha
  rcases ha with rfl | rfl
  · exact owned_device_read _ _ _ c sh 0 4 ⟨.device, 10240, 16⟩
      (regions_input (residual_buffers x u w initial) 0 (by simp)) (by decide) rfl
  · exact owned_device_read _ _ _ c' sh 0 4 ⟨.device, 10240, 16⟩
      (regions_input (residual_buffers x u w initial) 0 (by simp)) (by decide) rfl
end

/-! ## Gated-delta's and affine-row's shapes -/

def gatedShape : Launch := ⟨⟨7, [], [], []⟩, (32, 128, 48), (32, 4, 1), []⟩

theorem gated_tiles : gatedShape.Tiles 32 4 1 1 32 48 4 := ⟨rfl, rfl, rfl, by decide⟩

example (fuse : Nat → Bool) : (gatedShape.ctxAt fuse 0 5 7 (32 * 2 + 3)).coord .threadPositionInGrid = u32x3 3 22 7 :=
  (gated_tiles.threadPositionInGrid fuse 0 5 7 _).trans rfl

example (fuse : Nat → Bool) (l : Nat) : (gatedShape.ctxAt fuse 0 5 7 l).thread = (5 + 7 * 32) * 128 + l := by
  rw [gated_tiles.thread]

example (fuse : Nat → Bool) (l : Nat) :
    (gatedShape.ctxAt fuse 0 5 7 l).coord .threadgroupsPerGrid = u32x3 1 32 48 :=
  gated_tiles.threadgroupsPerGrid fuse 0 5 7 l

example : gatedShape.groups = (1, 32, 48) := gated_tiles.groups

def affineShape : Launch := ⟨⟨4, [(.scalar .f32, 5120), (.scalar .f32, 320)], [], []⟩, (32, 1280, 1), (32, 16, 1), []⟩

theorem affine_tiles : affineShape.Tiles 32 16 1 1 80 1 16 := ⟨rfl, rfl, rfl, by decide⟩

example (fuse : Nat → Bool) (y : Nat) (s : Fin 16) (i : Fin 32) :
    (affineShape.ctxAt fuse 0 y 0 (32 * s + i)).coord .threadPositionInThreadgroup = u32x3 i s 0 := by
  rw [affine_tiles.threadPositionInThreadgroup]
  have := s.isLt; have := i.isLt
  congr 1 <;> omega

/-! ## Shuffles and bounds -/

example : shuffle (fun l : Fin 32 => l.val) 16 3 = 19 := rfl
example : shuffle (fun l : Fin 32 => l.val) 16 20 = 20 := rfl

example (x : Fin 32 → Nat) : resolve C .shuffleDown .u32 4 (List.ofFn fun i => .int .u32 (x i)) =
    some (List.ofFn fun i => .int .u32 (shuffle x 4 i)) := resolve_shuffle_u32 C 4 x

example : ∃ b, ∀ i : Fin 3, ∀ m ≥ b, (i : Nat) ≤ m := exists_bound _ fun i => ⟨i, fun _ hm => hm⟩

/-! ## A small kernel through every level

Every thread shuffles its lane index down by one, then passes a barrier
ordering both memories: one threadgroup of two SIMD-groups. -/

def shuffleStmt : CStmt := .collective 0 0 .shuffleDown .u32 (.coord .threadIndexInSimdgroup) (.lit (.int .u32 1))
def tinyKernel : Kernel := ⟨0, [], [], [shuffleStmt, .barrier 1 true true]⟩
def tiny : Launch := ⟨tinyKernel, (64, 1, 1), (64, 1, 1), []⟩

theorem tiny_tiles : tiny.Tiles 64 1 1 1 1 1 2 := ⟨rfl, rfl, rfl, by decide⟩

section
variable (fuse : Nat → Bool)

def atShuffle (j : Fin 2) (i : Fin 32) : Thread :=
  { tiny.lanes fuse 0 0 0 j i with
    frames := [.block [.barrier 1 true true]]
    status := .collective 0 0 .shuffleDown .u32 (u32 i) 1 }

def atBarrier (j : Fin 2) (i : Fin 32) : Thread :=
  { ({ atShuffle fuse j i with status := .running }.set 0 (shuffle (fun l : Fin 32 => u32 l) 1 i)) with
    frames := [.block []]
    status := .barrier 1 true true }

def finished (j : Fin 2) (i : Fin 32) : Thread := { atBarrier fuse j i with frames := [], status := .done }

theorem lane_shuffle (j : Fin 2) (i : Fin 32) (sh : Shared) :
    (runThread C 2 (tiny.lanes fuse 0 0 0 j i)).run sh = some (atShuffle fuse j i, sh) := by
  have hv : (tiny.lanes fuse 0 0 0 j i).ctx.coord .threadIndexInSimdgroup = u32 i := Launch.ctxAt_lane tiny fuse 0 0 0 j i
  rw [runThread_collective C _ rfl rfl (eval_coord C _ _ _ sh) (eval_lit C _ _ _ sh) rfl, hv]
  rfl

theorem simd_first (j : Fin 2) (sh : Shared) :
    (runSimd C 2 2 (List.ofFn (tiny.lanes fuse 0 0 0 j))).run sh = some (List.ofFn (atBarrier fuse j), sh) := by
  have h1 := mapM_ofFn_run (tiny.lanes fuse 0 0 0 j) (runThread C 2) (atShuffle fuse j) (fun _ => sh)
    (fun i => lane_shuffle C fuse j i sh)
  rw [runSimd_collective_ofFn C 2 1 _ (atShuffle fuse j) sh sh 0 0 .shuffleDown .u32 1 (fun i => u32 i) _ h1
    (fun i => rfl) (resolve_shuffle C .u32 1 _)]
  have h2 := mapM_ofFn_run (fun i => { atShuffle fuse j i with status := .running }.set 0
    (shuffle (fun l : Fin 32 => u32 l) 1 i)) (runThread C 2) (atBarrier fuse j) (fun _ => sh) (fun i => rfl)
  exact runSimd_blocked_ofFn C 2 0 _ (atBarrier fuse j) sh sh h2 (fun i => rfl)

/-- `simd_first` through the invariant forms. -/
example (j : Fin 2) (sh : Shared) : ∃ (V : Fin 32 → Thread) (sh' : Shared),
    (runSimd C 2 2 (List.ofFn (tiny.lanes fuse 0 0 0 j))).run sh = some (List.ofFn V, sh') ∧ sh' = sh ∧
      ∀ i, V i = atBarrier fuse j i := by
  refine runSimd_collective_inv C 2 1 _ 0 0 .shuffleDown .u32 1 (fun i => u32 i) _ (resolve_shuffle C .u32 1 _)
    (fun _ s => s = sh) (fun i t => t = atShuffle fuse j i) (fun s => s = sh) (fun i t => t = atBarrier fuse j i)
    (fun i s hs => ⟨_, s, lane_shuffle C fuse j i s, hs, rfl, rfl⟩) ?_ sh rfl
  intro U s hU hs
  obtain rfl : U = atShuffle fuse j := funext hU
  obtain ⟨V, sh', hr, h1, hV⟩ := runSimd_blocked_inv C 2 0
    (fun i => { atShuffle fuse j i with status := .running }.set 0 (shuffle (fun l : Fin 32 => u32 l) 1 i))
    (fun _ s' => s' = s) (fun i t => t = atBarrier fuse j i)
    (fun i s' hs' => ⟨_, s', rfl, hs', rfl, rfl⟩) s rfl
  exact ⟨V, sh', hr, h1.trans hs, hV⟩

theorem simd_second (j : Fin 2) (sh : Shared) :
    (runSimd C 2 2 (List.ofFn fun i => { atBarrier fuse j i with status := .running })).run sh =
      some (List.ofFn (finished fuse j), sh) := by
  have h := mapM_ofFn_run (fun i => { atBarrier fuse j i with status := .running }) (runThread C 2) (finished fuse j)
    (fun _ => sh) (fun i => rfl)
  exact runSimd_blocked_ofFn C 2 1 _ _ sh sh h (fun i => rfl)

theorem tiny_group (sh : Shared) (hlog : sh.log = []) :
    ∃ sh', (runGroup C 2 2 2 (List.ofFn fun s : Fin 2 => List.ofFn (tiny.lanes fuse 0 0 0 s))).run sh =
      some ((), sh') ∧ sh'.log = [] := by
  refine runGroup_barrier_inv C (by decide) 2 2 1 (fun s => tiny.lanes fuse 0 0 0 s) 1 true true
    (fun _ sh => sh.log = []) (fun j i t => t = atBarrier fuse j i) (fun sh => sh.log = [])
    (fun j sh hj => ⟨atBarrier fuse j, sh, simd_first C fuse j sh, hj, fun i => ⟨rfl, rfl⟩⟩) ?_ sh hlog
  intro U sh hU hl
  obtain rfl : U = atBarrier fuse := funext fun j => funext fun i => hU j i
  exact runGroup_done_inv C 2 2 0 (fun j i => { atBarrier fuse j i with status := .running })
    (fun _ sh => sh.log = []) (fun j sh hj => ⟨finished fuse j, sh, simd_second C fuse j sh, hj, fun i => rfl⟩) _ hl

theorem tiny_run (garbage : Garbage) : ∃ r, runLaunch C fuse tiny garbage 2 2 2 = some r ∧ RaceFree tiny r := by
  obtain ⟨sh, hl, hr⟩ := tiny_tiles.launch_run C fuse garbage 2 2 2 (fun _ sh => sh.log = []) rfl
    (fun bx byy bz hx hy hz sh hl => by
      obtain rfl : bx = 0 := by omega
      obtain rfl : byy = 0 := by omega
      obtain rfl : bz = 0 := by omega
      exact tiny_group C fuse _ hl)
  refine ⟨_, hr, raceFree_of_owned tiny (fun _ _ => none) (fun _ _ _ _ => none) _ (fun a ha => ?_)⟩
  simp [hl] at ha
end

end Metal.Group.Tests
