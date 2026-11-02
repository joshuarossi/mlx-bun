import host.sim.compose.a4b.PLTHeap
import host.sim.compose.a4b.PLTFull
import host.sim.compose.a4b.PLTEFresh
import host.sim.compose.a4b.PLTK0
import host.sim.compose.a4b.PLTK1
import host.sim.compose.a4b.PLTK2
import host.sim.compose.a4b.PLTK3
import host.sim.compose.a4b.PLTK4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PLT.wideAll : ∀ p ∈ wideList, Pf.WideP PLTP.R.data PRE_pl_tail.s0 PRE_pl_common.s1 p.1 p.2 := by
  intro p hp
  simp only [wideList, wideListOf, ghostPf, ghostAddrs, List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact Pf.wideP_memo (by decide) PLT.memoFix PLT.memoGet0 PLT.memoGet1 PLT.memoKind PLT.memoImg
  · exact Pf.wideP_ghost (by decide) PLT.ghostFix1824 PLT.ghostChk1824
  · exact Pf.wideP_ghost (by decide) PLT.ghostFix1834 PLT.ghostChk1834
  · exact Pf.wideP_ghost (by decide) PLT.ghostFix1852 PLT.ghostChk1852
  · exact Pf.wideP_ghost (by decide) PLT.ghostFix1993 PLT.ghostChk1993
  · exact Pf.wideP_ghost (by decide) PLT.ghostFix2001 PLT.ghostChk2001
  · exact Pf.wideP_ghost (by decide) PLT.ghostFix1279 PLT.ghostChk1279
  · exact Pf.wideP_ghost (by decide) PLT.ghostFix1281 PLT.ghostChk1281
  · exact Pf.wideP_ghost (by decide) PLT.ghostFix1958 PLT.ghostChk1958
  · exact Pf.wideP_ghost (by decide) PLT.ghostFix1959 PLT.ghostChk1959
  · exact Pf.wideP_ghost (by decide) PLT.ghostFix4941 PLT.ghostChk4941

theorem PLT.facts : Pf.PfFacts PRE_pl_tail.s0 PRE_pl_common.s1 PRE_pl_tail.S0.tab PLT.tabP PLTP.R.data PLTP.R.inv PLT.θ PLT.P0 2827718 [] [2673479] wideG where
  num := PLT.num
  heap := by
    intro a h ha hm hw
    obtain ⟨q, hq, haq⟩ := PRE_pl_tail.cover a h ha (fun hf => by
      have hf : a ∈ 2665 :: wideList.map Prod.fst := hf
      rcases List.mem_cons.mp hf with h0 | h1
      · exact hm h0
      · exact Pf.lookupW_ne h1 hw)
    have he := PLTP.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PLT.fixP
  getP := PLT.getP
  kindP := PLT.kindP
  imgP := PLT.imgP
  wide a w hw := PLT.wideAll (a, w) (Pf.lookupW_mem hw)
  emptyP := PLT.emptyP
  keepF _ h := nomatch h
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pl_tail.allPresent PLT.ND.all PLT.ndFramed a ha
    unfold PLT.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PLT.n0
  n1 := PLT.n1
  ren := PLT.ren
  bound := PRE_pl_tail.presentBound
  ctl := PLT.ctl
  stack := PLT.stack
  jobs := PLT.jobs
  stores := PLT.stores
  heapSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.heapSupp
  ctlSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.1
  stackSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.1
  jobsSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pl_tail.tab_len]; exact PRE_pl_tail.rootsSupp.2.2.2
  band := PLT.band
  nh0 := Nat.le_of_ble_eq_true PLT.nh0le
  intr := by
    intro a ha
    have := PLT.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pl_tail.tab_len]; exact PLT.fullShift
  inactive := PLT.inactive
  raised := .inr ⟨17777, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx = true
    rw [PRE_pl_tail.hnext]
    exact PRE_pl_tail.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pl_tail.s0.trace PRE_pl_tail.s0
    rw [PRE_pl_tail.hnext]
    exact PRE_pl_tail.noBigFresh
  loLe := Nat.le_of_ble_eq_true PLT.lo
  hi0 := Nat.le_of_ble_eq_true PLT.hi0
  nhi0 := Nat.le_of_ble_eq_true PLT.nhi0
  hi1 := Nat.le_of_ble_eq_true PLT.hi1
  nhi1 := Nat.le_of_ble_eq_true PLT.nhi1
  jsHeap := PRE_pl_tail.jsHeap
  jsRoots := PRE_pl_tail.jsRoots
  jsNative := PRE_pl_tail.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PLT.jsLe) PLT.jsKeys

end Host.Load.Run.Tpl
