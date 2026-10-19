import host.ts.RenamePrivateListFrame
import host.ts.RenameKernelRfl

set_option Elab.async false
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned

def op : Name := ['o','p']
def call : Name := ['c','a','l','l']
def oldValue : PropV := .data .undef false false
def newValue : PropV := .data .null true false
def kept : PropV := .data (.bool true) false true
def duplicated : List ((Nat × Name) × PropV) :=
  [((7,op),oldValue),((7,op),kept),((9,call),kept),((9,call),oldValue)]

theorem different_names_keep_duplicate :
    findPriv 9 call (setPrivL 7 op newValue duplicated) = some kept := by host_kernel_rfl
theorem different_brands_keep_query :
    findPriv 7 call (setPrivL 9 op newValue duplicated) = findPriv 7 call duplicated := by host_kernel_rfl
theorem equal_brand_other_name :
    findPriv 7 op (setPrivL 7 call newValue duplicated) = some oldValue := by host_kernel_rfl
theorem same_name_overwrite :
    findPriv 7 op (setPrivL 7 op newValue duplicated) = some newValue := by host_kernel_rfl

open Lean Elab Command in
private def expectKernelRejection (claim marker : String) : CommandElabM Unit := do
  let saved : Lean.Elab.Command.State ← get
  let previous := (← get).messages.toList.length
  let mut thrown := ""
  try
    let commandSyntax ← match Parser.runParserCategory (← getEnv) `command claim with
      | .ok commandSyntax => pure commandSyntax
      | .error message => throwError "private-list claim did not parse: {message}"
    withScope (fun scope => {scope with opts := scope.opts.setBool `Elab.async false}) (elabCommand commandSyntax)
  catch exception =>
    thrown := (← exception.toMessageData.toString)
  let freshMessages := (← get).messages.toList.drop previous
  let mut fresh := ""
  for message in freshMessages do
    fresh := fresh ++ "\n" ++ (← message.data.toString)
  set saved
  let rendered := thrown ++ fresh
  if rendered == "" then throwError "private-list claim was accepted: {claim}"
  if (rendered.splitOn "Unknown identifier").length > 1 || (rendered.splitOn "unknown identifier").length > 1 then
    throwError "private-list rejection used an unknown identifier:\n{rendered}"
  unless (rendered.splitOn "(kernel) declaration type mismatch").length > 1 do
    throwError "private-list rejection was not a kernel diagnostic:\n{rendered}"
  unless (rendered.splitOn marker).length > 1 do
    throwError "private-list rejection did not mention {marker}:\n{rendered}"

run_cmd do
  expectKernelRejection "theorem same_name_not_preserved : Host.Ts.findPriv 7 Host.Ts.Owned.op (Host.Ts.setPrivL 7 Host.Ts.Owned.op Host.Ts.Owned.newValue Host.Ts.Owned.duplicated) = some Host.Ts.Owned.oldValue := by host_kernel_rfl" "oldValue"
  expectKernelRejection "theorem different_name_not_written : Host.Ts.findPriv 9 Host.Ts.Owned.call (Host.Ts.setPrivL 7 Host.Ts.Owned.op Host.Ts.Owned.newValue Host.Ts.Owned.duplicated) = some Host.Ts.Owned.newValue := by host_kernel_rfl" "newValue"

end Host.Ts.Owned
