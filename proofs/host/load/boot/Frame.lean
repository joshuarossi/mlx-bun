import host.load.boot.States
import host.load.run.prompt.Frame
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Layers Host.Load.Boot

/-! # `loadDone` in the full world

The boot's state at `loadDone` in the full world (`ldSt fw`): the load world's state `P.a2818 fw`
with the full world's native state `ldFull fw`, the load world's state with the bridge of the boot's
program creates (`replay P.oblog2818`, inactive), the handles the boot's object frees released
(`P.obfr2818`) and the kernel record of the boot's kernels (`P.obkr2818`); no layer rejected a call
(`loadDone_accepted`). The native state does not depend on the prompt (`ldFull_eq`), and the states
for two prompts differ only in the array at 2665 (`ld_frame`), so `rel_loadDone_full` frames every
prompt's state by the empty prompt's, for any native relation of the full world. -/

/-- The full world's native state at `loadDone`. -/
noncomputable def ldFull (fw : List Val) : full.S := toFull ((P.a2818 fw).ffi, P.ob2818)

/-- The full world's state at `loadDone`. -/
noncomputable def ldSt (fw : List Val) : St full.S := (P.a2818 fw).reFfi (ldFull fw)

theorem loadDone_layers (fw : List Val) :
    ldFull fw = ((⟨(P.a2818 fw).ffi, replay P.oblog2818⟩, some P.obfr2818), some P.obkr2818) := rfl

theorem loadDone_bridge (fw : List Val) : (ldFull fw).1.1.bridge.active = false := replay_active _

/-- **Accepted at `loadDone`**: no layer rejected a call of the boot. -/
theorem loadDone_accepted (fw : List Val) : accepted (ldFull fw) = true := rfl

theorem ldFull_eq (fw : List Val) : ldFull fw = ldFull [] := by
  unfold ldFull
  rw [show (P.a2818 fw).ffi = (P.a2818 []).ffi by rw [frame fw]; rfl]

theorem ld_frame (fw : List Val) : ldSt fw = (ldSt []).setObj 2665 (promptObj fw) := by
  unfold ldSt
  rw [ldFull_eq fw, frame fw]
  rfl

/-- **The relation at `loadDone` in the full world**: under the identity map, with the prompt array
framed (template prefix `[]`, target prefix `fw`), the empty prompt's full-world state is related to
the state for `fw`, given the empty prompt's closedness, native relation and server facts (for the
full world's native relation `Full.FullR`: `FR := FullR P NB`). -/
theorem rel_loadDone_full {FR : Map → Nat → full.S → full.S → Prop} {ν : Nat → F64} {S : SSrv} {C : CSrv}
    (lo hi : Nat) (fw : List Val) (h : FrameRel.Hyps full FR ν S C lo hi (ldSt [])) :
    Rel full FR Map.id ν (FrameRel.ctx (ldSt []) 2665 fw lo hi) (ldSt []) S (ldSt fw) C := by
  rw [ld_frame fw]
  exact FrameRel.relF_frame h (prompt_obj []) rfl (by decide)

end Host.Load.Run.Prompt
