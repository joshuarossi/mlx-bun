import host.sim.template.fill.Heap
import host.sim.template.base.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JavaScript part of the shift of case `FILL`: `FILL.s150` (the next
readback cut) holds a copy of the template `Base.s0` under `FILL.σ`, its numbers
the template entries substituted by `FILL.θ`. Every case-specific fact is a
kernel evaluation. -/

kernel_rfl FILL.num_check : checkNum FILL.σ FILL.θ FILL.S0 FILL.S1' = true
kernel_rfl FILL.fresh17 : freshVar 17 FILL.S150 Base.S0.tab = true
kernel_rfl FILL.S0_tab : FILL.S0.tab = Base.S0.tab
kernel_rfl FILL.nh0_check : Nat.ble 25000 FILL.R.data.nh0 = true
kernel_rfl FILL.src_handles : Nat.ble Base.s0.ffi.mlx.next 131072 = true
kernel_rfl FILL.ren_check : checkRen Base.s0 FILL.R.data FILL.R.inv = true
kernel_rfl FILL.band_check : FILL.R.data.checkBand 25000 = true
kernel_rfl FILL.n0_eq : FILL.R.data.n0 = Base.s0.next
kernel_rfl FILL.n1_eq : FILL.R.data.n1 = FILL.s150.next
kernel_rfl FILL.grows_check : Nat.ble Base.s0.next FILL.s150.next = true
kernel_rfl FILL.S0_len : FILL.S0.tab.length = Base.n
kernel_rfl FILL.ctl_eq : FILL.s150.ctl = FILL.σ.ctl Base.s0.ctl
kernel_rfl FILL.stack_eq : FILL.s150.stack = Base.s0.stack.map FILL.σ.frame
kernel_rfl FILL.jobs_eq : FILL.s150.jobs = Base.s0.jobs.map FILL.σ.job
kernel_rfl FILL.stores_eq : FILL.s150.stores = FILL.σ.stores Base.s0.stores
kernel_rfl FILL.intr_check : (List.range 40).all (fun a => Nat.beq (FILL.σ.a a) a) = true
kernel_rfl FILL.f1a : FILL.σ.a 2673447 = 2673447
kernel_rfl FILL.f1g0 : Base.s0.heap.get 2673447 = some (.obj (objOf Base.s0 2673447))
kernel_rfl FILL.f1k : (objOf Base.s0 2673447).kind = .array (arrOf Base.s0 2673447)
kernel_rfl FILL.f1g1 : FILL.s150.heap.get 2673447 = some (.obj { FILL.σ.obj (objOf Base.s0 2673447) with
  kind := .array (arrOf Base.s0 2673447 ++ (arrOf FILL.s150 2673447).drop (arrOf Base.s0 2673447).length) })
kernel_rfl FILL.f2a : FILL.σ.a 12502 = 12502
kernel_rfl FILL.f2g0 : Base.s0.heap.get 12502 = some (.obj (objOf Base.s0 12502))
kernel_rfl FILL.f2k : (objOf Base.s0 12502).kind = .array (arrOf Base.s0 12502)
kernel_rfl FILL.f2g1 : FILL.s150.heap.get 12502 = some (.obj { FILL.σ.obj (objOf Base.s0 12502) with
  kind := .array (arrOf Base.s0 12502 ++ (arrOf FILL.s150 12502).drop (arrOf Base.s0 12502).length) })

/-- The JavaScript part of `Shift` for case `FILL`, for every context whose framed
arrays are `forwarded`/`emitted` (with any target prefixes) and whose renamed-handle
band is `[25000, 131072)`; the end server is `FILL.S1'` (one fresh token reference). -/
theorem FILL.shiftJS (p1 p2 : List Val) (K : Host.Ts.Sim.Ctx) (hfr : K.fr = frOf Base.s0 p1 p2)
    (hlo : K.lo = 25000) (hhi : K.hi = 131072) :
    ShiftJS Host.Load.ffi FILL.σ FILL.θ K Base.s0 FILL.S0 FILL.s150 FILL.S1' where
  num := checkNum_sound FILL.num_check
  heap := by
    intro a h ha hk
    rw [hfr] at hk
    obtain ⟨q, hq, haq⟩ := Base.cover a h ha (frOf_none hk)
    rw [FILL.R.heapAt q hq a haq, ha]
    rfl
  framed := by
    intro a pre pre' hk
    rw [hfr] at hk
    rcases frOf_some hk with ⟨rfl, hp⟩ | ⟨rfl, hp⟩ <;> simp only [Prod.mk.injEq] at hp <;> obtain ⟨rfl, rfl⟩ := hp
    · exact ⟨FILL.f1a, objOf Base.s0 2673447, _, FILL.f1g0, FILL.f1k, FILL.f1g1⟩
    · exact ⟨FILL.f2a, objOf Base.s0 12502, _, FILL.f2g0, FILL.f2k, FILL.f2g1⟩
  next := by
    intro k
    show FILL.R.data.a (Base.s0.next + k) = _
    rw [← FILL.n0_eq, RData.a_fresh, FILL.n1_eq]
  grows := Nat.le_of_ble_eq_true FILL.grows_check
  present := by
    intro a hp
    obtain ⟨h, ha⟩ := Present.get hp
    by_cases hf : a ∈ framedList
    · simp only [framedList, List.mem_cons, List.mem_singleton, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl
      · rw [FILL.f1a]; exact Present.of_get FILL.f1g1
      · rw [FILL.f2a]; exact Present.of_get FILL.f2g1
    · obtain ⟨q, hq, haq⟩ := Base.cover a h ha hf
      have := FILL.R.heapAt q hq a haq
      rw [ha] at this
      exact Present.of_get this
  inj := a_inj (fun x hx => by rw [FILL.n0_eq]; exact Base.presentBound x hx) FILL.ren_check
  presentBound := Base.presentBound
  framedPresent := by
    intro a p hk
    rw [hfr] at hk
    rcases frOf_some hk with ⟨rfl, _⟩ | ⟨rfl, _⟩
    · exact Present.of_get FILL.f1g0
    · exact Present.of_get FILL.f2g0
  ctl := FILL.ctl_eq
  stack := FILL.stack_eq
  jobs := FILL.jobs_eq
  stores := FILL.stores_eq
  heapSupp := by rw [FILL.S0_len]; exact Base.heapSupp
  ctlSupp := by rw [FILL.S0_len]; exact Base.rootsSupp.1
  stackSupp := by rw [FILL.S0_len]; exact Base.rootsSupp.2.1
  jobsSupp := by rw [FILL.S0_len]; exact Base.rootsSupp.2.2.1
  storesSupp := by rw [FILL.S0_len]; exact Base.rootsSupp.2.2.2
  bigFixed := by
    rw [hlo, hhi]
    exact RData.big_fixed _ FILL.band_check (Nat.le_of_ble_eq_true FILL.nh0_check) (by decide)
  bigExt := RData.big_ext _
  intr := by
    intro a ha
    have := FILL.intr_check
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha

end Host.Load.Run.Tpl
