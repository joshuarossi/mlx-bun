import host.mlx.NativeNumberReturn
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select the six original transitions from the current integer result to
its Number conversion and saved caller. Only current source metadata is read. -/
elab "host_retained_number_return " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let integer ← field (← field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0) ``Val.big 1 0
    let stack ← whnf (← mkAppM ``St.stack #[s])
    let frame ← field (← field stack ``List.cons 3 1) ``Frame.c 1 0
    let fn ← field (← field frame ``CallF.args 6 1) ``Val.obj 1 0
    let receiver ← field frame ``CallF.args 6 2
    let argEnv ← field frame ``CallF.args 6 5
    let rest ← field stack ``List.cons 3 2
    let rest ← field rest ``List.cons 3 2
    let bodyFrame ← field (← field rest ``List.cons 3 1) ``Frame.s 1 0
    let bodyEnv ← field bodyFrame ``StmtF.block 2 1
    let mut caller ← field rest ``List.cons 3 2
    caller ← field caller ``List.cons 3 2
    caller ← field caller ``List.cons 3 2
    let function ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let code ← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0
    let data ← field code ``Code.native 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceInteger",integer),
        ("sourceFn",fn),("sourceReceiver",receiver),("sourceArgEnv",argEnv),("sourceBodyEnv",bodyEnv),
        ("sourceCaller",caller),("sourceFunction",function),("sourceData",data)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 6)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.big {n}.sourceInteger)"
  fact "source_stack" s!"{n}.input.stack = .c (.args 0 (.obj {n}.sourceFn) {n}.sourceReceiver [] [] {n}.sourceArgEnv) :: .s .ret :: .s (.block [] {n}.sourceBodyEnv) :: .s (.scope []) :: .k (.fn .call) :: {n}.sourceCaller"
  fact "source_read" s!"{n}.input.heap.get {n}.sourceFn = some (.obj {n}.sourceFunction)"
  fact "source_kind" s!"{n}.sourceFunction.kind = .fn (.native (.num .number) {n}.sourceData)"
  fact "source_output" ("{" ++ s!"{n}.input with ctl := .ret (intV {n}.sourceInteger),stack := {n}.sourceCaller" ++ "} = " ++ n ++ ".output")
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 6 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (meaning : SymE) (role fnRole thisRole : Annotated.Value)
      (schema : IntegerNumberRole role meaning)
      (retNote blockNote scopeNote boundaryNote : Annotated.Tree) (callerNotes : List Annotated.Tree)
      (controlNote : notes.runtime.control = returnNote role)
      (stackNotes : notes.runtime.stack = argumentFrameNote false 0 fnRole thisRole [] [] {n}.sourceArgEnv ::
        retNote::blockNote::scopeNote::boundaryNote::callerNotes) :
      ∃ result, runC {n}.F 6 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 6 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote (.literal meaning),callerNotes,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained,_,_,_⟩ := inventory.integer_number_return_block h
        {n}.sourceFn {n}.sourceFunction {n}.sourceData {n}.sourceReceiver {n}.sourceInteger
        meaning role fnRole thisRole schema {n}.sourceArgEnv {n}.sourceBodyEnv {n}.sourceCaller
        retNote blockNote scopeNote boundaryNote callerNotes {n}.source_control {n}.source_stack
        {n}.source_read {n}.source_kind controlNote stackNotes
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")
end Host.Ts.Owned.Annotated.Driver
