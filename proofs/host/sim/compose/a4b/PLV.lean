import host.sim.compose.a4b.PLVHeap
import host.sim.compose.a4b.PLVFull
import host.sim.compose.a4b.PLVEFresh
import host.sim.compose.a4b.PLVK0
import host.sim.compose.a4b.PLVK1
import host.sim.compose.a4b.PLVK2
import host.sim.compose.a4b.PLVK3
import host.sim.compose.a4b.PLVK4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PLV.wideAll : ∀ p ∈ wideListPf, Pf.WideP PLVW.R.data PRE_plvw_entry.s0 PRE_fd_vw_r0_body.s900 p.1 p.2 := by
  intro p hp
  simp only [wideListPf, wideListOf, ghostPf, ghostAddrs, List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl
  · exact Pf.wideP_memo (by decide) PLV.memoFix PLV.memoGet0 PLV.memoGet1 PLV.memoKind PLV.memoImg
  · exact Pf.wideP_ghost (by decide) PLV.ghostFix1824 PLV.ghostChk1824
  · exact Pf.wideP_ghost (by decide) PLV.ghostFix1834 PLV.ghostChk1834
  · exact Pf.wideP_ghost (by decide) PLV.ghostFix1852 PLV.ghostChk1852
  · exact Pf.wideP_ghost (by decide) PLV.ghostFix1993 PLV.ghostChk1993
  · exact Pf.wideP_ghost (by decide) PLV.ghostFix2001 PLV.ghostChk2001

theorem PLV.facts : Pf.PfFacts PRE_plvw_entry.s0 PRE_fd_vw_r0_body.s900 PRE_plvw_entry.S0.tab PLV.tabP PLVW.R.data PLVW.R.inv PLV.θ PLV.P0 2972768 [2823901] [2823906, 2823907] wideGPf where
  num := PLV.num
  heap := by
    intro a h ha hm hw
    obtain ⟨q, hq, haq⟩ := PRE_plvw_entry.cover a h ha (fun hf => by
      have hf : a ∈ 2665 :: wideListPf.map Prod.fst := hf
      rcases List.mem_cons.mp hf with h0 | h1
      · exact hm h0
      · exact Pf.lookupW_ne h1 hw)
    have he := PLVW.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PLV.fixP
  getP := PLV.getP
  kindP := PLV.kindP
  imgP := PLV.imgP
  wide a w hw := PLV.wideAll (a, w) (Pf.lookupW_mem hw)
  emptyP := PLV.emptyP
  keepF a ha := by
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl
    · exact ⟨by decide, PLV.keptNone0, PLV.keptFix0, PLV.keptGet0, PLV.keptKind0, PLV.keptImg0, PLV.keptEmpty0⟩
  notDrop := by
    intro a ha b hb he
    have hc := PRE_plvw_entry.allPresent PLV.ND.all PLV.ndFramed a ha
    unfold PLV.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PLV.n0
  n1 := PLV.n1
  ren := PLV.ren
  bound := PRE_plvw_entry.presentBound
  ctl := PLV.ctl
  stack := PLV.stack
  jobs := PLV.jobs
  stores := PLV.stores
  heapSupp := by rw [PRE_plvw_entry.tab_len]; exact PRE_plvw_entry.heapSupp
  ctlSupp := by rw [PRE_plvw_entry.tab_len]; exact PRE_plvw_entry.rootsSupp.1
  stackSupp := by rw [PRE_plvw_entry.tab_len]; exact PRE_plvw_entry.rootsSupp.2.1
  jobsSupp := by rw [PRE_plvw_entry.tab_len]; exact PRE_plvw_entry.rootsSupp.2.2.1
  storesSupp := by rw [PRE_plvw_entry.tab_len]; exact PRE_plvw_entry.rootsSupp.2.2.2
  band := PLV.band
  nh0 := Nat.le_of_ble_eq_true PLV.nh0le
  intr := by
    intro a ha
    have := PLV.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_plvw_entry.tab_len]; exact PLV.fullShift
  inactive := PLV.inactive
  raised := .inr ⟨21446, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_plvw_entry.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_plvw_entry.s0.ffi).mlx = true
    rw [PRE_plvw_entry.hnext]
    exact PRE_plvw_entry.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_plvw_entry.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_plvw_entry.s0.trace PRE_plvw_entry.s0
    rw [PRE_plvw_entry.hnext]
    exact PRE_plvw_entry.noBigFresh
  loLe := Nat.le_of_ble_eq_true PLV.lo
  hi0 := Nat.le_of_ble_eq_true PLV.hi0
  nhi0 := Nat.le_of_ble_eq_true PLV.nhi0
  hi1 := Nat.le_of_ble_eq_true PLV.hi1
  nhi1 := Nat.le_of_ble_eq_true PLV.nhi1
  jsHeap := PRE_plvw_entry.jsHeap
  jsRoots := PRE_plvw_entry.jsRoots
  jsNative := PRE_plvw_entry.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PLV.jsLe) PLV.jsKeys

end Host.Load.Run.Tpl
