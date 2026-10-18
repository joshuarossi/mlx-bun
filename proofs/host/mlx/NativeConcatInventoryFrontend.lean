import host.mlx.NativeConcatRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def concatHeader : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated in\n"

/-- Select the real two-input concatenation. Source metadata proposes graph
IDs and the normalized axis; every proposal and original execution equation
is checked, while current inventories supply the operand and slot meanings. -/
elab "host_retained_concat " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_concat: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_concat: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let values := ctl.getAppArgs[2]!
    let pointer ← whnf (← field values ``List.cons 3 1)
    let out ← field (← field pointer ``Val.ptr 2 0) ``Mem.js 1 0
    unless ← isDefEq (← field pointer ``Val.ptr 2 1) (mkNatLit 0) do
      throwError "host_retained_concat: expected zero pointer offset"
    let rest ← field values ``List.cons 3 2
    let vec ← mkAppM ``Int.toNat #[← field (← field rest ``List.cons 3 1) ``Val.big 1 0]
    let rest ← field rest ``List.cons 3 2
    let axisValue ← field (← field (← field rest ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    let rest ← field rest ``List.cons 3 2
    let stream ← mkAppM ``Int.toNat #[← field (← field rest ``List.cons 3 1) ``Val.big 1 0]
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_concat: expected exactly four arguments"
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.ffi 1 0
    unless (← whnf builtin).isConstOf ``FfiN.symbol do throwError "host_retained_concat: expected native FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_concatenate_axis") do
      throwError "host_retained_concat: expected mlx_concatenate_axis"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_concat: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let mlx ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let vector ← field (← mkAppM ``Host.Mlx.Ffi.St.obj? #[mlx,vec]) ``Option.some 2 1
    let entries ← field vector ``Host.Mlx.Ffi.Obj.vec 1 0
    let x ← field entries ``List.cons 3 1
    let rest ← field entries ``List.cons 3 2
    let y ← field rest ``List.cons 3 1
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_concat: expected exactly two vector entries"
    let nodes ← mkAppM ``Host.Mlx.Ffi.St.nodes #[mlx]
    let first ← field (← mkAppM ``PTrie.get #[nodes,x]) ``Option.some 2 1
    let second ← field (← mkAppM ``PTrie.get #[nodes,y]) ``Option.some 2 1
    let axisInt ← field (← mkAppM ``F64.toInt? #[axisValue]) ``Option.some 2 1
    let rank ← mkAppM ``Host.Ts.len #[← mkAppM ``Host.Mlx.Ffi.Node.shape #[first]]
    let axis ← field (← mkAppM ``Host.Mlx.Ffi.axisOf #[axisInt,rank]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("types",types),("signatureObject",signatureObject),("returns",returns),("sourceThis",ctl.getAppArgs[1]!),
      ("out",out),("vec",vec),("stream",stream),("axisValue",axisValue),("axisInt",axisInt),("axis",axis),
      ("x",x),("y",y),("first",first),("second",second)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.vec),.num (.lit {n}.axisValue),.big (Int.ofNat {n}.stream)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str Host.Load.Run.Full.Ordinary.ConcatFamilyHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array Host.Load.Run.Full.Ordinary.ConcatFamilyHost.signature"),
    ("source_vector",s!"{n}.input.ffi.mlx.obj? {n}.vec = some (.vec [{n}.x,{n}.y])"),
    ("source_first",s!"{n}.input.ffi.mlx.nodes.get {n}.x = some {n}.first"),
    ("source_second",s!"{n}.input.ffi.mlx.nodes.get {n}.y = some {n}.second"),
    ("source_axis",s!"axisOf {n}.axisInt (len {n}.first.shape) = some {n}.axis")]
    do Parametric.Driver.emit (concatHeader ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  for (fact,type) in [
    ("axis_fixed",s!"F64.un .int32 {n}.axisValue = {n}.axisValue"),
    ("axis_decode",s!"F64.toInt? {n}.axisValue = some {n}.axisInt"),
    ("source_native_bound",s!"{n}.input.ffi.mlx.next < 2^64"),
    ("source_node_bound",s!"{n}.input.ffi.mlx.nnext < 2^64"),
    ("source_output_bound",s!"{n}.out < 2^64")]
    do Parametric.Driver.emit (concatHeader ++ s!"theorem {n}.{fact} : {type} := by decide +kernel")
  Parametric.Driver.emit (concatHeader ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (concatHeader ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (concatHeader ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (signatureFrame : ¬ framed {n}.types) (owned : H {n}.vec)
      (outputShape : Shape) (sourceGeometry : ConcatGeometry ν₀ (roles {n}.x).shape (roles {n}.y).shape outputShape {n}.axis)
      (targetGeometry : ConcatGeometry ν (roles {n}.x).shape (roles {n}.y).shape outputShape {n}.axis)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects) (fnRole thisRole : Annotated.Value)
      (note : notes.runtime.control = callNote fnRole thisRole
        ((Host.Load.Run.Full.Ordinary.ConcatFamilyHost.arguments {n}.out {n}.vec {n}.stream {n}.axisValue).map FixedArgument.role))
      (selected : notes.buffers.owners {n}.out = some (handleSlotNotes 0)) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C)
          (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C
            (nodeWrite roles {n}.input.ffi.mlx.nnext (concatRole roles {n}.x {n}.y {n}.axis outputShape)) boundary
            (objectWrite objects {n}.input.ffi.mlx.next .stream) (fun a => a = {n}.input.ffi.mlx.next ∨ H a)
            (fun i => i = {n}.input.ffi.mlx.nnext ∨ N i) tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.nativeHandleResult {n}.out {n}.input.ffi.mlx.next) ν₀ ν C₀ C R live {n}.output result ∧
        ProducerAnnotations roots (fun a => a = {n}.input.ffi.mlx.next ∨ H a) (fun i => i = {n}.input.ffi.mlx.nnext ∨ N i)
          (nodeWrite roles {n}.input.ffi.mlx.nnext (concatRole roles {n}.x {n}.y {n}.axis outputShape))
          (objectWrite objects {n}.input.ffi.mlx.next .stream) ∧
        ProducerSupport roots (fun a => a = {n}.input.ffi.mlx.next ∨ H a) (fun i => i = {n}.input.ffi.mlx.nnext ∨ N i)
          {n}.output.ffi.mlx ∧ Inst ν₀ {n}.nextServer C₀ := by
      have support := (policy.source h.native.2).vector {n}.vec [{n}.x,{n}.y] owned {n}.source_vector
      obtain ⟨_,_,nodeRole⟩ := h.native.2.node_view support.1 {n}.source_first
      have normalize : axisOf {n}.axisInt (len (roles {n}.x).shape) = some {n}.axis := by
        simpa only [nodeRole.source.shape.len_eq] using {n}.source_axis
      obtain ⟨sourcePost,result,left,right,post,retained,policyPost,producers⟩ :=
        Host.Load.Run.Full.Ordinary.ConcatFamilyHost.retained_from_source ν₀ ν C₀ C R roles boundary objects H N tail host
          live framed before after old old' {n}.input s h inventory {n}.address {n}.types {n}.out {n}.vec {n}.x {n}.y
          {n}.axis {n}.stream {n}.axisValue {n}.axisInt {n}.returns {n}.object {n}.signatureObject {n}.sourceThis
          {n}.first {n}.second outputShape {n}.source_control {n}.source_heap {n}.source_kind {n}.source_signature
          {n}.signature_kind signatureFrame owned {n}.source_vector {n}.source_first {n}.source_second {n}.axis_fixed
          {n}.axis_decode normalize sourceGeometry targetGeometry roots policy {n}.source_node_bound targetNodes
          {n}.source_native_bound targetHandles {n}.source_output_bound targetHeap fnRole thisRole note selected
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained producers
      exact ⟨result,source,right,post,retained,policyPost,producers,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
