import host.ts.RenameRouteDriver
import host.ts.RenameParametricArrayIndex

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select original bracket-evaluation continuations. Array selection uses a
fixed evaluated index whose value is established by the preceding program. -/
elab "host_transport_array_index " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let left ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stateTy)
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let value ← field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0
    add "sourceValue" value
    let stack ← mkAppM ``St.stack #[s]
    add "sourceTail" (← field stack ``List.cons 3 2)
    let ef ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.e 1 0)
    if ef.isAppOfArity ``ExprF.indexL 3 then
      for (tag,i) in [("sourceKey",0),("sourceEnv",1),("sourceOptional",2)] do add tag ef.getAppArgs[i]!
      pure true
    else
      let address ← field (← field ef ``ExprF.indexR 1 0) ``Val.obj 1 0
      let obj ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
      let values ← field (← mkAppM ``Obj.kind #[obj]) ``Kind.array 1 0
      let index ← field (← mkAppM ``numIndex #[value]) ``Option.some 2 1
      let selected ← field (← mkAppM ``nth? #[values,index]) ``Option.some 2 1
      for (tag,v) in [("sourceAddress",address),("sourceObject",obj),("sourceValues",values),
        ("sourceIndex",index),("sourceSelected",selected)] do add tag v
      pure false
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
  let common := s!"{n}.F NR FR R C₀ C live framed before after old old' {n}.input s h"
  let rule ← if left then do
      fact "source_frame" s!"{n}.input.stack = .e (.indexL {n}.sourceKey {n}.sourceEnv false)::{n}.sourceTail"
      pure s!"step_index_left_from_source {common} {n}.sourceValue {n}.sourceKey {n}.sourceEnv
        {n}.sourceTail {n}.source_control {n}.source_frame"
    else do
      fact "source_frame" s!"{n}.input.stack = .e (.indexR (.obj {n}.sourceAddress))::{n}.sourceTail"
      fact "source_index" s!"numIndex {n}.sourceValue = some {n}.sourceIndex"
      fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
      fact "source_kind" s!"{n}.sourceObject.kind = .array {n}.sourceValues"
      fact "source_selected" s!"nth? {n}.sourceValues {n}.sourceIndex = some {n}.sourceSelected"
      pure s!"step_array_index_from_source {common} {n}.sourceValue {n}.sourceAddress {n}.sourceIndex
        {n}.sourceObject {n}.sourceValues {n}.sourceSelected {n}.sourceTail {n}.source_control
        {n}.source_frame {n}.source_index {n}.source_heap {n}.source_kind {n}.source_selected notFramed fixedIndex"
  emit (header ++ s!"theorem {n}.source_run (C₀ : CSrv) : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by host_kernel_rfl")
  let extra := if left then "" else s!"(notFramed : ¬ framed {n}.sourceAddress) (fixedIndex : s.ctl = .ret {n}.sourceValue)"
  let args := if left then "result,hr₀,hr,hpost" else "value,result,hr₀,hr,hpost,_"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by
    obtain ⟨{args}⟩ := {rule}
    rw [{n}.source_run] at hr₀
    have hs := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at hs
    rw [← hs] at hpost
    exact ⟨result,hr,hpost⟩")

end Host.Ts.Owned.Parametric.Driver
