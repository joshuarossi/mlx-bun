import host.route.cert.Row.EndCaches
import host.sim.compose.PostPath
set_option maxRecDepth 1000000
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Mlx.SimGraph
open Host.Load Host.Load.Extract Host.Load.Layers
open Host.Load.Run.Tpl (ghostAddrs wideG wideListOf)

/-! # The program's caches at a halted end cut

`end_caches`: the end cut's target reads the caches of its template, through the map. -/

kernel_rfl cacheEnv_lookup : lookupEnv chars!"cache" cacheEnv = some 2586

theorem binding_eq {S : Type} (s : St S) {je : Env} (hc : lookupEnv chars!"cache" je = some 2586) :
    bindingOf s je chars!"cache" = bindingOf s cacheEnv chars!"cache" := by
  unfold bindingOf
  rw [hc, cacheEnv_lookup]

theorem ok_env {S : Type} (s : St S) (wl : List Nat) {je : Env} (hc : lookupEnv chars!"cache" je = some 2586) :
    cachesOkWB s je wl = cachesOkWB s cacheEnv wl := by
  unfold cachesOkWB
  rw [binding_eq s hc]

theorem extraction_env {S : Type} (mx : S → Host.Mlx.Ffi.St) (s : St S) {je : Env} (hc : lookupEnv chars!"cache" je = some 2586) :
    cachesTW mx s je = cachesTW mx s cacheEnv := by
  unfold cachesTW
  rw [binding_eq s hc]

theorem lookupW_mem {a : Nat} {w : WFrame} : ∀ {l : List (Nat × WFrame)}, Disp.lookupW a l = some w → a ∈ l.map Prod.fst
  | [], h => by cases h
  | (b, w') :: l, h => by
    simp only [Disp.lookupW] at h
    cases hb : Nat.beq a b with
    | true =>
      have := Nat.eq_of_beq_eq_true hb
      subst this
      simp
    | false =>
      rw [hb] at h
      exact List.mem_cons_of_mem _ (lookupW_mem h)

theorem wide_mem (a : Nat) (w : WFrame) (h : wideG a = some w) : a ∈ 4910 :: ghostAddrs := by
  have hm := lookupW_mem (show Disp.lookupW a Host.Load.Run.Tpl.wideList = some w from h)
  simpa [Host.Load.Run.Tpl.wideList, wideListOf, List.map_map, Function.comp_def] using hm

/-- **The caches at a halted end cut.** -/
theorem end_caches {NB T cap : Nat} {tk : Nat → Nat} {extra : List Nat} {s : St FF.S} {S : SSrv} {x : SegInst FF} {je : Env}
    {aL : Nat} {cs0 : List Cache} (hr : (Compose.Post.endCut NB T tk cap extra s S).R x s ⟨S.tab, []⟩)
    (hb : (Compose.Post.endCut NB T tk cap extra s S).B x) (hc : lookupEnv chars!"cache" je = some 2586)
    (hcell : s.cell? 2586 = some (some (.obj aL))) (hfree : (Host.Load.Run.Tpl.PostOk.JF extra).framed.contains aL = false)
    (hok : cachesOkWB s cacheEnv (4910 :: ghostAddrs) = true) (hs : cachesTW mlxOf s cacheEnv = some cs0) :
    ∃ cs, ExtractSim.cachesT (x.t.reFfi (toLoad x.t.ffi)) je = some cs ∧
      cs.map cacheNodePair = (cs0.map cacheNodePair).map fun p => (p.1.map x.M.node, p.2.map x.M.node) := by
  obtain ⟨hrel, hbook⟩ := hr
  obtain ⟨Pm, _, r0⟩ := hrel.ffi.1
  have hfr : x.K.fr aL = none := by
    by_contra h
    have hm : aL ∈ (Host.Load.Run.Tpl.PostOk.JF extra).framed := (hbook.context.1.2.2 aL).mp h
    have ht : (Host.Load.Run.Tpl.PostOk.JF extra).framed.contains aL = true := List.elem_eq_true_of_mem hm
    rw [hfree] at ht
    cases ht
  obtain ⟨cs, h1, h2⟩ := hrel.cachesTW_end wide_mem (mx := mlxOf) r0.load.mlx.toMRw hc hb.2.1 (by decide) hcell hfr
    ((ok_env s _ hc).trans hok) ((extraction_env mlxOf s hc).trans hs)
  refine ⟨cs, ?_, ?_⟩
  · rw [← cachesTW_lf, cachesTW_reFfi]
    exact h1
  · have hn := cacheRW_nodes h2
    change cs.map cacheNodePair = (cs0.map cacheNodePair).map (fun p => (p.1.map x.M.node, p.2.map x.M.node)) at hn
    exact hn

end Host.Route.Cert.Row
