import host.sim.template.a4pre_d1_body.TraceApply
import host.sim.full.ReplayV
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyTrace
open Host.Ts Host.Ts.Sim Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Trace shapesOf)

/-- Values required by shaped lookup come from the existing server relation and
source reference bounds, rather than a selected target trace premise. -/
theorem shapesVOfNodes {ν : Nat → F64} {M : Map} {S : SSrv} {C : CSrv} {x : NSt}
    (hs : Srv M ν S C) : ∀ (ns : List Nat),
    (∀ n ∈ ns, PN x n) → (∀ n ∈ ns, valuedN x n = true) →
    (∀ n ∈ ns, ∀ j ∈ nodeRefs x n, RefSmall ν S j) →
    ∃ a av, shapesOf x ns = some a ∧ ShapesV M C S a av
  | [], _, _, _ => ⟨[], [], rfl, trivial⟩
  | n :: ns, hp, hv, href => by
    obtain ⟨nd, hn⟩ := Option.isSome_iff_exists.mp (hp n List.mem_cons_self)
    have hval := hv n List.mem_cons_self
    unfold valuedN at hval
    rw [hn] at hval
    have hsm : ∀ j ∈ nd.shape.flatMap dimRefs, RefSmall ν S j := by
      intro j hj
      apply href n List.mem_cons_self j
      unfold nodeRefs
      rw [hn]
      exact hj
    obtain ⟨ks, hks, hb⟩ := dvss_of hs hval hsm
    obtain ⟨a, av, ha, hva⟩ := shapesVOfNodes hs ns
      (fun k hk => hp k (List.mem_cons_of_mem _ hk))
      (fun k hk => hv k (List.mem_cons_of_mem _ hk))
      (fun k hk => href k (List.mem_cons_of_mem _ hk))
    refine ⟨(nd.shape, nd.dtype) :: a, (ks, nd.dtype) :: av, ?_, rfl, hks, hb, hva⟩
    simp only [shapesOf, hn, Option.bind_some, ha, Option.map_some]

theorem traceValuesOfNodes {ν : Nat → F64} {M : Map} {S : SSrv} {C : CSrv} {x : NSt}
    (hs : Srv M ν S C) : ∀ (ts : List Trace),
    (∀ t ∈ ts, ∀ n ∈ t.ins, PN x n) →
    (∀ t ∈ ts, ∀ n ∈ t.ins, valuedN x n = true) →
    (∀ t ∈ ts, ∀ n ∈ t.ins, ∀ j ∈ nodeRefs x n, RefSmall ν S j) →
    ∃ vs, TraceValues M C S x ts vs
  | [], _, _, _ => ⟨[], trivial⟩
  | t :: ts, hp, hv, href => by
    obtain ⟨a, av, ha, hva⟩ := shapesVOfNodes hs t.ins
      (hp t List.mem_cons_self) (hv t List.mem_cons_self) (href t List.mem_cons_self)
    obtain ⟨vs, hvs⟩ := traceValuesOfNodes hs ts
      (fun q hq => hp q (List.mem_cons_of_mem _ hq))
      (fun q hq => hv q (List.mem_cons_of_mem _ hq))
      (fun q hq => href q (List.mem_cons_of_mem _ hq))
    exact ⟨av :: vs, ⟨a, ha, hva⟩, hvs⟩

end Host.Load.Run.Tpl.D1BodyTrace

-- rechecked: literal chunk length
