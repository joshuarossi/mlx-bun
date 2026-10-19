import host.ts.RenameCompiledArgumentEntryChainStep
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.ChainNegative
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def ffi : Ffi := ⟨Unit, fun _ _ _ => .fail "unused", fun _ _ _ _ => none, fun _ => 4096, fun _ _ => .pure none⟩
def server : SSrv := ⟨[], []⟩
def base : St Unit := ⟨.nil, 100, .ret .undef, [], ⟨[], (), [], []⟩⟩
def chainInput : St Unit := (base.push (.e .chain)).ret (.bool true)
def chainOutput : St Unit := ({chainInput with stack := []}).ret (.bool true)

host_compiled_argument_chain_step ffi, chainInput using server to chainOutput using server as Chain

/-- error: host_compiled_argument_chain_step: expected Ctl.ret into ExprF.chain -/
#guard_msgs in
host_compiled_argument_chain_step ffi, base using server to chainOutput using server as WrongFrame

/-- error: host_compiled_argument_chain_step: expected Ctl.ret into ExprF.chain -/
#guard_msgs in
host_compiled_argument_chain_step ffi, (base.push (.e .typeof)).ret .undef using server to chainOutput using server as WrongExpression

open Lean Elab Command in
run_cmd do
  let saved : Command.State ← get
  let count := saved.messages.toList.length
  let mut rendered := ""
  try
    Parametric.Driver.emit "host_compiled_argument_chain_step ffi, chainInput using server to (base.ret (.bool false)) using server as WrongEndpoint"
  catch exception =>
    rendered := rendered ++ (← exception.toMessageData.toString)
  for message in (← get).messages.toList.drop count do
    rendered := rendered ++ "\n" ++ (← message.data.toString)
  if (← getEnv).contains ((← getCurrNamespace) ++ `WrongEndpoint.input) then
    throwError "wrong endpoint left a partial declaration"
  set saved
  unless (rendered.splitOn "(kernel) declaration type mismatch").length > 1 do
    throwError s!"wrong chain endpoint was not a kernel declaration type mismatch:\n{rendered.take 1500}"

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.ChainNegative
