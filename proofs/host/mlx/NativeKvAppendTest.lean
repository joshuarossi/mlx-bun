import host.mlx.NativeKvAppendRetained

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated.KvAppendTest
open Host.Ts Host.Ts.Owned

def constant (n : Int) : SymE := .lit (F64.ofInt n)
def cache : Shape := [.literal (constant 1),.literal (constant 2),.literal (.var 0),.literal (constant 128)]
def update : Shape := [.literal (constant 1),.literal (constant 2),.literal (constant 1),.literal (constant 128)]
def starts : List SymE := [constant 0,constant 0,.var 1,constant 0]
def stops : List SymE := [constant 1,constant 2,.bin .add (.var 1) (constant 1),constant 128]
def strides : List SymE := [constant 1,constant 1,constant 1,constant 1]
def valuation (capacity index : Int) (i : Nat) : F64 := if i = 0 then F64.ofInt capacity else F64.ofInt index

def ordinary : KvAppendValues (valuation 256 3) cache update
    (starts.map Dimension.literal) (stops.map Dimension.literal) (strides.map Dimension.literal) :=
  ⟨1,2,256,3,128,
    .cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel)
      (.cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel) .nil))),
    .cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel)
      (.cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel) .nil))),
    .cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel)
      (.cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel) .nil))),
    .cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel)
      (.cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel) .nil))),
    .cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel)
      (.cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel) .nil))),
    by decide +kernel,by decide +kernel,by decide +kernel,by decide +kernel,by decide +kernel⟩

def grown : KvAppendValues (valuation 512 256) cache update
    (starts.map Dimension.literal) (stops.map Dimension.literal) (strides.map Dimension.literal) :=
  ⟨1,2,512,256,128,
    .cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel)
      (.cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel) .nil))),
    .cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel)
      (.cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel) .nil))),
    .cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel)
      (.cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel) .nil))),
    .cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel)
      (.cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel) .nil))),
    .cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel)
      (.cons _ _ rfl (by decide +kernel) (.cons _ _ rfl (by decide +kernel) .nil))),
    by decide +kernel,by decide +kernel,by decide +kernel,by decide +kernel,by decide +kernel⟩

theorem ordinary_infer (C : CSrv) :
    infer (.sliceUpdate ([0,0,3,0].map Dim.lit) ([1,2,4,128].map Dim.lit) ([1,1,1,1].map Dim.lit))
      [([1,2,256,128].map Dim.lit,12),([1,2,1,128].map Dim.lit,12)] =
      M.pure (some (.node ([1,2,256,128].map Dim.lit) 12)) :=
  ordinary.geometry.infer 12 12 (ordinary.inputValues.holds C) (ordinary.updateValues.holds C)
    (ordinary.startValues.holds C) (ordinary.stopValues.holds C) (ordinary.strideValues.holds C)

theorem grown_infer (C : CSrv) :
    infer (.sliceUpdate ([0,0,256,0].map Dim.lit) ([1,2,257,128].map Dim.lit) ([1,1,1,1].map Dim.lit))
      [([1,2,512,128].map Dim.lit,12),([1,2,1,128].map Dim.lit,12)] =
      M.pure (some (.node ([1,2,512,128].map Dim.lit) 12)) :=
  grown.geometry.infer 12 12 (grown.inputValues.holds C) (grown.updateValues.holds C)
    (grown.startValues.holds C) (grown.stopValues.holds C) (grown.strideValues.holds C)

theorem full_cache_rejects_append :
    ¬ NativeRoles.SliceRanges [1,2,256,128] [0,0,256,0] [1,2,257,128] := by
  intro bounds
  have impossible := bounds.2.2.2.2.2.2.2.2.1
  omega

theorem reference_is_not_literal (ν : Nat → F64) (C : CSrv) (R : Ren) (meaning : SymE) (i : Nat) :
    ¬ Host.Ts.Owned.Annotated.Cell.Holds ν C R (.literal meaning) (.num (.ref i)) := by
  intro held
  cases held

end Host.Mlx.Ffi.Annotated.KvAppendTest
