import host.sim.compose.a4b.PostSingleton
import host.sim.conv.RebindVar
set_option Elab.async false
namespace Host.Ts.Sim.Compose.D1First
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl

/-- The singleton row is rebound without changing the actual state, server, or carrier map. -/
theorem toPostEntry (NB T : Nat) (tk : Nat → Nat) {s : St FF.S} {S : SSrv}
    (hs : s = D1Body.s155)
    (htab : S.tab = D1Body.S155.tab.map (·.subst (fun v => if v = 9 then .var 10 else .var v)))
    (hfree : ∀ e ∈ D1Body.S155.tab, e.noVar 10 = true) :
    CutConv (returnedSavedCut NB T tk) (Post.cut NB T tk 4096 1 s S) := by
  rintro x ⟨π, K0, hr, hb, hip, hv, hem⟩ hB
  have book := postSingletonBook hb hv hem hip
  obtain ⟨origin, hfb, hp⟩ := hb
  have hrel := hr.rebindVar (old := 9) (fresh := 10) (by decide) hfree
    (newOracle := []) (fun _ h => nomatch h)
  rw [hfb.singleton] at hrel
  have ep : (s, (⟨S.tab, []⟩ : SSrv)) =
      (D1Body.s155, ⟨D1Body.S155.tab.map (·.subst (fun v => if v = 9 then .var 10 else .var v)), []⟩) :=
    Prod.ext hs (congrArg (fun tab => (⟨tab, []⟩ : SSrv)) htab)
  have hrel' := (congrArg (fun p : St FF.S × SSrv => RelB FF
    (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
    (D1Frames.typedW (Post.bytes π)) [] (postSingletonPair x).M (postSingletonPair x).ν
    (postSingletonPair x).K p.1 p.2 (postSingletonPair x).t (postSingletonPair x).C) ep).mpr hrel
  exact ⟨postSingletonPair x, rfl, rfl, ⟨π, hfb.length, π, hrel', book⟩, hB⟩

end Host.Ts.Sim.Compose.D1First
