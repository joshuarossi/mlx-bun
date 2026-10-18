import host.mlx.NativeEvalRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Evaluation uses the current owned array/vector handle. Target validity follows the strong native relation; no independent target read is accepted. -/
elab "host_retained_eval " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let arrayMode ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_eval: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_eval: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let values := ctl.getAppArgs[2]!
    let handle ← mkAppM ``Int.toNat #[← field (← field values ``List.cons 3 1) ``Val.big 1 0]
    unless (← whnf (← field values ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_eval: expected exactly one argument"
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.ffi 1 0
    unless (← whnf builtin).isConstOf ``FfiN.symbol do throwError "host_retained_eval: expected native FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    let (mode,arrayMode) ← if ← isDefEq symbol (toExpr chars!"mlx_array_eval") then pure (mkConst ``Host.Load.Run.Full.Ordinary.EvalHost.Mode.arrayEval,true)
      else if ← isDefEq symbol (toExpr chars!"mlx_eval") then pure (mkConst ``Host.Load.Run.Full.Ordinary.EvalHost.Mode.vector,false)
      else if ← isDefEq symbol (toExpr chars!"mlx_async_eval") then pure (mkConst ``Host.Load.Run.Full.Ordinary.EvalHost.Mode.asyncVector,false)
      else throwError "host_retained_eval: expected mlx_array_eval, mlx_eval or mlx_async_eval"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_eval: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let world ← mkAppM ``St.ffi #[s]
    let mlx ← mkAppM ``Host.Load.LSt.mlx #[world]
    let validity ← whnf (← mkAppM (if arrayMode then ``Host.Mlx.Ffi.St.node? else ``Host.Mlx.Ffi.St.obj?) #[mlx,handle])
    unless validity.isAppOfArity ``Option.some 2 do throwError "host_retained_eval: source handle is absent"
    let sourceInput := validity.getAppArgs[1]!
    let sourceInput ← if arrayMode then pure sourceInput else field sourceInput ``Host.Mlx.Ffi.Obj.vec 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),("handle",handle),
      ("mode",mode),("sourceInput",sourceInput),("types",types),("signatureObject",signatureObject),("returns",returns),("sourceThis",ctl.getAppArgs[1]!)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
    pure arrayMode
  let inputType := if arrayMode then s!"{pre}.input.ffi.mlx.node? {pre}.handle = some {pre}.sourceInput" else s!"{pre}.input.ffi.mlx.obj? {pre}.handle = some (.vec {pre}.sourceInput)"
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi.Annotated in\n"
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.big (Int.ofNat {n}.handle)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str (Host.Load.Run.Full.Ordinary.EvalHost.Mode.name {n}.mode),.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array [.str chars!\"u64\"]"),
    ("source_valid",inputType),
    ("source_ffi",s!"{n}.output.ffi = {n}.input.ffi")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_input : Host.Load.Run.Full.Ordinary.EvalHost.Mode.Input {n}.mode {n}.input.ffi.mlx {n}.handle := ⟨{n}.sourceInput,{n}.source_valid⟩")
  let returnRole := "nativeStatusRole"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (signatureFrame : ¬ framed {n}.types) (owned : H {n}.handle)
      (roots : Nat → Prop) (policy : Host.Mlx.Ffi.Annotated.ProducerAnnotations roots H N roles objects)
      (fnRole thisRole : Annotated.Value) (note : notes.runtime.control = callNote fnRole thisRole [.handle {n}.handle]) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C)
          (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote ({returnRole}),notes.runtime.stack,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ result.ffi = s.ffi ∧ Inst ν₀ {n}.nextServer C₀ ∧
        Host.Mlx.Ffi.Annotated.ProducerAnnotations roots H N roles objects ∧
        Host.Mlx.Ffi.NativeRoles.ProducerSupport roots H N {n}.output.ffi.mlx ∧
        Host.Mlx.Ffi.NativeRoles.ProducerSupport (Host.Mlx.Ffi.NativeRoles.resourceImage R.node (fun i => N i ∧ roots i))
          (Host.Mlx.Ffi.NativeRoles.resourceImage R.handle H) (Host.Mlx.Ffi.NativeRoles.resourceImage R.node N) result.ffi.mlx := by
      obtain ⟨left,right,post,retained⟩ := Host.Load.Run.Full.Ordinary.EvalInventory.retained_from_source {n}.mode
        ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' {n}.input s h inventory
        {n}.address {n}.types {n}.handle {n}.object {n}.signatureObject {n}.returns {n}.sourceThis
        {n}.source_control {n}.source_heap {n}.source_kind {n}.source_signature {n}.signature_kind signatureFrame
        owned {n}.source_input fnRole thisRole note
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      refine ⟨_,source,right,post,retained,rfl,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source,policy,?_,?_⟩
      · have support := policy.source h.native.2
        rw [{n}.source_ffi]
        exact support
      · exact policy.target post.native.2")

end Host.Ts.Owned.Annotated.Driver
