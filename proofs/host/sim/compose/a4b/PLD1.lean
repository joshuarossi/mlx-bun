import host.sim.compose.a4b.PLD1Heap
import host.sim.compose.a4b.PLD1Full
import host.sim.compose.a4b.PLEntryFresh
import host.sim.compose.a4b.PLD1K0
import host.sim.compose.a4b.PLD1K1
import host.sim.compose.a4b.PLD1K2
import host.sim.compose.a4b.PLD1K3
import host.sim.compose.a4b.PLD1K4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem PLD1.wideAll : ∀ p ∈ wideListPf, Pf.WideP PLWalkD1.R.data PRE_pl_entry.s0 D1Body.s155 p.1 p.2 := by
  intro p hp
  simp only [wideListPf, wideListOf, ghostPf, ghostAddrs, List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl
  · exact Pf.wideP_memo (by decide) PLD1.memoFix PLD1.memoGet0 PLD1.memoGet1 PLD1.memoKind PLD1.memoImg
  · exact Pf.wideP_ghost (by decide) PLD1.ghostFix1824 PLD1.ghostChk1824
  · exact Pf.wideP_ghost (by decide) PLD1.ghostFix1834 PLD1.ghostChk1834
  · exact Pf.wideP_ghost (by decide) PLD1.ghostFix1852 PLD1.ghostChk1852
  · exact Pf.wideP_ghost (by decide) PLD1.ghostFix1993 PLD1.ghostChk1993
  · exact Pf.wideP_ghost (by decide) PLD1.ghostFix2001 PLD1.ghostChk2001

theorem PLD1.facts : Pf.PfFacts PRE_pl_entry.s0 D1Body.s155 PRE_pl_entry.S0.tab D1Body.S155.tab PLWalkD1.R.data PLWalkD1.R.inv PLD1.θ PLD1.P0 2826779 [D1Frames.chunk, D1Frames.buffer, D1Frames.view] wideGPf where
  num := PLD1.num
  heap := by
    intro a h ha hm hw
    obtain ⟨q, hq, haq⟩ := PRE_pl_entry.cover a h ha (fun hf => by
      have hf : a ∈ 2665 :: wideListPf.map Prod.fst := hf
      rcases List.mem_cons.mp hf with h0 | h1
      · exact hm h0
      · exact Pf.lookupW_ne h1 hw)
    have he := PLWalkD1.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PLD1.fixP
  getP := PLD1.getP
  kindP := PLD1.kindP
  imgP := PLD1.imgP
  wide a w hw := PLD1.wideAll (a, w) (Pf.lookupW_mem hw)
  emptyP := PLD1.emptyP
  notDrop := by
    intro a ha b hb he
    have hc := PRE_pl_entry.allPresent PLD1.ND.all PLD1.ndFramed a ha
    unfold PLD1.ndAt at hc
    have h2 := List.all_eq_true.mp hc b hb
    rw [he] at h2
    simp at h2
  n0 := PLD1.n0
  n1 := PLD1.n1
  ren := PLD1.ren
  bound := PRE_pl_entry.presentBound
  ctl := PLD1.ctl
  stack := PLD1.stack
  jobs := PLD1.jobs
  stores := PLD1.stores
  heapSupp := by rw [PRE_pl_entry.tab_len]; exact PRE_pl_entry.heapSupp
  ctlSupp := by rw [PRE_pl_entry.tab_len]; exact PRE_pl_entry.rootsSupp.1
  stackSupp := by rw [PRE_pl_entry.tab_len]; exact PRE_pl_entry.rootsSupp.2.1
  jobsSupp := by rw [PRE_pl_entry.tab_len]; exact PRE_pl_entry.rootsSupp.2.2.1
  storesSupp := by rw [PRE_pl_entry.tab_len]; exact PRE_pl_entry.rootsSupp.2.2.2
  band := PLD1.band
  nh0 := Nat.le_of_ble_eq_true PLD1.nh0le
  intr := by
    intro a ha
    have := PLD1.intr
    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this
    exact this a ha
  shift := by rw [PRE_pl_entry.tab_len]; exact PLD1.fullShift
  inactive := PLD1.inactive
  raised := .inr ⟨17764, rfl, by decide, rfl⟩
  bigs := by
    change bigsOutB (Host.Load.Layers.toLoad PRE_pl_entry.s0.ffi).mlx.next 131072 (Host.Load.Layers.toLoad PRE_pl_entry.s0.ffi).mlx = true
    rw [PRE_pl_entry.hnext]
    exact PRE_pl_entry.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Load.Layers.toLoad PRE_pl_entry.s0.ffi).mlx.next : Int) ≤ i ∧ i < 131072) PRE_pl_entry.s0.trace PRE_pl_entry.s0
    rw [PRE_pl_entry.hnext]
    exact PRE_pl_entry.noBigFresh
  loLe := Nat.le_of_ble_eq_true PLD1.lo
  hi0 := Nat.le_of_ble_eq_true PLD1.hi0
  nhi0 := Nat.le_of_ble_eq_true PLD1.nhi0
  hi1 := Nat.le_of_ble_eq_true PLD1.hi1
  nhi1 := Nat.le_of_ble_eq_true PLD1.nhi1
  jsHeap := PRE_pl_entry.jsHeap
  jsRoots := PRE_pl_entry.jsRoots
  jsNative := PRE_pl_entry.jsNative
  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true PLD1.jsLe) PLD1.jsKeys

end Host.Load.Run.Tpl
