import host.sim.compose.a4b.PF0Heap
import host.sim.compose.a4b.PF0Full
import host.sim.compose.a4b.PF0EFresh
import host.sim.compose.a4b.PF0K0
import host.sim.compose.a4b.PF0K1
import host.sim.compose.a4b.PF0K2
import host.sim.compose.a4b.PF0K3
import host.sim.compose.a4b.PF0K4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PF0.wideAll : ∀ p ∈ wideListPf, Pf.WideP PFW0.R.data PRE_pf_x0.s0 PRE_first_tail_x0_r0_suffix.s8 p.1 p.2 := by
  intro p hp
  simp only [wideListPf, wideListOf, ghostPf, ghostAddrs, List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl
  · exact Pf.wideP_memo (by decide) PF0.memoFix PF0.memoGet0 PF0.memoGet1 PF0.memoKind PF0.memoImg
  · exact Pf.wideP_ghost (by decide) PF0.ghostFix1824 PF0.ghostChk1824
  · exact Pf.wideP_ghost (by decide) PF0.ghostFix1834 PF0.ghostChk1834
  · exact Pf.wideP_ghost (by decide) PF0.ghostFix1852 PF0.ghostChk1852
  · exact Pf.wideP_ghost (by decide) PF0.ghostFix1993 PF0.ghostChk1993
  · exact Pf.wideP_ghost (by decide) PF0.ghostFix2001 PF0.ghostChk2001

theorem PF0.facts : Pf.PfFacts PRE_pf_x0.s0 PRE_first_tail_x0_r0_suffix.s8 PRE_pf_x0.S0.tab PF0.tabP PFW0.R.data PFW0.R.inv PF0.θ PF0.P0 2826767 [] [2673467, 2673472, 2673473] wideGPf where
  num := PF0.num
  heap := by
    intro a h ha hm hw
    obtain ⟨q, hq, haq⟩ := PRE_pf_x0.cover a h ha (fun hf => by
      have hf : a ∈ 2665 :: wideListPf.map Prod.fst := hf
      rcases List.mem_cons.mp hf with h0 | h1
      · exact hm h0
      · exact Pf.lookupW_ne h1 hw)
    have he := PFW0.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PF0.fixP
  getP := PF0.getP
  kindP := PF0.kindP
  imgP := PF0.imgP
  wide a w hw := PF0.wideAll (a, w) (Pf.lookupW_mem hw)
  emptyP := PF0.emptyP
  keepF _ h := nomatch h
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pf_x0.allPresent PF0.ND.all PF0.ndFramed a ha
    unfold PF0.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PF0.n0
  n1 := PF0.n1
  ren := PF0.ren
  bound := PRE_pf_x0.presentBound
  ctl := PF0.ctl
  stack := PF0.stack
  jobs := PF0.jobs
  stores := PF0.stores
  heapSupp := by rw [PRE_pf_x0.tab_len]; exact PRE_pf_x0.heapSupp
  ctlSupp := by rw [PRE_pf_x0.tab_len]; exact PRE_pf_x0.rootsSupp.1
  stackSupp := by rw [PRE_pf_x0.tab_len]; exact PRE_pf_x0.rootsSupp.2.1
  jobsSupp := by rw [PRE_pf_x0.tab_len]; exact PRE_pf_x0.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pf_x0.tab_len]; exact PRE_pf_x0.rootsSupp.2.2.2
  band := PF0.band
  nh0 := Nat.le_of_ble_eq_true PF0.nh0le
  intr := by
    intro a ha
    have := PF0.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pf_x0.tab_len]; exact PF0.fullShift
  inactive := PF0.inactive
  raised := .inr ⟨17764, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pf_x0.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pf_x0.s0.ffi).mlx = true
    rw [PRE_pf_x0.hnext]
    exact PRE_pf_x0.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pf_x0.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pf_x0.s0.trace PRE_pf_x0.s0
    rw [PRE_pf_x0.hnext]
    exact PRE_pf_x0.noBigFresh
  loLe := Nat.le_of_ble_eq_true PF0.lo
  hi0 := Nat.le_of_ble_eq_true PF0.hi0
  nhi0 := Nat.le_of_ble_eq_true PF0.nhi0
  hi1 := Nat.le_of_ble_eq_true PF0.hi1
  nhi1 := Nat.le_of_ble_eq_true PF0.nhi1
  jsHeap := PRE_pf_x0.jsHeap
  jsRoots := PRE_pf_x0.jsRoots
  jsNative := PRE_pf_x0.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PF0.jsLe) PF0.jsKeys

end Host.Load.Run.Tpl
