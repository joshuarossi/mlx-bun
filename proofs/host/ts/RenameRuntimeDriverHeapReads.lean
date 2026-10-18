import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeHeapReads
import host.ts.RenameRuntimePureScheduler
import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRuntimeStaticRead
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric

/-- Current cell/private notes fix the returned meaning. Source control,
environment and descriptor metadata select the actual original read rule. -/
elab "host_retained_heap_read " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let branch ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      let type? := if tag == "F" then none else some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F))))
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value type?
    let add (tag : String) (value : Lean.Expr) := Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.ev 2 then
      let expression ← whnf control.getAppArgs[0]!
      let env := control.getAppArgs[1]!
      add "sourceEnv" env
      if expression.isConstOf ``Expr.this then
        let a ← Parametric.Driver.field (← mkAppM ``lookupEnv #[mkConst ``nThis,env]) ``Option.some 2 1
        let initialized ← Parametric.Driver.field (← mkAppM ``St.cell? #[s,a]) ``Option.some 2 1
        let value ← Parametric.Driver.field initialized ``Option.some 2 1
        add "sourceAddress" a; add "sourceValue" value
        pure "this"
      else
        unless expression.isAppOfArity ``Expr.priv 3 do throwError "host_retained_heap_read: unsupported source expression"
        let args := expression.getAppArgs
        let brand ← Parametric.Driver.field (← mkAppM ``lookupEnv #[← mkAppM ``privName #[args[1]!],env]) ``Option.some 2 1
        for (tag,value) in [("sourceReceiver",args[0]!),("sourceName",args[1]!),("sourceOptional",args[2]!),("sourceBrand",brand)] do add tag value
        pure "descent"
    else
      let a ← Parametric.Driver.field (← Parametric.Driver.field control ``Ctl.ret 1 0) ``Val.obj 1 0
      let stack ← mkAppM ``St.stack #[s]
      let frame ← whnf (← Parametric.Driver.field (← Parametric.Driver.field stack ``List.cons 3 1) ``Frame.e 1 0)
      let brand ← Parametric.Driver.field frame ``ExprF.priv 3 0
      let name ← Parametric.Driver.field frame ``ExprF.priv 3 1
      unless (← whnf (← Parametric.Driver.field frame ``ExprF.priv 3 2)).isConstOf ``Bool.false do
        throwError "host_retained_heap_read: optional private continuation is not registered"
      let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
      let descriptor ← whnf (← Parametric.Driver.field (← mkAppM ``findPriv #[brand,name,← mkAppM ``Obj.priv #[object]]) ``Option.some 2 1)
      let value ← Parametric.Driver.field descriptor ``PropV.data 3 0
      for (tag,value) in [("sourceAddress",a),("sourceBrand",brand),("sourceName",name),("sourceObject",object),
        ("sourceValue",value),
        ("sourceWritable",← Parametric.Driver.field descriptor ``PropV.data 3 1),
        ("sourceEnumerable",← Parametric.Driver.field descriptor ``PropV.data 3 2),
        ("sourceTail",← Parametric.Driver.field stack ``List.cons 3 2)] do add tag value
      let value ← whnf value
      let staticRole := if value.isConstOf ``Val.undef then some (mkConst ``Value.undef)
        else if value.isConstOf ``Val.null then some (mkConst ``Value.null)
        else if value.isAppOfArity ``Val.bool 1 then some (mkApp (mkConst ``Value.bool) value.getAppArgs[0]!)
        else if value.isAppOfArity ``Val.str 1 then some (mkApp (mkConst ``Value.str) value.getAppArgs[0]!)
        else none
      if let some role := staticRole then
        add "sourceStaticRole" role
        pure "static"
      else pure "private"
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  let parameters := s!"(notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)"
  let (extra,postNotes,body) ← if branch == "this" then do
      fact "source_control" s!"{n}.input.ctl = .ev .this {n}.sourceEnv"
      fact "source_lookup" s!"lookupEnv nThis {n}.sourceEnv = some {n}.sourceAddress"
      fact "source_cell" s!"{n}.input.heap.get {n}.sourceAddress = some (.cell (some {n}.sourceValue))"
      pure (s!"(role : Annotated.Value) (entry : notes.runtime.cells.cells {n}.sourceAddress = some role)",
        "notes.withRuntime (notes.runtime.returning role)",s!"
      obtain ⟨value,left,right,post,runtime⟩ := inventory.runtime.this_step {n}.F FR notes.runtime ν₀ ν C₀ C R live framed
        before after old old' {n}.input s h {n}.sourceEnv {n}.sourceAddress {n}.sourceValue role
        {n}.source_control {n}.source_lookup {n}.source_cell entry
      have retained := inventory.heap_step runtime rfl rfl (TableExtends.refl C₀) (TableExtends.refl C)")
    else if branch == "descent" then do
      fact "source_control" s!"{n}.input.ctl = .ev (.priv {n}.sourceReceiver {n}.sourceName {n}.sourceOptional) {n}.sourceEnv"
      fact "source_lookup" s!"lookupEnv (privName {n}.sourceName) {n}.sourceEnv = some {n}.sourceBrand"
      pure ("",s!"notes.withRuntime (notes.runtime.privateDescent {n}.sourceReceiver {n}.sourceBrand {n}.sourceName {n}.sourceOptional {n}.sourceEnv)",s!"
      obtain ⟨left,right,post,runtime⟩ := inventory.runtime.private_descent_step {n}.F FR notes.runtime ν₀ ν C₀ C R live framed
        before after old old' {n}.input s h {n}.sourceReceiver {n}.sourceBrand {n}.sourceName {n}.sourceOptional
        {n}.sourceEnv {n}.source_control {n}.source_lookup
      have retained := inventory.heap_step runtime rfl rfl (TableExtends.refl C₀) (TableExtends.refl C)")
    else do
      fact "source_control" s!"{n}.input.ctl = .ret (.obj {n}.sourceAddress)"
      fact "source_frame" s!"{n}.input.stack = .e (.priv {n}.sourceBrand {n}.sourceName false)::{n}.sourceTail"
      fact "source_object" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
      fact "source_kind" s!"{n}.sourceObject.kind = .ordinary"
      fact "source_descriptor" s!"findPriv {n}.sourceBrand {n}.sourceName {n}.sourceObject.priv = some (.data {n}.sourceValue {n}.sourceWritable {n}.sourceEnumerable)"
      if branch == "static" then
        Parametric.Driver.emit (header ++ s!"theorem {n}.source_static : StaticValue {n}.sourceValue {n}.sourceStaticRole := by constructor")
        pure ("(headNote : Annotated.Tree) (tailNotes : List Annotated.Tree) (stackNotes : notes.runtime.stack = headNote::tailNotes)",
          "notes.withRuntime {notes.runtime with control := returnNote " ++ s!"{n}.sourceStaticRole,stack := tailNotes" ++ "}",s!"
      obtain ⟨value,frames,left,right,post,retained⟩ := inventory.private_static_read_step {n}.F FR h
        {n}.sourceAddress {n}.sourceBrand {n}.sourceName {n}.sourceValue {n}.sourceWritable {n}.sourceEnumerable
        {n}.sourceObject {n}.sourceStaticRole {n}.sourceTail headNote tailNotes {n}.source_control {n}.source_frame
        {n}.source_object {n}.source_kind {n}.source_descriptor {n}.source_static stackNotes")
      else pure (s!"(role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
        (entry : notes.privates.owners {n}.sourceAddress = some ⟨{n}.sourceBrand,{n}.sourceName,role⟩)
        (stackNotes : notes.runtime.stack = headNote::tailNotes)",
        "notes.withRuntime {notes.runtime with control := returnNote role,stack := tailNotes}",s!"
      obtain ⟨value,frames,left,right,post,runtime,_⟩ := inventory.runtime.private_read_step {n}.F FR notes.runtime notes.privates
        ν₀ ν C₀ C R live framed before after old old' {n}.input s h inventory.privates
        {n}.sourceAddress {n}.sourceBrand {n}.sourceName role {n}.sourceObject {n}.sourceValue {n}.sourceWritable
        {n}.sourceEnumerable {n}.sourceTail headNote tailNotes entry {n}.source_control {n}.source_frame
        {n}.source_object {n}.source_kind {n}.source_descriptor stackNotes
      have retained := inventory.heap_step runtime rfl rfl (TableExtends.refl C₀) (TableExtends.refl C)")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport {parameters} {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory ({postNotes}) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      {body}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
