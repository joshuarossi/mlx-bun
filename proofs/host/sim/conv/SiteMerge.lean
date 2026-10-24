import host.sim.conv.Site
import host.sim.conv.MergeSt
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage

/-! # The merged state at a site instance

At its own call site a site instance's call morphism is the identity (`σ = Map.id`, `τ = Map.id.res
n0 n0`, which is `Map.id`: `Map.id_res`), so the merged state `mergeSt Map.id τ rs wr s s2 s0 x` (the
boundary `tpl_chain` writes after a call) holds, address by address, the instance's return state with
the caller's frames back on the stack (`mergeSt_site`). The relation there is the caller's own, from
the instance's run (`site_merge`: `site_run`, then `RelB.srcCongr`): every written caller entry (an id
counter, a memo cell) stays under the caller's frames `W` and context `K`, related by the simulation as
the caller's entry it is, not re-related as a stage result under the stage's map. (`merge`, the
isolated path, needs the caller unframed at the template's images, `Iso.unfr`; a site instance does
not.) -/

/-- At its own site the result renaming is the identity. -/
theorem Map.id_res (n : Nat) : Map.id.res n n = Map.id := by
  show ({ Map.id with num := fun i => bif Nat.blt i n then Map.id.num i else .ref (n + (i - n)) } : Map) = Map.id
  have : (fun i => bif Nat.blt i n then Map.id.num i else NumV.ref (n + (i - n))) = Map.id.num := by
    funext i
    cases h : Nat.blt i n
    · have hn : ¬ i < n := fun hl => by
        have e : Nat.blt i n = true := by rw [Nat.blt_eq]; exact hl
        rw [e] at h; cases h
      have : n ≤ i := by omega
      show NumV.ref (n + (i - n)) = NumV.ref i
      congr 1; omega
    · rfl
  rw [this]

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}
  {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- The relation depends on the source's heap only through its entries. -/
theorem _root_.Host.Ts.Sim.RelB.srcCongr {s' : St F.S} (h : RelB F FR W stk M ν K s S t C)
    (hh : ∀ a, s'.heap.get a = s.heap.get a) (hn : s'.next = s.next) (hc : s'.ctl = s.ctl)
    (hs : s'.stack = s.stack) (hj : s'.jobs = s.jobs) (hf : s'.ffi = s.ffi) (htr : s'.trace = s.trace)
    (hst : s'.stores = s.stores) : RelB F FR W stk M ν K s' S t C := by
  have hP : Present s' = Present s := funext fun a => by unfold Present; rw [hh]
  exact {
    srv := h.srv
    heap := fun a o hg => h.heap a o (by rw [← hh]; exact hg)
    next := fun k => by rw [hn]; exact h.next k
    offset := by rw [hn]; exact h.offset
    room := h.room
    bigFixed := h.bigFixed
    bigExt := h.bigExt
    band := h.band
    intr := h.intr
    bound := by rw [hP]; exact h.bound
    inj := by rw [hP]; exact h.inj
    presentBound := by rw [hP, hn]; exact h.presentBound
    framedPresent := by rw [hP]; exact h.framedPresent
    ctl := by rw [hc]; exact h.ctl
    stack := by rw [hs]; exact h.stack
    jobs := by rw [hj]; exact h.jobs
    stores := by rw [hst]; exact h.stores
    ffi := by rw [hf]; exact h.ffi
    trace := by rw [htr]; exact h.trace
    heapSupp := fun a o hg => by rw [hP]; exact h.heapSupp a o (by rw [← hh]; exact hg)
    ctlSupp := by rw [hP, hc]; exact h.ctlSupp
    stackSupp := by rw [hP, hs]; exact h.stackSupp
    jobsSupp := by rw [hP, hj]; exact h.jobsSupp
    storesSupp := by rw [hP, hst]; exact h.storesSupp
    traceSupp := by rw [hP, htr]; exact h.traceSupp }

private theorem map_id_of {α : Type} {f : α → α} (hf : ∀ x, f x = x) : ∀ l : List α, l.map f = l
  | [] => rfl
  | x :: l => by rw [List.map_cons, hf x, map_id_of hf l]

/-- **The merged state at a site** is the instance's return state with the caller's frames, entry by
entry: written entries (`wr`, distinct, in the stores' range) carry the end's values, the others the
call's, which the stage left. -/
theorem mergeSt_site {wr : List Nat} {s0 s2 sr : St F.S} {n0 : Nat} (hs0 : s0 = { s with stack := [] })
    (hfoot : StageFoot wr s0 s2) (hnd : wr.Nodup) (hbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31)
    (htr : ∃ fr, s2.trace = fr ++ s0.trace) (hsr : sr = mergeSt Map.id (Map.id.res n0 n0) s.stack wr s s2 s0 s2.ffi) :
    (∀ a, sr.heap.get a = s2.heap.get a) ∧ sr.next = s2.next ∧ sr.ctl = s2.ctl ∧
      sr.stack = s2.stack ++ s.stack ∧ sr.jobs = s2.jobs ∧ sr.ffi = s2.ffi ∧ sr.trace = s2.trace ∧
      sr.stores = s2.stores := by
  subst hs0 hsr
  rw [Map.id_res]
  refine ⟨fun a => ?_, ?_, Map.ctl_id _, ?_, map_id_of Map.job_id _, rfl, ?_, Map.stores_id _⟩
  · show (mergeHeap Map.id Map.id wr s.heap s2.heap).get a = _
    by_cases ha : a ∈ wr
    · obtain ⟨o, hg⟩ := Present.get (hfoot.wrP a ha)
      exact (mergeHeap_ovr (σ := Map.id) (τ := Map.id) (h := s.heap) hbd hnd (fun _ _ _ _ e => e) ha hg).trans
        (by rw [Map.hobj_id, hg])
    · have hk := mergeHeap_kept (σ := Map.id) (τ := Map.id) (h := s.heap) (h2 := s2.heap) hbd
        (fun b hb e => ha (by have : b = a := e; rw [← this]; exact hb))
      rw [hk, hfoot.same a ha]
  · have : s.next ≤ s2.next := hfoot.grows
    show s.next + (s2.next - s.next) = s2.next
    omega
  · show s2.stack.map Map.id.frame ++ s.stack = _
    rw [map_id_of Map.frame_id]
  · obtain ⟨fr, hfr⟩ := htr
    have hfr' : s2.trace = fr ++ s.trace := hfr
    show (s2.trace.take (s2.trace.length - s.trace.length)).map Map.id.event ++ s.trace = s2.trace
    rw [map_id_of Map.event_id, hfr']
    simp

/-- **The merge at a site instance**: the caller's relation at the merged state, from the instance's
run (`site_run`), with the caller's frames `W`, context `K` and native relation; the written caller
entries stay the caller's. -/
theorem site_merge {ok : St F.S → SSrv → Bool} {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop}
    (T : StageTpl F ok) {wr : List Nat} (hs0 : T.s0 = { s with stack := [] }) (hS0 : T.S0 = S)
    (hsim : ∀ r, Disp.StepSimXLB F FR ok Kp W r VBOk) (hloc : ∀ s S, ok s S = true → Disp.localB s = true)
    (hK : Kp K) (hν : VBOk ν) (hfoot : StageFoot wr T.s0 T.s2) (hnd : wr.Nodup)
    (hbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31) (htr : ∃ fr, T.s2.trace = fr ++ T.s0.trace) (n0 : Nat)
    (h : RelB F FR W stk M ν K s S t C) :
    ∃ M' t' C', runC F (T.n + 1) t C = some (t', C') ∧ Ext M M' S.tab.length ∧
      RelB F FR W stk M' ν K (mergeSt Map.id (Map.id.res n0 n0) s.stack wr s T.s2 T.s0 T.s2.ffi) T.S2 t' C' := by
  obtain ⟨M', t', C', hrun, he, h2⟩ := site_run T hs0 hS0 hsim hloc hK hν hfoot h
  obtain ⟨hh, hn, hc, hst, hj, hf, htr', hso⟩ := mergeSt_site (s := s) (n0 := n0) hs0 hfoot hnd hbd htr rfl
  exact ⟨M', t', C', hrun, he, h2.srcCongr hh hn hc hst hj hf htr' hso⟩

end

end Host.Ts.Sim.Conv
