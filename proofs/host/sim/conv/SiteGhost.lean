import host.sim.conv.Site
import host.sim.world.IterCut
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill

/-! # The decode iteration's ghost across a site instance

A site instance keeps the caller's valuation and context and extends its map on the call's table
(`cut_site`), so the iteration's ghost `IterGhostW` (`host.sim.world.IterCut`) crosses it as a merge
binding no fresh variable (`IterGhostW.merge` at `V := False`), the growth the world's for the
instance's run. (`IterGhostW.mergeQ` is the same step in the shape of `cut_merge`'s `hQ`, whose glued
map is a fixed function of the two pairs; a site's map is the run's, so `site_ghost` is stated for
`cut_site`'s `hQ`.) -/

theorem site_ghost {Wd : World} {A : Addr} {θ : Nat → SymE} {tab0 : List SymE} {x0 c : SegInst Wd.F}
    (h : IterGhostW Wd A θ tab0 x0 c) {M' : Map} {t' : St Wd.F.S} {C' : CSrv} {n : Nat}
    (he : Ext c.M M' n) (hn : tab0.length ≤ n) (hg : Wd.Grows c.t t') :
    IterGhostW Wd A θ tab0 x0 ⟨M', c.ν, c.K, t', C'⟩ :=
  h.merge (V := fun _ => False) (he.mono hn) (fun _ _ => rfl) (fun _ _ _ _ hv => hv.elim)
    (fun _ _ _ _ hv => hv.elim) hg

end Host.Ts.Sim.Conv
