import host.ts.RenameRetainedUsing
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select a current object-valued using declaration. The complete inherited
disposal lookup and nearest-scope choice are kernel-checked source facts. -/
elab "host_retained_using " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (←getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (←mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.ret 1 do throwError "host_retained_using: expected source return"
    let resource ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let stack ←mkAppM ``St.stack #[s]
    let frame ←field stack ``List.cons 3 1
    let declaration ←whnf (←field frame ``Frame.s 1 0)
    unless declaration.isAppOfArity ``StmtF.decl 4 do throwError "host_retained_using: expected declaration frame"
    unless (←whnf declaration.getAppArgs[0]!).isConstOf ``DeclKind.using do throwError "host_retained_using: expected using declaration"
    let tail ←field stack ``List.cons 3 2
    let mut frames := tail
    let mut scopeIndex := 0
    let mut found := false
    for _ in [:1024] do
      if (←whnf frames).isAppOfArity ``List.nil 1 then throwError "host_retained_using: no nearest scope"
      let head ←whnf (←field frames ``List.cons 3 1)
      if head.isAppOfArity ``Frame.s 1 && (←whnf head.getAppArgs[0]!).isAppOfArity ``StmtF.scope 1 then
        found := true
        break
      scopeIndex := scopeIndex+1
      frames ←field frames ``List.cons 3 2
    unless found do throwError "host_retained_using: no nearest scope"
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceAddress",resource),("sourcePattern",declaration.getAppArgs[1]!),
      ("sourceRest",declaration.getAppArgs[2]!),("sourceEnv",declaration.getAppArgs[3]!),("sourceTail",tail),("scopeIndex",toExpr scopeIndex)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (←mkAppM ``numberServer #[←Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (←mkAppM ``numberServer #[←Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (name type : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{name} : {type} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.obj {n}.sourceAddress)"
  fact "source_stack" s!"{n}.input.stack = .s (.decl .using {n}.sourcePattern {n}.sourceRest {n}.sourceEnv)::{n}.sourceTail"
  let rec choosePath (address : Lean.Expr) : Nat → Nat → CommandElabM String
    | 0,_ => throwError "host_retained_using: exhausted source prototype path"
    | fuel+1,index => do
      let stem := s!"{n}.path{index}"
      let found ←liftTermElabM do
        let source := mkConst (pre ++ `input)
        let object ←field (←mkAppM ``St.obj? #[source,address]) ``Option.some 2 1
        unless (←whnf (←mkAppM ``Obj.kind #[object])).isConstOf ``Kind.ordinary do
          throwError "host_retained_using: expected ordinary source disposal path"
        let property ←whnf (←mkAppM ``findProp #[←mkAppM ``PKey.sym #[toExpr symDispose],←mkAppM ``Obj.props #[object]])
        addData (pre ++ Name.mkSimple s!"path{index}Address") address
        addData (pre ++ Name.mkSimple s!"path{index}Object") object
        if property.isAppOfArity ``Option.some 2 then
          let data ←whnf property.getAppArgs[1]!
          unless data.isAppOfArity ``PropV.data 3 do throwError "host_retained_using: expected source data disposal method"
          let method ←whnf data.getAppArgs[0]!
          unless method.isAppOfArity ``Val.obj 1 do throwError "host_retained_using: expected object disposal method"
          addData (pre ++ `sourceMethod) method.getAppArgs[0]!
          addData (pre ++ `sourceWritable) data.getAppArgs[1]!
          addData (pre ++ `sourceEnumerable) data.getAppArgs[2]!
          pure (none : Option Lean.Expr)
        else
          let proto ←whnf (←mkAppM ``Obj.proto #[object])
          unless proto.isAppOfArity ``Val.obj 1 do throwError "host_retained_using: missing source disposal method"
          pure (some proto.getAppArgs[0]!)
      fact s!"path{index}Heap" s!"{n}.input.heap.get {stem}Address = some (.obj {stem}Object)"
      fact s!"path{index}Kind" s!"{stem}Object.kind = .ordinary"
      match found with
      | none =>
        fact s!"path{index}Find" s!"findProp (.sym symDispose) {stem}Object.props = some (.data (.obj {n}.sourceMethod) {n}.sourceWritable {n}.sourceEnumerable)"
        pure s!"OrdinarySymbolLookup.hit {fuel} {stem}Address {stem}Object (.data (.obj {n}.sourceMethod) {n}.sourceWritable {n}.sourceEnumerable) {stem}Heap {stem}Kind {stem}Find"
      | some next =>
        fact s!"path{index}Find" s!"findProp (.sym symDispose) {stem}Object.props = none"
        liftTermElabM <| addData (pre ++ Name.mkSimple s!"path{index}Next") next
        fact s!"path{index}NextEq" s!"{stem}Object.proto = .obj {stem}Next"
        let child ←choosePath next fuel (index+1)
        pure s!"OrdinarySymbolLookup.next {fuel} {stem}Address {stem}Next {stem}Object {stem}Heap {stem}Kind {stem}Find {stem}NextEq ({child})"
  let path ←choosePath (mkConst (pre ++ `sourceAddress)) 16 0
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_path : OrdinarySymbolLookup {n}.input symDispose 16 {n}.sourceAddress (some (.data (.obj {n}.sourceMethod) {n}.sourceWritable {n}.sourceEnumerable)) := {path}")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_scope : ScopeAt {n}.sourceTail {n}.scopeIndex := by decide +kernel")
  fact "source_run (C : CSrv)" s!"interpC (step {n}.F {n}.input).run C = some ({n}.output,C)"
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (resourceRole : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
      (controlNote : notes.runtime.control = returnNote resourceRole) (stackNotes : notes.runtime.stack = headNote::tailNotes) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.usingObject resourceRole {n}.sourceMethod {n}.sourcePattern {n}.sourceRest {n}.sourceEnv {n}.scopeIndex tailNotes)
          ν₀ ν C₀ C R live {n}.output result ∧ result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨registered,targetRegistered,left,right,post,retained⟩ := inventory.using_object_step FR h
        {n}.sourceAddress {n}.sourceMethod {n}.sourcePattern {n}.sourceRest {n}.sourceEnv {n}.sourceTail
        {n}.sourceWritable {n}.sourceEnumerable {n}.scopeIndex {n}.source_control {n}.source_stack {n}.source_path {n}.source_scope
        resourceRole headNote tailNotes controlNote stackNotes
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,rfl,rfl,rfl,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
