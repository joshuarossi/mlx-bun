import host.sim.compose.a4b.PF4L9Heap
import host.sim.compose.a4b.PF4L9Full
import host.sim.compose.a4b.PF4L9EFresh
import host.sim.compose.a4b.PF4L9K0
import host.sim.compose.a4b.PF4L9K1
import host.sim.compose.a4b.PF4L9K2
import host.sim.compose.a4b.PF4L9K3
import host.sim.compose.a4b.PF4L9K4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PF4L9.wideAll : ∀ p ∈ wideListPf, Pf.WideP PFW4L9.R.data PRE_pf_x4_L9.s0 PRE_first_tail_x4_L9_r0_suffix.s8 p.1 p.2 := by
  intro p hp
  simp only [wideListPf, wideListOf, ghostPf, ghostAddrs, List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl
  · exact Pf.wideP_memo (by decide) PF4L9.memoFix PF4L9.memoGet0 PF4L9.memoGet1 PF4L9.memoKind PF4L9.memoImg
  · exact Pf.wideP_ghost (by decide) PF4L9.ghostFix1824 PF4L9.ghostChk1824
  · exact Pf.wideP_ghost (by decide) PF4L9.ghostFix1834 PF4L9.ghostChk1834
  · exact Pf.wideP_ghost (by decide) PF4L9.ghostFix1852 PF4L9.ghostChk1852
  · exact Pf.wideP_ghost (by decide) PF4L9.ghostFix1993 PF4L9.ghostChk1993
  · exact Pf.wideP_ghost (by decide) PF4L9.ghostFix2001 PF4L9.ghostChk2001

theorem PF4L9.facts : Pf.PfFacts PRE_pf_x4_L9.s0 PRE_first_tail_x4_L9_r0_suffix.s8 PRE_pf_x4_L9.S0.tab PF4L9.tabP PFW4L9.R.data PFW4L9.R.inv PF4L9.θ PF4L9.P0 2834721 [] [2673467, 2673472, 2673473] wideGPf where
  num := PF4L9.num
  heap := by
    intro a h ha hm hw
    obtain ⟨q, hq, haq⟩ := PRE_pf_x4_L9.cover a h ha (fun hf => by
      have hf : a ∈ 2665 :: wideListPf.map Prod.fst := hf
      rcases List.mem_cons.mp hf with h0 | h1
      · exact hm h0
      · exact Pf.lookupW_ne h1 hw)
    have he := PFW4L9.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PF4L9.fixP
  getP := PF4L9.getP
  kindP := PF4L9.kindP
  imgP := PF4L9.imgP
  wide a w hw := PF4L9.wideAll (a, w) (Pf.lookupW_mem hw)
  emptyP := PF4L9.emptyP
  keepF _ h := nomatch h
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pf_x4_L9.allPresent PF4L9.ND.all PF4L9.ndFramed a ha
    unfold PF4L9.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PF4L9.n0
  n1 := PF4L9.n1
  ren := PF4L9.ren
  bound := PRE_pf_x4_L9.presentBound
  ctl := PF4L9.ctl
  stack := PF4L9.stack
  jobs := PF4L9.jobs
  stores := PF4L9.stores
  heapSupp := by rw [PRE_pf_x4_L9.tab_len]; exact PRE_pf_x4_L9.heapSupp
  ctlSupp := by rw [PRE_pf_x4_L9.tab_len]; exact PRE_pf_x4_L9.rootsSupp.1
  stackSupp := by rw [PRE_pf_x4_L9.tab_len]; exact PRE_pf_x4_L9.rootsSupp.2.1
  jobsSupp := by rw [PRE_pf_x4_L9.tab_len]; exact PRE_pf_x4_L9.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pf_x4_L9.tab_len]; exact PRE_pf_x4_L9.rootsSupp.2.2.2
  band := PF4L9.band
  nh0 := Nat.le_of_ble_eq_true PF4L9.nh0le
  intr := by
    intro a ha
    have := PF4L9.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pf_x4_L9.tab_len]; exact PF4L9.fullShift
  inactive := PF4L9.inactive
  raised := .inr ⟨19265, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pf_x4_L9.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pf_x4_L9.s0.ffi).mlx = true
    rw [PRE_pf_x4_L9.hnext]
    exact PRE_pf_x4_L9.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pf_x4_L9.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pf_x4_L9.s0.trace PRE_pf_x4_L9.s0
    rw [PRE_pf_x4_L9.hnext]
    exact PRE_pf_x4_L9.noBigFresh
  loLe := Nat.le_of_ble_eq_true PF4L9.lo
  hi0 := Nat.le_of_ble_eq_true PF4L9.hi0
  nhi0 := Nat.le_of_ble_eq_true PF4L9.nhi0
  hi1 := Nat.le_of_ble_eq_true PF4L9.hi1
  nhi1 := Nat.le_of_ble_eq_true PF4L9.nhi1
  jsHeap := PRE_pf_x4_L9.jsHeap
  jsRoots := PRE_pf_x4_L9.jsRoots
  jsNative := PRE_pf_x4_L9.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PF4L9.jsLe) PF4L9.jsKeys

end Host.Load.Run.Tpl
