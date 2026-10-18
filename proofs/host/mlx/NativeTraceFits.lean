import host.mlx.AnnotatedInputs
import host.mlx.NativeBinaryRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- A fixed annotation-level signature for selecting one cached trace. A
shape-sensitive slot shares a literal shape profile; a shapeless slot shares
only rank and dtype. Numeric values may vary between paired executions. -/
inductive TraceSignature : Bool → Metadata → Metadata → Prop where
  | nil (shapeless : Bool) : TraceSignature shapeless [] []
  | literal (shapeless : Bool) (shape : Shape) (dtype : Nat) {rest inputs : Metadata}
      (exactShape : shape.Literal) (tail : TraceSignature shapeless rest inputs) :
      TraceSignature shapeless ((shape,dtype)::rest) ((shape,dtype)::inputs)
  | rank (left right : Shape) (dtype : Nat) {rest inputs : Metadata}
      (sameRank : len left = len right) (tail : TraceSignature true rest inputs) :
      TraceSignature true ((left,dtype)::rest) ((right,dtype)::inputs)

theorem TraceSignature.go {shapeless : Bool} {captured inputs : Metadata}
    (signature : TraceSignature shapeless captured inputs) {ν : Nat → F64} {C : CSrv}
    {a b : List (List Dim × Nat)} (ha : Metadata.Holds ν C captured a) (hb : Metadata.Holds ν C inputs b) :
    traceFits.go shapeless a b = M.pure true := by
  induction signature generalizing a b with
  | nil _ => cases ha; cases hb; rfl
  | literal mode shape dtype exactShape tail ih =>
    cases ha with | @cons _ a _ atail hhead ha =>
      cases hb with | @cons _ b _ bs hhead' hb =>
        rcases a with ⟨sa,da⟩
        rcases b with ⟨sb,db⟩
        rcases hhead with ⟨hsa,hda⟩
        rcases hhead' with ⟨hsb,hdb⟩
        dsimp only at hda hdb hsa hsb
        subst da; subst db
        have same := Shape.literal_unique exactShape hsa hsb
        subst sb
        cases mode <;> funext β k
        all_goals simp only [traceFits.go,Nat.beq_refl,Bool.not_true,Bool.false_or,Bool.cond_false,Bool.cond_true,
          InferenceRoles.allEq_self,ih ha hb,M.bind,M.pure]
  | rank left right dtype sameRank tail ih =>
    cases ha with | @cons _ a _ atail hhead ha =>
      cases hb with | @cons _ b _ bs hhead' hb =>
        rcases a with ⟨sa,da⟩
        rcases b with ⟨sb,db⟩
        rcases hhead with ⟨hsa,hda⟩
        rcases hhead' with ⟨hsb,hdb⟩
        dsimp only at hda hdb hsa hsb
        subst da; subst db
        have same : len sa = len sb := hsa.len_eq.symm.trans (sameRank.trans hsb.len_eq)
        simp only [traceFits.go,same,Nat.beq_refl,Bool.not_true,Bool.false_or,Bool.cond_false,Bool.cond_true,ih ha hb]

theorem TraceSignature.traceFits {shapeless : Bool} {captured inputs : Metadata}
    (signature : TraceSignature shapeless captured inputs) (s : St) (trace : Ffi.Trace) (xs : List Nat)
    {ν : Nat → F64} {C : CSrv} {a b : List (List Dim × Nat)}
    (sourceTrace : Host.Mlx.Ffi.shapesOf s trace.ins = some a) (sourceInputs : Host.Mlx.Ffi.shapesOf s xs = some b)
    (ha : Metadata.Holds ν C captured a) (hb : Metadata.Holds ν C inputs b) :
    traceFits s shapeless trace xs = M.pure true := by
  simp only [Ffi.traceFits,sourceTrace,sourceInputs]
  exact signature.go ha hb

theorem TraceSignature.findTrace {shapeless : Bool} {captured inputs : Metadata}
    (signature : TraceSignature shapeless captured inputs) (s : St) (trace : Ffi.Trace) (xs : List Nat)
    {ν : Nat → F64} {C : CSrv} {a b : List (List Dim × Nat)}
    (sourceTrace : Host.Mlx.Ffi.shapesOf s trace.ins = some a) (sourceInputs : Host.Mlx.Ffi.shapesOf s xs = some b)
    (ha : Metadata.Holds ν C captured a) (hb : Metadata.Holds ν C inputs b) :
    findTrace s shapeless xs [trace] = M.pure (some trace) := by
  rw [Ffi.findTrace,signature.traceFits s trace xs sourceTrace sourceInputs ha hb]
  rfl

def Metadata.subst (θ : Nat → SymE) (roles : Metadata) : Metadata := roles.map fun (shape,dtype) => (Shape.subst θ shape,dtype)

theorem TraceSignature.subst {shapeless : Bool} {captured inputs : Metadata}
    (signature : TraceSignature shapeless captured inputs) (θ : Nat → SymE) :
    TraceSignature shapeless (Metadata.subst θ captured) (Metadata.subst θ inputs) := by
  induction signature with
  | nil mode => exact .nil mode
  | literal mode shape dtype exactShape _ ih => exact .literal mode _ dtype (exactShape.subst θ) ih
  | rank left right dtype sameRank _ ih =>
    exact .rank _ _ dtype (by simpa only [Shape.subst,Host.Ts.len_map] using sameRank) ih

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- Both cached trace selections follow from source metadata reads and the
fixed signature. The target graph lookup is supplied by the strong indexed
native invariant, rather than an independent target execution premise. -/
theorem findTrace_signature {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (shapeless : Bool) (trace trace' : Ffi.Trace) (xs : List Nat)
    (mappedTrace : trace'.ins = trace.ins.map R.node)
    (traceLive : listSupport N trace.ins) (inputsLive : listSupport N xs)
    (signature : TraceSignature shapeless (inputRoles roles trace.ins) (inputRoles roles xs))
    (traceMeta inputsMeta : List (List Dim × Nat))
    (sourceTrace : Host.Mlx.Ffi.shapesOf s trace.ins = some traceMeta) (sourceInputs : Host.Mlx.Ffi.shapesOf s xs = some inputsMeta) :
    findTrace s shapeless xs [trace] = M.pure (some trace) ∧
      findTrace s' shapeless (xs.map R.node) [trace'] = M.pure (some trace') := by
  have weak := h.mono (fun _ _ p => p) (fun _ _ _ p => p) (fun _ _ _ p => p.base)
  obtain ⟨traceMeta',ht',hsTrace,htTrace⟩ := shapesOf_roles weak trace.ins traceMeta traceLive sourceTrace
  obtain ⟨inputsMeta',hi',hsInputs,htInputs⟩ := shapesOf_roles weak xs inputsMeta inputsLive sourceInputs
  refine ⟨signature.findTrace s trace xs sourceTrace sourceInputs hsTrace hsInputs,?_⟩
  have ht : Host.Mlx.Ffi.shapesOf s' trace'.ins = some traceMeta' := by rw [mappedTrace]; exact ht'
  exact signature.findTrace s' trace' (xs.map R.node) ht hi' htTrace htInputs

end Host.Mlx.Ffi.NativeRoles.Live
