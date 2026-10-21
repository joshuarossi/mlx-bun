import metal.Run

namespace Metal
open Core Inference.Contracts.Mlx

/-! # Launches

MLX dispatches a custom kernel with `dispatchThreads(grid, min(tg, grid))`
(backend/metal/custom_kernel.cpp:84-99): the grid counts threads, and the last
threadgroup along a dimension may be partial. Threadgroups are numbered with
x fastest; inside a threadgroup, threads are numbered by their linear index
x + y·width + z·width·height, and SIMD-group `s` holds threads 32s … 32s+31.

Memory regions: buffer `i` of the launch is region `i`; threadgroup array `j`
is region `buffers + j` (each threadgroup has its own, reset to that
threadgroup's unwritten contents when it starts); thread array `j` of thread
`t` is region `buffers + groupArrays + t · threadArrays + j`. -/

/-- A buffer: space, size, guaranteed alignment of its base address, contents. -/
structure Buffer where
  space : Space
  size : Nat
  align : Nat
  bytes : ByteMemory.Bytes

structure Launch where
  kernel : Kernel
  grid : Nat × Nat × Nat
  threadgroup : Nat × Nat × Nat
  buffers : List Buffer

/-- Contents of memory a launch has not written: threadgroup arrays (by
threadgroup) and thread arrays (by thread). -/
structure Garbage where
  group : Nat → Nat → ByteMemory.Bytes
  thread : Nat → Nat → ByteMemory.Bytes

structure Result where
  buffers : Nat → ByteMemory.Bytes
  log : List Access

def ceilDiv (a b : Nat) : Nat := (a + b - 1) / b

def u32 (n : Nat) : Val := .int .u32 (n % 2 ^ 32)
def u32x3 (x y z : Nat) : Val := .vec .u32 [u32 x, u32 y, u32 z]

namespace Launch
variable (L : Launch)

/-- Threadgroup size actually used: `min(tg, grid)` per dimension. -/
def group : Nat × Nat × Nat :=
  (min L.threadgroup.1 L.grid.1, min L.threadgroup.2.1 L.grid.2.1, min L.threadgroup.2.2 L.grid.2.2)

def groups : Nat × Nat × Nat :=
  (ceilDiv L.grid.1 L.group.1, ceilDiv L.grid.2.1 L.group.2.1, ceilDiv L.grid.2.2 L.group.2.2)

def groupArrays : Nat := L.kernel.threadgroupArrays.length
def threadArrays : Nat := L.kernel.threadArrays.length

def regions (region : Nat) : Option Region :=
  if h : region < L.buffers.length then
    let b := L.buffers[region]
    some ⟨b.space, b.size, b.align⟩
  else if region < L.buffers.length + L.groupArrays then
    (L.kernel.threadgroupArrays[region - L.buffers.length]?).map fun (t, n) => ⟨.threadgroup, t.bytes * n, alignment t⟩
  else if L.threadArrays = 0 then none
  else
    (L.kernel.threadArrays[(region - L.buffers.length - L.groupArrays) % L.threadArrays]?).map
      fun (t, n) => ⟨.thread, t.bytes * n, alignment t⟩

/-- Threadgroup `(bx, by, bz)`'s threads, in linear order. -/
def threads (fuse : Nat → Bool) (bx byy bz : Nat) : List Thread :=
  let (tx, ty, tz) := L.group
  let (gx, gy, gz) := L.groups
  let ax := min tx (L.grid.1 - bx * tx)
  let ay := min ty (L.grid.2.1 - byy * ty)
  let az := min tz (L.grid.2.2 - bz * tz)
  let g := bx + byy * gx + bz * gx * gy
  let size := ax * ay * az
  (List.range size).map fun l =>
    let lx := l % ax
    let ly := l / ax % ay
    let lz := l / (ax * ay)
    let t := g * (tx * ty * tz) + l
    let coord : Coord → Val
      | .threadPositionInGrid => u32x3 (bx * tx + lx) (byy * ty + ly) (bz * tz + lz)
      | .threadPositionInThreadgroup => u32x3 lx ly lz
      | .threadgroupPositionInGrid => u32x3 bx byy bz
      | .threadsPerThreadgroup => u32x3 ax ay az
      | .threadgroupsPerGrid => u32x3 gx gy gz
      | .threadsPerGrid => u32x3 L.grid.1 L.grid.2.1 L.grid.2.2
      | .threadIndexInSimdgroup => u32 (l % 32)
      | .simdgroupIndexInThreadgroup => u32 (l / 32)
      | .threadIndexInThreadgroup => u32 l
      | .simdgroupsPerThreadgroup => u32 (ceilDiv size 32)
      | .threadsPerSimdgroup => u32 32
    let ctx : Ctx := {
      thread := t
      group := g
      coord := coord
      threadArray := fun j => L.buffers.length + L.groupArrays + t * L.threadArrays + j
      groupArray := fun j => L.buffers.length + j
      fuse := fuse }
    { ctx := ctx, locals := fun _ => none, frames := [.block L.kernel.body] }

def chunks (n : Nat) (xs : List α) : List (List α) :=
  (List.range (ceilDiv xs.length n)).map fun i => (xs.drop (i * n)).take n

def initial (garbage : Garbage) : Shared where
  regions := L.regions
  bytes := fun region =>
    if h : region < L.buffers.length then L.buffers[region].bytes
    else if region < L.buffers.length + L.groupArrays then garbage.group 0 (region - L.buffers.length)
    else if L.threadArrays = 0 then fun _ => 0
    else garbage.thread ((region - L.buffers.length - L.groupArrays) / L.threadArrays)
      ((region - L.buffers.length - L.groupArrays) % L.threadArrays)
  log := []

/-- Threadgroup `g`'s arrays, reset to its unwritten contents. -/
def resetGroup (garbage : Garbage) (g : Nat) (bytes : Nat → ByteMemory.Bytes) (region : Nat) : ByteMemory.Bytes :=
  if L.buffers.length ≤ region ∧ region < L.buffers.length + L.groupArrays then garbage.group g (region - L.buffers.length)
  else bytes region

end Launch

/-- The run of a launch, threadgroup by threadgroup. `fuel` bounds the steps a
thread takes between stops, `rounds` the collectives a SIMD-group passes
between barriers, `barriers` the barriers a threadgroup passes. -/
def runLaunch (C : M1Max.Contract) (fuse : Nat → Bool) (L : Launch) (garbage : Garbage)
    (fuel rounds barriers : Nat) : Option Result := do
  let (gx, gy, gz) := L.groups
  let groups := (List.range (gx * gy * gz)).map fun g => (g % gx, g / gx % gy, g / (gx * gy))
  let ((), final) ← (groups.forM (m := M) fun (bx, byy, bz) => do
      let g := bx + byy * gx + bz * gx * gy
      modify fun (sh : Shared) => { sh with bytes := L.resetGroup garbage g sh.bytes }
      runGroup C fuel rounds barriers (Launch.chunks 32 (L.threads fuse bx byy bz))).run (L.initial garbage)
  pure ⟨final.bytes, final.log⟩

/-- Two accesses conflict: same byte, different threads, one writing, and not
ordered — threadgroup memory within one barrier epoch of its threadgroup;
device memory within one device epoch of a threadgroup, or from two
threadgroups. -/
def Conflict (L : Launch) (a b : Access) : Prop :=
  a.region = b.region ∧ a.byte = b.byte ∧ a.thread ≠ b.thread ∧ (a.write = true ∨ b.write = true) ∧
  match L.regions a.region with
  | some ⟨.threadgroup, _, _⟩ => a.group = b.group ∧ a.groupEpoch = b.groupEpoch
  | _ => a.group ≠ b.group ∨ a.deviceEpoch = b.deviceEpoch

def RaceFree (L : Launch) (r : Result) : Prop := ∀ a ∈ r.log, ∀ b ∈ r.log, ¬ Conflict L a b

end Metal
