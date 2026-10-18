import host.ts.RenameRuntimeDriverUpdate
import host.ts.RenameRetainedChain
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.UpdateDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def env : Env := [(chars!"index",70)]
def base : St Unit := ⟨PTrie.nil.set 70 (.cell (some (natV 0))),100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def input : St Unit := base.go (.ev (.update true false (.id chars!"index")) env)
def readOut : St Unit := (base.push (.a (.updOld true false (.var chars!"index" env)))).ret (natV 0)
def storeOut : St Unit := fixedPostincrement base 70 (F64.ofNat 0) (F64.ofNat 1) []
def output : St Unit := (base.setCell 70 (natV 1)).ret (natV 0)
host_retained_update ffi, input using server to readOut using server as Read
host_retained_update ffi, readOut using server to storeOut using server as Store
host_retained_update ffi, storeOut using server to output using server as Old

theorem postfix_retains_old (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → Unit → Unit → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St Unit) (inst : Inst ν₀ (numberServer server) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    (entry : notes.runtime.cells.cells 70 = some (.literal (.lit (F64.ofNat 0))))
    (budget : s.next+1 ≤ 2^64) :
    ∃ result, runC ffi 3 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' output result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.literal (.lit (F64.ofNat 0))),notes.runtime.stack,
        notes.runtime.cells.write 70 (.literal (.bin .add (.lit (F64.ofNat 0)) (.lit (.fin false 1 0))))⟩)
        ν₀ ν C₀ C R live output result ∧ Inst ν₀ (numberServer server) C₀ := by
  host_retained_chain ffi, [Read.retained_transport,Store.retained_transport,Old.retained_transport] using h, inventory, inst

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_update ffi, storeOut using server to output.ret (natV 1) using server as WrongPostfixValue"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "postfix returned its new value without kernel rejection"
end Host.Ts.Owned.Annotated.Tests.UpdateDriver
