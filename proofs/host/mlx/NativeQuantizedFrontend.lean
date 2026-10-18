import host.mlx.NativeQuantizedRetained
import host.mlx.NativeQuantizedLiteralGeometry
import host.mlx.NativeClosedProducer
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select the original ten-argument affine matmul. Current closed producer
shapes and the source's checked ABI certify both geometries and all guards. -/
elab "host_retained_quantized " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_quantized: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.call 3 do throwError "host_retained_quantized: expected source call"
    let fn ← field control.getAppArgs[0]! ``Val.obj 1 0
    let mut rest := control.getAppArgs[2]!
    let mut values : Array Lean.Expr := #[]
    for _ in [:10] do
      values := values.push (← field rest ``List.cons 3 1)
      rest ← field rest ``List.cons 3 2
    unless (← whnf rest).isAppOfArity ``List.nil 1 do throwError "host_retained_quantized: expected ten arguments"
    let pointer (value : Lean.Expr) := do
      unless ← isDefEq (← field value ``Val.ptr 2 1) (mkNatLit 0) do throwError "host_retained_quantized: expected zero pointer offset"
      field (← field value ``Val.ptr 2 0) ``Mem.js 1 0
    let natural (value : Lean.Expr) := do mkAppM ``Int.toNat #[← field value ``Val.big 1 0]
    let out ← pointer values[0]!
    let mut handles : Array Lean.Expr := #[]
    for i in [1,2,3,4] do handles := handles.push (← natural values[i]!)
    let tr ← field values[5]! ``Val.bool 1 0
    let group ← mkAppM ``Nat.mod #[← natural values[6]!,mkNatLit (2^32)]
    let bits ← mkAppM ``Nat.mod #[← natural values[7]!,mkNatLit (2^32)]
    let modeBuffer ← pointer values[8]!
    let stream ← natural values[9]!
    let function ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do throwError "host_retained_quantized: expected native FFI symbol"
    let captures := code.getAppArgs[1]!
    let symbol ← field (← field captures ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_quantized_matmul") do throwError "host_retained_quantized: expected quantized matmul"
    let captures ← field captures ``List.cons 3 2
    let types ← field (← field captures ``List.cons 3 1) ``Val.obj 1 0
    let returns ← field (← field (← field captures ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0
    let signature ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let modeObject ← field (← mkAppM ``St.obj? #[s,modeBuffer]) ``Option.some 2 1
    let modeBytes ← field (← mkAppM ``Obj.kind #[modeObject]) ``Kind.buf 1 0
    let nativeState ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let mut producers : Array Lean.Expr := #[]
    let mut nodes : Array Lean.Expr := #[]
    let mut shapes : Array Lean.Expr := #[]
    for handle in handles do
      let producer ← field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[nativeState,handle]) ``Option.some 2 1
      let node ← field (← mkAppM ``PTrie.get #[← mkAppM ``Host.Mlx.Ffi.St.nodes #[nativeState],producer]) ``Option.some 2 1
      let mut dimensions ← mkAppM ``Host.Mlx.Ffi.Node.shape #[node]
      let mut integers : Array Lean.Expr := #[]
      while !(← whnf dimensions).isAppOfArity ``List.nil 1 do
        integers := integers.push (← field (← field dimensions ``List.cons 3 1) ``Host.Mlx.Ffi.Dim.lit 1 0)
        dimensions ← field dimensions ``List.cons 3 2
      producers := producers.push producer
      nodes := nodes.push node
      shapes := shapes.push (← mkListLit (mkConst ``Int) integers.toList)
    let weight := shapes[1]!
    let rows ← field weight ``List.cons 3 1
    let weightTail ← field weight ``List.cons 3 2
    let cols ← field weightTail ``List.cons 3 1
    unless (← whnf (← field weightTail ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_quantized: expected rank-two packed weights"
    for (tag,value) in [("F",f),("input",s),("output",t),("fn",fn),("out",out),("stream",stream),
      ("function",function),("types",types),("returns",returns),("signature",signature),("sourceThis",control.getAppArgs[1]!),
      ("tr",tr),("group",group),("bits",bits),("rows",rows),("cols",cols),("modeBuffer",modeBuffer),
      ("modeObject",modeObject),("modeBytes",modeBytes),("inputSizes",shapes[0]!),("scaleSizes",shapes[2]!)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    for i in [:4] do
      let tag := #["x","w","sc","bi"][i]!
      addData (pre ++ Name.mkSimple ("h"++tag)) handles[i]!
      addData (pre ++ Name.mkSimple tag) producers[i]!
      addData (pre ++ Name.mkSimple (tag++"n")) nodes[i]!
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.fn) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.hx),.big (Int.ofNat {n}.hw),.big (Int.ofNat {n}.hsc),.big (Int.ofNat {n}.hbi),.bool {n}.tr,.big (Int.ofNat (packedOptInt {n}.group)),.big (Int.ofNat (packedOptInt {n}.bits)),.ptr (.js {n}.modeBuffer) 0,.big (Int.ofNat {n}.stream)]"),
    ("source_function_read",s!"{n}.input.heap.get {n}.fn = some (.obj {n}.function)"),
    ("source_function_kind",s!"{n}.function.kind = .fn (.native (.ffi .symbol) [.str QuantizedHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signature)"),
    ("source_signature_kind",s!"{n}.signature.kind = .array QuantizedHost.signature"),
    ("source_mode_read",s!"{n}.input.heap.get {n}.modeBuffer = some (.obj {n}.modeObject)"),
    ("source_mode_kind",s!"{n}.modeObject.kind = .buf {n}.modeBytes"),
    ("source_producers",s!"nodesOf {n}.input.ffi.mlx [{n}.hx,{n}.hw,{n}.hsc,{n}.hbi] = some [{n}.x,{n}.w,{n}.sc,{n}.bi]"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  for (tag,sizes) in [("x",s!"{n}.inputSizes"),("w",s!"[{n}.rows,{n}.cols]"),("sc",s!"{n}.scaleSizes"),("bi",s!"{n}.scaleSizes")] do
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_{tag} : {n}.input.ffi.mlx.nodes.get {n}.{tag} = some {n}.{tag}n := by host_kernel_rfl")
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_{tag}_shape : {n}.{tag}n.shape = ({sizes}).map Dim.lit := by host_kernel_rfl")
  for a in ["x","w","sc","bi"] do
    for b in ["x","w","sc","bi"] do
      if a != b then Parametric.Driver.emit (header ++ s!"theorem {n}.{a}_ne_{b} : {n}.{a} ≠ {n}.{b} := by decide +kernel")
  for (tag,type) in [
    ("source_mode",s!"cstrArg (.jsPtr {n}.modeBuffer 0 {n}.modeBytes) = some chars!\"affine\""),
    ("weight_exact",s!"ExactDimensions [{n}.rows,{n}.cols]"),("scales_exact",s!"ExactDimensions {n}.scaleSizes"),
    ("inner_equal",s!"nthD 0 {n}.inputSizes (len {n}.inputSizes-1) = qmmInner {n}.tr {n}.bits {n}.rows {n}.cols"),
    ("inner_exact",s!"F64.toInt? (F64.ofInt (qmmInner {n}.tr {n}.bits {n}.rows {n}.cols)) = some (qmmInner {n}.tr {n}.bits {n}.rows {n}.cols)"),
    ("outer_exact",s!"F64.toInt? (F64.ofInt (qmmOuter {n}.tr {n}.bits {n}.rows {n}.cols)) = some (qmmOuter {n}.tr {n}.bits {n}.rows {n}.cols)"),
    ("source_weight_dtype",s!"{n}.wn.dtype = dtUint32"),("nonzero",s!"Nat.beq {n}.bits 0 = false"),
    ("source_float",s!"isFloat (promote {n}.xn.dtype (promote {n}.scn.dtype {n}.bin.dtype)) = true"),
    ("group_bound",s!"{n}.group < 2^32"),("bits_bound",s!"{n}.bits < 2^32"),
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
      (signatureFrame : ¬ framed {n}.types) (handlesLive : listSupport H [{n}.hx,{n}.hw,{n}.hsc,{n}.hbi])
      (closedX : closedLiteralShape (roles {n}.x).shape = true)
      (closedW : closedLiteralShape (roles {n}.w).shape = true)
      (closedSc : closedLiteralShape (roles {n}.sc).shape = true)
      (closedBi : closedLiteralShape (roles {n}.bi).shape = true)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (fnRole thisRole groupRole bitsRole : Annotated.Value)
      (groupSchema : FixedIntegerRole groupRole (Int.ofNat (packedOptInt {n}.group)))
      (bitsSchema : FixedIntegerRole bitsRole (Int.ofNat (packedOptInt {n}.bits)))
      (controlNote : notes.runtime.control = callNote fnRole thisRole
        [.ptr (.js {n}.out) 0,.handle {n}.hx,.handle {n}.hw,.handle {n}.hsc,.handle {n}.hbi,.bool {n}.tr,groupRole,bitsRole,.ptr (.js {n}.modeBuffer) 0,.handle {n}.stream])
      (slotNote : notes.buffers.owners {n}.out = some (handleSlotNotes 0)) :
      let normalizedRoles := nodeShapeRoles (nodeShapeRoles (nodeShapeRoles (nodeShapeRoles roles {n}.x {n}.inputSizes) {n}.w [{n}.rows,{n}.cols]) {n}.sc {n}.scaleSizes) {n}.bi {n}.scaleSizes
      let newRoles := nodeWrite normalizedRoles {n}.input.ffi.mlx.nnext (qmmRole normalizedRoles {n}.x {n}.w {n}.sc {n}.bi {n}.tr {n}.group {n}.bits {n}.rows {n}.cols)
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
      let r2 := nodeShapeRoles r1 {n}.w [{n}.rows,{n}.cols]
      let r3 := nodeShapeRoles r2 {n}.sc {n}.scaleSizes
      let r4 := nodeShapeRoles r3 {n}.bi {n}.scaleSizes
      have supported := h.native.2.nodesOf_support [{n}.hx,{n}.hw,{n}.hsc,{n}.hbi] [{n}.x,{n}.w,{n}.sc,{n}.bi] handlesLive {n}.source_producers
      obtain ⟨_,_,rx⟩ := h.native.2.node_view supported.1 {n}.source_x
      obtain ⟨_,_,rw⟩ := h.native.2.node_view supported.2.1 {n}.source_w
      obtain ⟨_,_,rs⟩ := h.native.2.node_view supported.2.2.1 {n}.source_sc
      obtain ⟨_,_,rb⟩ := h.native.2.node_view supported.2.2.2.1 {n}.source_bi
      obtain ⟨h1,_,p1,_⟩ := VectorHost.normalize_closed_producer h inventory {n}.x {n}.xn {n}.inputSizes supported.1
        {n}.source_x {n}.source_x_shape closedX roots policy
      have cw : closedLiteralShape (r1 {n}.w).shape = true := by
        simpa only [r1,nodeShapeRoles_other _ _ _ _ {n}.w_ne_x] using closedW
      obtain ⟨h2,_,p2,_⟩ := VectorHost.normalize_closed_producer h1 inventory {n}.w {n}.wn [{n}.rows,{n}.cols] supported.2.1
        {n}.source_w {n}.source_w_shape cw roots p1
      have cs : closedLiteralShape (r2 {n}.sc).shape = true := by
        simpa only [r2,r1,nodeShapeRoles_other _ _ _ _ {n}.sc_ne_w,nodeShapeRoles_other _ _ _ _ {n}.sc_ne_x] using closedSc
      obtain ⟨h3,_,p3,_⟩ := VectorHost.normalize_closed_producer h2 inventory {n}.sc {n}.scn {n}.scaleSizes supported.2.2.1
        {n}.source_sc {n}.source_sc_shape cs roots p2
      have cb : closedLiteralShape (r3 {n}.bi).shape = true := by
        simpa only [r3,r2,r1,nodeShapeRoles_other _ _ _ _ {n}.bi_ne_sc,nodeShapeRoles_other _ _ _ _ {n}.bi_ne_w,nodeShapeRoles_other _ _ _ _ {n}.bi_ne_x] using closedBi
      obtain ⟨h4,_,p4,_⟩ := VectorHost.normalize_closed_producer h3 inventory {n}.bi {n}.bin {n}.scaleSizes supported.2.2.2.1
        {n}.source_bi {n}.source_bi_shape cb roots p3
      have xs : (r4 {n}.x).shape = constantShape {n}.inputSizes := by
        simp only [r4,r3,r2,r1,nodeShapeRoles,nodeWrite,ite_eq_right {n}.x_ne_bi,ite_eq_right {n}.x_ne_sc,ite_eq_right {n}.x_ne_w,ite_true]
      have ws : (r4 {n}.w).shape = constantShape [{n}.rows,{n}.cols] := by
        simp only [r4,r3,r2,nodeShapeRoles,nodeWrite,ite_eq_right {n}.w_ne_bi,ite_eq_right {n}.w_ne_sc,ite_true]
      have ss : (r4 {n}.sc).shape = constantShape {n}.scaleSizes := by
        simp only [r4,r3,nodeShapeRoles,nodeWrite,ite_eq_right {n}.sc_ne_bi,ite_true]
      have bs : (r4 {n}.bi).shape = constantShape {n}.scaleSizes := by
        simp only [r4,nodeShapeRoles,nodeWrite,ite_true]
      have geometry (v : Nat → F64) : QmmGeometry v {n}.tr {n}.bits {n}.rows {n}.cols (r4 {n}.x).shape (r4 {n}.w).shape (r4 {n}.sc).shape (r4 {n}.bi).shape := by
        rw [xs,ws,ss,bs]
        exact .constants v {n}.tr {n}.bits {n}.rows {n}.cols {n}.inputSizes {n}.scaleSizes {n}.weight_exact {n}.scales_exact {n}.inner_equal {n}.inner_exact
      have wd : (r4 {n}.w).dtype = dtUint32 := by
        simpa only [r4,r3,r2,r1,nodeShapeRoles_dtype,←rw.source.dtype] using {n}.source_weight_dtype
      have fl : isFloat (promote (r4 {n}.x).dtype (promote (r4 {n}.sc).dtype (r4 {n}.bi).dtype)) = true := by
        simpa only [r4,r3,r2,r1,nodeShapeRoles_dtype,←rx.source.dtype,←rs.source.dtype,←rb.source.dtype] using {n}.source_float
      obtain ⟨sourcePost,result,left,right,post,retained,policy',support⟩ := QuantizedHost.retained_from_source
        ν₀ ν C₀ C R r4 boundary objects roots H N tail host live framed before after old old' {n}.input s h4 inventory p4
        {n}.fn {n}.types {n}.out {n}.hx {n}.hw {n}.hsc {n}.hbi {n}.x {n}.w {n}.sc {n}.bi {n}.modeBuffer {n}.stream {n}.group {n}.bits {n}.tr {n}.rows {n}.cols
        {n}.function {n}.signature {n}.modeObject {n}.returns {n}.sourceThis {n}.modeBytes {n}.xn {n}.wn {n}.scn {n}.bin
        {n}.source_control {n}.source_function_read {n}.source_function_kind {n}.source_signature_read {n}.source_signature_kind
        {n}.source_mode_read {n}.source_mode_kind signatureFrame handlesLive {n}.source_producers {n}.source_x {n}.source_w {n}.source_sc {n}.source_bi {n}.source_mode
        (geometry ν₀) (geometry ν) wd {n}.nonzero fl {n}.outer_exact {n}.group_bound {n}.bits_bound
        {n}.source_node_bound targetNodes {n}.source_handle_bound targetHandles {n}.source_heap_bound targetHeap
        fnRole thisRole groupRole bitsRole groupSchema bitsSchema controlNote slotNote
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained support
      exact ⟨_,source,right,post,retained,policy',support,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
