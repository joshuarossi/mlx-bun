import host.ts.RenameParametricClassValues
import host.ts.RenameRouteDriver
namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select a real private initializer return. Source facts, the field-list
restriction and source execution are separately checked by the kernel. -/
elab "host_transport_private_initializer " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let value ← field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← field stack ``List.cons 3 1
    let fn ← whnf (← field frame ``Frame.k 1 0)
    unless fn.isAppOfArity ``FnF.privVal 5 do
      throwError "host_transport_private_initializer: expected private initializer frame"
    let args := fn.getAppArgs
    let object ← field (← mkAppM ``St.obj? #[s,args[0]!]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceValue",value),("sourceAddress",args[0]!),
      ("sourceBrand",args[1]!),("sourceName",args[2]!),("sourceMembers",args[3]!),
      ("sourceEnv",args[4]!),("sourceTail",← field stack ``List.cons 3 2),("sourceObject",object)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
  fact "source_frame" s!"{n}.input.stack = .k (.privVal {n}.sourceAddress {n}.sourceBrand {n}.sourceName {n}.sourceMembers {n}.sourceEnv)::{n}.sourceTail"
  fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .ordinary"
  emit (header ++ s!"theorem {n}.source_private : PrivateFields {n}.sourceMembers := by repeat constructor")
  emit (header ++ s!"theorem {n}.source_bound : {n}.input.next ≤ 2^64 := by decide +kernel")
  emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s)
      (bound : s.next ≤ 2^64) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result ∧
        classBodyArgument result.stack = classBodyArgument s.stack := by
    obtain ⟨v,r₀,r,_,hr₀,hr,hs,_,harg⟩ := step_private_initializer_from_source {n}.F NR FR R C₀ C
      live framed before after old old' {n}.input s h {n}.sourceValue {n}.sourceAddress {n}.sourceBrand {n}.sourceName
      {n}.sourceObject {n}.sourceMembers {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame
      {n}.source_private {n}.source_heap {n}.source_kind {n}.source_bound bound
    rw [{n}.source_run] at hr₀
    have he := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at he
    subst r₀
    exact ⟨r,hr,hs,harg⟩")

end Host.Ts.Owned.Parametric.Driver
