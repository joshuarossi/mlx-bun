import host.ts.RenameRouteDriver
import host.ts.RenameParametricArrayPush

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select the original Array.push builtin and check its actual source heap,
arguments and endpoint before applying the general interpreter theorem. -/
elab "host_transport_array_push " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stateTy)
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let fn ← field (← field ctl ``Ctl.call 3 0) ``Val.obj 1 0
    let a ← field (← field ctl ``Ctl.call 3 1) ``Val.obj 1 0
    let fo ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let o ← field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
    let code ← field (← mkAppM ``Obj.kind #[fo]) ``Kind.fn 1 0
    let data ← field code ``Code.native 2 1
    let values ← field (← mkAppM ``Obj.kind #[o]) ``Kind.array 1 0
    for (tag,value) in [("sourceFunction",fn),("sourceAddress",a),("sourceCallee",fo),
      ("sourceObject",o),("sourceData",data),("sourceArgs",ctl.getAppArgs[2]!),
      ("sourceValues",values)] do add tag value
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .call (.obj {n}.sourceFunction) (.obj {n}.sourceAddress) {n}.sourceArgs"
  fact "source_callee" s!"{n}.input.heap.get {n}.sourceFunction = some (.obj {n}.sourceCallee)"
  fact "source_code" s!"{n}.sourceCallee.kind = .fn (.native (.arr .push) {n}.sourceData)"
  fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .array {n}.sourceValues"
  fact "source_extensible" s!"{n}.sourceObject.extensible = true"
  emit (header ++ s!"theorem {n}.source_bound : {n}.input.next ≤ 2^64 := by decide +kernel")
  emit (header ++ s!"theorem {n}.source_run (C₀ : CSrv) : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (notFramed : ¬ framed {n}.sourceAddress) (bound : s.next ≤ 2^64) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        result.ctl = .ret (natV (len ({n}.sourceValues++{n}.sourceArgs))) := by
    obtain ⟨result,hr₀,hr,hpost,hctl⟩ := step_array_push_from_source {n}.F FR R ν₀ ν C₀ C live framed before after old old'
      {n}.input s h {n}.sourceFunction {n}.sourceAddress {n}.sourceCallee {n}.sourceObject
      {n}.sourceData {n}.sourceArgs {n}.sourceValues {n}.source_control {n}.source_callee {n}.source_code
      {n}.source_heap {n}.source_kind {n}.source_extensible notFramed {n}.source_bound bound
    rw [{n}.source_run] at hr₀
    have he := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at he
    rw [← he] at hpost
    exact ⟨result,hr,hpost,hctl⟩")

end Host.Ts.Owned.Parametric.Driver
