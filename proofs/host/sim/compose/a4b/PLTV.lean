import host.sim.compose.a4b.PLTVHeap
import host.sim.compose.a4b.PLTVFull
import host.sim.compose.a4b.PLTEFresh
import host.sim.compose.a4b.PLTVK0
import host.sim.compose.a4b.PLTVK1
import host.sim.compose.a4b.PLTVK2
import host.sim.compose.a4b.PLTVK3
import host.sim.compose.a4b.PLTVK4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PLTV.facts : Pf.PfFacts PRE_pl_tail.s0 PRE_plvw_common.s4 PRE_pl_tail.S0.tab PRE_plvw_common.S4.tab PLTailVW.R.data PLTailVW.R.inv PLTV.θ PLTV.P0 2827718 [ ] where
  num := PLTV.num
  heap := by
    intro a h ha hm
    obtain ⟨q, hq, haq⟩ := PRE_pl_tail.cover a h ha (fun hf => hm (by rw [PRE_pl_tail.frames_eq] at hf; simpa using hf))
    have he := PLTailVW.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PLTV.fixP
  getP := PLTV.getP
  kindP := PLTV.kindP
  imgP := PLTV.imgP
  emptyP := PLTV.emptyP
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pl_tail.allPresent PLTV.ND.all PLTV.ndFramed a ha
    unfold PLTV.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PLTV.n0
  n1 := PLTV.n1
  grows := Nat.le_of_ble_eq_true PLTV.grows
  ren := PLTV.ren
  bound := PRE_pl_tail.presentBound
  ctl := PLTV.ctl
  stack := PLTV.stack
  jobs := PLTV.jobs
  stores := PLTV.stores
  heapSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.heapSupp
  ctlSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.1
  stackSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.1
  jobsSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.2.2
  band := PLTV.band
  nh0 := Nat.le_of_ble_eq_true PLTV.nh0le
  intr := by
    intro a ha
    have := PLTV.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pl_tail.tab_len]; exact PLTV.fullShift
  inactive := PLTV.inactive
  raised := .inr ⟨17777, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx = true
    rw [PRE_pl_tail.hnext]
    exact PRE_pl_tail.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pl_tail.s0.trace PRE_pl_tail.s0
    rw [PRE_pl_tail.hnext]
    exact PRE_pl_tail.noBigFresh
  loLe := Nat.le_of_ble_eq_true PLTV.lo
  hi0 := Nat.le_of_ble_eq_true PLTV.hi0
  nhi0 := Nat.le_of_ble_eq_true PLTV.nhi0
  hi1 := Nat.le_of_ble_eq_true PLTV.hi1
  nhi1 := Nat.le_of_ble_eq_true PLTV.nhi1
  jsHeap := PRE_pl_tail.jsHeap
  jsRoots := PRE_pl_tail.jsRoots
  jsNative := PRE_pl_tail.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PLTV.jsLe) PLTV.jsKeys

end Host.Load.Run.Tpl
