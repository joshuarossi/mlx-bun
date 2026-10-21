import host.sim.template.growth.Heap
import host.sim.template.base.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JavaScript part of the shift of case `GROWTH`: `GROWTH.s153` (the next
readback cut) holds a copy of the template `Base.s0` under `GROWTH.σ`, its numbers
the template entries substituted by `GROWTH.θ`. Every case-specific fact is a
kernel evaluation. -/

kernel_rfl GROWTH.num_check : checkNum GROWTH.σ GROWTH.θ GROWTH.S0 GROWTH.S1' = true
kernel_rfl GROWTH.fresh17 : freshVar 17 GROWTH.S153 Base.S0.tab = true
kernel_rfl GROWTH.S0_tab : GROWTH.S0.tab = Base.S0.tab
kernel_rfl GROWTH.nh0_check : Nat.ble 25000 GROWTH.R.data.nh0 = true
kernel_rfl GROWTH.src_handles : Nat.ble Base.s0.ffi.mlx.next 131072 = true
kernel_rfl GROWTH.ren_check : checkRen Base.s0 GROWTH.R.data GROWTH.R.inv = true
kernel_rfl GROWTH.band_check : GROWTH.R.data.checkBand 25000 = true
kernel_rfl GROWTH.n0_eq : GROWTH.R.data.n0 = Base.s0.next
kernel_rfl GROWTH.n1_eq : GROWTH.R.data.n1 = GROWTH.s153.next
kernel_rfl GROWTH.grows_check : Nat.ble Base.s0.next GROWTH.s153.next = true
kernel_rfl GROWTH.S0_len : GROWTH.S0.tab.length = Base.n
kernel_rfl GROWTH.ctl_eq : GROWTH.s153.ctl = GROWTH.σ.ctl Base.s0.ctl
kernel_rfl GROWTH.stack_eq : GROWTH.s153.stack = Base.s0.stack.map GROWTH.σ.frame
kernel_rfl GROWTH.jobs_eq : GROWTH.s153.jobs = Base.s0.jobs.map GROWTH.σ.job
kernel_rfl GROWTH.stores_eq : GROWTH.s153.stores = GROWTH.σ.stores Base.s0.stores
kernel_rfl GROWTH.intr_check : (List.range 40).all (fun a => Nat.beq (GROWTH.σ.a a) a) = true
kernel_rfl GROWTH.f1a : GROWTH.σ.a 2673447 = 2673447
kernel_rfl GROWTH.f1g0 : Base.s0.heap.get 2673447 = some (.obj (objOf Base.s0 2673447))
kernel_rfl GROWTH.f1k : (objOf Base.s0 2673447).kind = .array (arrOf Base.s0 2673447)
kernel_rfl GROWTH.f1g1 : GROWTH.s153.heap.get 2673447 = some (.obj { GROWTH.σ.obj (objOf Base.s0 2673447) with
  kind := .array (arrOf Base.s0 2673447 ++ (arrOf GROWTH.s153 2673447).drop (arrOf Base.s0 2673447).length) })
kernel_rfl GROWTH.f2a : GROWTH.σ.a 12502 = 12502
kernel_rfl GROWTH.f2g0 : Base.s0.heap.get 12502 = some (.obj (objOf Base.s0 12502))
kernel_rfl GROWTH.f2k : (objOf Base.s0 12502).kind = .array (arrOf Base.s0 12502)
kernel_rfl GROWTH.f2g1 : GROWTH.s153.heap.get 12502 = some (.obj { GROWTH.σ.obj (objOf Base.s0 12502) with
  kind := .array (arrOf Base.s0 12502 ++ (arrOf GROWTH.s153 12502).drop (arrOf Base.s0 12502).length) })

/-- The JavaScript part of `Shift` for case `GROWTH`, for every context whose framed
arrays are `forwarded`/`emitted` (with any target prefixes) and whose renamed-handle
band is `[25000, 131072)`; the end server is `GROWTH.S1'` (one fresh token reference). -/
theorem GROWTH.shiftJS (p1 p2 : List Val) (K : Host.Ts.Sim.Ctx) (hfr : K.fr = frOf Base.s0 p1 p2)
    (hlo : K.lo = 25000) (hhi : K.hi = 131072) :
    ShiftJS Host.Load.ffi GROWTH.σ GROWTH.θ K Base.s0 GROWTH.S0 GROWTH.s153 GROWTH.S1' where
  num := checkNum_sound GROWTH.num_check
  heap := by
    intro a h ha hk
    rw [hfr] at hk
    obtain ⟨q, hq, haq⟩ := Base.cover a h ha (frOf_none hk)
    rw [GROWTH.R.heapAt q hq a haq, ha]
    rfl
  framed := by
    intro a pre pre' hk
    rw [hfr] at hk
    rcases frOf_some hk with ⟨rfl, hp⟩ | ⟨rfl, hp⟩ <;> simp only [Prod.mk.injEq] at hp <;> obtain ⟨rfl, rfl⟩ := hp
    · exact ⟨GROWTH.f1a, objOf Base.s0 2673447, _, GROWTH.f1g0, GROWTH.f1k, GROWTH.f1g1⟩
    · exact ⟨GROWTH.f2a, objOf Base.s0 12502, _, GROWTH.f2g0, GROWTH.f2k, GROWTH.f2g1⟩
  next := by
    intro k
    show GROWTH.R.data.a (Base.s0.next + k) = _
    rw [← GROWTH.n0_eq, RData.a_fresh, GROWTH.n1_eq]
  grows := Nat.le_of_ble_eq_true GROWTH.grows_check
  present := by
    intro a hp
    obtain ⟨h, ha⟩ := Present.get hp
    by_cases hf : a ∈ framedList
    · simp only [framedList, List.mem_cons, List.mem_singleton, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl
      · rw [GROWTH.f1a]; exact Present.of_get GROWTH.f1g1
      · rw [GROWTH.f2a]; exact Present.of_get GROWTH.f2g1
    · obtain ⟨q, hq, haq⟩ := Base.cover a h ha hf
      have := GROWTH.R.heapAt q hq a haq
      rw [ha] at this
      exact Present.of_get this
  inj := a_inj (fun x hx => by rw [GROWTH.n0_eq]; exact Base.presentBound x hx) GROWTH.ren_check
  presentBound := Base.presentBound
  framedPresent := by
    intro a p hk
    rw [hfr] at hk
    rcases frOf_some hk with ⟨rfl, _⟩ | ⟨rfl, _⟩
    · exact Present.of_get GROWTH.f1g0
    · exact Present.of_get GROWTH.f2g0
  ctl := GROWTH.ctl_eq
  stack := GROWTH.stack_eq
  jobs := GROWTH.jobs_eq
  stores := GROWTH.stores_eq
  heapSupp := by rw [GROWTH.S0_len]; exact Base.heapSupp
  ctlSupp := by rw [GROWTH.S0_len]; exact Base.rootsSupp.1
  stackSupp := by rw [GROWTH.S0_len]; exact Base.rootsSupp.2.1
  jobsSupp := by rw [GROWTH.S0_len]; exact Base.rootsSupp.2.2.1
  storesSupp := by rw [GROWTH.S0_len]; exact Base.rootsSupp.2.2.2
  bigFixed := by
    rw [hlo, hhi]
    exact RData.big_fixed _ GROWTH.band_check (Nat.le_of_ble_eq_true GROWTH.nh0_check) (by decide)
  bigExt := RData.big_ext _
  intr := by
    intro a ha
    have := GROWTH.intr_check
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha

end Host.Load.Run.Tpl
