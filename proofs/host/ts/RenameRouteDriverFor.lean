import host.ts.RenameRouteDriver
import host.ts.RenameParametricForInit
import host.ts.RenameParametricForControl

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Dispatch real for-loop headers and continuations. Lexical-cell copies are
proved from the source heap, including the actual per-iteration allocation. -/
elab "host_transport_for " f:term ", " s:term " to " t:term " as " name:ident : command => do
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
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    if ctl.isAppOfArity ``Ctl.ex 2 then
      let st ← whnf ctl.getAppArgs[0]!
      unless st.isAppOfArity ``Stmt.for_ 4 do throwError "host_transport_for: expected for statement"
      let init ← field st.getAppArgs[0]! ``Option.some 2 1
      let kind ← field init ``ForHead.decl 2 0
      unless (← whnf kind).isConstOf ``DeclKind.let_ do throwError "host_transport_for: expected let header"
      let pairs ← field init ``ForHead.decl 2 1
      let tail ← whnf (← field pairs ``List.cons 3 2)
      unless tail.isAppOfArity ``List.nil 1 do throwError "host_transport_for: expected one declaration"
      let pair ← field pairs ``List.cons 3 1
      let name ← field (← field pair ``Prod.mk 4 2) ``Pat.id 1 0
      let value ← field (← field pair ``Prod.mk 4 3) ``Option.some 2 1
      for (tag,v) in [("sourceName",name),("sourceInitializer",value),("sourceTest",st.getAppArgs[1]!),
        ("sourceUpdate",st.getAppArgs[2]!),("sourceBody",st.getAppArgs[3]!),("sourceEnv",ctl.getAppArgs[1]!)] do add tag v
      pure "init"
    else
      let value ← field ctl ``Ctl.ret 1 0
      add "sourceValue" value
      let stack ← mkAppM ``St.stack #[s]
      add "sourceTail" (← field stack ``List.cons 3 2)
      let lf ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.lp 1 0)
      let isTest := lf.isAppOfArity ``LoopF.forTest 7
      let isBody := lf.isAppOfArity ``LoopF.forBody 6
      unless isTest || isBody || lf.isAppOfArity ``LoopF.forUpd 6 do throwError "host_transport_for: unsupported continuation"
      let a := lf.getAppArgs
      let offset := if isTest then 1 else 0
      for (tag,i) in [("sourceTest",0),("sourceUpdate",1),("sourceBody",2),("sourceEnv",3),
        ("sourceNames",4),("sourceLabels",5)] do add tag a[offset+i]!
      let branch ← if isTest then do
          let flag ← whnf a[0]!
          if flag.isConstOf ``Bool.true then pure "copy" else if flag.isConstOf ``Bool.false then pure "test"
          else throwError "host_transport_for: expected concrete copy flag"
        else if isBody then
          add "sourceGuard" (← field value ``Val.bool 1 0)
          pure "body"
        else pure "update"
      if branch == "copy" || branch == "update" then
        let names := a[offset+4]!
        let name ← field names ``List.cons 3 1
        unless (← whnf (← field names ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
          throwError "host_transport_for: expected one per-iteration binding"
        let env := a[offset+3]!
        let cell ← field (← mkAppM ``lookupEnv #[name,env]) ``Option.some 2 1
        let val ← field (← field (← mkAppM ``St.cell? #[s,cell]) ``Option.some 2 1) ``Option.some 2 1
        for (tag,v) in [("sourceName",name),("sourceCell",cell),("sourceCellValue",val)] do add tag v
      pure branch
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  let common := s!"{n}.F NR FR R C₀ C live framed before after old old' {n}.input s h"
  let alloc := branch == "copy" || branch == "update"
  let rule ← if branch == "init" then do
      fact "source_control" s!"{n}.input.ctl = .ex (.for_ (some (.decl .let_ [(.id {n}.sourceName,some {n}.sourceInitializer)]))
        {n}.sourceTest {n}.sourceUpdate {n}.sourceBody) {n}.sourceEnv"
      emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+1 ≤ 2^64 := by decide +kernel")
      pure s!"step_for_let_from_source {common} {n}.sourceName {n}.sourceInitializer {n}.sourceTest {n}.sourceUpdate
        {n}.sourceBody {n}.sourceEnv {n}.source_control {n}.source_bound targetBound"
    else do
      let ctor := if branch == "copy" then "forTest true" else if branch == "test" then "forTest false"
        else if branch == "body" then "forBody" else "forUpd"
      let value := if branch == "body" then s!"(.bool {n}.sourceGuard)" else s!"{n}.sourceValue"
      let names := if alloc then s!"[{n}.sourceName]" else s!"{n}.sourceNames"
      fact "source_control" s!"{n}.input.ctl = .ret {value}"
      fact "source_frame" s!"{n}.input.stack = .lp (.{ctor} {n}.sourceTest {n}.sourceUpdate
        {n}.sourceBody {n}.sourceEnv {names} {n}.sourceLabels)::{n}.sourceTail"
      if alloc then
        fact "source_lookup" s!"lookupEnv {n}.sourceName {n}.sourceEnv = some {n}.sourceCell"
        fact "source_cell" s!"{n}.input.heap.get {n}.sourceCell = some (.cell (some {n}.sourceCellValue))"
        emit (header ++ s!"theorem {n}.source_bound : {n}.input.next < 2^64 := by decide +kernel")
        pure s!"step_for_{branch}_from_source {common} {n}.sourceValue {n}.sourceTest {n}.sourceUpdate
          {n}.sourceBody {n}.sourceEnv {n}.sourceName {n}.sourceLabels {n}.sourceTail {n}.sourceCell
          {n}.sourceCellValue {n}.source_control {n}.source_frame {n}.source_lookup {n}.source_cell
          {n}.source_bound targetBound"
      else
        let v := if branch == "body" then s!"{n}.sourceGuard" else s!"{n}.sourceValue"
        pure s!"step_for_{branch}_from_source {common} {v} {n}.sourceTest {n}.sourceUpdate {n}.sourceBody
          {n}.sourceEnv {n}.sourceNames {n}.sourceLabels {n}.sourceTail {n}.source_control {n}.source_frame"
  emit (header ++ s!"theorem {n}.source_run (C₀ : CSrv) : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by host_kernel_rfl")
  let extra := if branch == "init" then "(targetBound : s.next+1 ≤ 2^64)" else if alloc then "(targetBound : s.next < 2^64)" else ""
  let targetLive := if branch == "init" then s!"(CellsLive live {n}.input.next [{n}.sourceName])"
    else if alloc then s!"(LiveAfter live {n}.input.next)" else "live"
  let args := if branch == "init" then "hr₀,hr,hpost" else "result,hr₀,hr,hpost"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R {targetLive} framed before after old old' {n}.output result := by
    obtain ⟨{args}⟩ := {rule}
    rw [{n}.source_run] at hr₀
    have hs := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at hs
    rw [← hs] at hpost
    exact ⟨_,hr,hpost⟩")

end Host.Ts.Owned.Parametric.Driver
