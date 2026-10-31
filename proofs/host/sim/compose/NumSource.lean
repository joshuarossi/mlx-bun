import host.sim.compose.NumImage
import host.sim.conv.SuppMap

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim

/-- A source image which changes only number references. The native relation and
the new server are supplied separately, so restriction of native references stays
under the native layer's own contract. -/
theorem rel_numImage {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M N σ : Map} {ν ν' : Nat → F64}
    {K : Ctx} {s s' t : St F.S} {S S' : SSrv} {C : CSrv}
    (h : RelB F FR W stk M ν K s S t C)
    (ha : σ.a = id) (hc : N.after σ = M) (he : Ext M N 0)
    (hheap : ∀ a, s'.heap.get a = (s.heap.get a).map σ.hobj)
    (hnext : s'.next = s.next) (hctl : s'.ctl = σ.ctl s.ctl)
    (hstack : s'.stack = s.stack.map σ.frame) (hjobs : s'.jobs = s.jobs.map σ.job)
    (hstores : s'.stores = σ.stores s.stores) (htrace : s'.trace = s.trace.map σ.event)
    (hbase : K.base.map σ.event = K.base)
    (hpre : ∀ a pre pre', K.fr a = some (pre, pre') → σ.vals pre = pre)
    (hnum : ∀ j, j < S.tab.length → Supp.nv (Present s') S'.tab.length (σ.num j))
    (hsrv : Srv N ν' S' C) (hffi : FR N S'.tab.length s'.ffi t.ffi) :
    RelB F FR W stk N ν' K s' S' t C := by
  have hP : Present s' = Present s := by
    funext a
    unfold Present
    rw [hheap a]
    cases s.heap.get a <;> rfl
  have hA : ∀ a, Present s a → Present s' (σ.a a) := by
    intro a hp
    rw [congrFun ha a, hP]
    exact hp
  have getOld : ∀ a o, s'.heap.get a = some o → ∃ q, s.heap.get a = some q ∧ o = σ.hobj q := by
    intro a o ho
    rw [hheap a] at ho
    cases hq : s.heap.get a with
    | none => simp only [hq, Option.map_none] at ho; cases ho
    | some q => exact ⟨q, rfl, (Option.some.inj (by simpa only [hq, Option.map_some] using ho)).symm⟩
  refine {
    srv := hsrv
    heap := fun a o ho => ?_
    next := fun k => by rw [he.a, hnext]; exact h.next k
    offset := by rw [hnext]; exact h.offset
    room := h.room
    bigFixed := by rw [he.big]; exact h.bigFixed
    bigExt := by rw [he.big, he.region]; exact h.bigExt
    band := h.band
    intr := by rw [he.a]; exact h.intr
    bound := by rw [hP, he.a]; exact h.bound
    inj := by rw [hP, he.a]; exact h.inj
    presentBound := by rw [hP, hnext]; exact h.presentBound
    framedPresent := by rw [hP]; exact h.framedPresent
    ctl := by rw [hctl, Map.ctl_after, hc]; exact h.ctl
    stack := ?_
    jobs := ?_
    stores := by rw [hstores, Map.stores_after, hc]; exact h.stores
    ffi := hffi
    trace := ?_
    heapSupp := fun a o ho => ?_
    ctlSupp := by rw [hctl]; exact Conv.Supp.ctl_map hA hnum h.ctlSupp
    stackSupp := ?_
    jobsSupp := ?_
    storesSupp := by rw [hstores]; exact Conv.Supp.stores_map hA hnum h.storesSupp
    traceSupp := ?_ }
  · obtain ⟨q, hq, rfl⟩ := getOld a o ho
    rw [he.a]
    exact slot_numImage ha hc (hpre a) (h.heap a q hq)
  · rw [hstack, List.map_map]
    simp only [Function.comp_def, Map.frame_after, hc]
    exact h.stack
  · rw [hjobs, List.map_map]
    simp only [Function.comp_def, Map.job_after, hc]
    exact h.jobs
  · obtain ⟨fresh, hs, ht⟩ := h.trace
    refine ⟨fresh.map σ.event, ?_, ?_⟩
    · rw [htrace, hs, List.map_append, hbase]
    · rw [List.map_map]
      simpa only [Function.comp_def, Map.event_after, hc] using ht
  · obtain ⟨q, hq, rfl⟩ := getOld a o ho
    exact Conv.Supp.hobj_map hA hnum (h.heapSupp a q hq)
  · intro f hf
    rw [hstack] at hf
    obtain ⟨g, hg, rfl⟩ := List.mem_map.mp hf
    exact Conv.Supp.frame_map hA hnum (h.stackSupp g hg)
  · intro j hj
    rw [hjobs] at hj
    obtain ⟨k, hk, rfl⟩ := List.mem_map.mp hj
    exact Conv.Supp.job_map hA hnum (h.jobsSupp k hk)
  · obtain ⟨fresh, hs, hf⟩ := h.traceSupp
    refine ⟨fresh.map σ.event, ?_, ?_⟩
    · rw [htrace, hs, List.map_append, hbase]
    · intro e he
      obtain ⟨f, hf', rfl⟩ := List.mem_map.mp he
      exact Conv.Supp.event_map hA hnum (hf f hf')

end Host.Ts.Sim.Compose
