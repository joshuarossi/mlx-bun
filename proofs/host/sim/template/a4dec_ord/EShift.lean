import host.sim.template.a4dec_ord.EHeap
import host.sim.template.a4dec.Closed
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The JavaScript part of chain `DEC_ord`'s end shift: `DEC_ord.s11` holds a copy of `DEC_ord.s0` under `DEC_ord.σ`, its numbers the template's
substituted by `DEC_ord.θ`, the frames `addrPrompt`'s and `framesP`'s without the wide one. -/

kernel_rfl DEC_ord.num_check : checkNum DEC_ord.σ DEC_ord.θ ⟨DEC_ord.S0.tab, []⟩ DEC_ord.S1' = true
kernel_rfl DEC_ord.nh0_check : Nat.ble 25000 DEC_ord.R.data.nh0 = true
kernel_rfl DEC_ord.ren_check : checkRen DEC_ord.s0 DEC_ord.R.data DEC_ord.R.inv = true
kernel_rfl DEC_ord.band_check : DEC_ord.R.data.checkBand 25000 = true
kernel_rfl DEC_ord.n0_eq : DEC_ord.R.data.n0 = DEC_ord.s0.next
kernel_rfl DEC_ord.n1_eq : DEC_ord.R.data.n1 = DEC_ord.s11.next
kernel_rfl DEC_ord.grows_check : Nat.ble DEC_ord.s0.next DEC_ord.s11.next = true
kernel_rfl DEC_ord.ctl_eq : DEC_ord.s11.ctl = DEC_ord.σ.ctl DEC_ord.s0.ctl
kernel_rfl DEC_ord.stack_eq : DEC_ord.s11.stack = DEC_ord.s0.stack.map DEC_ord.σ.frame
kernel_rfl DEC_ord.jobs_eq : DEC_ord.s11.jobs = DEC_ord.s0.jobs.map DEC_ord.σ.job
kernel_rfl DEC_ord.stores_eq : DEC_ord.s11.stores = DEC_ord.σ.stores DEC_ord.s0.stores
kernel_rfl DEC_ord.intr_check : (List.range 40).all (fun a => Nat.beq (DEC_ord.σ.a a) a) = true
kernel_rfl DEC_ord.f1a : DEC_ord.σ.a 2673448 = 2673448
kernel_rfl DEC_ord.f1g0 : DEC_ord.s0.heap.get 2673448 = some (.obj (objOf DEC_ord.s0 2673448))
kernel_rfl DEC_ord.f1k : (objOf DEC_ord.s0 2673448).kind = .array (arrOf DEC_ord.s0 2673448)
kernel_rfl DEC_ord.f1g1 : DEC_ord.s11.heap.get 2673448 = some (.obj { DEC_ord.σ.obj (objOf DEC_ord.s0 2673448) with
  kind := .array (arrOf DEC_ord.s0 2673448 ++ (arrOf DEC_ord.s11 2673448).drop (arrOf DEC_ord.s0 2673448).length) })
kernel_rfl DEC_ord.f2a : DEC_ord.σ.a 12504 = 12504
kernel_rfl DEC_ord.f2g0 : DEC_ord.s0.heap.get 12504 = some (.obj (objOf DEC_ord.s0 12504))
kernel_rfl DEC_ord.f2k : (objOf DEC_ord.s0 12504).kind = .array (arrOf DEC_ord.s0 12504)
kernel_rfl DEC_ord.f2g1 : DEC_ord.s11.heap.get 12504 = some (.obj { DEC_ord.σ.obj (objOf DEC_ord.s0 12504) with
  kind := .array (arrOf DEC_ord.s0 12504 ++ (arrOf DEC_ord.s11 12504).drop (arrOf DEC_ord.s0 12504).length) })
kernel_rfl DEC_ord.f3a : DEC_ord.σ.a 2665 = 2665
kernel_rfl DEC_ord.f3g0 : DEC_ord.s0.heap.get 2665 = some (.obj (objOf DEC_ord.s0 2665))
kernel_rfl DEC_ord.f3k : (objOf DEC_ord.s0 2665).kind = .array (arrOf DEC_ord.s0 2665)
kernel_rfl DEC_ord.f3g1 : DEC_ord.s11.heap.get 2665 = some (.obj { DEC_ord.σ.obj (objOf DEC_ord.s0 2665) with
  kind := .array (arrOf DEC_ord.s0 2665 ++ (arrOf DEC_ord.s11 2665).drop (arrOf DEC_ord.s0 2665).length) })

/-- **The JavaScript part of the end shift**, for every context framed by `frA addrPrompt` with the prompt route's
further frames (any target prefixes) and the band `[25000, 131072)`, its wide frame dropped. -/
theorem DEC_ord.shiftJS (q p1 p2 : List Val) (K : Host.Ts.Sim.Ctx)
    (hfr : K.fr = frA Host.Load.Run.Prompt.addrPrompt DEC_ord.s0 (framesP DEC_ord.s0 q).X p1 p2) (hlo : K.lo = 25000) (hhi : K.hi = 131072) :
    ShiftJS Host.Load.Layers.full DEC_ord.σ DEC_ord.θ (K.unW wideP) DEC_ord.s0 ⟨DEC_ord.S0.tab, []⟩ DEC_ord.s11 DEC_ord.S1' where
  num := checkNum_sound DEC_ord.num_check
  heap := by
    intro a h ha hk
    have hm := frP_none hfr hk
    rw [← DT.frames_eq] at hm
    obtain ⟨q', hq, haq⟩ := DT.cover a h ha hm
    rw [DEC_ord.R.heapAt q' hq a haq, ha]
    rfl
  framed := by
    intro a pre pre' hk
    rcases frP_some hfr hk with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · exact ⟨DEC_ord.f1a, objOf DEC_ord.s0 2673448, _, DEC_ord.f1g0, DEC_ord.f1k, DEC_ord.f1g1⟩
    · exact ⟨DEC_ord.f2a, objOf DEC_ord.s0 12504, _, DEC_ord.f2g0, DEC_ord.f2k, DEC_ord.f2g1⟩
    · exact ⟨DEC_ord.f3a, objOf DEC_ord.s0 2665, _, DEC_ord.f3g0, DEC_ord.f3k, DEC_ord.f3g1⟩
  next := by
    intro k
    show DEC_ord.R.data.a (DEC_ord.s0.next + k) = _
    rw [← DEC_ord.n0_eq, RData.a_fresh, DEC_ord.n1_eq]
  grows := Nat.le_of_ble_eq_true DEC_ord.grows_check
  present := by
    intro a hp
    obtain ⟨h, ha⟩ := Present.get hp
    by_cases hf : a ∈ [2673448, 12504, 2665]
    · simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl | rfl
      · rw [DEC_ord.f1a]; exact Present.of_get DEC_ord.f1g1
      · rw [DEC_ord.f2a]; exact Present.of_get DEC_ord.f2g1
      · rw [DEC_ord.f3a]; exact Present.of_get DEC_ord.f3g1
    · rw [← DT.frames_eq] at hf
      obtain ⟨q', hq, haq⟩ := DT.cover a h ha hf
      have := DEC_ord.R.heapAt q' hq a haq
      rw [ha] at this
      exact Present.of_get this
  inj := a_inj (fun x hx => by rw [DEC_ord.n0_eq]; exact DT.presentBound x hx) DEC_ord.ren_check
  presentBound := DT.presentBound
  framedPresent := by
    intro a p hk
    obtain ⟨pre, pre'⟩ := p
    rcases frP_some hfr hk with ⟨rfl, _⟩ | ⟨rfl, _⟩ | ⟨rfl, _⟩
    · exact Present.of_get DEC_ord.f1g0
    · exact Present.of_get DEC_ord.f2g0
    · exact Present.of_get DEC_ord.f3g0
  ctl := DEC_ord.ctl_eq
  stack := DEC_ord.stack_eq
  jobs := DEC_ord.jobs_eq
  stores := DEC_ord.stores_eq
  heapSupp := by rw [show (⟨DEC_ord.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_ord.S0_len]; exact DT.heapSupp
  ctlSupp := by rw [show (⟨DEC_ord.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_ord.S0_len]; exact DT.rootsSupp.1
  stackSupp := by rw [show (⟨DEC_ord.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_ord.S0_len]; exact DT.rootsSupp.2.1
  jobsSupp := by rw [show (⟨DEC_ord.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_ord.S0_len]; exact DT.rootsSupp.2.2.1
  storesSupp := by rw [show (⟨DEC_ord.S0.tab, []⟩ : SSrv).tab.length = DT.n from DEC_ord.S0_len]; exact DT.rootsSupp.2.2.2
  bigFixed := by
    show ∀ i, BigFixed K.lo K.hi i → _
    rw [hlo, hhi]
    exact RData.big_fixed _ DEC_ord.band_check (Nat.le_of_ble_eq_true DEC_ord.nh0_check) (by decide)
  bigExt := RData.big_ext _
  intr := by
    intro a ha
    have := DEC_ord.intr_check
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha

end Host.Load.Run.Tpl
