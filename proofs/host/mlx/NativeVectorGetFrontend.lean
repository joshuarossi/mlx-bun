import host.mlx.NativeVectorGetRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select a checked current vector element and its existing producer.
The target read and fixed output-slot update follow from current inventories. -/
elab "host_retained_vectorGet " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_vectorGet: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_vectorGet: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let values := ctl.getAppArgs[2]!
    let pointer ← field values ``List.cons 3 1
    let out ← field (← field pointer ``Val.ptr 2 0) ``Mem.js 1 0
    unless ← isDefEq (← field pointer ``Val.ptr 2 1) (mkNatLit 0) do throwError "host_retained_vectorGet: expected zero output pointer offset"
    let rest ← field values ``List.cons 3 2
    let handleValue ← field (← field rest ``List.cons 3 1) ``Val.big 1 0
    let handle ← mkAppM ``Int.toNat #[handleValue]
    let rest ← field rest ``List.cons 3 2
    let indexValue ← field (← field rest ``List.cons 3 1) ``Val.big 1 0
    let index ← mkAppM ``Int.toNat #[indexValue]
    unless ← isDefEq indexValue (← mkAppM ``Int.ofNat #[index]) do throwError "host_retained_vectorGet: expected nonnegative index"
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do throwError "host_retained_vectorGet: expected three arguments"
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do throwError "host_retained_vectorGet: expected FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_vector_array_get") do throwError "host_retained_vectorGet: expected mlx_vector_array_get"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do throwError "host_retained_vectorGet: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let outObject ← field (← mkAppM ``St.obj? #[s,out]) ``Option.some 2 1
    let mlx ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let vector ← field (← mkAppM ``Host.Mlx.Ffi.St.obj? #[mlx,handle]) ``Option.some 2 1
    let entries ← field vector ``Host.Mlx.Ffi.Obj.vec 1 0
    let selected ← whnf (← mkAppM ``Host.Ts.nth? #[entries,index])
    unless selected.isAppOfArity ``Option.some 2 do throwError "host_retained_vectorGet: source vector index is absent"
    let node := selected.getAppArgs[1]!
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("types",types),("signatureObject",signatureObject),("returns",returns),("sourceThis",ctl.getAppArgs[1]!),
      ("out",out),("outObject",outObject),("handle",handle),("index",index),("entries",entries),("node",node)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.handle),.big (Int.ofNat {n}.index)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str chars!\"mlx_vector_array_get\",.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array [.str chars!\"ptr\",.str chars!\"u64\",.str chars!\"u64\"]"),
    ("source_vector",s!"{n}.input.ffi.mlx.obj? {n}.handle = some (.vec {n}.entries)"),
    ("source_index",s!"nth? {n}.entries {n}.index = some {n}.node"),
    ("source_buffer",s!"{n}.input.heap.get {n}.out = some (.obj {n}.outObject)"),
    ("source_handle_allocation",s!"{n}.output.ffi.mlx.next = {n}.input.ffi.mlx.next+1"),
    ("source_node_frame",s!"{n}.output.ffi.mlx.nnext = {n}.input.ffi.mlx.nnext")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  for (fact,type) in [("source_bound",s!"{n}.input.ffi.mlx.next < 2^64"),("source_heap_bound",s!"{n}.out < 2^64")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{fact} : {type} := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (signatureFrame : ¬ framed {n}.types) (handleLive : H {n}.handle)
      (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
      (fnRole thisRole indexRole : Annotated.Value) (indexSchema : FixedIntegerRole indexRole (Int.ofNat {n}.index))
      (note : notes.runtime.control = callNote fnRole thisRole [.ptr (.js {n}.out) 0,.handle {n}.handle,indexRole])
      (selected : notes.buffers.owners {n}.out = some (handleSlotNotes 0)) :
      let newObjects := objectWrite objects {n}.input.ffi.mlx.next .stream
      let newH := fun a => a = {n}.input.ffi.mlx.next ∨ H a
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧ interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary newObjects newH N tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.nativeHandleResult {n}.out {n}.input.ffi.mlx.next) ν₀ ν C₀ C R live {n}.output result ∧
        ProducerAnnotations roots newH N roles newObjects ∧ ProducerSupport roots newH N {n}.output.ffi.mlx ∧
        ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
          (resourceImage R.handle newH) (resourceImage R.node N) result.ffi.mlx ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨sourcePost,result,left,right,post,retained,policyPost,sourceSupport,targetSupport⟩ :=
        VectorGetHost.retained_from_source ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old'
          {n}.input s h inventory {n}.address {n}.types {n}.out {n}.handle {n}.index {n}.node {n}.object {n}.signatureObject
          {n}.outObject {n}.returns {n}.sourceThis {n}.entries {n}.source_control {n}.source_heap {n}.source_kind
          {n}.source_signature {n}.signature_kind signatureFrame handleLive {n}.source_vector {n}.source_index {n}.source_buffer
          {n}.source_bound targetHandles {n}.source_heap_bound targetHeap roots policy fnRole thisRole indexRole indexSchema note selected
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained sourceSupport
      exact ⟨_,source,right,post,retained,policyPost,sourceSupport,targetSupport,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
