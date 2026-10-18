import host.ts.RenameParametricTryEntry
import host.ts.RenameRouteDriver
namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta
elab "host_transport_try " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← mkAppM ``St.ctl #[s]
    let st ← whnf (← field ctl ``Ctl.ex 2 0)
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceBody",← field st ``Stmt.try_ 3 0),
      ("sourceHandler",← field st ``Stmt.try_ 3 1),("sourceFinalizer",← field st ``Stmt.try_ 3 2),("sourceEnv",← field ctl ``Ctl.ex 2 1)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ex (.try_ {n}.sourceBody {n}.sourceHandler {n}.sourceFinalizer) {n}.sourceEnv := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_hoist : noInitFunctions {n}.sourceBody = true := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+(blockNames {n}.sourceBody).length ≤ 2^64 := by decide +kernel")
  emit (header ++ s!"theorem {n}.source_post : enterBlock ({n}.input.push (.s (.try_ {n}.sourceHandler {n}.sourceFinalizer {n}.sourceEnv)))
    {n}.sourceBody {n}.sourceEnv = {n}.output := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s)
      (bound : s.next+(blockNames {n}.sourceBody).length ≤ 2^64) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R (CellsLive live {n}.input.next (blockNames {n}.sourceBody)) framed before after old old' {n}.output result := by
    obtain ⟨_,hr,hs⟩ := step_try_entry_from_source {n}.F NR FR R C₀ C live framed before after old old'
      {n}.input s h {n}.sourceBody {n}.sourceHandler {n}.sourceFinalizer {n}.sourceEnv {n}.source_control
      {n}.source_hoist {n}.source_bound bound
    exact ⟨_,hr,{n}.source_post ▸ hs⟩")
end Host.Ts.Owned.Parametric.Driver
