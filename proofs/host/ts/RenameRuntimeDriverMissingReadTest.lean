import host.ts.RenameRuntimeDriverMissingRead
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.MissingRead
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨(PTrie.nil.set 50 (.obj ⟨.ordinary,.obj 51,[],[],true⟩)).set 51
  (.obj ⟨.ordinary,.null,[],[],true⟩),100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def source : St Unit := (base.push (.e (.member (.str chars!"optionalInventory") false))).ret (.obj 50)
host_retained_missing_read ffi, source using server to base.ret .undef using server as Missing
def inherited : St Unit := base.setObj 51
  ⟨.ordinary,.null,[(.str chars!"optionalInventory",.data (.bool true) true true)],[],true⟩

open Lean Elab Command in
run_cmd do
  for command in [
      "host_retained_missing_read ffi, source using server to base.ret (.bool true) using server as WrongAbsentValue",
      "host_retained_missing_read ffi, (inherited.push (.e (.member (.str chars!\"optionalInventory\") false))).ret (.obj 50) using server to inherited.ret .undef using server as IgnoredPrototype"] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit command
    catch exception =>
      let message ← exception.toMessageData.toString
      rejected := (message.splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      let rendered ← message.data.toString
      if (rendered.splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "missing lookup accepted an incorrect result or ignored an inherited property"
end Host.Ts.Owned.Annotated.Tests.MissingRead
