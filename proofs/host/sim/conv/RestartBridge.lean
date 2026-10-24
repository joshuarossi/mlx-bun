import host.sim.conv.CompactBridge
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Layers

/-! # The restart with the Neural Engine bridge

`full_restart_drop` at the full world's relation with the bridge (`FullRX`): the instance `BridgeX` of
`full_restart_dropB`, the template's shift `FullShiftX` (`FullShiftB BridgeX`: its bridge part the bridge
relation at the restart map), the bridge relation reading only node names (`bridgeX_names`) and composing
with the shift's (`shiftComp_X`). With the template start's bridge inactive it is today's restart
(`full_restart_drop_ofX`: `FullShift.toX`, `FullR.toX`, `FullRX.toR`). -/

/-- **The full world's restart dropping frames with the bridge** (`full_restart_drop` at `FullRX`). -/
theorem full_restart_dropX (NB k w : Nat) {P : LoadP} {r0 : List NumV} {M M1 : Map} {ν : Nat → F64} {K K1 : Ctx}
    {Wf W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t t1 : St FF.S} {S0 S1 : SSrv} {C C1 : CSrv}
    {n : Nat} {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (hst : fullStart P k s0) (h : RelF FF (FullRX { P with rest := r0 } NB) Wf M ν K s0 S0 t C) (hr0 : r0 = v :: r)
    (hrc : runC FF n t C = some (t1, C1)) (hext : Ext M M1 S0.tab.length)
    (h1 : RelF FF (FullRX { P with rest := r0 } NB) W1 M1 ν K1 s1 S1 t1 C1)
    (hKD : K1.D = K.D) (hKlo : K1.lo = K.lo) (hKhi : K1.hi = K.hi)
    (htab : ∀ e ∈ S1.tab, e.noVar w = true) (hor : ∀ q ∈ S1.oracle, q.noVar w = true)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftX P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w)
    (hσ : σ.num k = .ref S1.tab.length) (hk : k < S0.tab.length)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C.val v = some x) (hE : (mlxOf s1.ffi).next < P.E) (hD : s1.next - s0.next + K.D < Sim.bound)
    (hroomH : (mlxOf t.ffi).next + ((mlxOf s1.ffi).next - (mlxOf s0.ffi).next) + (P.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hroomN : (mlxOf t.ffi).nnext + ((mlxOf s1.ffi).nnext - (mlxOf s0.ffi).nnext) + (P.NE - (mlxOf s0.ffi).nnext) <
      2 ^ 62) :
    t1.next = t.next + (s1.next - s0.next) ∧
      (mlxOf t1.ffi).next = (mlxOf t.ffi).next + ((mlxOf s1.ffi).next - (mlxOf s0.ffi).next) ∧
      (mlxOf t1.ffi).nnext = (mlxOf t.ffi).nnext + ((mlxOf s1.ffi).nnext - (mlxOf s0.ffi).nnext) ∧
      RelF FF (FullRX { P with rest := r } NB) W0
        (((M1.setNum S1.tab.length v).after σ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
        (Shift.valuation θ (upd ν w x))
        ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨S0.tab, []⟩ t1 C1 :=
  full_restart_dropB bridgeX_names shiftComp_X NB k w hst h hr0 hrc hext h1 hKD hKlo hKhi htab hor hshift hW hσ hk
    hband hx hE hD hroomH hroomN

/-- **`full_restart_dropX` from the end relation alone** (`full_restart_dropE` at `FullRX`). -/
theorem full_restart_dropEX (NB k w : Nat) {P : LoadP} {r0 : List NumV} {M1 : Map} {ν : Nat → F64} {K1 : Ctx}
    {W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv}
    {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (hst : fullStart P k s0) (hr0 : r0 = v :: r) (h1 : RelF FF (FullRX { P with rest := r0 } NB) W1 M1 ν K1 s1 S1 t1 C1)
    (htab : ∀ e ∈ S1.tab, e.noVar w = true) (hor : ∀ q ∈ S1.oracle, q.noVar w = true)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftX P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w) (hσ : σ.num k = .ref S1.tab.length) (hk : k < S0.tab.length)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C1.val v = some x) (hroom : t1.next - s0.next < Sim.bound)
    (hroomH : (mlxOf t1.ffi).next + (P.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hroomN : (mlxOf t1.ffi).nnext + (P.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62) :
    RelF FF (FullRX { P with rest := r } NB) W0
      (((M1.setNum S1.tab.length v).after σ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      (Shift.valuation θ (upd ν w x))
      ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩
      s0 ⟨S0.tab, []⟩ t1 C1 :=
  full_restart_dropEB bridgeX_names shiftComp_X NB k w hst hr0 h1 htab hor hshift hW hσ hk hband hx hroom hroomH hroomN

/-- **Agreement for inactive bridges**: with the template start's bridge inactive, the restart with
the bridge gives today's (`full_restart_drop`'s statement from `full_restart_dropX`). -/
theorem full_restart_drop_ofX (NB k w : Nat) {P : LoadP} {r0 : List NumV} {M M1 : Map} {ν : Nat → F64} {K K1 : Ctx}
    {Wf W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t t1 : St FF.S} {S0 S1 : SSrv} {C C1 : CSrv}
    {n : Nat} {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (ha : (bridgeOf s0.ffi).active = false)
    (hst : fullStart P k s0) (h : RelF FF (FLR P NB r0) Wf M ν K s0 S0 t C) (hr0 : r0 = v :: r)
    (hrc : runC FF n t C = some (t1, C1)) (hext : Ext M M1 S0.tab.length)
    (h1 : RelF FF (FLR P NB r0) W1 M1 ν K1 s1 S1 t1 C1)
    (hKD : K1.D = K.D) (hKlo : K1.lo = K.lo) (hKhi : K1.hi = K.hi)
    (htab : ∀ e ∈ S1.tab, e.noVar w = true) (hor : ∀ q ∈ S1.oracle, q.noVar w = true)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShift P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w)
    (hσ : σ.num k = .ref S1.tab.length) (hk : k < S0.tab.length)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C.val v = some x) (hE : (mlxOf s1.ffi).next < P.E) (hD : s1.next - s0.next + K.D < Sim.bound)
    (hroomH : (mlxOf t.ffi).next + ((mlxOf s1.ffi).next - (mlxOf s0.ffi).next) + (P.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hroomN : (mlxOf t.ffi).nnext + ((mlxOf s1.ffi).nnext - (mlxOf s0.ffi).nnext) + (P.NE - (mlxOf s0.ffi).nnext) <
      2 ^ 62) :
    t1.next = t.next + (s1.next - s0.next) ∧
      (mlxOf t1.ffi).next = (mlxOf t.ffi).next + ((mlxOf s1.ffi).next - (mlxOf s0.ffi).next) ∧
      (mlxOf t1.ffi).nnext = (mlxOf t.ffi).nnext + ((mlxOf s1.ffi).nnext - (mlxOf s0.ffi).nnext) ∧
      RelF FF (FLR P NB r) W0 (((M1.setNum S1.tab.length v).after σ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
        (Shift.valuation θ (upd ν w x))
        ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨S0.tab, []⟩ t1 C1 := by
  have hshiftX : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftX P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩ :=
    { hshift with ffi := ⟨hshift.ffi.1, hshift.ffi.2.toX ha⟩ }
  obtain ⟨h1', h2', h3', hrel⟩ := full_restart_dropX NB k w hst (h.mapFR' h.ffi.toX) hr0 hrc hext
    (h1.mapFR' h1.ffi.toX) hKD hKlo hKhi htab hor hshiftX hW hσ hk hband hx hE hD hroomH hroomN
  exact ⟨h1', h2', h3', hrel.mapFR' (hrel.ffi.toR ha)⟩

end Host.Ts.Sim.Conv
