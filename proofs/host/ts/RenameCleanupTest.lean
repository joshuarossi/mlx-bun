import host.ts.RenameRetainedCleanupFrontend

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.CleanupTest
open Parametric

theorem starts_normal (F : Ffi) (s : St F.S) :
    step F {s with ctl := .ret (.big 7),stack := .s (.scope [(.obj 11,.obj 12),(.obj 21,.obj 22)])::s.stack} =
      M.pure ((s.push (.s (.dispose [(.obj 21,.obj 22)] (.normal (.big 7))))).go (.call (.obj 12) (.obj 11) [])) :=
  step_scope_cleanup_eq F _ (.normal (.big 7)) _ _ _ _ rfl rfl

theorem starts_abrupt (F : Ffi) (s : St F.S) :
    step F {s with ctl := .abr (.throw (.obj 31)),stack := .s (.scope [(.obj 11,.obj 12)])::s.stack} =
      M.pure ((s.push (.s (.dispose [] (.abrupt (.throw (.obj 31)))))).go (.call (.obj 12) (.obj 11) [])) :=
  step_scope_cleanup_eq F _ (.abrupt (.throw (.obj 31))) _ _ _ _ rfl rfl

theorem next_resource (F : Ffi) (s : St F.S) (returned : Val) :
    step F {s with ctl := .ret returned,stack := .s (.dispose [(.obj 21,.obj 22)] (.abrupt (.ret (.obj 31))))::s.stack} =
      M.pure ((s.push (.s (.dispose [] (.abrupt (.ret (.obj 31)))))).go (.call (.obj 22) (.obj 21) [])) :=
  step_dispose_cleanup_eq F {s with ctl := .ret returned,stack := .s (.dispose [(.obj 21,.obj 22)] (.abrupt (.ret (.obj 31))))::s.stack} returned (.abrupt (.ret (.obj 31))) [(.obj 21,.obj 22)] s.stack rfl rfl

theorem resume_normal_discards_disposer_result (F : Ffi) (s : St F.S) (returned : Val) :
    step F {s with ctl := .ret returned,stack := .s (.dispose [] (.normal (.big 7)))::s.stack} = M.pure (s.ret (.big 7)) :=
  step_dispose_cleanup_eq F {s with ctl := .ret returned,stack := .s (.dispose [] (.normal (.big 7)))::s.stack} returned (.normal (.big 7)) [] s.stack rfl rfl

theorem resume_pending_return (F : Ffi) (s : St F.S) (returned : Val) :
    step F {s with ctl := .ret returned,stack := .s (.dispose [] (.abrupt (.ret (.obj 31))))::s.stack} =
      M.pure (s.go (.abr (.ret (.obj 31)))) :=
  step_dispose_cleanup_eq F {s with ctl := .ret returned,stack := .s (.dispose [] (.abrupt (.ret (.obj 31))))::s.stack} returned (.abrupt (.ret (.obj 31))) [] s.stack rfl rfl

theorem resume_pending_throw (F : Ffi) (s : St F.S) (returned : Val) :
    step F {s with ctl := .ret returned,stack := .s (.dispose [] (.abrupt (.throw (.obj 31))))::s.stack} =
      M.pure (s.go (.abr (.throw (.obj 31)))) :=
  step_dispose_cleanup_eq F {s with ctl := .ret returned,stack := .s (.dispose [] (.abrupt (.throw (.obj 31))))::s.stack} returned (.abrupt (.throw (.obj 31))) [] s.stack rfl rfl

theorem pair_notes_move_without_retagging (notes : RuntimeNotes) (resource method : Value) (rest : List Tree)
    (pending : Tree) (tail : List Tree) :
    notes.cleanup (.node "List" (.node "pair" [.value resource,.value method]::rest)) pending tail =
      {notes with control := .node "Ctl.call" [.value method,.value resource,.node "List" []],stack := cleanupDisposeNote (.node "List" rest) pending::tail} := rfl

theorem preserves_saved_normal_value (notes : RuntimeNotes) (role : Value) (tail : List Tree) :
    notes.cleanup (.node "List" []) (.node "Comp.normal" [.value role]) tail =
      {notes with control := returnNote role,stack := tail} := rfl

def noteTag : Tree → String
  | .node tag _ => tag
  | _ => ""

theorem note_tag_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {note : Tree} {value : Owned.Tree}
    (held : note.Holds ν C R value) : noteTag note = treeTag value := by cases held <;> rfl

theorem reject_completion_kind (ν : Nat → F64) (C : CSrv) (R : Ren) :
    ¬ (Tree.node "Comp.normal" [.value (.ordinaryBig 7)]).Holds ν C R (Encode.comp (.abrupt (.ret (.big 7)))) := by
  intro held
  have tags := note_tag_holds held
  exact (by decide : "Comp.normal" ≠ "Comp.abrupt") tags

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ←Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "theorem reject_disposer_return_overwrite (F : Ffi) (s : St F.S) : cleanupNext s [] (.normal (.big 7)) = s.ret (.big 99) := by host_kernel_rfl"
  finally Lean.setEnv saved
def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def scopeInput : St Unit := {base with ctl := .ret (.big 7),stack := [.s (.scope [(.obj 11,.obj 12),(.obj 21,.obj 22)])]}
def scopeOutput : St Unit := (base.push (.s (.dispose [(.obj 21,.obj 22)] (.normal (.big 7))))).go (.call (.obj 12) (.obj 11) [])
def nextInput : St Unit := (base.push (.s (.dispose [(.obj 21,.obj 22)] (.normal (.big 7))))).ret (.big 99)
def nextOutput : St Unit := (base.push (.s (.dispose [] (.normal (.big 7))))).go (.call (.obj 22) (.obj 21) [])
def finalInput : St Unit := (base.push (.s (.dispose [] (.normal (.big 7))))).ret (.big 99)
host_retained_cleanup ffi, scopeInput using server to scopeOutput using server as NormalScope
host_retained_cleanup ffi, nextInput using server to nextOutput using server as NextResource
host_retained_cleanup ffi, finalInput using server to base.ret (.big 7) using server as SavedNormal
end Host.Ts.Owned.Annotated.CleanupTest
