import host.mlx.NativeAttentionRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def attentionHeader : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated in\n"

/-- Select the original rank-four SDPA call with its current producers and
mask bytes. The transport theorem derives target metadata from indexed node
roles, including a variable cache-prefix length. -/
elab "host_retained_attention " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_attention: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_attention: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let mut args := ctl.getAppArgs[2]!
    let mut values : Array Lean.Expr := #[]
    for _ in [:10] do
      values := values.push (← field args ``List.cons 3 1)
      args ← field args ``List.cons 3 2
    unless (← whnf args).isAppOfArity ``List.nil 1 do throwError "host_retained_attention: expected ten arguments"
    let pointer (value : Lean.Expr) := do
      let memory ← field value ``Val.ptr 2 0
      unless ← isDefEq (← field value ``Val.ptr 2 1) (mkNatLit 0) do
        throwError "host_retained_attention: expected zero pointer offset"
      field memory ``Mem.js 1 0
    let natural (value : Lean.Expr) := do mkAppM ``Int.toNat #[← field value ``Val.big 1 0]
    let out ← pointer values[0]!
    let hq ← natural values[1]!
    let hk ← natural values[2]!
    let hv ← natural values[3]!
    let scale ← field (← field values[4]! ``Val.num 1 0) ``NumV.lit 1 0
    let maskBuffer ← pointer values[5]!
    for i in [6,7] do
      unless ← isDefEq (← natural values[i]!) (mkNatLit 0) do
        throwError "host_retained_attention: expected null mask/size handles"
    let force ← field values[8]! ``Val.bool 1 0
    let stream ← natural values[9]!
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do
      throwError "host_retained_attention: expected FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_fast_scaled_dot_product_attention") do
      throwError "host_retained_attention: expected scaled dot-product attention"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_attention: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let maskObject ← field (← mkAppM ``St.obj? #[s,maskBuffer]) ``Option.some 2 1
    let maskBytes ← field (← mkAppM ``Obj.kind #[maskObject]) ``Kind.buf 1 0
    let maskArg ← mkAppM ``Arg.jsPtr #[maskBuffer,mkNatLit 0,maskBytes]
    let mask ← field (← mkAppM ``Host.Mlx.Ffi.cstrArg #[maskArg]) ``Option.some 2 1
    let mlx ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let q ← field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[mlx,hq]) ``Option.some 2 1
    let k ← field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[mlx,hk]) ``Option.some 2 1
    let v ← field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[mlx,hv]) ``Option.some 2 1
    let nodes ← mkAppM ``Host.Mlx.Ffi.St.nodes #[mlx]
    let qn ← field (← mkAppM ``PTrie.get #[nodes,q]) ``Option.some 2 1
    let kn ← field (← mkAppM ``PTrie.get #[nodes,k]) ``Option.some 2 1
    let vn ← field (← mkAppM ``PTrie.get #[nodes,v]) ``Option.some 2 1
    for node in [qn,kn,vn] do
      unless ← isDefEq (← mkAppM ``List.length #[← mkAppM ``Host.Mlx.Ffi.Node.shape #[node]]) (mkNatLit 4) do
        throwError "host_retained_attention: expected rank-four query/key/value"
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("types",types),("signatureObject",signatureObject),("returns",returns),("sourceThis",ctl.getAppArgs[1]!),
      ("out",out),("hq",hq),("hk",hk),("hv",hv),("scale",scale),("force",force),("stream",stream),
      ("q",q),("k",k),("v",v),("qn",qn),("kn",kn),("vn",vn),("maskBuffer",maskBuffer),
      ("maskObject",maskObject),("maskBytes",maskBytes),("mask",mask)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.hq),.big (Int.ofNat {n}.hk),.big (Int.ofNat {n}.hv),.num (.lit {n}.scale),.ptr (.js {n}.maskBuffer) 0,.big 0,.big 0,.bool {n}.force,.big (Int.ofNat {n}.stream)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str Host.Load.Run.Full.Ordinary.AttentionHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array Host.Load.Run.Full.Ordinary.AttentionHost.signature"),
    ("source_mask",s!"{n}.input.heap.get {n}.maskBuffer = some (.obj {n}.maskObject)"),
    ("mask_kind",s!"{n}.maskObject.kind = .buf {n}.maskBytes"),
    ("mask_decode",s!"cstrArg (.jsPtr {n}.maskBuffer 0 {n}.maskBytes) = some {n}.mask"),
    ("source_producers",s!"nodesOf {n}.input.ffi.mlx [{n}.hq,{n}.hk,{n}.hv] = some [{n}.q,{n}.k,{n}.v]"),
    ("source_query",s!"{n}.input.ffi.mlx.nodes.get {n}.q = some {n}.qn"),
    ("source_key",s!"{n}.input.ffi.mlx.nodes.get {n}.k = some {n}.kn"),
    ("source_value",s!"{n}.input.ffi.mlx.nodes.get {n}.v = some {n}.vn"),
    ("query_rank",s!"len {n}.qn.shape = 4"),("key_rank",s!"len {n}.kn.shape = 4"),("value_rank",s!"len {n}.vn.shape = 4")]
    do Parametric.Driver.emit (attentionHeader ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  for (fact,type) in [
    ("source_native_bound",s!"{n}.input.ffi.mlx.next < 2^64"),
    ("source_node_bound",s!"{n}.input.ffi.mlx.nnext < 2^64"),
    ("source_output_bound",s!"{n}.out < 2^64")]
    do Parametric.Driver.emit (attentionHeader ++ s!"theorem {n}.{fact} : {type} := by decide +kernel")
  Parametric.Driver.emit (attentionHeader ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (attentionHeader ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (attentionHeader ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (signatureFrame : ¬ framed {n}.types) (handlesLive : listSupport H [{n}.hq,{n}.hk,{n}.hv])
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
      (fnRole thisRole : Annotated.Value)
      (note : notes.runtime.control = callNote fnRole thisRole ((Host.Load.Run.Full.Ordinary.AttentionHost.arguments
        {n}.out {n}.hq {n}.hk {n}.hv {n}.maskBuffer {n}.stream {n}.scale {n}.force).map FixedArgument.role))
      (selected : notes.buffers.owners {n}.out = some (handleSlotNotes 0)) :
      let newRoles := nodeWrite roles {n}.input.ffi.mlx.nnext (attentionRole roles {n}.q {n}.k {n}.v
        (Host.Load.Run.Full.Ordinary.AttentionHost.scaleRole {n}.scale) {n}.mask)
      let newObjects := objectWrite objects {n}.input.ffi.mlx.next .stream
      let newH := fun a => a = {n}.input.ffi.mlx.next ∨ H a
      let newN := fun i => i = {n}.input.ffi.mlx.nnext ∨ N i
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C)
          (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.nativeHandleResult {n}.out {n}.input.ffi.mlx.next) ν₀ ν C₀ C R live {n}.output result ∧
        ProducerAnnotations roots newH newN newRoles newObjects ∧
        ProducerSupport roots newH newN {n}.output.ffi.mlx ∧ Inst ν₀ {n}.nextServer C₀ := by
      exact Host.Load.Run.Full.Ordinary.AttentionHost.retained_cut ν₀ ν C₀ C R roles boundary objects H N tail host
        live framed before after old old' {n}.input s h inventory {n}.address {n}.types {n}.out {n}.hq {n}.hk {n}.hv
        {n}.q {n}.k {n}.v {n}.maskBuffer {n}.stream {n}.scale {n}.force {n}.object {n}.signatureObject {n}.maskObject
        {n}.returns {n}.sourceThis {n}.maskBytes {n}.mask {n}.qn {n}.kn {n}.vn {n}.source_control {n}.source_heap
        {n}.source_kind {n}.source_signature {n}.signature_kind {n}.source_mask {n}.mask_kind signatureFrame handlesLive
        {n}.source_producers {n}.source_query {n}.source_key {n}.source_value {n}.mask_decode {n}.query_rank {n}.key_rank {n}.value_rank
        {n}.source_node_bound targetNodes {n}.source_native_bound targetHandles {n}.source_output_bound targetHeap roots policy
        fnRole thisRole note selected {n}.output {n}.initialServer {n}.nextServer inst {n}.source_step")

end Host.Ts.Owned.Annotated.Driver
