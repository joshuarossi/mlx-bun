import host.ts.RenameRuntimeDriverObjectShorthand
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.ObjectShorthandDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[.var 0],[]⟩
def object : Obj := ⟨.ordinary,.obj aObjectProto,[],[],true⟩
def base : St Unit := ⟨(PTrie.nil.set 50 (.obj object)).set 70 (.cell (some (.num (.ref 0)))),
  100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def env : Env := [(chars!"next",70)]
def input : St Unit := (base.push (.l (.objVal 50 (.str chars!"first") [.short chars!"next"] env))).ret (natV 4)
def output : St Unit := objectShortState (objectFieldState base 50 object chars!"first" (natV 4) [])
  50 chars!"next" [] env (.num (.ref 0))

host_retained_object_short ffi, input using server to output using server as Lexical

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_object_short ffi, input using server to output.ret (natV 0) using server as WrongValue"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong shorthand value was not rejected by the kernel"
end Host.Ts.Owned.Annotated.Tests.ObjectShorthandDriver
