import host.ts.renameOrdinary.RankOriginCacheRoles
import host.ts.RenameIntegerPacking

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
variable (timeMeaning capacityMeaning : SymE)

def usedMeaning : SymE := .bin .add timeMeaning (.lit (F64.ofNat 1))
def rowShape : Shape := [fixedDimension 1,fixedDimension 4,fixedDimension 1,fixedDimension 256]
def appendStarts : Shape := [fixedDimension 0,fixedDimension 0,.literal timeMeaning,fixedDimension 0]
def usedShape : Shape := [fixedDimension 1,fixedDimension 4,.literal (usedMeaning timeMeaning),fixedDimension 256]
def unitStrides : Shape := [fixedDimension 1,fixedDimension 1,fixedDimension 1,fixedDimension 1]
def viewStarts : Shape := [fixedDimension 0,fixedDimension 0,fixedDimension 0,fixedDimension 0]

theorem used_meaning_eval (ν : Nat → F64) (position : Nat)
    (time : timeMeaning.eval ν = F64.ofNat position) (bound : position+1 < 2^53) :
    (usedMeaning timeMeaning).eval ν = F64.ofNat (position+1) := by
  change F64.bin .add (timeMeaning.eval ν) (F64.ofNat 1) = _
  rw [time]
  exact F64.add_ofNat53 position 1 bound

private theorem exact_natural (ν : Nat → F64) (e : SymE) (n : Nat)
    (value : e.eval ν = F64.ofNat n) (bound : n < 2^53) :
    e.eval ν = F64.ofInt ((n : Int)) ∧ F64.toInt? (e.eval ν) = some ((n : Int)) := by
  refine ⟨value,?_⟩
  rw [value]
  exact F64.toInt_ofNat53 n bound

theorem capacity_dimensions (ν : Nat → F64) (capacity : Nat)
    (value : capacityMeaning.eval ν = F64.ofNat capacity) (bound : capacity < 2^53) :
    LiteralDimensions ν (capacityShape capacityMeaning) [1,4,(capacity : Int),256] := by
  have exactValue := exact_natural ν capacityMeaning capacity value bound
  exact .cons _ 1 rfl (by simp only [SymE.eval]; decide +kernel) (.cons _ 4 rfl (by simp only [SymE.eval]; decide +kernel)
    (.cons _ ((capacity : Int)) exactValue.1 exactValue.2 (.cons _ 256 rfl (by simp only [SymE.eval]; decide +kernel) .nil)))

theorem used_dimensions (ν : Nat → F64) (used : Nat)
    (value : (usedMeaning timeMeaning).eval ν = F64.ofNat used) (bound : used < 2^53) :
    LiteralDimensions ν (usedShape timeMeaning) [1,4,(used : Int),256] := by
  have exactValue := exact_natural ν (usedMeaning timeMeaning) used value bound
  exact .cons _ 1 rfl (by simp only [SymE.eval]; decide +kernel) (.cons _ 4 rfl (by simp only [SymE.eval]; decide +kernel)
    (.cons _ ((used : Int)) exactValue.1 exactValue.2 (.cons _ 256 rfl (by simp only [SymE.eval]; decide +kernel) .nil)))

theorem row_dimensions (ν : Nat → F64) : LiteralDimensions ν rowShape [1,4,1,256] :=
  .cons _ 1 rfl (by simp only [SymE.eval]; decide +kernel) (.cons _ 4 rfl (by simp only [SymE.eval]; decide +kernel)
    (.cons _ 1 rfl (by simp only [SymE.eval]; decide +kernel) (.cons _ 256 rfl (by simp only [SymE.eval]; decide +kernel) .nil)))

theorem start_dimensions (ν : Nat → F64) (position : Nat)
    (value : timeMeaning.eval ν = F64.ofNat position) (bound : position < 2^53) :
    LiteralDimensions ν (appendStarts timeMeaning) [0,0,(position : Int),0] := by
  have exactValue := exact_natural ν timeMeaning position value bound
  exact .cons _ 0 rfl (by simp only [SymE.eval]; decide +kernel) (.cons _ 0 rfl (by simp only [SymE.eval]; decide +kernel)
    (.cons _ ((position : Int)) exactValue.1 exactValue.2 (.cons _ 0 rfl (by simp only [SymE.eval]; decide +kernel) .nil)))

theorem stride_dimensions (ν : Nat → F64) : LiteralDimensions ν unitStrides [1,1,1,1] :=
  .cons _ 1 rfl (by simp only [SymE.eval]; decide +kernel) (.cons _ 1 rfl (by simp only [SymE.eval]; decide +kernel)
    (.cons _ 1 rfl (by simp only [SymE.eval]; decide +kernel) (.cons _ 1 rfl (by simp only [SymE.eval]; decide +kernel) .nil)))

theorem view_start_dimensions (ν : Nat → F64) : LiteralDimensions ν viewStarts [0,0,0,0] :=
  .cons _ 0 rfl (by simp only [SymE.eval]; decide +kernel) (.cons _ 0 rfl (by simp only [SymE.eval]; decide +kernel)
    (.cons _ 0 rfl (by simp only [SymE.eval]; decide +kernel) (.cons _ 0 rfl (by simp only [SymE.eval]; decide +kernel) .nil)))

/-- Current offset and capacity meanings determine both real append shapes.
The witnesses are valid for arbitrary supported positions and capacities. -/
noncomputable def append_values (ν : Nat → F64) (position capacity : Nat)
    (time : timeMeaning.eval ν = F64.ofNat position) (size : capacityMeaning.eval ν = F64.ofNat capacity)
    (capacityBound : capacity < 2^31) (fits : position+1 ≤ capacity) :
    KvAppendValues ν (capacityShape capacityMeaning) rowShape (appendStarts timeMeaning) (usedShape timeMeaning) unitStrides := by
  have capacity53 : capacity < 2^53 := by omega
  have position53 : position+1 < 2^53 := by omega
  have output := (used_dimensions timeMeaning) ν (position+1) ((used_meaning_eval timeMeaning) ν position time position53) position53
  refine ⟨1,4,(capacity : Int),(position : Int),256,
    (capacity_dimensions capacityMeaning) ν capacity size capacity53,row_dimensions ν,
    (start_dimensions timeMeaning) ν position time (by omega),?_,stride_dimensions ν,
    by decide,by decide,by omega,by decide,by omega⟩
  simpa only [Int.natCast_add,Int.natCast_one] using output

noncomputable def view_values (ν : Nat → F64) (position capacity : Nat) (kind : SliceResult)
    (time : timeMeaning.eval ν = F64.ofNat position) (size : capacityMeaning.eval ν = F64.ofNat capacity)
    (capacityBound : capacity < 2^31) (fits : position+1 ≤ capacity)
    (branch : decide (position+1 = capacity) = kind.same) :
    KvViewValues ν (capacityShape capacityMeaning) (usedShape timeMeaning) viewStarts (usedShape timeMeaning) unitStrides kind := by
  have capacity53 : capacity < 2^53 := by omega
  have position53 : position+1 < 2^53 := by omega
  have output := (used_dimensions timeMeaning) ν (position+1) ((used_meaning_eval timeMeaning) ν position time position53) position53
  refine ⟨1,4,(capacity : Int),((position+1 : Nat) : Int),256,
    (capacity_dimensions capacityMeaning) ν capacity size capacity53,output,view_start_dimensions ν,output,stride_dimensions ν,
    by decide,by decide,by omega,by decide,by omega,?_⟩
  simpa only [Int.natCast_inj] using branch

end Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry
