import host.sim.template.clear.Heap
import host.sim.template.base.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JavaScript part of the shift of case `CLEAR`: `CLEAR.s150` (the next
readback cut) holds a copy of the template `Base.s0` under `CLEAR.σ`, its numbers
the template entries substituted by `CLEAR.θ`. Every case-specific fact is a
kernel evaluation. -/

kernel_rfl CLEAR.num_check : checkNum CLEAR.σ CLEAR.θ CLEAR.S0 CLEAR.S1' = true
kernel_rfl CLEAR.fresh17 : freshVar 17 CLEAR.S150 Base.S0.tab = true
kernel_rfl CLEAR.S0_tab : CLEAR.S0.tab = Base.S0.tab
kernel_rfl CLEAR.nh0_check : Nat.ble 25000 CLEAR.R.data.nh0 = true
kernel_rfl CLEAR.src_handles : Nat.ble Base.s0.ffi.mlx.next 131072 = true
kernel_rfl CLEAR.ren_check : checkRen Base.s0 CLEAR.R.data CLEAR.R.inv = true
kernel_rfl CLEAR.band_check : CLEAR.R.data.checkBand 25000 = true
kernel_rfl CLEAR.n0_eq : CLEAR.R.data.n0 = Base.s0.next
kernel_rfl CLEAR.n1_eq : CLEAR.R.data.n1 = CLEAR.s150.next
kernel_rfl CLEAR.grows_check : Nat.ble Base.s0.next CLEAR.s150.next = true
kernel_rfl CLEAR.S0_len : CLEAR.S0.tab.length = Base.n
kernel_rfl CLEAR.ctl_eq : CLEAR.s150.ctl = CLEAR.σ.ctl Base.s0.ctl
kernel_rfl CLEAR.stack_eq : CLEAR.s150.stack = Base.s0.stack.map CLEAR.σ.frame
kernel_rfl CLEAR.jobs_eq : CLEAR.s150.jobs = Base.s0.jobs.map CLEAR.σ.job
kernel_rfl CLEAR.stores_eq : CLEAR.s150.stores = CLEAR.σ.stores Base.s0.stores
kernel_rfl CLEAR.intr_check : (List.range 40).all (fun a => Nat.beq (CLEAR.σ.a a) a) = true
kernel_rfl CLEAR.f1a : CLEAR.σ.a 2673447 = 2673447
kernel_rfl CLEAR.f1g0 : Base.s0.heap.get 2673447 = some (.obj (objOf Base.s0 2673447))
kernel_rfl CLEAR.f1k : (objOf Base.s0 2673447).kind = .array (arrOf Base.s0 2673447)
kernel_rfl CLEAR.f1g1 : CLEAR.s150.heap.get 2673447 = some (.obj { CLEAR.σ.obj (objOf Base.s0 2673447) with
  kind := .array (arrOf Base.s0 2673447 ++ (arrOf CLEAR.s150 2673447).drop (arrOf Base.s0 2673447).length) })
kernel_rfl CLEAR.f2a : CLEAR.σ.a 12502 = 12502
kernel_rfl CLEAR.f2g0 : Base.s0.heap.get 12502 = some (.obj (objOf Base.s0 12502))
kernel_rfl CLEAR.f2k : (objOf Base.s0 12502).kind = .array (arrOf Base.s0 12502)
kernel_rfl CLEAR.f2g1 : CLEAR.s150.heap.get 12502 = some (.obj { CLEAR.σ.obj (objOf Base.s0 12502) with
  kind := .array (arrOf Base.s0 12502 ++ (arrOf CLEAR.s150 12502).drop (arrOf Base.s0 12502).length) })

/-- The JavaScript part of `Shift` for case `CLEAR`, for every context whose framed
arrays are `forwarded`/`emitted` (with any target prefixes) and whose renamed-handle
band is `[25000, 131072)`; the end server is `CLEAR.S1'` (one fresh token reference). -/
theorem CLEAR.shiftJS (p1 p2 : List Val) (K : Host.Ts.Sim.Ctx) (hfr : K.fr = frOf Base.s0 p1 p2)
    (hlo : K.lo = 25000) (hhi : K.hi = 131072) :
    ShiftJS Host.Load.ffi CLEAR.σ CLEAR.θ K Base.s0 CLEAR.S0 CLEAR.s150 CLEAR.S1' where
  num := checkNum_sound CLEAR.num_check
  heap := by
    intro a h ha hk
    rw [hfr] at hk
    obtain ⟨q, hq, haq⟩ := Base.cover a h ha (frOf_none hk)
    rw [CLEAR.R.heapAt q hq a haq, ha]
    rfl
  framed := by
    intro a pre pre' hk
    rw [hfr] at hk
    rcases frOf_some hk with ⟨rfl, hp⟩ | ⟨rfl, hp⟩ <;> simp only [Prod.mk.injEq] at hp <;> obtain ⟨rfl, rfl⟩ := hp
    · exact ⟨CLEAR.f1a, objOf Base.s0 2673447, _, CLEAR.f1g0, CLEAR.f1k, CLEAR.f1g1⟩
    · exact ⟨CLEAR.f2a, objOf Base.s0 12502, _, CLEAR.f2g0, CLEAR.f2k, CLEAR.f2g1⟩
  next := by
    intro k
    show CLEAR.R.data.a (Base.s0.next + k) = _
    rw [← CLEAR.n0_eq, RData.a_fresh, CLEAR.n1_eq]
  grows := Nat.le_of_ble_eq_true CLEAR.grows_check
  present := by
    intro a hp
    obtain ⟨h, ha⟩ := Present.get hp
    by_cases hf : a ∈ framedList
    · simp only [framedList, List.mem_cons, List.mem_singleton, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl
      · rw [CLEAR.f1a]; exact Present.of_get CLEAR.f1g1
      · rw [CLEAR.f2a]; exact Present.of_get CLEAR.f2g1
    · obtain ⟨q, hq, haq⟩ := Base.cover a h ha hf
      have := CLEAR.R.heapAt q hq a haq
      rw [ha] at this
      exact Present.of_get this
  inj := a_inj (fun x hx => by rw [CLEAR.n0_eq]; exact Base.presentBound x hx) CLEAR.ren_check
  presentBound := Base.presentBound
  framedPresent := by
    intro a p hk
    rw [hfr] at hk
    rcases frOf_some hk with ⟨rfl, _⟩ | ⟨rfl, _⟩
    · exact Present.of_get CLEAR.f1g0
    · exact Present.of_get CLEAR.f2g0
  ctl := CLEAR.ctl_eq
  stack := CLEAR.stack_eq
  jobs := CLEAR.jobs_eq
  stores := CLEAR.stores_eq
  heapSupp := by rw [CLEAR.S0_len]; exact Base.heapSupp
  ctlSupp := by rw [CLEAR.S0_len]; exact Base.rootsSupp.1
  stackSupp := by rw [CLEAR.S0_len]; exact Base.rootsSupp.2.1
  jobsSupp := by rw [CLEAR.S0_len]; exact Base.rootsSupp.2.2.1
  storesSupp := by rw [CLEAR.S0_len]; exact Base.rootsSupp.2.2.2
  bigFixed := by
    rw [hlo, hhi]
    exact RData.big_fixed _ CLEAR.band_check (Nat.le_of_ble_eq_true CLEAR.nh0_check) (by decide)
  bigExt := RData.big_ext _
  intr := by
    intro a ha
    have := CLEAR.intr_check
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha

end Host.Load.Run.Tpl
