import host.load.RuntimeDefaultIdentifierParameterCuts
import host.ts.ast.mlx.Ops
import host.ts.RenameRetainedDefaultIdentifierParameter

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def pinnedFunction : Func := Sources.Mlx.Ops.ast_n360
def parameterName : Name := chars!"s"
def defaultName : Name := chars!"gpuStream"
noncomputable def sourceRemainingParams : List Pat :=
  match From1371.s9.stack with
  | .k (.params _ (.dflt _ _::remaining) _ _)::_ => remaining
  | _ => []
noncomputable def sourceArgs : List Val :=
  match From1371.s9.stack with
  | .k (.params _ _ args _)::_ => args
  | _ => []
noncomputable def sourceEnv : Env :=
  match From1371.s9.stack with
  | .k (.params _ _ _ env)::_ => env
  | _ => []
noncomputable def sourceCallerFrames : List Frame :=
  match From1371.s9.stack with
  | .k (.params _ _ _ _)::frames => frames
  | _ => []
noncomputable def parameterAddress : Nat :=
  match lookupEnv parameterName sourceEnv with
  | some address => address
  | none => 0
noncomputable def defaultAddress : Nat :=
  match lookupEnv defaultName sourceEnv with
  | some address => address
  | none => 0
noncomputable def sourceDefaultValue : Val :=
  match From1371.s9.heap.get defaultAddress with
  | some (.cell (some value)) => value
  | _ => .undef

theorem source_control : From1371.s9.ctl = .ret .undef := by host_kernel_rfl
theorem source_stack : From1371.s9.stack =
    .k (.params pinnedFunction
      (.dflt (.id parameterName) (.id defaultName)::sourceRemainingParams) sourceArgs sourceEnv)::sourceCallerFrames := by
  host_kernel_rfl
theorem source_parameter_lookup : lookupEnv parameterName sourceEnv = some parameterAddress := by
  host_kernel_rfl
theorem source_parameter_cell : From1371.s9.heap.get parameterAddress = some (.cell none) := by
  host_kernel_rfl
theorem source_default_lookup : lookupEnv defaultName sourceEnv = some defaultAddress := by
  host_kernel_rfl
theorem source_default_cell : From1371.s9.heap.get defaultAddress =
    some (.cell (some sourceDefaultValue)) := by host_kernel_rfl
theorem source_missing_argument : nthD .undef sourceArgs 0 = .undef := by host_kernel_rfl
theorem source_parameter_bound : parameterAddress < From1371.s9.next := by decide +kernel
theorem source_bound : From1371.s9.next ≤ 2^64 := by decide +kernel
theorem source_servers :
    numberServer (From1371.S9.substitute LoopVariables.oracleVariables) =
      numberServer (From1375.S4.substitute LoopVariables.oracleVariables) := by host_kernel_rfl
theorem source_endpoint : defaultIdentifierParameterReached From1371.s9 parameterAddress
    sourceDefaultValue pinnedFunction sourceRemainingParams sourceArgs sourceEnv sourceCallerFrames = From1375.s4 := by
  host_kernel_rfl

/-- The pinned source fixture instantiates the generic four-transition block
at source 1371 and reaches the generated source state at 1375. -/
theorem retained_entry (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (target : St P.F.S)
    (inst : Inst ν₀ (numberServer (From1371.S9.substitute LoopVariables.oracleVariables)) C₀)
    (related : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      From1371.s9 target)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live From1371.s9 target)
    (roles : List Value) (tailNotes : List Tree) (defaultRole : Value)
    (stackNotes : notes.runtime.stack = parameterFrameNote pinnedFunction
      (.dflt (.id parameterName) (.id defaultName)::sourceRemainingParams) roles sourceEnv::tailNotes)
    (defaultEntry : notes.runtime.cells.cells defaultAddress = some defaultRole)
    (targetBound : target.next ≤ 2^64) :
    ∃ (result : St P.F.S),
      runC P.F 4 target C = some (result,C) ∧
      runC P.F 4 From1371.s9 C₀ = some (From1375.s4,C₀) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' From1375.s4 result ∧
      RetainedInventory (defaultIdentifierParameterNotes notes pinnedFunction sourceRemainingParams
        roles sourceEnv tailNotes parameterAddress defaultRole) ν₀ ν C₀ C R live From1375.s4 result ∧
      Inst ν₀ (numberServer (From1375.S4.substitute LoopVariables.oracleVariables)) C₀ ∧
      (∃ (targetDefaultValue targetValue : Val), defaultRole.Holds ν C R targetDefaultValue ∧
        targetValue = targetDefaultValue ∧
        From1375.s4.heap.get parameterAddress = some (.cell (some sourceDefaultValue)) ∧
        result.heap.get (R.a parameterAddress) = some (.cell (some targetValue)) ∧
        result.ffi = target.ffi ∧ result.next = target.next ∧
        (∀ address, address ≠ R.a parameterAddress → result.heap.get address = target.heap.get address)) := by
  obtain ⟨targetDefaultValue,targetValue,result,targetRun,sourceRun,post,retained,role,valueEq,
      sourceCell,targetCell,ffi,next,heap⟩ := inventory.default_identifier_parameter_block
    related .undef pinnedFunction parameterName defaultName sourceRemainingParams sourceArgs sourceEnv
    sourceCallerFrames roles tailNotes parameterAddress defaultAddress sourceDefaultValue defaultRole
    source_control source_stack source_missing_argument source_parameter_lookup source_parameter_cell
    source_default_lookup source_default_cell defaultEntry source_parameter_bound source_bound targetBound
    stackNotes
  rw [source_endpoint] at sourceRun post retained sourceCell
  exact ⟨result,targetRun,sourceRun,post,retained,source_servers ▸ inst,
    ⟨targetDefaultValue,targetValue,role,valueEq,sourceCell,targetCell,ffi,next,heap⟩⟩

host_assert_retained_schema retained_entry, 4

end Host.Load.Run.Full.Ordinary.NamespacedDecode
