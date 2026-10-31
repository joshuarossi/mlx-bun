import host.sim.full.BridgeJs

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim

/-- The source's native data and recorded kernel arguments use only the first `k` references. -/
def NumClosed (k : Nat) (x : FF.S) : Prop :=
  SSt (· < k) (mlxOf x) ∧
    ∀ r, krecOf x = some r → ∀ h l, r.targs.get h = some l → STargs (· < k) l

/-- Check the closed native prefix, including the kernel-recording layer. -/
def numClosedB (k : Nat) (x : FF.S) : Bool :=
  Template.checkSSt k (mlxOf x) && match krecOf x with
    | none => true
    | some r => (Template.PTrie.keys r.targs).all fun h => (r.targs.get h).all fun l =>
        l.all fun p => match p.2 with
          | .int v => Template.bSN k v
          | .dtype _ => true

theorem numClosedB_sound {k : Nat} {x : FF.S} (h : numClosedB k x = true) : NumClosed k x := by
  rw [numClosedB, Bool.and_eq_true] at h
  refine ⟨Template.checkSSt_sound h.1, ?_⟩
  intro r hr i l hl nm v hv
  have hc := h.2
  rw [hr] at hc
  have ht := List.all_eq_true.mp hc i (Template.PTrie.mem_keys _ _ _ hl)
  rw [hl] at ht
  exact Template.bSN_sound (List.all_eq_true.mp ht (nm, .int v) hv)

section
variable {P : LoadP} {NB n k n' : Nat} {M M' : Map} {x y : FF.S}

/-- Tighten the native relation's closedness bound without changing its states or map. -/
theorem FullRB.closeNum {BR : Map → FF.S → FF.S → Prop} (h : FullRB BR P NB M n x y)
    (hc : NumClosed k x) : FullRB BR P NB M k x y := by
  have hl : G.LoadR P NB M k (Host.Load.Layers.toLoad x) (Host.Load.Layers.toLoad y) :=
    { h.load with mlx := { h.load.mlx with cl := hc.1 } }
  refine ⟨hl, h.bridge, h.live, ?_, h.pend⟩
  intro r hr
  obtain ⟨r', hr', hk⟩ := h.kern r hr
  exact ⟨r', hr', { hk with cl := hc.2 r hr }⟩

theorem FullRXD.closeNum (h : FullRXD P NB M n x y) (hc : NumClosed k x) :
    FullRXD P NB M k x y := by
  obtain ⟨P', hP, h⟩ := h
  exact ⟨P', hP, h.closeNum hc⟩

/-- Restrict the table after changing reference names outside a closed native prefix. -/
theorem FullRXD.restrictNum (h : FullRXD P NB M n x y) (hc : NumClosed k x)
    (he : Ext M M' k) (hle : k ≤ n') : FullRXD P NB M' n' x y :=
  (fullRXD_laws P NB).mono M' k n' x y
    ((fullRXD_laws P NB).stable M M' k x y (h.closeNum hc) he) hle

/-- The same restriction preserves the JavaScript pointer law. -/
theorem fullRXDJ_restrictNum (h : Disp.FRJ (FullRXD P NB) M n x y) (hc : NumClosed k x)
    (he : Ext M M' k) (hle : k ≤ n') : Disp.FRJ (FullRXD P NB) M' n' x y :=
  ⟨h.1.restrictNum hc he hle, h.2.ext he⟩

end
end Host.Ts.Sim.Full
