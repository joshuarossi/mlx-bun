import host.ts.RenameRouteDriver
import host.ts.RenameParametricParameterStep

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Execute actual parameter binding/default continuations. Function-body
entry uses the checked source AST and retains its real hoisted allocation. -/
elab "host_transport_parameter " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let branch ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      let type? := if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F))))
      addData (pre ++ Name.mkSimple tag) value type?
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    add "sourceValue" (← field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0)
    let stack ← mkAppM ``St.stack #[s]
    add "sourceTail" (← field stack ``List.cons 3 2)
    let fn ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.k 1 0)
    let a := fn.getAppArgs
    if fn.isAppOfArity ``FnF.paramDflt 5 then
      for (tag,i) in [("sourceFunction",0),("sourcePattern",1),("sourceParams",2),("sourceArgs",3),("sourceEnv",4)] do add tag a[i]!
      pure "return"
    else
      unless fn.isAppOfArity ``FnF.params 4 do throwError "host_transport_parameter: unsupported function frame"
      add "sourceFunction" a[0]!
      add "sourceArgs" a[2]!
      add "sourceEnv" a[3]!
      let ps ← whnf a[1]!
      if ps.isAppOfArity ``List.nil 1 then
        let f ← whnf a[0]!
        add "sourceName" (← field f ``Func.mk 7 0)
        add "sourceParams" (← field f ``Func.mk 7 1)
        add "sourceBody" (← field (← field f ``Func.mk 7 3) ``Body.block 1 0)
        pure "body"
      else
        let p ← whnf (← field ps ``List.cons 3 1)
        add "sourceParams" (← field ps ``List.cons 3 2)
        if p.isAppOfArity ``Pat.id 1 then
          add "sourceName" p.getAppArgs[0]!
          pure "id"
        else
          add "sourcePattern" (← field p ``Pat.dflt 2 0)
          add "sourceDefault" (← field p ``Pat.dflt 2 1)
          pure "default"
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
  let common := s!"{n}.F NR FR R C₀ C live framed before after old old' {n}.input s h {n}.sourceValue"
  let rule ← if branch == "id" then do
      fact "source_frame" s!"{n}.input.stack = .k (.params {n}.sourceFunction (.id {n}.sourceName :: {n}.sourceParams)
        {n}.sourceArgs {n}.sourceEnv) :: {n}.sourceTail"
      pure s!"step_parameter_id_from_source {common} {n}.sourceFunction {n}.sourceName {n}.sourceParams
        {n}.sourceArgs {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame"
    else if branch == "default" then do
      fact "source_frame" s!"{n}.input.stack = .k (.params {n}.sourceFunction
        (.dflt {n}.sourcePattern {n}.sourceDefault :: {n}.sourceParams) {n}.sourceArgs {n}.sourceEnv) :: {n}.sourceTail"
      fact "source_default" s!"nthD .undef {n}.sourceArgs 0 = .undef"
      pure s!"step_parameter_default_from_source {common} {n}.sourceFunction {n}.sourcePattern {n}.sourceDefault
        {n}.sourceParams {n}.sourceArgs {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame {n}.source_default"
    else if branch == "return" then do
      fact "source_frame" s!"{n}.input.stack = .k (.paramDflt {n}.sourceFunction {n}.sourcePattern {n}.sourceParams
        {n}.sourceArgs {n}.sourceEnv) :: {n}.sourceTail"
      pure s!"step_parameter_default_return_from_source {common} {n}.sourceFunction {n}.sourcePattern {n}.sourceParams
        {n}.sourceArgs {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame"
    else do
      fact "source_frame" s!"{n}.input.stack = .k (.params
        (.mk {n}.sourceName {n}.sourceParams none (.block {n}.sourceBody) false false []) []
        {n}.sourceArgs {n}.sourceEnv) :: {n}.sourceTail"
      fact "source_hoist" s!"noInitFunctions {n}.sourceBody = true"
      emit (header ++ s!"theorem {n}.source_bound : {n}.input.next + (blockNames {n}.sourceBody).length ≤ 2^64 := by decide +kernel")
      pure s!"step_parameter_body_from_source {common} {n}.sourceName {n}.sourceParams {n}.sourceBody
        {n}.sourceArgs {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame {n}.source_hoist
        {n}.source_bound targetBound"
  emit (header ++ s!"theorem {n}.source_run (C₀ : CSrv) : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by host_kernel_rfl")
  let extra := if branch == "body" then s!"(targetBound : s.next + (blockNames {n}.sourceBody).length ≤ 2^64)" else ""
  let targetLive := if branch == "body" then s!"(CellsLive live {n}.input.next (blockNames {n}.sourceBody))" else "live"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R {targetLive} framed before after old old' {n}.output result := by
    obtain ⟨result,hr₀,hr,hpost⟩ := {rule}
    rw [{n}.source_run] at hr₀
    have hs := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at hs
    rw [← hs] at hpost
    exact ⟨_,hr,hpost⟩")

end Host.Ts.Owned.Parametric.Driver
