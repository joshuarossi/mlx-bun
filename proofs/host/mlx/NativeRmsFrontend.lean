import host.mlx.NativeRmsRetained
import host.mlx.NativeClosedProducer
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

theorem RmsGeometry.constants (input : List Int) (feature : Int)
    (last : nthD 0 input (len input-1) = feature) :
    RmsGeometry (constantShape input) (constantShape [feature]) := by
  refine ⟨.lit (F64.ofInt feature),?_,rfl⟩
  have mapped := nthD_map constantDimension (0 : Int) input (len input-1)
  simpa only [constantShape,len_map,last,constantDimension] using mapped

end Host.Mlx.Ffi.Annotated

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select the actual weighted RMS ABI, including f32 epsilon rounding.
Current closed source metadata supplies the common feature dimension. -/
elab "host_retained_rms " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_rms: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.call 3 do throwError "host_retained_rms: expected source call"
    let fn ← field control.getAppArgs[0]! ``Val.obj 1 0
    let mut rest := control.getAppArgs[2]!
    let mut values : Array Lean.Expr := #[]
    for _ in [:5] do
      values := values.push (← field rest ``List.cons 3 1)
      rest ← field rest ``List.cons 3 2
    unless (← whnf rest).isAppOfArity ``List.nil 1 do throwError "host_retained_rms: expected five arguments"
    let out ← field (← field values[0]! ``Val.ptr 2 0) ``Mem.js 1 0
    unless ← isDefEq (← field values[0]! ``Val.ptr 2 1) (mkNatLit 0) do throwError "host_retained_rms: expected zero pointer offset"
    let natural (value : Lean.Expr) := do mkAppM ``Int.toNat #[← field value ``Val.big 1 0]
    let hx ← natural values[1]!
    let hw ← natural values[2]!
    let epsilon ← field (← field values[3]! ``Val.num 1 0) ``NumV.lit 1 0
    let stream ← natural values[4]!
    let function ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do throwError "host_retained_rms: expected native FFI symbol"
    let captures := code.getAppArgs[1]!
    let symbol ← field (← field captures ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_fast_rms_norm") do throwError "host_retained_rms: expected RMS norm"
    let captures ← field captures ``List.cons 3 2
    let types ← field (← field captures ``List.cons 3 1) ``Val.obj 1 0
    let returns ← field (← field (← field captures ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0
    let signature ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let nativeState ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let producer (handle : Lean.Expr) := do field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[nativeState,handle]) ``Option.some 2 1
    let x ← producer hx
    let w ← producer hw
    let nodes ← mkAppM ``Host.Mlx.Ffi.St.nodes #[nativeState]
    let xn ← field (← mkAppM ``PTrie.get #[nodes,x]) ``Option.some 2 1
    let wn ← field (← mkAppM ``PTrie.get #[nodes,w]) ``Option.some 2 1
    let mut dimensions ← mkAppM ``Host.Mlx.Ffi.Node.shape #[xn]
    let mut integers : Array Lean.Expr := #[]
    while !(← whnf dimensions).isAppOfArity ``List.nil 1 do
      integers := integers.push (← field (← field dimensions ``List.cons 3 1) ``Host.Mlx.Ffi.Dim.lit 1 0)
      dimensions ← field dimensions ``List.cons 3 2
    let inputSizes ← mkListLit (mkConst ``Int) integers.toList
    let weightShape ← mkAppM ``Host.Mlx.Ffi.Node.shape #[wn]
    let feature ← field (← field weightShape ``List.cons 3 1) ``Host.Mlx.Ffi.Dim.lit 1 0
    unless (← whnf (← field weightShape ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_rms: expected rank-one weights"
    for (tag,value) in [("F",f),("input",s),("output",t),("fn",fn),("out",out),("hx",hx),("hw",hw),("stream",stream),
      ("function",function),("types",types),("returns",returns),("signature",signature),("sourceThis",control.getAppArgs[1]!),
      ("epsilon",epsilon),("inputSizes",inputSizes),("feature",feature),("x",x),("w",w),("xn",xn),("wn",wn)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.fn) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.hx),.big (Int.ofNat {n}.hw),.num (.lit {n}.epsilon),.big (Int.ofNat {n}.stream)]"),
    ("source_function_read",s!"{n}.input.heap.get {n}.fn = some (.obj {n}.function)"),
    ("source_function_kind",s!"{n}.function.kind = .fn (.native (.ffi .symbol) [.str RmsHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signature)"),
    ("source_signature_kind",s!"{n}.signature.kind = .array RmsHost.signature"),
    ("source_producers",s!"nodesOf {n}.input.ffi.mlx [{n}.hx,{n}.hw] = some [{n}.x,{n}.w]"),
    ("source_x",s!"{n}.input.ffi.mlx.nodes.get {n}.x = some {n}.xn"),
    ("source_w",s!"{n}.input.ffi.mlx.nodes.get {n}.w = some {n}.wn"),
    ("source_input_shape",s!"{n}.xn.shape = {n}.inputSizes.map Dim.lit"),
    ("source_weight_shape",s!"{n}.wn.shape = [{n}.feature].map Dim.lit"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  for (tag,type) in [
    ("x_ne_w",s!"{n}.x ≠ {n}.w"),("w_ne_x",s!"{n}.w ≠ {n}.x"),("weight_nonzero",s!"{n}.hw ≠ 0"),
    ("inner_equal",s!"nthD 0 {n}.inputSizes (len {n}.inputSizes-1) = {n}.feature"),
    ("source_float",s!"isFloat (promote {n}.xn.dtype {n}.wn.dtype) = true"),
    ("source_node_bound",s!"{n}.input.ffi.mlx.nnext < 2^64"),("source_handle_bound",s!"{n}.input.ffi.mlx.next < 2^64"),
    ("source_heap_bound",s!"{n}.out < 2^64")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by decide +kernel")
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
      (signatureFrame : ¬ framed {n}.types) (handlesLive : listSupport H [{n}.hx,{n}.hw])
      (closedInput : closedLiteralShape (roles {n}.x).shape = true)
      (closedWeight : closedLiteralShape (roles {n}.w).shape = true)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (fnRole thisRole epsilonNote : Annotated.Value) (epsilonSchema : ClosedLiteralNote epsilonNote)
      (controlNote : notes.runtime.control = callNote fnRole thisRole
        [.ptr (.js {n}.out) 0,.handle {n}.hx,.handle {n}.hw,epsilonNote,.handle {n}.stream])
      (slotNote : notes.buffers.owners {n}.out = some (handleSlotNotes 0)) :
      let normalizedRoles := nodeShapeRoles (nodeShapeRoles roles {n}.x {n}.inputSizes) {n}.w [{n}.feature]
      let newRoles := nodeWrite normalizedRoles {n}.input.ffi.mlx.nnext (rmsRole normalizedRoles {n}.x {n}.w (RmsHost.epsilonRole {n}.epsilon))
      let newObjects := objectWrite objects {n}.input.ffi.mlx.next .stream
      let newH := fun a => a = {n}.input.ffi.mlx.next ∨ H a
      let newN := fun i => i = {n}.input.ffi.mlx.nnext ∨ N i
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.nativeHandleResult {n}.out {n}.input.ffi.mlx.next) ν₀ ν C₀ C R live {n}.output result ∧
        ProducerAnnotations roots newH newN newRoles newObjects ∧ ProducerSupport roots newH newN {n}.output.ffi.mlx ∧
        Inst ν₀ {n}.nextServer C₀ := by
      dsimp only
      let r1 := nodeShapeRoles roles {n}.x {n}.inputSizes
      let r2 := nodeShapeRoles r1 {n}.w [{n}.feature]
      have supported := h.native.2.nodesOf_support [{n}.hx,{n}.hw] [{n}.x,{n}.w] handlesLive {n}.source_producers
      obtain ⟨_,_,rx⟩ := h.native.2.node_view supported.1 {n}.source_x
      obtain ⟨_,_,rw⟩ := h.native.2.node_view supported.2.1 {n}.source_w
      obtain ⟨h1,_,p1,_⟩ := VectorHost.normalize_closed_producer h inventory {n}.x {n}.xn {n}.inputSizes supported.1
        {n}.source_x {n}.source_input_shape closedInput roots policy
      have cw : closedLiteralShape (r1 {n}.w).shape = true := by
        simpa only [r1,nodeShapeRoles_other _ _ _ _ {n}.w_ne_x] using closedWeight
      obtain ⟨h2,_,p2,_⟩ := VectorHost.normalize_closed_producer h1 inventory {n}.w {n}.wn [{n}.feature] supported.2.1
        {n}.source_w {n}.source_weight_shape cw roots p1
      have xs : (r2 {n}.x).shape = constantShape {n}.inputSizes := by
        simp only [r2,r1,nodeShapeRoles,nodeWrite,ite_eq_right {n}.x_ne_w,ite_true]
      have ws : (r2 {n}.w).shape = constantShape [{n}.feature] := by
        simp only [r2,nodeShapeRoles,nodeWrite,ite_true]
      have geometry : RmsGeometry (r2 {n}.x).shape (r2 {n}.w).shape := by
        rw [xs,ws]; exact .constants {n}.inputSizes {n}.feature {n}.inner_equal
      have fl : isFloat (promote (r2 {n}.x).dtype (r2 {n}.w).dtype) = true := by
        simpa only [r2,r1,nodeShapeRoles_dtype,←rx.source.dtype,←rw.source.dtype] using {n}.source_float
      obtain ⟨sourcePost,result,left,right,post,retained,policy',support⟩ := RmsHost.retained_from_source
        ν₀ ν C₀ C R r2 boundary objects roots H N tail host live framed before after old old' {n}.input s h2 inventory p2
        {n}.fn {n}.types {n}.out {n}.hx {n}.hw {n}.x {n}.w {n}.stream {n}.epsilon {n}.function {n}.signature {n}.returns {n}.sourceThis {n}.xn {n}.wn
        {n}.source_control {n}.source_function_read {n}.source_function_kind {n}.source_signature_read {n}.source_signature_kind
        signatureFrame handlesLive {n}.weight_nonzero {n}.source_producers {n}.source_x {n}.source_w geometry fl
        {n}.source_node_bound targetNodes {n}.source_handle_bound targetHandles {n}.source_heap_bound targetHeap
        fnRole thisRole epsilonNote epsilonSchema controlNote slotNote
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained support
      exact ⟨_,source,right,post,retained,policy',support,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
