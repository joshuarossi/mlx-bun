import host.sim.compose.a4b.PF2Heap
import host.sim.compose.a4b.PF2Full
import host.sim.compose.a4b.PF15EFresh
import host.sim.compose.a4b.PF2K0
import host.sim.compose.a4b.PF2K1
import host.sim.compose.a4b.PF2K2
import host.sim.compose.a4b.PF2K3
import host.sim.compose.a4b.PF2K4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PF2.facts : Pf.PfFacts PRE_pf_vw.s0 PRE_first_tail_x2_r0_suffix.s8 PRE_pf_vw.S0.tab PF2.tabP PFW2.R.data PFW2.R.inv PF2.θ PF2.P0 2825043 [2673467, 2673472, 2673473] where
  num := PF2.num
  heap := by
    intro a h ha hm
    obtain ⟨q, hq, haq⟩ := PRE_pf_vw.cover a h ha (fun hf => hm (by rw [PRE_pf_vw.frames_eq] at hf; simpa using hf))
    have he := PFW2.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PF2.fixP
  getP := PF2.getP
  kindP := PF2.kindP
  imgP := PF2.imgP
  emptyP := PF2.emptyP
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pf_vw.allPresent PF2.ND.all PF2.ndFramed a ha
    unfold PF2.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PF2.n0
  n1 := PF2.n1
  grows := Nat.le_of_ble_eq_true PF2.grows
  ren := PF2.ren
  bound := PRE_pf_vw.presentBound
  ctl := PF2.ctl
  stack := PF2.stack
  jobs := PF2.jobs
  stores := PF2.stores
  heapSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.heapSupp
  ctlSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.1
  stackSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.1
  jobsSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.2.2
  band := PF2.band
  nh0 := Nat.le_of_ble_eq_true PF2.nh0le
  intr := by
    intro a ha
    have := PF2.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pf_vw.tab_len]; exact PF2.fullShift
  inactive := PF2.inactive
  raised := .inr ⟨19057, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx = true
    rw [PRE_pf_vw.hnext]
    exact PRE_pf_vw.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pf_vw.s0.trace PRE_pf_vw.s0
    rw [PRE_pf_vw.hnext]
    exact PRE_pf_vw.noBigFresh
  loLe := Nat.le_of_ble_eq_true PF2.lo
  hi0 := Nat.le_of_ble_eq_true PF2.hi0
  nhi0 := Nat.le_of_ble_eq_true PF2.nhi0
  hi1 := Nat.le_of_ble_eq_true PF2.hi1
  nhi1 := Nat.le_of_ble_eq_true PF2.nhi1
  jsHeap := PRE_pf_vw.jsHeap
  jsRoots := PRE_pf_vw.jsRoots
  jsNative := PRE_pf_vw.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PF2.jsLe) PF2.jsKeys

end Host.Load.Run.Tpl
