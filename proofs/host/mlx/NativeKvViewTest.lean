import host.mlx.NativeKvViewRetained
import host.ts.RenameKernelRfl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated.KvViewTest
open Host.Ts Host.Ts.Owned NativeRoles

def constant (n : Int) : SymE := .lit (F64.ofInt n)
def cache : Shape := [.literal (constant 1),.literal (constant 4),.literal (.var 0),.literal (constant 256)]
def output : Shape := [.literal (constant 1),.literal (constant 4),.literal (.var 1),.literal (constant 256)]
def starts : List SymE := [constant 0,constant 0,constant 0,constant 0]
def stops : List SymE := [constant 1,constant 4,.var 1,constant 256]
def strides : List SymE := [constant 1,constant 1,constant 1,constant 1]
def valuation (capacity used : Int) (i : Nat) : F64 := if i = 0 then F64.ofInt capacity else F64.ofInt used

def values (capacity used : Int) (kind : SliceResult)
    (capacityExact : F64.toInt? (F64.ofInt capacity) = some capacity)
    (usedExact : F64.toInt? (F64.ofInt used) = some used)
    (nonnegative : 0 ≤ used) (bound : used ≤ capacity) (branch : decide (used = capacity) = kind.same) :
    KvViewValues (valuation capacity used) cache output
      (starts.map Dimension.literal) (stops.map Dimension.literal) (strides.map Dimension.literal) kind :=
  ⟨1,4,capacity,used,256,
    .cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel)
      (.cons _ _ rfl capacityExact (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) .nil))),
    .cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel)
      (.cons _ _ rfl usedExact (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) .nil))),
    .cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel)
      (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) .nil))),
    .cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel)
      (.cons _ _ rfl usedExact (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) .nil))),
    .cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel)
      (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) (.cons _ _ rfl (by (try dsimp only [constant,SymE.eval]); decide +kernel) .nil))),
    by decide +kernel,by decide +kernel,nonnegative,by decide +kernel,bound,branch⟩

theorem prefix_infer (C : CSrv) :
    infer (.slice ([0,0,0,0].map Dim.lit) ([1,4,4,256].map Dim.lit) ([1,1,1,1].map Dim.lit))
      [([1,4,256,256].map Dim.lit,12)] = M.pure (some (.node ([1,4,4,256].map Dim.lit) 12)) := by
  let h := values 256 4 .fresh (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel)
  obtain ⟨r,hr,inference⟩ := h.geometry.infer 12 (h.inputValues.holds C)
    (h.startValues.holds C) (h.stopValues.holds C) (h.strideValues.holds C)
  rw [hr.literalValues h.outputValues.literalValues] at inference
  exact inference

theorem grown_prefix_infer (C : CSrv) :
    infer (.slice ([0,0,0,0].map Dim.lit) ([1,4,257,256].map Dim.lit) ([1,1,1,1].map Dim.lit))
      [([1,4,512,256].map Dim.lit,12)] = M.pure (some (.node ([1,4,257,256].map Dim.lit) 12)) := by
  let h := values 512 257 .fresh (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel)
  obtain ⟨r,hr,inference⟩ := h.geometry.infer 12 (h.inputValues.holds C)
    (h.startValues.holds C) (h.stopValues.holds C) (h.strideValues.holds C)
  rw [hr.literalValues h.outputValues.literalValues] at inference
  exact inference

theorem capacity_alias_infer (C : CSrv) :
    infer (.slice ([0,0,0,0].map Dim.lit) ([1,4,256,256].map Dim.lit) ([1,1,1,1].map Dim.lit))
      [([1,4,256,256].map Dim.lit,12)] = M.pure (some (.same 0)) := by
  let h := values 256 256 .alias (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel) (by (try dsimp only [constant,SymE.eval]); decide +kernel)
  obtain ⟨r,hr,inference⟩ := h.geometry.infer 12 (h.inputValues.holds C)
    (h.startValues.holds C) (h.stopValues.holds C) (h.strideValues.holds C)
  exact inference

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd Lean.Elab.Command.liftTermElabM do
  let saved ← Lean.getEnv
  try
    let source ← Lean.Elab.Term.elabTerm (← `(infer (.slice ([0,0,0,0].map Dim.lit)
      ([1,4,256,256].map Dim.lit) ([1,1,1,1].map Dim.lit)) [([1,4,256,256].map Dim.lit,12)])) none
    let wrong ← Lean.Elab.Term.elabTermEnsuringType
      (← `(M.pure (some (.node ([1,4,256,256].map Dim.lit) 12)))) (← Lean.Meta.inferType source)
    Lean.Elab.Term.synthesizeSyntheticMVarsNoPostponing
    let source ← Lean.instantiateMVars source
    let wrong ← Lean.instantiateMVars wrong
    let scopeName ← Lean.getCurrNamespace
    let type ← Lean.Meta.mkEq source wrong
    let value ← Lean.Meta.mkEqRefl source
    Lean.addDecl (.thmDecl {name := scopeName ++ `reject_fresh_at_capacity,levelParams := [],type := type,value := value})
  finally Lean.setEnv saved

theorem alias_allocates_no_node (s : Host.Mlx.Ffi.St) (input : Nat) :
    (SliceResult.alias.state s input [] [] [] [] 12).nnext = s.nnext := rfl

theorem fresh_allocates_one_node (s : Host.Mlx.Ffi.St) (input : Nat) :
    (SliceResult.fresh.state s input [] [] [] [] 12).nnext = s.nnext+1 := rfl

end Host.Mlx.Ffi.Annotated.KvViewTest
