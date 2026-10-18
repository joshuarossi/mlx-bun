import host.mlx.NativeKvViewRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def kvHeader : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated in\n"

/-- Select any original four-dimensional used-prefix cache view. Source
inspection proposes only source facts; the exported theorem requires the
current fixed role/buffer inventory and pure prefix bounds, then derives the
target call, all six inventories and the new producer policy. -/
elab "host_retained_kvView " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_kvView: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_kvView: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let mut arguments := ctl.getAppArgs[2]!
    let mut values : Array Lean.Expr := #[]
    for _ in [:9] do
      values := values.push (← field arguments ``List.cons 3 1)
      arguments ← field arguments ``List.cons 3 2
    unless (← whnf arguments).isAppOfArity ``List.nil 1 do
      throwError "host_retained_kvView: expected exactly nine arguments"
    let pointer (value : Lean.Expr) := do
      let memory ← field value ``Val.ptr 2 0
      let owner ← field memory ``Mem.js 1 0
      unless ← isDefEq (← field value ``Val.ptr 2 1) (mkNatLit 0) do
        throwError "host_retained_kvView: expected zero pointer offset"
      pure owner
    let natural (value : Lean.Expr) := do mkAppM ``Int.toNat #[← field value ``Val.big 1 0]
    let out ← pointer values[0]!
    let handle ← natural values[1]!
    let start ← pointer values[2]!
    let stop ← pointer values[4]!
    let stride ← pointer values[6]!
    let stream ← natural values[8]!
    for i in [3,5,7] do
      unless ← isDefEq (← natural values[i]!) (mkNatLit 4) do
        throwError "host_retained_kvView: expected four dimensions"
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do
      throwError "host_retained_kvView: expected FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_slice") do
      throwError "host_retained_kvView: expected mlx_slice"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_kvView: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let mlx ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let producer (handle : Lean.Expr) := do
      field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[mlx,handle]) ``Option.some 2 1
    let input ← producer handle
    let nodes ← mkAppM ``Host.Mlx.Ffi.St.nodes #[mlx]
    let node ← field (← mkAppM ``PTrie.get #[nodes,input]) ``Option.some 2 1
    unless ← isDefEq (← mkAppM ``List.length #[← mkAppM ``Host.Mlx.Ffi.Node.shape #[node]]) (mkNatLit 4) do
      throwError "host_retained_kvView: expected four-dimensional input"
    let sourceNext ← mkAppM ``Host.Mlx.Ffi.St.nnext #[mlx]
    let sourceEndNative ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[t]]
    let sourceEndNext ← mkAppM ``Host.Mlx.Ffi.St.nnext #[sourceEndNative]
    let kind := if ← isDefEq sourceNext sourceEndNext then mkConst ``Host.Mlx.Ffi.NativeRoles.SliceResult.alias
      else mkConst ``Host.Mlx.Ffi.NativeRoles.SliceResult.fresh
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("types",types),("signatureObject",signatureObject),("returns",returns),("sourceThis",ctl.getAppArgs[1]!),
      ("out",out),("handle",handle),("start",start),("stop",stop),("stride",stride),("stream",stream),
      ("producer",input),("node",node),("kind",kind)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.handle),.ptr (.js {n}.start) 0,.big (Int.ofNat 4),.ptr (.js {n}.stop) 0,.big (Int.ofNat 4),.ptr (.js {n}.stride) 0,.big (Int.ofNat 4),.big (Int.ofNat {n}.stream)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str Host.Load.Run.Full.Ordinary.SliceFamilyHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array Host.Load.Run.Full.Ordinary.SliceFamilyHost.signature"),
    ("source_producers",s!"nodesOf {n}.input.ffi.mlx [{n}.handle] = some [{n}.producer]"),
    ("source_node",s!"{n}.input.ffi.mlx.nodes.get {n}.producer = some {n}.node"),
    ("source_allocation",s!"{n}.output.ffi.mlx.nnext = {n}.input.ffi.mlx.nnext + (match {n}.kind with | .fresh => 1 | .alias => 0)")]
    do Parametric.Driver.emit (kvHeader ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  for (fact,type) in [
    ("source_native_bound",s!"{n}.input.ffi.mlx.next < 2^64"),
    ("source_node_bound",s!"{n}.input.ffi.mlx.nnext < 2^64"),
    ("source_output_bound",s!"{n}.out < 2^64")]
    do Parametric.Driver.emit (kvHeader ++ s!"theorem {n}.{fact} : {type} := by decide +kernel")
  Parametric.Driver.emit (kvHeader ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (kvHeader ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (kvHeader ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (signatureFrame : ¬ framed {n}.types) (handleLive : H {n}.handle)
      (starts stops strides : List SymE) (outputShape : Shape)
      (sourceValues : KvViewValues ν₀ (roles {n}.producer).shape outputShape
        (starts.map Dimension.literal) (stops.map Dimension.literal) (strides.map Dimension.literal) {n}.kind)
      (targetValues : KvViewValues ν (roles {n}.producer).shape outputShape
        (starts.map Dimension.literal) (stops.map Dimension.literal) (strides.map Dimension.literal) {n}.kind)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
      (fnRole thisRole startCount stopCount strideCount : Annotated.Value)
      (startSchema : FixedIntegerRole startCount (Int.ofNat 4)) (stopSchema : FixedIntegerRole stopCount (Int.ofNat 4)) (strideSchema : FixedIntegerRole strideCount (Int.ofNat 4))
      (note : notes.runtime.control = callNote fnRole thisRole
        (Host.Load.Run.Full.Ordinary.SliceFamilyHost.kvViewArgumentNotes {n}.out {n}.handle {n}.start {n}.stop {n}.stride {n}.stream startCount stopCount strideCount))
      (selected : notes.buffers.owners {n}.out = some (handleSlotNotes 0))
      (selectedStart : notes.buffers.owners {n}.start = some (literalShapeByteNotes starts))
      (selectedStop : notes.buffers.owners {n}.stop = some (literalShapeByteNotes stops))
      (selectedStride : notes.buffers.owners {n}.stride = some (literalShapeByteNotes strides)) :
      let newRoles := sliceOutputRoles {n}.kind roles {n}.input.ffi.mlx.nnext {n}.producer (starts.map Dimension.literal) (stops.map Dimension.literal) (strides.map Dimension.literal) outputShape
      let newObjects := objectWrite objects {n}.input.ffi.mlx.next .stream
      let newH := fun a => a = {n}.input.ffi.mlx.next ∨ H a
      let newN := {n}.kind.support {n}.input.ffi.mlx.nnext N
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C)
          (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.nativeHandleResult {n}.out {n}.input.ffi.mlx.next) ν₀ ν C₀ C R live {n}.output result ∧
        ProducerAnnotations roots newH newN newRoles newObjects ∧
        ProducerSupport roots newH newN {n}.output.ffi.mlx ∧ Inst ν₀ {n}.nextServer C₀ := by
      have sl : starts.length = 4 := by simpa only [List.length_map,List.length_cons,List.length_nil] using sourceValues.startValues.length
      have el : stops.length = 4 := by simpa only [List.length_map,List.length_cons,List.length_nil] using sourceValues.stopValues.length
      have rl : strides.length = 4 := by simpa only [List.length_map,List.length_cons,List.length_nil] using sourceValues.strideValues.length
      have ctl : {n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis
          [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.handle),
          .ptr (.js {n}.start) 0,.big (Int.ofNat starts.length),.ptr (.js {n}.stop) 0,.big (Int.ofNat stops.length),
          .ptr (.js {n}.stride) 0,.big (Int.ofNat strides.length),.big (Int.ofNat {n}.stream)] := by
        simpa only [sl,el,rl] using {n}.source_control
      exact Host.Load.Run.Full.Ordinary.SliceFamilyHost.retained_kv_view_cut {n}.kind ν₀ ν C₀ C R roles boundary objects H N tail host
        live framed before after old old' {n}.input s h inventory {n}.address {n}.types {n}.out {n}.handle
        {n}.producer {n}.start {n}.stop {n}.stride {n}.stream {n}.object {n}.signatureObject {n}.returns {n}.sourceThis
        starts stops strides outputShape {n}.node ctl {n}.source_heap {n}.source_kind {n}.source_signature {n}.signature_kind
        signatureFrame handleLive {n}.source_producers {n}.source_node sourceValues targetValues
        {n}.source_node_bound targetNodes {n}.source_native_bound targetHandles {n}.source_output_bound targetHeap roots policy
        fnRole thisRole startCount stopCount strideCount (sl.symm ▸ startSchema) (el.symm ▸ stopSchema) (rl.symm ▸ strideSchema)
        note selected selectedStart selectedStop selectedStride {n}.output {n}.initialServer {n}.nextServer inst {n}.source_step")

end Host.Ts.Owned.Annotated.Driver
