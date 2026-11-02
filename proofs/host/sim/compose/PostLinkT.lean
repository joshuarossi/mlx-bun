import host.sim.compose.PostLink
import host.sim.compose.RestartT
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl

/-! # A class's link to the tail, its traces at other node numbers

The link's shift renames nodes above `NB` (`Conv.FullShiftTB`), so classes whose compiled traces sit in another order than the template's
share it. The rest is `toTail`'s. -/

/-- The checks with a shift renaming nodes above `NB`. -/
structure PfFactsT (NB : Nat) (s0 s1 : St FF.S) (tab0 tab1 : List SymE) (D : RData) (inv : PTrie Nat)
    (θ : Nat → SymE) (P0 : LoadP) (nJ : Nat) (kept drop : List Nat) (W0 : Nat → Option WFrame) : Prop
    extends Pf.PfCore s0 s1 tab0 tab1 D inv θ P0 nJ kept drop W0 where
  shift : Conv.FullShiftTB (fun _ x y => bridgeOf y = bridgeOf x) P0 NB tab0.length D.map s0.ffi s1.ffi

/-- **The relation at the template.** -/
theorem PfFactsT.rel {NB T : Nat} {tk : Nat → Nat} {s0 s1 : St FF.S} {tab0 tab1 : List SymE} {D : RData} {inv : PTrie Nat}
    {θ : Nat → SymE} {P0 : LoadP} {nJ : Nat} {kept drop : List Nat} {W0 W : Nat → Option WFrame} {π : List Nat} {M : Map}
    {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {kw : List Nat}
    (F : PfFactsT NB s0 s1 tab0 tab1 D inv θ P0 nJ kept drop W0)
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W [] M ν K s1 ⟨tab1, []⟩ t C)
    (hfr : ∀ a, K.fr a ≠ none ↔ a ∈ 2665 :: (kept ++ (kw ++ drop))) (hkw : ∀ b ∈ kw, W0 b ≠ none)
    (hwk : ∀ a w, W0 a = some w → K.fr a = none ∨ W a = some w) (hlo : K.lo = 18151) (hhi : K.hi = 131072)
    (hP : K.fr 2665 = some ([], π.map natV)) (hK : ∀ b ∈ kept, ∃ q, K.fr b = some ([], q))
    (hroomN : NRoom setupP (Host.Load.Layers.toLoad s0.ffi) (Host.Load.Layers.toLoad t.ffi))
    (hD : K.D + (s1.next - s0.next) < Sim.bound) (hge : s0.next ≤ s1.next + K.D) :
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) W0 []
      (((M.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf t.ffi).next).withJs) (Shift.valuation θ ν)
      ⟨frW M K (Pf.keepOf kept) W0 s1, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩ s0 ⟨tab0, []⟩ t C := by
  have hsh : Conv.FullShiftTX P0 NB tab0.length D.map s0.ffi s1.ffi :=
    ⟨F.shift.load, F.shift.tokens, F.shift.tokSupp, .inl ⟨F.shift.bridge, F.inactive⟩, F.shift.live, F.shift.kern, F.shift.pend⟩
  have hs := Pf.pfShift F.toPfCore (FS := Conv.FullShiftTX P0 NB tab0.length) hsh hfr hkw hwk hlo hhi hP hK
  have hoff : t.next = s1.next + K.D := hr.offset
  exact Pf.pfRelOf F.toPfCore hr (Conv.full_compactWT NB (P := setupP) (r := machReads T tk)
    (s0 := s0) (s1 := s1) (S0 := ⟨tab0, []⟩) (S1 := ⟨tab1, []⟩) (W1 := W) (W0 := W0) (kp := Pf.keepOf kept)
    F.raised hr.ofJ hs F.bigs F.free (Pf.linkBand F.toPfCore hlo hhi) (fun _ h => nomatch h) (by omega) (by omega) hroomN) hlo

theorem toTailT {NB T cap capT nI nIT : Nat} {tk : Nat → Nat} {π extra : List Nat} {s0 s1 : St FF.S} {S0 S1 : SSrv}
    {D : RData} {inv : PTrie Nat} {θ : Nat → SymE} {P0 : LoadP} {nJ : Nat} {Mem Mem' : SegInst FF → Prop}
    (F : PfFactsT NB s0 s1 S0.tab (S1.tab ++ S0.tab.map (·.subst θ)) D inv θ P0 nJ [] extra wideG)
    (hxw : ∀ b ∈ extra, wideG b = none)
    (hH : (mlxOf s1.ffi).next + 4096 ≤ (mlxOf s0.ffi).next + 65536)
    (hN : (mlxOf s1.ffi).nnext + 4096 ≤ (mlxOf s0.ffi).nnext + 65536)
    (hgrow : s0.next ≤ s1.next) (hcap : cap + (s1.next - s0.next) ≤ capT) (hbound : capT < Sim.bound)
    (h9 : θ 9 = .var 9) (h10 : θ 10 = .var 10) (h11 : θ 11 = .var 11) (h16 : θ 16 = .var 16)
    (hres : ∀ j, j < 9 → θ j = .var j)
    (hval : ∀ x : SegInst FF, Mem x → VBOkF loopVB x.ν → VBOkF loopVB (Shift.valuation θ x.ν))
    (hdims : ∀ x : SegInst FF, Mem x → tail.dims (Shift.valuation θ x.ν))
    (hhand : ∀ x : SegInst FF, Mem x → tail.hand π.length (Shift.valuation θ x.ν))
    (hA : D.a 2590 = 2590) (hB : D.a 2586 = 2586) (hC : D.a 2589 = 2589) (hE : D.a 12504 = 12504)
    (hI : D.nodeF nIT = nI)
    (hook : ∀ x y : SegInst FF, y.t = x.t → y.C = x.C → (∀ c, y.M.node c = x.M.node (D.nodeF c)) →
      y.M.a 12504 = x.M.a 12504 → Mem x → Mem' y) :
    CutConv (withMem Mem (indexedCut0 extra NB T tk cap nI π s1 S1)) (withMem Mem' (indexedCut NB T tk capT nIT π s0 S0)) :=
  toTailOf F.toPfCore (fun hrP hfr hwk hlo hhi hP hroomN hD hge =>
      F.rel (π := π) (kw := 4910 :: ghostPf) hrP hfr kwTail hwk hlo hhi hP (fun _ h => nomatch h) hroomN hD hge)
    hxw hH hN hgrow hcap hbound h9 h10 h11 h16 hres hval hdims hhand hA hB hC hE hI hook

end Host.Ts.Sim.Compose.Post
