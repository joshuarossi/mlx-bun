import host.ts.RenameRuntimeDriverPatterns

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.PatternDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def owner : Obj := ⟨.ordinary,.null,
  [(.str chars!"q",.data (.obj 101) true true),(.str chars!"k",.data (.obj 102) true true)],[],true⟩
def base : St Unit := ⟨PTrie.nil.set 100 (.obj owner),200,.ret .undef,[],⟨[],(),[],[]⟩⟩
def rest : List (Key × Pat) := [(.id chars!"k",.id chars!"k")]
def entry : St Unit := base.go (.bind (.object ((.id chars!"q",.id chars!"q")::rest) none) (.obj 100) [] .init .const)
def selected : St Unit := (base.push (.b (.objVal (.obj 100) (.str chars!"q") (.id chars!"q") rest none [.str chars!"q"] [] .init .const))).ret (.obj 101)
def binding : St Unit := (base.push (.b (.obj (.obj 100) rest none [.str chars!"q"] [] .init .const))).go (.bind (.id chars!"q") (.obj 101) [] .init .const)
def following : St Unit := (base.push (.b (.obj (.obj 100) rest none [.str chars!"q"] [] .init .const))).ret .undef
def second : St Unit := (base.push (.b (.objVal (.obj 100) (.str chars!"k") (.id chars!"k") [] none [.str chars!"k",.str chars!"q"] [] .init .const))).ret (.obj 102)
def complete : St Unit := (base.push (.b (.obj (.obj 100) [] none [.str chars!"k",.str chars!"q"] [] .init .const))).ret .undef

host_retained_pattern ffi, entry using server to selected using server as ObjectEntry
host_retained_pattern ffi, selected using server to binding using server as ObjectValue
host_retained_pattern ffi, following using server to second using server as ObjectNext
host_retained_pattern ffi, complete using server to base using server as ObjectDone

def present : St Unit := base.go (.bind (.dflt (.id chars!"x") (.id chars!"fallback")) (.obj 101) [] .init .const)
def presentOut : St Unit := base.go (.bind (.id chars!"x") (.obj 101) [] .init .const)
def missing : St Unit := base.go (.bind (.dflt (.id chars!"x") (.id chars!"fallback")) .undef [] .init .const)
def missingOut : St Unit := (base.push (.b (.dflt (.id chars!"x") [] .init .const))).go (.ev (.id chars!"fallback") [])
def returned : St Unit := (base.push (.b (.dflt (.id chars!"x") [] .init .const))).ret (.obj 101)

host_retained_pattern ffi, present using server to presentOut using server as DefaultPresent
host_retained_pattern ffi, missing using server to missingOut using server as DefaultMissing
host_retained_pattern ffi, returned using server to presentOut using server as DefaultReturn

/- The source endpoint is a checked obligation even for a command that only
selects metadata. Remove the deliberately rejected partial declarations. -/
open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Parametric.Driver.emit "host_retained_pattern ffi, entry using server to base using server as WrongEndpoint"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong pattern endpoint was not rejected by the kernel"

end Host.Ts.Owned.Annotated.Tests.PatternDriver
