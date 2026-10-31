import host.sim.template.FullWorld
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Host.Ts Host.Mlx Host.Load

def inactiveFfi (p : FS) : FS :=
  ((⟨p.1.1.base, { p.1.1.bridge with active := false }⟩, p.1.2), p.2)

private theorem inactiveBridge_eq (b : FfiAne.St) (h : b.active = false) :
    { b with active := false } = b := by
  cases b
  cases h
  rfl

theorem inactiveFfi_eq (p : FS) (h : p.1.1.bridge.active = false) : inactiveFfi p = p := by
  obtain ⟨⟨⟨l, b⟩, fr⟩, kr⟩ := p
  change ((Ane.ASt.mk l { b with active := false }, fr), kr) = ((Ane.ASt.mk l b, fr), kr)
  rw [inactiveBridge_eq b h]

def inactiveState (s : St Host.Load.Layers.full.S) : St Host.Load.Layers.full.S :=
  s.setFfi (inactiveFfi s.ffi)

theorem inactiveState_eq (s : St Host.Load.Layers.full.S) (h : s.ffi.1.1.bridge.active = false) :
    inactiveState s = s := by
  unfold inactiveState
  rw [inactiveFfi_eq s.ffi h]
  cases s
  rfl

end Host.Ts.Sim.Template
