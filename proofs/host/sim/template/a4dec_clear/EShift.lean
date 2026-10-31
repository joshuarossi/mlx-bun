import host.sim.template.a4dec_clear.EHeap
import host.sim.template.a4dec.Closed
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JavaScript part of chain `DEC_clear`'s end shift: `DEC_clear.s11` holds a copy of `DEC_clear.s0` under `DEC_clear.σ`, its numbers the template's
substituted by `DEC_clear.θ`, the frames `addrPrompt`'s and `framesP`'s without the wide one. -/

kernel_rfl DEC_clear.num_check : checkNum DEC_clear.σ DEC_clear.θ ⟨DEC_clear.S0.tab, []⟩ DEC_clear.S1' = true
kernel_rfl DEC_clear.nh0_check : Nat.ble 25000 DEC_clear.R.data.nh0 = true
kernel_rfl DEC_clear.ren_check : checkRen DEC_clear.s0 DEC_clear.R.data DEC_clear.R.inv = true
kernel_rfl DEC_clear.band_check : DEC_clear.R.data.checkBand 25000 = true
kernel_rfl DEC_clear.n0_eq : DEC_clear.R.data.n0 = DEC_clear.s0.next
kernel_rfl DEC_clear.n1_eq : DEC_clear.R.data.n1 = DEC_clear.s11.next
kernel_rfl DEC_clear.grows_check : Nat.ble DEC_clear.s0.next DEC_clear.s11.next = true
kernel_rfl DEC_clear.ctl_eq : DEC_clear.s11.ctl = DEC_clear.σ.ctl DEC_clear.s0.ctl
kernel_rfl DEC_clear.stack_eq : DEC_clear.s11.stack = DEC_clear.s0.stack.map DEC_clear.σ.frame
kernel_rfl DEC_clear.jobs_eq : DEC_clear.s11.jobs = DEC_clear.s0.jobs.map DEC_clear.σ.job
kernel_rfl DEC_clear.stores_eq : DEC_clear.s11.stores = DEC_clear.σ.stores DEC_clear.s0.stores
kernel_rfl DEC_clear.intr_check : (List.range 40).all (fun a => Nat.beq (DEC_clear.σ.a a) a) = true
kernel_rfl DEC_clear.f1a : DEC_clear.σ.a 2673448 = 2673448
kernel_rfl DEC_clear.f1g0 : DEC_clear.s0.heap.get 2673448 = some (.obj (objOf DEC_clear.s0 2673448))
kernel_rfl DEC_clear.f1k : (objOf DEC_clear.s0 2673448).kind = .array (arrOf DEC_clear.s0 2673448)
kernel_rfl DEC_clear.f1g1 : DEC_clear.s11.heap.get 2673448 = some (.obj { DEC_clear.σ.obj (objOf DEC_clear.s0 2673448) with
  kind := .array (arrOf DEC_clear.s0 2673448 ++ (arrOf DEC_clear.s11 2673448).drop (arrOf DEC_clear.s0 2673448).length) })
kernel_rfl DEC_clear.f2a : DEC_clear.σ.a 12504 = 12504
kernel_rfl DEC_clear.f2g0 : DEC_clear.s0.heap.get 12504 = some (.obj (objOf DEC_clear.s0 12504))
kernel_rfl DEC_clear.f2k : (objOf DEC_clear.s0 12504).kind = .array (arrOf DEC_clear.s0 12504)
kernel_rfl DEC_clear.f2g1 : DEC_clear.s11.heap.get 12504 = some (.obj { DEC_clear.σ.obj (objOf DEC_clear.s0 12504) with
  kind := .array (arrOf DEC_clear.s0 12504 ++ (arrOf DEC_clear.s11 12504).drop (arrOf DEC_clear.s0 12504).length) })
kernel_rfl DEC_clear.f3a : DEC_clear.σ.a 2665 = 2665
kernel_rfl DEC_clear.f3g0 : DEC_clear.s0.heap.get 2665 = some (.obj (objOf DEC_clear.s0 2665))
kernel_rfl DEC_clear.f3k : (objOf DEC_clear.s0 2665).kind = .array (arrOf DEC_clear.s0 2665)
kernel_rfl DEC_clear.f3g1 : DEC_clear.s11.heap.get 2665 = some (.obj { DEC_clear.σ.obj (objOf DEC_clear.s0 2665) with
  kind := .array (arrOf DEC_clear.s0 2665 ++ (arrOf DEC_clear.s11 2665).drop (arrOf DEC_clear.s0 2665).length) })

/-- **The JavaScript part of the end shift**, for every context framed by `frA addrPrompt` with the prompt route's
further frames (any target prefixes) and the band `[25000, 131072)`, its wide frame dropped. -/
theorem DEC_clear.shiftJS (q p1 p2 : List Val) (K : Host.Ts.Sim.Ctx)
    (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt DEC_clear.s0 (framesP DEC_clear.s0 q).X p1 p2) (hlo : K.lo = 25000) (hhi : K.hi = 131072) :
    ShiftJS Host.Load.Layers.full DEC_clear.σ DEC_clear.θ (K.unW wideP) DEC_clear.s0 ⟨DEC_clear.S0.tab, []⟩ DEC_clear.s11 DEC_clear.S1' where
  num := checkNum_sound DEC_clear.num_check
  heap := by
    intro a h ha hk
    have hm := frP_none hfr hk
    rw [← DT.frames_eq] at hm
    obtain ⟨q', hq, haq⟩ := DT.cover a h ha hm
    rw [DEC_clear.R.heapAt q' hq a haq, ha]
    rfl
  framed := by
    intro a pre pre' hk
    rcases frP_some hfr hk with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · exact ⟨DEC_clear.f1a, objOf DEC_clear.s0 2673448, _, DEC_clear.f1g0, DEC_clear.f1k, DEC_clear.f1g1⟩
    · exact ⟨DEC_clear.f2a, objOf DEC_clear.s0 12504, _, DEC_clear.f2g0, DEC_clear.f2k, DEC_clear.f2g1⟩
    · exact ⟨DEC_clear.f3a, objOf DEC_clear.s0 2665, _, DEC_clear.f3g0, DEC_clear.f3k, DEC_clear.f3g1⟩
  next := by
    intro k
    show DEC_clear.R.data.a (DEC_clear.s0.next + k) = _
    rw [← DEC_clear.n0_eq, RData.a_fresh, DEC_clear.n1_eq]
  grows := Nat.le_of_ble_eq_true DEC_clear.grows_check
  present := by
    intro a hp
    obtain ⟨h, ha⟩ := Present.get hp
    by_cases hf : a ∈ [2673448, 12504, 2665]
    · simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl | rfl
      · rw [DEC_clear.f1a]; exact Present.of_get DEC_clear.f1g1
      · rw [DEC_clear.f2a]; exact Present.of_get DEC_clear.f2g1
      · rw [DEC_clear.f3a]; exact Present.of_get DEC_clear.f3g1
    · rw [← DT.frames_eq] at hf
      obtain ⟨q', hq, haq⟩ := DT.cover a h ha hf
      have := DEC_clear.R.heapAt q' hq a haq
      rw [ha] at this
      exact Present.of_get this
  inj := a_inj (fun x hx => by rw [DEC_clear.n0_eq]; exact DT.presentBound x hx) DEC_clear.ren_check
  presentBound := DT.presentBound
  framedPresent := by
    intro a p hk
    obtain ⟨pre, pre'⟩ := p
    rcases frP_some hfr hk with ⟨rfl, _⟩ | ⟨rfl, _⟩ | ⟨rfl, _⟩
    · exact Present.of_get DEC_clear.f1g0
    · exact Present.of_get DEC_clear.f2g0
    · exact Present.of_get DEC_clear.f3g0
  ctl := DEC_clear.ctl_eq
  stack := DEC_clear.stack_eq
  jobs := DEC_clear.jobs_eq
  stores := DEC_clear.stores_eq
  heapSupp := by rw [show (⟨DEC_clear.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_clear.S0_len]; exact DT.heapSupp
  ctlSupp := by rw [show (⟨DEC_clear.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_clear.S0_len]; exact DT.rootsSupp.1
  stackSupp := by rw [show (⟨DEC_clear.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_clear.S0_len]; exact DT.rootsSupp.2.1
  jobsSupp := by rw [show (⟨DEC_clear.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_clear.S0_len]; exact DT.rootsSupp.2.2.1
  storesSupp := by rw [show (⟨DEC_clear.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_clear.S0_len]; exact DT.rootsSupp.2.2.2
  bigFixed := by
    show ∀ i, BigFixed K.lo K.hi i → _
    rw [hlo, hhi]
    exact RData.big_fixed _ DEC_clear.band_check (Nat.le_of_ble_eq_true DEC_clear.nh0_check) (by decide)
  bigExt := RData.big_ext _
  intr := by
    intro a ha
    have := DEC_clear.intr_check
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha

end Host.Load.Run.Tpl
