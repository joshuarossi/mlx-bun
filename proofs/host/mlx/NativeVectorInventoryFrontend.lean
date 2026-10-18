import host.mlx.NativeVectorDataRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def vectorHeader : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated in\n"

/-- Source decoding proposes resource labels. Kernel equations establish the
exact byte layout and original call; retained notes establish its meanings. -/
elab "host_retained_vectorData " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_vectorData: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_vectorData: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let values := ctl.getAppArgs[2]!
    let pointer ← whnf (← field values ``List.cons 3 1)
    let buffer ← field (← field pointer ``Val.ptr 2 0) ``Mem.js 1 0
    unless ← isDefEq (← field pointer ``Val.ptr 2 1) (mkNatLit 0) do
      throwError "host_retained_vectorData: expected zero pointer offset"
    let rest ← field values ``List.cons 3 2
    let count ← field (← field rest ``List.cons 3 1) ``Val.big 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_vectorData: expected exactly two arguments"
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.ffi 1 0
    unless (← whnf builtin).isConstOf ``FfiN.symbol do throwError "host_retained_vectorData: expected native FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_vector_array_new_data") do
      throwError "host_retained_vectorData: expected mlx_vector_array_new_data"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_vectorData: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let bufferObject ← field (← mkAppM ``St.obj? #[s,buffer]) ``Option.some 2 1
    let bytes ← field (← mkAppM ``Obj.kind #[bufferObject]) ``Kind.buf 1 0
    let countNat ← mkAppM ``Int.toNat #[count]
    let handles ← field (← mkAppM ``Host.Mlx.Ffi.cellsU64 #[countNat,bytes]) ``Option.some 2 1
    let world ← mkAppM ``St.ffi #[s]
    let mlx ← mkAppM ``Host.Load.LSt.mlx #[world]
    let nodes ← field (← mkAppM ``Host.Mlx.Ffi.nodesOf #[mlx,handles]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("buffer",buffer),("bufferObject",bufferObject),("types",types),("signatureObject",signatureObject),
      ("returns",returns),("sourceThis",ctl.getAppArgs[1]!),("handles",handles),("nodes",nodes)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.ptr (.js {n}.buffer) 0,.big (Int.ofNat {n}.handles.length)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str chars!\"mlx_vector_array_new_data\",.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array [.str chars!\"ptr\",.str chars!\"u64\"]"),
    ("source_bytes",s!"{n}.bufferObject.kind = .buf (VectorBuffer.bytes {n}.handles)"),
    ("source_nodes",s!"nodesOf {n}.input.ffi.mlx {n}.handles = some {n}.nodes")]
    do Parametric.Driver.emit (vectorHeader ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  Parametric.Driver.emit (vectorHeader ++ s!"theorem {n}.source_native_bound : {n}.input.ffi.mlx.next < 2^64 := by decide +kernel")
  Parametric.Driver.emit (vectorHeader ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (vectorHeader ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (vectorHeader ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (signatureFrame : ¬ framed {n}.types) (owned : listSupport H {n}.handles)
      (targetBound : s.ffi.mlx.next < 2^64) (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
      (fnRole thisRole countRole : Annotated.Value) (schema : FixedIntegerRole countRole (Int.ofNat {n}.handles.length))
      (note : notes.runtime.control = callNote fnRole thisRole [.ptr (.js {n}.buffer) 0,countRole])
      (selected : notes.buffers.owners {n}.buffer = some (handleArrayBytes {n}.handles)) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C)
          (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary
            (objectWrite objects {n}.input.ffi.mlx.next (.vec {n}.nodes))
            (fun a => a = {n}.input.ffi.mlx.next ∨ H a) N tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote (.handle {n}.input.ffi.mlx.next),notes.runtime.stack,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧
        ProducerAnnotations roots (fun a => a = {n}.input.ffi.mlx.next ∨ H a) N roles
          (objectWrite objects {n}.input.ffi.mlx.next (.vec {n}.nodes)) ∧
        ProducerSupport roots (fun a => a = {n}.input.ffi.mlx.next ∨ H a) N {n}.output.ffi.mlx ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,post,retained,policyPost,support⟩ := Host.Load.Run.Full.Ordinary.VectorDataHost.retained_from_source
        ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' {n}.input s h inventory
        {n}.address {n}.types {n}.buffer {n}.object {n}.signatureObject {n}.returns {n}.sourceThis {n}.handles {n}.nodes
        {n}.source_control {n}.source_heap {n}.source_kind {n}.source_signature {n}.signature_kind signatureFrame
        owned {n}.source_nodes {n}.source_native_bound targetBound roots policy fnRole thisRole countRole schema note selected
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained support
      exact ⟨_,source,right,post,retained,policyPost,support,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
