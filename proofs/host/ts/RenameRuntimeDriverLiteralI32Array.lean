import host.ts.RenameRetainedLiteralI32Array
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def servers (pre : Lean.Name) (initial next : Syntax) : CommandElabM Unit := liftTermElabM do
  let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
  let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
  addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
  addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])

private def header : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"

private def sourceFacts (n : String) (facts : List (String × String)) : CommandElabM Unit := do
  for (name,type) in facts do
    Parametric.Driver.emit (header ++ s!"theorem {n}.{name} : {type} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next < 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")

elab "host_retained_literalI32Typed " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.construct 3 do throwError "host_retained_literalI32Typed: expected source construct"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let values := ctl.getAppArgs[1]!
    let arrayOwner ← field (← field values ``List.cons 3 1) ``Val.obj 1 0
    unless (← whnf (← field values ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_literalI32Typed: expected exactly one source argument"
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.buf 1 0
    unless (← whnf builtin).isConstOf ``BufN.typedCtor do throwError "host_retained_literalI32Typed: expected typedCtor callee"
    let data := code.getAppArgs[1]!
    let x ← field (← field (← field data ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    let rest ← field data ``List.cons 3 2
    let y ← field (← field (← field rest ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_literalI32Typed: expected exactly two source builtin captures"
    let proto ← field (← mkAppM ``F64.toIndex? #[y]) ``Option.some 2 1
    let arrayObject ← field (← mkAppM ``St.obj? #[s,arrayOwner]) ``Option.some 2 1
    let values ← field (← mkAppM ``Obj.kind #[arrayObject]) ``Kind.array 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("arrayOwner",arrayOwner),("arrayObject",arrayObject),("newTarget",ctl.getAppArgs[2]!),
      ("sourceValues",values),("codeLiteral",x),("protoLiteral",y),("protoIndex",proto)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  servers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  sourceFacts n [
    ("source_control",s!"{n}.input.ctl = .construct (.obj {n}.address) [.obj {n}.arrayOwner] {n}.newTarget"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.buf .typedCtor) [.num (.lit {n}.codeLiteral),.num (.lit {n}.protoLiteral)])"),
    ("source_array",s!"{n}.input.heap.get {n}.arrayOwner = some (.obj {n}.arrayObject)"),
    ("source_elements",s!"{n}.arrayObject.kind = .array ({n}.sourceValues)"),
    ("code_index",s!"F64.toIndex? {n}.codeLiteral = some 4"),
    ("proto_index",s!"F64.toIndex? {n}.protoLiteral = some {n}.protoIndex")]
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_typed_bound : {n}.input.next+1 < 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (metadata : NativeCaptureNote) (roles : List Annotated.Value) (selected : notes.captures.owners {n}.address = some metadata)
      (codeNote : metadata.roles 0 = some (.literal (.lit {n}.codeLiteral)))
      (protoNote : metadata.roles 1 = some (.literal (.lit {n}.protoLiteral)))
      (elements : notes.arrays.owners {n}.arrayOwner = some roles)
      (literalRoles : roles = (literalArrayExpressions roles).map Annotated.Value.literal)
      (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
      (protoLive : live {n}.protoIndex) (protoFixed : R.a {n}.protoIndex = {n}.protoIndex)
      (targetBound : s.next+2 ≤ 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter (LiveAfter live {n}.input.next) ({n}.input.next+1))
          framed before after old old' {n}.output result ∧
        RetainedInventory (notes.typedBytes {n}.input.next (literalI32Bytes (literalArrayExpressions roles))) ν₀ ν C₀ C R
          (LiveAfter (LiveAfter live {n}.input.next) ({n}.input.next+1)) {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,post,retained⟩ := inventory.typedArray_i32_literals_step {n}.F FR h
        {n}.address {n}.arrayOwner {n}.protoIndex {n}.object {n}.newTarget {n}.codeLiteral {n}.protoLiteral metadata roles
        {n}.source_control {n}.source_heap {n}.source_kind {n}.code_index {n}.proto_index selected codeNote protoNote
        elements literalRoles bufferProtoLive bufferProtoFixed protoLive protoFixed {n}.source_typed_bound (by omega)
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")


end Host.Ts.Owned.Annotated.Driver
