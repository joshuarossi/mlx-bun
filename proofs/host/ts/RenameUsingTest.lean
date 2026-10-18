import host.ts.RenameRetainedUsingFrontend

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.UsingTest
open Parametric

def frames : List Frame :=
  [.s (.block [] []),.s (.scope [(.obj 11,.obj 12)]),.s (.scope [(.obj 21,.obj 22)])]

theorem nearest_scope : ScopeAt frames 1 := by decide +kernel

theorem nearest_scope_lifo : addUsing (.obj 31,.obj 32) frames = some
    [.s (.block [] []),.s (.scope [(.obj 31,.obj 32),(.obj 11,.obj 12)]),.s (.scope [(.obj 21,.obj 22)])] := rfl

theorem outer_scope_rejected : ¬ ScopeAt frames 2 := by decide +kernel

theorem fresh_symbol_disjoint (R : Ren) (allocated : Nat) :
    keyEq (.sym symDispose) (R.key (.sym (allocated+16))) = false := by
  rw [keyEq_wellKnown_symbol_map R symDispose (by decide +kernel)]
  change Nat.beq 5 (2*(allocated+16)+1) = false
  cases eq : Nat.beq 5 (2*(allocated+16)+1) with
  | false => rfl
  | true => have := Nat.eq_of_beq_eq_true eq; omega

theorem retains_unrelated_notes (resource method : Value) (head : Tree) (tail : List Tree) (prior : List Tree) :
    registerUsingNotes resource method 1
      (head::.node "Frame.s" [.node "StmtF.scope" [.node "List" prior]]::tail) =
      head::.node "Frame.s" [.node "StmtF.scope" [.node "List" (.node "pair" [.value resource,.value method]::prior)]]::tail := rfl

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ←Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "theorem reject_dispose_key_relabel (R : Host.Ts.Ren) : R.sym Host.Ts.symDispose = Host.Ts.symDispose+1 := by host_kernel_rfl"
  finally Lean.setEnv saved
end Host.Ts.Owned.Annotated.UsingTest
