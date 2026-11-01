import host.sim.compose.a4b.PF15Heap
import host.sim.compose.a4b.PF15K0
import host.sim.compose.a4b.PF15K1
import host.sim.compose.a4b.PF15K2
import host.sim.compose.a4b.PF15K3
import host.sim.compose.a4b.PF15K4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PF15.facts : Pf.PfFacts PRE_pf_vw.s0 PRE_first_tail_x15_r0_suffix.s8 PRE_pf_vw.S0.tab PRE_first_tail_x15_r0_suffix.S8.tab PFW15.R.data PFW15.R.inv PF15.θ PF15.P0 2825043 [2673467, 2673472, 2673473] where
  num := PF15.num
  heap := by
    intro a h ha hm
    obtain ⟨q, hq, haq⟩ := PRE_pf_vw.cover a h ha (fun hf => hm (by rw [PRE_pf_vw.frames_eq] at hf; simpa using hf))
    have he := PFW15.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PF15.fixP
  getP := PF15.getP
  kindP := PF15.kindP
  imgP := PF15.imgP
  emptyP := PF15.emptyP
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pf_vw.allPresent PF15.ND.all PF15.ndFramed a ha
    unfold PF15.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PF15.n0
  n1 := PF15.n1
  grows := Nat.le_of_ble_eq_true PF15.grows
  ren := PF15.ren
  bound := PRE_pf_vw.presentBound
  ctl := PF15.ctl
  stack := PF15.stack
  jobs := PF15.jobs
  stores := PF15.stores
  heapSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.heapSupp
  ctlSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.1
  stackSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.1
  jobsSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.2.2
  band := PF15.band
  nh0 := Nat.le_of_ble_eq_true PF15.nh0le
  intr := by
    intro a ha
    have := PF15.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pf_vw.tab_len]; exact PF15.fullShift
  inactive := PF15.inactive
  raised := .inr ⟨19057, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx = true
    rw [PRE_pf_vw.hnext]
    exact PRE_pf_vw.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pf_vw.s0.trace PRE_pf_vw.s0
    rw [PRE_pf_vw.hnext]
    exact PRE_pf_vw.noBigFresh
  loLe := Nat.le_of_ble_eq_true PF15.lo
  hi0 := Nat.le_of_ble_eq_true PF15.hi0
  nhi0 := Nat.le_of_ble_eq_true PF15.nhi0
  hi1 := Nat.le_of_ble_eq_true PF15.hi1
  nhi1 := Nat.le_of_ble_eq_true PF15.nhi1
  jsHeap := PRE_pf_vw.jsHeap
  jsRoots := PRE_pf_vw.jsRoots
  jsNative := PRE_pf_vw.jsNative
  jsFix := Post.jsFix_of_keys (Nat.le_of_ble_eq_true PF15.jsLe) PF15.jsKeys

end Host.Load.Run.Tpl
