import host.ts.RenameRuntimeDriverArrays

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.ArrayDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[.var 0],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def entry : St Unit := base.go (.ev (.array [.expr (.id chars!"x"),.expr (.id chars!"y")]) [])
def entryOut : St Unit := arrayElement base [] (.id chars!"x") [.expr (.id chars!"y")] []
def following : St Unit := (base.push (.l (.array [] [.expr (.id chars!"y")] []))).ret (natV 1)
def followingOut : St Unit := arrayElement base [natV 1] (.id chars!"y") [] []
def final : St Unit := (base.push (.l (.array [natV 1] [] []))).ret (.num (.ref 0))
def finalOut : St Unit := (base.alloc (valueArray [natV 1,.num (.ref 0)])).2.ret (.obj base.next)
def empty : St Unit := base.go (.ev (.array []) [])
def emptyOut : St Unit := (base.alloc (valueArray [])).2.ret (.obj base.next)

host_retained_array ffi, entry using server to entryOut using server as Entry
host_retained_array ffi, following using server to followingOut using server as Next
host_retained_array ffi, final using server to finalOut using server as Final
host_retained_array ffi, empty using server to emptyOut using server as Empty

def spreadBase : St Unit := {base with heap := base.heap.set 50 (.obj ⟨.array [.num (.ref 0),natV 2],.obj aArrayProto,[],[],true⟩)}
def spread : St Unit := (spreadBase.push (.c (.spread 0 (.obj 80) .undef [natV 9] [] []))).ret (.obj 50)
def spreadOut : St Unit := spreadBase.go (.call (.obj 80) .undef [natV 9,.num (.ref 0),natV 2])

host_retained_array ffi, spread using server to spreadOut using server as Spread

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Parametric.Driver.emit "host_retained_array ffi, final using server to base using server as WrongEndpoint"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong array endpoint was not rejected by the kernel"

end Host.Ts.Owned.Annotated.Tests.ArrayDriver
