import host.ts.RenameRouteDriver
import host.ts.RenameParametricNamespace
import host.ts.RenameParametricArrayLiteral
import host.ts.RenameParametricStatements

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Prepare real method calls and array arguments. Source selection is merely
metaprogramming; facts and the exact endpoint are checked by the kernel. -/
elab "host_transport_preparation " f:term ", " s:term " to " t:term " as " name:ident : command => do
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
      let kind ← field st ``Stmt.decl 2 0
      let pairs ← field st ``Stmt.decl 2 1
      let pair ← whnf (← field pairs ``List.cons 3 1)
      let pat ← field pair ``Prod.mk 4 2
      let value ← field (← field pair ``Prod.mk 4 3) ``Option.some 2 1
      let rest ← field pairs ``List.cons 3 2
      add "sourceAction" (mkAppN (mkConst ``StatementAction.declarationInit) #[kind,pat,value,rest])
      add "sourceEnv" ctl.getAppArgs[1]!
      pure "statement"
    else if ctl.isAppOfArity ``Ctl.ev 2 then
      let expr ← whnf ctl.getAppArgs[0]!
      add "sourceEnv" ctl.getAppArgs[1]!
      if expr.isAppOfArity ``Expr.call 3 then
        let member ← whnf expr.getAppArgs[0]!
        unless member.isAppOfArity ``Expr.member 3 do throwError "host_transport_preparation: expected member call"
        for (tag,value) in [("sourceExpression",member.getAppArgs[0]!),("sourceName",member.getAppArgs[1]!),
          ("sourceOptObject",member.getAppArgs[2]!),("sourceArgs",expr.getAppArgs[1]!),("sourceOptCall",expr.getAppArgs[2]!)] do add tag value
        pure "methodDescent"
      else
        let elems ← field expr ``Expr.array 1 0
        add "sourceExpression" (← field (← field elems ``List.cons 3 1) ``Elem.expr 1 0)
        add "sourceRest" (← field elems ``List.cons 3 2)
        pure "arrayEntry"
    else
      let value ← field ctl ``Ctl.ret 1 0
      add "sourceValue" value
      let stack ← mkAppM ``St.stack #[s]
      let frame ← whnf (← field stack ``List.cons 3 1)
      add "sourceTail" (← field stack ``List.cons 3 2)
      if frame.isAppOfArity ``Frame.s 1 then
        let st ← whnf frame.getAppArgs[0]!
        let rest ← field st ``StmtF.block 2 0
        add "sourceStatement" (← field rest ``List.cons 3 1)
        add "sourceRest" (← field rest ``List.cons 3 2)
        add "sourceEnv" (← field st ``StmtF.block 2 1)
        pure "block"
      else if frame.isAppOfArity ``Frame.c 1 then
        let cf ← whnf frame.getAppArgs[0]!
        let a := cf.getAppArgs
        if cf.isAppOfArity ``CallF.member 5 then
          let name ← field a[0]! ``PKey.str 1 0
          let addr ← field value ``Val.obj 1 0
          let obj ← field (← mkAppM ``St.obj? #[s,addr]) ``Option.some 2 1
          for (tag,v) in [("sourceAddress",addr),("sourceObject",obj),("sourceName",name),
            ("sourceArgs",a[1]!),("sourceEnv",a[2]!),("sourceOptObject",a[3]!),("sourceOptCall",a[4]!)] do add tag v
          let kind ← whnf (← mkAppM ``Obj.kind #[obj])
          if kind.isAppOfArity ``Kind.ns 1 then
            let exports := kind.getAppArgs[0]!
            let cell ← field (← mkAppM ``findExport #[name,exports]) ``Option.some 2 1
            let value ← field (← field (← mkAppM ``St.cell? #[s,cell]) ``Option.some 2 1) ``Option.some 2 1
            for (tag,v) in [("sourceExports",exports),("sourceCell",cell),("sourceMethod",value)] do add tag v
            pure "namespace"
          else
            let prop ← whnf (← field (← mkAppM ``findProp #[a[0]!,← mkAppM ``Obj.props #[obj]]) ``Option.some 2 1)
            unless prop.isAppOfArity ``PropV.data 3 do throwError "host_transport_preparation: expected own data method"
            for (tag,v) in [("sourceMethod",prop.getAppArgs[0]!),("sourceWritable",prop.getAppArgs[1]!),("sourceEnumerable",prop.getAppArgs[2]!)] do add tag v
            pure "methodData"
        else
          unless cf.isAppOfArity ``CallF.method 4 do throwError "host_transport_preparation: unsupported call frame"
          add "sourceAddress" (← field value ``Val.obj 1 0)
          for (tag,v) in [("sourceThis",a[0]!),("sourceArgs",a[1]!),("sourceEnv",a[2]!),
            ("sourceMode",mkApp (mkConst ``CallStart.method) a[3]!)] do add tag v
          pure "callStart"
      else
        let lf ← whnf (← field frame ``Frame.l 1 0)
        unless lf.isAppOfArity ``LitF.array 3 do throwError "host_transport_preparation: unsupported literal frame"
        let a := lf.getAppArgs
        add "sourceAcc" a[0]!
        add "sourceEnv" a[2]!
        let rest ← whnf a[1]!
        if rest.isAppOfArity ``List.nil 1 then pure "arrayFinal"
        else
          add "sourceExpression" (← field (← field rest ``List.cons 3 1) ``Elem.expr 1 0)
          add "sourceRest" (← field rest ``List.cons 3 2)
          pure "arrayNext"
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  let common := s!"{n}.F NR FR R C₀ C live framed before after old old' {n}.input s h"
  let (rule,hasResult) ← if branch == "statement" then do
      fact "source_control" s!"{n}.input.ctl = .ex {n}.sourceAction.statement {n}.sourceEnv"
      pure (s!"step_statement_from_source {common} {n}.sourceAction {n}.sourceEnv {n}.source_control",false)
    else if branch == "methodDescent" then do
      fact "source_control" s!"{n}.input.ctl = .ev (.call (.member {n}.sourceExpression {n}.sourceName {n}.sourceOptObject)
        {n}.sourceArgs {n}.sourceOptCall) {n}.sourceEnv"
      pure (s!"step_method_descent_from_source {common} {n}.sourceExpression {n}.sourceName {n}.sourceArgs
        {n}.sourceEnv {n}.sourceOptObject {n}.sourceOptCall {n}.source_control",false)
    else if branch == "arrayEntry" then do
      fact "source_control" s!"{n}.input.ctl = .ev (.array (.expr {n}.sourceExpression :: {n}.sourceRest)) {n}.sourceEnv"
      pure (s!"step_array_entry_from_source {common} {n}.sourceExpression {n}.sourceRest {n}.sourceEnv {n}.source_control",false)
    else do
      fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
      if branch == "block" then
        fact "source_frame" s!"{n}.input.stack = .s (.block ({n}.sourceStatement :: {n}.sourceRest) {n}.sourceEnv) :: {n}.sourceTail"
        pure (s!"step_block_next_from_source {common} {n}.sourceValue {n}.sourceStatement {n}.sourceRest {n}.sourceEnv
          {n}.sourceTail {n}.source_control {n}.source_frame",true)
      else if branch == "methodData" || branch == "namespace" then
        fact "source_frame" s!"{n}.input.stack = .c (.member (.str {n}.sourceName) {n}.sourceArgs {n}.sourceEnv
          {n}.sourceOptObject {n}.sourceOptCall) :: {n}.sourceTail"
        fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
        if branch == "namespace" then
          fact "source_kind" s!"{n}.sourceObject.kind = .ns {n}.sourceExports"
          fact "source_export" s!"findExport {n}.sourceName {n}.sourceExports = some {n}.sourceCell"
          fact "source_cell" s!"{n}.input.heap.get {n}.sourceCell = some (.cell (some {n}.sourceMethod))"
          pure (s!"step_namespace_method_from_source {common} {n}.sourceAddress {n}.sourceObject {n}.sourceExports
            {n}.sourceName {n}.sourceArgs {n}.sourceEnv {n}.sourceOptObject {n}.sourceOptCall {n}.sourceCell
            {n}.sourceMethod {n}.sourceTail {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind
            {n}.source_export {n}.source_cell",true)
        else
          fact "source_kind" s!"{n}.sourceObject.kind = .ordinary"
          fact "source_property" s!"findProp (.str {n}.sourceName) {n}.sourceObject.props =
            some (.data {n}.sourceMethod {n}.sourceWritable {n}.sourceEnumerable)"
          pure (s!"step_method_data_from_source {common} {n}.sourceAddress {n}.sourceObject {n}.sourceName {n}.sourceArgs
            {n}.sourceEnv {n}.sourceOptObject {n}.sourceOptCall {n}.sourceMethod {n}.sourceWritable {n}.sourceEnumerable
            {n}.sourceTail {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind {n}.source_property",true)
      else if branch == "callStart" then
        fact "source_frame" s!"{n}.input.stack = {n}.sourceMode.frame {n}.sourceThis {n}.sourceArgs {n}.sourceEnv :: {n}.sourceTail"
        pure (s!"step_callStart_from_source {common} {n}.sourceMode {n}.sourceAddress {n}.sourceThis {n}.sourceArgs
          {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame",true)
      else if branch == "arrayNext" then
        fact "source_frame" s!"{n}.input.stack = .l (.array {n}.sourceAcc (.expr {n}.sourceExpression :: {n}.sourceRest)
          {n}.sourceEnv) :: {n}.sourceTail"
        pure (s!"step_array_next_from_source {common} {n}.sourceValue {n}.sourceAcc {n}.sourceExpression {n}.sourceRest
          {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame",true)
      else
        fact "source_frame" s!"{n}.input.stack = .l (.array {n}.sourceAcc [] {n}.sourceEnv) :: {n}.sourceTail"
        emit (header ++ s!"theorem {n}.source_bound : {n}.input.next < 2^64 := by decide +kernel")
        pure (s!"step_array_final_from_source {common} {n}.sourceValue {n}.sourceAcc {n}.sourceEnv {n}.sourceTail
          {n}.source_control {n}.source_frame prototypeLive prototypeFixed {n}.source_bound targetBound",true)
  emit (header ++ s!"theorem {n}.source_run (C₀ : CSrv) : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by host_kernel_rfl")
  let extras := if branch == "arrayFinal" then
    "(prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto) (targetBound : s.next < 2^64)" else ""
  let targetLive := if branch == "arrayFinal" then s!"(LiveAfter live {n}.input.next)" else "live"
  let obtainArgs := if hasResult then "result,hr₀,hr,hpost" else "hr₀,hr,hpost"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) {extras} :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R {targetLive} framed before after old old' {n}.output result := by
    obtain ⟨{obtainArgs}⟩ := {rule}
    rw [{n}.source_run] at hr₀
    have hs := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at hs
    rw [← hs] at hpost
    exact ⟨_,hr,hpost⟩")

end Host.Ts.Owned.Parametric.Driver
