import host.sim.template.a4pre_d1_body.TraceLookup
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyTrace
open Host.Ts Host.Ts.Sim Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Trace)

/-- The original indexed replay and output-slot operation, without a lookup
purity requirement. All original replay and room guards remain premises. -/
theorem applyDoneSim {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64}
    {S : SSrv} {C : CSrv} {x y : NSt} {ck b off sl : Nat} {t : Trace} {xs : List Nat}
    (hs : Srv M ν S C) (hr : G.MR P NB M S.tab.length x y)
    (hck : rchk P.NL ck x (t.ins.zip xs) t.order = true)
    (tIns : ∀ a ∈ t.ins, PN x a) (hxs : ∀ a ∈ xs, PN x a)
    (tOuts : ∀ a ∈ t.outs, PN x a)
    (tRoom : x.nnext + t.order.length ≤ P.NE)
    (hsl : sl = 0 ∨ PH x sl) (hE : x.next + 1 ≤ P.E) :
    MSim (G.MPost P NB M ν S C) S C (Host.Mlx.Ffi.applyDone x ck b off sl t xs)
      (Host.Mlx.Ffi.applyDone y (M.handle ck) (M.a b) off (M.handle sl) (M.trace t) (xs.map M.node)) := by
  unfold Host.Mlx.Ffi.applyDone Host.Mlx.Ffi.replay
  have hzip : (M.trace t).ins.zip (xs.map M.node) = substN M (t.ins.zip xs) := by
    show (t.ins.map M.node).zip (xs.map M.node) = _
    rw [List.zip_map]
    rfl
  have hzm : ∀ p ∈ t.ins.zip xs, PN x p.1 ∧ PN x p.2 := by
    intro p hp
    obtain ⟨a, k⟩ := p
    exact ⟨tIns a (List.of_mem_zip hp).1, hxs k (List.of_mem_zip hp).2⟩
  obtain ⟨rr, rr', er, er', hrel⟩ := G.MR.replayOrder ck t.order (t.ins.zip xs) hr hck hzm tRoom
  rw [hzip, show (M.trace t).order = t.order.map M.node from rfl, bind_pureP er, bind_pureP er']
  cases rr with
  | none =>
    cases rr' with
    | none => exact G.msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | some _ => exact hrel.elim
  | some q =>
    cases rr' with
    | none => exact hrel.elim
    | some q' =>
      obtain ⟨x', m1⟩ := q
      obtain ⟨y', m1'⟩ := q'
      obtain ⟨hr', rfl, hm1, hg, hnx, hax, hox⟩ := hrel
      simp only
      have houts : (M.trace t).outs.map (Host.Mlx.Ffi.substOf (substN M m1)) =
          (t.outs.map (Host.Mlx.Ffi.substOf m1)).map M.node := by
        show (t.outs.map M.node).map _ = _
        rw [List.map_map, List.map_map]
        exact List.map_congr_left fun a ha =>
          substOf_substN M (Q := PN x') (fun u v hu hv => hr'.ninj u v hu hv) m1
            (fun p hp => (hm1 p hp).1) a (hr.pn_grow hg (tOuts a ha))
      rw [houts]
      have hsl' : sl = 0 ∨ PH x' sl := by
        rcases hsl with h | h
        · exact .inl h
        · right
          unfold PH
          rw [hax, hox]
          exact h
      obtain ⟨hh, x'', hh', y'', e3, e4, hr2, hb⟩ :=
        hr'.setVec_map hsl' (by rw [hnx]; exact hE) (t.outs.map (Host.Mlx.Ffi.substOf m1))
      rw [bind_pureP (m := Host.Ts.M.pure _) (fun _ _ => rfl),
        bind_pureP (m := Host.Ts.M.pure _) (fun _ _ => rfl)]
      simp only
      rw [e3, e4]
      exact G.msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr2

end Host.Load.Run.Tpl.D1BodyTrace
