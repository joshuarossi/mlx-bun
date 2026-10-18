import host.mlx.NativeConvRetained
import host.mlx.NativeClosedProducer
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def convHeader : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated in\n"

/-- Current closed input/weight shapes and literal parameter occurrences
supply source-selected convolution geometry for both valuations. -/
elab "host_retained_conv1d " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_conv1d: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_conv1d: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let mut arguments := ctl.getAppArgs[2]!
    let mut values : Array Lean.Expr := #[]
    for _ in [:8] do
      values := values.push (← field arguments ``List.cons 3 1)
      arguments ← field arguments ``List.cons 3 2
    unless (← whnf arguments).isAppOfArity ``List.nil 1 do throwError "host_retained_conv1d: expected eight arguments"
    let pointer (value : Lean.Expr) := do
      let owner ← field (← field value ``Val.ptr 2 0) ``Mem.js 1 0
      unless ← isDefEq (← field value ``Val.ptr 2 1) (mkNatLit 0) do throwError "host_retained_conv1d: expected zero pointer offset"
      pure owner
    let natural (value : Lean.Expr) := do mkAppM ``Int.toNat #[← field value ``Val.big 1 0]
    let out ← pointer values[0]!
    let hx ← natural values[1]!
    let hy ← natural values[2]!
    let stream ← natural values[7]!
    let mut parameters : Array (Lean.Expr × Lean.Expr) := #[]
    for i in [3,4,5,6] do
      let number ← field values[i]! ``Val.num 1 0
      let literal ← field number ``NumV.lit 1 0
      let value ← field (← mkAppM ``Host.Mlx.Ffi.argNat #[← mkAppM ``Arg.num #[number]]) ``Option.some 2 1
      parameters := parameters.push (value,literal)
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do throwError "host_retained_conv1d: expected FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_conv1d") do throwError "host_retained_conv1d: expected mlx_conv1d"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do throwError "host_retained_conv1d: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let mlx ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let producer (handle : Lean.Expr) := do field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[mlx,handle]) ``Option.some 2 1
    let x ← producer hx
    let y ← producer hy
    let nodes ← mkAppM ``Host.Mlx.Ffi.St.nodes #[mlx]
    let xn ← field (← mkAppM ``PTrie.get #[nodes,x]) ``Option.some 2 1
    let yn ← field (← mkAppM ``PTrie.get #[nodes,y]) ``Option.some 2 1
    let dimensions (node : Lean.Expr) := do
      let mut rest ← mkAppM ``Host.Mlx.Ffi.Node.shape #[node]
      let mut result : Array Lean.Expr := #[]
      for _ in [:3] do
        result := result.push (← field (← field rest ``List.cons 3 1) ``Host.Mlx.Ffi.Dim.lit 1 0)
        rest ← field rest ``List.cons 3 2
      unless (← whnf rest).isAppOfArity ``List.nil 1 do throwError "host_retained_conv1d: expected rank-three literal inputs"
      pure result
    let xd ← dimensions xn
    let yd ← dimensions yn
    let inputSizes ← mkListLit (mkConst ``Int) xd.toList
    let weightSizes ← mkListLit (mkConst ``Int) yd.toList
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("types",types),("signatureObject",signatureObject),("returns",returns),("sourceThis",ctl.getAppArgs[1]!),
      ("out",out),("hx",hx),("hy",hy),("stream",stream),("x",x),("y",y),("xn",xn),("yn",yn),
      ("inputSizes",inputSizes),("weightSizes",weightSizes),("batch",xd[0]!),("length",xd[1]!),("channels",xd[2]!),
      ("outChannels",yd[0]!),("kernel",yd[1]!),("inChannels",yd[2]!)] do
      let type? := if tag == "input" || tag == "output" then some stateTy else none
      addData (pre ++ Name.mkSimple tag) value type?
    for (tag,(value,literal)) in (["stride","padding","dilation","groups"].zip parameters.toList) do
      addData (pre ++ Name.mkSimple tag) value
      addData (pre ++ Name.mkSimple (tag++"Value")) literal
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  for tag in ["stride","padding","dilation","groups"] do
    Parametric.Driver.emit (convHeader ++ s!"theorem {n}.{tag}_decode : argNat (.num (.lit {n}.{tag}Value)) = some {n}.{tag} := by host_kernel_rfl")
    Parametric.Driver.emit (convHeader ++ s!"theorem {n}.{tag}_fixed : F64.un .int32 {n}.{tag}Value = {n}.{tag}Value := by decide +kernel")
  Parametric.Driver.emit (convHeader ++ s!"noncomputable def {n}.parameters : ConvParameters := ⟨{n}.stride,{n}.padding,{n}.dilation,{n}.groups,{n}.strideValue,{n}.paddingValue,{n}.dilationValue,{n}.groupsValue,{n}.stride_decode,{n}.padding_decode,{n}.dilation_decode,{n}.groups_decode⟩")
  Parametric.Driver.emit (convHeader ++ s!"noncomputable def {n}.outputSizes : List Int := [{n}.batch,convLength {n}.length {n}.kernel {n}.stride {n}.padding {n}.dilation,{n}.outChannels]")
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.hx),.big (Int.ofNat {n}.hy),.num (.lit {n}.strideValue),.num (.lit {n}.paddingValue),.num (.lit {n}.dilationValue),.num (.lit {n}.groupsValue),.big (Int.ofNat {n}.stream)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str Host.Load.Run.Full.Ordinary.ConvFamilyHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array Host.Load.Run.Full.Ordinary.ConvFamilyHost.signature"),
    ("source_producers",s!"nodesOf {n}.input.ffi.mlx [{n}.hx,{n}.hy] = some [{n}.x,{n}.y]"),
    ("source_x",s!"{n}.input.ffi.mlx.nodes.get {n}.x = some {n}.xn"),
    ("source_y",s!"{n}.input.ffi.mlx.nodes.get {n}.y = some {n}.yn"),
    ("source_input_shape",s!"{n}.xn.shape = {n}.inputSizes.map Dim.lit"),
    ("source_weight_shape",s!"{n}.yn.shape = {n}.weightSizes.map Dim.lit"),
    ("input_values",s!"{n}.inputSizes = [{n}.batch,{n}.length,{n}.channels]"),
    ("weight_values",s!"{n}.weightSizes = [{n}.outChannels,{n}.kernel,{n}.inChannels]"),
    ("source_allocation",s!"{n}.output.ffi.mlx.nnext = {n}.input.ffi.mlx.nnext + 1")]
    do Parametric.Driver.emit (convHeader ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  for (fact,type) in [
    ("source_native_bound",s!"{n}.input.ffi.mlx.next < 2^64"),("source_node_bound",s!"{n}.input.ffi.mlx.nnext < 2^64"),
    ("source_output_bound",s!"{n}.out < 2^64"),("input_exact",s!"ExactDimensions {n}.inputSizes"),
    ("weight_exact",s!"ExactDimensions {n}.weightSizes"),("output_exact",s!"ExactDimensions {n}.outputSizes"),
    ("stride_positive",s!"0 < {n}.stride"),("groups_positive",s!"0 < {n}.groups"),
    ("channel_guard",s!"{n}.channels = {n}.inChannels*{n}.groups"),("x_ne_y",s!"{n}.x ≠ {n}.y"),("y_ne_x",s!"{n}.y ≠ {n}.x")]
    do Parametric.Driver.emit (convHeader ++ s!"theorem {n}.{fact} : {type} := by decide +kernel")
  Parametric.Driver.emit (convHeader ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (convHeader ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (convHeader ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (signatureFrame : ¬ framed {n}.types) (handlesLive : listSupport H [{n}.hx,{n}.hy])
      (closedInput : closedLiteralShape (roles {n}.x).shape = true)
      (closedWeight : closedLiteralShape (roles {n}.y).shape = true)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
      (fnRole thisRole stride padding dilation groups : Annotated.Value)
      (strideSchema : ClosedLiteralNote stride) (paddingSchema : ClosedLiteralNote padding)
      (dilationSchema : ClosedLiteralNote dilation) (groupsSchema : ClosedLiteralNote groups)
      (note : notes.runtime.control = callNote fnRole thisRole
        (Host.Load.Run.Full.Ordinary.ConvFamilyHost.convArgumentNotes {n}.out {n}.hx {n}.hy {n}.stream stride padding dilation groups))
      (selected : notes.buffers.owners {n}.out = some (handleSlotNotes 0)) :
      let normalizedRoles := nodeShapeRoles (nodeShapeRoles roles {n}.x {n}.inputSizes) {n}.y {n}.weightSizes
      let newRoles := nodeWrite normalizedRoles {n}.input.ffi.mlx.nnext (convRole normalizedRoles {n}.parameters {n}.x {n}.y (constantShape {n}.outputSizes))
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
      let roles1 := nodeShapeRoles roles {n}.x {n}.inputSizes
      let roles2 := nodeShapeRoles roles1 {n}.y {n}.weightSizes
      have supported := h.native.2.nodesOf_support [{n}.hx,{n}.hy] [{n}.x,{n}.y] handlesLive {n}.source_producers
      obtain ⟨h1,_,policy1,_⟩ := Host.Load.Run.Full.Ordinary.VectorHost.normalize_closed_producer h inventory
        {n}.x {n}.xn {n}.inputSizes supported.1 {n}.source_x {n}.source_input_shape closedInput roots policy
      have closedWeight1 : closedLiteralShape (roles1 {n}.y).shape = true := by
        simpa only [roles1,nodeShapeRoles,nodeWrite,ite_eq_right {n}.y_ne_x] using closedWeight
      obtain ⟨h2,_,policy2,_⟩ := Host.Load.Run.Full.Ordinary.VectorHost.normalize_closed_producer h1 inventory
        {n}.y {n}.yn {n}.weightSizes supported.2.1 {n}.source_y {n}.source_weight_shape closedWeight1 roots policy1
      have xs : (roles2 {n}.x).shape = constantShape {n}.inputSizes := by
        simp only [roles2,roles1,nodeShapeRoles,nodeWrite,ite_eq_right {n}.x_ne_y,ite_true]
      have ys : (roles2 {n}.y).shape = constantShape {n}.weightSizes := by
        simp only [roles2,nodeShapeRoles,nodeWrite,ite_true]
      have geometry (v : Nat → F64) : ConvGeometry v (roles2 {n}.x).shape (roles2 {n}.y).shape
          (constantShape {n}.outputSizes) {n}.parameters.stride {n}.parameters.padding {n}.parameters.dilation {n}.parameters.groups := by
        rw [xs,ys,{n}.input_values,{n}.weight_values]
        exact ConvGeometry.constants v {n}.stride {n}.padding {n}.dilation {n}.groups {n}.batch {n}.length {n}.channels
          {n}.outChannels {n}.kernel {n}.inChannels (by simpa only [{n}.input_values] using {n}.input_exact)
          (by simpa only [{n}.weight_values] using {n}.weight_exact) {n}.output_exact
          {n}.stride_positive {n}.groups_positive {n}.channel_guard
      obtain ⟨sourcePost,result,left,right,post,retained,policyPost,support⟩ :=
        Host.Load.Run.Full.Ordinary.ConvFamilyHost.retained_from_source {n}.parameters ν₀ ν C₀ C R roles2 boundary objects H N tail host
          live framed before after old old' {n}.input s h2 inventory {n}.address {n}.types {n}.out {n}.hx {n}.hy {n}.x {n}.y {n}.stream
          {n}.returns {n}.object {n}.signatureObject {n}.sourceThis {n}.xn {n}.yn (constantShape {n}.outputSizes)
          {n}.source_control {n}.source_heap {n}.source_kind {n}.source_signature {n}.signature_kind signatureFrame handlesLive
          {n}.source_producers {n}.source_x {n}.source_y {n}.stride_fixed {n}.padding_fixed {n}.dilation_fixed {n}.groups_fixed
          (geometry ν₀) (geometry ν) {n}.source_node_bound targetNodes {n}.source_native_bound targetHandles
          {n}.source_output_bound targetHeap roots policy2 fnRole thisRole stride padding dilation groups
          strideSchema paddingSchema dilationSchema groupsSchema note selected
      obtain ⟨D,actual,instAfter⟩ := interp_sim ν₀ (step {n}.F {n}.input).run {n}.initialServer C₀ {n}.output {n}.nextServer inst {n}.source_step
      have equality := Option.some.inj (left.symm.trans actual)
      have same : sourcePost = {n}.output := congrArg Prod.fst equality
      have table : C₀ = D := congrArg Prod.snd equality
      rw [same] at left post retained support
      exact ⟨result,left,right,post,retained,policyPost,support,table ▸ instAfter⟩")

end Host.Ts.Owned.Annotated.Driver
