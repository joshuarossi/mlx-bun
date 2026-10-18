import host.mlx.NativeMetalRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.MetalFamilyHost
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.Annotated

private theorem output_length {α β : Type} {rel : α → β → Prop} {xs : List α} {ys : List β}
    (held : ListR rel xs ys) : xs.length = ys.length := by
  induction held with
  | nil => rfl
  | cons _ _ ih => exact congrArg Nat.succ ih

theorem config_output_length {ν : Nat → F64} {C : CSrv} {role : Config} {config : Host.Mlx.Ffi.Cfg}
    (held : role.Holds ν C config) : role.outs.length = config.outs.length := output_length held.output
end Host.Load.Run.Full.Ordinary.MetalFamilyHost

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select an original Metal application to an existing output vector. The
current configuration and producer inventories determine the output graph. -/
elab "host_retained_metal " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_metal: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.call 3 do throwError "host_retained_metal: expected source call"
    let fn ← field control.getAppArgs[0]! ``Val.obj 1 0
    let mut rest := control.getAppArgs[2]!
    let pointer ← field (← field rest ``List.cons 3 1) ``Val.ptr 2 0
    let out ← field pointer ``Mem.js 1 0
    rest ← field rest ``List.cons 3 2
    let mut handles : Array Lean.Expr := #[]
    for _ in [:4] do
      handles := handles.push (← mkAppM ``Int.toNat #[← field (← field rest ``List.cons 3 1) ``Val.big 1 0])
      rest ← field rest ``List.cons 3 2
    unless (← whnf rest).isAppOfArity ``List.nil 1 do throwError "host_retained_metal: expected five arguments"
    let kernel := handles[0]!
    let inputs := handles[1]!
    let config := handles[2]!
    let function ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do
      throwError "host_retained_metal: expected native FFI symbol"
    let captures := code.getAppArgs[1]!
    let symbol ← field (← field captures ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_fast_metal_kernel_apply") do
      throwError "host_retained_metal: expected mlx_fast_metal_kernel_apply"
    let captures ← field captures ``List.cons 3 2
    let types ← field (← field captures ``List.cons 3 1) ``Val.obj 1 0
    let returns ← field (← field (← field captures ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0
    let signature ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let bufferObject ← field (← mkAppM ``St.obj? #[s,out]) ``Option.some 2 1
    let bytes ← field (← mkAppM ``Obj.kind #[bufferObject]) ``Kind.buf 1 0
    let cell ← field (← mkAppM ``readCell #[mkConst ``EltK.u64,bytes]) ``Option.some 2 1
    let slot ← mkAppM ``Int.toNat #[← field cell ``Cell.big 1 0]
    let nativeState ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let object (handle : Lean.Expr) := do field (← mkAppM ``Host.Mlx.Ffi.St.obj? #[nativeState,handle]) ``Option.some 2 1
    let kernelObject ← object kernel
    let sourceName ← field kernelObject ``Host.Mlx.Ffi.Obj.kernel 5 0
    let sourceCode ← field kernelObject ``Host.Mlx.Ffi.Obj.kernel 5 1
    let sourceHeader ← field kernelObject ``Host.Mlx.Ffi.Obj.kernel 5 2
    let nIn ← field kernelObject ``Host.Mlx.Ffi.Obj.kernel 5 3
    let nOut ← field kernelObject ``Host.Mlx.Ffi.Obj.kernel 5 4
    let sourceInputs ← field (← object inputs) ``Host.Mlx.Ffi.Obj.vec 1 0
    let sourceOutputs ← field (← object slot) ``Host.Mlx.Ffi.Obj.vec 1 0
    let sourceConfig ← field (← object config) ``Host.Mlx.Ffi.Obj.cfg 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("fn",fn),("out",out),("kernel",kernel),("inputs",inputs),
      ("config",config),("stream",handles[3]!),("slot",slot),("function",function),("types",types),("returns",returns),
      ("signature",signature),("bufferObject",bufferObject),("sourceName",sourceName),("sourceCode",sourceCode),
      ("sourceHeader",sourceHeader),("nIn",nIn),("nOut",nOut),("sourceInputs",sourceInputs),("sourceOutputs",sourceOutputs),
      ("sourceConfig",sourceConfig),("sourceThis",control.getAppArgs[1]!)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.fn) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.kernel),.big (Int.ofNat {n}.inputs),.big (Int.ofNat {n}.config),.big (Int.ofNat {n}.stream)]"),
    ("source_function_read",s!"{n}.input.heap.get {n}.fn = some (.obj {n}.function)"),
    ("source_function_kind",s!"{n}.function.kind = .fn (.native (.ffi .symbol) [.str MetalFamilyHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signature)"),
    ("source_signature_kind",s!"{n}.signature.kind = .array MetalFamilyHost.signature"),
    ("source_buffer_read",s!"{n}.input.heap.get {n}.out = some (.obj {n}.bufferObject)"),
    ("source_buffer_kind",s!"{n}.bufferObject.kind = .buf (cellParts .u64 (.big (Int.ofNat {n}.slot)) 8 0)"),
    ("source_kernel",s!"{n}.input.ffi.mlx.obj? {n}.kernel = some (.kernel {n}.sourceName {n}.sourceCode {n}.sourceHeader {n}.nIn {n}.nOut)"),
    ("source_inputs",s!"{n}.input.ffi.mlx.obj? {n}.inputs = some (.vec {n}.sourceInputs)"),
    ("source_outputs",s!"{n}.input.ffi.mlx.obj? {n}.slot = some (.vec {n}.sourceOutputs)"),
    ("source_config",s!"{n}.input.ffi.mlx.obj? {n}.config = some (.cfg {n}.sourceConfig)"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  for (tag,type) in [
    ("source_node_bound",s!"{n}.input.ffi.mlx.nnext + {n}.sourceConfig.outs.length < 2^64"),
    ("source_handle_bound",s!"{n}.input.ffi.mlx.next < 2^64"),
    ("source_heap_bound",s!"{n}.out < 2^64")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let nextNotes := "notes.withRuntime ⟨returnNote nativeStatusRole,notes.runtime.stack,notes.runtime.cells⟩"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (roots H N : Nat → Prop) (tail : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (policy : ProducerAnnotations roots H N roles objects)
      (signatureFrame : ¬ framed {n}.types) (kernelLive : H {n}.kernel) (inputsLive : H {n}.inputs)
      (configLive : H {n}.config) (slotLive : H {n}.slot)
      (configRole : Config) (objectRole : objects {n}.config = .config configRole)
      (targetNodes : s.ffi.mlx.nnext + configRole.outs.length < 2^64)
      (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (fnRole thisRole : Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole
        ((MetalFamilyHost.arguments {n}.out {n}.kernel {n}.inputs {n}.config {n}.stream).map FixedArgument.role))
      (slotNote : notes.buffers.owners {n}.out = some (handleSlotNotes {n}.slot)) :
      let newRoles := kernelOutputRoles roles {n}.kernel {n}.sourceInputs configRole {n}.input.ffi.mlx.nnext 0 configRole.outs
      let outputs := (MetalFamilyHost.result {n}.input.ffi {n}.kernel {n}.sourceInputs {n}.sourceConfig).2
      let newObjects := objectWrite objects {n}.slot (.vec outputs)
      let newN := outputSupport N outputs
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects H newN tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory ({nextNotes}) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ ∧
        ProducerAnnotations roots H newN newRoles newObjects ∧ ProducerSupport roots H newN {n}.output.ffi.mlx := by
      dsimp only
      obtain ⟨_,_,configHeld,_⟩ := h.native.2.config_view_roles {n}.config configLive configRole {n}.sourceConfig objectRole {n}.source_config
      have count := MetalFamilyHost.config_output_length configHeld
      have sourceNodes : {n}.input.ffi.mlx.nnext + configRole.outs.length < 2^64 := by
        rw [count]; exact {n}.source_node_bound
      obtain ⟨result,left,right,post,retained,policy',support⟩ := MetalFamilyHost.retained_from_source
        ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' {n}.input s h inventory
        {n}.fn {n}.types {n}.out {n}.kernel {n}.inputs {n}.config {n}.stream {n}.slot
        {n}.function {n}.signature {n}.bufferObject {n}.returns {n}.sourceThis
        {n}.sourceName {n}.sourceCode {n}.sourceHeader {n}.nIn {n}.nOut {n}.sourceInputs {n}.sourceOutputs configRole {n}.sourceConfig
        {n}.source_control {n}.source_function_read {n}.source_function_kind {n}.source_signature_read {n}.source_signature_kind
        {n}.source_buffer_read {n}.source_buffer_kind signatureFrame kernelLive inputsLive configLive slotLive
        {n}.source_kernel {n}.source_inputs {n}.source_outputs {n}.source_config objectRole roots policy sourceNodes targetNodes
        {n}.source_handle_bound targetHandles {n}.source_heap_bound targetHeap fnRole thisRole controlNote slotNote
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained support
      exact ⟨_,source,right,post,retained,{n}.source_servers ▸ inst,policy',support⟩")

end Host.Ts.Owned.Annotated.Driver
