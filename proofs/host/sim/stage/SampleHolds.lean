import host.sim.stage.Mlx
import host.sim.stage.SampleRun
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Ts.Sim.Stage.Sample
open Host.Ts Host.Ts.Sim.Stage

/-! # The sample stage contracts

* **`sample`** (`SamplePost`, classes `cold` and `warm`): for every caller stack, the call returns a fresh
  `{ token, extras: null }` whose `token` is an `MlxArray` of a new live handle `h`; the live-set delta is
  `{h}` allocated, every temporary (the `[1, V]` reshape, the closure's vectors) allocated and freed; no
  existing node changes; the graph (`G`): `h`'s node is the compiled closure's (object 7) replay of the
  normalized argmax — `reshape [1]` of the finish kernel (`normalized_argmax_finish`) over the partial
  kernel's (`normalized_argmax_partial`) two outputs over the logits reshaped to `[1, 248320]` and its
  `logsumexp` (axis 1, kept), the partials `[1, 243]` (`⌈248320/1024⌉` tiles). The cold call also writes
  the module's memo cells (written ranges: the kernel and compiled-function memos) and traces the closure;
  the warm call writes no existing heap entry.
* **dispatch** `ops.asyncEvalAll([token])` (`AsyncPost`): arrays and graph unchanged, the trace gains
  `mlx_vector_array_new_data`, `mlx_async_eval`, `mlx_vector_array_free`, the vector holds the token's node.
* **readback** `ops.itemUint32(token)` (`ReadPost`): returns the first queued token (through the server:
  the readback value `t`), the queue loses it, the token's node records it (`items`), arrays and graph
  unchanged, the trace gains `mlx_array_eval`, `mlx_array_item_uint32`. -/

/-- **`sample`'s postcondition**: written ranges `ws`, handle-table update `es`, token handle `h`, graph `G`. -/
def SamplePost (ws es : List (Nat × Nat)) (h : Int) (G : Host.Mlx.Ffi.St → Prop) (t t' : St Host.Mlx.Ffi.St) : Prop :=
  Framed (F := MF) (fun b => ∃ p ∈ ws, p.1 ≤ b ∧ b < p.2)
      (fun x y => LiveDelta (F := MF) mlxLive (fun h => ∃ m, (h, m) ∈ es ∧ m ≠ 0) (fun h => (h, 0) ∈ es) x y ∧
        NodesKept x y) t t' ∧
    ∃ b tok, t'.ctl = .ret (.obj b) ∧ t.next ≤ b ∧ propOf (t'.obj? b) chars!"token" = some (.obj tok) ∧
      handleOf (t'.obj? tok) = some h ∧ propOf (t'.obj? b) chars!"extras" = some .null ∧ G t'.aux.ffi

/-- **The dispatch's postcondition**: arrays and graph unchanged, three events, the vector of nodes `ns`. -/
def AsyncPost (ns : List Nat) (t t' : St Host.Mlx.Ffi.St) : Prop :=
  Framed (F := MF) (fun b => ∃ p ∈ ([] : List (Nat × Nat)), p.1 ≤ b ∧ b < p.2)
      (fun x y => y.arrs = x.arrs ∧ y.nodes = x.nodes) t t' ∧
    (t'.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_async_eval", chars!"mlx_vector_array_new_data"] ∧
    t'.aux.ffi.objs.get t.aux.ffi.next = some (.vec ns)

/-- **The readback's postcondition**: the token node `n` records queue entry `k`, which the call returns,
reading `tok` through the server. -/
def ReadPost (n k tok : Nat) (t t' : St Host.Mlx.Ffi.St) (C' : CSrv) : Prop :=
  Framed (F := MF) (fun b => ∃ p ∈ ([] : List (Nat × Nat)), p.1 ≤ b ∧ b < p.2)
      (fun x y => y.arrs = x.arrs ∧ y.nodes = x.nodes ∧ y.tokens = x.tokens.drop 1 ∧ y.items.get n = some (.ref k)) t t' ∧
    (t'.trace.take 2).map Event.sym = [chars!"mlx_array_item_uint32", chars!"mlx_array_eval"] ∧
    ∃ v, t'.ctl = .ret v ∧ natAt C' v = some tok

/-! ## `sample`, class `cold` -/

def Smp.coldG (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 30 = y.nodes.get 13 ∧ nodeKey y 13 = some ([4, 7, 1], [12], [(.lit 1)], 3) ∧
    nodeKey y 12 = some ([4, 7, 3, 18, 0], [10, 11], [(.lit 1)], 3) ∧
    nodeKey y 10 = some ([4, 7, 3, 15, 0], [2, 9], [(.lit 1), (.lit 243)], 10) ∧
    nodeKey y 11 = some ([4, 7, 3, 15, 1], [2, 9], [(.lit 1), (.lit 243)], 3) ∧
    nodeKey y 9 = some ([4, 7, 2, 1], [2], [(.lit 1), (.lit 1)], 12) ∧
    nodeKey y 2 = some ([1], [1], [(.lit 1), (.lit 248320)], 12) ∧
    kernelName y 15 = some chars!"normalized_argmax_partial" ∧ kernelName y 18 = some chars!"normalized_argmax_finish"

kernel_rfl Smp.coldArrs : Smp.s69.aux.ffi.arrs = setAll Smp.s1.aux.ffi.arrs [(5, 0), (12, 0), (19, 0), (23, 0), (24, 0), (28, 0), (29, 0), (30, 13)]
kernel_rfl Smp.coldNodes : Smp.s69.aux.ffi.nodes = setAll Smp.s1.aux.ffi.nodes (freshOf Smp.s69.aux.ffi.nodes Smp.s1.aux.ffi.nnext Smp.s69.aux.ffi.nnext)
kernel_rfl Smp.coldNSmall : Nat.blt Smp.s69.aux.ffi.nnext 1048576 = true
kernel_rfl Smp.coldHeap : Smp.s69.heap = setAll Smp.s1.heap (rangesOf Smp.s69.heap [(426, 427), (430, 431), (445, 448), (1423, 1424)] ++ freshOf Smp.s69.heap Smp.s1.next Smp.s69.next)
kernel_rfl Smp.coldNextLe : Nat.ble Smp.s1.next Smp.s69.next = true
kernel_rfl Smp.coldSmall : Nat.blt Smp.s69.next 1048576 = true
kernel_rfl Smp.coldJobs : Smp.s69.aux.jobs = Smp.s1.aux.jobs
kernel_rfl Smp.coldStores : Smp.s69.aux.stores = Smp.s1.aux.stores
kernel_rfl Smp.coldTrace : Smp.s69.aux.trace = Smp.s69.aux.trace.take (Smp.s69.aux.trace.length - Smp.s1.aux.trace.length) ++ Smp.s1.aux.trace
kernel_rfl Smp.coldRet : Smp.s69.ctl = .ret (.obj 1625)
kernel_rfl Smp.coldFresh : Nat.ble Smp.s1.next 1625 = true
kernel_rfl Smp.coldTok : propOf (Smp.s69.obj? 1625) chars!"token" = some (.obj 2176)
kernel_rfl Smp.coldHd : handleOf (Smp.s69.obj? 2176) = some 30
kernel_rfl Smp.coldEx : propOf (Smp.s69.obj? 1625) chars!"extras" = some .null
kernel_rfl Smp.coldG13 : nodeKey Smp.s69.aux.ffi 13 = some ([4, 7, 1], [12], [(.lit 1)], 3)
kernel_rfl Smp.coldG12 : nodeKey Smp.s69.aux.ffi 12 = some ([4, 7, 3, 18, 0], [10, 11], [(.lit 1)], 3)
kernel_rfl Smp.coldG10 : nodeKey Smp.s69.aux.ffi 10 = some ([4, 7, 3, 15, 0], [2, 9], [(.lit 1), (.lit 243)], 10)
kernel_rfl Smp.coldG11 : nodeKey Smp.s69.aux.ffi 11 = some ([4, 7, 3, 15, 1], [2, 9], [(.lit 1), (.lit 243)], 3)
kernel_rfl Smp.coldG9 : nodeKey Smp.s69.aux.ffi 9 = some ([4, 7, 2, 1], [2], [(.lit 1), (.lit 1)], 12)
kernel_rfl Smp.coldG2 : nodeKey Smp.s69.aux.ffi 2 = some ([1], [1], [(.lit 1), (.lit 248320)], 12)
kernel_rfl Smp.coldH : Smp.s69.aux.ffi.node? 30 = Smp.s69.aux.ffi.nodes.get 13
kernel_rfl Smp.coldK15 : kernelName Smp.s69.aux.ffi 15 = some chars!"normalized_argmax_partial"
kernel_rfl Smp.coldK18 : kernelName Smp.s69.aux.ffi 18 = some chars!"normalized_argmax_finish"

/-- **`sample` (cold)** (parameter: the valuation; the call reads no number). -/
def Smp.coldStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN Smp.s1 0 [] ∧ Inst ρ Smp.S1 C
  Post ρ t _ t' C' := SamplePost [(426, 427), (430, 431), (445, 448), (1423, 1424)] [(5, 0), (12, 0), (19, 0), (23, 0), (24, 0), (28, 0), (29, 0), (30, 13)] 30 Smp.coldG t t' ∧ Inst ρ Smp.S69 C'

theorem Smp.coldHolds : Smp.coldStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim Smp.cold hi
  exact ⟨_, tplN Smp.s69 0 [], _, ⟨⟨framedW_of Smp.coldHeap Smp.coldNextLe Smp.coldSmall (by decide) Smp.coldJobs Smp.coldStores
    Smp.coldTrace ⟨liveDelta_setAll Smp.coldArrs (by decide) (by decide), nodesKept_of Smp.coldNodes Smp.coldNSmall⟩,
    1625, 2176, Smp.coldRet, Nat.le_of_ble_eq_true Smp.coldFresh, Smp.coldTok, Smp.coldHd, Smp.coldEx, Smp.coldH, Smp.coldG13, Smp.coldG12, Smp.coldG10, Smp.coldG11, Smp.coldG9, Smp.coldG2, Smp.coldK15, Smp.coldK18⟩, hi'⟩, hrun⟩

/-! ## `sample`, class `warm` -/

def Smp.warmG (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 36 = y.nodes.get 20 ∧ nodeKey y 20 = some ([4, 7, 1], [19], [(.lit 1)], 3) ∧
    nodeKey y 19 = some ([4, 7, 3, 18, 0], [17, 18], [(.lit 1)], 3) ∧
    nodeKey y 17 = some ([4, 7, 3, 15, 0], [15, 16], [(.lit 1), (.lit 243)], 10) ∧
    nodeKey y 18 = some ([4, 7, 3, 15, 1], [15, 16], [(.lit 1), (.lit 243)], 3) ∧
    nodeKey y 16 = some ([4, 7, 2, 1], [15], [(.lit 1), (.lit 1)], 12) ∧
    nodeKey y 15 = some ([1], [14], [(.lit 1), (.lit 248320)], 12) ∧
    kernelName y 15 = some chars!"normalized_argmax_partial" ∧ kernelName y 18 = some chars!"normalized_argmax_finish"

kernel_rfl Smp.warmArrs : Smp.s78.aux.ffi.arrs = setAll Smp.s76.aux.ffi.arrs [(33, 0), (36, 20)]
kernel_rfl Smp.warmNodes : Smp.s78.aux.ffi.nodes = setAll Smp.s76.aux.ffi.nodes (freshOf Smp.s78.aux.ffi.nodes Smp.s76.aux.ffi.nnext Smp.s78.aux.ffi.nnext)
kernel_rfl Smp.warmNSmall : Nat.blt Smp.s78.aux.ffi.nnext 1048576 = true
kernel_rfl Smp.warmHeap : Smp.s78.heap = setAll Smp.s76.heap (rangesOf Smp.s78.heap [] ++ freshOf Smp.s78.heap Smp.s76.next Smp.s78.next)
kernel_rfl Smp.warmNextLe : Nat.ble Smp.s76.next Smp.s78.next = true
kernel_rfl Smp.warmSmall : Nat.blt Smp.s78.next 1048576 = true
kernel_rfl Smp.warmJobs : Smp.s78.aux.jobs = Smp.s76.aux.jobs
kernel_rfl Smp.warmStores : Smp.s78.aux.stores = Smp.s76.aux.stores
kernel_rfl Smp.warmTrace : Smp.s78.aux.trace = Smp.s78.aux.trace.take (Smp.s78.aux.trace.length - Smp.s76.aux.trace.length) ++ Smp.s76.aux.trace
kernel_rfl Smp.warmRet : Smp.s78.ctl = .ret (.obj 2325)
kernel_rfl Smp.warmFresh : Nat.ble Smp.s76.next 2325 = true
kernel_rfl Smp.warmTok : propOf (Smp.s78.obj? 2325) chars!"token" = some (.obj 2367)
kernel_rfl Smp.warmHd : handleOf (Smp.s78.obj? 2367) = some 36
kernel_rfl Smp.warmEx : propOf (Smp.s78.obj? 2325) chars!"extras" = some .null
kernel_rfl Smp.warmG20 : nodeKey Smp.s78.aux.ffi 20 = some ([4, 7, 1], [19], [(.lit 1)], 3)
kernel_rfl Smp.warmG19 : nodeKey Smp.s78.aux.ffi 19 = some ([4, 7, 3, 18, 0], [17, 18], [(.lit 1)], 3)
kernel_rfl Smp.warmG17 : nodeKey Smp.s78.aux.ffi 17 = some ([4, 7, 3, 15, 0], [15, 16], [(.lit 1), (.lit 243)], 10)
kernel_rfl Smp.warmG18 : nodeKey Smp.s78.aux.ffi 18 = some ([4, 7, 3, 15, 1], [15, 16], [(.lit 1), (.lit 243)], 3)
kernel_rfl Smp.warmG16 : nodeKey Smp.s78.aux.ffi 16 = some ([4, 7, 2, 1], [15], [(.lit 1), (.lit 1)], 12)
kernel_rfl Smp.warmG15 : nodeKey Smp.s78.aux.ffi 15 = some ([1], [14], [(.lit 1), (.lit 248320)], 12)
kernel_rfl Smp.warmH : Smp.s78.aux.ffi.node? 36 = Smp.s78.aux.ffi.nodes.get 20
kernel_rfl Smp.warmK15 : kernelName Smp.s78.aux.ffi 15 = some chars!"normalized_argmax_partial"
kernel_rfl Smp.warmK18 : kernelName Smp.s78.aux.ffi 18 = some chars!"normalized_argmax_finish"

/-- **`sample` (warm)** (parameter: the valuation; the call reads no number). -/
def Smp.warmStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN Smp.s76 0 [] ∧ Inst ρ Smp.S76 C
  Post ρ t _ t' C' := SamplePost [] [(33, 0), (36, 20)] 36 Smp.warmG t t' ∧ Inst ρ Smp.S78 C'

theorem Smp.warmHolds : Smp.warmStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim Smp.warm hi
  exact ⟨_, tplN Smp.s78 0 [], _, ⟨⟨framedW_of Smp.warmHeap Smp.warmNextLe Smp.warmSmall (by decide) Smp.warmJobs Smp.warmStores
    Smp.warmTrace ⟨liveDelta_setAll Smp.warmArrs (by decide) (by decide), nodesKept_of Smp.warmNodes Smp.warmNSmall⟩,
    2325, 2367, Smp.warmRet, Nat.le_of_ble_eq_true Smp.warmFresh, Smp.warmTok, Smp.warmHd, Smp.warmEx, Smp.warmH, Smp.warmG20, Smp.warmG19, Smp.warmG17, Smp.warmG18, Smp.warmG16, Smp.warmG15, Smp.warmK15, Smp.warmK18⟩, hi'⟩, hrun⟩

/-! ## dispatch `dispatch0` -/

kernel_rfl Smp.dispatch0Arrs : Smp.s72.aux.ffi.arrs = Smp.s70.aux.ffi.arrs
kernel_rfl Smp.dispatch0Nodes : Smp.s72.aux.ffi.nodes = Smp.s70.aux.ffi.nodes
kernel_rfl Smp.dispatch0Heap : Smp.s72.heap = setAll Smp.s70.heap (rangesOf Smp.s72.heap [] ++ freshOf Smp.s72.heap Smp.s70.next Smp.s72.next)
kernel_rfl Smp.dispatch0NextLe : Nat.ble Smp.s70.next Smp.s72.next = true
kernel_rfl Smp.dispatch0Small : Nat.blt Smp.s72.next 1048576 = true
kernel_rfl Smp.dispatch0Jobs : Smp.s72.aux.jobs = Smp.s70.aux.jobs
kernel_rfl Smp.dispatch0Stores : Smp.s72.aux.stores = Smp.s70.aux.stores
kernel_rfl Smp.dispatch0Trace : Smp.s72.aux.trace = Smp.s72.aux.trace.take 3 ++ Smp.s70.aux.trace
kernel_rfl Smp.dispatch0Syms : (Smp.s72.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_async_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl Smp.dispatch0Vec : Smp.s72.aux.ffi.objs.get Smp.s70.aux.ffi.next = some (.vec [13])

def Smp.dispatch0Stage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN Smp.s70 0 [] ∧ Inst ρ Smp.S70 C
  Post ρ t _ t' C' := AsyncPost [13] t t' ∧ Inst ρ Smp.S72 C'

theorem Smp.dispatch0Holds : Smp.dispatch0Stage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim Smp.dispatch0 hi
  exact ⟨_, tplN Smp.s72 0 [], _, ⟨⟨framedW_of Smp.dispatch0Heap Smp.dispatch0NextLe Smp.dispatch0Small (by decide) Smp.dispatch0Jobs Smp.dispatch0Stores
    Smp.dispatch0Trace ⟨Smp.dispatch0Arrs, Smp.dispatch0Nodes⟩, Smp.dispatch0Syms, Smp.dispatch0Vec⟩, hi'⟩, hrun⟩

/-! ## dispatch `dispatch1` -/

kernel_rfl Smp.dispatch1Arrs : Smp.s81.aux.ffi.arrs = Smp.s79.aux.ffi.arrs
kernel_rfl Smp.dispatch1Nodes : Smp.s81.aux.ffi.nodes = Smp.s79.aux.ffi.nodes
kernel_rfl Smp.dispatch1Heap : Smp.s81.heap = setAll Smp.s79.heap (rangesOf Smp.s81.heap [] ++ freshOf Smp.s81.heap Smp.s79.next Smp.s81.next)
kernel_rfl Smp.dispatch1NextLe : Nat.ble Smp.s79.next Smp.s81.next = true
kernel_rfl Smp.dispatch1Small : Nat.blt Smp.s81.next 1048576 = true
kernel_rfl Smp.dispatch1Jobs : Smp.s81.aux.jobs = Smp.s79.aux.jobs
kernel_rfl Smp.dispatch1Stores : Smp.s81.aux.stores = Smp.s79.aux.stores
kernel_rfl Smp.dispatch1Trace : Smp.s81.aux.trace = Smp.s81.aux.trace.take 3 ++ Smp.s79.aux.trace
kernel_rfl Smp.dispatch1Syms : (Smp.s81.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_async_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl Smp.dispatch1Vec : Smp.s81.aux.ffi.objs.get Smp.s79.aux.ffi.next = some (.vec [20])

def Smp.dispatch1Stage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN Smp.s79 0 [] ∧ Inst ρ Smp.S79 C
  Post ρ t _ t' C' := AsyncPost [20] t t' ∧ Inst ρ Smp.S81 C'

theorem Smp.dispatch1Holds : Smp.dispatch1Stage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim Smp.dispatch1 hi
  exact ⟨_, tplN Smp.s81 0 [], _, ⟨⟨framedW_of Smp.dispatch1Heap Smp.dispatch1NextLe Smp.dispatch1Small (by decide) Smp.dispatch1Jobs Smp.dispatch1Stores
    Smp.dispatch1Trace ⟨Smp.dispatch1Arrs, Smp.dispatch1Nodes⟩, Smp.dispatch1Syms, Smp.dispatch1Vec⟩, hi'⟩, hrun⟩

/-! ## readback `readback0` -/

kernel_rfl Smp.readback0Arrs : Smp.s75.aux.ffi.arrs = Smp.s73.aux.ffi.arrs
kernel_rfl Smp.readback0Nodes : Smp.s75.aux.ffi.nodes = Smp.s73.aux.ffi.nodes
kernel_rfl Smp.readback0Tokens : Smp.s75.aux.ffi.tokens = Smp.s73.aux.ffi.tokens.drop 1
kernel_rfl Smp.readback0Items : Smp.s75.aux.ffi.items.get 13 = some (.ref 0)
kernel_rfl Smp.readback0Heap : Smp.s75.heap = setAll Smp.s73.heap (rangesOf Smp.s75.heap [] ++ freshOf Smp.s75.heap Smp.s73.next Smp.s75.next)
kernel_rfl Smp.readback0NextLe : Nat.ble Smp.s73.next Smp.s75.next = true
kernel_rfl Smp.readback0Small : Nat.blt Smp.s75.next 1048576 = true
kernel_rfl Smp.readback0Jobs : Smp.s75.aux.jobs = Smp.s73.aux.jobs
kernel_rfl Smp.readback0Stores : Smp.s75.aux.stores = Smp.s73.aux.stores
kernel_rfl Smp.readback0Trace : Smp.s75.aux.trace = Smp.s75.aux.trace.take 2 ++ Smp.s73.aux.trace
kernel_rfl Smp.readback0Syms : (Smp.s75.aux.trace.take 2).map Event.sym = [chars!"mlx_array_item_uint32", chars!"mlx_array_eval"]
kernel_rfl Smp.readback0Ret : Smp.s75.ctl = .ret (.num (.ref 0))
kernel_rfl Smp.readback0E : nth? Smp.S75.tab 0 = some (.var 0)

/-- **The readback readback0** (parameters: the two queued tokens). -/
def Smp.readback0Stage : Stage MF where
  Par := Nat × Nat
  Pre q t C := q.1 < 248320 ∧ q.2 < 248320 ∧ t = tplN Smp.s73 0 [] ∧ C = ⟨Smp.S73.tab.map (SymE.eval (ρtok q.1 q.2))⟩
  Post q t _ t' C' := ReadPost 13 0 q.1 t t' C'

theorem Smp.readback0Holds : Smp.readback0Stage.Holds := by
  rintro ⟨t0, t1⟩ t Cs ⟨h0, h1, rfl, rfl⟩
  have hi : Inst (ρtok t0 t1) Smp.S73 ⟨Smp.S73.tab.map (SymE.eval (ρtok t0 t1))⟩ := ⟨rfl, by intro q hq; simp_all [Smp.S73]⟩
  obtain ⟨_, hrun⟩ := tplN_sim Smp.readback0 hi
  refine ⟨_, tplN Smp.s75 0 [], _, ⟨framedW_of Smp.readback0Heap Smp.readback0NextLe Smp.readback0Small (by decide) Smp.readback0Jobs Smp.readback0Stores
    Smp.readback0Trace ⟨Smp.readback0Arrs, Smp.readback0Nodes, Smp.readback0Tokens, Smp.readback0Items⟩, Smp.readback0Syms, .num (.ref 0), Smp.readback0Ret, ?_⟩, hrun⟩
  exact natAt_ref (by rw [nth_inst Smp.readback0E]; exact congrArg some (Lin.ofNat_ie t0 (by omega))) (by omega)

/-! ## readback `readback1` -/

kernel_rfl Smp.readback1Arrs : Smp.s84.aux.ffi.arrs = Smp.s82.aux.ffi.arrs
kernel_rfl Smp.readback1Nodes : Smp.s84.aux.ffi.nodes = Smp.s82.aux.ffi.nodes
kernel_rfl Smp.readback1Tokens : Smp.s84.aux.ffi.tokens = Smp.s82.aux.ffi.tokens.drop 1
kernel_rfl Smp.readback1Items : Smp.s84.aux.ffi.items.get 20 = some (.ref 1)
kernel_rfl Smp.readback1Heap : Smp.s84.heap = setAll Smp.s82.heap (rangesOf Smp.s84.heap [] ++ freshOf Smp.s84.heap Smp.s82.next Smp.s84.next)
kernel_rfl Smp.readback1NextLe : Nat.ble Smp.s82.next Smp.s84.next = true
kernel_rfl Smp.readback1Small : Nat.blt Smp.s84.next 1048576 = true
kernel_rfl Smp.readback1Jobs : Smp.s84.aux.jobs = Smp.s82.aux.jobs
kernel_rfl Smp.readback1Stores : Smp.s84.aux.stores = Smp.s82.aux.stores
kernel_rfl Smp.readback1Trace : Smp.s84.aux.trace = Smp.s84.aux.trace.take 2 ++ Smp.s82.aux.trace
kernel_rfl Smp.readback1Syms : (Smp.s84.aux.trace.take 2).map Event.sym = [chars!"mlx_array_item_uint32", chars!"mlx_array_eval"]
kernel_rfl Smp.readback1Ret : Smp.s84.ctl = .ret (.num (.ref 1))
kernel_rfl Smp.readback1E : nth? Smp.S84.tab 1 = some (.var 1)

/-- **The readback readback1** (parameters: the two queued tokens). -/
def Smp.readback1Stage : Stage MF where
  Par := Nat × Nat
  Pre q t C := q.1 < 248320 ∧ q.2 < 248320 ∧ t = tplN Smp.s82 0 [] ∧ C = ⟨Smp.S82.tab.map (SymE.eval (ρtok q.1 q.2))⟩
  Post q t _ t' C' := ReadPost 20 1 q.2 t t' C'

theorem Smp.readback1Holds : Smp.readback1Stage.Holds := by
  rintro ⟨t0, t1⟩ t Cs ⟨h0, h1, rfl, rfl⟩
  have hi : Inst (ρtok t0 t1) Smp.S82 ⟨Smp.S82.tab.map (SymE.eval (ρtok t0 t1))⟩ := ⟨rfl, by intro q hq; simp_all [Smp.S82]⟩
  obtain ⟨_, hrun⟩ := tplN_sim Smp.readback1 hi
  refine ⟨_, tplN Smp.s84 0 [], _, ⟨framedW_of Smp.readback1Heap Smp.readback1NextLe Smp.readback1Small (by decide) Smp.readback1Jobs Smp.readback1Stores
    Smp.readback1Trace ⟨Smp.readback1Arrs, Smp.readback1Nodes, Smp.readback1Tokens, Smp.readback1Items⟩, Smp.readback1Syms, .num (.ref 1), Smp.readback1Ret, ?_⟩, hrun⟩
  exact natAt_ref (by rw [nth_inst Smp.readback1E]; exact congrArg some (Lin.ofNat_ie t1 (by omega))) (by omega)

end Host.Ts.Sim.Stage.Sample
