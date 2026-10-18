import host.mlx.NativeReshapeRetained
import host.mlx.NativeReshapeLiteralGeometry
import host.mlx.NativeClosedProducer
import host.mlx.NativeClosedShapeBuffer
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select an explicit reshape from closed current shape occurrences. The
source dimensions and byte decoding certify the normalized meanings, integer
product guard, original native call and complete retained result. -/
elab "host_retained_reshape " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_reshape: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.call 3 do throwError "host_retained_reshape: expected source call"
    let fn ← field control.getAppArgs[0]! ``Val.obj 1 0
    let mut rest := control.getAppArgs[2]!
    let mut values : Array Lean.Expr := #[]
    for _ in [:5] do
      values := values.push (← field rest ``List.cons 3 1)
      rest ← field rest ``List.cons 3 2
    unless (← whnf rest).isAppOfArity ``List.nil 1 do throwError "host_retained_reshape: expected five arguments"
    let pointer (value : Lean.Expr) := do
      unless ← isDefEq (← field value ``Val.ptr 2 1) (mkNatLit 0) do throwError "host_retained_reshape: expected zero pointer offset"
      field (← field value ``Val.ptr 2 0) ``Mem.js 1 0
    let natural (value : Lean.Expr) := do mkAppM ``Int.toNat #[← field value ``Val.big 1 0]
    let out ← pointer values[0]!
    let handle ← natural values[1]!
    let shapeBuffer ← pointer values[2]!
    let count ← natural values[3]!
    let stream ← natural values[4]!
    let function ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do throwError "host_retained_reshape: expected native FFI symbol"
    let captures := code.getAppArgs[1]!
    let symbol ← field (← field captures ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_reshape") do throwError "host_retained_reshape: expected mlx_reshape"
    let captures ← field captures ``List.cons 3 2
    let types ← field (← field captures ``List.cons 3 1) ``Val.obj 1 0
    let returns ← field (← field (← field captures ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0
    let signature ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let nativeState ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let producer ← field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[nativeState,handle]) ``Option.some 2 1
    let node ← field (← mkAppM ``PTrie.get #[← mkAppM ``Host.Mlx.Ffi.St.nodes #[nativeState],producer]) ``Option.some 2 1
    let integers (dimensions : Lean.Expr) := do
      let mut rest := dimensions
      let mut result : Array Lean.Expr := #[]
      while !(← whnf rest).isAppOfArity ``List.nil 1 do
        result := result.push (← field (← field rest ``List.cons 3 1) ``Host.Mlx.Ffi.Dim.lit 1 0)
        rest ← field rest ``List.cons 3 2
      mkListLit (mkConst ``Int) result.toList
    let inputSizes ← integers (← mkAppM ``Host.Mlx.Ffi.Node.shape #[node])
    let shapeObject ← field (← mkAppM ``St.obj? #[s,shapeBuffer]) ``Option.some 2 1
    let bytes ← field (← mkAppM ``Obj.kind #[shapeObject]) ``Kind.buf 1 0
    let argument ← mkAppM ``Arg.jsPtr #[shapeBuffer,mkNatLit 0,bytes]
    let countArg ← mkAppM ``Arg.big #[← mkAppM ``Int.ofNat #[count]]
    let request ← integers (← field (← mkAppM ``Host.Mlx.Ffi.dimsArg #[argument,countArg]) ``Option.some 2 1)
    for (tag,value) in [("F",f),("input",s),("output",t),("fn",fn),("out",out),("handle",handle),("stream",stream),
      ("function",function),("types",types),("returns",returns),("signature",signature),
      ("producer",producer),("node",node),("sourceThis",control.getAppArgs[1]!),("shapeBuffer",shapeBuffer),
      ("shapeObject",shapeObject),("inputSizes",inputSizes),("request",request)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.fn) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.handle),.ptr (.js {n}.shapeBuffer) 0,.big (Int.ofNat {n}.request.length),.big (Int.ofNat {n}.stream)]"),
    ("source_function_read",s!"{n}.input.heap.get {n}.fn = some (.obj {n}.function)"),
    ("source_function_kind",s!"{n}.function.kind = .fn (.native (.ffi .symbol) [.str ReshapeHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signature)"),
    ("source_signature_kind",s!"{n}.signature.kind = .array ReshapeHost.signature"),
    ("source_producers",s!"nodesOf {n}.input.ffi.mlx [{n}.handle] = some [{n}.producer]"),
    ("source_node",s!"{n}.input.ffi.mlx.nodes.get {n}.producer = some {n}.node"),
    ("source_input_shape",s!"{n}.node.shape = {n}.inputSizes.map Dim.lit"),
    ("source_shape_read",s!"{n}.input.heap.get {n}.shapeBuffer = some (.obj {n}.shapeObject)"),
    ("source_shape_kind",s!"{n}.shapeObject.kind = .buf (shapeBytes ({n}.request.map Dim.lit))"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  for (tag,type) in [
    ("input_exact",s!"ExactDimensions {n}.inputSizes"),("request_exact",s!"ExactDimensions {n}.request"),
    ("source_products",s!"{n}.inputSizes.foldr (· * ·) 1 = {n}.request.foldr (· * ·) 1"),
    ("out_ne_shape",s!"{n}.out ≠ {n}.shapeBuffer"),
    ("source_node_bound",s!"{n}.input.ffi.mlx.nnext < 2^64"),
    ("source_handle_bound",s!"{n}.input.ffi.mlx.next < 2^64"),("source_heap_bound",s!"{n}.out < 2^64")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.request_nonnegative : listSupport (fun i => 0 ≤ i) {n}.request := by apply reshape_nonnegative_of_all; decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
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
      (signatureFrame : ¬ framed {n}.types) (handleLive : H {n}.handle)
      (closedInput : closedLiteralShape (roles {n}.producer).shape = true)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (fnRole thisRole countRole : Annotated.Value) (countSchema : FixedIntegerRole countRole (Int.ofNat {n}.request.length))
      (controlNote : notes.runtime.control = callNote fnRole thisRole
        [.ptr (.js {n}.out) 0,.handle {n}.handle,.ptr (.js {n}.shapeBuffer) 0,countRole,.handle {n}.stream])
      (slotNote : notes.buffers.owners {n}.out = some (handleSlotNotes 0))
      (expressions : List SymE) (shapeNote : notes.buffers.owners {n}.shapeBuffer = some (literalShapeByteNotes expressions))
      (closedShape : expressions.all SymE.closed = true) :
      let normalizedRoles := nodeShapeRoles roles {n}.producer {n}.inputSizes
      let normalizedNotes := notes.normalizeShapeBuffer {n}.shapeBuffer {n}.request
      let newRoles := nodeWrite normalizedRoles {n}.input.ffi.mlx.nnext (reshapeRole normalizedRoles {n}.producer (constantShape {n}.request))
      let newObjects := objectWrite objects {n}.input.ffi.mlx.next .stream
      let newH := fun a => a = {n}.input.ffi.mlx.next ∨ H a
      let newN := fun i => i = {n}.input.ffi.mlx.nnext ∨ N i
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (normalizedNotes.nativeHandleResult {n}.out {n}.input.ffi.mlx.next) ν₀ ν C₀ C R live {n}.output result ∧
        ProducerAnnotations roots newH newN newRoles newObjects ∧ ProducerSupport roots newH newN {n}.output.ffi.mlx ∧
        Inst ν₀ {n}.nextServer C₀ := by
      dsimp only
      let normalizedRoles := nodeShapeRoles roles {n}.producer {n}.inputSizes
      let normalizedNotes := notes.normalizeShapeBuffer {n}.shapeBuffer {n}.request
      have supported := h.native.2.nodesOf_support [{n}.handle] [{n}.producer] ⟨handleLive,True.intro⟩ {n}.source_producers
      obtain ⟨normalizedState,_,normalizedPolicy,_⟩ := VectorHost.normalize_closed_producer h inventory {n}.producer {n}.node {n}.inputSizes
        supported.1 {n}.source_node {n}.source_input_shape closedInput roots policy
      have normalizedInventory := inventory.normalize_closed_shape_buffer {n}.shapeBuffer expressions {n}.request shapeNote
        {n}.shapeObject {n}.source_shape_read {n}.source_shape_kind {n}.request_exact closedShape
      have normalizedSlot : normalizedNotes.buffers.owners {n}.out = some (handleSlotNotes 0) := by
        simpa only [normalizedNotes,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,ite_eq_right {n}.out_ne_shape] using slotNote
      have normalizedShape : normalizedNotes.buffers.owners {n}.shapeBuffer = some (literalShapeByteNotes (constantExpressions {n}.request)) := by
        simp only [normalizedNotes,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,ite_true]
      have inputSchema : (normalizedRoles {n}.producer).shape = constantShape {n}.inputSizes := by
        simp only [normalizedRoles,nodeShapeRoles,nodeWrite,ite_true]
      have values₀ : LiteralDimensions ν₀ ((constantExpressions {n}.request).map Dimension.literal) {n}.request := by
        rw [constantExpressions_shape]; exact .constants ν₀ _ {n}.request_exact
      have values : LiteralDimensions ν ((constantExpressions {n}.request).map Dimension.literal) {n}.request := by
        rw [constantExpressions_shape]; exact .constants ν _ {n}.request_exact
      have geometry₀ : ReshapeGeometry ν₀ (normalizedRoles {n}.producer).shape ((constantExpressions {n}.request).map Dimension.literal) := by
        rw [inputSchema,constantExpressions_shape]
        exact .constants ν₀ _ _ {n}.input_exact {n}.request_exact {n}.request_nonnegative {n}.source_products
      have geometry : ReshapeGeometry ν (normalizedRoles {n}.producer).shape ((constantExpressions {n}.request).map Dimension.literal) := by
        rw [inputSchema,constantExpressions_shape]
        exact .constants ν _ _ {n}.input_exact {n}.request_exact {n}.request_nonnegative {n}.source_products
      have control' : normalizedNotes.runtime.control = callNote fnRole thisRole
          [.ptr (.js {n}.out) 0,.handle {n}.handle,.ptr (.js {n}.shapeBuffer) 0,countRole,.handle {n}.stream] := controlNote
      obtain ⟨sourcePost,result,left,right,post,retained,policy',support⟩ := ReshapeHost.retained_from_source
        ν₀ ν C₀ C R normalizedRoles boundary objects roots H N tail host live framed before after old old' {n}.input s
        normalizedState normalizedInventory normalizedPolicy {n}.fn {n}.types {n}.out {n}.handle {n}.producer {n}.shapeBuffer {n}.stream
        {n}.function {n}.signature {n}.returns {n}.sourceThis (constantExpressions {n}.request) {n}.node
        (by simpa only [constantExpressions,List.length_map] using {n}.source_control) {n}.source_function_read {n}.source_function_kind
        {n}.source_signature_read {n}.source_signature_kind signatureFrame handleLive {n}.source_producers {n}.source_node
        {n}.request {n}.request values₀ values geometry₀ geometry {n}.source_node_bound targetNodes
        {n}.source_handle_bound targetHandles {n}.source_heap_bound targetHeap fnRole thisRole countRole
        (by simpa only [constantExpressions,List.length_map] using countSchema) control' normalizedSlot normalizedShape
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained support
      rw [constantExpressions_shape] at post policy'
      exact ⟨_,source,right,post,retained,policy',support,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
