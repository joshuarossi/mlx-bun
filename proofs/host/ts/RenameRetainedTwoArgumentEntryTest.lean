import host.ts.RenameRetainedTwoArgumentEntryFrontend
import host.ts.RenameRetainedChain
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.Tests.TwoArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def body : List Stmt := [.decl .const [(.id chars!"slot",none)]]
def function : Obj := ⟨.fn (.closure (twoParameterFunction (some chars!"outArray") chars!"op" chars!"call" body) [] false .undef),
  .null,[],[],true⟩
def input : St Unit := ⟨(.nil : PTrie HObj).set 1 (.obj function),100,
  .call (.obj 1) (.obj 7) [.big 3,.big 4],[],⟨[],(),[],[]⟩⟩
def output : St Unit := twoArgumentEntry input (some chars!"outArray") chars!"op" chars!"call" body [] (.obj 7) (.big 3) (.big 4)

host_retained_two_argument_entry ffi, input using server to output using server as Pinned

theorem first_argument_cell : output.heap.get (input.next+1) = some (.cell (some (.big 3))) := by host_kernel_rfl
theorem second_argument_cell : output.heap.get (input.next+2) = some (.cell (some (.big 4))) := by host_kernel_rfl
theorem keeps_callers : output.stack = .s (.block body ((chars!"slot",input.next+3)::(chars!"call",input.next+2)::
    (chars!"op",input.next+1)::(nThis,input.next)::[]))::.s (.scope [])::.k (.fn .call)::input.stack := by host_kernel_rfl

open Host.Ts.Owned.Annotated
host_retained_theorem pinned := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → Unit → Unit → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Unit)
    (inst : Inst ν₀ Pinned.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Pinned.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Pinned.input s)
    (firstRole secondRole fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [firstRole,secondRole])
    (bound : s.next+4+(blockNames Pinned.sourceBody).length ≤ 2^64) => by
  host_retained_chain ffi, [Pinned.retained_transport] using h, inventory, inst
host_assert_retained_schema pinned, 6
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema pinned, 7

def swapped : St Unit := ⟨input.heap,input.next,.call (.obj 1) (.obj 7) [.big 4,.big 3],input.stack,input.aux⟩
def sameName : Obj := ⟨.fn (.closure (twoParameterFunction (some chars!"outArray") chars!"op" chars!"op" []) [] false .undef),
  .null,[],[],true⟩
def sameNameInput : St Unit := ⟨(.nil : PTrie HObj).set 1 (.obj sameName),100,
  .call (.obj 1) (.obj 7) [.big 3,.big 4],[],⟨[],(),[],[]⟩⟩
def mutated : Obj := ⟨.fn (.closure (twoParameterFunction (some chars!"outArray") chars!"op" chars!"call" []) [] false .undef),
  .null,[],[],true⟩
def mutatedInput : St Unit := ⟨(.nil : PTrie HObj).set 1 (.obj mutated),100,
  .call (.obj 1) (.obj 7) [.big 3,.big 4],[],⟨[],(),[],[]⟩⟩

open Lean Elab Command in
run_cmd do
  for claim in [
      "host_retained_two_argument_entry ffi, input using server to input using server as RejectEndpoint",
      "host_retained_two_argument_entry ffi, swapped using server to output using server as RejectSwappedArguments",
      "host_retained_two_argument_entry ffi, sameNameInput using server to output using server as RejectSameName",
      "host_retained_two_argument_entry ffi, mutatedInput using server to output using server as RejectMutatedBody",
      "theorem swapped_role : output.heap.get (input.next+1) = some (.cell (some (.big 4))) := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception => rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "two-argument negative was not rejected by the kernel: {claim}"

end Host.Ts.Owned.Annotated.Tests.TwoArgumentEntry
