import host.ts.RenameRuntimeDriverObjects

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.ObjectDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[.var 0],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def object : Obj := ⟨.ordinary,.obj aObjectProto,[],[],true⟩
def initialAction : ObjectAction := .initial (.id chars!"first") chars!"first" (.id chars!"value") []
def spreadAction : ObjectAction := .spread (.id chars!"fields") []

def emptyEntry : St Unit := base.go (.ev (.object []) [])
def emptyOutput : St Unit := ObjectAction.done.advance (base.alloc (.obj object)).2 base.next []
def initialEntry : St Unit := base.go (.ev (.object initialAction.properties) [])
def initialOutput : St Unit := initialAction.advance (base.alloc (.obj object)).2 base.next []
def spreadEntry : St Unit := base.go (.ev (.object spreadAction.properties) [])
def spreadOutput : St Unit := spreadAction.advance (base.alloc (.obj object)).2 base.next []

host_retained_object ffi, emptyEntry using server to emptyOutput using server as Empty
host_retained_object ffi, initialEntry using server to initialOutput using server as Initial
host_retained_object ffi, spreadEntry using server to spreadOutput using server as Spread

def storedBase : St Unit := {base with heap := base.heap.set 50 (.obj object)}
def valueEntry (action : ObjectAction) : St Unit :=
  (storedBase.push (.l (.objVal 50 (.str chars!"current") action.properties []))).ret (.num (.ref 0))
def valueOutput (action : ObjectAction) : St Unit :=
  objectValueState storedBase 50 object chars!"current" (.num (.ref 0)) [] [] action

host_retained_object ffi, valueEntry .done using server to valueOutput .done using server as ValueDone
host_retained_object ffi, valueEntry initialAction using server to valueOutput initialAction using server as ValueInitial
host_retained_object ffi, valueEntry spreadAction using server to valueOutput spreadAction using server as ValueSpread

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Parametric.Driver.emit "host_retained_object ffi, valueEntry .done using server to base using server as WrongEndpoint"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong object endpoint was not rejected by the kernel"

end Host.Ts.Owned.Annotated.Tests.ObjectDriver
