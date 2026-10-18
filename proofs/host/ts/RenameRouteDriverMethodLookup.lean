import host.ts.RenameRouteDriver
import host.ts.RenameParametricRegistry
namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select an actual ordinary prototype path for method lookup. -/
elab "host_transport_method_lookup " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let add (tag : String) (v : Lean.Expr) := addData (pre ++ Name.mkSimple tag) v
    for (tag,v) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) v (if tag == "F" then none else some stateTy)
    let a ← field (← field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0) ``Val.obj 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← whnf (← field stack ``List.cons 3 1)
    unless frame.isAppOfArity ``Frame.c 1 do throwError "host_transport_method_lookup: expected method lookup continuation"
    let cf ← whnf frame.getAppArgs[0]!
    unless cf.isAppOfArity ``CallF.member 5 do throwError "host_transport_method_lookup: expected method lookup continuation"
    let name ← field cf.getAppArgs[0]! ``PKey.str 1 0
    for (tag,v) in [("sourceAddress",a),("sourceName",name),("sourceArgs",cf.getAppArgs[1]!),
      ("sourceEnv",cf.getAppArgs[2]!),("sourceOptObject",cf.getAppArgs[3]!),
      ("sourceOptCall",cf.getAppArgs[4]!),("sourceTail",← field stack ``List.cons 3 2)] do add tag v
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag p : String) := emit (header ++ s!"theorem {n}.{tag} : {p} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.obj {n}.sourceAddress)"
  fact "source_frame" s!"{n}.input.stack = .c (.member (.str {n}.sourceName) {n}.sourceArgs {n}.sourceEnv {n}.sourceOptObject {n}.sourceOptCall)::{n}.sourceTail"
  let rec choosePath (address : Lean.Expr) : Nat → Nat → CommandElabM (String × Bool)
    | 0, _ => throwError "host_transport_read: exhausted prototype path"
    | fuel+1, index => do
      let stem := s!"{n}.path{index}"
      let found ← liftTermElabM do
        let source := mkConst (pre ++ `input)
        let obj ← field (← mkAppM ``St.obj? #[source,address]) ``Option.some 2 1
        let property ← whnf (← mkAppM ``findProp #[mkApp (mkConst ``PKey.str) (mkConst (pre ++ `sourceName)),← mkAppM ``Obj.props #[obj]])
        addData (pre ++ Name.mkSimple s!"path{index}Address") address
        addData (pre ++ Name.mkSimple s!"path{index}Object") obj
        addData (pre ++ Name.mkSimple s!"path{index}Property") property
        if property.isAppOfArity ``Option.some 2 then pure (none : Option Lean.Expr)
        else
          let proto ← whnf (← mkAppM ``Obj.proto #[obj])
          if proto.isConstOf ``Val.null then pure (some (mkConst ``Val.null))
          else pure (some (← field proto ``Val.obj 1 0))
      fact s!"path{index}Heap" s!"{n}.input.heap.get {stem}Address = some (.obj {stem}Object)"
      fact s!"path{index}Kind" s!"{stem}Object.kind = .ordinary"
      match found with
      | none =>
        liftTermElabM do
          let value ← field (mkConst (pre ++ Name.mkSimple s!"path{index}Property")) ``Option.some 2 1
          addData (pre ++ `sourceProperty) value
        fact s!"path{index}Find" s!"findProp (.str {n}.sourceName) {stem}Object.props = some {n}.sourceProperty"
        pure (s!"OrdinaryLookup.hit {fuel} {stem}Address {stem}Object {n}.sourceProperty {stem}Heap {stem}Kind {stem}Find",false)
      | some next =>
        fact s!"path{index}Find" s!"findProp (.str {n}.sourceName) {stem}Object.props = none"
        if next.isConstOf ``Val.null then
          fact s!"path{index}Null" s!"{stem}Object.proto = .null"
          return (s!"OrdinaryLookup.stop {fuel} {stem}Address {stem}Object {stem}Heap {stem}Kind {stem}Find {stem}Null",true)
        liftTermElabM <| addData (pre ++ Name.mkSimple s!"path{index}Next") next
        fact s!"path{index}NextEq" s!"{stem}Object.proto = .obj {stem}Next"
        let (child,missing) ← choosePath next (fuel) (index+1)
        pure (s!"OrdinaryLookup.next {fuel} {stem}Address {stem}Next {stem}Object {stem}Heap {stem}Kind {stem}Find {stem}NextEq ({child})",missing)
  let (path,missing) ← choosePath (mkConst (pre ++ `sourceAddress)) 16 0
  let property := if missing then "none" else s!"(some {n}.sourceProperty)"
  emit (header ++ s!"theorem {n}.source_path : OrdinaryLookup {n}.input {n}.sourceName 16 {n}.sourceAddress {property} := {path}")
  let post := "Host.Ts.readProp " ++ s!"{n}.F ((" ++ "{" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}" ++ s!".push (.c (.method (.obj {n}.sourceAddress) {n}.sourceArgs {n}.sourceEnv {n}.sourceOptCall)))) (.obj {n}.sourceAddress) {property}"
  fact "source_post" s!"({post}) = {n}.output"
  let rule := s!"step_method_lookup_from_source {n}.F NR FR R C₀ C live framed before after old old' {n}.input s h {n}.sourceAddress {n}.sourceName {n}.sourceArgs {n}.sourceEnv {n}.sourceOptObject {n}.sourceOptCall {property} {n}.sourceTail {n}.source_control {n}.source_frame {n}.source_path"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by
    obtain ⟨p,fs,_,run,related⟩ := {rule}
    exact ⟨_,run,{n}.source_post ▸ related⟩")
  emit (header ++ s!"theorem {n}.heap_frame (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C D : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s result : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s)
      (run : interpC (step {n}.F s).run C = some (result,D)) : result.heap = s.heap := by
    obtain ⟨p,fs,_,hr,_⟩ := {rule}
    have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
    have hh := congrArg St.heap he
    rw [readProp_heap] at hh
    exact hh")
end Host.Ts.Owned.Parametric.Driver
