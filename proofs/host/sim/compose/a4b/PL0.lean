import host.sim.compose.a4b.PL0Heap
import host.sim.compose.a4b.PL0Full
import host.sim.compose.a4b.PL0EFresh
import host.sim.compose.a4b.PL0K0
import host.sim.compose.a4b.PL0K1
import host.sim.compose.a4b.PL0K2
import host.sim.compose.a4b.PL0K3
import host.sim.compose.a4b.PL0K4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PL0.wideAll : ∀ p ∈ wideListPf, Pf.WideP PLW0.R.data PRE_plx0_entry.s0 PRE_fd_x0_r0_body.s447 p.1 p.2 := by
  intro p hp
  simp only [wideListPf, wideListOf, ghostPf, ghostAddrs, List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl
  · exact Pf.wideP_memo (by decide) PL0.memoFix PL0.memoGet0 PL0.memoGet1 PL0.memoKind PL0.memoImg
  · exact Pf.wideP_ghost (by decide) PL0.ghostFix1824 PL0.ghostChk1824
  · exact Pf.wideP_ghost (by decide) PL0.ghostFix1834 PL0.ghostChk1834
  · exact Pf.wideP_ghost (by decide) PL0.ghostFix1852 PL0.ghostChk1852
  · exact Pf.wideP_ghost (by decide) PL0.ghostFix1993 PL0.ghostChk1993
  · exact Pf.wideP_ghost (by decide) PL0.ghostFix2001 PL0.ghostChk2001

theorem PL0.facts : Pf.PfFacts PRE_plx0_entry.s0 PRE_fd_x0_r0_body.s447 PRE_plx0_entry.S0.tab PL0.tabP PLW0.R.data PLW0.R.inv PL0.θ PL0.P0 2974263 [2826777] [2826782, 2826783] wideGPf where
  num := PL0.num
  heap := by
    intro a h ha hm hw
    obtain ⟨q, hq, haq⟩ := PRE_plx0_entry.cover a h ha (fun hf => by
      have hf : a ∈ 2665 :: wideListPf.map Prod.fst := hf
      rcases List.mem_cons.mp hf with h0 | h1
      · exact hm h0
      · exact Pf.lookupW_ne h1 hw)
    have he := PLW0.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PL0.fixP
  getP := PL0.getP
  kindP := PL0.kindP
  imgP := PL0.imgP
  wide a w hw := PL0.wideAll (a, w) (Pf.lookupW_mem hw)
  emptyP := PL0.emptyP
  keepF a ha := by
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl
    · exact ⟨by decide, PL0.keptNone0, PL0.keptFix0, PL0.keptGet0, PL0.keptKind0, PL0.keptImg0, PL0.keptEmpty0⟩
  notDrop := by
    intro a ha b hb he
    have hc := PRE_plx0_entry.allPresent PL0.ND.all PL0.ndFramed a ha
    unfold PL0.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PL0.n0
  n1 := PL0.n1
  ren := PL0.ren
  bound := PRE_plx0_entry.presentBound
  ctl := PL0.ctl
  stack := PL0.stack
  jobs := PL0.jobs
  stores := PL0.stores
  heapSupp := by rw [PRE_plx0_entry.tab_len]; exact PRE_plx0_entry.heapSupp
  ctlSupp := by rw [PRE_plx0_entry.tab_len]; exact PRE_plx0_entry.rootsSupp.1
  stackSupp := by rw [PRE_plx0_entry.tab_len]; exact PRE_plx0_entry.rootsSupp.2.1
  jobsSupp := by rw [PRE_plx0_entry.tab_len]; exact PRE_plx0_entry.rootsSupp.2.2.1
  storesSupp := by rw [PRE_plx0_entry.tab_len]; exact PRE_plx0_entry.rootsSupp.2.2.2
  band := PL0.band
  nh0 := Nat.le_of_ble_eq_true PL0.nh0le
  intr := by
    intro a ha
    have := PL0.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_plx0_entry.tab_len]; exact PL0.fullShift
  inactive := PL0.inactive
  raised := .inr ⟨20138, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_plx0_entry.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_plx0_entry.s0.ffi).mlx = true
    rw [PRE_plx0_entry.hnext]
    exact PRE_plx0_entry.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_plx0_entry.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_plx0_entry.s0.trace PRE_plx0_entry.s0
    rw [PRE_plx0_entry.hnext]
    exact PRE_plx0_entry.noBigFresh
  loLe := Nat.le_of_ble_eq_true PL0.lo
  hi0 := Nat.le_of_ble_eq_true PL0.hi0
  nhi0 := Nat.le_of_ble_eq_true PL0.nhi0
  hi1 := Nat.le_of_ble_eq_true PL0.hi1
  nhi1 := Nat.le_of_ble_eq_true PL0.nhi1
  jsHeap := PRE_plx0_entry.jsHeap
  jsRoots := PRE_plx0_entry.jsRoots
  jsNative := PRE_plx0_entry.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PL0.jsLe) PL0.jsKeys

end Host.Load.Run.Tpl
