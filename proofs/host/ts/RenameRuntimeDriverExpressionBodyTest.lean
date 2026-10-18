import host.ts.RenameRuntimeDriverExpressionBody
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.ExpressionBodyDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def body : Expr := .id chars!"argument"
def env : Env := [(chars!"argument",70)]
def fn : Func := .mk none [] none (.expr body) false false []
def input : St Unit := (base.push (.k (.params fn [] [] env))).ret .undef
def output : St Unit := (base.push (.s .ret)).go (.ev body env)
host_retained_expression_body ffi, input using server to output using server as Arrow

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_expression_body ffi, input using server to base.go (.ev body env) using server as MissingReturn"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "missing expression-body return frame was not rejected by the kernel"
end Host.Ts.Owned.Annotated.Tests.ExpressionBodyDriver
