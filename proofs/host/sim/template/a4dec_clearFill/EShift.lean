import host.sim.template.a4dec_clearFill.EHeap
import host.sim.template.a4dec.Closed
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JavaScript part of chain `DEC_clearFill`'s end shift: `DEC_clearFill.s11` holds a copy of `DEC_clearFill.s0` under `DEC_clearFill.σ`, its numbers the template's
substituted by `DEC_clearFill.θ`, the frames `addrPrompt`'s and `framesP`'s without the wide one. -/

kernel_rfl DEC_clearFill.num_check : checkNum DEC_clearFill.σ DEC_clearFill.θ ⟨DEC_clearFill.S0.tab, []⟩ DEC_clearFill.S1' = true
kernel_rfl DEC_clearFill.nh0_check : Nat.ble 25000 DEC_clearFill.R.data.nh0 = true
kernel_rfl DEC_clearFill.ren_check : checkRen DEC_clearFill.s0 DEC_clearFill.R.data DEC_clearFill.R.inv = true
kernel_rfl DEC_clearFill.band_check : DEC_clearFill.R.data.checkBand 25000 = true
kernel_rfl DEC_clearFill.n0_eq : DEC_clearFill.R.data.n0 = DEC_clearFill.s0.next
kernel_rfl DEC_clearFill.n1_eq : DEC_clearFill.R.data.n1 = DEC_clearFill.s11.next
kernel_rfl DEC_clearFill.grows_check : Nat.ble DEC_clearFill.s0.next DEC_clearFill.s11.next = true
kernel_rfl DEC_clearFill.ctl_eq : DEC_clearFill.s11.ctl = DEC_clearFill.σ.ctl DEC_clearFill.s0.ctl
kernel_rfl DEC_clearFill.stack_eq : DEC_clearFill.s11.stack = DEC_clearFill.s0.stack.map DEC_clearFill.σ.frame
kernel_rfl DEC_clearFill.jobs_eq : DEC_clearFill.s11.jobs = DEC_clearFill.s0.jobs.map DEC_clearFill.σ.job
kernel_rfl DEC_clearFill.stores_eq : DEC_clearFill.s11.stores = DEC_clearFill.σ.stores DEC_clearFill.s0.stores
kernel_rfl DEC_clearFill.intr_check : (List.range 40).all (fun a => Nat.beq (DEC_clearFill.σ.a a) a) = true
kernel_rfl DEC_clearFill.f1a : DEC_clearFill.σ.a 2673448 = 2673448
kernel_rfl DEC_clearFill.f1g0 : DEC_clearFill.s0.heap.get 2673448 = some (.obj (objOf DEC_clearFill.s0 2673448))
kernel_rfl DEC_clearFill.f1k : (objOf DEC_clearFill.s0 2673448).kind = .array (arrOf DEC_clearFill.s0 2673448)
kernel_rfl DEC_clearFill.f1g1 : DEC_clearFill.s11.heap.get 2673448 = some (.obj { DEC_clearFill.σ.obj (objOf DEC_clearFill.s0 2673448) with
  kind := .array (arrOf DEC_clearFill.s0 2673448 ++ (arrOf DEC_clearFill.s11 2673448).drop (arrOf DEC_clearFill.s0 2673448).length) })
kernel_rfl DEC_clearFill.f2a : DEC_clearFill.σ.a 12504 = 12504
kernel_rfl DEC_clearFill.f2g0 : DEC_clearFill.s0.heap.get 12504 = some (.obj (objOf DEC_clearFill.s0 12504))
kernel_rfl DEC_clearFill.f2k : (objOf DEC_clearFill.s0 12504).kind = .array (arrOf DEC_clearFill.s0 12504)
kernel_rfl DEC_clearFill.f2g1 : DEC_clearFill.s11.heap.get 12504 = some (.obj { DEC_clearFill.σ.obj (objOf DEC_clearFill.s0 12504) with
  kind := .array (arrOf DEC_clearFill.s0 12504 ++ (arrOf DEC_clearFill.s11 12504).drop (arrOf DEC_clearFill.s0 12504).length) })
kernel_rfl DEC_clearFill.f3a : DEC_clearFill.σ.a 2665 = 2665
kernel_rfl DEC_clearFill.f3g0 : DEC_clearFill.s0.heap.get 2665 = some (.obj (objOf DEC_clearFill.s0 2665))
kernel_rfl DEC_clearFill.f3k : (objOf DEC_clearFill.s0 2665).kind = .array (arrOf DEC_clearFill.s0 2665)
kernel_rfl DEC_clearFill.f3g1 : DEC_clearFill.s11.heap.get 2665 = some (.obj { DEC_clearFill.σ.obj (objOf DEC_clearFill.s0 2665) with
  kind := .array (arrOf DEC_clearFill.s0 2665 ++ (arrOf DEC_clearFill.s11 2665).drop (arrOf DEC_clearFill.s0 2665).length) })

/-- **The JavaScript part of the end shift**, for every context framed by `frA addrPrompt` with the prompt route's
further frames (any target prefixes) and the band `[25000, 131072)`, its wide frame dropped. -/
theorem DEC_clearFill.shiftJS (q p1 p2 : List Val) (K : Host.Ts.Sim.Ctx)
    (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt DEC_clearFill.s0 (framesP DEC_clearFill.s0 q).X p1 p2) (hlo : K.lo = 25000) (hhi : K.hi = 131072) :
    ShiftJS Host.Load.Layers.full DEC_clearFill.σ DEC_clearFill.θ (K.unW wideP) DEC_clearFill.s0 ⟨DEC_clearFill.S0.tab, []⟩ DEC_clearFill.s11 DEC_clearFill.S1' where
  num := checkNum_sound DEC_clearFill.num_check
  heap := by
    intro a h ha hk
    have hm := frP_none hfr hk
    rw [← DT.frames_eq] at hm
    obtain ⟨q', hq, haq⟩ := DT.cover a h ha hm
    rw [DEC_clearFill.R.heapAt q' hq a haq, ha]
    rfl
  framed := by
    intro a pre pre' hk
    rcases frP_some hfr hk with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · exact ⟨DEC_clearFill.f1a, objOf DEC_clearFill.s0 2673448, _, DEC_clearFill.f1g0, DEC_clearFill.f1k, DEC_clearFill.f1g1⟩
    · exact ⟨DEC_clearFill.f2a, objOf DEC_clearFill.s0 12504, _, DEC_clearFill.f2g0, DEC_clearFill.f2k, DEC_clearFill.f2g1⟩
    · exact ⟨DEC_clearFill.f3a, objOf DEC_clearFill.s0 2665, _, DEC_clearFill.f3g0, DEC_clearFill.f3k, DEC_clearFill.f3g1⟩
  next := by
    intro k
    show DEC_clearFill.R.data.a (DEC_clearFill.s0.next + k) = _
    rw [← DEC_clearFill.n0_eq, RData.a_fresh, DEC_clearFill.n1_eq]
  grows := Nat.le_of_ble_eq_true DEC_clearFill.grows_check
  present := by
    intro a hp
    obtain ⟨h, ha⟩ := Present.get hp
    by_cases hf : a ∈ [2673448, 12504, 2665]
    · simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl | rfl
      · rw [DEC_clearFill.f1a]; exact Present.of_get DEC_clearFill.f1g1
      · rw [DEC_clearFill.f2a]; exact Present.of_get DEC_clearFill.f2g1
      · rw [DEC_clearFill.f3a]; exact Present.of_get DEC_clearFill.f3g1
    · rw [← DT.frames_eq] at hf
      obtain ⟨q', hq, haq⟩ := DT.cover a h ha hf
      have := DEC_clearFill.R.heapAt q' hq a haq
      rw [ha] at this
      exact Present.of_get this
  inj := a_inj (fun x hx => by rw [DEC_clearFill.n0_eq]; exact DT.presentBound x hx) DEC_clearFill.ren_check
  presentBound := DT.presentBound
  framedPresent := by
    intro a p hk
    obtain ⟨pre, pre'⟩ := p
    rcases frP_some hfr hk with ⟨rfl, _⟩ | ⟨rfl, _⟩ | ⟨rfl, _⟩
    · exact Present.of_get DEC_clearFill.f1g0
    · exact Present.of_get DEC_clearFill.f2g0
    · exact Present.of_get DEC_clearFill.f3g0
  ctl := DEC_clearFill.ctl_eq
  stack := DEC_clearFill.stack_eq
  jobs := DEC_clearFill.jobs_eq
  stores := DEC_clearFill.stores_eq
  heapSupp := by rw [show (⟨DEC_clearFill.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_clearFill.S0_len]; exact DT.heapSupp
  ctlSupp := by rw [show (⟨DEC_clearFill.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_clearFill.S0_len]; exact DT.rootsSupp.1
  stackSupp := by rw [show (⟨DEC_clearFill.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_clearFill.S0_len]; exact DT.rootsSupp.2.1
  jobsSupp := by rw [show (⟨DEC_clearFill.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_clearFill.S0_len]; exact DT.rootsSupp.2.2.1
  storesSupp := by rw [show (⟨DEC_clearFill.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_clearFill.S0_len]; exact DT.rootsSupp.2.2.2
  bigFixed := by
    show ∀ i, BigFixed K.lo K.hi i → _
    rw [hlo, hhi]
    exact RData.big_fixed _ DEC_clearFill.band_check (Nat.le_of_ble_eq_true DEC_clearFill.nh0_check) (by decide)
  bigExt := RData.big_ext _
  intr := by
    intro a ha
    have := DEC_clearFill.intr_check
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha

end Host.Load.Run.Tpl
