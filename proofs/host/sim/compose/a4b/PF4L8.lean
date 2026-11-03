import host.sim.compose.a4b.PF4L8Heap
import host.sim.compose.a4b.PF4L8Full
import host.sim.compose.a4b.PF4L8EFresh
import host.sim.compose.a4b.PF4L8K0
import host.sim.compose.a4b.PF4L8K1
import host.sim.compose.a4b.PF4L8K2
import host.sim.compose.a4b.PF4L8K3
import host.sim.compose.a4b.PF4L8K4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PF4L8.wideAll : ∀ p ∈ wideListPf, Pf.WideP PFW4L8.R.data PRE_pf_x4_L8.s0 PRE_first_tail_x4_L8_r0_suffix.s8 p.1 p.2 := by
  intro p hp
  simp only [wideListPf, wideListOf, ghostPf, ghostAddrs, List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl
  · exact Pf.wideP_memo (by decide) PF4L8.memoFix PF4L8.memoGet0 PF4L8.memoGet1 PF4L8.memoKind PF4L8.memoImg
  · exact Pf.wideP_ghost (by decide) PF4L8.ghostFix1824 PF4L8.ghostChk1824
  · exact Pf.wideP_ghost (by decide) PF4L8.ghostFix1834 PF4L8.ghostChk1834
  · exact Pf.wideP_ghost (by decide) PF4L8.ghostFix1852 PF4L8.ghostChk1852
  · exact Pf.wideP_ghost (by decide) PF4L8.ghostFix1993 PF4L8.ghostChk1993
  · exact Pf.wideP_ghost (by decide) PF4L8.ghostFix2001 PF4L8.ghostChk2001

theorem PF4L8.facts : Pf.PfFacts PRE_pf_x4_L8.s0 PRE_first_tail_x4_L8_r0_suffix.s8 PRE_pf_x4_L8.S0.tab PF4L8.tabP PFW4L8.R.data PFW4L8.R.inv PF4L8.θ PF4L8.P0 2834417 [] [2673467, 2673472, 2673473] wideGPf where
  num := PF4L8.num
  heap := by
    intro a h ha hm hw
    obtain ⟨q, hq, haq⟩ := PRE_pf_x4_L8.cover a h ha (fun hf => by
      have hf : a ∈ 2665 :: wideListPf.map Prod.fst := hf
      rcases List.mem_cons.mp hf with h0 | h1
      · exact hm h0
      · exact Pf.lookupW_ne h1 hw)
    have he := PFW4L8.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PF4L8.fixP
  getP := PF4L8.getP
  kindP := PF4L8.kindP
  imgP := PF4L8.imgP
  wide a w hw := PF4L8.wideAll (a, w) (Pf.lookupW_mem hw)
  emptyP := PF4L8.emptyP
  keepF _ h := nomatch h
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pf_x4_L8.allPresent PF4L8.ND.all PF4L8.ndFramed a ha
    unfold PF4L8.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PF4L8.n0
  n1 := PF4L8.n1
  ren := PF4L8.ren
  bound := PRE_pf_x4_L8.presentBound
  ctl := PF4L8.ctl
  stack := PF4L8.stack
  jobs := PF4L8.jobs
  stores := PF4L8.stores
  heapSupp := by rw [PRE_pf_x4_L8.tab_len]; exact PRE_pf_x4_L8.heapSupp
  ctlSupp := by rw [PRE_pf_x4_L8.tab_len]; exact PRE_pf_x4_L8.rootsSupp.1
  stackSupp := by rw [PRE_pf_x4_L8.tab_len]; exact PRE_pf_x4_L8.rootsSupp.2.1
  jobsSupp := by rw [PRE_pf_x4_L8.tab_len]; exact PRE_pf_x4_L8.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pf_x4_L8.tab_len]; exact PRE_pf_x4_L8.rootsSupp.2.2.2
  band := PF4L8.band
  nh0 := Nat.le_of_ble_eq_true PF4L8.nh0le
  intr := by
    intro a ha
    have := PF4L8.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pf_x4_L8.tab_len]; exact PF4L8.fullShift
  inactive := PF4L8.inactive
  raised := .inr ⟨19265, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pf_x4_L8.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pf_x4_L8.s0.ffi).mlx = true
    rw [PRE_pf_x4_L8.hnext]
    exact PRE_pf_x4_L8.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pf_x4_L8.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pf_x4_L8.s0.trace PRE_pf_x4_L8.s0
    rw [PRE_pf_x4_L8.hnext]
    exact PRE_pf_x4_L8.noBigFresh
  loLe := Nat.le_of_ble_eq_true PF4L8.lo
  hi0 := Nat.le_of_ble_eq_true PF4L8.hi0
  nhi0 := Nat.le_of_ble_eq_true PF4L8.nhi0
  hi1 := Nat.le_of_ble_eq_true PF4L8.hi1
  nhi1 := Nat.le_of_ble_eq_true PF4L8.nhi1
  jsHeap := PRE_pf_x4_L8.jsHeap
  jsRoots := PRE_pf_x4_L8.jsRoots
  jsNative := PRE_pf_x4_L8.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PF4L8.jsLe) PF4L8.jsKeys

end Host.Load.Run.Tpl
