import host.mlx.NativeDataRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def dataHeader : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated in\n"

/-- The constructor retains the current payload annotations. Only its closed
shape/count/dtype occurrences are source-certified and normalized. -/
elab "host_retained_arrayNewData " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_arrayNewData: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_arrayNewData: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let mut arguments := ctl.getAppArgs[2]!
    let mut values : Array Lean.Expr := #[]
    for _ in [:4] do
      values := values.push (← field arguments ``List.cons 3 1)
      arguments ← field arguments ``List.cons 3 2
    unless (← whnf arguments).isAppOfArity ``List.nil 1 do throwError "host_retained_arrayNewData: expected four arguments"
    let pointer (value : Lean.Expr) := do
      let owner ← field (← field value ``Val.ptr 2 0) ``Mem.js 1 0
      unless ← isDefEq (← field value ``Val.ptr 2 1) (mkNatLit 0) do throwError "host_retained_arrayNewData: expected zero pointer offset"
      pure owner
    let dataBuffer ← pointer values[0]!
    let shapeBuffer ← pointer values[1]!
    let countNumber ← field values[2]! ``Val.num 1 0
    let dtypeNumber ← field values[3]! ``Val.num 1 0
    let countArg ← field countNumber ``NumV.lit 1 0
    let dtypeArg ← field dtypeNumber ``NumV.lit 1 0
    let dtype ← field (← mkAppM ``Host.Mlx.Ffi.argNat #[← mkAppM ``Arg.num #[dtypeNumber]]) ``Option.some 2 1
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do throwError "host_retained_arrayNewData: expected FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_array_new_data") do throwError "host_retained_arrayNewData: expected mlx_array_new_data"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do throwError "host_retained_arrayNewData: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let shapeObject ← field (← mkAppM ``St.obj? #[s,shapeBuffer]) ``Option.some 2 1
    let bytes ← field (← mkAppM ``Obj.kind #[shapeObject]) ``Kind.buf 1 0
    let pointerArg ← mkAppM ``Arg.jsPtr #[shapeBuffer,mkNatLit 0,bytes]
    let mut dimensions ← field (← mkAppM ``Host.Mlx.Ffi.dimsArg #[pointerArg,← mkAppM ``Arg.num #[countNumber]]) ``Option.some 2 1
    let mut integers : Array Lean.Expr := #[]
    while !(← whnf dimensions).isAppOfArity ``List.nil 1 do
      integers := integers.push (← field (← field dimensions ``List.cons 3 1) ``Host.Mlx.Ffi.Dim.lit 1 0)
      dimensions ← field dimensions ``List.cons 3 2
    let shape ← mkListLit (mkConst ``Int) integers.toList
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("types",types),("signatureObject",signatureObject),("returns",returns),("sourceThis",ctl.getAppArgs[1]!),
      ("dataBuffer",dataBuffer),("shapeBuffer",shapeBuffer),("countArg",countArg),("dtypeArg",dtypeArg),("dtype",dtype),
      ("shapeObject",shapeObject),("shape",shape)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.ptr (.js {n}.dataBuffer) 0,.ptr (.js {n}.shapeBuffer) 0,.num (.lit {n}.countArg),.num (.lit {n}.dtypeArg)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str Host.Load.Run.Full.Ordinary.DataHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array Host.Load.Run.Full.Ordinary.DataHost.signature"),
    ("source_shape_buffer",s!"{n}.input.heap.get {n}.shapeBuffer = some (.obj {n}.shapeObject)"),
    ("shape_kind",s!"{n}.shapeObject.kind = .buf (shapeBytes ({n}.shape.map Dim.lit))"),
    ("source_shape",s!"dimsArg (.jsPtr {n}.shapeBuffer 0 (shapeBytes ({n}.shape.map Dim.lit))) (.num (.lit {n}.countArg)) = some ({n}.shape.map Dim.lit)"),
    ("source_dtype",s!"argNat (.num (.lit {n}.dtypeArg)) = some {n}.dtype"),
    ("source_allocation",s!"{n}.output.ffi.mlx.nnext = {n}.input.ffi.mlx.nnext + 1")]
    do Parametric.Driver.emit (dataHeader ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  for (fact,type) in [
    ("source_native_bound",s!"{n}.input.ffi.mlx.next < 2^64"),("source_node_bound",s!"{n}.input.ffi.mlx.nnext < 2^64"),
    ("shape_exact",s!"ExactDimensions {n}.shape"),("count_fixed",s!"F64.un .int32 {n}.countArg = {n}.countArg"),
    ("dtype_fixed",s!"F64.un .int32 {n}.dtypeArg = {n}.dtypeArg"),("data_ne_shape",s!"{n}.dataBuffer ≠ {n}.shapeBuffer")]
    do Parametric.Driver.emit (dataHeader ++ s!"theorem {n}.{fact} : {type} := by decide +kernel")
  Parametric.Driver.emit (dataHeader ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (dataHeader ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (dataHeader ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (signatureFrame : ¬ framed {n}.types)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
      (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
      (fnRole thisRole countNote dtypeNote : Annotated.Value)
      (countSchema : ClosedLiteralNote countNote) (dtypeSchema : ClosedLiteralNote dtypeNote)
      (note : notes.runtime.control = callNote fnRole thisRole
        (Host.Load.Run.Full.Ordinary.DataHost.dataArgumentNotes {n}.dataBuffer {n}.shapeBuffer countNote dtypeNote))
      (payload : List Host.Ts.Owned.Annotated.Byte)
      (selectedData : notes.buffers.owners {n}.dataBuffer = some payload)
      (shapeExpressions : List SymE)
      (selectedShape : notes.buffers.owners {n}.shapeBuffer = some (literalShapeByteNotes shapeExpressions))
      (closedShape : shapeExpressions.all SymE.closed = true) :
      let normalizedNotes := notes.normalizeShapeBuffer {n}.shapeBuffer {n}.shape
      let newRoles := nodeWrite roles {n}.input.ffi.mlx.nnext (dataRole ({n}.shape.map Dim.lit) {n}.dtype (constantShape {n}.shape) payload)
      let newObjects := objectWrite objects {n}.input.ffi.mlx.next .stream
      let newH := fun a => a = {n}.input.ffi.mlx.next ∨ H a
      let newN := fun i => i = {n}.input.ffi.mlx.nnext ∨ N i
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧ interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C)
          (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (normalizedNotes.withRuntime ⟨returnNote (.handle {n}.input.ffi.mlx.next),normalizedNotes.runtime.stack,normalizedNotes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧
        ProducerAnnotations roots newH newN newRoles newObjects ∧ ProducerSupport roots newH newN {n}.output.ffi.mlx ∧ Inst ν₀ {n}.nextServer C₀ := by
      let normalizedNotes := notes.normalizeShapeBuffer {n}.shapeBuffer {n}.shape
      have normalized := inventory.normalize_closed_shape_buffer {n}.shapeBuffer shapeExpressions {n}.shape selectedShape
        {n}.shapeObject {n}.source_shape_buffer {n}.shape_kind {n}.shape_exact closedShape
      have dataSelected : normalizedNotes.buffers.owners {n}.dataBuffer = some payload := by
        simpa only [normalizedNotes,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,ite_eq_right {n}.data_ne_shape] using selectedData
      have shapeSelected : normalizedNotes.buffers.owners {n}.shapeBuffer = some (literalShapeByteNotes (constantExpressions {n}.shape)) := by
        simp only [normalizedNotes,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,ite_true]
      obtain ⟨sourcePost,result,left,right,post,retained,policyPost,support⟩ :=
        Host.Load.Run.Full.Ordinary.DataHost.retained_from_source ν₀ ν C₀ C R roles boundary objects H N tail host
          live framed before after old old' {n}.input s h normalized {n}.address {n}.types {n}.dataBuffer {n}.shapeBuffer {n}.dtype
          {n}.countArg {n}.dtypeArg {n}.object {n}.signatureObject {n}.returns {n}.sourceThis {n}.shape payload
          {n}.source_control {n}.source_heap {n}.source_kind {n}.source_signature {n}.signature_kind signatureFrame
          {n}.source_shape {n}.source_dtype {n}.count_fixed {n}.dtype_fixed {n}.shape_exact
          {n}.source_node_bound targetNodes {n}.source_native_bound targetHandles roots policy fnRole thisRole countNote dtypeNote
          countSchema dtypeSchema note dataSelected shapeSelected
      obtain ⟨D,actual,instAfter⟩ := interp_sim ν₀ (step {n}.F {n}.input).run {n}.initialServer C₀ {n}.output {n}.nextServer inst {n}.source_step
      have equality := Option.some.inj (left.symm.trans actual)
      have same : sourcePost = {n}.output := congrArg Prod.fst equality
      have table : C₀ = D := congrArg Prod.snd equality
      rw [same] at left post retained support
      exact ⟨result,left,right,post,retained,policyPost,support,table ▸ instAfter⟩")

end Host.Ts.Owned.Annotated.Driver
