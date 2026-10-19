import host.ts.RenameRetainedLiteralArrowFrontend
import host.ts.RenameRetainedChain
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.LiteralArrow
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def function : Obj := ⟨.fn (.closure (literalArrow none (.num ['1'])) [] true .undef),.null,[],[],true⟩
def input : St Unit := ⟨(.nil : PTrie HObj).set 1 (.obj function),100,.call (.obj 1) .undef [.big 17],[],⟨[],(),[],[]⟩⟩
def output : St Unit := input.ret (.num (.lit (F64.ofNat 1)))

host_retained_literal_arrow ffi, input using server to output using server as Constant

host_retained_theorem constant_return := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → Unit → Unit → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Unit)
    (inst : Inst ν₀ Constant.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Constant.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Constant.input s)
    (fnRole thisRole : Annotated.Value) (argRoles : List Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole argRoles)
    (targetBound : s.next+2 ≤ 2^64) => by
  host_retained_chain ffi, [Constant.retained_transport] using h, inventory, inst
host_assert_retained_schema constant_return, 5
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema constant_return, 6

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_literal_arrow ffi, input using server to input.ret (.num (.lit (F64.ofNat 2))) using server as WrongValue"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "incorrect literal-arrow result was not rejected by the kernel"
end Host.Ts.Owned.Annotated.Tests.LiteralArrow
