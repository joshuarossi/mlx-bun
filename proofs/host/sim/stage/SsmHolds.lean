import host.sim.stage.Mlx
import host.sim.stage.SsmRun
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Ts.Sim.Stage.Ssm
open Host.Ts Host.Ts.Sim.Stage

/-! # The SSM cache stage contracts

**`recurDecode`** (`SsmPost`), per class, for every caller stack:
* the existing heap entries written are the cache object, the `MlxArray` objects the call disposes
  (`qkv`, `a`, `b`, the replaced `#conv`/`#recurrent`) and, in the classes with fresh memos
  (`SsmF.first`, `Ssm.cold`), the module memo cells and the compiled-function objects (written ranges
  `ws`); jobs, stores unchanged, the trace gains the call's mlx-c events;
* **live-set delta** (`mlxLive`): the handles `es` sets to a node are allocated (the output, the new
  `#conv` and `#recurrent`; in the cold classes also the closures' and kernels' retained arrays), those it
  resets are freed: the consumed `qkv`, `a`, `b`, the replaced states and every temporary; no existing
  graph node changes (`NodesKept`);
* `offset` advances by one (read through the return server), `#conv`/`#recurrent` hold the new
  handles, the call returns a fresh `MlxArray` of the output handle;
* the graph (`*.G`, every node the call adds): the output and the new recurrent state are outputs 0
  and 1 of `gated_delta_step` over the heads (outputs of `mlx_bun_silu_rms_heads`, replayed by the
  shared compiled closure over the `conv1d` (stride 1, groups 10240) of the stored state concatenated
  with `qkv`), `g` (`computeG`'s compiled closure: `exp(-exp(aLog_f32) · logaddexp(a + dtBias, 0))`),
  `beta = sigmoid(b)`, the stored recurrent state (`zeros` for a null state) and the length `T`; the
  new `#conv` is the dynamic slice of the concatenation's last three rows. The cold classes also trace
  both closures (`tracer` nodes and the traced graph).

Precondition: the class's call state (`tplN`) and the server instantiated at the offset `o`.

**`evalCacheState`** (`EvalPost`): the evaluated vector holds `#conv` and `#recurrent` in that
order (`state()`, ssm.ts:250-256). -/

/-- **`recurDecode`'s postcondition**: cache object `a`, written ranges `ws`, handle-table update `es`,
new `#conv`/`#recurrent`/output handles `hc`/`hr`/`hy`, the offset value `offV` reading `n`, graph `G`. -/
def SsmPost (a : Nat) (ws es : List (Nat × Nat)) (hc hr hy : Int) (offV : Val) (n : Nat) (G : Host.Mlx.Ffi.St → Prop)
    (t t' : St Host.Mlx.Ffi.St) (C' : CSrv) : Prop :=
  Framed (F := MF) (fun b => ∃ p ∈ ws, p.1 ≤ b ∧ b < p.2)
      (fun x y => LiveDelta (F := MF) mlxLive (fun h => ∃ m, (h, m) ∈ es ∧ m ≠ 0) (fun h => (h, 0) ∈ es) x y ∧
        NodesKept x y) t t' ∧
    propOf (t'.obj? a) chars!"offset" = some offV ∧ natAt C' offV = some n ∧
    PrivArr t' a chars!"conv" hc ∧ PrivArr t' a chars!"recurrent" hr ∧
    (∃ b, t'.ctl = .ret (.obj b) ∧ t.next ≤ b ∧ handleOf (t'.obj? b) = some hy) ∧ G t'.aux.ffi

theorem ρ1_0 (o : Nat) (h : o < 2 ^ 53) : ρ1 o 0 = Lin.ie o := Lin.ofNat_ie o h

theorem eval_o1 (o : Nat) (h : o < 2 ^ 52) :
    SymE.eval (ρ1 o) (.bin .add (.var 0) (.lit (.fin false 1 0))) = Lin.ie (o + 1 : Nat) := by
  simp only [SymE.eval]
  rw [ρ1_0 o (by omega), one_ie]
  show F64.add _ _ = _
  rw [Lin.add_ie _ _ (by omega)]
  exact ie_cast (by omega)

theorem eval_o2 (o : Nat) (h : o < 2 ^ 51) :
    SymE.eval (ρ1 o) (.bin .add (.bin .add (.var 0) (.lit (.fin false 1 0))) (.lit (.fin false 1 0))) = Lin.ie (o + 2 : Nat) := by
  have h1 := eval_o1 o (by omega)
  have h2 : F64.add (Lin.ie ((o + 1 : Nat) : Int)) (Lin.ie 1) = Lin.ie ((o + 2 : Nat) : Int) := by
    rw [Lin.add_ie _ _ (by omega)]; exact ie_cast (by omega)
  simp only [SymE.eval] at h1 ⊢
  rw [h1, one_ie]
  exact h2

theorem natAt_one (C : CSrv) : natAt C (.num (.lit (F64.fin false 1 0))) = some 1 := by
  rw [one_ie]; exact toIndex_ie 1 (by decide)

/-! ## `recurDecode`, class `SsmF.first`: null states (the only row of a one-token prompt), fresh memos: both closures traced -/

/-- The graph of class `SsmF.first`: the output, `#conv` and `#recurrent` handles' nodes, every node the call adds, the kernels. -/
def SsmF.firstG (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 67 = y.nodes.get 45 ∧
    y.node? 19 = y.nodes.get 13 ∧
    y.node? 68 = y.nodes.get 46 ∧
    nodeKey y 9 = some ([5], [], [(.lit 1), (.lit 3), (.lit 10240)], 12) ∧
    nodeKey y 10 = some ([8, 1], [9, 6], [(.lit 1), (.lit 4), (.lit 10240)], 12) ∧
    nodeKey y 11 = some ([6], [10], [(.lit 1), (.lit 3), (.lit 10240)], 12) ∧
    nodeKey y 12 = some ([10], [], [], 7) ∧
    nodeKey y 13 = some ([15, 0], [11, 12], [(.lit 1), (.lit 3), (.lit 10240)], 12) ∧
    nodeKey y 14 = some ([14, 1, 0, 1, 10240], [10, 3], [(.lit 1), (.lit 1), (.lit 10240)], 12) ∧
    nodeKey y 15 = some ([9, 0], [], [(.lit 1), (.lit 1), (.lit 10240)], 12) ∧
    nodeKey y 16 = some ([9, 1], [], [(.lit 128)], 12) ∧
    nodeKey y 17 = some ([9, 2], [], [(.lit 128)], 12) ∧
    nodeKey y 18 = some ([3, 30, 0], [15, 16, 17], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12) ∧
    nodeKey y 19 = some ([3, 30, 1], [15, 16, 17], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12) ∧
    nodeKey y 20 = some ([3, 30, 2], [15, 16, 17], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12) ∧
    nodeKey y 21 = some ([4, 5, 3, 30, 0], [14, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12) ∧
    nodeKey y 22 = some ([4, 5, 3, 30, 1], [14, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12) ∧
    nodeKey y 23 = some ([4, 5, 3, 30, 2], [14, 1, 2], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12) ∧
    nodeKey y 24 = some ([12, 115, 105, 103, 109, 111, 105, 100], [8], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 25 = some ([9, 0], [], [(.lit 48)], 12) ∧
    nodeKey y 26 = some ([9, 1], [], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 27 = some ([9, 2], [], [(.lit 48)], 12) ∧
    nodeKey y 28 = some ([11, 10], [25], [(.lit 48)], 10) ∧
    nodeKey y 29 = some ([12, 101, 120, 112], [28], [(.lit 48)], 10) ∧
    nodeKey y 30 = some ([12, 110, 101, 103, 97, 116, 105, 118, 101], [29], [(.lit 48)], 10) ∧
    nodeKey y 31 = some ([13, 97, 100, 100], [26, 27], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 32 = some ([10], [], [], 12) ∧
    nodeKey y 33 = some ([13, 108, 111, 103, 97, 100, 100, 101, 120, 112], [31, 32], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 34 = some ([13, 109, 117, 108, 116, 105, 112, 108, 121], [30, 33], [(.lit 1), (.lit 1), (.lit 48)], 10) ∧
    nodeKey y 35 = some ([12, 101, 120, 112], [34], [(.lit 1), (.lit 1), (.lit 48)], 10) ∧
    nodeKey y 36 = some ([4, 42, 11, 10], [4], [(.lit 48)], 10) ∧
    nodeKey y 37 = some ([4, 42, 12, 101, 120, 112], [36], [(.lit 48)], 10) ∧
    nodeKey y 38 = some ([4, 42, 12, 110, 101, 103, 97, 116, 105, 118, 101], [37], [(.lit 48)], 10) ∧
    nodeKey y 39 = some ([4, 42, 13, 97, 100, 100], [7, 5], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 40 = some ([4, 42, 13, 108, 111, 103, 97, 100, 100, 101, 120, 112], [39, 32], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 41 = some ([4, 42, 13, 109, 117, 108, 116, 105, 112, 108, 121], [38, 40], [(.lit 1), (.lit 1), (.lit 48)], 10) ∧
    nodeKey y 42 = some ([4, 42, 12, 101, 120, 112], [41], [(.lit 1), (.lit 1), (.lit 48)], 10) ∧
    nodeKey y 43 = some ([5], [], [(.lit 1), (.lit 48), (.lit 128), (.lit 128)], 10) ∧
    nodeKey y 44 = some ([10], [], [(.lit 1)], 7) ∧
    nodeKey y 45 = some ([3, 63, 0], [21, 22, 23, 42, 24, 43, 44], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12) ∧
    nodeKey y 46 = some ([3, 63, 1], [21, 22, 23, 42, 24, 43, 44], [(.lit 1), (.lit 48), (.lit 128), (.lit 128)], 10) ∧
    kernelName y 30 = some chars!"mlx_bun_silu_rms_heads" ∧
    kernelName y 63 = some chars!"gated_delta_step"

kernel_rfl SsmF.firstSrv : SsmF.S4.oracle = SsmF.O
kernel_rfl SsmF.firstArrs : SsmF.s173.aux.ffi.arrs = setAll SsmF.s4.aux.ffi.arrs [(11, 0), (12, 0), (13, 0), (14, 0), (16, 0), (17, 0), (18, 12), (19, 13), (20, 0), (25, 0), (26, 0), (27, 0), (34, 0), (35, 0), (36, 0), (37, 0), (38, 0), (39, 0), (40, 0), (47, 0), (48, 0), (49, 0), (50, 0), (51, 0), (52, 0), (53, 0), (54, 0), (55, 0), (56, 0), (57, 0), (58, 0), (59, 0), (60, 0), (67, 45), (68, 46)]
kernel_rfl SsmF.firstNodes : SsmF.s173.aux.ffi.nodes = setAll SsmF.s4.aux.ffi.nodes (freshOf SsmF.s173.aux.ffi.nodes SsmF.s4.aux.ffi.nnext SsmF.s173.aux.ffi.nnext)
kernel_rfl SsmF.firstNSmall : Nat.blt SsmF.s173.aux.ffi.nnext 1048576 = true
kernel_rfl SsmF.firstHeap : SsmF.s173.heap = setAll SsmF.s4.heap (rangesOf SsmF.s173.heap [(425, 426), (430, 431), (434, 435), (452, 453), (455, 456), (470, 471), (1368, 1369), (1451, 1452), (1868, 1869), (1891, 1892), (1917, 1918), (1943, 1944)] ++ freshOf SsmF.s173.heap SsmF.s4.next SsmF.s173.next)
kernel_rfl SsmF.firstNextLe : Nat.ble SsmF.s4.next SsmF.s173.next = true
kernel_rfl SsmF.firstSmall : Nat.blt SsmF.s173.next 1048576 = true
kernel_rfl SsmF.firstJobs : SsmF.s173.aux.jobs = SsmF.s4.aux.jobs
kernel_rfl SsmF.firstStores : SsmF.s173.aux.stores = SsmF.s4.aux.stores
kernel_rfl SsmF.firstTrace : SsmF.s173.aux.trace = SsmF.s173.aux.trace.take (SsmF.s173.aux.trace.length - SsmF.s4.aux.trace.length) ++ SsmF.s4.aux.trace
kernel_rfl SsmF.firstOff : propOf (SsmF.s173.obj? 1868) chars!"offset" = some (.num (.lit (F64.fin false 1 0)))
kernel_rfl SsmF.firstConv : privOf (SsmF.s173.obj? 1868) chars!"conv" = some (.obj 2253)
kernel_rfl SsmF.firstConvH : handleOf (SsmF.s173.obj? 2253) = some 19
kernel_rfl SsmF.firstRec : privOf (SsmF.s173.obj? 1868) chars!"recurrent" = some (.obj 3522)
kernel_rfl SsmF.firstRecH : handleOf (SsmF.s173.obj? 3522) = some 68
kernel_rfl SsmF.firstRet : SsmF.s173.ctl = .ret (.obj 3516)
kernel_rfl SsmF.firstFresh : Nat.ble SsmF.s4.next 3516 = true
kernel_rfl SsmF.firstRetH : handleOf (SsmF.s173.obj? 3516) = some 67
kernel_rfl SsmF.firstHy : SsmF.s173.aux.ffi.node? 67 = SsmF.s173.aux.ffi.nodes.get 45
kernel_rfl SsmF.firstHc : SsmF.s173.aux.ffi.node? 19 = SsmF.s173.aux.ffi.nodes.get 13
kernel_rfl SsmF.firstHr : SsmF.s173.aux.ffi.node? 68 = SsmF.s173.aux.ffi.nodes.get 46
kernel_rfl SsmF.firstG9 : nodeKey SsmF.s173.aux.ffi 9 = some ([5], [], [(.lit 1), (.lit 3), (.lit 10240)], 12)
kernel_rfl SsmF.firstG10 : nodeKey SsmF.s173.aux.ffi 10 = some ([8, 1], [9, 6], [(.lit 1), (.lit 4), (.lit 10240)], 12)
kernel_rfl SsmF.firstG11 : nodeKey SsmF.s173.aux.ffi 11 = some ([6], [10], [(.lit 1), (.lit 3), (.lit 10240)], 12)
kernel_rfl SsmF.firstG12 : nodeKey SsmF.s173.aux.ffi 12 = some ([10], [], [], 7)
kernel_rfl SsmF.firstG13 : nodeKey SsmF.s173.aux.ffi 13 = some ([15, 0], [11, 12], [(.lit 1), (.lit 3), (.lit 10240)], 12)
kernel_rfl SsmF.firstG14 : nodeKey SsmF.s173.aux.ffi 14 = some ([14, 1, 0, 1, 10240], [10, 3], [(.lit 1), (.lit 1), (.lit 10240)], 12)
kernel_rfl SsmF.firstG15 : nodeKey SsmF.s173.aux.ffi 15 = some ([9, 0], [], [(.lit 1), (.lit 1), (.lit 10240)], 12)
kernel_rfl SsmF.firstG16 : nodeKey SsmF.s173.aux.ffi 16 = some ([9, 1], [], [(.lit 128)], 12)
kernel_rfl SsmF.firstG17 : nodeKey SsmF.s173.aux.ffi 17 = some ([9, 2], [], [(.lit 128)], 12)
kernel_rfl SsmF.firstG18 : nodeKey SsmF.s173.aux.ffi 18 = some ([3, 30, 0], [15, 16, 17], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12)
kernel_rfl SsmF.firstG19 : nodeKey SsmF.s173.aux.ffi 19 = some ([3, 30, 1], [15, 16, 17], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12)
kernel_rfl SsmF.firstG20 : nodeKey SsmF.s173.aux.ffi 20 = some ([3, 30, 2], [15, 16, 17], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12)
kernel_rfl SsmF.firstG21 : nodeKey SsmF.s173.aux.ffi 21 = some ([4, 5, 3, 30, 0], [14, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12)
kernel_rfl SsmF.firstG22 : nodeKey SsmF.s173.aux.ffi 22 = some ([4, 5, 3, 30, 1], [14, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12)
kernel_rfl SsmF.firstG23 : nodeKey SsmF.s173.aux.ffi 23 = some ([4, 5, 3, 30, 2], [14, 1, 2], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12)
kernel_rfl SsmF.firstG24 : nodeKey SsmF.s173.aux.ffi 24 = some ([12, 115, 105, 103, 109, 111, 105, 100], [8], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl SsmF.firstG25 : nodeKey SsmF.s173.aux.ffi 25 = some ([9, 0], [], [(.lit 48)], 12)
kernel_rfl SsmF.firstG26 : nodeKey SsmF.s173.aux.ffi 26 = some ([9, 1], [], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl SsmF.firstG27 : nodeKey SsmF.s173.aux.ffi 27 = some ([9, 2], [], [(.lit 48)], 12)
kernel_rfl SsmF.firstG28 : nodeKey SsmF.s173.aux.ffi 28 = some ([11, 10], [25], [(.lit 48)], 10)
kernel_rfl SsmF.firstG29 : nodeKey SsmF.s173.aux.ffi 29 = some ([12, 101, 120, 112], [28], [(.lit 48)], 10)
kernel_rfl SsmF.firstG30 : nodeKey SsmF.s173.aux.ffi 30 = some ([12, 110, 101, 103, 97, 116, 105, 118, 101], [29], [(.lit 48)], 10)
kernel_rfl SsmF.firstG31 : nodeKey SsmF.s173.aux.ffi 31 = some ([13, 97, 100, 100], [26, 27], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl SsmF.firstG32 : nodeKey SsmF.s173.aux.ffi 32 = some ([10], [], [], 12)
kernel_rfl SsmF.firstG33 : nodeKey SsmF.s173.aux.ffi 33 = some ([13, 108, 111, 103, 97, 100, 100, 101, 120, 112], [31, 32], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl SsmF.firstG34 : nodeKey SsmF.s173.aux.ffi 34 = some ([13, 109, 117, 108, 116, 105, 112, 108, 121], [30, 33], [(.lit 1), (.lit 1), (.lit 48)], 10)
kernel_rfl SsmF.firstG35 : nodeKey SsmF.s173.aux.ffi 35 = some ([12, 101, 120, 112], [34], [(.lit 1), (.lit 1), (.lit 48)], 10)
kernel_rfl SsmF.firstG36 : nodeKey SsmF.s173.aux.ffi 36 = some ([4, 42, 11, 10], [4], [(.lit 48)], 10)
kernel_rfl SsmF.firstG37 : nodeKey SsmF.s173.aux.ffi 37 = some ([4, 42, 12, 101, 120, 112], [36], [(.lit 48)], 10)
kernel_rfl SsmF.firstG38 : nodeKey SsmF.s173.aux.ffi 38 = some ([4, 42, 12, 110, 101, 103, 97, 116, 105, 118, 101], [37], [(.lit 48)], 10)
kernel_rfl SsmF.firstG39 : nodeKey SsmF.s173.aux.ffi 39 = some ([4, 42, 13, 97, 100, 100], [7, 5], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl SsmF.firstG40 : nodeKey SsmF.s173.aux.ffi 40 = some ([4, 42, 13, 108, 111, 103, 97, 100, 100, 101, 120, 112], [39, 32], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl SsmF.firstG41 : nodeKey SsmF.s173.aux.ffi 41 = some ([4, 42, 13, 109, 117, 108, 116, 105, 112, 108, 121], [38, 40], [(.lit 1), (.lit 1), (.lit 48)], 10)
kernel_rfl SsmF.firstG42 : nodeKey SsmF.s173.aux.ffi 42 = some ([4, 42, 12, 101, 120, 112], [41], [(.lit 1), (.lit 1), (.lit 48)], 10)
kernel_rfl SsmF.firstG43 : nodeKey SsmF.s173.aux.ffi 43 = some ([5], [], [(.lit 1), (.lit 48), (.lit 128), (.lit 128)], 10)
kernel_rfl SsmF.firstG44 : nodeKey SsmF.s173.aux.ffi 44 = some ([10], [], [(.lit 1)], 7)
kernel_rfl SsmF.firstG45 : nodeKey SsmF.s173.aux.ffi 45 = some ([3, 63, 0], [21, 22, 23, 42, 24, 43, 44], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12)
kernel_rfl SsmF.firstG46 : nodeKey SsmF.s173.aux.ffi 46 = some ([3, 63, 1], [21, 22, 23, 42, 24, 43, 44], [(.lit 1), (.lit 48), (.lit 128), (.lit 128)], 10)
kernel_rfl SsmF.firstK30 : kernelName SsmF.s173.aux.ffi 30 = some chars!"mlx_bun_silu_rms_heads"
kernel_rfl SsmF.firstK63 : kernelName SsmF.s173.aux.ffi 63 = some chars!"gated_delta_step"

/-- **`recurDecode` (SsmF.first)** (parameter: the offset `o`). -/
def SsmF.firstStage : Stage MF where
  Par := Nat
  Pre o t C := o < 2 ^ 51 ∧ t = tplN SsmF.s4 0 [] ∧ C = ⟨SsmF.S4.tab.map (SymE.eval (ρ1 o))⟩
  Post _ t _ t' C' := SsmPost 1868 [(425, 426), (430, 431), (434, 435), (452, 453), (455, 456), (470, 471), (1368, 1369), (1451, 1452), (1868, 1869), (1891, 1892), (1917, 1918), (1943, 1944)] [(11, 0), (12, 0), (13, 0), (14, 0), (16, 0), (17, 0), (18, 12), (19, 13), (20, 0), (25, 0), (26, 0), (27, 0), (34, 0), (35, 0), (36, 0), (37, 0), (38, 0), (39, 0), (40, 0), (47, 0), (48, 0), (49, 0), (50, 0), (51, 0), (52, 0), (53, 0), (54, 0), (55, 0), (56, 0), (57, 0), (58, 0), (59, 0), (60, 0), (67, 45), (68, 46)] 19 68 67 (.num (.lit (F64.fin false 1 0))) (1) SsmF.firstG t t' C'

theorem SsmF.firstHolds : SsmF.firstStage.Holds := by
  rintro o t Cs ⟨ho, rfl, rfl⟩
  have hi : Inst (ρ1 o) SsmF.S4 ⟨SsmF.S4.tab.map (SymE.eval (ρ1 o))⟩ := ⟨rfl, by rw [SsmF.firstSrv]; intro q hq; simp [SsmF.O] at hq⟩
  obtain ⟨_, hrun⟩ := tplN_sim SsmF.first hi
  refine ⟨16738, tplN SsmF.s173 0 [], ⟨SsmF.S173.tab.map (SymE.eval (ρ1 o))⟩, ⟨?_, SsmF.firstOff, ?_, ⟨_, SsmF.firstConv, SsmF.firstConvH⟩,
    ⟨_, SsmF.firstRec, SsmF.firstRecH⟩, ⟨3516, SsmF.firstRet, Nat.le_of_ble_eq_true SsmF.firstFresh, SsmF.firstRetH⟩, ⟨SsmF.firstHy, SsmF.firstHc, SsmF.firstHr, SsmF.firstG9, SsmF.firstG10, SsmF.firstG11, SsmF.firstG12, SsmF.firstG13, SsmF.firstG14, SsmF.firstG15, SsmF.firstG16, SsmF.firstG17, SsmF.firstG18, SsmF.firstG19, SsmF.firstG20, SsmF.firstG21, SsmF.firstG22, SsmF.firstG23, SsmF.firstG24, SsmF.firstG25, SsmF.firstG26, SsmF.firstG27, SsmF.firstG28, SsmF.firstG29, SsmF.firstG30, SsmF.firstG31, SsmF.firstG32, SsmF.firstG33, SsmF.firstG34, SsmF.firstG35, SsmF.firstG36, SsmF.firstG37, SsmF.firstG38, SsmF.firstG39, SsmF.firstG40, SsmF.firstG41, SsmF.firstG42, SsmF.firstG43, SsmF.firstG44, SsmF.firstG45, SsmF.firstG46, SsmF.firstK30, SsmF.firstK63⟩⟩, hrun⟩
  · exact framedW_of SsmF.firstHeap SsmF.firstNextLe SsmF.firstSmall (by decide) SsmF.firstJobs SsmF.firstStores SsmF.firstTrace
      ⟨liveDelta_setAll SsmF.firstArrs (by decide) (by decide), nodesKept_of SsmF.firstNodes SsmF.firstNSmall⟩
  · exact natAt_one _

/-! ## `evalCacheState` after `SsmF.first` -/

kernel_rfl SsmF.evalArrs : SsmF.s176.aux.ffi.arrs = SsmF.s174.aux.ffi.arrs
kernel_rfl SsmF.evalNodes : SsmF.s176.aux.ffi.nodes = SsmF.s174.aux.ffi.nodes
kernel_rfl SsmF.evalHeap : SsmF.s176.heap = setAll SsmF.s174.heap (rangesOf SsmF.s176.heap [] ++ freshOf SsmF.s176.heap SsmF.s174.next SsmF.s176.next)
kernel_rfl SsmF.evalNextLe : Nat.ble SsmF.s174.next SsmF.s176.next = true
kernel_rfl SsmF.evalSmall : Nat.blt SsmF.s176.next 1048576 = true
kernel_rfl SsmF.evalJobs : SsmF.s176.aux.jobs = SsmF.s174.aux.jobs
kernel_rfl SsmF.evalStores : SsmF.s176.aux.stores = SsmF.s174.aux.stores
kernel_rfl SsmF.evalTrace : SsmF.s176.aux.trace = SsmF.s176.aux.trace.take 3 ++ SsmF.s174.aux.trace
kernel_rfl SsmF.evalSyms : (SsmF.s176.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl SsmF.evalVec : SsmF.s176.aux.ffi.objs.get SsmF.s174.aux.ffi.next = some (.vec [13, 46])

/-- **`evalCacheState` (SsmF.eval)** (parameter: the valuation). -/
def SsmF.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN SsmF.s174 0 [] ∧ Inst ρ SsmF.S174 C
  Post ρ t _ t' C' := EvalPost [13, 46] t t' ∧ Inst ρ SsmF.S176 C'

theorem SsmF.evalHolds : SsmF.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim SsmF.eval hi
  exact ⟨992, tplN SsmF.s176 0 [], _, ⟨⟨framedW_of SsmF.evalHeap SsmF.evalNextLe SsmF.evalSmall (by decide) SsmF.evalJobs SsmF.evalStores SsmF.evalTrace
    ⟨SsmF.evalArrs, SsmF.evalNodes⟩, SsmF.evalSyms, SsmF.evalVec⟩, hi'⟩, hrun⟩

/-! ## `recurDecode`, class `Ssm.cold`: states present, fresh memos: both closures traced at one row -/

/-- The graph of class `Ssm.cold`: the output, `#conv` and `#recurrent` handles' nodes, every node the call adds, the kernels. -/
def Ssm.coldG (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 67 = y.nodes.get 45 ∧
    y.node? 20 = y.nodes.get 14 ∧
    y.node? 68 = y.nodes.get 46 ∧
    nodeKey y 11 = some ([8, 1], [6, 8], [(.lit 1), (.lit 4), (.lit 10240)], 12) ∧
    nodeKey y 12 = some ([6], [11], [(.lit 1), (.lit 3), (.lit 10240)], 12) ∧
    nodeKey y 13 = some ([10], [], [], 7) ∧
    nodeKey y 14 = some ([15, 0], [12, 13], [(.lit 1), (.lit 3), (.lit 10240)], 12) ∧
    nodeKey y 15 = some ([14, 1, 0, 1, 10240], [11, 3], [(.lit 1), (.lit 1), (.lit 10240)], 12) ∧
    nodeKey y 16 = some ([9, 0], [], [(.lit 1), (.lit 1), (.lit 10240)], 12) ∧
    nodeKey y 17 = some ([9, 1], [], [(.lit 128)], 12) ∧
    nodeKey y 18 = some ([9, 2], [], [(.lit 128)], 12) ∧
    nodeKey y 19 = some ([3, 31, 0], [16, 17, 18], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12) ∧
    nodeKey y 20 = some ([3, 31, 1], [16, 17, 18], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12) ∧
    nodeKey y 21 = some ([3, 31, 2], [16, 17, 18], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12) ∧
    nodeKey y 22 = some ([4, 5, 3, 31, 0], [15, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12) ∧
    nodeKey y 23 = some ([4, 5, 3, 31, 1], [15, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12) ∧
    nodeKey y 24 = some ([4, 5, 3, 31, 2], [15, 1, 2], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12) ∧
    nodeKey y 25 = some ([12, 115, 105, 103, 109, 111, 105, 100], [10], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 26 = some ([9, 0], [], [(.lit 48)], 12) ∧
    nodeKey y 27 = some ([9, 1], [], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 28 = some ([9, 2], [], [(.lit 48)], 12) ∧
    nodeKey y 29 = some ([11, 10], [26], [(.lit 48)], 10) ∧
    nodeKey y 30 = some ([12, 101, 120, 112], [29], [(.lit 48)], 10) ∧
    nodeKey y 31 = some ([12, 110, 101, 103, 97, 116, 105, 118, 101], [30], [(.lit 48)], 10) ∧
    nodeKey y 32 = some ([13, 97, 100, 100], [27, 28], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 33 = some ([10], [], [], 12) ∧
    nodeKey y 34 = some ([13, 108, 111, 103, 97, 100, 100, 101, 120, 112], [32, 33], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 35 = some ([13, 109, 117, 108, 116, 105, 112, 108, 121], [31, 34], [(.lit 1), (.lit 1), (.lit 48)], 10) ∧
    nodeKey y 36 = some ([12, 101, 120, 112], [35], [(.lit 1), (.lit 1), (.lit 48)], 10) ∧
    nodeKey y 37 = some ([4, 43, 11, 10], [4], [(.lit 48)], 10) ∧
    nodeKey y 38 = some ([4, 43, 12, 101, 120, 112], [37], [(.lit 48)], 10) ∧
    nodeKey y 39 = some ([4, 43, 12, 110, 101, 103, 97, 116, 105, 118, 101], [38], [(.lit 48)], 10) ∧
    nodeKey y 40 = some ([4, 43, 13, 97, 100, 100], [9, 5], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 41 = some ([4, 43, 13, 108, 111, 103, 97, 100, 100, 101, 120, 112], [40, 33], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 42 = some ([4, 43, 13, 109, 117, 108, 116, 105, 112, 108, 121], [39, 41], [(.lit 1), (.lit 1), (.lit 48)], 10) ∧
    nodeKey y 43 = some ([4, 43, 12, 101, 120, 112], [42], [(.lit 1), (.lit 1), (.lit 48)], 10) ∧
    nodeKey y 44 = some ([10], [], [(.lit 1)], 7) ∧
    nodeKey y 45 = some ([3, 63, 0], [22, 23, 24, 43, 25, 7, 44], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12) ∧
    nodeKey y 46 = some ([3, 63, 1], [22, 23, 24, 43, 25, 7, 44], [(.lit 1), (.lit 48), (.lit 128), (.lit 128)], 10) ∧
    kernelName y 31 = some chars!"mlx_bun_silu_rms_heads" ∧
    kernelName y 63 = some chars!"gated_delta_step"

kernel_rfl Ssm.coldSrv : Ssm.S4.oracle = Ssm.O
kernel_rfl Ssm.coldArrs : Ssm.s168.aux.ffi.arrs = setAll Ssm.s4.aux.ffi.arrs [(11, 0), (12, 0), (13, 0), (14, 0), (15, 0), (17, 0), (18, 0), (19, 13), (20, 14), (21, 0), (26, 0), (27, 0), (28, 0), (35, 0), (36, 0), (37, 0), (38, 0), (39, 0), (40, 0), (41, 0), (48, 0), (49, 0), (50, 0), (51, 0), (52, 0), (53, 0), (54, 0), (55, 0), (56, 0), (57, 0), (58, 0), (59, 0), (60, 0), (67, 45), (68, 46)]
kernel_rfl Ssm.coldNodes : Ssm.s168.aux.ffi.nodes = setAll Ssm.s4.aux.ffi.nodes (freshOf Ssm.s168.aux.ffi.nodes Ssm.s4.aux.ffi.nnext Ssm.s168.aux.ffi.nnext)
kernel_rfl Ssm.coldNSmall : Nat.blt Ssm.s168.aux.ffi.nnext 1048576 = true
kernel_rfl Ssm.coldHeap : Ssm.s168.heap = setAll Ssm.s4.heap (rangesOf Ssm.s168.heap [(425, 426), (430, 431), (434, 435), (452, 453), (455, 456), (470, 471), (1369, 1370), (1452, 1453), (1869, 1870), (1892, 1893), (1926, 1927), (1960, 1961), (1986, 1987), (2012, 2013)] ++ freshOf Ssm.s168.heap Ssm.s4.next Ssm.s168.next)
kernel_rfl Ssm.coldNextLe : Nat.ble Ssm.s4.next Ssm.s168.next = true
kernel_rfl Ssm.coldSmall : Nat.blt Ssm.s168.next 1048576 = true
kernel_rfl Ssm.coldJobs : Ssm.s168.aux.jobs = Ssm.s4.aux.jobs
kernel_rfl Ssm.coldStores : Ssm.s168.aux.stores = Ssm.s4.aux.stores
kernel_rfl Ssm.coldTrace : Ssm.s168.aux.trace = Ssm.s168.aux.trace.take (Ssm.s168.aux.trace.length - Ssm.s4.aux.trace.length) ++ Ssm.s4.aux.trace
kernel_rfl Ssm.coldOff : propOf (Ssm.s168.obj? 1869) chars!"offset" = some (.num (.ref 1))
kernel_rfl Ssm.coldOffE : nth? Ssm.S168.tab 1 = some (Host.Ts.SymE.bin Host.Ts.NBin.add (Host.Ts.SymE.var 0) (Host.Ts.SymE.lit (Host.Ts.F64.fin false 1 0)))
kernel_rfl Ssm.coldConv : privOf (Ssm.s168.obj? 1869) chars!"conv" = some (.obj 2292)
kernel_rfl Ssm.coldConvH : handleOf (Ssm.s168.obj? 2292) = some 20
kernel_rfl Ssm.coldRec : privOf (Ssm.s168.obj? 1869) chars!"recurrent" = some (.obj 3535)
kernel_rfl Ssm.coldRecH : handleOf (Ssm.s168.obj? 3535) = some 68
kernel_rfl Ssm.coldRet : Ssm.s168.ctl = .ret (.obj 3529)
kernel_rfl Ssm.coldFresh : Nat.ble Ssm.s4.next 3529 = true
kernel_rfl Ssm.coldRetH : handleOf (Ssm.s168.obj? 3529) = some 67
kernel_rfl Ssm.coldHy : Ssm.s168.aux.ffi.node? 67 = Ssm.s168.aux.ffi.nodes.get 45
kernel_rfl Ssm.coldHc : Ssm.s168.aux.ffi.node? 20 = Ssm.s168.aux.ffi.nodes.get 14
kernel_rfl Ssm.coldHr : Ssm.s168.aux.ffi.node? 68 = Ssm.s168.aux.ffi.nodes.get 46
kernel_rfl Ssm.coldG11 : nodeKey Ssm.s168.aux.ffi 11 = some ([8, 1], [6, 8], [(.lit 1), (.lit 4), (.lit 10240)], 12)
kernel_rfl Ssm.coldG12 : nodeKey Ssm.s168.aux.ffi 12 = some ([6], [11], [(.lit 1), (.lit 3), (.lit 10240)], 12)
kernel_rfl Ssm.coldG13 : nodeKey Ssm.s168.aux.ffi 13 = some ([10], [], [], 7)
kernel_rfl Ssm.coldG14 : nodeKey Ssm.s168.aux.ffi 14 = some ([15, 0], [12, 13], [(.lit 1), (.lit 3), (.lit 10240)], 12)
kernel_rfl Ssm.coldG15 : nodeKey Ssm.s168.aux.ffi 15 = some ([14, 1, 0, 1, 10240], [11, 3], [(.lit 1), (.lit 1), (.lit 10240)], 12)
kernel_rfl Ssm.coldG16 : nodeKey Ssm.s168.aux.ffi 16 = some ([9, 0], [], [(.lit 1), (.lit 1), (.lit 10240)], 12)
kernel_rfl Ssm.coldG17 : nodeKey Ssm.s168.aux.ffi 17 = some ([9, 1], [], [(.lit 128)], 12)
kernel_rfl Ssm.coldG18 : nodeKey Ssm.s168.aux.ffi 18 = some ([9, 2], [], [(.lit 128)], 12)
kernel_rfl Ssm.coldG19 : nodeKey Ssm.s168.aux.ffi 19 = some ([3, 31, 0], [16, 17, 18], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12)
kernel_rfl Ssm.coldG20 : nodeKey Ssm.s168.aux.ffi 20 = some ([3, 31, 1], [16, 17, 18], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12)
kernel_rfl Ssm.coldG21 : nodeKey Ssm.s168.aux.ffi 21 = some ([3, 31, 2], [16, 17, 18], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12)
kernel_rfl Ssm.coldG22 : nodeKey Ssm.s168.aux.ffi 22 = some ([4, 5, 3, 31, 0], [15, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12)
kernel_rfl Ssm.coldG23 : nodeKey Ssm.s168.aux.ffi 23 = some ([4, 5, 3, 31, 1], [15, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12)
kernel_rfl Ssm.coldG24 : nodeKey Ssm.s168.aux.ffi 24 = some ([4, 5, 3, 31, 2], [15, 1, 2], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12)
kernel_rfl Ssm.coldG25 : nodeKey Ssm.s168.aux.ffi 25 = some ([12, 115, 105, 103, 109, 111, 105, 100], [10], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl Ssm.coldG26 : nodeKey Ssm.s168.aux.ffi 26 = some ([9, 0], [], [(.lit 48)], 12)
kernel_rfl Ssm.coldG27 : nodeKey Ssm.s168.aux.ffi 27 = some ([9, 1], [], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl Ssm.coldG28 : nodeKey Ssm.s168.aux.ffi 28 = some ([9, 2], [], [(.lit 48)], 12)
kernel_rfl Ssm.coldG29 : nodeKey Ssm.s168.aux.ffi 29 = some ([11, 10], [26], [(.lit 48)], 10)
kernel_rfl Ssm.coldG30 : nodeKey Ssm.s168.aux.ffi 30 = some ([12, 101, 120, 112], [29], [(.lit 48)], 10)
kernel_rfl Ssm.coldG31 : nodeKey Ssm.s168.aux.ffi 31 = some ([12, 110, 101, 103, 97, 116, 105, 118, 101], [30], [(.lit 48)], 10)
kernel_rfl Ssm.coldG32 : nodeKey Ssm.s168.aux.ffi 32 = some ([13, 97, 100, 100], [27, 28], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl Ssm.coldG33 : nodeKey Ssm.s168.aux.ffi 33 = some ([10], [], [], 12)
kernel_rfl Ssm.coldG34 : nodeKey Ssm.s168.aux.ffi 34 = some ([13, 108, 111, 103, 97, 100, 100, 101, 120, 112], [32, 33], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl Ssm.coldG35 : nodeKey Ssm.s168.aux.ffi 35 = some ([13, 109, 117, 108, 116, 105, 112, 108, 121], [31, 34], [(.lit 1), (.lit 1), (.lit 48)], 10)
kernel_rfl Ssm.coldG36 : nodeKey Ssm.s168.aux.ffi 36 = some ([12, 101, 120, 112], [35], [(.lit 1), (.lit 1), (.lit 48)], 10)
kernel_rfl Ssm.coldG37 : nodeKey Ssm.s168.aux.ffi 37 = some ([4, 43, 11, 10], [4], [(.lit 48)], 10)
kernel_rfl Ssm.coldG38 : nodeKey Ssm.s168.aux.ffi 38 = some ([4, 43, 12, 101, 120, 112], [37], [(.lit 48)], 10)
kernel_rfl Ssm.coldG39 : nodeKey Ssm.s168.aux.ffi 39 = some ([4, 43, 12, 110, 101, 103, 97, 116, 105, 118, 101], [38], [(.lit 48)], 10)
kernel_rfl Ssm.coldG40 : nodeKey Ssm.s168.aux.ffi 40 = some ([4, 43, 13, 97, 100, 100], [9, 5], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl Ssm.coldG41 : nodeKey Ssm.s168.aux.ffi 41 = some ([4, 43, 13, 108, 111, 103, 97, 100, 100, 101, 120, 112], [40, 33], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl Ssm.coldG42 : nodeKey Ssm.s168.aux.ffi 42 = some ([4, 43, 13, 109, 117, 108, 116, 105, 112, 108, 121], [39, 41], [(.lit 1), (.lit 1), (.lit 48)], 10)
kernel_rfl Ssm.coldG43 : nodeKey Ssm.s168.aux.ffi 43 = some ([4, 43, 12, 101, 120, 112], [42], [(.lit 1), (.lit 1), (.lit 48)], 10)
kernel_rfl Ssm.coldG44 : nodeKey Ssm.s168.aux.ffi 44 = some ([10], [], [(.lit 1)], 7)
kernel_rfl Ssm.coldG45 : nodeKey Ssm.s168.aux.ffi 45 = some ([3, 63, 0], [22, 23, 24, 43, 25, 7, 44], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12)
kernel_rfl Ssm.coldG46 : nodeKey Ssm.s168.aux.ffi 46 = some ([3, 63, 1], [22, 23, 24, 43, 25, 7, 44], [(.lit 1), (.lit 48), (.lit 128), (.lit 128)], 10)
kernel_rfl Ssm.coldK31 : kernelName Ssm.s168.aux.ffi 31 = some chars!"mlx_bun_silu_rms_heads"
kernel_rfl Ssm.coldK63 : kernelName Ssm.s168.aux.ffi 63 = some chars!"gated_delta_step"

/-- **`recurDecode` (Ssm.cold)** (parameter: the offset `o`). -/
def Ssm.coldStage : Stage MF where
  Par := Nat
  Pre o t C := o < 2 ^ 51 ∧ t = tplN Ssm.s4 0 [] ∧ C = ⟨Ssm.S4.tab.map (SymE.eval (ρ1 o))⟩
  Post o t _ t' C' := SsmPost 1869 [(425, 426), (430, 431), (434, 435), (452, 453), (455, 456), (470, 471), (1369, 1370), (1452, 1453), (1869, 1870), (1892, 1893), (1926, 1927), (1960, 1961), (1986, 1987), (2012, 2013)] [(11, 0), (12, 0), (13, 0), (14, 0), (15, 0), (17, 0), (18, 0), (19, 13), (20, 14), (21, 0), (26, 0), (27, 0), (28, 0), (35, 0), (36, 0), (37, 0), (38, 0), (39, 0), (40, 0), (41, 0), (48, 0), (49, 0), (50, 0), (51, 0), (52, 0), (53, 0), (54, 0), (55, 0), (56, 0), (57, 0), (58, 0), (59, 0), (60, 0), (67, 45), (68, 46)] 20 68 67 (.num (.ref 1)) (o + 1) Ssm.coldG t t' C'

theorem Ssm.coldHolds : Ssm.coldStage.Holds := by
  rintro o t Cs ⟨ho, rfl, rfl⟩
  have hi : Inst (ρ1 o) Ssm.S4 ⟨Ssm.S4.tab.map (SymE.eval (ρ1 o))⟩ := ⟨rfl, by rw [Ssm.coldSrv]; intro q hq; simp [Ssm.O] at hq⟩
  obtain ⟨_, hrun⟩ := tplN_sim Ssm.cold hi
  refine ⟨16264, tplN Ssm.s168 0 [], ⟨Ssm.S168.tab.map (SymE.eval (ρ1 o))⟩, ⟨?_, Ssm.coldOff, ?_, ⟨_, Ssm.coldConv, Ssm.coldConvH⟩,
    ⟨_, Ssm.coldRec, Ssm.coldRecH⟩, ⟨3529, Ssm.coldRet, Nat.le_of_ble_eq_true Ssm.coldFresh, Ssm.coldRetH⟩, ⟨Ssm.coldHy, Ssm.coldHc, Ssm.coldHr, Ssm.coldG11, Ssm.coldG12, Ssm.coldG13, Ssm.coldG14, Ssm.coldG15, Ssm.coldG16, Ssm.coldG17, Ssm.coldG18, Ssm.coldG19, Ssm.coldG20, Ssm.coldG21, Ssm.coldG22, Ssm.coldG23, Ssm.coldG24, Ssm.coldG25, Ssm.coldG26, Ssm.coldG27, Ssm.coldG28, Ssm.coldG29, Ssm.coldG30, Ssm.coldG31, Ssm.coldG32, Ssm.coldG33, Ssm.coldG34, Ssm.coldG35, Ssm.coldG36, Ssm.coldG37, Ssm.coldG38, Ssm.coldG39, Ssm.coldG40, Ssm.coldG41, Ssm.coldG42, Ssm.coldG43, Ssm.coldG44, Ssm.coldG45, Ssm.coldG46, Ssm.coldK31, Ssm.coldK63⟩⟩, hrun⟩
  · exact framedW_of Ssm.coldHeap Ssm.coldNextLe Ssm.coldSmall (by decide) Ssm.coldJobs Ssm.coldStores Ssm.coldTrace
      ⟨liveDelta_setAll Ssm.coldArrs (by decide) (by decide), nodesKept_of Ssm.coldNodes Ssm.coldNSmall⟩
  · exact natAt_ref (by rw [nth_inst Ssm.coldOffE]; exact congrArg some (eval_o1 o (by omega))) (by omega)

/-! ## `recurDecode`, class `Ssm.warm`: the steady decode call: memos filled, both closures replayed -/

/-- The graph of class `Ssm.warm`: the output, `#conv` and `#recurrent` handles' nodes, every node the call adds, the kernels. -/
def Ssm.warmG (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 90 = y.nodes.get 66 ∧
    y.node? 75 = y.nodes.get 52 ∧
    y.node? 91 = y.nodes.get 67 ∧
    nodeKey y 50 = some ([8, 1], [14, 47], [(.lit 1), (.lit 4), (.lit 10240)], 12) ∧
    nodeKey y 51 = some ([6], [50], [(.lit 1), (.lit 3), (.lit 10240)], 12) ∧
    nodeKey y 52 = some ([15, 0], [51, 13], [(.lit 1), (.lit 3), (.lit 10240)], 12) ∧
    nodeKey y 53 = some ([14, 1, 0, 1, 10240], [50, 3], [(.lit 1), (.lit 1), (.lit 10240)], 12) ∧
    nodeKey y 54 = some ([4, 5, 3, 31, 0], [53, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12) ∧
    nodeKey y 55 = some ([4, 5, 3, 31, 1], [53, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12) ∧
    nodeKey y 56 = some ([4, 5, 3, 31, 2], [53, 1, 2], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12) ∧
    nodeKey y 57 = some ([12, 115, 105, 103, 109, 111, 105, 100], [49], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 58 = some ([4, 43, 11, 10], [4], [(.lit 48)], 10) ∧
    nodeKey y 59 = some ([4, 43, 12, 101, 120, 112], [58], [(.lit 48)], 10) ∧
    nodeKey y 60 = some ([4, 43, 12, 110, 101, 103, 97, 116, 105, 118, 101], [59], [(.lit 48)], 10) ∧
    nodeKey y 61 = some ([4, 43, 13, 97, 100, 100], [48, 5], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 62 = some ([4, 43, 13, 108, 111, 103, 97, 100, 100, 101, 120, 112], [61, 33], [(.lit 1), (.lit 1), (.lit 48)], 12) ∧
    nodeKey y 63 = some ([4, 43, 13, 109, 117, 108, 116, 105, 112, 108, 121], [60, 62], [(.lit 1), (.lit 1), (.lit 48)], 10) ∧
    nodeKey y 64 = some ([4, 43, 12, 101, 120, 112], [63], [(.lit 1), (.lit 1), (.lit 48)], 10) ∧
    nodeKey y 65 = some ([10], [], [(.lit 1)], 7) ∧
    nodeKey y 66 = some ([3, 63, 0], [54, 55, 56, 64, 57, 46, 65], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12) ∧
    nodeKey y 67 = some ([3, 63, 1], [54, 55, 56, 64, 57, 46, 65], [(.lit 1), (.lit 48), (.lit 128), (.lit 128)], 10) ∧
    kernelName y 31 = some chars!"mlx_bun_silu_rms_heads" ∧
    kernelName y 63 = some chars!"gated_delta_step"

kernel_rfl Ssm.warmSrv : Ssm.S169.oracle = Ssm.O
kernel_rfl Ssm.warmArrs : Ssm.s242.aux.ffi.arrs = setAll Ssm.s169.aux.ffi.arrs [(20, 0), (68, 0), (69, 0), (70, 0), (71, 0), (73, 0), (74, 0), (75, 52), (76, 0), (79, 0), (80, 0), (81, 0), (82, 0), (85, 0), (86, 0), (90, 66), (91, 67)]
kernel_rfl Ssm.warmNodes : Ssm.s242.aux.ffi.nodes = setAll Ssm.s169.aux.ffi.nodes (freshOf Ssm.s242.aux.ffi.nodes Ssm.s169.aux.ffi.nnext Ssm.s242.aux.ffi.nnext)
kernel_rfl Ssm.warmNSmall : Nat.blt Ssm.s242.aux.ffi.nnext 1048576 = true
kernel_rfl Ssm.warmHeap : Ssm.s242.heap = setAll Ssm.s169.heap (rangesOf Ssm.s242.heap [(1869, 1870), (2292, 2293), (3535, 3536), (3595, 3596), (3621, 3622), (3647, 3648)] ++ freshOf Ssm.s242.heap Ssm.s169.next Ssm.s242.next)
kernel_rfl Ssm.warmNextLe : Nat.ble Ssm.s169.next Ssm.s242.next = true
kernel_rfl Ssm.warmSmall : Nat.blt Ssm.s242.next 1048576 = true
kernel_rfl Ssm.warmJobs : Ssm.s242.aux.jobs = Ssm.s169.aux.jobs
kernel_rfl Ssm.warmStores : Ssm.s242.aux.stores = Ssm.s169.aux.stores
kernel_rfl Ssm.warmTrace : Ssm.s242.aux.trace = Ssm.s242.aux.trace.take (Ssm.s242.aux.trace.length - Ssm.s169.aux.trace.length) ++ Ssm.s169.aux.trace
kernel_rfl Ssm.warmOff : propOf (Ssm.s242.obj? 1869) chars!"offset" = some (.num (.ref 2))
kernel_rfl Ssm.warmOffE : nth? Ssm.S242.tab 2 = some (Host.Ts.SymE.bin Host.Ts.NBin.add (Host.Ts.SymE.bin Host.Ts.NBin.add (Host.Ts.SymE.var 0) (Host.Ts.SymE.lit (Host.Ts.F64.fin false 1 0))) (Host.Ts.SymE.lit (Host.Ts.F64.fin false 1 0)))
kernel_rfl Ssm.warmConv : privOf (Ssm.s242.obj? 1869) chars!"conv" = some (.obj 3909)
kernel_rfl Ssm.warmConvH : handleOf (Ssm.s242.obj? 3909) = some 75
kernel_rfl Ssm.warmRec : privOf (Ssm.s242.obj? 1869) chars!"recurrent" = some (.obj 4335)
kernel_rfl Ssm.warmRecH : handleOf (Ssm.s242.obj? 4335) = some 91
kernel_rfl Ssm.warmRet : Ssm.s242.ctl = .ret (.obj 4329)
kernel_rfl Ssm.warmFresh : Nat.ble Ssm.s169.next 4329 = true
kernel_rfl Ssm.warmRetH : handleOf (Ssm.s242.obj? 4329) = some 90
kernel_rfl Ssm.warmHy : Ssm.s242.aux.ffi.node? 90 = Ssm.s242.aux.ffi.nodes.get 66
kernel_rfl Ssm.warmHc : Ssm.s242.aux.ffi.node? 75 = Ssm.s242.aux.ffi.nodes.get 52
kernel_rfl Ssm.warmHr : Ssm.s242.aux.ffi.node? 91 = Ssm.s242.aux.ffi.nodes.get 67
kernel_rfl Ssm.warmG50 : nodeKey Ssm.s242.aux.ffi 50 = some ([8, 1], [14, 47], [(.lit 1), (.lit 4), (.lit 10240)], 12)
kernel_rfl Ssm.warmG51 : nodeKey Ssm.s242.aux.ffi 51 = some ([6], [50], [(.lit 1), (.lit 3), (.lit 10240)], 12)
kernel_rfl Ssm.warmG52 : nodeKey Ssm.s242.aux.ffi 52 = some ([15, 0], [51, 13], [(.lit 1), (.lit 3), (.lit 10240)], 12)
kernel_rfl Ssm.warmG53 : nodeKey Ssm.s242.aux.ffi 53 = some ([14, 1, 0, 1, 10240], [50, 3], [(.lit 1), (.lit 1), (.lit 10240)], 12)
kernel_rfl Ssm.warmG54 : nodeKey Ssm.s242.aux.ffi 54 = some ([4, 5, 3, 31, 0], [53, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12)
kernel_rfl Ssm.warmG55 : nodeKey Ssm.s242.aux.ffi 55 = some ([4, 5, 3, 31, 1], [53, 1, 2], [(.lit 1), (.lit 1), (.lit 16), (.lit 128)], 12)
kernel_rfl Ssm.warmG56 : nodeKey Ssm.s242.aux.ffi 56 = some ([4, 5, 3, 31, 2], [53, 1, 2], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12)
kernel_rfl Ssm.warmG57 : nodeKey Ssm.s242.aux.ffi 57 = some ([12, 115, 105, 103, 109, 111, 105, 100], [49], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl Ssm.warmG58 : nodeKey Ssm.s242.aux.ffi 58 = some ([4, 43, 11, 10], [4], [(.lit 48)], 10)
kernel_rfl Ssm.warmG59 : nodeKey Ssm.s242.aux.ffi 59 = some ([4, 43, 12, 101, 120, 112], [58], [(.lit 48)], 10)
kernel_rfl Ssm.warmG60 : nodeKey Ssm.s242.aux.ffi 60 = some ([4, 43, 12, 110, 101, 103, 97, 116, 105, 118, 101], [59], [(.lit 48)], 10)
kernel_rfl Ssm.warmG61 : nodeKey Ssm.s242.aux.ffi 61 = some ([4, 43, 13, 97, 100, 100], [48, 5], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl Ssm.warmG62 : nodeKey Ssm.s242.aux.ffi 62 = some ([4, 43, 13, 108, 111, 103, 97, 100, 100, 101, 120, 112], [61, 33], [(.lit 1), (.lit 1), (.lit 48)], 12)
kernel_rfl Ssm.warmG63 : nodeKey Ssm.s242.aux.ffi 63 = some ([4, 43, 13, 109, 117, 108, 116, 105, 112, 108, 121], [60, 62], [(.lit 1), (.lit 1), (.lit 48)], 10)
kernel_rfl Ssm.warmG64 : nodeKey Ssm.s242.aux.ffi 64 = some ([4, 43, 12, 101, 120, 112], [63], [(.lit 1), (.lit 1), (.lit 48)], 10)
kernel_rfl Ssm.warmG65 : nodeKey Ssm.s242.aux.ffi 65 = some ([10], [], [(.lit 1)], 7)
kernel_rfl Ssm.warmG66 : nodeKey Ssm.s242.aux.ffi 66 = some ([3, 63, 0], [54, 55, 56, 64, 57, 46, 65], [(.lit 1), (.lit 1), (.lit 48), (.lit 128)], 12)
kernel_rfl Ssm.warmG67 : nodeKey Ssm.s242.aux.ffi 67 = some ([3, 63, 1], [54, 55, 56, 64, 57, 46, 65], [(.lit 1), (.lit 48), (.lit 128), (.lit 128)], 10)
kernel_rfl Ssm.warmK31 : kernelName Ssm.s242.aux.ffi 31 = some chars!"mlx_bun_silu_rms_heads"
kernel_rfl Ssm.warmK63 : kernelName Ssm.s242.aux.ffi 63 = some chars!"gated_delta_step"

/-- **`recurDecode` (Ssm.warm)** (parameter: the offset `o`). -/
def Ssm.warmStage : Stage MF where
  Par := Nat
  Pre o t C := o < 2 ^ 51 ∧ t = tplN Ssm.s169 0 [] ∧ C = ⟨Ssm.S169.tab.map (SymE.eval (ρ1 o))⟩
  Post o t _ t' C' := SsmPost 1869 [(1869, 1870), (2292, 2293), (3535, 3536), (3595, 3596), (3621, 3622), (3647, 3648)] [(20, 0), (68, 0), (69, 0), (70, 0), (71, 0), (73, 0), (74, 0), (75, 52), (76, 0), (79, 0), (80, 0), (81, 0), (82, 0), (85, 0), (86, 0), (90, 66), (91, 67)] 75 91 90 (.num (.ref 2)) (o + 2) Ssm.warmG t t' C'

theorem Ssm.warmHolds : Ssm.warmStage.Holds := by
  rintro o t Cs ⟨ho, rfl, rfl⟩
  have hi : Inst (ρ1 o) Ssm.S169 ⟨Ssm.S169.tab.map (SymE.eval (ρ1 o))⟩ := ⟨rfl, by rw [Ssm.warmSrv]; intro q hq; simp [Ssm.O] at hq⟩
  obtain ⟨_, hrun⟩ := tplN_sim Ssm.warm hi
  refine ⟨7181, tplN Ssm.s242 0 [], ⟨Ssm.S242.tab.map (SymE.eval (ρ1 o))⟩, ⟨?_, Ssm.warmOff, ?_, ⟨_, Ssm.warmConv, Ssm.warmConvH⟩,
    ⟨_, Ssm.warmRec, Ssm.warmRecH⟩, ⟨4329, Ssm.warmRet, Nat.le_of_ble_eq_true Ssm.warmFresh, Ssm.warmRetH⟩, ⟨Ssm.warmHy, Ssm.warmHc, Ssm.warmHr, Ssm.warmG50, Ssm.warmG51, Ssm.warmG52, Ssm.warmG53, Ssm.warmG54, Ssm.warmG55, Ssm.warmG56, Ssm.warmG57, Ssm.warmG58, Ssm.warmG59, Ssm.warmG60, Ssm.warmG61, Ssm.warmG62, Ssm.warmG63, Ssm.warmG64, Ssm.warmG65, Ssm.warmG66, Ssm.warmG67, Ssm.warmK31, Ssm.warmK63⟩⟩, hrun⟩
  · exact framedW_of Ssm.warmHeap Ssm.warmNextLe Ssm.warmSmall (by decide) Ssm.warmJobs Ssm.warmStores Ssm.warmTrace
      ⟨liveDelta_setAll Ssm.warmArrs (by decide) (by decide), nodesKept_of Ssm.warmNodes Ssm.warmNSmall⟩
  · exact natAt_ref (by rw [nth_inst Ssm.warmOffE]; exact congrArg some (eval_o2 o (by omega))) (by omega)

/-! ## `evalCacheState` after `Ssm.warm` -/

kernel_rfl Ssm.evalArrs : Ssm.s245.aux.ffi.arrs = Ssm.s243.aux.ffi.arrs
kernel_rfl Ssm.evalNodes : Ssm.s245.aux.ffi.nodes = Ssm.s243.aux.ffi.nodes
kernel_rfl Ssm.evalHeap : Ssm.s245.heap = setAll Ssm.s243.heap (rangesOf Ssm.s245.heap [] ++ freshOf Ssm.s245.heap Ssm.s243.next Ssm.s245.next)
kernel_rfl Ssm.evalNextLe : Nat.ble Ssm.s243.next Ssm.s245.next = true
kernel_rfl Ssm.evalSmall : Nat.blt Ssm.s245.next 1048576 = true
kernel_rfl Ssm.evalJobs : Ssm.s245.aux.jobs = Ssm.s243.aux.jobs
kernel_rfl Ssm.evalStores : Ssm.s245.aux.stores = Ssm.s243.aux.stores
kernel_rfl Ssm.evalTrace : Ssm.s245.aux.trace = Ssm.s245.aux.trace.take 3 ++ Ssm.s243.aux.trace
kernel_rfl Ssm.evalSyms : (Ssm.s245.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl Ssm.evalVec : Ssm.s245.aux.ffi.objs.get Ssm.s243.aux.ffi.next = some (.vec [52, 67])

/-- **`evalCacheState` (Ssm.eval)** (parameter: the valuation). -/
def Ssm.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN Ssm.s243 0 [] ∧ Inst ρ Ssm.S243 C
  Post ρ t _ t' C' := EvalPost [52, 67] t t' ∧ Inst ρ Ssm.S245 C'

theorem Ssm.evalHolds : Ssm.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim Ssm.eval hi
  exact ⟨992, tplN Ssm.s245 0 [], _, ⟨⟨framedW_of Ssm.evalHeap Ssm.evalNextLe Ssm.evalSmall (by decide) Ssm.evalJobs Ssm.evalStores Ssm.evalTrace
    ⟨Ssm.evalArrs, Ssm.evalNodes⟩, Ssm.evalSyms, Ssm.evalVec⟩, hi'⟩, hrun⟩

end Host.Ts.Sim.Stage.Ssm
