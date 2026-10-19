import host.load.RuntimeNamespacedDecodeCuts1175
import host.ts.RenameRetainedNdim
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NdimEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open NamespacedDecode

def expression : Expr :=
  (Expr.id chars!"Number").call
    [.expr (((Expr.id chars!"C").member chars!"mlx_array_ndim" false).call
      [.expr (Expr.this.member chars!"handle" false)] false)] false

noncomputable def functionObject : Obj := (From1175.s12.obj? 4865).get (by host_kernel_rfl)
noncomputable def environment : Env :=
  match functionObject.kind with | .fn (.closure _ env _ _) => env | _ => []
noncomputable def home : Val :=
  match functionObject.kind with | .fn (.closure _ _ _ value) => value | _ => .undef
def function : Func := singleReturnFunction none expression
noncomputable def reachedLive (live : Nat → Prop) :=
  CellsLive (ClosureLive live From1175.s12.next false home function)
    (closureState From1175.s12 function environment false home (.obj 3126785) [] .call).next []
noncomputable def reachedNotes (notes : RetainedNotes) :=
  notes.withRuntime (singleReturnEntryRuntime notes.runtime function
    (closureEnvironment From1175.s12 function environment false home (.obj 3126785))
    From1175.s12.next 3126785 expression)

theorem source_function : function = Sources.Mlx.Array.ast_n61 := rfl
theorem source_control : From1175.s12.ctl = .call (.obj 4865) (.obj 3126785) [] := by host_kernel_rfl
theorem source_read : From1175.s12.heap.get 4865 = some (.obj functionObject) := by host_kernel_rfl
theorem source_kind : functionObject.kind = .fn (.closure function environment false home) := by host_kernel_rfl
theorem source_endpoint :
    singleReturnEntryState From1175.s12 none environment home 3126785 expression = From1175.s16 := by host_kernel_rfl
theorem source_bound : From1175.s12.next+2 ≤ 2^64 := by decide +kernel
theorem source_servers :
    numberServer (From1175.S12.substitute LoopVariables.oracleVariables) =
      numberServer (From1175.S16.substitute LoopVariables.oracleVariables) := by host_kernel_rfl

/-- Instantiate the generic entry with kernel-derived source data. The actual
source run and reached state are conclusions, never caller-supplied premises. -/
theorem retained_entry (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer (From1175.S12.substitute LoopVariables.oracleVariables)) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' From1175.s12 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live From1175.s12 s)
    (controlNote : notes.runtime.control = callNote (.obj 4865) (.obj 3126785) [])
    (targetBound : s.next+2 ≤ 2^64) :
    ∃ result, runC P.F 4 s C = some (result,C) ∧
      runC P.F 4 From1175.s12 C₀ = some (From1175.s16,C₀) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (reachedLive live) framed before after old old' From1175.s16 result ∧
      RetainedInventory (reachedNotes notes) ν₀ ν C₀ C R (reachedLive live) From1175.s16 result ∧
      Inst ν₀ (numberServer (From1175.S16.substitute LoopVariables.oracleVariables)) C₀ := by
  obtain ⟨result,left,right,post,retained,_,_,_⟩ := inventory.single_return_entry_block h
    4865 3126785 functionObject none environment home expression
    source_control source_read source_kind controlNote source_bound targetBound
  rw [source_endpoint] at left post retained
  exact ⟨result,right,left,post,retained,source_servers ▸ inst⟩

host_assert_retained_schema retained_entry, 4

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_entry, 5

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem wrong_source_endpoint : singleReturnEntryState From1175.s12 none environment home 3126785 expression = From1175.s15 := by host_kernel_rfl",
      "theorem wrong_source_body : functionObject.kind = .fn (.closure (singleReturnFunction none (.priv .this chars!\"handle\" false)) environment false home) := by host_kernel_rfl",
      "theorem wrong_source_receiver : From1175.s12.ctl = .call (.obj 4865) (.obj 3131993) [] := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception => rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect ndim source claim was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.NdimEntry
