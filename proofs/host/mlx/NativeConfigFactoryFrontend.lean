import host.mlx.NativeConfigFactoryRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select and check the original empty Metal configuration constructor. -/
elab "host_retained_configNew " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_configNew: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.call 3 do throwError "host_retained_configNew: expected source call"
    unless (← whnf control.getAppArgs[2]!).isAppOfArity ``List.nil 1 do
      throwError "host_retained_configNew: expected no arguments"
    let fn ← field control.getAppArgs[0]! ``Val.obj 1 0
    let function ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let caps ← field code ``Code.native 2 1
    let caps ← field caps ``List.cons 3 2
    let types ← field (← field caps ``List.cons 3 1) ``Val.obj 1 0
    let returns ← field (← field (← field caps ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0
    let signature ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceFn",fn),("sourceFunction",function),
      ("sourceTypes",types),("sourceReturns",returns),("sourceSignature",signature),("sourceThis",control.getAppArgs[1]!)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.sourceFn) {n}.sourceThis []"),
    ("source_function_read",s!"{n}.input.heap.get {n}.sourceFn = some (.obj {n}.sourceFunction)"),
    ("source_function_kind",s!"{n}.sourceFunction.kind = .fn (.native (.ffi .symbol) [.str chars!\"mlx_fast_metal_kernel_config_new\",.obj {n}.sourceTypes,.str {n}.sourceReturns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.sourceTypes = some (.obj {n}.sourceSignature)"),
    ("source_signature_kind",s!"{n}.sourceSignature.kind = .array []")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.ffi.mlx.next < 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let noteText := "notes.withRuntime {notes.runtime with control := returnNote (.handle " ++ n ++ ".input.ffi.mlx.next)}"
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
      (signatureFrame : ¬ framed {n}.sourceTypes) (targetBound : s.ffi.mlx.next < 2^64) :
      let newObjects := objectWrite objects {n}.input.ffi.mlx.next (.config emptyConfig)
      let newHandles := fun i => i = {n}.input.ffi.mlx.next ∨ H i
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C)
          (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary newObjects newHandles N tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory ({noteText}) ν₀ ν C₀ C R live {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ ∧ ProducerAnnotations roots newHandles N nodes newObjects ∧
        ProducerSupport roots newHandles N {n}.output.ffi.mlx ∧
        ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
          (resourceImage R.handle newHandles) (resourceImage R.node N) result.ffi.mlx := by
      dsimp only
      obtain ⟨left,right,post,retained,policy',sourceSupport,targetSupport⟩ :=
        ConfigFactoryInventory.retained_from_source ν₀ ν C₀ C R nodes boundary objects roots H N tail host
          live framed before after old old' {n}.input s h inventory policy {n}.sourceFn {n}.sourceTypes
          {n}.sourceFunction {n}.sourceSignature {n}.sourceReturns {n}.sourceThis {n}.source_control
          {n}.source_function_read {n}.source_function_kind {n}.source_signature_read {n}.source_signature_kind
          signatureFrame {n}.source_bound targetBound
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained sourceSupport
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source,policy',sourceSupport,targetSupport⟩")

end Host.Ts.Owned.Annotated.Driver
