import host.load.boot.States
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Load Host.Load.Layers Host.Load.Boot

/-! # The full world's boot start and `loadDone` states

`bootStartF s`: a booted load-world state with the layers' initial states (`Layers.start`, the empty
bridge; `Route.bootStart`). `ldStT fw tail`: the full world's state at `loadDone` for the prompt `fw`
and the unread readback suffix `tail` (the load world's state `P.at2818 fw tail` with the bridge of the
boot's creates and the observers' states of the boot's calls, `P.ob2818`). -/

/-- The full world's start of a booted state: the layers' initial states. -/
def bootStartF (s : St LSt) : St full.S := s.reFfi (start ⟨s.ffi, Host.Mlx.FfiAne.St.empty⟩)

/-- The full world's state at `loadDone` for prompt `fw` and unread readback suffix `tail`. -/
noncomputable def ldStT (fw : List Val) (tail : List NumV) : St full.S :=
  (P.at2818 fw tail).reFfi (toFull ((P.at2818 fw tail).ffi, P.ob2818))


/-- The layers' states at `loadDone`: the bridge of the boot's creates, the handles its object frees released,
its kernels' record. -/
theorem ldStT_layers (fw : List Val) (tail : List NumV) :
    (ldStT fw tail).ffi = ((⟨(P.at2818 fw tail).ffi, replay P.oblog2818⟩, some P.obfr2818), some P.obkr2818) := rfl

/-- **Accepted at `loadDone`**: no layer rejected a call of the boot. -/
theorem ldStT_accepted (fw : List Val) (tail : List NumV) : accepted (ldStT fw tail).ffi = true := rfl

/-- The bridge at `loadDone` is inactive. -/
theorem ldStT_bridge (fw : List Val) (tail : List NumV) : (ldStT fw tail).ffi.1.1.bridge.active = false :=
  replay_active _

end Host.Load.Run.Prompt
