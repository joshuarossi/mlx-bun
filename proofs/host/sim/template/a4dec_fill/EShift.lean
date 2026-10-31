import host.sim.template.a4dec_fill.EHeap
import host.sim.template.a4dec.Closed
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JavaScript part of chain `DEC_fill`'s end shift: `DEC_fill.s11` holds a copy of `DEC_fill.s0` under `DEC_fill.σ`, its numbers the template's
substituted by `DEC_fill.θ`, the frames `addrPrompt`'s and `framesP`'s without the wide one. -/

kernel_rfl DEC_fill.num_check : checkNum DEC_fill.σ DEC_fill.θ ⟨DEC_fill.S0.tab, []⟩ DEC_fill.S1' = true
kernel_rfl DEC_fill.nh0_check : Nat.ble 25000 DEC_fill.R.data.nh0 = true
kernel_rfl DEC_fill.ren_check : checkRen DEC_fill.s0 DEC_fill.R.data DEC_fill.R.inv = true
kernel_rfl DEC_fill.band_check : DEC_fill.R.data.checkBand 25000 = true
kernel_rfl DEC_fill.n0_eq : DEC_fill.R.data.n0 = DEC_fill.s0.next
kernel_rfl DEC_fill.n1_eq : DEC_fill.R.data.n1 = DEC_fill.s11.next
kernel_rfl DEC_fill.grows_check : Nat.ble DEC_fill.s0.next DEC_fill.s11.next = true
kernel_rfl DEC_fill.ctl_eq : DEC_fill.s11.ctl = DEC_fill.σ.ctl DEC_fill.s0.ctl
kernel_rfl DEC_fill.stack_eq : DEC_fill.s11.stack = DEC_fill.s0.stack.map DEC_fill.σ.frame
kernel_rfl DEC_fill.jobs_eq : DEC_fill.s11.jobs = DEC_fill.s0.jobs.map DEC_fill.σ.job
kernel_rfl DEC_fill.stores_eq : DEC_fill.s11.stores = DEC_fill.σ.stores DEC_fill.s0.stores
kernel_rfl DEC_fill.intr_check : (List.range 40).all (fun a => Nat.beq (DEC_fill.σ.a a) a) = true
kernel_rfl DEC_fill.f1a : DEC_fill.σ.a 2673448 = 2673448
kernel_rfl DEC_fill.f1g0 : DEC_fill.s0.heap.get 2673448 = some (.obj (objOf DEC_fill.s0 2673448))
kernel_rfl DEC_fill.f1k : (objOf DEC_fill.s0 2673448).kind = .array (arrOf DEC_fill.s0 2673448)
kernel_rfl DEC_fill.f1g1 : DEC_fill.s11.heap.get 2673448 = some (.obj { DEC_fill.σ.obj (objOf DEC_fill.s0 2673448) with
  kind := .array (arrOf DEC_fill.s0 2673448 ++ (arrOf DEC_fill.s11 2673448).drop (arrOf DEC_fill.s0 2673448).length) })
kernel_rfl DEC_fill.f2a : DEC_fill.σ.a 12504 = 12504
kernel_rfl DEC_fill.f2g0 : DEC_fill.s0.heap.get 12504 = some (.obj (objOf DEC_fill.s0 12504))
kernel_rfl DEC_fill.f2k : (objOf DEC_fill.s0 12504).kind = .array (arrOf DEC_fill.s0 12504)
kernel_rfl DEC_fill.f2g1 : DEC_fill.s11.heap.get 12504 = some (.obj { DEC_fill.σ.obj (objOf DEC_fill.s0 12504) with
  kind := .array (arrOf DEC_fill.s0 12504 ++ (arrOf DEC_fill.s11 12504).drop (arrOf DEC_fill.s0 12504).length) })
kernel_rfl DEC_fill.f3a : DEC_fill.σ.a 2665 = 2665
kernel_rfl DEC_fill.f3g0 : DEC_fill.s0.heap.get 2665 = some (.obj (objOf DEC_fill.s0 2665))
kernel_rfl DEC_fill.f3k : (objOf DEC_fill.s0 2665).kind = .array (arrOf DEC_fill.s0 2665)
kernel_rfl DEC_fill.f3g1 : DEC_fill.s11.heap.get 2665 = some (.obj { DEC_fill.σ.obj (objOf DEC_fill.s0 2665) with
  kind := .array (arrOf DEC_fill.s0 2665 ++ (arrOf DEC_fill.s11 2665).drop (arrOf DEC_fill.s0 2665).length) })

/-- **The JavaScript part of the end shift**, for every context framed by `frA addrPrompt` with the prompt route's
further frames (any target prefixes) and the band `[25000, 131072)`, its wide frame dropped. -/
theorem DEC_fill.shiftJS (q p1 p2 : List Val) (K : Host.Ts.Sim.Ctx)
    (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt DEC_fill.s0 (framesP DEC_fill.s0 q).X p1 p2) (hlo : K.lo = 25000) (hhi : K.hi = 131072) :
    ShiftJS Host.Load.Layers.full DEC_fill.σ DEC_fill.θ (K.unW wideP) DEC_fill.s0 ⟨DEC_fill.S0.tab, []⟩ DEC_fill.s11 DEC_fill.S1' where
  num := checkNum_sound DEC_fill.num_check
  heap := by
    intro a h ha hk
    have hm := frP_none hfr hk
    rw [← DT.frames_eq] at hm
    obtain ⟨q', hq, haq⟩ := DT.cover a h ha hm
    rw [DEC_fill.R.heapAt q' hq a haq, ha]
    rfl
  framed := by
    intro a pre pre' hk
    rcases frP_some hfr hk with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · exact ⟨DEC_fill.f1a, objOf DEC_fill.s0 2673448, _, DEC_fill.f1g0, DEC_fill.f1k, DEC_fill.f1g1⟩
    · exact ⟨DEC_fill.f2a, objOf DEC_fill.s0 12504, _, DEC_fill.f2g0, DEC_fill.f2k, DEC_fill.f2g1⟩
    · exact ⟨DEC_fill.f3a, objOf DEC_fill.s0 2665, _, DEC_fill.f3g0, DEC_fill.f3k, DEC_fill.f3g1⟩
  next := by
    intro k
    show DEC_fill.R.data.a (DEC_fill.s0.next + k) = _
    rw [← DEC_fill.n0_eq, RData.a_fresh, DEC_fill.n1_eq]
  grows := Nat.le_of_ble_eq_true DEC_fill.grows_check
  present := by
    intro a hp
    obtain ⟨h, ha⟩ := Present.get hp
    by_cases hf : a ∈ [2673448, 12504, 2665]
    · simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl | rfl
      · rw [DEC_fill.f1a]; exact Present.of_get DEC_fill.f1g1
      · rw [DEC_fill.f2a]; exact Present.of_get DEC_fill.f2g1
      · rw [DEC_fill.f3a]; exact Present.of_get DEC_fill.f3g1
    · rw [← DT.frames_eq] at hf
      obtain ⟨q', hq, haq⟩ := DT.cover a h ha hf
      have := DEC_fill.R.heapAt q' hq a haq
      rw [ha] at this
      exact Present.of_get this
  inj := a_inj (fun x hx => by rw [DEC_fill.n0_eq]; exact DT.presentBound x hx) DEC_fill.ren_check
  presentBound := DT.presentBound
  framedPresent := by
    intro a p hk
    obtain ⟨pre, pre'⟩ := p
    rcases frP_some hfr hk with ⟨rfl, _⟩ | ⟨rfl, _⟩ | ⟨rfl, _⟩
    · exact Present.of_get DEC_fill.f1g0
    · exact Present.of_get DEC_fill.f2g0
    · exact Present.of_get DEC_fill.f3g0
  ctl := DEC_fill.ctl_eq
  stack := DEC_fill.stack_eq
  jobs := DEC_fill.jobs_eq
  stores := DEC_fill.stores_eq
  heapSupp := by rw [show (⟨DEC_fill.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_fill.S0_len]; exact DT.heapSupp
  ctlSupp := by rw [show (⟨DEC_fill.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_fill.S0_len]; exact DT.rootsSupp.1
  stackSupp := by rw [show (⟨DEC_fill.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_fill.S0_len]; exact DT.rootsSupp.2.1
  jobsSupp := by rw [show (⟨DEC_fill.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_fill.S0_len]; exact DT.rootsSupp.2.2.1
  storesSupp := by rw [show (⟨DEC_fill.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_fill.S0_len]; exact DT.rootsSupp.2.2.2
  bigFixed := by
    show ∀ i, BigFixed K.lo K.hi i → _
    rw [hlo, hhi]
    exact RData.big_fixed _ DEC_fill.band_check (Nat.le_of_ble_eq_true DEC_fill.nh0_check) (by decide)
  bigExt := RData.big_ext _
  intr := by
    intro a ha
    have := DEC_fill.intr_check
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha

end Host.Load.Run.Tpl
