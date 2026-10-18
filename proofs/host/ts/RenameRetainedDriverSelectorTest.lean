import host.ts.RenameRetainedDriverStep
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.Selector
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
/- A zero-payload return frame must be classified before any scope payload is read. -/
host_retained_step ffi, (base.push (.s .ret)).ret .undef using server
  to base.go (.abr (.ret .undef)) using server as Return

/- Ordinary assignment has no logical-assignment payload. It remains a
rejected unsupported expression without an out-of-bounds selector read. -/
open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  let mut invalidRead := false
  try Parametric.Driver.emit "host_retained_step ffi, base.ev (.assign .assign (.id ['x']) (.lit .undef)) [] using server to base using server as Assignment"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := true
    invalidRead := (message.splitOn "index out of bounds").length > 1 ||
      (message.splitOn "PANIC").length > 1
  for message in (← get).messages.toList do
    let text ← message.data.toString
    if message.severity == .error then rejected := true
    if (text.splitOn "index out of bounds").length > 1 || (text.splitOn "PANIC").length > 1 then
      invalidRead := true
  set saved
  unless rejected do throwError "ordinary assignment fixture unexpectedly accepted"
  if invalidRead then throwError "selector read a nonexistent constructor payload"
end Host.Ts.Owned.Annotated.Tests.Selector
