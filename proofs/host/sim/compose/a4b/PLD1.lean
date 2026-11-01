import host.sim.compose.a4b.PLD1Heap
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

theorem PLD1.facts : Post.LinkFacts PRE_pl_entry.s0 D1Body.s155 PRE_pl_entry.S0.tab D1Body.S155.tab PLWalkD1.R.data PLWalkD1.R.inv PLD1.θ PLD1.P0 2826779 where
  num := PLD1.num
  heap := by
    intro a h ha hm
    obtain ⟨q, hq, haq⟩ := PRE_pl_entry.cover a h ha (fun hf => hm (Post.frames_perm (by rw [PRE_pl_entry.frames_eq] at hf; exact hf)))
    have he := PLWalkD1.R.heapAt q hq a haq
    rw [ha] at he
    exact he
  fixP := PLD1.fixP
  fixC := PLD1.fixC
  fixB := PLD1.fixB
  fixV := PLD1.fixV
  getP := PLD1.getP
  kindP := PLD1.kindP
  imgP := PLD1.imgP
  getC := PLD1.getC
  kindC := PLD1.kindC
  imgC := PLD1.imgC
  getB := PLD1.getB
  imgB := PLD1.imgB
  getV := PLD1.getV
  imgV := PLD1.imgV
  framesEmpty := PLD1.framesEmpty
  n0 := PLD1.n0
  n1 := PLD1.n1
  grows := Nat.le_of_ble_eq_true PLD1.grows
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
  jsFix := Post.jsFix_of_keys (Nat.le_of_ble_eq_true PLD1.jsLe) PLD1.jsKeys

end Host.Load.Run.Tpl
