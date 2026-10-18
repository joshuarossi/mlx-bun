import host.ts.RenameRouteDriver
import host.ts.RenameParametricArrayBinding

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select real declaration, array-pattern and initialized-cell transitions.
Every selected source fact and endpoint is rechecked by the kernel. -/
elab "host_transport_binding " f:term ", " s:term " to " t:term " as " name:ident : command => do
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
    if ctl.isAppOfArity ``Ctl.bind 5 then
      let args := ctl.getAppArgs
      let pat ← whnf args[0]!
      add "sourceValue" args[1]!
      add "sourceEnv" args[2]!
      add "sourceMode" args[3]!
      add "sourceKind" args[4]!
      if pat.isAppOfArity ``Pat.array 2 then
        unless (← whnf pat.getAppArgs[1]!).isAppOfArity ``Option.none 1 do
          throwError "host_transport_binding: array rest allocation requires a separate rule"
        let a ← field args[1]! ``Val.obj 1 0
        let obj ← field (← field (← mkAppM ``PTrie.get #[← mkAppM ``St.heap #[s],a]) ``Option.some 2 1) ``HObj.obj 1 0
        let vals ← field (← mkAppM ``Obj.kind #[obj]) ``Kind.array 1 0
        for (tag,value) in [("sourcePatterns",pat.getAppArgs[0]!),("sourceAddress",a),("sourceObject",obj),("sourceValues",vals)] do
          add tag value
        pure "array"
      else if pat.isAppOfArity ``Pat.id 1 then
        unless (← whnf args[3]!).isConstOf ``BindMode.init do
          throwError "host_transport_binding: assignment requires a separate rule"
        let name := pat.getAppArgs[0]!
        let a ← field (← mkAppM ``lookupEnv #[name,args[2]!]) ``Option.some 2 1
        let prior ← field (← field (← mkAppM ``PTrie.get #[← mkAppM ``St.heap #[s],a]) ``Option.some 2 1) ``HObj.cell 1 0
        for (tag,value) in [("sourceName",name),("sourceAddress",a),("sourcePrior",prior)] do add tag value
        pure "init"
      else throwError "host_transport_binding: unsupported pattern"
    else
      let value ← field ctl ``Ctl.ret 1 0
      let stack ← mkAppM ``St.stack #[s]
      let frame ← whnf (← field stack ``List.cons 3 1)
      add "sourceValue" value
      add "sourceTail" (← field stack ``List.cons 3 2)
      if frame.isAppOfArity ``Frame.b 1 then
        let bf ← whnf frame.getAppArgs[0]!
        unless bf.isAppOfArity ``BindF.arr 6 do throwError "host_transport_binding: unsupported binding frame"
        let args := bf.getAppArgs
        unless (← whnf args[1]!).isAppOfArity ``Option.none 1 do
          throwError "host_transport_binding: array rest allocation requires a separate rule"
        for (tag,i) in [("sourcePatterns",0),("sourceValues",2),("sourceEnv",3),("sourceMode",4),("sourceKind",5)] do add tag args[i]!
        pure "next"
      else
        let st ← whnf (← field frame ``Frame.s 1 0)
        let args := st.getAppArgs
        if st.isAppOfArity ``StmtF.decl 4 then
          for (tag,i) in [("sourceKind",0),("sourcePattern",1),("sourceRest",2),("sourceEnv",3)] do add tag args[i]!
          pure "decl"
        else if st.isAppOfArity ``StmtF.declNext 3 then
          for (tag,i) in [("sourceKind",0),("sourceRest",1),("sourceEnv",2)] do add tag args[i]!
          pure "declNext"
        else throwError "host_transport_binding: unsupported declaration frame"
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  let ctl := if branch == "array" then
      s!".bind (.array {n}.sourcePatterns none) (.obj {n}.sourceAddress) {n}.sourceEnv {n}.sourceMode {n}.sourceKind"
    else if branch == "init" then
      s!".bind (.id {n}.sourceName) {n}.sourceValue {n}.sourceEnv .init {n}.sourceKind"
    else s!".ret {n}.sourceValue"
  fact "source_control" s!"{n}.input.ctl = {ctl}"
  let (extra,rule) ← if branch == "array" then do
      fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
      fact "source_kind" s!"{n}.sourceObject.kind = .array {n}.sourceValues"
      pure (s!"(notFramed : ¬ framed {n}.sourceAddress)",
        s!"step_bind_array_from_source {n}.F NR FR R C₀ C live framed before after old old' {n}.input s h
          {n}.sourcePatterns {n}.sourceAddress {n}.sourceObject {n}.sourceValues {n}.sourceEnv {n}.sourceMode
          {n}.sourceKind {n}.source_control {n}.source_heap {n}.source_kind notFramed")
    else if branch == "init" then do
      fact "source_lookup" s!"lookupEnv {n}.sourceName {n}.sourceEnv = some {n}.sourceAddress"
      fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.cell {n}.sourcePrior)"
      emit (header ++ s!"theorem {n}.source_bound : {n}.input.next ≤ 2^64 := by decide +kernel")
      pure ("(targetBound : s.next ≤ 2^64)",
        s!"step_bind_init_from_source {n}.F NR FR R C₀ C live framed before after old old' {n}.input s h
          {n}.sourceName {n}.sourceValue {n}.sourceEnv {n}.sourceKind {n}.sourceAddress {n}.sourcePrior
          {n}.source_control {n}.source_lookup {n}.source_heap {n}.source_bound targetBound")
    else if branch == "next" then do
      fact "source_frame" s!"{n}.input.stack = .b (.arr {n}.sourcePatterns none {n}.sourceValues {n}.sourceEnv
        {n}.sourceMode {n}.sourceKind) :: {n}.sourceTail"
      pure ("",s!"step_array_binding_next_from_source {n}.F NR FR R C₀ C live framed before after old old' {n}.input s h
        {n}.sourceValue {n}.sourcePatterns {n}.sourceValues {n}.sourceEnv {n}.sourceMode {n}.sourceKind
        {n}.sourceTail {n}.source_control {n}.source_frame")
    else if branch == "decl" then do
      fact "source_frame" s!"{n}.input.stack = .s (.decl {n}.sourceKind {n}.sourcePattern {n}.sourceRest {n}.sourceEnv) :: {n}.sourceTail"
      fact "source_kind" s!"isUsing {n}.sourceKind = false"
      pure ("",s!"step_declaration_value_from_source {n}.F NR FR R C₀ C live framed before after old old' {n}.input s h
        {n}.sourceValue {n}.sourceKind {n}.sourcePattern {n}.sourceRest {n}.sourceEnv {n}.sourceTail
        {n}.source_control {n}.source_frame {n}.source_kind")
    else do
      fact "source_frame" s!"{n}.input.stack = .s (.declNext {n}.sourceKind {n}.sourceRest {n}.sourceEnv) :: {n}.sourceTail"
      pure ("",s!"step_declaration_next_from_source {n}.F NR FR R C₀ C live framed before after old old' {n}.input s h
        {n}.sourceValue {n}.sourceKind {n}.sourceRest {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame")
  emit (header ++ s!"theorem {n}.source_run (C₀ : CSrv) : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by
    obtain ⟨result,hr₀,hr,hpost⟩ := {rule}
    rw [{n}.source_run] at hr₀
    have hs := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at hs
    rw [← hs] at hpost
    exact ⟨_,hr,hpost⟩")

end Host.Ts.Owned.Parametric.Driver
