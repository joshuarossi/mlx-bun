import host.ts.RenameLoopCut
import host.ts.RenameOwnedState
namespace Host.Ts

/-- Runtime positions that change with the source iteration. These are locations,
not a global substitution of all occurrences of the same numeric literal. -/
structure LoopRolePlaces extends ReadbackSlots where
  cur : LoopPlace
  yieldedEarly : LoopPlace
  currentHandle : LoopPlace
  cacheCapacities : List LoopPlace

/-- Exact source entry to the ordinary uint32 read, after lookahead forwarding.
The loop counter and all cache positions are literal numbers in this source
execution; the limit may remain a symbolic number with its given valuation. -/
structure SupportedOrdinaryCut (F : Ffi) (native : F.S → Host.Mlx.Ffi.St) (places : LoopRolePlaces)
    (C : CSrv) (s : St F.S) (prompt i limit capacity : Nat)
    (recorded : List Val) (token : NumV) (future : List NumV) : Prop
    extends ReadbackCut native places.toReadbackSlots C s prompt i limit capacity recorded recorded token future where
  supported : prompt + limit ≤ 262144
  capacitySupported : capacity ≤ 262144
  generatedLiteral : places.generated.read s = some (natV i)
  stepIndexLiteral : places.stepIndex.read s = some (natV i)
  offsetLiterals : ∀ p ∈ places.cacheOffsets, p.read s = some (natV (prompt + i + 1))
  capacityCount : places.cacheCapacities.length = 16
  capacityLiterals : ∀ p ∈ places.cacheCapacities, p.read s = some (natV capacity)
  early : places.yieldedEarly.read s = some (.bool false)
  pendingObject : ∃ a, places.pending.read s = some (.obj a) ∧ places.cur.read s = some (.obj a)
  readEntry : ∃ fn types b off handle fo to bs,
    s.ctl = .call (.obj fn) .undef [.ptr (.js b) off, .big (Int.ofNat handle)] ∧
    s.obj? fn = some fo ∧
    fo.kind = .fn (.native (.ffi .symbol)
      [.str chars!"mlx_array_item_uint32", .obj types, .str chars!"i32"]) ∧
    s.obj? types = some to ∧ to.kind = .array [.str chars!"ptr", .str chars!"u64"] ∧
    places.currentHandle.read s = some (.big (Int.ofNat handle)) ∧
    bufBytes F s b = some bs

/-- The next body may perform a periodic cache clear independently of whether
its one-token append grows a KV allocation. The last read has no lookahead. -/
inductive NextCutCase (prompt i limit capacity : Nat) : Prop where
  | ordinarySteady : i + 2 < limit → prompt + i + 1 < capacity →
      NextCutCase prompt i limit capacity
  | ordinaryGrowth : i + 2 < limit → prompt + i + 1 = capacity →
      NextCutCase prompt i limit capacity
  | final : i + 2 = limit → NextCutCase prompt i limit capacity

def clearsAfterRead (i : Nat) : Bool := decide (i % 256 = 0)

def capacityAfterAppend (n capacity : Nat) : Nat := if n = capacity then capacity + 256 else capacity

namespace SupportedOrdinaryCut
variable {F : Ffi} {native : F.S → Host.Mlx.Ffi.St} {places : LoopRolePlaces}
  {C : CSrv} {s : St F.S} {prompt i limit capacity : Nat} {recorded : List Val}
  {token : NumV} {future : List NumV}

theorem nextCase (h : SupportedOrdinaryCut F native places C s prompt i limit capacity recorded token future) :
    NextCutCase prompt i limit capacity := by
  by_cases hnext : i + 2 < limit
  · by_cases hfull : prompt + i + 1 = capacity
    · exact .ordinaryGrowth hnext hfull
    · exact .ordinarySteady hnext (by have := h.fits; omega)
  · exact .final (by have := h.lookahead; omega)

theorem growthWithinSupportedContext
    (h : SupportedOrdinaryCut F native places C s prompt i limit capacity recorded token future)
    (hnext : i + 2 < limit) :
    capacityAfterAppend (prompt + i + 1) capacity ≤ 262144 := by
  unfold capacityAfterAppend
  split
  · have := h.supported
    have := h.capacityAligned
    omega
  · exact h.capacitySupported

theorem nextOffsetFits
    (h : SupportedOrdinaryCut F native places C s prompt i limit capacity recorded token future) :
    prompt + (i + 1) + 1 ≤ capacityAfterAppend (prompt + i + 1) capacity := by
  unfold capacityAfterAppend
  split
  · omega
  · have := h.fits
    omega

/-- The actual bounded binary64 KV guard agrees with the natural-number branch;
there is no extrapolation from the observed capacity256 source cut. -/
theorem growthGuard
    (h : SupportedOrdinaryCut F native places C s prompt i limit capacity recorded token future) :
    F64.test .lt (F64.ofNat capacity)
      (F64.add (F64.ofNat (prompt + i + 1)) (F64.ofNat 1)) =
        decide (prompt + i + 1 = capacity) := by
  apply F64.kv_growth_test _ _ h.capacityBounded _ h.fits
  have := h.supported
  have := h.lookahead
  omega

/-- After this read, generated becomes i+1; the source clear condition is i%256.
It cannot be elided from a statement quantified over all supported iterations. -/
theorem clearIndex : ((i + 1) - 1) % 256 = i % 256 := by omega

end SupportedOrdinaryCut
end Host.Ts
