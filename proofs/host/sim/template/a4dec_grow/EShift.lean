import host.sim.template.a4dec_grow.EHeap
import host.sim.template.a4dec.Closed
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JavaScript part of chain `DEC_grow`'s end shift: `DEC_grow.s11` holds a copy of `DEC_grow.s0` under `DEC_grow.σ`, its numbers the template's
substituted by `DEC_grow.θ`, the frames `addrPrompt`'s and `framesP`'s without the wide one. -/

kernel_rfl DEC_grow.num_check : checkNum DEC_grow.σ DEC_grow.θ ⟨DEC_grow.S0.tab, []⟩ DEC_grow.S1' = true
kernel_rfl DEC_grow.nh0_check : Nat.ble 25000 DEC_grow.R.data.nh0 = true
kernel_rfl DEC_grow.ren_check : checkRen DEC_grow.s0 DEC_grow.R.data DEC_grow.R.inv = true
kernel_rfl DEC_grow.band_check : DEC_grow.R.data.checkBand 25000 = true
kernel_rfl DEC_grow.n0_eq : DEC_grow.R.data.n0 = DEC_grow.s0.next
kernel_rfl DEC_grow.n1_eq : DEC_grow.R.data.n1 = DEC_grow.s11.next
kernel_rfl DEC_grow.grows_check : Nat.ble DEC_grow.s0.next DEC_grow.s11.next = true
kernel_rfl DEC_grow.ctl_eq : DEC_grow.s11.ctl = DEC_grow.σ.ctl DEC_grow.s0.ctl
kernel_rfl DEC_grow.stack_eq : DEC_grow.s11.stack = DEC_grow.s0.stack.map DEC_grow.σ.frame
kernel_rfl DEC_grow.jobs_eq : DEC_grow.s11.jobs = DEC_grow.s0.jobs.map DEC_grow.σ.job
kernel_rfl DEC_grow.stores_eq : DEC_grow.s11.stores = DEC_grow.σ.stores DEC_grow.s0.stores
kernel_rfl DEC_grow.intr_check : (List.range 40).all (fun a => Nat.beq (DEC_grow.σ.a a) a) = true
kernel_rfl DEC_grow.f1a : DEC_grow.σ.a 2673448 = 2673448
kernel_rfl DEC_grow.f1g0 : DEC_grow.s0.heap.get 2673448 = some (.obj (objOf DEC_grow.s0 2673448))
kernel_rfl DEC_grow.f1k : (objOf DEC_grow.s0 2673448).kind = .array (arrOf DEC_grow.s0 2673448)
kernel_rfl DEC_grow.f1g1 : DEC_grow.s11.heap.get 2673448 = some (.obj { DEC_grow.σ.obj (objOf DEC_grow.s0 2673448) with
  kind := .array (arrOf DEC_grow.s0 2673448 ++ (arrOf DEC_grow.s11 2673448).drop (arrOf DEC_grow.s0 2673448).length) })
kernel_rfl DEC_grow.f2a : DEC_grow.σ.a 12504 = 12504
kernel_rfl DEC_grow.f2g0 : DEC_grow.s0.heap.get 12504 = some (.obj (objOf DEC_grow.s0 12504))
kernel_rfl DEC_grow.f2k : (objOf DEC_grow.s0 12504).kind = .array (arrOf DEC_grow.s0 12504)
kernel_rfl DEC_grow.f2g1 : DEC_grow.s11.heap.get 12504 = some (.obj { DEC_grow.σ.obj (objOf DEC_grow.s0 12504) with
  kind := .array (arrOf DEC_grow.s0 12504 ++ (arrOf DEC_grow.s11 12504).drop (arrOf DEC_grow.s0 12504).length) })
kernel_rfl DEC_grow.f3a : DEC_grow.σ.a 2665 = 2665
kernel_rfl DEC_grow.f3g0 : DEC_grow.s0.heap.get 2665 = some (.obj (objOf DEC_grow.s0 2665))
kernel_rfl DEC_grow.f3k : (objOf DEC_grow.s0 2665).kind = .array (arrOf DEC_grow.s0 2665)
kernel_rfl DEC_grow.f3g1 : DEC_grow.s11.heap.get 2665 = some (.obj { DEC_grow.σ.obj (objOf DEC_grow.s0 2665) with
  kind := .array (arrOf DEC_grow.s0 2665 ++ (arrOf DEC_grow.s11 2665).drop (arrOf DEC_grow.s0 2665).length) })

/-- **The JavaScript part of the end shift**, for every context framed by `frA addrPrompt` with the prompt route's
further frames (any target prefixes) and the band `[25000, 131072)`, its wide frame dropped. -/
theorem DEC_grow.shiftJS (q p1 p2 : List Val) (K : Host.Ts.Sim.Ctx)
    (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt DEC_grow.s0 (framesP DEC_grow.s0 q).X p1 p2) (hlo : K.lo = 25000) (hhi : K.hi = 131072) :
    ShiftJS Host.Load.Layers.full DEC_grow.σ DEC_grow.θ (K.unW wideP) DEC_grow.s0 ⟨DEC_grow.S0.tab, []⟩ DEC_grow.s11 DEC_grow.S1' where
  num := checkNum_sound DEC_grow.num_check
  heap := by
    intro a h ha hk
    have hm := frP_none hfr hk
    rw [← DT.frames_eq] at hm
    obtain ⟨q', hq, haq⟩ := DT.cover a h ha hm
    rw [DEC_grow.R.heapAt q' hq a haq, ha]
    rfl
  framed := by
    intro a pre pre' hk
    rcases frP_some hfr hk with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · exact ⟨DEC_grow.f1a, objOf DEC_grow.s0 2673448, _, DEC_grow.f1g0, DEC_grow.f1k, DEC_grow.f1g1⟩
    · exact ⟨DEC_grow.f2a, objOf DEC_grow.s0 12504, _, DEC_grow.f2g0, DEC_grow.f2k, DEC_grow.f2g1⟩
    · exact ⟨DEC_grow.f3a, objOf DEC_grow.s0 2665, _, DEC_grow.f3g0, DEC_grow.f3k, DEC_grow.f3g1⟩
  next := by
    intro k
    show DEC_grow.R.data.a (DEC_grow.s0.next + k) = _
    rw [← DEC_grow.n0_eq, RData.a_fresh, DEC_grow.n1_eq]
  grows := Nat.le_of_ble_eq_true DEC_grow.grows_check
  present := by
    intro a hp
    obtain ⟨h, ha⟩ := Present.get hp
    by_cases hf : a ∈ [2673448, 12504, 2665]
    · simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl | rfl
      · rw [DEC_grow.f1a]; exact Present.of_get DEC_grow.f1g1
      · rw [DEC_grow.f2a]; exact Present.of_get DEC_grow.f2g1
      · rw [DEC_grow.f3a]; exact Present.of_get DEC_grow.f3g1
    · rw [← DT.frames_eq] at hf
      obtain ⟨q', hq, haq⟩ := DT.cover a h ha hf
      have := DEC_grow.R.heapAt q' hq a haq
      rw [ha] at this
      exact Present.of_get this
  inj := a_inj (fun x hx => by rw [DEC_grow.n0_eq]; exact DT.presentBound x hx) DEC_grow.ren_check
  presentBound := DT.presentBound
  framedPresent := by
    intro a p hk
    obtain ⟨pre, pre'⟩ := p
    rcases frP_some hfr hk with ⟨rfl, _⟩ | ⟨rfl, _⟩ | ⟨rfl, _⟩
    · exact Present.of_get DEC_grow.f1g0
    · exact Present.of_get DEC_grow.f2g0
    · exact Present.of_get DEC_grow.f3g0
  ctl := DEC_grow.ctl_eq
  stack := DEC_grow.stack_eq
  jobs := DEC_grow.jobs_eq
  stores := DEC_grow.stores_eq
  heapSupp := by rw [show (⟨DEC_grow.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_grow.S0_len]; exact DT.heapSupp
  ctlSupp := by rw [show (⟨DEC_grow.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_grow.S0_len]; exact DT.rootsSupp.1
  stackSupp := by rw [show (⟨DEC_grow.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_grow.S0_len]; exact DT.rootsSupp.2.1
  jobsSupp := by rw [show (⟨DEC_grow.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_grow.S0_len]; exact DT.rootsSupp.2.2.1
  storesSupp := by rw [show (⟨DEC_grow.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_grow.S0_len]; exact DT.rootsSupp.2.2.2
  bigFixed := by
    show ∀ i, BigFixed K.lo K.hi i → _
    rw [hlo, hhi]
    exact RData.big_fixed _ DEC_grow.band_check (Nat.le_of_ble_eq_true DEC_grow.nh0_check) (by decide)
  bigExt := RData.big_ext _
  intr := by
    intro a ha
    have := DEC_grow.intr_check
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha

end Host.Load.Run.Tpl
