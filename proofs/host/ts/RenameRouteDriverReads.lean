import host.ts.RenameRouteDriver
import host.ts.RenameParametricReads
import host.ts.RenameRouteReadFields
namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

elab "host_transport_read " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let privateRead ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stTy
    let t ← Term.elabTermEnsuringType t stTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stTy)
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let addr ← field (← field ctl ``Ctl.ret 1 0) ``Val.obj 1 0
    let stack ← mkAppM ``St.stack #[s]
    let ef ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.e 1 0)
    addData (pre ++ `sourceAddress) addr
    addData (pre ++ `sourceTail) (← field stack ``List.cons 3 2)
    if ef.isAppOfArity ``ExprF.priv 3 then
      addData (pre ++ `sourceBrand) ef.getAppArgs[0]!
      addData (pre ++ `sourceName) ef.getAppArgs[1]!
      unless (← whnf ef.getAppArgs[2]!).isConstOf ``Bool.false do throwError "host_transport_read: optional private read"
      let obj ← field (← mkAppM ``St.obj? #[s,addr]) ``Option.some 2 1
      addData (pre ++ `sourceObject) obj
      let prop ← field (← mkAppM ``findPriv #[ef.getAppArgs[0]!,ef.getAppArgs[1]!,← mkAppM ``Obj.priv #[obj]]) ``Option.some 2 1
      addData (pre ++ `sourceProperty) prop
      pure true
    else
      unless ef.isAppOfArity ``ExprF.member 2 do throwError "host_transport_read: expected member/private frame"
      addData (pre ++ `sourceName) (← field ef.getAppArgs[0]! ``PKey.str 1 0)
      unless (← whnf ef.getAppArgs[1]!).isConstOf ``Bool.false do throwError "host_transport_read: optional member read"
      pure false
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.obj {n}.sourceAddress)"
  let rule ← if privateRead then do
    fact "source_frame" s!"{n}.input.stack = .e (.priv {n}.sourceBrand {n}.sourceName false)::{n}.sourceTail"
    fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
    fact "source_kind" s!"{n}.sourceObject.kind = .ordinary"
    fact "source_property" s!"findPriv {n}.sourceBrand {n}.sourceName {n}.sourceObject.priv = some {n}.sourceProperty"
    pure s!"step_private_read_from_source {n}.F NR FR R C₀ C live framed before after old old' {n}.input s h
      {n}.sourceAddress {n}.sourceBrand {n}.sourceName {n}.sourceObject {n}.sourceProperty {n}.sourceTail
      {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind {n}.source_property"
  else do
    fact "source_frame" s!"{n}.input.stack = .e (.member (.str {n}.sourceName) false)::{n}.sourceTail"
    let rec choosePath (address : Lean.Expr) : Nat → Nat → CommandElabM String
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
          pure s!"OrdinaryLookup.hit {fuel} {stem}Address {stem}Object {n}.sourceProperty {stem}Heap {stem}Kind {stem}Find"
        | some next =>
          fact s!"path{index}Find" s!"findProp (.str {n}.sourceName) {stem}Object.props = none"
          if next.isConstOf ``Val.null then
            throwError "host_transport_read: absent-property endpoint requires separate branch"
          liftTermElabM <| addData (pre ++ Name.mkSimple s!"path{index}Next") next
          fact s!"path{index}NextEq" s!"{stem}Object.proto = .obj {stem}Next"
          let child ← choosePath next (fuel) (index+1)
          pure s!"OrdinaryLookup.next {fuel} {stem}Address {stem}Next {stem}Object {stem}Heap {stem}Kind {stem}Find {stem}NextEq ({child})"
    let path ← choosePath (mkConst (pre ++ `sourceAddress)) 16 0
    emit (header ++ s!"theorem {n}.source_path : OrdinaryLookup {n}.input {n}.sourceName 16 {n}.sourceAddress (some {n}.sourceProperty) := {path}")
    pure s!"step_member_lookup_from_source {n}.F NR FR R C₀ C live framed before after old old' {n}.input s h
      {n}.sourceAddress {n}.sourceName (some {n}.sourceProperty) {n}.sourceTail {n}.source_control {n}.source_frame {n}.source_path"
  let post := "Host.Ts.readProp " ++ s!"{n}.F " ++ "{" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}" ++ s!" (.obj {n}.sourceAddress) (some {n}.sourceProperty)"
  fact "source_post" s!"({post}) = {n}.output"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by
    obtain ⟨p,fs,_,hr,hs,_⟩ := {rule}
    exact ⟨_,hr,{n}.source_post ▸ hs⟩")
  emit (header ++ s!"theorem {n}.heap_frame (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C D : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s result : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s)
      (run : interpC (step {n}.F s).run C = some (result,D)) : result.heap = s.heap := by
    obtain ⟨p,fs,_,hr,_,_⟩ := {rule}
    have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
    have hh := congrArg St.heap he
    rw [readProp_heap] at hh
    exact hh")
end Host.Ts.Owned.Parametric.Driver
