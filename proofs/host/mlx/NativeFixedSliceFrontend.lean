import host.mlx.NativeLiteralSliceRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def fixedSliceHeader : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated in\n"

/-- Select an original fixed three-dimensional unit-stride view. Source
inspection proposes only source facts; the exported theorem requires the
current fixed role/buffer inventory. Source-certified constant geometry then
derives the target call, all six inventories and the new producer policy. -/
elab "host_retained_fixedSlice " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_fixedSlice: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_fixedSlice: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let mut arguments := ctl.getAppArgs[2]!
    let mut values : Array Lean.Expr := #[]
    for _ in [:9] do
      values := values.push (← field arguments ``List.cons 3 1)
      arguments ← field arguments ``List.cons 3 2
    unless (← whnf arguments).isAppOfArity ``List.nil 1 do
      throwError "host_retained_fixedSlice: expected exactly nine arguments"
    let pointer (value : Lean.Expr) := do
      let memory ← field value ``Val.ptr 2 0
      let owner ← field memory ``Mem.js 1 0
      unless ← isDefEq (← field value ``Val.ptr 2 1) (mkNatLit 0) do
        throwError "host_retained_fixedSlice: expected zero pointer offset"
      pure owner
    let natural (value : Lean.Expr) := do mkAppM ``Int.toNat #[← field value ``Val.big 1 0]
    let out ← pointer values[0]!
    let handle ← natural values[1]!
    let start ← pointer values[2]!
    let stop ← pointer values[4]!
    let stride ← pointer values[6]!
    let stream ← natural values[8]!
    for i in [3,5,7] do
      unless ← isDefEq (← natural values[i]!) (mkNatLit 3) do
        throwError "host_retained_fixedSlice: expected three dimensions"
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do
      throwError "host_retained_fixedSlice: expected FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_slice") do
      throwError "host_retained_fixedSlice: expected mlx_slice"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_fixedSlice: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let mlx ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let producer (handle : Lean.Expr) := do
      field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[mlx,handle]) ``Option.some 2 1
    let input ← producer handle
    let nodes ← mkAppM ``Host.Mlx.Ffi.St.nodes #[mlx]
    let node ← field (← mkAppM ``PTrie.get #[nodes,input]) ``Option.some 2 1
    unless ← isDefEq (← mkAppM ``List.length #[← mkAppM ``Host.Mlx.Ffi.Node.shape #[node]]) (mkNatLit 3) do
      throwError "host_retained_fixedSlice: expected three-dimensional input"
    let integers (dimensions : Lean.Expr) := do
      let mut rest := dimensions
      let mut result : Array Lean.Expr := #[]
      while !(← whnf rest).isAppOfArity ``List.nil 1 do
        let dimension ← field rest ``List.cons 3 1
        result := result.push (← field dimension ``Host.Mlx.Ffi.Dim.lit 1 0)
        rest ← field rest ``List.cons 3 2
      mkListLit (mkConst ``Int) result.toList
    let inputSizes ← integers (← mkAppM ``Host.Mlx.Ffi.Node.shape #[node])
    let dimensionBuffer (owner : Lean.Expr) := do
      let object ← field (← mkAppM ``St.obj? #[s,owner]) ``Option.some 2 1
      let bytes ← field (← mkAppM ``Obj.kind #[object]) ``Kind.buf 1 0
      let argument ← mkAppM ``Arg.jsPtr #[owner,mkNatLit 0,bytes]
      let count ← mkAppM ``Arg.big #[← mkAppM ``Int.ofNat #[mkNatLit 3]]
      let dimensions ← integers (← field (← mkAppM ``Host.Mlx.Ffi.dimsArg #[argument,count]) ``Option.some 2 1)
      pure (object,dimensions)
    let (startObject,first) ← dimensionBuffer start
    let (stopObject,last) ← dimensionBuffer stop
    let (strideObject,steps) ← dimensionBuffer stride
    unless ← isDefEq steps (← mkListLit (mkConst ``Int) [toExpr (1 : Int),toExpr (1 : Int),toExpr (1 : Int)]) do
      throwError "host_retained_fixedSlice: expected unit strides"
    let extents ← mkAppM ``Host.Mlx.Ffi.NativeRoles.sliceExtents #[first,last]
    let kind := if ← isDefEq extents inputSizes then mkConst ``Host.Mlx.Ffi.NativeRoles.SliceResult.alias
      else mkConst ``Host.Mlx.Ffi.NativeRoles.SliceResult.fresh
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("types",types),("signatureObject",signatureObject),("returns",returns),("sourceThis",ctl.getAppArgs[1]!),
      ("out",out),("handle",handle),("start",start),("stop",stop),("stride",stride),("stream",stream),
      ("producer",input),("node",node),("kind",kind),("inputSizes",inputSizes),("first",first),("last",last),
      ("startObject",startObject),("stopObject",stopObject),("strideObject",strideObject)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.handle),.ptr (.js {n}.start) 0,.big (Int.ofNat 3),.ptr (.js {n}.stop) 0,.big (Int.ofNat 3),.ptr (.js {n}.stride) 0,.big (Int.ofNat 3),.big (Int.ofNat {n}.stream)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str Host.Load.Run.Full.Ordinary.SliceFamilyHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array Host.Load.Run.Full.Ordinary.SliceFamilyHost.signature"),
    ("source_producers",s!"nodesOf {n}.input.ffi.mlx [{n}.handle] = some [{n}.producer]"),
    ("source_node",s!"{n}.input.ffi.mlx.nodes.get {n}.producer = some {n}.node"),
    ("source_input_shape",s!"{n}.node.shape = {n}.inputSizes.map Dim.lit"),
    ("source_start",s!"{n}.input.heap.get {n}.start = some (.obj {n}.startObject)"),
    ("source_stop",s!"{n}.input.heap.get {n}.stop = some (.obj {n}.stopObject)"),
    ("source_stride",s!"{n}.input.heap.get {n}.stride = some (.obj {n}.strideObject)"),
    ("start_kind",s!"{n}.startObject.kind = .buf (shapeBytes ({n}.first.map Dim.lit))"),
    ("stop_kind",s!"{n}.stopObject.kind = .buf (shapeBytes ({n}.last.map Dim.lit))"),
    ("stride_kind",s!"{n}.strideObject.kind = .buf (shapeBytes ((List.replicate {n}.inputSizes.length 1).map Dim.lit))"),
    ("source_allocation",s!"{n}.output.ffi.mlx.nnext = {n}.input.ffi.mlx.nnext + (match {n}.kind with | .fresh => 1 | .alias => 0)")]
    do Parametric.Driver.emit (fixedSliceHeader ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  for (fact,type) in [
    ("source_native_bound",s!"{n}.input.ffi.mlx.next < 2^64"),
    ("source_node_bound",s!"{n}.input.ffi.mlx.nnext < 2^64"),
    ("source_output_bound",s!"{n}.out < 2^64"),
    ("out_ne_start",s!"{n}.out ≠ {n}.start"),("out_ne_stop",s!"{n}.out ≠ {n}.stop"),
    ("out_ne_stride",s!"{n}.out ≠ {n}.stride"),("stop_ne_start",s!"{n}.stop ≠ {n}.start"),
    ("stride_ne_start",s!"{n}.stride ≠ {n}.start"),("stride_ne_stop",s!"{n}.stride ≠ {n}.stop")]
    do Parametric.Driver.emit (fixedSliceHeader ++ s!"theorem {n}.{fact} : {type} := by decide +kernel")
  for (fact,type) in [
    ("input_exact",s!"ExactDimensions {n}.inputSizes"),("start_exact",s!"ExactDimensions {n}.first"),
    ("stop_exact",s!"ExactDimensions {n}.last"),("output_exact",s!"ExactDimensions (sliceExtents {n}.first {n}.last)"),
    ("source_bounds",s!"SliceRanges {n}.inputSizes {n}.first {n}.last"),
    ("source_branch",s!"decide (sliceExtents {n}.first {n}.last = {n}.inputSizes) = {n}.kind.same")]
    do Parametric.Driver.emit (fixedSliceHeader ++ s!"theorem {n}.{fact} : {type} := by decide +kernel")
  Parametric.Driver.emit (fixedSliceHeader ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (fixedSliceHeader ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (fixedSliceHeader ++ s!"theorem {n}.retained_transport
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
      (inputSchema : (roles {n}.producer).shape = constantShape {n}.inputSizes)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
      (fnRole thisRole startCount stopCount strideCount : Annotated.Value)
      (startSchema : FixedIntegerRole startCount (Int.ofNat 3)) (stopSchema : FixedIntegerRole stopCount (Int.ofNat 3)) (strideSchema : FixedIntegerRole strideCount (Int.ofNat 3))
      (note : notes.runtime.control = callNote fnRole thisRole
        (Host.Load.Run.Full.Ordinary.SliceFamilyHost.literalSliceArgumentNotes {n}.out {n}.handle {n}.start {n}.stop {n}.stride {n}.stream startCount stopCount strideCount))
      (selected : notes.buffers.owners {n}.out = some (handleSlotNotes 0))
      (selectedStart : notes.buffers.owners {n}.start = some (literalShapeByteNotes (constantExpressions {n}.first)))
      (selectedStop : notes.buffers.owners {n}.stop = some (literalShapeByteNotes (constantExpressions {n}.last)))
      (selectedStride : notes.buffers.owners {n}.stride = some (literalShapeByteNotes (constantExpressions (List.replicate {n}.inputSizes.length 1)))) :
      let newRoles := sliceOutputRoles {n}.kind roles {n}.input.ffi.mlx.nnext {n}.producer (constantShape {n}.first) (constantShape {n}.last) (constantShape (List.replicate {n}.inputSizes.length 1)) (constantShape (sliceExtents {n}.first {n}.last))
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
      let starts := constantExpressions {n}.first
      let stops := constantExpressions {n}.last
      let strides := constantExpressions (List.replicate {n}.inputSizes.length 1)
      have sourceValues := LiteralSliceValues.constants ν₀ {n}.inputSizes {n}.first {n}.last {n}.kind
        {n}.input_exact {n}.start_exact {n}.stop_exact {n}.output_exact {n}.source_bounds {n}.source_branch
      have targetValues := LiteralSliceValues.constants ν {n}.inputSizes {n}.first {n}.last {n}.kind
        {n}.input_exact {n}.start_exact {n}.stop_exact {n}.output_exact {n}.source_bounds {n}.source_branch
      have sl : starts.length = 3 := by host_kernel_rfl
      have el : stops.length = 3 := by host_kernel_rfl
      have rl : strides.length = 3 := by host_kernel_rfl
      have sourceValues' : LiteralSliceValues ν₀ (roles {n}.producer).shape (constantShape (sliceExtents {n}.first {n}.last))
          (starts.map Dimension.literal) (stops.map Dimension.literal) (strides.map Dimension.literal) {n}.kind := by
        simpa only [starts,stops,strides,constantExpressions_shape,inputSchema] using sourceValues
      have targetValues' : LiteralSliceValues ν (roles {n}.producer).shape (constantShape (sliceExtents {n}.first {n}.last))
          (starts.map Dimension.literal) (stops.map Dimension.literal) (strides.map Dimension.literal) {n}.kind := by
        simpa only [starts,stops,strides,constantExpressions_shape,inputSchema] using targetValues
      have ctl : {n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis
          [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.handle),
          .ptr (.js {n}.start) 0,.big (Int.ofNat starts.length),.ptr (.js {n}.stop) 0,.big (Int.ofNat stops.length),
          .ptr (.js {n}.stride) 0,.big (Int.ofNat strides.length),.big (Int.ofNat {n}.stream)] := by
        simpa only [sl,el,rl] using {n}.source_control
      have result := Host.Load.Run.Full.Ordinary.SliceFamilyHost.retained_literal_cut {n}.kind ν₀ ν C₀ C R roles boundary objects H N tail host
        live framed before after old old' {n}.input s h inventory {n}.address {n}.types {n}.out {n}.handle
        {n}.producer {n}.start {n}.stop {n}.stride {n}.stream {n}.object {n}.signatureObject {n}.returns {n}.sourceThis
        starts stops strides (constantShape (sliceExtents {n}.first {n}.last)) {n}.node ctl {n}.source_heap {n}.source_kind {n}.source_signature {n}.signature_kind
        signatureFrame handleLive {n}.source_producers {n}.source_node sourceValues' targetValues'
        {n}.source_node_bound targetNodes {n}.source_native_bound targetHandles {n}.source_output_bound targetHeap roots policy
        fnRole thisRole startCount stopCount strideCount (sl.symm ▸ startSchema) (el.symm ▸ stopSchema) (rl.symm ▸ strideSchema)
        note selected selectedStart selectedStop selectedStride {n}.output {n}.initialServer {n}.nextServer inst {n}.source_step
      simp only [starts,stops,strides,constantExpressions_shape] at result
      exact result")

end Host.Ts.Owned.Annotated.Driver
