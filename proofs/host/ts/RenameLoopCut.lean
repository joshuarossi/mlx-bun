import host.ts.RenameBounded
namespace Host.Ts

/-- Source locations of loop-carried values. Private fields are addressed by their
runtime brand, rather than identified with unrelated bigint or numeric resources. -/
inductive LoopPlace where
  | cell (address : Nat)
  | data (address : Nat) (key : PKey)
  | privField (address brand : Nat) (name : Name)

def LoopPlace.read {S : Type} (s : St S) : LoopPlace → Option Val
  | .cell a => (s.cell? a).join
  | .data a k => do
    let o ← s.obj? a
    match findProp k o.props with
    | some (.data v _ _) => some v
    | _ => none
  | .privField a b n => do
    let o ← s.obj? a
    match findPriv b n o.priv with
    | some (.data v _ _) => some v
    | _ => none

def LoopPlace.number {S : Type} (C : CSrv) (s : St S) (p : LoopPlace) : Option F64 := do
  match ← p.read s with
  | .num x => C.val x
  | _ => none

def loopArray {S : Type} (s : St S) (a : Nat) : Option (List Val) := do
  let o ← s.obj? a
  match o.kind with
  | .array xs => some xs
  | _ => none

structure ReadbackSlots where
  generated : LoopPlace
  stepIndex : LoopPlace
  maxTokens : LoopPlace
  pending : LoopPlace
  nextPending : LoopPlace
  forwarded : Nat
  emitted : Nat
  cacheOffsets : List LoopPlace
  /-- Locations of the bigint private handles of the sixteen KV key/value pairs. -/
  kvHandles : List LoopPlace

/-- The ordinary current-token readback cut, after the next-token graph has already entered
the cache and before the current readback and `forwarded.push`. The prefill sample,
early-first yield/resume, and final body use different cuts. This records source-state
observations only; it contains no execution or simulation premise. -/
structure ReadbackCut {S : Type} (native : S → Host.Mlx.Ffi.St)
    (slots : ReadbackSlots) (C : CSrv) (s : St S)
    (prompt i maximum capacity : Nat) (forwarded emitted : List Val)
    (currentToken : NumV) (future : List NumV) : Prop where
  ordinary : 1 ≤ i
  lookahead : i + 1 < maximum
  promptPositive : 0 < prompt
  bounded : prompt + maximum < 2 ^ 31
  capacityPositive : 0 < capacity
  capacityAligned : capacity % 256 = 0
  fits : prompt + i + 1 ≤ capacity
  capacityBounded : capacity < 2 ^ 31
  generated : slots.generated.number C s = some (F64.ofNat i)
  stepIndex : slots.stepIndex.number C s = some (F64.ofNat i)
  maximum : slots.maxTokens.number C s = some (F64.ofNat maximum)
  forwardedArray : loopArray s slots.forwarded = some forwarded
  emittedArray : loopArray s slots.emitted = some emitted
  recordedPrefix : forwarded = emitted
  forwardedLength : forwarded.length = i
  emittedLength : emitted.length = i
  layerCount : slots.cacheOffsets.length = 64
  offsets : ∀ p ∈ slots.cacheOffsets, p.number C s = some (F64.ofNat (prompt + i + 1))
  kvCount : slots.kvHandles.length = 32
  kvCarriers : ∀ p ∈ slots.kvHandles, ∃ h node,
    p.read s = some (.big (Int.ofNat h)) ∧
    (native s.ffi).node? h = some node ∧
    node.shape = Host.Mlx.Ffi.lits [1, 4, capacity, 256] ∧ node.dtype = 12
  currentPending : ∃ a, slots.pending.read s = some (.obj a)
  nextPending : ∃ a, slots.nextPending.read s = some (.obj a)
  unread : (native s.ffi).tokens = currentToken :: future

/-- At this cut the cache is exactly one token ahead of the recorded forwarded
prefix. This is the lookahead token whose readback is still pending. -/
theorem ReadbackCut.offset_ahead {S : Type} {native : S → Host.Mlx.Ffi.St}
    {slots : ReadbackSlots} {C : CSrv} {s : St S} {prompt i maximum capacity : Nat}
    {forwarded emitted : List Val} {currentToken : NumV} {future : List NumV}
    (h : ReadbackCut native slots C s prompt i maximum capacity forwarded emitted currentToken future)
    (p : LoopPlace) (hp : p ∈ slots.cacheOffsets) :
    p.number C s = some (F64.ofNat (prompt + forwarded.length + 1)) := by
  rw [h.forwardedLength]
  exact h.offsets p hp

end Host.Ts
