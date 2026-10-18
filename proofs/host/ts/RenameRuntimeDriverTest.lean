import host.ts.RenameRuntimeDriver
import host.ts.RenameKernelRflTest
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.RuntimeDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def input : St Unit := ⟨.nil,0,.ret (.num (.ref 1)),[.e (.binR .mul (.num (.ref 0)))],⟨[],(),[],[]⟩⟩
def initial : SSrv := ⟨[.var 0,.var 1],[]⟩
def output : St Unit := {input with ctl := .ret (.num (.ref 2)),stack := []}
def next : SSrv := ⟨[.var 0,.var 1,.bin .mul (.var 0) (.var 1)],[]⟩

host_runtime_arithmetic ffi, input using initial to output using next as Reference

def ν : Nat → F64 | 0 => F64.ofNat 3 | _ => F64.ofNat 4
def C₀ : CSrv := ⟨[F64.ofNat 3,F64.ofNat 4]⟩
def C : CSrv := ⟨[]⟩
def target : St Unit := {input with ctl := .ret (natV 4),stack := [.e (.binR .mul (natV 3))]}
def targetOutput : St Unit := {target with ctl := .ret (natV 12),stack := []}
def notes : RuntimeNotes := ⟨returnNote (.num (.var 1)),[binaryRightNote .mul (.num (.var 0))],Notes.empty⟩

theorem source_inst : Inst ν initial C₀ := ⟨rfl,by intro q entry; cases entry⟩

theorem related : Parametric.StateR (NumberRoles ν ν C₀ C) (fun _ _ _ => True) identity
    (fun _ => False) (fun _ => False) [] [] [] [] input target := by
  constructor
  · constructor
    · intro a impossible; exact False.elim impossible
    · intro a impossible; exact False.elim impossible
    · intro a impossible; exact False.elim impossible
    · intro a impossible; exact False.elim impossible
    · intro a b impossible; exact False.elim impossible
    · intro k; rfl
  · exact .node _ (.cons (.value (.num ⟨.var 1,⟨rfl,rfl⟩⟩)) .nil)
  · exact ⟨True.intro,True.intro⟩
  · exact .cons (.node _ (.cons (.node _ (.cons (.atom BinOp .mul)
      (.cons (.value (.num ⟨.var 0,⟨rfl,rfl⟩⟩)) .nil))) .nil)) .nil
  · exact ⟨⟨⟨True.intro,True.intro,True.intro⟩,True.intro⟩,True.intro⟩
  · exact .nil
  · exact True.intro
  · exact .node _ .nil
  · exact True.intro
  · exact True.intro
  · exact ⟨[],[],rfl,rfl,.nil⟩

theorem annotated : RuntimeInventory notes ν ν C₀ C identity (fun _ => False) input target := by
  refine ⟨(by intro a role entry; cases entry),?_,?_⟩
  · exact ⟨returnNote_holds (.num _ _ rfl),.cons (binaryRightNote_holds .mul (.num _ _ rfl)) .nil,
      by intro a role entry; cases entry⟩
  · exact ⟨returnNote_holds (.num _ _ rfl),.cons (binaryRightNote_holds .mul (.num _ _ rfl)) .nil,
      by intro a role entry; cases entry⟩

theorem target_step : interpC (step ffi target).run C = some (targetOutput,C) := by host_kernel_rfl

/-- The generated source cut allocates ref 2, while the related target folds
both literals and allocates no numeric reference. -/
theorem reference_to_literal :
    ∃ D₀, interpC (step ffi input).run C₀ = some (output,D₀) ∧
      interpC (step ffi target).run C = some (targetOutput,C) ∧
      Parametric.StateR (NumberRoles ν ν D₀ C) (fun _ _ _ => True) identity
        (fun _ => False) (fun _ => False) [] [] [] [] output targetOutput ∧ D₀.tab.length = 3 := by
  obtain ⟨result,D₀,D,sourceRun,targetRun,inst,post,_,_,_⟩ := Reference.runtime_transport notes ν ν C₀ C identity
    (fun _ _ _ => True) (fun _ => False) (fun _ => False) [] [] [] [] target source_inst related annotated
    (.var 0) (.var 1) (.num (.var 0)) (.num (.var 1)) (.number _) (.number _) [] rfl rfl
  have same := Option.some.inj (targetRun.symm.trans target_step)
  obtain ⟨rfl,rfl⟩ := Prod.mk.inj same
  exact ⟨D₀,sourceRun,target_step,post,by rw [inst.1]; rfl⟩

/- A wrong next numeric table is rejected synchronously by the kernel. The
failed command's partial declarations are removed from the environment. -/
open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Parametric.Driver.emit "host_runtime_arithmetic ffi, input using initial to output using initial as WrongTable"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong source numeric table was not rejected by the kernel"

/-- error: host_runtime_arithmetic: expected numeric return control -/
#guard_msgs in
host_runtime_arithmetic ffi, {input with ctl := .halt (.normal .undef)} using initial to output using next as Unsupported

end Host.Ts.Owned.Annotated.Tests.RuntimeDriver
