import host.sim.compose.a4b.PF8Heap
import host.sim.compose.a4b.PF8Full
import host.sim.compose.a4b.PF15EFresh
import host.sim.compose.a4b.PF8K0
import host.sim.compose.a4b.PF8K1
import host.sim.compose.a4b.PF8K2
import host.sim.compose.a4b.PF8K3
import host.sim.compose.a4b.PF8K4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PF8.wideAll : ∀ p ∈ wideListPf, Pf.WideP PFW8.R.data PRE_pf_vw.s0 PRE_first_tail_x8_r0_suffix.s8 p.1 p.2 := by
  intro p hp
  simp only [wideListPf, wideListOf, ghostPf, ghostAddrs, List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl
  · exact Pf.wideP_memo (by decide) PF8.memoFix PF8.memoGet0 PF8.memoGet1 PF8.memoKind PF8.memoImg
  · exact Pf.wideP_ghost (by decide) PF8.ghostFix1824 PF8.ghostChk1824
  · exact Pf.wideP_ghost (by decide) PF8.ghostFix1834 PF8.ghostChk1834
  · exact Pf.wideP_ghost (by decide) PF8.ghostFix1852 PF8.ghostChk1852
  · exact Pf.wideP_ghost (by decide) PF8.ghostFix1993 PF8.ghostChk1993
  · exact Pf.wideP_ghost (by decide) PF8.ghostFix2001 PF8.ghostChk2001

theorem PF8.facts : Pf.PfFacts PRE_pf_vw.s0 PRE_first_tail_x8_r0_suffix.s8 PRE_pf_vw.S0.tab PF8.tabP PFW8.R.data PFW8.R.inv PF8.θ PF8.P0 2823887 [2673467, 2673472, 2673473] wideGPf where
  num := PF8.num
  heap := by
    intro a h ha hm hw
    obtain ⟨q, hq, haq⟩ := PRE_pf_vw.cover a h ha (fun hf => by
      have hf : a ∈ 2665 :: wideListPf.map Prod.fst := hf
      rcases List.mem_cons.mp hf with h0 | h1
      · exact hm h0
      · exact Pf.lookupW_ne h1 hw)
    have he := PFW8.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PF8.fixP
  getP := PF8.getP
  kindP := PF8.kindP
  imgP := PF8.imgP
  wide a w hw := PF8.wideAll (a, w) (Pf.lookupW_mem hw)
  emptyP := PF8.emptyP
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pf_vw.allPresent PF8.ND.all PF8.ndFramed a ha
    unfold PF8.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PF8.n0
  n1 := PF8.n1
  ren := PF8.ren
  bound := PRE_pf_vw.presentBound
  ctl := PF8.ctl
  stack := PF8.stack
  jobs := PF8.jobs
  stores := PF8.stores
  heapSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.heapSupp
  ctlSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.1
  stackSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.1
  jobsSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pf_vw.tab_len]; exact PRE_pf_vw.rootsSupp.2.2.2
  band := PF8.band
  nh0 := Nat.le_of_ble_eq_true PF8.nh0le
  intr := by
    intro a ha
    have := PF8.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pf_vw.tab_len]; exact PF8.fullShift
  inactive := PF8.inactive
  raised := .inr ⟨19057, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx = true
    rw [PRE_pf_vw.hnext]
    exact PRE_pf_vw.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pf_vw.s0.trace PRE_pf_vw.s0
    rw [PRE_pf_vw.hnext]
    exact PRE_pf_vw.noBigFresh
  loLe := Nat.le_of_ble_eq_true PF8.lo
  hi0 := Nat.le_of_ble_eq_true PF8.hi0
  nhi0 := Nat.le_of_ble_eq_true PF8.nhi0
  hi1 := Nat.le_of_ble_eq_true PF8.hi1
  nhi1 := Nat.le_of_ble_eq_true PF8.nhi1
  jsHeap := PRE_pf_vw.jsHeap
  jsRoots := PRE_pf_vw.jsRoots
  jsNative := PRE_pf_vw.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PF8.jsLe) PF8.jsKeys

end Host.Load.Run.Tpl
