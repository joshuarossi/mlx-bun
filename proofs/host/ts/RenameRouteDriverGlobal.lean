import host.ts.RenameRouteDriver
import host.ts.RenameParametricGlobal

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select an actual global identifier and check its source descriptor. -/
elab "host_transport_global " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let identifier ← field (← field ctl ``Ctl.ev 2 0) ``Expr.id 1 0
    let env := ctl.getAppArgs[1]!
    let obj ← field (← mkAppM ``St.obj? #[s,mkConst ``aGlobal]) ``Option.some 2 1
    let key := mkApp (mkConst ``PKey.str) identifier
    let prop ← whnf (← field (← mkAppM ``findProp #[key,← mkAppM ``Obj.props #[obj]]) ``Option.some 2 1)
    let value ← field prop ``PropV.data 3 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceName",identifier),
      ("sourceEnv",env),("sourceObject",obj),("sourceValue",value),
      ("sourceWritable",prop.getAppArgs[1]!),("sourceEnumerable",prop.getAppArgs[2]!)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ev (.id {n}.sourceName) {n}.sourceEnv"
  fact "source_local" s!"lookupEnv {n}.sourceName {n}.sourceEnv = none"
  fact "source_heap" s!"{n}.input.heap.get aGlobal = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .ordinary"
  fact "source_property" s!"findProp (.str {n}.sourceName) {n}.sourceObject.props =
    some (.data {n}.sourceValue {n}.sourceWritable {n}.sourceEnumerable)"
  fact "source_post" s!"{n}.input.ret {n}.sourceValue = {n}.output"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s)
      (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) :
      ∃ value, interpC (step {n}.F s).run C = some (s.ret value,C) ∧
        StateR NR FR R live framed before after old old' {n}.output (s.ret value) ∧ ValueR NR R {n}.sourceValue value := by
    obtain ⟨value,_,hr,hpost,hv⟩ := step_global_from_source {n}.F NR FR R C₀ C live framed before after old old'
      {n}.input s h {n}.sourceName {n}.sourceEnv {n}.sourceObject {n}.sourceValue {n}.sourceWritable
      {n}.sourceEnumerable {n}.source_control {n}.source_local {n}.source_heap {n}.source_kind {n}.source_property
      globalLive globalFixed
    rw [{n}.source_post] at hpost
    exact ⟨value,hr,hpost,hv⟩")

end Host.Ts.Owned.Parametric.Driver
