import host.sim.world.Halt

namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

section
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {G : St Wd.F.S → CSrv → Prop}
  {P : Wd.Par} {W : Nat → Option WFrame} {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE}
  {fixA : List Nat} {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat}

/-- The final halt uses the exact frame already carried by the loop invariant. -/
theorem last_haltW_framed {T : Nat} {t : St Wd.F.S} {C : CSrv} {env : Env} {nm : Name} {ks : List Nat}
    (st : LoopStartW Wd A P s0 tab0) (hks : ks = [A.tok] ∨ ks = [A.tok, tab0.length])
    (hs : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      (ks.map fun k => .num (.ref k)))
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hupd : ∀ nx, upd (V (T - 2) nx) A.nxt (F64.ofNat (tk T)) = V (T - 2) (tk T))
    (hinv : LoopInvW Wd A Gx (relW Wd P W) P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (V (T - 2) (tk T)) hs.S0.oracle)
    (hQA : ∀ p1 (K : Ctx),
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (T - 2 - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P →
      hs.QA (V (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE) (hG : LastGStepW A Gx P W Fr fixA hs V tk G) :
    ∃ tF CF v, runC Wd.F hs.case.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (elementsW tF) = some (E0 ++ (toks.take (T - 3 + ks.length)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF ∧
      ∀ Fin, HaltFinW hs fixA Fin → Fin tF := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, htokM, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have hT1 : T - 2 + 1 = T - 1 := by omega
  have hi : T - 2 < toks.length := by omega
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 2 + 1) := List.drop_eq_getElem_cons hi
  have hT2 : T - 2 + 2 = T := by omega
  have hx : C.val toks[T - 2] = some (F64.ofNat (tk T)) := by
    have := hvals (T - 2) hi; rw [hT2] at this; exact this
  -- the look-ahead reference
  have h1 := h.extendVar' (Wd.laws _ _) hfrN (fun q hq => by cases hq) hx
  have hf : Wd.R P (toks.drop (T - 2 + 1)) (M.setNum tab0.length toks[T - 2]) (tab0.length + 1)
      (Wd.pushTok s0.ffi tab0.length) t.ffi := by
    have := h.ffi
    rw [hdrop] at this
    exact Wd.addToken this
  have h2 := h1.withSrcFfi (FR' := Wd.R P (toks.drop (T - 2 + 1))) (Wd.pushTok s0.ffi tab0.length)
    (by simpa using hf)
  rw [hupd] at h2
  have h3 : RelF Wd.F (Wd.R P (toks.drop (T - 2 + 1))) W (M.setNum tab0.length toks[T - 2])
      (V (T - 2) (tk T)) K (Wd.finalStartW s0 tab0.length) hs.S0 t C :=
    h2.srvSwap (by rw [hs.tab]) ⟨fun j e he => h2.srv.num j e (by rw [hs.tab] at he; exact he), hgood⟩
  rw [hT1] at h3
  have hKfr : ∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs := fun a => by
    rw [hfr]; exact frA_ne_none A s0 Fr p1 _ a
  -- the chain
  obtain ⟨x1, hst, hend, ⟨v, hv⟩⟩ :=
    hs.halt (x := ⟨M.setNum tab0.length toks[T - 2], V (T - 2) (tk T), K, t, C⟩) ⟨h3, hQA p1 K hfr hlo hhi⟩
  obtain ⟨hF, -⟩ := hs.rend x1 _ _ hend
  have hS0 : hs.S0.tab.length = tab0.length + 1 := by rw [hs.tab]; simp
  have hext : Ext (M.setNum tab0.length toks[T - 2]) x1.M (tab0.length + 1) := by rw [← hS0]; exact hst.ext
  have hMa : x1.M.a = M.a := hext.a
  obtain ⟨hklo, hkhi, hke⟩ := hst.kr
  refine ⟨x1.t, x1.C, v, hst.run, hv, ?_, hst.le, ?_,
    fun Fin hfin => hfin x1 hend fun a ha => by rw [hMa]; exact hfix a ha⟩
  · -- the emitted tokens
    have hk : x1.K.fr A.emit = some (arrOf s0 A.emit, E0 ++ (toks.take (T - 2 - 1)).map Val.num) := by
      rw [hke, hfr, frA_emit]
    obtain ⟨o, hg, hkind⟩ := hs.emitG
    refine (hF.emittedW henv hs.cell (by rw [hMa]; exact hfix _ hcE) (by rw [hMa]; exact hfix _ hb) hk hg hkind
      hwc hwe).trans ?_
    have hnum : ∀ j, j < tab0.length + 1 → x1.M.num j = (M.setNum tab0.length toks[T - 2]).num j :=
      fun j hj => hext.num j hj
    have hnt : x1.M.num A.tok = toks[T - 3] := by
      rw [hnum A.tok (by have := st.htok; omega), (Map.setNum_ext M tab0.length toks[T - 2]).num A.tok st.htok]
      have := htokM; rw [show T - 2 - 1 = T - 3 by omega, List.getElem?_eq_getElem (by omega)] at this
      exact (Option.some.inj this).symm
    rcases hks with rfl | rfl
    · show some (E0 ++ (toks.take (T - 2 - 1)).map Val.num ++ [Val.num (x1.M.nv (.ref A.tok))]) = _
      simp only [Map.nv, hnt]
      rw [show T - 2 - 1 = T - 3 by omega, show T - 3 + [A.tok].length = T - 3 + 1 by rfl,
        ← take_map_succ toks (T - 3) (by omega), List.append_assoc]
    · have hnn : x1.M.num tab0.length = toks[T - 2] := by
        rw [hnum tab0.length (by omega), Map.setNum_self]
      show some (E0 ++ (toks.take (T - 2 - 1)).map Val.num ++ [Val.num (x1.M.nv (.ref A.tok)),
        Val.num (x1.M.nv (.ref tab0.length))]) = _
      simp only [Map.nv, hnt, hnn]
      rw [show T - 2 - 1 = T - 3 by omega, show T - 3 + [A.tok, tab0.length].length = T - 3 + 1 + 1 by rfl,
        ← take_map_succ toks (T - 3 + 1) (by omega), ← take_map_succ toks (T - 3) (by omega)]
      simp only [List.append_assoc, List.singleton_append, show T - 3 + 1 = T - 2 by omega]
  · exact hG hi nx M K t C x1 hGx hfix h hKfr hlo hhi hst.run hst.tr hext hst.val (hklo.trans hlo) (hkhi.trans hhi)
      hke hend


/-- A domain-only final entry proof also holds at the exact invariant frame. -/
theorem last_framed_entry_of_domain {ν : Nat → F64} {T : Nat} {QA : (Nat → F64) → Ctx → Prop}
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) →
      K.lo = Wd.lo P → K.hi = Wd.E P → QA ν K) :
    ∀ p1 (K : Ctx), K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (T - 2 - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P → QA ν K := by
  intro p1 K hfr hlo hhi
  exact hQA K (fun a => by rw [hfr]; exact frA_ne_none A s0 Fr p1 _ a) hlo hhi

end
end Host.Ts.Sim.Prefill
