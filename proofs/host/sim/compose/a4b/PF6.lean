import host.sim.compose.a4b.PF6Heap
import host.sim.compose.a4b.PF6Full
import host.sim.compose.a4b.PFVEFresh
import host.sim.compose.a4b.PF6K0
import host.sim.compose.a4b.PF6K1
import host.sim.compose.a4b.PF6K2
import host.sim.compose.a4b.PF6K3
import host.sim.compose.a4b.PF6K4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PF6.facts : Pf.PfFacts PRE_pf_vw.s0 PRE_first_tail_x6_r0_suffix.s8 PRE_pf_vw.S0.tab PRE_first_tail_x6_r0_suffix.S8.tab PFW6.R.data PFW6.R.inv PF6.θ PF6.P0 2825043 [2673467, 2673472, 2673473] where
  num := PF6.num
  heap := by
    intro a h ha hm
    obtain ⟨q, hq, haq⟩ := PRE_pf_vw.cover a h ha (fun hf => hm (by rw [PRE_pf_vw.frames_eq] at hf; simpa using hf))
    have he := PFW6.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PF6.fixP
  getP := PF6.getP
  kindP := PF6.kindP
  imgP := PF6.imgP
  emptyP := PF6.emptyP
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pf_vw.allPresent PF6.ND.all PF6.ndFramed a ha
    unfold PF6.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PF6.n0
  n1 := PF6.n1
  grows := Nat.le_of_ble_eq_true PF6.grows
  ren := PF6.ren
  bound := PRE_pf_vw.presentBound
  ctl := PF6.ctl
  stack := PF6.stack
  jobs := PF6.jobs
  stores := PF6.stores
  heapSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.heapSupp
  ctlSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.1
  stackSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.1
  jobsSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.2.2
  band := PF6.band
  nh0 := Nat.le_of_ble_eq_true PF6.nh0le
  intr := by
    intro a ha
    have := PF6.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pf_vw.tab_len]; exact PF6.fullShift
  inactive := PF6.inactive
  raised := .inr ⟨19057, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx = true
    rw [PRE_pf_vw.hnext]
    exact PRE_pf_vw.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pf_vw.s0.trace PRE_pf_vw.s0
    rw [PRE_pf_vw.hnext]
    exact PRE_pf_vw.noBigFresh
  loLe := Nat.le_of_ble_eq_true PF6.lo
  hi0 := Nat.le_of_ble_eq_true PF6.hi0
  nhi0 := Nat.le_of_ble_eq_true PF6.nhi0
  hi1 := Nat.le_of_ble_eq_true PF6.hi1
  nhi1 := Nat.le_of_ble_eq_true PF6.nhi1
  jsHeap := PRE_pf_vw.jsHeap
  jsRoots := PRE_pf_vw.jsRoots
  jsNative := PRE_pf_vw.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PF6.jsLe) PF6.jsKeys

end Host.Load.Run.Tpl
