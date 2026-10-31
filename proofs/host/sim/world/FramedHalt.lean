import host.sim.world.Halt

namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

section
variable {Wd : World} {A : Addr}
  {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {G : St Wd.F.S → CSrv → Prop}
  {P : Wd.Par} {W : Nat → Option WFrame} {Fr : LoopFramesA A}
  {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals}
  {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- A halt's entry may use the exact frame contents already present in the loop invariant. -/
theorem cut_haltW_framed {i : Nat} {t : St Wd.F.S} {C : CSrv} {env : Env} {nm : Name}
    (hs : HaltSegW Wd A W P (toks.drop i) s0 s0 tab0 []) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hinv : LoopInvW Wd A Gx (relW Wd P W) P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C)
    (hgood : ∀ nx, nx ≤ 2 ^ 20 → Good (V i nx) hs.S0.oracle)
    (hQA : ∀ nx p1 (K : Ctx), nx ≤ 2 ^ 20 →
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (i - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P → hs.QA (V i nx) K)
    (henv : lookupEnv nm env = some A.cE) (hG : CutGStepW A Gx P W Fr fixA hs V G) :
    ∃ tF CF v, runC Wd.F hs.case.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (elementsW tF) = some (E0 ++ (toks.take (i - 1)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF ∧
      ∀ Fin, HaltFinW hs fixA Fin → Fin tF := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, htokM, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have h1 : RelF Wd.F (Wd.R P (toks.drop i)) W M (V i nx) K s0 hs.S0 t C :=
    h.srvSwap hs.tab ⟨fun j e he => h.srv.num j e (by rw [hs.tab] at he; exact he), hgood nx hnx⟩
  have hKfr : ∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs := fun a => by
    rw [hfr]; exact frA_ne_none A s0 Fr p1 _ a
  obtain ⟨x1, hst, hend, ⟨v, hv⟩⟩ := hs.halt (x := ⟨M, V i nx, K, t, C⟩)
    ⟨h1, hQA nx p1 K hnx hfr hlo hhi⟩
  obtain ⟨hF, -⟩ := hs.rend x1 _ _ hend
  have hext : Ext M x1.M tab0.length := by rw [← hs.tab]; exact hst.ext
  have hMa : x1.M.a = M.a := hext.a
  obtain ⟨hklo, hkhi, hke⟩ := hst.kr
  refine ⟨x1.t, x1.C, v, hst.run, hv, ?_, hst.le, ?_,
    fun Fin hfin => hfin x1 hend fun a ha => by rw [hMa]; exact hfix a ha⟩
  · have hk : x1.K.fr A.emit = some (arrOf s0 A.emit, E0 ++ (toks.take (i - 1)).map Val.num) := by
      rw [hke, hfr, frA_emit]
    obtain ⟨o, hg, hkind⟩ := hs.emitG
    refine (hF.emittedW henv hs.cell (by rw [hMa]; exact hfix _ hcE) (by rw [hMa]; exact hfix _ hb) hk hg hkind
      hwc hwe).trans ?_
    simp [Map.vals]
  · exact hG nx M K t C x1 hGx hfix h hKfr hlo hhi hst.run hst.tr hext hst.val (hklo.trans hlo) (hkhi.trans hhi)
      hke hend

/-- Every old entry proof, which needs only frame membership, supplies the framed entry proof. -/
theorem framed_entry_of_domain {i : Nat} {QA : (Nat → F64) → Ctx → Prop}
    (hQA : ∀ nx (K : Ctx), nx ≤ 2 ^ 20 →
      (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) →
      K.lo = Wd.lo P → K.hi = Wd.E P → QA (V i nx) K) :
    ∀ nx p1 (K : Ctx), nx ≤ 2 ^ 20 →
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (i - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P → QA (V i nx) K := by
  intro nx p1 K hnx hfr hlo hhi
  exact hQA nx K hnx (fun a => by rw [hfr]; exact frA_ne_none A s0 Fr p1 _ a) hlo hhi

end
end Host.Ts.Sim.Prefill
