import host.sim.compose.a4b.PLT0Heap
import host.sim.compose.a4b.PLT0Full
import host.sim.compose.a4b.PLTEFresh
import host.sim.compose.a4b.PLT0K0
import host.sim.compose.a4b.PLT0K1
import host.sim.compose.a4b.PLT0K2
import host.sim.compose.a4b.PLT0K3
import host.sim.compose.a4b.PLT0K4
import host.sim.compose.PostLinkT
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PLT0.wideAll : ∀ p ∈ wideList, Pf.WideP PLTW0.R.data PRE_pl_tail.s0 PRE_plx0_common.s1 p.1 p.2 := by
  intro p hp
  simp only [wideList, wideListOf, ghostPf, ghostAddrs, List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact Pf.wideP_memo (by decide) PLT0.memoFix PLT0.memoGet0 PLT0.memoGet1 PLT0.memoKind PLT0.memoImg
  · exact Pf.wideP_ghost (by decide) PLT0.ghostFix1824 PLT0.ghostChk1824
  · exact Pf.wideP_ghost (by decide) PLT0.ghostFix1834 PLT0.ghostChk1834
  · exact Pf.wideP_ghost (by decide) PLT0.ghostFix1852 PLT0.ghostChk1852
  · exact Pf.wideP_ghost (by decide) PLT0.ghostFix1993 PLT0.ghostChk1993
  · exact Pf.wideP_ghost (by decide) PLT0.ghostFix2001 PLT0.ghostChk2001
  · exact Pf.wideP_ghost (by decide) PLT0.ghostFix1279 PLT0.ghostChk1279
  · exact Pf.wideP_ghost (by decide) PLT0.ghostFix1281 PLT0.ghostChk1281
  · exact Pf.wideP_ghost (by decide) PLT0.ghostFix1958 PLT0.ghostChk1958
  · exact Pf.wideP_ghost (by decide) PLT0.ghostFix1959 PLT0.ghostChk1959
  · exact Pf.wideP_ghost (by decide) PLT0.ghostFix4941 PLT0.ghostChk4941

theorem PLT0.facts : Post.PfFactsT 15235 PRE_pl_tail.s0 PRE_plx0_common.s1 PRE_pl_tail.S0.tab PLT0.tabP PLTW0.R.data PLTW0.R.inv PLT0.θ PLT0.P0 2673649 [] [2826777] wideG where
  num := PLT0.num
  heap := by
    intro a h ha hm hw
    obtain ⟨q, hq, haq⟩ := PRE_pl_tail.cover a h ha (fun hf => by
      have hf : a ∈ 2665 :: wideList.map Prod.fst := hf
      rcases List.mem_cons.mp hf with h0 | h1
      · exact hm h0
      · exact Pf.lookupW_ne h1 hw)
    have he := PLTW0.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PLT0.fixP
  getP := PLT0.getP
  kindP := PLT0.kindP
  imgP := PLT0.imgP
  wide a w hw := PLT0.wideAll (a, w) (Pf.lookupW_mem hw)
  emptyP := PLT0.emptyP
  keepF _ h := nomatch h
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pl_tail.allPresent PLT0.ND.all PLT0.ndFramed a ha
    unfold PLT0.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PLT0.n0
  n1 := PLT0.n1
  ren := PLT0.ren
  bound := PRE_pl_tail.presentBound
  ctl := PLT0.ctl
  stack := PLT0.stack
  jobs := PLT0.jobs
  stores := PLT0.stores
  heapSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.heapSupp
  ctlSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.1
  stackSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.1
  jobsSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.2.2
  band := PLT0.band
  nh0 := Nat.le_of_ble_eq_true PLT0.nh0le
  intr := by
    intro a ha
    have := PLT0.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pl_tail.tab_len]; exact PLT0.fullShift
  inactive := PLT0.inactive
  raised := .inr ⟨17777, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx = true
    rw [PRE_pl_tail.hnext]
    exact PRE_pl_tail.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pl_tail.s0.trace PRE_pl_tail.s0
    rw [PRE_pl_tail.hnext]
    exact PRE_pl_tail.noBigFresh
  loLe := Nat.le_of_ble_eq_true PLT0.lo
  hi0 := Nat.le_of_ble_eq_true PLT0.hi0
  nhi0 := Nat.le_of_ble_eq_true PLT0.nhi0
  hi1 := Nat.le_of_ble_eq_true PLT0.hi1
  nhi1 := Nat.le_of_ble_eq_true PLT0.nhi1
  jsHeap := PRE_pl_tail.jsHeap
  jsRoots := PRE_pl_tail.jsRoots
  jsNative := PRE_pl_tail.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PLT0.jsLe) PLT0.jsKeys

end Host.Load.Run.Tpl
