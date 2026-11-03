import host.sim.compose.a4b.PL4L9Heap
import host.sim.compose.a4b.PL4L9Full
import host.sim.compose.a4b.PL4L9EFresh
import host.sim.compose.a4b.PL4L9K0
import host.sim.compose.a4b.PL4L9K1
import host.sim.compose.a4b.PL4L9K2
import host.sim.compose.a4b.PL4L9K3
import host.sim.compose.a4b.PL4L9K4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PL4L9.wideAll : ∀ p ∈ wideListPf, Pf.WideP PLW4L9.R.data PRE_plx4_L9_entry.s0 PRE_fd_x4_L9_r0_body.s451 p.1 p.2 := by
  intro p hp
  simp only [wideListPf, wideListOf, ghostPf, ghostAddrs, List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl
  · exact Pf.wideP_memo (by decide) PL4L9.memoFix PL4L9.memoGet0 PL4L9.memoGet1 PL4L9.memoKind PL4L9.memoImg
  · exact Pf.wideP_ghost (by decide) PL4L9.ghostFix1824 PL4L9.ghostChk1824
  · exact Pf.wideP_ghost (by decide) PL4L9.ghostFix1834 PL4L9.ghostChk1834
  · exact Pf.wideP_ghost (by decide) PL4L9.ghostFix1852 PL4L9.ghostChk1852
  · exact Pf.wideP_ghost (by decide) PL4L9.ghostFix1993 PL4L9.ghostChk1993
  · exact Pf.wideP_ghost (by decide) PL4L9.ghostFix2001 PL4L9.ghostChk2001

theorem PL4L9.facts : Pf.PfFacts PRE_plx4_L9_entry.s0 PRE_fd_x4_L9_r0_body.s451 PRE_plx4_L9_entry.S0.tab PL4L9.tabP PLW4L9.R.data PLW4L9.R.inv PL4L9.θ PL4L9.P0 2983598 [2834731] [2834736, 2834737] wideGPf where
  num := PL4L9.num
  heap := by
    intro a h ha hm hw
    obtain ⟨q, hq, haq⟩ := PRE_plx4_L9_entry.cover a h ha (fun hf => by
      have hf : a ∈ 2665 :: wideListPf.map Prod.fst := hf
      rcases List.mem_cons.mp hf with h0 | h1
      · exact hm h0
      · exact Pf.lookupW_ne h1 hw)
    have he := PLW4L9.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PL4L9.fixP
  getP := PL4L9.getP
  kindP := PL4L9.kindP
  imgP := PL4L9.imgP
  wide a w hw := PL4L9.wideAll (a, w) (Pf.lookupW_mem hw)
  emptyP := PL4L9.emptyP
  keepF a ha := by
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl
    · exact ⟨by decide, PL4L9.keptNone0, PL4L9.keptFix0, PL4L9.keptGet0, PL4L9.keptKind0, PL4L9.keptImg0, PL4L9.keptEmpty0⟩
  notDrop := by
    intro a ha b hb he
    have hc := PRE_plx4_L9_entry.allPresent PL4L9.ND.all PL4L9.ndFramed a ha
    unfold PL4L9.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PL4L9.n0
  n1 := PL4L9.n1
  ren := PL4L9.ren
  bound := PRE_plx4_L9_entry.presentBound
  ctl := PL4L9.ctl
  stack := PL4L9.stack
  jobs := PL4L9.jobs
  stores := PL4L9.stores
  heapSupp := by rw [PRE_plx4_L9_entry.tab_len]; exact PRE_plx4_L9_entry.heapSupp
  ctlSupp := by rw [PRE_plx4_L9_entry.tab_len]; exact PRE_plx4_L9_entry.rootsSupp.1
  stackSupp := by rw [PRE_plx4_L9_entry.tab_len]; exact PRE_plx4_L9_entry.rootsSupp.2.1
  jobsSupp := by rw [PRE_plx4_L9_entry.tab_len]; exact PRE_plx4_L9_entry.rootsSupp.2.2.1
  storesSupp := by rw [PRE_plx4_L9_entry.tab_len]; exact PRE_plx4_L9_entry.rootsSupp.2.2.2
  band := PL4L9.band
  nh0 := Nat.le_of_ble_eq_true PL4L9.nh0le
  intr := by
    intro a ha
    have := PL4L9.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_plx4_L9_entry.tab_len]; exact PL4L9.fullShift
  inactive := PL4L9.inactive
  raised := .inr ⟨21654, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_plx4_L9_entry.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_plx4_L9_entry.s0.ffi).mlx = true
    rw [PRE_plx4_L9_entry.hnext]
    exact PRE_plx4_L9_entry.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_plx4_L9_entry.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_plx4_L9_entry.s0.trace PRE_plx4_L9_entry.s0
    rw [PRE_plx4_L9_entry.hnext]
    exact PRE_plx4_L9_entry.noBigFresh
  loLe := Nat.le_of_ble_eq_true PL4L9.lo
  hi0 := Nat.le_of_ble_eq_true PL4L9.hi0
  nhi0 := Nat.le_of_ble_eq_true PL4L9.nhi0
  hi1 := Nat.le_of_ble_eq_true PL4L9.hi1
  nhi1 := Nat.le_of_ble_eq_true PL4L9.nhi1
  jsHeap := PRE_plx4_L9_entry.jsHeap
  jsRoots := PRE_plx4_L9_entry.jsRoots
  jsNative := PRE_plx4_L9_entry.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PL4L9.jsLe) PL4L9.jsKeys

end Host.Load.Run.Tpl
