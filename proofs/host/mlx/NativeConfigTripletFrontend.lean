import host.mlx.NativeConfigTripletRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select the original grid or thread-group declaration. The three current
literal argument notes determine the original i32 conversions and the updated
configuration role; no target configuration contents are assumed. -/
elab "host_retained_configTriplet " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_configTriplet: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.call 3 do throwError "host_retained_configTriplet: expected source call"
    let fn ← field control.getAppArgs[0]! ``Val.obj 1 0
    let args := control.getAppArgs[2]!
    let handle ← mkAppM ``Int.toNat #[← field (← field args ``List.cons 3 1) ``Val.big 1 0]
    let mut rest ← field args ``List.cons 3 2
    let mut values : Array Lean.Expr := #[]
    for _ in [:3] do
      let value ← field (← field rest ``List.cons 3 1) ``Val.num 1 0
      values := values.push (← field value ``NumV.lit 1 0)
      rest ← field rest ``List.cons 3 2
    unless (← whnf rest).isAppOfArity ``List.nil 1 do throwError "host_retained_configTriplet: expected four arguments"
    let function ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.ffi 1 0
    unless (← whnf builtin).isConstOf ``FfiN.symbol do throwError "host_retained_configTriplet: expected native FFI symbol"
    let captures := code.getAppArgs[1]!
    let symbol ← field (← field captures ``List.cons 3 1) ``Val.str 1 0
    let op ← if ← isDefEq symbol (toExpr chars!"mlx_fast_metal_kernel_config_set_grid") then
        pure (mkConst ``Host.Mlx.Ffi.Annotated.ConfigTriplet.grid)
      else if ← isDefEq symbol (toExpr chars!"mlx_fast_metal_kernel_config_set_thread_group") then
        pure (mkConst ``Host.Mlx.Ffi.Annotated.ConfigTriplet.group)
      else throwError "host_retained_configTriplet: expected grid or thread-group declaration"
    let captures ← field captures ``List.cons 3 2
    let types ← field (← field captures ``List.cons 3 1) ``Val.obj 1 0
    let returns ← field (← field (← field captures ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0
    let signature ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let nativeState ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let config ← field (← field (← mkAppM ``Host.Mlx.Ffi.St.obj? #[nativeState,handle]) ``Option.some 2 1) ``Host.Mlx.Ffi.Obj.cfg 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceFn",fn),("sourceHandle",handle),
      ("sourceX",values[0]!),("sourceY",values[1]!),("sourceZ",values[2]!),("sourceOp",op),
      ("sourceFunction",function),("sourceTypes",types),("sourceReturns",returns),("sourceSignature",signature),
      ("sourceConfig",config),("sourceThis",control.getAppArgs[1]!)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.sourceFn) {n}.sourceThis [.big (Int.ofNat {n}.sourceHandle),.num (.lit {n}.sourceX),.num (.lit {n}.sourceY),.num (.lit {n}.sourceZ)]"),
    ("source_function_read",s!"{n}.input.heap.get {n}.sourceFn = some (.obj {n}.sourceFunction)"),
    ("source_function_kind",s!"{n}.sourceFunction.kind = .fn (.native (.ffi .symbol) [.str {n}.sourceOp.name,.obj {n}.sourceTypes,.str {n}.sourceReturns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.sourceTypes = some (.obj {n}.sourceSignature)"),
    ("source_signature_kind",s!"{n}.sourceSignature.kind = .array ConfigHost.signature"),
    ("source_config_read",s!"{n}.input.ffi.mlx.obj? {n}.sourceHandle = some (.cfg {n}.sourceConfig)"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.sourceHandle < 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let updated := s!"objectWrite objects {n}.sourceHandle (.config ({n}.sourceOp.role configRole [(Number.literal ex).decoded .i32,(Number.literal ey).decoded .i32,(Number.literal ez).decoded .i32]))"
  let nextNotes := "notes.withRuntime {notes.runtime with control := returnNote nativeStatusRole}"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (roots H N : Nat → Prop) (tail : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (policy : ProducerAnnotations roots H N nodes objects)
      (signatureFrame : ¬ framed {n}.sourceTypes) (handleLive : H {n}.sourceHandle)
      (configRole : Config) (objectRole : objects {n}.sourceHandle = .config configRole)
      (fnRole thisRole : Annotated.Value) (ex ey ez : SymE)
      (controlNote : notes.runtime.control = callNote fnRole thisRole [.handle {n}.sourceHandle,.literal ex,.literal ey,.literal ez])
      (targetBound : R.handle {n}.sourceHandle < 2^64) :
      let updated := {updated}
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary updated H N tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory ({nextNotes})
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ ∧
        ProducerAnnotations roots H N nodes updated ∧ ProducerSupport roots H N {n}.output.ffi.mlx ∧
        ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) result.ffi.mlx := by
      dsimp only
      obtain ⟨x₀,y₀,z₀,x,y,z,target,left,right,post,retained,policy'⟩ :=
        ConfigTripletInventory.retained_from_source ν₀ ν C₀ C R nodes boundary objects roots H N tail host
          live framed before after old old' {n}.input s h inventory policy
          {n}.sourceOp {n}.sourceFn {n}.sourceTypes {n}.sourceHandle (.lit {n}.sourceX) (.lit {n}.sourceY) (.lit {n}.sourceZ)
          {n}.sourceFunction {n}.sourceSignature {n}.sourceReturns {n}.sourceThis
          {n}.source_control {n}.source_function_read {n}.source_function_kind {n}.source_signature_read {n}.source_signature_kind
          signatureFrame handleLive configRole {n}.sourceConfig objectRole {n}.source_config_read fnRole thisRole ex ey ez controlNote
          {n}.source_bound targetBound
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      have sourceSupport := policy'.source post.native.2
      have targetSupport := policy'.target post.native.2
      rw [same] at post retained sourceSupport
      exact ⟨_,source,right,post,retained,{n}.source_servers ▸ inst,policy',sourceSupport,targetSupport⟩")

end Host.Ts.Owned.Annotated.Driver
