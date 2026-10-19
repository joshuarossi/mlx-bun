import host.ts.RenameRetainedCstrCachedCall
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- Extract only current source cache metadata. Every proposed read, AST,
returned buffer and endpoint is checked against the original interpreter. -/
elab "host_retained_cstr_cached_call " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← mkAppM ``St.ctl #[s]
    let address ← Parametric.Driver.field (← Parametric.Driver.field ctl ``Ctl.call 3 0) ``Val.obj 1 0
    let receiver ← Parametric.Driver.field ctl ``Ctl.call 3 1
    let arguments ← Parametric.Driver.field ctl ``Ctl.call 3 2
    let key ← Parametric.Driver.field (← Parametric.Driver.field arguments ``List.cons 3 1) ``Val.str 1 0
    let closureObject ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let closureCode ← Parametric.Driver.field (← mkAppM ``Obj.kind #[closureObject]) ``Kind.fn 1 0
    let env ← Parametric.Driver.field closureCode ``Code.closure 4 1
    let cell (text : String) := do
      Parametric.Driver.field (← mkAppM ``lookupEnv #[toExpr text.toList,env]) ``Option.some 2 1
    let cacheCell ← cell "cstrCache"
    let cellValue (a : Lean.Expr) := do
      Parametric.Driver.field (← Parametric.Driver.field (← mkAppM ``PTrie.get #[← mkAppM ``St.heap #[s],a]) ``Option.some 2 1) ``HObj.cell 1 0
    let owner ← Parametric.Driver.field (← Parametric.Driver.field (← cellValue cacheCell) ``Option.some 2 1) ``Val.obj 1 0
    let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,owner]) ``Option.some 2 1
    let entries ← Parametric.Driver.field (← mkAppM ``Obj.kind #[object]) ``Kind.map 1 0
    let buffer ← Parametric.Driver.field (← Parametric.Driver.field
      (← mkAppM ``StringIndex.firstValue #[← mkAppM ``pack #[key],entries]) ``Option.some 2 1) ``Val.obj 1 0
    let prototype ← Parametric.Driver.field (← mkAppM ``Obj.proto #[object]) ``Val.obj 1 0
    let parent ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,prototype]) ``Option.some 2 1
    let descriptor ← Parametric.Driver.field (← mkAppM ``findProp #[mkApp (mkConst ``PKey.str) (toExpr ("get".toList)),
      ← mkAppM ``Obj.props #[parent]]) ``Option.some 2 1
    let callee ← Parametric.Driver.field (← Parametric.Driver.field descriptor ``PropV.data 3 0) ``Val.obj 1 0
    let function ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,callee]) ``Option.some 2 1
    let data ← Parametric.Driver.field (← Parametric.Driver.field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0) ``Code.native 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceEnv",env),("sourceAddress",address),("sourceThis",receiver),("sourceClosure",closureObject),
      ("sourceCacheCell",cacheCell),("sourceOwner",owner),
      ("sourceKey",key),("sourceObject",object),("sourceEntries",entries),("sourceBuffer",buffer),
      ("sourcePrototype",prototype),("sourceParent",parent),("sourceCallee",callee),("sourceFunction",function),
      ("sourceData",data),("sourceWritable",← Parametric.Driver.field descriptor ``PropV.data 3 1),
      ("sourceEnumerable",← Parametric.Driver.field descriptor ``PropV.data 3 2)] do
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
        (if tag == "input" || tag == "output" then some stateTy else none)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
    Parametric.Driver.addData (pre ++ `span) (toExpr (29 : Nat))
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .call (.obj {n}.sourceAddress) {n}.sourceThis [.str {n}.sourceKey]"
  fact "source_function" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceClosure)"
  fact "source_kind" s!"{n}.sourceClosure.kind = .fn (.closure cstrFunction {n}.sourceEnv false .undef)"
  Parametric.Driver.emit (header ++ s!"noncomputable def {n}.current : CstrCacheBefore {n}.input {n}.sourceEnv {n}.sourceKey {n}.sourceBuffer :=
    ⟨{n}.sourceCacheCell,{n}.sourceOwner,{n}.sourcePrototype,{n}.sourceCallee,
      {n}.sourceObject,{n}.sourceParent,{n}.sourceFunction,{n}.sourceEntries,{n}.sourceData,
      {n}.sourceWritable,{n}.sourceEnumerable,
      by host_kernel_rfl,by host_kernel_rfl,by host_kernel_rfl,by host_kernel_rfl,
      by host_kernel_rfl,by host_kernel_rfl,by host_kernel_rfl,by host_kernel_rfl,
      by host_kernel_rfl,by host_kernel_rfl,by host_kernel_rfl,by host_kernel_rfl⟩")
  fact "source_output" s!"cstrCallResult {n}.input {n}.sourceEnv {n}.sourceThis {n}.sourceKey {n}.sourceBuffer = {n}.output"
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+4 ≤ 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 29 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (fnRole thisRole : Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole [.str {n}.sourceKey])
      (targetBound : s.next+4 ≤ 2^64) :
      ∃ result, runC {n}.F 29 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 29 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (CellsLive (ClosureLive live {n}.input.next false .undef cstrFunction) ({n}.input.next+2) [chars!\"b\"]) framed before after old old' {n}.output result ∧
        RetainedInventory (cstrCallNotes notes {n}.input {n}.sourceEnv {n}.sourceThis {n}.sourceKey {n}.sourceBuffer thisRole)
          ν₀ ν C₀ C R (CellsLive (ClosureLive live {n}.input.next false .undef cstrFunction) ({n}.input.next+2) [chars!\"b\"]) {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained⟩ := inventory.cstr_cached_call h
        {n}.sourceAddress {n}.sourceClosure {n}.sourceEnv {n}.sourceThis {n}.sourceKey {n}.sourceBuffer {n}.current
        {n}.source_control {n}.source_function {n}.source_kind fnRole thisRole controlNote {n}.source_bound targetBound
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
