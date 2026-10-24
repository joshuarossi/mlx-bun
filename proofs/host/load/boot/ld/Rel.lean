import host.load.boot.ld.Closed
import host.load.boot.ld.LoadR
import host.load.run.prompt.Frame
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Ts.Sim Host.Load
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The relation at `loadDone` across readback suffixes

The template at `loadDone` is the boot's state for the empty prompt with no unread readback after the two
known heads (`P.at2818 [] []`); the target for the prompt `fw` and the unread readback suffix `τ`
(`P.at2818 fw τ`) is the template with the prompt array at 2665 holding `fw` and the native state
`Ld.Y τ` (`Ld.frameT`). `Ld.rel_load`: under the identity map they are related (`Rel`, the prompt array
framed: template prefix `[]`, target prefix `fw`) with the load world's general native relation
`G.LoadR` at the remaining readbacks `τ`, at every valuation `ρ` of the load's table, the template's
closedness (`Ld.heapSupp`, `Ld.rootsSupp`, `Ld.presentBound`) and its native relation (`Ld.loadR`)
checked here. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager Ld.frameT : ∀ (fw : List Val) (τ : List NumV),
  P.at2818 fw τ = ((P.at2818 [] []).setObj 2665 (promptObj fw)).reFfi (Ld.Y τ)

kernel_rfl Ld.heap_eq : (P.at2818 [] []).heap = Ld.s0.heap
kernel_rfl Ld.next_eq : (P.at2818 [] []).next = Ld.s0.next
kernel_rfl Ld.ctl_eq : (P.at2818 [] []).ctl = Ld.s0.ctl
kernel_rfl Ld.stack_eq : (P.at2818 [] []).stack = Ld.s0.stack
kernel_rfl Ld.jobs_eq : @St.jobs Host.Load.ffi.S (P.at2818 [] []) = Ld.s0.jobs
kernel_rfl Ld.stores_eq : @St.stores Host.Load.ffi.S (P.at2818 [] []) = Ld.s0.stores
kernel_rfl Ld.prompt_obj : (P.at2818 [] []).heap.get 2665 = some (.obj (promptObj []))
kernel_rfl Ld.S2818_oracle : P.S2818.oracle = []

theorem Ld.present_iff (a : Nat) : Present (P.at2818 [] []) a ↔ Present Ld.s0 a := by
  unfold Present; rw [Ld.heap_eq]

/-- The template server instantiated at `ρ`: the identity map's number references denote `ρ`'s values. -/
theorem Ld.srv (ρ : Nat → F64) : Srv Map.id ρ P.S2818 ⟨P.S2818.tab.map (SymE.eval ρ)⟩ := by
  refine ⟨fun i e he => ?_, by rw [Ld.S2818_oracle]; intro q hq; cases hq⟩
  show nth? (P.S2818.tab.map (SymE.eval ρ)) i = some (e.eval ρ)
  rw [Host.Ts.nth?_map, he]; rfl

/-- **The relation at `loadDone`** in the load world. -/
theorem Ld.rel_load (P0 : LoadP) (NB : Nat) (hlo : 0 < P0.lo ∧ P0.lo ≤ 18151) (hE : 18151 ≤ P0.E ∧ P0.E < 2 ^ 46)
    (hN : P0.NL = 15235 ∧ P0.N0 = 15235) (hNE : 15235 ≤ P0.NE ∧ P0.NE < 2 ^ 61) (hNB : NB ≤ P0.NL)
    (ρ : Nat → F64) (lo hi : Nat) (hhi : hi ≤ 2 ^ 56) (fw : List Val) (τ : List NumV) :
    Rel Host.Load.ffi (G.LoadR { P0 with rest := τ } NB) Map.id ρ (FrameRel.ctx (P.at2818 [] []) 2665 fw lo hi)
      (P.at2818 [] []) P.S2818 (P.at2818 fw τ) ⟨P.S2818.tab.map (SymE.eval ρ)⟩ := by
  rw [Ld.frameT fw τ]
  have ha : (2665 : Nat) / 4096 < 4 ^ 31 := by decide
  have hsub : @Present Host.Load.ffi.S (P.at2818 [] []) = Present Ld.s0 := funext fun a => propext (Ld.present_iff a)
  exact {
    srv := Ld.srv ρ
    heap := by
      intro b hb hg
      show SlotOK Map.id (FrameRel.ctx (P.at2818 [] []) 2665 fw lo hi).fr b hb
        (((P.at2818 [] []).heap.set 2665 (.obj (promptObj fw))).get b)
      by_cases hba : b = 2665
      · subst hba
        rw [SlotOK.some_iff (pre := []) (pre' := fw) (by rw [FrameRel.ctx_fr]; simp)]
        rw [Ld.prompt_obj] at hg
        refine ⟨promptObj [], promptObj fw, (Option.some.inj hg).symm, PTrie.get_set_self _ _ _ ha, [], rfl, ?_⟩
        rw [Map.obj_id]; simp [Map.vals, promptObj]
      · rw [SlotOK.none_iff (by rw [FrameRel.ctx_fr]; simp [hba]), PTrie.get_set_ne _ _ _ ha _ hba, hg, Map.hobj_id]
    next := fun _ => rfl
    offset := rfl
    room := by show 0 < bound; decide
    bigFixed := fun _ _ => rfl
    bigExt := fun _ _ _ => rfl
    band := hhi
    intr := fun _ _ => rfl
    bound := fun b hb => by
      show b < (P.at2818 [] []).next
      rw [Ld.next_eq]; exact Ld.presentBound b ((Ld.present_iff b).mp hb)
    inj := fun _ _ _ _ he => he
    presentBound := fun b hb => by rw [Ld.next_eq]; exact Ld.presentBound b ((Ld.present_iff b).mp hb)
    framedPresent := by
      intro b p hp
      rw [FrameRel.ctx_fr] at hp
      by_cases hba : b = 2665
      · subst hba; exact Present.of_get Ld.prompt_obj
      · simp [hba] at hp
    ctl := (Map.ctl_id _).symm
    stack := by show (P.at2818 [] []).stack = (P.at2818 [] []).stack.map Map.id.frame ++ []; rw [List.append_nil, List.map_id'' Map.frame_id]
    jobs := (List.map_id'' Map.job_id _).symm
    stores := (Map.stores_id _).symm
    ffi := Ld.loadR P0 NB hlo hE hN hNE hNB τ
    trace := ⟨[], rfl, rfl⟩
    heapSupp := by
      intro b h hg
      rw [hsub]
      rw [Ld.heap_eq] at hg
      exact Ld.heapSupp b h hg
    ctlSupp := by rw [hsub, Ld.ctl_eq]; exact Ld.rootsSupp.1
    stackSupp := by rw [hsub, Ld.stack_eq]; exact Ld.rootsSupp.2.1
    jobsSupp := by rw [hsub, Ld.jobs_eq]; exact Ld.rootsSupp.2.2.1
    storesSupp := by rw [hsub, Ld.stores_eq]; exact Ld.rootsSupp.2.2.2
    traceSupp := ⟨[], rfl, by simp⟩ }


/-- **`FrameRel.Hyps` at `loadDone`** for the load world's general native relation (no unread readback):
the template's server facts at `ρ`, its native relation to itself (`Ld.loadR` at `τ = []`) and its
closedness. -/
theorem Ld.hyps (P0 : LoadP) (NB : Nat) (hlo : 0 < P0.lo ∧ P0.lo ≤ 18151) (hE : 18151 ≤ P0.E ∧ P0.E < 2 ^ 46)
    (hN : P0.NL = 15235 ∧ P0.N0 = 15235) (hNE : 15235 ≤ P0.NE ∧ P0.NE < 2 ^ 61) (hNB : NB ≤ P0.NL)
    (ρ : Nat → F64) (lo hi : Nat) (hhi : hi ≤ 2 ^ 56) :
    FrameRel.Hyps Host.Load.ffi (G.LoadR { P0 with rest := [] } NB) ρ P.S2818 ⟨P.S2818.tab.map (SymE.eval ρ)⟩ lo hi
      (P.at2818 [] []) :=
  have h := Ld.rel_load P0 NB hlo hE hN hNE hNB ρ lo hi hhi [] []
  ⟨h.srv, h.ffi, h.band, h.presentBound, h.heapSupp, h.ctlSupp, h.stackSupp, h.jobsSupp, h.storesSupp⟩

end Host.Load.Run.Prompt
