import host.ts.RenameRuntimeDriverValues
import host.ts.RuntimeInventoryDefaultBinding
import host.ts.RuntimeInventoryObjectBinding

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def patternHeader : String :=
  "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"

private def patternFact (n tag proposition : String) : CommandElabM Unit :=
  Parametric.Driver.emit (patternHeader ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")

private def patternServers (pre : Lean.Name) (initial next : Syntax) : CommandElabM Unit := liftTermElabM do
  let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
  let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
  addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
  addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])

private def patternTransport (n extra postNotes call results : String) : CommandElabM Unit := do
  patternFact n "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (patternHeader ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (patternHeader ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory ({postNotes}) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨{results}⟩ := {call}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

/-- Default-pattern dispatch observes only the source operand and saved
binding frame. Retained operand roles come from the entry inventory. -/
elab "host_retained_default_pattern " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let branch ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))))
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.bind 5 then
      let args := control.getAppArgs
      let pattern ← whnf args[0]!
      unless pattern.isAppOfArity ``Pat.dflt 2 do throwError "host_retained_default_pattern: expected default pattern"
      for (tag,value) in [("sourcePattern",pattern.getAppArgs[0]!),("sourceFallback",pattern.getAppArgs[1]!),
        ("sourceValue",args[1]!),("sourceEnv",args[2]!),("sourceMode",args[3]!),("sourceKind",args[4]!)] do add tag value
      pure (if (← whnf args[1]!).isConstOf ``Val.undef then "missing" else "present")
    else
      let value ← field control ``Ctl.ret 1 0
      let stack ← mkAppM ``St.stack #[s]
      let frame ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.b 1 0)
      unless frame.isAppOfArity ``BindF.dflt 4 do throwError "host_retained_default_pattern: expected default continuation"
      for (tag,value) in [("sourceValue",value),("sourcePattern",frame.getAppArgs[0]!),("sourceEnv",frame.getAppArgs[1]!),
        ("sourceMode",frame.getAppArgs[2]!),("sourceKind",frame.getAppArgs[3]!),("sourceTail",← field stack ``List.cons 3 2)] do add tag value
      pure "return"
  patternServers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  let base := s!"{n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h inventory"
  let (extra,postNotes,call,results) ← if branch == "return" then do
      patternFact n "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
      patternFact n "source_frame" s!"{n}.input.stack = .b (.dflt {n}.sourcePattern {n}.sourceEnv {n}.sourceMode {n}.sourceKind)::{n}.sourceTail"
      pure ("(role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
        (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = headNote::tailNotes)",
        "notes.withRuntime ({notes.runtime with stack := tailNotes}.bindingResult " ++ s!"{n}.sourcePattern role {n}.sourceEnv {n}.sourceMode {n}.sourceKind)",
        s!"RetainedInventory.default_binding_return_step {base} {n}.sourcePattern {n}.sourceValue role {n}.sourceEnv {n}.sourceMode {n}.sourceKind
          {n}.sourceTail headNote tailNotes {n}.source_control {n}.source_frame controlNote stackNotes",
        "value,frames,left,right,post,retained")
    else do
      patternFact n "source_control" s!"{n}.input.ctl = .bind (.dflt {n}.sourcePattern {n}.sourceFallback) {n}.sourceValue {n}.sourceEnv {n}.sourceMode {n}.sourceKind"
      if branch == "missing" then
        patternFact n "source_missing_control" s!"{n}.input.ctl = .bind (.dflt {n}.sourcePattern {n}.sourceFallback) .undef {n}.sourceEnv {n}.sourceMode {n}.sourceKind"
        pure ("",s!"notes.withRuntime (notes.runtime.defaultBinding {n}.sourcePattern {n}.sourceFallback {n}.sourceEnv {n}.sourceMode {n}.sourceKind)",
          s!"RetainedInventory.default_binding_missing_step {base} {n}.sourcePattern {n}.sourceFallback {n}.sourceEnv {n}.sourceMode {n}.sourceKind {n}.source_missing_control",
          "left,right,post,retained")
      else
        Parametric.Driver.emit (patternHeader ++ s!"theorem {n}.source_present : {n}.sourceValue ≠ .undef := by intro same; cases same")
        pure (s!"(role : Annotated.Value) (controlNote : notes.runtime.control = bindingNote (.dflt {n}.sourcePattern {n}.sourceFallback) role {n}.sourceEnv {n}.sourceMode {n}.sourceKind)",
          s!"notes.withRuntime (notes.runtime.bindingResult {n}.sourcePattern role {n}.sourceEnv {n}.sourceMode {n}.sourceKind)",
          s!"RetainedInventory.default_binding_present_step {base} {n}.sourcePattern {n}.sourceFallback {n}.sourceValue role {n}.sourceEnv {n}.sourceMode {n}.sourceKind {n}.source_control {n}.source_present controlNote",
          "value,left,right,post,retained")
  patternTransport n extra postNotes call results

private partial def patternStringNames (keys : Lean.Expr) : TermElabM Lean.Expr := do
  let keys ← whnf keys
  if keys.isAppOfArity ``List.nil 1 then
    pure (mkApp (mkConst ``List.nil [.zero]) (mkConst ``Host.Ts.Name))
  else
    let key ← field keys ``List.cons 3 1
    let name ← field key ``PKey.str 1 0
    let tail ← patternStringNames (← field keys ``List.cons 3 2)
    pure (mkAppN (mkConst ``List.cons [.zero]) #[mkConst ``Host.Ts.Name,name,tail])

/-- Static string-key object patterns read their actual source own data
descriptors. The object-valued field meaning is its initialized owner identity. -/
elab "host_retained_object_pattern " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let branch ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))))
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let sourceField (a key : Lean.Expr) : TermElabM Unit := do
      let name ← field (← field (← mkAppM ``keyOf #[key]) ``Option.some 2 1) ``PKey.str 1 0
      let object ← field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
      unless (← whnf (← mkAppM ``Obj.kind #[object])).isConstOf ``Kind.ordinary do
        throwError "host_retained_object_pattern: expected ordinary source owner"
      let descriptor ← field (← mkAppM ``findProp #[mkApp (mkConst ``PKey.str) name,← mkAppM ``Obj.props #[object]]) ``Option.some 2 1
      let value ← field descriptor ``PropV.data 3 0
      let owner ← field value ``Val.obj 1 0
      for (tag,value) in [("sourceName",name),("sourceObject",object),("sourceField",owner),
        ("sourceWritable",← field descriptor ``PropV.data 3 1),("sourceEnumerable",← field descriptor ``PropV.data 3 2)] do add tag value
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.bind 5 then
      let args := control.getAppArgs
      let pattern ← whnf args[0]!
      unless pattern.isAppOfArity ``Pat.object 2 do throwError "host_retained_object_pattern: expected object pattern"
      unless (← whnf pattern.getAppArgs[1]!).isAppOfArity ``Option.none 1 do
        throwError "host_retained_object_pattern: object rest requires its allocation rule"
      let first ← field pattern.getAppArgs[0]! ``List.cons 3 1
      let key ← field first ``Prod.mk 4 2
      let a ← field args[1]! ``Val.obj 1 0
      for (tag,value) in [("sourceAddress",a),("sourceKey",key),("sourcePattern",← field first ``Prod.mk 4 3),
        ("sourcePatterns",← field pattern.getAppArgs[0]! ``List.cons 3 2),("sourceEnv",args[2]!),
        ("sourceMode",args[3]!),("sourceKind",args[4]!)] do add tag value
      sourceField a key
      pure "entry"
    else
      let value ← field control ``Ctl.ret 1 0
      let stack ← mkAppM ``St.stack #[s]
      let frame ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.b 1 0)
      add "sourceValue" value
      add "sourceTail" (← field stack ``List.cons 3 2)
      if frame.isAppOfArity ``BindF.objVal 9 then
        let args := frame.getAppArgs
        unless (← whnf args[4]!).isAppOfArity ``Option.none 1 do
          throwError "host_retained_object_pattern: object rest requires its allocation rule"
        for (tag,value) in [("sourceAddress",← field args[0]! ``Val.obj 1 0),("sourceName",← field args[1]! ``PKey.str 1 0),
          ("sourcePattern",args[2]!),("sourcePatterns",args[3]!),("sourceUsed",← patternStringNames args[5]!),
          ("sourceEnv",args[6]!),("sourceMode",args[7]!),("sourceKind",args[8]!)] do add tag value
        pure "value"
      else
        unless frame.isAppOfArity ``BindF.obj 7 do throwError "host_retained_object_pattern: expected object continuation"
        let args := frame.getAppArgs
        unless (← whnf args[2]!).isAppOfArity ``Option.none 1 do
          throwError "host_retained_object_pattern: object rest requires its allocation rule"
        let a ← field args[0]! ``Val.obj 1 0
        for (tag,value) in [("sourceAddress",a),("sourceUsed",← patternStringNames args[3]!),
          ("sourceEnv",args[4]!),("sourceMode",args[5]!),("sourceKind",args[6]!)] do add tag value
        let patterns ← whnf args[1]!
        if patterns.isAppOfArity ``List.nil 1 then pure "done"
        else
          let first ← field patterns ``List.cons 3 1
          let key ← field first ``Prod.mk 4 2
          for (tag,value) in [("sourceKey",key),("sourcePattern",← field first ``Prod.mk 4 3),
            ("sourcePatterns",← field patterns ``List.cons 3 2)] do add tag value
          sourceField a key
          pure "next"
  patternServers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  let base := s!"{n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h inventory"
  let saved := "(headNote : Annotated.Tree) (tailNotes : List Annotated.Tree) (stackNotes : notes.runtime.stack = headNote::tailNotes)"
  let tuple := s!"{n}.sourceEnv {n}.sourceMode {n}.sourceKind"
  if branch == "entry" then
    patternFact n "source_control" s!"{n}.input.ctl = .bind (.object (({n}.sourceKey,{n}.sourcePattern)::{n}.sourcePatterns) none) (.obj {n}.sourceAddress) {tuple}"
  else
    patternFact n "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
    let frame := if branch == "value" then
        s!".objVal (.obj {n}.sourceAddress) (.str {n}.sourceName) {n}.sourcePattern {n}.sourcePatterns none ({n}.sourceUsed.map PKey.str) {tuple}"
      else if branch == "next" then
        s!".obj (.obj {n}.sourceAddress) (({n}.sourceKey,{n}.sourcePattern)::{n}.sourcePatterns) none ({n}.sourceUsed.map PKey.str) {tuple}"
      else s!".obj (.obj {n}.sourceAddress) [] none ({n}.sourceUsed.map PKey.str) {tuple}"
    patternFact n "source_frame" s!"{n}.input.stack = .b ({frame})::{n}.sourceTail"
  if branch == "entry" || branch == "next" then
    patternFact n "source_key" s!"keyOf {n}.sourceKey = some (.str {n}.sourceName)"
    patternFact n "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
    patternFact n "source_kind" s!"{n}.sourceObject.kind = .ordinary"
    patternFact n "source_property" s!"findProp (.str {n}.sourceName) {n}.sourceObject.props = some (.data (.obj {n}.sourceField) {n}.sourceWritable {n}.sourceEnumerable)"
  let (extra,postNotes,call,results) := if branch == "entry" then
      ("",s!"notes.withRuntime (notes.runtime.objectRead {n}.sourceAddress {n}.sourceName {n}.sourcePattern {n}.sourcePatterns [{n}.sourceName] {tuple} (.obj {n}.sourceField))",
       s!"RetainedInventory.object_binding_object_step {base} {n}.sourceKey {n}.sourceName {n}.sourcePattern {n}.sourcePatterns
         {n}.sourceAddress {n}.sourceField {n}.sourceObject {n}.sourceWritable {n}.sourceEnumerable {tuple}
         {n}.source_control {n}.source_key {n}.source_heap {n}.source_kind {n}.source_property",
       "left,right,post,retained")
    else if branch == "next" then
      (saved,"notes.withRuntime ({notes.runtime with stack := tailNotes}.objectRead " ++ s!"{n}.sourceAddress {n}.sourceName {n}.sourcePattern {n}.sourcePatterns ({n}.sourceName::{n}.sourceUsed) {tuple} (.obj {n}.sourceField))",
       s!"RetainedInventory.object_binding_next_object_step {base} {n}.sourceValue {n}.sourceKey {n}.sourceName {n}.sourcePattern {n}.sourcePatterns
         {n}.sourceAddress {n}.sourceField {n}.sourceObject {n}.sourceWritable {n}.sourceEnumerable {n}.sourceUsed {tuple}
         {n}.sourceTail headNote tailNotes {n}.source_control {n}.source_frame stackNotes {n}.source_key {n}.source_heap {n}.source_kind {n}.source_property",
       "frames,left,right,post,retained")
    else if branch == "value" then
      ("(role : Annotated.Value) " ++ saved ++ " (controlNote : notes.runtime.control = returnNote role)",
       "notes.withRuntime ({notes.runtime with stack := tailNotes}.objectBind " ++ s!"{n}.sourceAddress {n}.sourcePattern {n}.sourcePatterns {n}.sourceUsed {tuple} role)",
       s!"RetainedInventory.object_binding_value_step {base} {n}.sourceValue role {n}.sourceAddress {n}.sourceName {n}.sourcePattern {n}.sourcePatterns {n}.sourceUsed {tuple}
         {n}.sourceTail headNote tailNotes {n}.source_control {n}.source_frame controlNote stackNotes",
       "value,frames,left,right,post,retained")
    else
      (saved,"notes.withRuntime {notes.runtime with control := returnNote .undef,stack := tailNotes}",
       s!"RetainedInventory.object_binding_done_step {base} {n}.sourceValue {n}.sourceAddress {n}.sourceUsed {tuple}
         {n}.sourceTail headNote tailNotes {n}.source_control {n}.source_frame stackNotes",
       "frames,left,right,post,retained")
  patternTransport n extra postNotes call results

end Host.Ts.Owned.Annotated.Driver
