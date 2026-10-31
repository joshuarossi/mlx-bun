import host.sim.compose.ChainFill

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers

section
variable {b0 : BSt} {NB : Nat} {Pw : LoadP} {fr : List Nat} {wd : List (Nat × WFrame)} {W : Nat → Option WFrame} {A : Addr}
  {Fr : LoopFramesA A} {s0 : St FF.S} {tab0 : List SymE} {fixA : List Nat} {toks : List NumV}
  {L T : Nat} {tk : Nat → Nat} {uses : List Row} {ΔJ ΔH ΔN : Nat}

/-- The first decode link needs valuation bounds only at the iterations supported by `DecAt`. -/
def startLinkBounded {E0 : List Val} {B : LoopBase} {ρ : Nat → F64} {m : List (Nat × Q)} {θ : Nat → SymE}
    {sst : St FF.S} {Sst : SSrv} (O : List Ans) (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true)
    (hs : sst = s0) (hS : Sst.tab = tab0) (hfr : ∀ a, a ∈ A.fwd :: A.emit :: Fr.xs ↔ a ∈ fr)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx))
    (hMap : ∀ i nx, MapOk (valL ρ T tk L i nx) (decI L T i (tk (i + 1))) m) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf s0.ffi).next + T * ΔH + B.H + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf s0.ffi).nnext + T * ΔN + B.N + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62) :
    DLink (DecAt L T tk) uses m []
      (fun i x0 => iterGhostW (fullWorldFb b0 NB) A W Pw Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN θ i.k x0)
      (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ (GhostP.init (fullWorldFb b0 NB) s0) m sst Sst) where
  n := 0
  O := O
  chk := hchk
  ok _ _ i _ _ hadm x0 := CutConv.step fun x hR hB => by
    obtain ⟨hg, hν, hK, nx, p1, hν0, hfr0, hlo, hhi, -, -, hnx, -, hD, hHx, hNx, -⟩ := hB
    have hk := hadm.2.1
    have mJ : (i.k - 1 + 1) * ΔJ ≤ T * ΔJ := Nat.mul_le_mul_right _ (by omega)
    have mH : (i.k - 1 + 1) * ΔH ≤ T * ΔH := Nat.mul_le_mul_right _ (by omega)
    have mN : (i.k - 1 + 1) * ΔN ≤ T * ΔN := Nat.mul_le_mul_right _ (by omega)
    rw [Nat.add_one_mul] at mJ mH mN
    refine ⟨x, rfl, rfl, ⟨?_, ?_, ?_, ?_⟩, hg, ?_, ?_, ?_⟩
    · show RelB FF (FLRb b0 Pw NB _) W [] x.M x.ν x.K sst ⟨Sst.tab, []⟩ x.t x.C
      rw [hs, hS]; exact hR
    · rw [hν, hν0]; exact hVB _ nx hk hnx
    · rw [hK]
      exact ⟨hlo, hhi, fun a => by rw [hfr0]; exact (frA_ne_none A s0 Fr _ _ a).trans (hfr a)⟩
    · have h := hMap i.k nx
      rw [← hadm.1] at h
      rw [hν, hν0]; exact h
    · show x0.K.D + ΔJ < Sim.bound; omega
    · show (mlxOf x0.t.ffi).next + ΔH + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46
      have : (mlxOf x0.t.ffi).next ≤ (mlxOf s0.ffi).next + (i.k - 1) * ΔH + B.H := hHx
      omega
    · show (mlxOf x0.t.ffi).nnext + ΔN + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62
      have : (mlxOf x0.t.ffi).nnext ≤ (mlxOf s0.ffi).nnext + (i.k - 1) * ΔN + B.N := hNx
      omega


end

end Host.Ts.Sim.Compose
