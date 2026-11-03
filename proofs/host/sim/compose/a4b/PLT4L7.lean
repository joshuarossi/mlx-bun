import host.sim.compose.a4b.PLT4L7Heap
import host.sim.compose.a4b.PLT4L7Full
import host.sim.compose.a4b.PLTEFresh
import host.sim.compose.a4b.PLT4L7K0
import host.sim.compose.a4b.PLT4L7K1
import host.sim.compose.a4b.PLT4L7K2
import host.sim.compose.a4b.PLT4L7K3
import host.sim.compose.a4b.PLT4L7K4
import host.sim.compose.PostLinkT
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PLT4L7.wideAll : ∀ p ∈ wideList, Pf.WideP PLTW4L7.R.data PRE_pl_tail.s0 PRE_plx4_L7_common.s1 p.1 p.2 := by
  intro p hp
  simp only [wideList, wideListOf, ghostPf, ghostAddrs, List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact Pf.wideP_memo (by decide) PLT4L7.memoFix PLT4L7.memoGet0 PLT4L7.memoGet1 PLT4L7.memoKind PLT4L7.memoImg
  · exact Pf.wideP_ghost (by decide) PLT4L7.ghostFix1824 PLT4L7.ghostChk1824
  · exact Pf.wideP_ghost (by decide) PLT4L7.ghostFix1834 PLT4L7.ghostChk1834
  · exact Pf.wideP_ghost (by decide) PLT4L7.ghostFix1852 PLT4L7.ghostChk1852
  · exact Pf.wideP_ghost (by decide) PLT4L7.ghostFix1993 PLT4L7.ghostChk1993
  · exact Pf.wideP_ghost (by decide) PLT4L7.ghostFix2001 PLT4L7.ghostChk2001
  · exact Pf.wideP_ghost (by decide) PLT4L7.ghostFix1279 PLT4L7.ghostChk1279
  · exact Pf.wideP_ghost (by decide) PLT4L7.ghostFix1281 PLT4L7.ghostChk1281
  · exact Pf.wideP_ghost (by decide) PLT4L7.ghostFix1958 PLT4L7.ghostChk1958
  · exact Pf.wideP_ghost (by decide) PLT4L7.ghostFix1959 PLT4L7.ghostChk1959
  · exact Pf.wideP_ghost (by decide) PLT4L7.ghostFix4941 PLT4L7.ghostChk4941

theorem PLT4L7.facts : Post.PfFactsT 15235 PRE_pl_tail.s0 PRE_plx4_L7_common.s1 PRE_pl_tail.S0.tab PLT4L7.tabP PLTW4L7.R.data PLTW4L7.R.inv PLT4L7.θ PLT4L7.P0 2673649 [] [2834123] wideG where
  num := PLT4L7.num
  heap := by
    intro a h ha hm hw
    obtain ⟨q, hq, haq⟩ := PRE_pl_tail.cover a h ha (fun hf => by
      have hf : a ∈ 2665 :: wideList.map Prod.fst := hf
      rcases List.mem_cons.mp hf with h0 | h1
      · exact hm h0
      · exact Pf.lookupW_ne h1 hw)
    have he := PLTW4L7.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PLT4L7.fixP
  getP := PLT4L7.getP
  kindP := PLT4L7.kindP
  imgP := PLT4L7.imgP
  wide a w hw := PLT4L7.wideAll (a, w) (Pf.lookupW_mem hw)
  emptyP := PLT4L7.emptyP
  keepF _ h := nomatch h
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pl_tail.allPresent PLT4L7.ND.all PLT4L7.ndFramed a ha
    unfold PLT4L7.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PLT4L7.n0
  n1 := PLT4L7.n1
  ren := PLT4L7.ren
  bound := PRE_pl_tail.presentBound
  ctl := PLT4L7.ctl
  stack := PLT4L7.stack
  jobs := PLT4L7.jobs
  stores := PLT4L7.stores
  heapSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.heapSupp
  ctlSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.1
  stackSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.1
  jobsSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.2.2
  band := PLT4L7.band
  nh0 := Nat.le_of_ble_eq_true PLT4L7.nh0le
  intr := by
    intro a ha
    have := PLT4L7.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pl_tail.tab_len]; exact PLT4L7.fullShift
  inactive := PLT4L7.inactive
  raised := .inr ⟨17777, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx = true
    rw [PRE_pl_tail.hnext]
    exact PRE_pl_tail.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pl_tail.s0.trace PRE_pl_tail.s0
    rw [PRE_pl_tail.hnext]
    exact PRE_pl_tail.noBigFresh
  loLe := Nat.le_of_ble_eq_true PLT4L7.lo
  hi0 := Nat.le_of_ble_eq_true PLT4L7.hi0
  nhi0 := Nat.le_of_ble_eq_true PLT4L7.nhi0
  hi1 := Nat.le_of_ble_eq_true PLT4L7.hi1
  nhi1 := Nat.le_of_ble_eq_true PLT4L7.nhi1
  jsHeap := PRE_pl_tail.jsHeap
  jsRoots := PRE_pl_tail.jsRoots
  jsNative := PRE_pl_tail.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PLT4L7.jsLe) PLT4L7.jsKeys

end Host.Load.Run.Tpl
