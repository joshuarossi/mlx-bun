import host.ts.RenameRuntimeStaticCall
import Lean

set_option Elab.async false
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.Tests.StaticCall
open Host.Ts.Owned.Annotated

theorem universal_object_call_note
    {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {source target : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live source target)
    (callee receiver : Nat)
    (control : source.ctl = .call (.obj callee) (.obj receiver) []) :
    notes.control = callNote (.obj callee) (.obj receiver) [] :=
  inventory.object_call_note callee receiver control

open Lean Elab Command in
private def expectTypedMismatch (claim marker : String) : CommandElabM Unit := do
  let saved : Lean.Elab.Command.State ← get
  let previous := (← get).messages.toList.length
  let mut thrown := ""
  try
    let commandSyntax ← match Parser.runParserCategory (← getEnv) `command claim with
      | .ok commandSyntax => pure commandSyntax
      | .error message => throwError "static call claim did not parse: {message}"
    withScope (fun scope => {scope with opts := scope.opts.setBool `Elab.async false}) (elabCommand commandSyntax)
  catch exception =>
    thrown := (← exception.toMessageData.toString)
  let freshMessages := (← get).messages.toList.drop previous
  let mut fresh := ""
  for message in freshMessages do
    fresh := fresh ++ "\n" ++ (← message.data.toString)
  set saved
  let rendered := thrown ++ fresh
  if rendered == "" then throwError "static call claim was accepted: {claim}"
  if (rendered.splitOn "Unknown identifier").length > 1 || (rendered.splitOn "unknown identifier").length > 1 then
    throwError "static call rejection used an unknown identifier:\n{rendered}"
  unless (rendered.splitOn "type mismatch").length > 1 || (rendered.splitOn "Type mismatch").length > 1 do
    throwError "static call rejection was not a typed mismatch:\n{rendered}"
  unless (rendered.splitOn marker).length > 1 do
    throwError "static call rejection did not mention {marker}:\n{rendered}"

run_cmd do
  expectTypedMismatch "theorem swapped_object_call_note {S : Type} {notes : Host.Ts.Owned.Annotated.RuntimeNotes} {ν₀ ν : Nat → F64} {C₀ C : Host.Ts.CSrv} {R : Host.Ts.Ren} {live : Nat → Prop} {source target : Host.Ts.St S} (inventory : Host.Ts.Owned.Annotated.RuntimeInventory notes ν₀ ν C₀ C R live source target) (callee receiver : Nat) (control : source.ctl = .call (.obj callee) (.obj receiver) []) : notes.control = Host.Ts.Owned.Annotated.callNote (.obj receiver) (.obj callee) [] := inventory.object_call_note receiver callee control" "receiver"
  expectTypedMismatch "theorem nonempty_object_call_note {S : Type} {notes : Host.Ts.Owned.Annotated.RuntimeNotes} {ν₀ ν : Nat → F64} {C₀ C : Host.Ts.CSrv} {R : Host.Ts.Ren} {live : Nat → Prop} {source target : Host.Ts.St S} (inventory : Host.Ts.Owned.Annotated.RuntimeInventory notes ν₀ ν C₀ C R live source target) (callee receiver : Nat) (argument : Host.Ts.Val) (control : source.ctl = .call (.obj callee) (.obj receiver) [argument]) : notes.control = Host.Ts.Owned.Annotated.callNote (.obj callee) (.obj receiver) [] := inventory.object_call_note callee receiver control" "argument"

end Host.Ts.Owned.Annotated.Tests.StaticCall
