import host.sim.compose.a4b.GraphStart
import host.sim.compose.ValuationTerminal
import host.sim.compose.PrefillLen
import host.sim.compose.ChainFill
import host.sim.compose.ValuationBounded
import host.sim.full.TargetGrowD
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Layers
open Host.Load.Run.Prompt
namespace FinalPlainData

abbrev J (fr : List Nat) : Disp.JSP FF := fullJSPP DEC.Pw fr [(4910, .memo [])]
abbrev Q (fr : List Nat) (ν : Nat → F64) (K : Ctx) : Prop := Disp.Kp (J fr) K ∧ VBOkF loopVB ν

lemma wp (fr : List Nat) : Disp.Wp (J fr) wideP := by
  intro a w hw
  by_cases h : a = 4910
  · subst a
    have : w = .memo [] := by simpa [wideP] using hw.symm
    subst w
    rfl
  · simp [wideP, beq_false h] at hw

noncomputable def acc (b0 : BSt) (NB : Nat) (fr : List Nat) :
    AccSimG (fullWorldFb b0 NB) DEC.Pw wideP (VBOkF loopVB)
      (decOk DEC.Pw fr [(4910, .memo [])]) fr where
  jsP := J fr
  hj := ⟨rfl, rfl, fun _ => Iff.rfl⟩
  sim r := (decSim b0 NB DEC.Pw fr [(4910, .memo [])] wideP (wp fr) r).xv.nil
  simL r := (decSim b0 NB DEC.Pw fr [(4910, .memo [])] wideP (wp fr) r).nil
  ng r M ν K n s t s1 t1 S S1 C C1 hK hν hr hok hrun ht := by
    exact glue_ngrow (fun y0 => fullStepSimXLBKFbQ { DEC.Pw with rest := r } NB loopVB (J fr)
      (okCallFS_rest DEC.Pw r).symm rfl rfl rfl rfl b0 [] (wp fr) y0) hok hrun hν hK hr ht
  ngL r M ν K s t s1 t1 S S1 C C1 hK hν hr hh hok hs ht := by
    have ds := fullStepSimXLBKFbQ { DEC.Pw with rest := r } NB loopVB (J fr)
      (okCallFS_rest DEC.Pw r).symm rfl rfl rfl rfl b0 [] (wp fr) (mlxOf t.ffi)
    have hrq : RelXF FF (FRQ (FLRb b0 DEC.Pw NB r)
        (fun y => Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf y))) wideP M ν K s S t C := by
      rcases hr with hr | ⟨v, v', rs, env, fs, hc, ht, hst, hr⟩
      · exact .inl (relB_withQ hr (Host.Mlx.Ffi.NGrow.refl _))
      · exact .inr ⟨v, v', rs, env, fs, hc, ht, hst,
          relB_withQ hr (Host.Mlx.Ffi.NGrow.refl _)⟩
    obtain ⟨M1, t2, C2, ht2, _, hr2⟩ := ds M ν K s S t C s1 S1 hK hν hrq hh (.inl rfl) hok hs
    change interpC (step FF t).run C = some (t1, C1) at ht
    rw [ht] at ht2
    cases ht2
    exact relXB_q hr2

/-- A fixed checked piece consumes its own answers and preserves any remaining good oracle. -/
noncomputable def piece {Wd : World} {A : Addr} {P : Wd.Par} {W : Nat → Option WFrame}
    {sa sb : St Wd.F.S} {Sa Sb : SSrv} {QA QB : (Nat → F64) → Ctx → Prop} {n : Nat}
    (O : List Ans) (hO : Sa.oracle = O) (hlen : Sa.tab.length ≤ Sb.tab.length)
    (p : ∀ r, PieceSim (haltLawsW Wd A) (relQW Wd.F (Wd.R P r) W QA)
      (relQW Wd.F (Wd.R P r) W QB) n sa Sa sb Sb) :
    SPiece (haltLawsW Wd A) (Wd.R P) W sa Sa.tab QA sb Sb.tab QB where
  n := n
  O := O
  len := hlen
  sim r rest x hx := by
    have hg : Good x.ν Sa.oracle := by
      rw [hO]
      intro a ha
      exact hx.1.srv.good a (List.mem_append_left rest ha)
    have hrest : Good x.ν rest := by
      intro a ha
      exact hx.1.srv.good a (List.mem_append_right O ha)
    have hin : relQW Wd.F (Wd.R P r) W QA x sa Sa :=
      ⟨hx.1.srvSwap rfl ⟨hx.1.srv.num, hg⟩, hx.2⟩
    obtain ⟨x', hs, hout⟩ := p r x hin
    refine ⟨x', hs, ?_, hout.2⟩
    exact hout.1.withOracle (by rw [hs.val]; exact hrest)


/-- Lift the existing length cut to a segment piece, retaining its map and context facts. -/
theorem lenPiece {Wd : World} {A : Addr} {P : Wd.Par} {W : Nat → Option WFrame}
    {r : List NumV} {sa sb : St Wd.F.S} {Sa Sb : SSrv}
    {QA QB : (Nat → F64) → Ctx → Prop} {a : Nat} {opt : Bool} {fs : List Frame}
    {pre pre' xs : List Val} {o : Obj} {e : SymE}
    (hc : sa.ctl = .ret (.obj a)) (hst : sa.stack = .e (.member kLength opt) :: fs)
    (ho : sa.obj? a = some o) (hk : o.kind = .array (pre ++ xs))
    (hp : Bridge.lenPatch sa Sa e = (sb, Sb)) (hSb : Sb.oracle = [])
    (hf : ∀ ν K, QA ν K → K.fr a = some (pre, pre'))
    (hv : ∀ ν K, QA ν K → e.eval ν = F64.ofNat (pre'.length + xs.length))
    (hq : ∀ ν K, QA ν K → QB ν K)
    (hg : ∀ t t' : St Wd.F.S, t'.ffi = t.ffi → Wd.Grows t t') :
    PieceSim (haltLawsW Wd A) (relQW Wd.F (Wd.R P r) W QA)
      (relQW Wd.F (Wd.R P r) W QB) 1 sa Sa sb Sb := by
  intro x hx
  let J : Prefill.ICut Wd.F :=
    (Prefill.Cut.mk sb Sb.tab (Conv.relB Wd.F (Wd.R P r) W [] (fun c => QB c.ν c.K))).with
      (fun c => Ext x.M c.M Sa.tab.length ∧ c.ν = x.ν ∧ c.K = x.K)
  have cut := cut_len (J := J) (Q := fun c => QA c.ν c.K) (B := fun c => c = x)
    (Wd.laws P r) hc hst ho hk hp
    (fun c h _ => hf c.ν c.K h) (fun c h _ => hv c.ν c.K h)
    (fun c M' t' h hc' _ he hr => by
      subst c
      exact ⟨⟨hr, hq _ _ h⟩, he, rfl, rfl⟩)
  obtain ⟨t', C', hrun, x', ht', hC', hr, he, hν, hK⟩ := cut x.t x.C
    ⟨x, rfl, rfl, ⟨hx.1.withOracle (fun _ h => nomatch h), hx.2⟩, rfl⟩
  have hh : isHalt x.t.ctl = false := by rw [hx.1.ctl, hc]; rfl
  have actual := (Disp.bridge_len hx.1 (Wd.laws P r) hc hst (hf _ _ hx.2) ho hk e (hv _ _ hx.2)).1
  have hrun' := runC_one hh actual
  rw [hrun] at hrun'
  have hffi : t'.ffi = x.t.ffi := by
    injection hrun' with hp'
    have ht := congrArg Prod.fst hp'
    have hf := congrArg (fun st : St Wd.F.S => st.ffi) ht
    exact hf
  refine ⟨x', ⟨?_, hν, he, ?_, ?_⟩, ?_⟩
  · rw [ht', hC']; exact hrun
  · rw [hK]; exact (haltLawsW Wd A).krefl x.K
  · rw [ht']; exact hg _ _ hffi
  · exact ⟨hr.1.withOracle (by rw [hSb]; intro _ h; nomatch h), hr.2⟩

end FinalPlainData
end Host.Ts.Sim.Compose
