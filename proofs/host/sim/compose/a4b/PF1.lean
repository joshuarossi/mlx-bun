import host.sim.compose.a4b.PF1Heap
import host.sim.compose.a4b.PF1Full
import host.sim.compose.a4b.PF15EFresh
import host.sim.compose.a4b.PF1K0
import host.sim.compose.a4b.PF1K1
import host.sim.compose.a4b.PF1K2
import host.sim.compose.a4b.PF1K3
import host.sim.compose.a4b.PF1K4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PF1.facts : Pf.PfFacts PRE_pf_vw.s0 PRE_first_tail_x1_r0_suffix.s8 PRE_pf_vw.S0.tab PF1.tabP PFW1.R.data PFW1.R.inv PF1.θ PF1.P0 2825043 [2673467, 2673472, 2673473] where
  num := PF1.num
  heap := by
    intro a h ha hm
    obtain ⟨q, hq, haq⟩ := PRE_pf_vw.cover a h ha (fun hf => hm (by rw [PRE_pf_vw.frames_eq] at hf; simpa using hf))
    have he := PFW1.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PF1.fixP
  getP := PF1.getP
  kindP := PF1.kindP
  imgP := PF1.imgP
  emptyP := PF1.emptyP
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pf_vw.allPresent PF1.ND.all PF1.ndFramed a ha
    unfold PF1.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PF1.n0
  n1 := PF1.n1
  grows := Nat.le_of_ble_eq_true PF1.grows
  ren := PF1.ren
  bound := PRE_pf_vw.presentBound
  ctl := PF1.ctl
  stack := PF1.stack
  jobs := PF1.jobs
  stores := PF1.stores
  heapSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.heapSupp
  ctlSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.1
  stackSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.1
  jobsSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.2.2
  band := PF1.band
  nh0 := Nat.le_of_ble_eq_true PF1.nh0le
  intr := by
    intro a ha
    have := PF1.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pf_vw.tab_len]; exact PF1.fullShift
  inactive := PF1.inactive
  raised := .inr ⟨19057, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx = true
    rw [PRE_pf_vw.hnext]
    exact PRE_pf_vw.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pf_vw.s0.trace PRE_pf_vw.s0
    rw [PRE_pf_vw.hnext]
    exact PRE_pf_vw.noBigFresh
  loLe := Nat.le_of_ble_eq_true PF1.lo
  hi0 := Nat.le_of_ble_eq_true PF1.hi0
  nhi0 := Nat.le_of_ble_eq_true PF1.nhi0
  hi1 := Nat.le_of_ble_eq_true PF1.hi1
  nhi1 := Nat.le_of_ble_eq_true PF1.nhi1
  jsHeap := PRE_pf_vw.jsHeap
  jsRoots := PRE_pf_vw.jsRoots
  jsNative := PRE_pf_vw.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PF1.jsLe) PF1.jsKeys

end Host.Load.Run.Tpl
