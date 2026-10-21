import host.sim.template.ordinary.Heap
import host.sim.template.base.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JavaScript part of the shift of case `ORDINARY`: `ORDINARY.s150` (the next
readback cut) holds a copy of the template `Base.s0` under `ORDINARY.σ`, its numbers
the template entries substituted by `ORDINARY.θ`. Every case-specific fact is a
kernel evaluation. -/

kernel_rfl ORDINARY.num_check : checkNum ORDINARY.σ ORDINARY.θ ORDINARY.S0 ORDINARY.S1' = true
kernel_rfl ORDINARY.fresh17 : freshVar 17 ORDINARY.S150 Base.S0.tab = true
kernel_rfl ORDINARY.S0_tab : ORDINARY.S0.tab = Base.S0.tab
kernel_rfl ORDINARY.nh0_check : Nat.ble 25000 ORDINARY.R.data.nh0 = true
kernel_rfl ORDINARY.src_handles : Nat.ble Base.s0.ffi.mlx.next 131072 = true
kernel_rfl ORDINARY.ren_check : checkRen Base.s0 ORDINARY.R.data ORDINARY.R.inv = true
kernel_rfl ORDINARY.band_check : ORDINARY.R.data.checkBand 25000 = true
kernel_rfl ORDINARY.n0_eq : ORDINARY.R.data.n0 = Base.s0.next
kernel_rfl ORDINARY.n1_eq : ORDINARY.R.data.n1 = ORDINARY.s150.next
kernel_rfl ORDINARY.grows_check : Nat.ble Base.s0.next ORDINARY.s150.next = true
kernel_rfl ORDINARY.S0_len : ORDINARY.S0.tab.length = Base.n
kernel_rfl ORDINARY.ctl_eq : ORDINARY.s150.ctl = ORDINARY.σ.ctl Base.s0.ctl
kernel_rfl ORDINARY.stack_eq : ORDINARY.s150.stack = Base.s0.stack.map ORDINARY.σ.frame
kernel_rfl ORDINARY.jobs_eq : ORDINARY.s150.jobs = Base.s0.jobs.map ORDINARY.σ.job
kernel_rfl ORDINARY.stores_eq : ORDINARY.s150.stores = ORDINARY.σ.stores Base.s0.stores
kernel_rfl ORDINARY.intr_check : (List.range 40).all (fun a => Nat.beq (ORDINARY.σ.a a) a) = true
kernel_rfl ORDINARY.f1a : ORDINARY.σ.a 2673447 = 2673447
kernel_rfl ORDINARY.f1g0 : Base.s0.heap.get 2673447 = some (.obj (objOf Base.s0 2673447))
kernel_rfl ORDINARY.f1k : (objOf Base.s0 2673447).kind = .array (arrOf Base.s0 2673447)
kernel_rfl ORDINARY.f1g1 : ORDINARY.s150.heap.get 2673447 = some (.obj { ORDINARY.σ.obj (objOf Base.s0 2673447) with
  kind := .array (arrOf Base.s0 2673447 ++ (arrOf ORDINARY.s150 2673447).drop (arrOf Base.s0 2673447).length) })
kernel_rfl ORDINARY.f2a : ORDINARY.σ.a 12502 = 12502
kernel_rfl ORDINARY.f2g0 : Base.s0.heap.get 12502 = some (.obj (objOf Base.s0 12502))
kernel_rfl ORDINARY.f2k : (objOf Base.s0 12502).kind = .array (arrOf Base.s0 12502)
kernel_rfl ORDINARY.f2g1 : ORDINARY.s150.heap.get 12502 = some (.obj { ORDINARY.σ.obj (objOf Base.s0 12502) with
  kind := .array (arrOf Base.s0 12502 ++ (arrOf ORDINARY.s150 12502).drop (arrOf Base.s0 12502).length) })

/-- The JavaScript part of `Shift` for case `ORDINARY`, for every context whose framed
arrays are `forwarded`/`emitted` (with any target prefixes) and whose renamed-handle
band is `[25000, 131072)`; the end server is `ORDINARY.S1'` (one fresh token reference). -/
theorem ORDINARY.shiftJS (p1 p2 : List Val) (K : Host.Ts.Sim.Ctx) (hfr : K.fr = frOf Base.s0 p1 p2)
    (hlo : K.lo = 25000) (hhi : K.hi = 131072) :
    ShiftJS Host.Load.ffi ORDINARY.σ ORDINARY.θ K Base.s0 ORDINARY.S0 ORDINARY.s150 ORDINARY.S1' where
  num := checkNum_sound ORDINARY.num_check
  heap := by
    intro a h ha hk
    rw [hfr] at hk
    obtain ⟨q, hq, haq⟩ := Base.cover a h ha (frOf_none hk)
    rw [ORDINARY.R.heapAt q hq a haq, ha]
    rfl
  framed := by
    intro a pre pre' hk
    rw [hfr] at hk
    rcases frOf_some hk with ⟨rfl, hp⟩ | ⟨rfl, hp⟩ <;> simp only [Prod.mk.injEq] at hp <;> obtain ⟨rfl, rfl⟩ := hp
    · exact ⟨ORDINARY.f1a, objOf Base.s0 2673447, _, ORDINARY.f1g0, ORDINARY.f1k, ORDINARY.f1g1⟩
    · exact ⟨ORDINARY.f2a, objOf Base.s0 12502, _, ORDINARY.f2g0, ORDINARY.f2k, ORDINARY.f2g1⟩
  next := by
    intro k
    show ORDINARY.R.data.a (Base.s0.next + k) = _
    rw [← ORDINARY.n0_eq, RData.a_fresh, ORDINARY.n1_eq]
  grows := Nat.le_of_ble_eq_true ORDINARY.grows_check
  present := by
    intro a hp
    obtain ⟨h, ha⟩ := Present.get hp
    by_cases hf : a ∈ framedList
    · simp only [framedList, List.mem_cons, List.mem_singleton, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl
      · rw [ORDINARY.f1a]; exact Present.of_get ORDINARY.f1g1
      · rw [ORDINARY.f2a]; exact Present.of_get ORDINARY.f2g1
    · obtain ⟨q, hq, haq⟩ := Base.cover a h ha hf
      have := ORDINARY.R.heapAt q hq a haq
      rw [ha] at this
      exact Present.of_get this
  inj := a_inj (fun x hx => by rw [ORDINARY.n0_eq]; exact Base.presentBound x hx) ORDINARY.ren_check
  presentBound := Base.presentBound
  framedPresent := by
    intro a p hk
    rw [hfr] at hk
    rcases frOf_some hk with ⟨rfl, _⟩ | ⟨rfl, _⟩
    · exact Present.of_get ORDINARY.f1g0
    · exact Present.of_get ORDINARY.f2g0
  ctl := ORDINARY.ctl_eq
  stack := ORDINARY.stack_eq
  jobs := ORDINARY.jobs_eq
  stores := ORDINARY.stores_eq
  heapSupp := by rw [ORDINARY.S0_len]; exact Base.heapSupp
  ctlSupp := by rw [ORDINARY.S0_len]; exact Base.rootsSupp.1
  stackSupp := by rw [ORDINARY.S0_len]; exact Base.rootsSupp.2.1
  jobsSupp := by rw [ORDINARY.S0_len]; exact Base.rootsSupp.2.2.1
  storesSupp := by rw [ORDINARY.S0_len]; exact Base.rootsSupp.2.2.2
  bigFixed := by
    rw [hlo, hhi]
    exact RData.big_fixed _ ORDINARY.band_check (Nat.le_of_ble_eq_true ORDINARY.nh0_check) (by decide)
  bigExt := RData.big_ext _
  intr := by
    intro a ha
    have := ORDINARY.intr_check
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha

end Host.Load.Run.Tpl
