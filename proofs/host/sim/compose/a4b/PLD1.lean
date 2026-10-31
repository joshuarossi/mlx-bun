import host.sim.compose.a4b.PLD1Heap
import host.sim.compose.a4b.PLD1Full
import host.sim.compose.a4b.PLEntryFresh
import host.sim.template.a4pre_d1_body.D4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

noncomputable def PLD1.θ : Nat → SymE := thetaOf PLWalkD1.R.theta
kernel_rfl PLD1.num : checkNum PLWalkD1.R.data.map PLD1.θ ⟨PRE_pl_entry.S0.tab, []⟩ ⟨D1Body.S155.tab, []⟩ = true
kernel_rfl PLD1.fixP : PLWalkD1.R.data.a 2665 = 2665
kernel_rfl PLD1.fixC : PLWalkD1.R.data.a D1Frames.chunk = D1Frames.chunk
kernel_rfl PLD1.fixB : PLWalkD1.R.data.a D1Frames.buffer = D1Frames.buffer
kernel_rfl PLD1.fixV : PLWalkD1.R.data.a D1Frames.view = D1Frames.view
kernel_rfl PLD1.getP : PRE_pl_entry.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pl_entry.s0 2665))
kernel_rfl PLD1.kindP : (Template.objOf PRE_pl_entry.s0 2665).kind = .array []
kernel_rfl PLD1.imgP : D1Body.s155.heap.get 2665 = some (.obj { PLWalkD1.R.data.map.obj (Template.objOf PRE_pl_entry.s0 2665) with kind := .array ([] ++ arrOf D1Body.s155 2665) })
kernel_rfl PLD1.getC : PRE_pl_entry.s0.heap.get D1Frames.chunk = some (.obj (Template.objOf PRE_pl_entry.s0 D1Frames.chunk))
kernel_rfl PLD1.kindC : (Template.objOf PRE_pl_entry.s0 D1Frames.chunk).kind = .array []
kernel_rfl PLD1.imgC : D1Body.s155.heap.get D1Frames.chunk = some (.obj { PLWalkD1.R.data.map.obj (Template.objOf PRE_pl_entry.s0 D1Frames.chunk) with kind := .array ([] ++ arrOf D1Body.s155 D1Frames.chunk) })
kernel_rfl PLD1.getB : (PRE_pl_entry.s0.heap.get D1Frames.buffer).isSome = true
kernel_rfl PLD1.imgB : D1Body.s155.heap.get D1Frames.buffer = (PRE_pl_entry.s0.heap.get D1Frames.buffer).map PLWalkD1.R.data.map.hobj
kernel_rfl PLD1.getV : (PRE_pl_entry.s0.heap.get D1Frames.view).isSome = true
kernel_rfl PLD1.imgV : D1Body.s155.heap.get D1Frames.view = (PRE_pl_entry.s0.heap.get D1Frames.view).map PLWalkD1.R.data.map.hobj
kernel_rfl PLD1.framesEmpty : [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view].all (fun a => (arrOf D1Body.s155 a).isEmpty) = true
kernel_rfl PLD1.n0 : PLWalkD1.R.data.n0 = PRE_pl_entry.s0.next
kernel_rfl PLD1.n1 : PLWalkD1.R.data.n1 = D1Body.s155.next
kernel_rfl PLD1.grows : Nat.ble PRE_pl_entry.s0.next D1Body.s155.next = true
kernel_rfl PLD1.ren : checkRen PRE_pl_entry.s0 PLWalkD1.R.data PLWalkD1.R.inv = true
kernel_rfl PLD1.ctl : D1Body.s155.ctl = PLWalkD1.R.data.map.ctl PRE_pl_entry.s0.ctl
kernel_rfl PLD1.stack : D1Body.s155.stack = PRE_pl_entry.s0.stack.map PLWalkD1.R.data.map.frame
kernel_rfl PLD1.jobs : D1Body.s155.jobs = PRE_pl_entry.s0.jobs.map PLWalkD1.R.data.map.job
kernel_rfl PLD1.stores : D1Body.s155.stores = PLWalkD1.R.data.map.stores PRE_pl_entry.s0.stores
kernel_rfl PLD1.band : PLWalkD1.R.data.checkBand 18151 = true
kernel_rfl PLD1.nh0le : Nat.ble 18151 PLWalkD1.R.data.nh0 = true
kernel_rfl PLD1.intr : (List.range 40).all (fun a => Nat.beq (PLWalkD1.R.data.a a) a) = true
kernel_rfl PLD1.inactive : (bridgeOf PRE_pl_entry.s0.ffi).active = false
kernel_rfl PLD1.lo : Nat.ble 18151 (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi).next = true
kernel_rfl PLD1.hi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi).next setupP.E = true
kernel_rfl PLD1.nhi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi).nnext setupP.NE = true
kernel_rfl PLD1.hi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf D1Body.s155.ffi).next setupP.E = true
kernel_rfl PLD1.nhi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf D1Body.s155.ffi).nnext setupP.NE = true
kernel_rfl PLD1.jsKeys : (PTrie.keys PLWalkD1.R.data.heap).all (Nat.ble 2826779) = true
kernel_rfl PLD1.jsLe : Nat.ble 2826779 PLWalkD1.R.data.n0 = true

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
    change bigsOutB (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi).next 131072 (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi) = true
    rw [PRE_pl_entry.hnext]
    exact PRE_pl_entry.nativeFresh
  free := by
    change NoBigSt (fun i => ((Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi).next : Int) ≤ i ∧ i < 131072) PRE_pl_entry.s0.trace PRE_pl_entry.s0
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
