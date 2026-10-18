import host.mlx.NativeTransposeRetained
import host.mlx.NativeClosedShapeBuffer
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def transposeHeader : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated in\n"

/-- Current closed axis-byte notes supply the original permutation. Input dimensions remain indexed expressions, including varying cache geometry. -/
elab "host_retained_transpose " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_transpose: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_transpose: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let mut arguments := ctl.getAppArgs[2]!
    let mut values : Array Lean.Expr := #[]
    for _ in [:5] do
      values := values.push (← field arguments ``List.cons 3 1)
      arguments ← field arguments ``List.cons 3 2
    unless (← whnf arguments).isAppOfArity ``List.nil 1 do throwError "host_retained_transpose: expected five arguments"
    let pointer (value : Lean.Expr) := do
      let memory ← field value ``Val.ptr 2 0
      let owner ← field memory ``Mem.js 1 0
      unless ← isDefEq (← field value ``Val.ptr 2 1) (mkNatLit 0) do
        throwError "host_retained_transpose: expected zero pointer offset"
      pure owner
    let natural (value : Lean.Expr) := do mkAppM ``Int.toNat #[← field value ``Val.big 1 0]
    let out ← pointer values[0]!
    let handle ← natural values[1]!
    let axisBuffer ← pointer values[2]!
    let axisCount ← natural values[3]!
    let stream ← natural values[4]!
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do
      throwError "host_retained_transpose: expected FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_transpose_axes") do throwError "host_retained_transpose: expected mlx_transpose_axes"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_transpose: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let mlx ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let producer (handle : Lean.Expr) := do
      field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[mlx,handle]) ``Option.some 2 1
    let input ← producer handle
    let nodes ← mkAppM ``Host.Mlx.Ffi.St.nodes #[mlx]
    let node ← field (← mkAppM ``PTrie.get #[nodes,input]) ``Option.some 2 1
    let integers (dimensions : Lean.Expr) := do
      let mut rest := dimensions
      let mut result : Array Lean.Expr := #[]
      while !(← whnf rest).isAppOfArity ``List.nil 1 do
        let dimension ← field rest ``List.cons 3 1
        result := result.push (← field dimension ``Host.Mlx.Ffi.Dim.lit 1 0)
        rest ← field rest ``List.cons 3 2
      mkListLit (mkConst ``Int) result.toList
    let dimensionBuffer (owner count : Lean.Expr) := do
      let object ← field (← mkAppM ``St.obj? #[s,owner]) ``Option.some 2 1
      let bytes ← field (← mkAppM ``Obj.kind #[object]) ``Kind.buf 1 0
      let argument ← mkAppM ``Arg.jsPtr #[owner,mkNatLit 0,bytes]
      let count ← mkAppM ``Arg.big #[← mkAppM ``Int.ofNat #[count]]
      let dimensions ← field (← mkAppM ``Host.Mlx.Ffi.dimsArg #[argument,count]) ``Option.some 2 1
      pure (object,← integers dimensions,dimensions)
    let (axisObject,axisIntegers,axisDims) ← dimensionBuffer axisBuffer axisCount
    let axes ← field (← mkAppM ``Host.Mlx.Ffi.natsOfDims #[axisDims]) ``Option.some 2 1
    let rank ← mkAppM ``List.length #[← mkAppM ``Host.Mlx.Ffi.Node.shape #[node]]
    let axisLength ← mkAppM ``Host.Ts.len #[axes]
    unless ← isDefEq axisLength rank do throwError "host_retained_transpose: expected axis count matching input rank"
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("types",types),("signatureObject",signatureObject),("returns",returns),("sourceThis",ctl.getAppArgs[1]!),
      ("out",out),("handle",handle),("axisBuffer",axisBuffer),("stream",stream),
      ("producer",input),("node",node),
      ("axes",axes),("axisIntegers",axisIntegers),("axisObject",axisObject)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.handle),.ptr (.js {n}.axisBuffer) 0,.big (Int.ofNat {n}.axisIntegers.length),.big (Int.ofNat {n}.stream)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str Host.Load.Run.Full.Ordinary.TransposeHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array Host.Load.Run.Full.Ordinary.TransposeHost.signature"),
    ("source_producer",s!"nodesOf {n}.input.ffi.mlx [{n}.handle] = some [{n}.producer]"),
    ("source_node",s!"{n}.input.ffi.mlx.nodes.get {n}.producer = some {n}.node"),
    ("source_axes_buffer",s!"{n}.input.heap.get {n}.axisBuffer = some (.obj {n}.axisObject)"),
    ("axes_kind",s!"{n}.axisObject.kind = .buf (shapeBytes ({n}.axisIntegers.map Dim.lit))"),
    ("source_axes",s!"(dimsArg (.jsPtr {n}.axisBuffer 0 (shapeBytes ({n}.axisIntegers.map Dim.lit))) (.big (Int.ofNat {n}.axisIntegers.length))).bind natsOfDims = some {n}.axes"),
    ("source_allocation",s!"{n}.output.ffi.mlx.nnext = {n}.input.ffi.mlx.nnext + 1")]
    do Parametric.Driver.emit (transposeHeader ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  for (fact,type) in [
    ("source_native_bound",s!"{n}.input.ffi.mlx.next < 2^64"),("source_node_bound",s!"{n}.input.ffi.mlx.nnext < 2^64"),
    ("source_output_bound",s!"{n}.out < 2^64"),("axes_exact",s!"ExactDimensions {n}.axisIntegers"),
    ("source_permutation",s!"(Nat.beq (len {n}.axes) {n}.node.shape.length && (List.range {n}.node.shape.length).all (fun a => {n}.axes.any (Nat.beq a))) = true"),
    ("out_ne_axis",s!"{n}.out ≠ {n}.axisBuffer")]
    do Parametric.Driver.emit (transposeHeader ++ s!"theorem {n}.{fact} : {type} := by decide +kernel")
  Parametric.Driver.emit (transposeHeader ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (transposeHeader ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (transposeHeader ++ s!"theorem {n}.retained_transport
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
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
      (fnRole thisRole countRole : Annotated.Value) (countSchema : FixedIntegerRole countRole (Int.ofNat {n}.axisIntegers.length))
      (note : notes.runtime.control = callNote fnRole thisRole
        (Host.Load.Run.Full.Ordinary.TransposeHost.argumentNotes {n}.out {n}.handle {n}.axisBuffer {n}.stream countRole))
      (selected : notes.buffers.owners {n}.out = some (handleSlotNotes 0))
      (axisExpressions : List SymE)
      (selectedAxes : notes.buffers.owners {n}.axisBuffer = some (literalShapeByteNotes axisExpressions))
      (closedAxes : axisExpressions.all SymE.closed = true) :
      let normalizedNotes := notes.normalizeShapeBuffer {n}.axisBuffer {n}.axisIntegers
      let newRoles := nodeWrite roles {n}.input.ffi.mlx.nnext (transposeRole roles {n}.producer {n}.axes)
      let newObjects := objectWrite objects {n}.input.ffi.mlx.next .stream
      let newH := fun a => a = {n}.input.ffi.mlx.next ∨ H a
      let newN := fun i => i = {n}.input.ffi.mlx.nnext ∨ N i
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧ interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C)
          (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (normalizedNotes.nativeHandleResult {n}.out {n}.input.ffi.mlx.next) ν₀ ν C₀ C R live {n}.output result ∧
        ProducerAnnotations roots newH newN newRoles newObjects ∧ ProducerSupport roots newH newN {n}.output.ffi.mlx ∧
        ProducerSupport (resourceImage R.node (fun i => newN i ∧ roots i))
          (resourceImage R.handle newH) (resourceImage R.node newN) result.ffi.mlx ∧ Inst ν₀ {n}.nextServer C₀ := by
      let normalizedNotes := notes.normalizeShapeBuffer {n}.axisBuffer {n}.axisIntegers
      have inv := inventory.normalize_closed_shape_buffer {n}.axisBuffer axisExpressions {n}.axisIntegers selectedAxes
        {n}.axisObject {n}.source_axes_buffer {n}.axes_kind {n}.axes_exact closedAxes
      have outSelected : normalizedNotes.buffers.owners {n}.out = some (handleSlotNotes 0) := by
        simpa only [normalizedNotes,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,ite_eq_right {n}.out_ne_axis] using selected
      have axisSelected : normalizedNotes.buffers.owners {n}.axisBuffer = some (literalShapeByteNotes (constantExpressions {n}.axisIntegers)) := by
        simp only [normalizedNotes,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,ite_true]
      obtain ⟨sourcePost,result,left,right,post,retained,policyPost,sourceSupport,targetSupport⟩ :=
        Host.Load.Run.Full.Ordinary.TransposeHost.retained_from_source ν₀ ν C₀ C R roles boundary objects H N tail host
          live framed before after old old' {n}.input s h inv {n}.address {n}.types {n}.out {n}.handle {n}.producer {n}.axisBuffer {n}.stream
          {n}.object {n}.signatureObject {n}.returns {n}.sourceThis {n}.axisIntegers {n}.axes {n}.node
          {n}.source_control {n}.source_heap {n}.source_kind {n}.source_signature {n}.signature_kind signatureFrame handleLive
          {n}.source_producer {n}.source_node {n}.source_axes {n}.axes_exact {n}.source_permutation
          {n}.source_node_bound targetNodes {n}.source_native_bound targetHandles {n}.source_output_bound targetHeap roots policy
          fnRole thisRole countRole countSchema note outSelected axisSelected
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained sourceSupport
      exact ⟨result,source,right,post,retained,policyPost,sourceSupport,targetSupport,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
