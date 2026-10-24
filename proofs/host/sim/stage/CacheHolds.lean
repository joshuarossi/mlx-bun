import host.sim.stage.Mlx
import host.sim.stage.CacheRun
import host.sim.PrefillSched
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Ts.Sim.Stage.Cache
open Host.Ts Host.Ts.Sim.Stage

/-! # The cache stage contracts

**KV append** (`appendDecode`/`appendWindow` → `updateAndFetch`), per growth class, at offset `o`,
capacity `c` and `r` rows (`KvPost`): for every caller stack,
* the only existing heap entry written is the cache object (`Framed`, written range `[a, a+1)`);
  jobs, stores unchanged, the trace gains the call's mlx-c events;
* **live-set delta** against the MLX liveness layer (`mlxLive`): the four handles named by
  `(h, n)` with `n ≠ 0` in `es` are allocated (new `keys`, `values`, and the two views the
  returned read owns), the call's `keys`/`values` handles are freed, and the growth temporaries
  (zeros, concat; `es` entries reset to `0`) are allocated and freed inside the call; no
  existing graph node changes (`NodesKept`);
* the cache's `offset` reads `o + r` through the return server, its `keys`/`values` hold the new
  handles, the call returns a fresh read object;
* the graph (`*.G`): the new `keys`/`values` nodes are `sliceUpdate` of the (grown) buffer at rows
  `[o, o+r)`, the views `slice` rows `[0, o+r)`; growth (`KvDGrow`, `KvWGrow`) concatenates
  `zeros [1, 4, 256·⌈r/256⌉, 256]`, a null buffer (`KvDFirst`, `KvWFirst`) starts from zeros of that
  size (dimensions are server numbers: entries of the class's return table).

Precondition (`*.Dom`): the class's inputs; growth only at `o % 256 = 0` with `cap = o` — the
power-of-two chunk fact (`route_noTrim`: on the route the capacity is `capL o` and every append
starts at a multiple of 256 or fits, so the trim branch is never taken).

**`evalCacheState`** (`EvalPost`): no heap entry written, arrays and graph unchanged (no live-set
change), the trace gains `mlx_vector_array_new_data`, `mlx_eval`, `mlx_vector_array_free`, and the
evaluated vector holds the cache's `keys` and `values` nodes in that order (`state()`, kv.ts:168-170). -/

/-! ## The route's growth classes -/

/-- **No trim on the route**: an append of `r ≤ C` rows at `o = j·C` (chunk `C` among the route's
sizes) or of one row at any `o`, into capacity `capL o`, either fits or starts at a multiple of 256,
where `capL o = o` (a full buffer, the growth classes' `cap = o`). -/
theorem route_noTrim {o r : Nat} (h : o % 256 = 0 ∨ o + r ≤ capL o) :
    o + r ≤ capL o ∨ (o % 256 = 0 ∧ capL o = o) := by
  unfold capL at *
  rcases h with h | h
  · right; exact ⟨h, by omega⟩
  · left; exact h

theorem route_noTrim_chunk {C j r : Nat} (hC : C ∈ Prefill.chunkSizes) (hr : r ≤ C) :
    j * C + r ≤ capL (j * C) ∨ ((j * C) % 256 = 0 ∧ capL (j * C) = j * C) :=
  route_noTrim (Prefill.sched_ok hC hr)

theorem route_noTrim_one (o : Nat) : o + 1 ≤ capL o ∨ (o % 256 = 0 ∧ capL o = o) :=
  route_noTrim (Prefill.one_ok o)

/-! ## Contracts -/

/-- **The KV append's postcondition** for a class: cache object `a`, handle-table update `es`, new
`keys`/`values` handles `hk`/`hv`, the offset value `offV` reading `n`, the graph facts `G`. -/
def KvPost (a : Nat) (ws : List (Nat × Nat)) (es : List (Nat × Nat)) (hk hv : Int) (offV : Val) (n : Nat) (G : Host.Mlx.Ffi.St → Prop)
    (t t' : St Host.Mlx.Ffi.St) (C' : CSrv) : Prop :=
  Framed (F := MF) (fun b => ∃ p ∈ ws, p.1 ≤ b ∧ b < p.2)
      (fun x y => LiveDelta (F := MF) mlxLive (fun h => ∃ m, (h, m) ∈ es ∧ m ≠ 0) (fun h => (h, 0) ∈ es) x y ∧
        NodesKept x y) t t' ∧
    propOf (t'.obj? a) chars!"offset" = some offV ∧ natAt C' offV = some n ∧
    ArrAt t' a chars!"keys" hk ∧ ArrAt t' a chars!"values" hv ∧
    (∃ b, t'.ctl = .ret (.obj b) ∧ t.next ≤ b) ∧ G t'.aux.ffi

theorem ρ3_0 (o c r : Nat) (h : o < 2 ^ 53) : ρ3 o c r 0 = Lin.ie o := Lin.ofNat_ie o h
theorem ρ3_2 (o c r : Nat) (h : r < 2 ^ 53) : ρ3 o c r 2 = Lin.ie r := Lin.ofNat_ie r h

theorem int32_small {r : Nat} (h : r < 2 ^ 31) : F64.un .int32 (Lin.ie r) = Lin.ie r := by
  rw [Lin.int32_ie]; exact ie_cast (by omega)

theorem eval_o1 (o c r : Nat) (h : o < 2 ^ 52) :
    SymE.eval (ρ3 o c r) (.bin .add (.var 0) (.lit (.fin false 1 0))) = Lin.ie (o + 1 : Nat) := by
  simp only [SymE.eval]
  rw [ρ3_0 o c r (by omega), one_ie]
  show F64.add _ _ = _
  rw [Lin.add_ie _ _ (by omega)]
  exact ie_cast (by omega)

theorem eval_or (o c r : Nat) (h : o < 2 ^ 52) (h2 : r < 2 ^ 31) :
    SymE.eval (ρ3 o c r) (.bin .add (.var 0) (.un .int32 (.var 2))) = Lin.ie (o + r : Nat) := by
  simp only [SymE.eval]
  rw [ρ3_0 o c r (by omega), ρ3_2 o c r (by omega), int32_small h2]
  show F64.add _ _ = _
  rw [Lin.add_ie _ _ (by omega)]
  exact ie_cast (by omega)

theorem eval_0r (o c r : Nat) (h2 : r < 2 ^ 31) :
    SymE.eval (ρ3 o c r) (.bin .add (.lit (.zero false)) (.un .int32 (.var 2))) = Lin.ie (0 + r : Nat) := by
  simp only [SymE.eval]
  rw [ρ3_2 o c r (by omega), int32_small h2, show F64.zero false = Lin.ie 0 from rfl]
  show F64.add _ _ = _
  rw [Lin.add_ie _ _ (by omega)]
  exact ie_cast (by omega)

/-! ## Class `KvDFit`: a decode row into room (`o + 1 < cap`) -/

/-- The inputs of class `KvDFit`. -/
def KvDFit.Dom (o c r : Nat) : Prop := 1 ≤ o ∧ o + 1 < c ∧ c ≤ 536870912 ∧ r = 1

/-- The graph of class `KvDFit`'s new handles. -/
def KvDFit.G (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 7)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 8)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩ ∧
    y.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 10)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 11)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩ ∧
    y.node? 10 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 13)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [5], [(.lit 1), (.lit 4), (.sym (.ref 14)), (.lit 256)], 12⟩ ∧
    y.node? 11 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 15)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [6], [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)], 12⟩

kernel_rfl KvDFit.srv1 : KvDFit.S1.oracle = KvDFit.O
kernel_rfl KvDFit.arrs : KvDFit.s3.aux.ffi.arrs = setAll KvDFit.s1.aux.ffi.arrs [(4, 0), (5, 0), (8, 5), (9, 6), (10, 7), (11, 8)]
kernel_rfl KvDFit.nodes : KvDFit.s3.aux.ffi.nodes = setAll KvDFit.s1.aux.ffi.nodes (freshOf KvDFit.s3.aux.ffi.nodes KvDFit.s1.aux.ffi.nnext KvDFit.s3.aux.ffi.nnext)
kernel_rfl KvDFit.nsmall : Nat.blt KvDFit.s3.aux.ffi.nnext 1048576 = true
kernel_rfl KvDFit.heap : KvDFit.s3.heap = setAll KvDFit.s1.heap (rangesOf KvDFit.s3.heap [(1378, 1379), (1408, 1409), (1434, 1435)] ++ freshOf KvDFit.s3.heap KvDFit.s1.next KvDFit.s3.next)
kernel_rfl KvDFit.nextLe : Nat.ble KvDFit.s1.next KvDFit.s3.next = true
kernel_rfl KvDFit.small : Nat.blt KvDFit.s3.next 1048576 = true
kernel_rfl KvDFit.jobs : KvDFit.s3.aux.jobs = KvDFit.s1.aux.jobs
kernel_rfl KvDFit.stores : KvDFit.s3.aux.stores = KvDFit.s1.aux.stores
kernel_rfl KvDFit.trace : KvDFit.s3.aux.trace = KvDFit.s3.aux.trace.take (KvDFit.s3.aux.trace.length - KvDFit.s1.aux.trace.length) ++ KvDFit.s1.aux.trace
kernel_rfl KvDFit.off : propOf (KvDFit.s3.obj? 1378) chars!"offset" = some (.num (.ref 6))
kernel_rfl KvDFit.offE : nth? KvDFit.S3.tab 6 = some (Host.Ts.SymE.bin (Host.Ts.NBin.add) (Host.Ts.SymE.var 0) (Host.Ts.SymE.lit (Host.Ts.F64.fin false 1 0)))
kernel_rfl KvDFit.keysArr : propOf (KvDFit.s3.obj? 1378) chars!"keys" = some (.obj 1609)
kernel_rfl KvDFit.keysH : handleOf (KvDFit.s3.obj? 1609) = some 8
kernel_rfl KvDFit.valuesArr : propOf (KvDFit.s3.obj? 1378) chars!"values" = some (.obj 1661)
kernel_rfl KvDFit.valuesH : handleOf (KvDFit.s3.obj? 1661) = some 9
kernel_rfl KvDFit.ret : KvDFit.s3.ctl = .ret (.obj 1773)
kernel_rfl KvDFit.freshRet : Nat.ble KvDFit.s1.next 1773 = true
kernel_rfl KvDFit.g8 : KvDFit.s3.aux.ffi.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 7)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 8)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩
kernel_rfl KvDFit.g9 : KvDFit.s3.aux.ffi.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 10)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 11)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩
kernel_rfl KvDFit.g10 : KvDFit.s3.aux.ffi.node? 10 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 13)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [5], [(.lit 1), (.lit 4), (.sym (.ref 14)), (.lit 256)], 12⟩
kernel_rfl KvDFit.g11 : KvDFit.s3.aux.ffi.node? 11 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 15)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [6], [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)], 12⟩

def KvDFit.ps : List Lin.Prm := [{ lo := 1, hi := 536870912 }, { lo := 0, hi := 536870912 }]
def KvDFit.V : List (Nat × Lin.Aff) := [(0, Lin.P 0), (1, Lin.P 0 + Lin.P 1 + 2), (2, 1)]
theorem KvDFit.lin : Lin.goodLin KvDFit.ps KvDFit.V KvDFit.O = true := by decide +kernel

/-- **The KV append of class `KvDFit`.** -/
def KvDFit.stage : Stage MF where
  Par := Nat × Nat × Nat
  Pre q t C := KvDFit.Dom q.1 q.2.1 q.2.2 ∧ t = tplN KvDFit.s1 0 [] ∧ C = ⟨KvDFit.S1.tab.map (SymE.eval (ρ3 q.1 q.2.1 q.2.2))⟩
  Post q t _ t' C' := KvPost 1378 [(1378, 1379), (1408, 1409), (1434, 1435)] [(4, 0), (5, 0), (8, 5), (9, 6), (10, 7), (11, 8)] 8 9 (.num (.ref 6)) (q.1 + q.2.2) KvDFit.G t t' C'

theorem KvDFit.holds : KvDFit.stage.Holds := by
  rintro ⟨o, c, r⟩ t Cs ⟨hd, rfl, rfl⟩
  dsimp only [KvDFit.Dom] at hd
  obtain ⟨h0, h1, h2, h3⟩ := hd
  have hg : Good (ρ3 o c r) KvDFit.O :=
    Lin.goodLin_sound KvDFit.lin (x := Lin.vx [(o : Int), (c : Int) - o - 2]) (by simp only [KvDFit.ps]; lin_mem) (by simp only [KvDFit.V]; lin_mem [ρ3])
  have hi : Inst (ρ3 o c r) KvDFit.S1 ⟨KvDFit.S1.tab.map (SymE.eval (ρ3 o c r))⟩ := ⟨rfl, by rw [KvDFit.srv1]; exact hg⟩
  obtain ⟨_, hrun⟩ := tplN_sim KvDFit.append hi
  refine ⟨2760, tplN KvDFit.s3 0 [], ⟨KvDFit.S3.tab.map (SymE.eval (ρ3 o c r))⟩, ⟨?_, KvDFit.off, ?_, ⟨_, KvDFit.keysArr, KvDFit.keysH⟩,
    ⟨_, KvDFit.valuesArr, KvDFit.valuesH⟩, ⟨1773, KvDFit.ret, Nat.le_of_ble_eq_true KvDFit.freshRet⟩, ⟨KvDFit.g8, KvDFit.g9, KvDFit.g10, KvDFit.g11⟩⟩, hrun⟩
  · exact framedW_of KvDFit.heap KvDFit.nextLe KvDFit.small (by decide) KvDFit.jobs KvDFit.stores KvDFit.trace
      ⟨liveDelta_setAll KvDFit.arrs (by decide) (by decide), nodesKept_of KvDFit.nodes KvDFit.nsmall⟩
  · show natAt _ (.num (.ref 6)) = some (o + r)
    have hv := natAt_ref (C := ⟨KvDFit.S3.tab.map (SymE.eval (ρ3 o c r))⟩) (by rw [nth_inst KvDFit.offE]; exact congrArg some (eval_o1 o c r (by omega))) (n := (o + 1 : Nat)) (by omega)
    rw [hv] <;> (congr 1; omega)

kernel_rfl KvDFit.arrs6 : KvDFit.s6.aux.ffi.arrs = KvDFit.s4.aux.ffi.arrs
kernel_rfl KvDFit.nodes6 : KvDFit.s6.aux.ffi.nodes = KvDFit.s4.aux.ffi.nodes
kernel_rfl KvDFit.heap6 : KvDFit.s6.heap = setAll KvDFit.s4.heap (rangesOf KvDFit.s6.heap [] ++ freshOf KvDFit.s6.heap KvDFit.s4.next KvDFit.s6.next)
kernel_rfl KvDFit.nextLe6 : Nat.ble KvDFit.s4.next KvDFit.s6.next = true
kernel_rfl KvDFit.small6 : Nat.blt KvDFit.s6.next 1048576 = true
kernel_rfl KvDFit.jobs6 : KvDFit.s6.aux.jobs = KvDFit.s4.aux.jobs
kernel_rfl KvDFit.stores6 : KvDFit.s6.aux.stores = KvDFit.s4.aux.stores
kernel_rfl KvDFit.trace6 : KvDFit.s6.aux.trace = KvDFit.s6.aux.trace.take 3 ++ KvDFit.s4.aux.trace
kernel_rfl KvDFit.syms6 : (KvDFit.s6.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl KvDFit.vec6 : KvDFit.s6.aux.ffi.objs.get KvDFit.s4.aux.ffi.next = some (.vec [5, 6])

/-- **`evalCacheState` after the append of class `KvDFit`** (parameter: the valuation). -/
def KvDFit.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN KvDFit.s4 0 [] ∧ Inst ρ KvDFit.S4 C
  Post ρ t _ t' C' := EvalPost [5, 6] t t' ∧ Inst ρ KvDFit.S6 C'

theorem KvDFit.evalHolds : KvDFit.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim KvDFit.eval hi
  exact ⟨946, tplN KvDFit.s6 0 [], _, ⟨⟨framedW_of KvDFit.heap6 KvDFit.nextLe6 KvDFit.small6 (by decide) KvDFit.jobs6 KvDFit.stores6 KvDFit.trace6
    ⟨KvDFit.arrs6, KvDFit.nodes6⟩, KvDFit.syms6, KvDFit.vec6⟩, hi'⟩, hrun⟩

/-! ## Class `KvDFill`: a decode row filling the buffer (`o + 1 = cap`: the views are the buffer) -/

/-- The inputs of class `KvDFill`. -/
def KvDFill.Dom (o c r : Nat) : Prop := 1 ≤ o ∧ c = o + 1 ∧ c ≤ 536870912 ∧ r = 1

/-- The graph of class `KvDFill`'s new handles. -/
def KvDFill.G (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 7)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 8)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩ ∧
    y.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 10)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 11)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩ ∧
    y.node? 10 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 7)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 8)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩ ∧
    y.node? 11 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 10)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 11)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩

kernel_rfl KvDFill.srv1 : KvDFill.S1.oracle = KvDFill.O
kernel_rfl KvDFill.arrs : KvDFill.s3.aux.ffi.arrs = setAll KvDFill.s1.aux.ffi.arrs [(4, 0), (5, 0), (8, 5), (9, 6), (10, 5), (11, 6)]
kernel_rfl KvDFill.nodes : KvDFill.s3.aux.ffi.nodes = setAll KvDFill.s1.aux.ffi.nodes (freshOf KvDFill.s3.aux.ffi.nodes KvDFill.s1.aux.ffi.nnext KvDFill.s3.aux.ffi.nnext)
kernel_rfl KvDFill.nsmall : Nat.blt KvDFill.s3.aux.ffi.nnext 1048576 = true
kernel_rfl KvDFill.heap : KvDFill.s3.heap = setAll KvDFill.s1.heap (rangesOf KvDFill.s3.heap [(1378, 1379), (1408, 1409), (1434, 1435)] ++ freshOf KvDFill.s3.heap KvDFill.s1.next KvDFill.s3.next)
kernel_rfl KvDFill.nextLe : Nat.ble KvDFill.s1.next KvDFill.s3.next = true
kernel_rfl KvDFill.small : Nat.blt KvDFill.s3.next 1048576 = true
kernel_rfl KvDFill.jobs : KvDFill.s3.aux.jobs = KvDFill.s1.aux.jobs
kernel_rfl KvDFill.stores : KvDFill.s3.aux.stores = KvDFill.s1.aux.stores
kernel_rfl KvDFill.trace : KvDFill.s3.aux.trace = KvDFill.s3.aux.trace.take (KvDFill.s3.aux.trace.length - KvDFill.s1.aux.trace.length) ++ KvDFill.s1.aux.trace
kernel_rfl KvDFill.off : propOf (KvDFill.s3.obj? 1378) chars!"offset" = some (.num (.ref 6))
kernel_rfl KvDFill.offE : nth? KvDFill.S3.tab 6 = some (Host.Ts.SymE.bin (Host.Ts.NBin.add) (Host.Ts.SymE.var 0) (Host.Ts.SymE.lit (Host.Ts.F64.fin false 1 0)))
kernel_rfl KvDFill.keysArr : propOf (KvDFill.s3.obj? 1378) chars!"keys" = some (.obj 1609)
kernel_rfl KvDFill.keysH : handleOf (KvDFill.s3.obj? 1609) = some 8
kernel_rfl KvDFill.valuesArr : propOf (KvDFill.s3.obj? 1378) chars!"values" = some (.obj 1661)
kernel_rfl KvDFill.valuesH : handleOf (KvDFill.s3.obj? 1661) = some 9
kernel_rfl KvDFill.ret : KvDFill.s3.ctl = .ret (.obj 1773)
kernel_rfl KvDFill.freshRet : Nat.ble KvDFill.s1.next 1773 = true
kernel_rfl KvDFill.g8 : KvDFill.s3.aux.ffi.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 7)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 8)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩
kernel_rfl KvDFill.g9 : KvDFill.s3.aux.ffi.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 10)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 11)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩
kernel_rfl KvDFill.g10 : KvDFill.s3.aux.ffi.node? 10 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 7)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 8)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩
kernel_rfl KvDFill.g11 : KvDFill.s3.aux.ffi.node? 11 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 10)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 11)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩

def KvDFill.ps : List Lin.Prm := [{ lo := 1, hi := 536870912 }]
def KvDFill.V : List (Nat × Lin.Aff) := [(0, Lin.P 0), (1, Lin.P 0 + 1), (2, 1)]
theorem KvDFill.lin : Lin.goodLin KvDFill.ps KvDFill.V KvDFill.O = true := by decide +kernel

/-- **The KV append of class `KvDFill`.** -/
def KvDFill.stage : Stage MF where
  Par := Nat × Nat × Nat
  Pre q t C := KvDFill.Dom q.1 q.2.1 q.2.2 ∧ t = tplN KvDFill.s1 0 [] ∧ C = ⟨KvDFill.S1.tab.map (SymE.eval (ρ3 q.1 q.2.1 q.2.2))⟩
  Post q t _ t' C' := KvPost 1378 [(1378, 1379), (1408, 1409), (1434, 1435)] [(4, 0), (5, 0), (8, 5), (9, 6), (10, 5), (11, 6)] 8 9 (.num (.ref 6)) (q.1 + q.2.2) KvDFill.G t t' C'

theorem KvDFill.holds : KvDFill.stage.Holds := by
  rintro ⟨o, c, r⟩ t Cs ⟨hd, rfl, rfl⟩
  dsimp only [KvDFill.Dom] at hd
  obtain ⟨h0, h1, h2, h3⟩ := hd
  have hg : Good (ρ3 o c r) KvDFill.O :=
    Lin.goodLin_sound KvDFill.lin (x := Lin.vx [(o : Int)]) (by simp only [KvDFill.ps]; lin_mem) (by simp only [KvDFill.V]; lin_mem [ρ3])
  have hi : Inst (ρ3 o c r) KvDFill.S1 ⟨KvDFill.S1.tab.map (SymE.eval (ρ3 o c r))⟩ := ⟨rfl, by rw [KvDFill.srv1]; exact hg⟩
  obtain ⟨_, hrun⟩ := tplN_sim KvDFill.append hi
  refine ⟨2760, tplN KvDFill.s3 0 [], ⟨KvDFill.S3.tab.map (SymE.eval (ρ3 o c r))⟩, ⟨?_, KvDFill.off, ?_, ⟨_, KvDFill.keysArr, KvDFill.keysH⟩,
    ⟨_, KvDFill.valuesArr, KvDFill.valuesH⟩, ⟨1773, KvDFill.ret, Nat.le_of_ble_eq_true KvDFill.freshRet⟩, ⟨KvDFill.g8, KvDFill.g9, KvDFill.g10, KvDFill.g11⟩⟩, hrun⟩
  · exact framedW_of KvDFill.heap KvDFill.nextLe KvDFill.small (by decide) KvDFill.jobs KvDFill.stores KvDFill.trace
      ⟨liveDelta_setAll KvDFill.arrs (by decide) (by decide), nodesKept_of KvDFill.nodes KvDFill.nsmall⟩
  · show natAt _ (.num (.ref 6)) = some (o + r)
    have hv := natAt_ref (C := ⟨KvDFill.S3.tab.map (SymE.eval (ρ3 o c r))⟩) (by rw [nth_inst KvDFill.offE]; exact congrArg some (eval_o1 o c r (by omega))) (n := (o + 1 : Nat)) (by omega)
    rw [hv] <;> (congr 1; omega)

kernel_rfl KvDFill.arrs6 : KvDFill.s6.aux.ffi.arrs = KvDFill.s4.aux.ffi.arrs
kernel_rfl KvDFill.nodes6 : KvDFill.s6.aux.ffi.nodes = KvDFill.s4.aux.ffi.nodes
kernel_rfl KvDFill.heap6 : KvDFill.s6.heap = setAll KvDFill.s4.heap (rangesOf KvDFill.s6.heap [] ++ freshOf KvDFill.s6.heap KvDFill.s4.next KvDFill.s6.next)
kernel_rfl KvDFill.nextLe6 : Nat.ble KvDFill.s4.next KvDFill.s6.next = true
kernel_rfl KvDFill.small6 : Nat.blt KvDFill.s6.next 1048576 = true
kernel_rfl KvDFill.jobs6 : KvDFill.s6.aux.jobs = KvDFill.s4.aux.jobs
kernel_rfl KvDFill.stores6 : KvDFill.s6.aux.stores = KvDFill.s4.aux.stores
kernel_rfl KvDFill.trace6 : KvDFill.s6.aux.trace = KvDFill.s6.aux.trace.take 3 ++ KvDFill.s4.aux.trace
kernel_rfl KvDFill.syms6 : (KvDFill.s6.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl KvDFill.vec6 : KvDFill.s6.aux.ffi.objs.get KvDFill.s4.aux.ffi.next = some (.vec [5, 6])

/-- **`evalCacheState` after the append of class `KvDFill`** (parameter: the valuation). -/
def KvDFill.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN KvDFill.s4 0 [] ∧ Inst ρ KvDFill.S4 C
  Post ρ t _ t' C' := EvalPost [5, 6] t t' ∧ Inst ρ KvDFill.S6 C'

theorem KvDFill.evalHolds : KvDFill.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim KvDFill.eval hi
  exact ⟨946, tplN KvDFill.s6 0 [], _, ⟨⟨framedW_of KvDFill.heap6 KvDFill.nextLe6 KvDFill.small6 (by decide) KvDFill.jobs6 KvDFill.stores6 KvDFill.trace6
    ⟨KvDFill.arrs6, KvDFill.nodes6⟩, KvDFill.syms6, KvDFill.vec6⟩, hi'⟩, hrun⟩

/-! ## Class `KvDGrow`: a decode row at a full buffer (`cap = o`, `o % 256 = 0`): grows by 256 -/

/-- The inputs of class `KvDGrow`. -/
def KvDGrow.Dom (o c r : Nat) : Prop := 256 ≤ o ∧ o % 256 = 0 ∧ c = o ∧ o ≤ 536870912 ∧ r = 1

/-- The graph of class `KvDGrow`'s new handles. -/
def KvDGrow.G (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 14 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 10)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 11)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [7, 3], [(.lit 1), (.lit 4), (.sym (.ref 7)), (.lit 256)], 12⟩ ∧
    y.node? 15 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 13)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 14)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [8, 4], [(.lit 1), (.lit 4), (.sym (.ref 8)), (.lit 256)], 12⟩ ∧
    y.node? 16 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [9], [(.lit 1), (.lit 4), (.sym (.ref 17)), (.lit 256)], 12⟩ ∧
    y.node? 17 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [10], [(.lit 1), (.lit 4), (.sym (.ref 19)), (.lit 256)], 12⟩

kernel_rfl KvDGrow.srv1 : KvDGrow.S1.oracle = KvDGrow.O
kernel_rfl KvDGrow.arrs : KvDGrow.s3.aux.ffi.arrs = setAll KvDGrow.s1.aux.ffi.arrs [(4, 0), (5, 0), (8, 0), (9, 0), (11, 0), (13, 0), (14, 9), (15, 10), (16, 11), (17, 12)]
kernel_rfl KvDGrow.nodes : KvDGrow.s3.aux.ffi.nodes = setAll KvDGrow.s1.aux.ffi.nodes (freshOf KvDGrow.s3.aux.ffi.nodes KvDGrow.s1.aux.ffi.nnext KvDGrow.s3.aux.ffi.nnext)
kernel_rfl KvDGrow.nsmall : Nat.blt KvDGrow.s3.aux.ffi.nnext 1048576 = true
kernel_rfl KvDGrow.heap : KvDGrow.s3.heap = setAll KvDGrow.s1.heap (rangesOf KvDGrow.s3.heap [(1378, 1379), (1408, 1409), (1434, 1435)] ++ freshOf KvDGrow.s3.heap KvDGrow.s1.next KvDGrow.s3.next)
kernel_rfl KvDGrow.nextLe : Nat.ble KvDGrow.s1.next KvDGrow.s3.next = true
kernel_rfl KvDGrow.small : Nat.blt KvDGrow.s3.next 1048576 = true
kernel_rfl KvDGrow.jobs : KvDGrow.s3.aux.jobs = KvDGrow.s1.aux.jobs
kernel_rfl KvDGrow.stores : KvDGrow.s3.aux.stores = KvDGrow.s1.aux.stores
kernel_rfl KvDGrow.trace : KvDGrow.s3.aux.trace = KvDGrow.s3.aux.trace.take (KvDGrow.s3.aux.trace.length - KvDGrow.s1.aux.trace.length) ++ KvDGrow.s1.aux.trace
kernel_rfl KvDGrow.off : propOf (KvDGrow.s3.obj? 1378) chars!"offset" = some (.num (.ref 9))
kernel_rfl KvDGrow.offE : nth? KvDGrow.S3.tab 9 = some (Host.Ts.SymE.bin (Host.Ts.NBin.add) (Host.Ts.SymE.var 0) (Host.Ts.SymE.lit (Host.Ts.F64.fin false 1 0)))
kernel_rfl KvDGrow.keysArr : propOf (KvDGrow.s3.obj? 1378) chars!"keys" = some (.obj 1805)
kernel_rfl KvDGrow.keysH : handleOf (KvDGrow.s3.obj? 1805) = some 14
kernel_rfl KvDGrow.valuesArr : propOf (KvDGrow.s3.obj? 1378) chars!"values" = some (.obj 1857)
kernel_rfl KvDGrow.valuesH : handleOf (KvDGrow.s3.obj? 1857) = some 15
kernel_rfl KvDGrow.ret : KvDGrow.s3.ctl = .ret (.obj 1969)
kernel_rfl KvDGrow.freshRet : Nat.ble KvDGrow.s1.next 1969 = true
kernel_rfl KvDGrow.g14 : KvDGrow.s3.aux.ffi.node? 14 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 10)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 11)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [7, 3], [(.lit 1), (.lit 4), (.sym (.ref 7)), (.lit 256)], 12⟩
kernel_rfl KvDGrow.g15 : KvDGrow.s3.aux.ffi.node? 15 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 13)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 14)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [8, 4], [(.lit 1), (.lit 4), (.sym (.ref 8)), (.lit 256)], 12⟩
kernel_rfl KvDGrow.g16 : KvDGrow.s3.aux.ffi.node? 16 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [9], [(.lit 1), (.lit 4), (.sym (.ref 17)), (.lit 256)], 12⟩
kernel_rfl KvDGrow.g17 : KvDGrow.s3.aux.ffi.node? 17 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [10], [(.lit 1), (.lit 4), (.sym (.ref 19)), (.lit 256)], 12⟩

def KvDGrow.ps : List Lin.Prm := [{ lo := 1, hi := 2097152 }]
def KvDGrow.V : List (Nat × Lin.Aff) := [(0, (256 : Nat) • Lin.P 0), (1, (256 : Nat) • Lin.P 0), (2, 1)]
theorem KvDGrow.lin : Lin.goodLin KvDGrow.ps KvDGrow.V KvDGrow.O = true := by decide +kernel

/-- **The KV append of class `KvDGrow`.** -/
def KvDGrow.stage : Stage MF where
  Par := Nat × Nat × Nat
  Pre q t C := KvDGrow.Dom q.1 q.2.1 q.2.2 ∧ t = tplN KvDGrow.s1 0 [] ∧ C = ⟨KvDGrow.S1.tab.map (SymE.eval (ρ3 q.1 q.2.1 q.2.2))⟩
  Post q t _ t' C' := KvPost 1378 [(1378, 1379), (1408, 1409), (1434, 1435)] [(4, 0), (5, 0), (8, 0), (9, 0), (11, 0), (13, 0), (14, 9), (15, 10), (16, 11), (17, 12)] 14 15 (.num (.ref 9)) (q.1 + q.2.2) KvDGrow.G t t' C'

theorem KvDGrow.holds : KvDGrow.stage.Holds := by
  rintro ⟨o, c, r⟩ t Cs ⟨hd, rfl, rfl⟩
  dsimp only [KvDGrow.Dom] at hd
  obtain ⟨h0, h1, h2, h3, h4⟩ := hd
  have hg : Good (ρ3 o c r) KvDGrow.O :=
    Lin.goodLin_sound KvDGrow.lin (x := Lin.vx [(o : Int) / 256]) (by simp only [KvDGrow.ps]; lin_mem) (by simp only [KvDGrow.V]; lin_mem [ρ3])
  have hi : Inst (ρ3 o c r) KvDGrow.S1 ⟨KvDGrow.S1.tab.map (SymE.eval (ρ3 o c r))⟩ := ⟨rfl, by rw [KvDGrow.srv1]; exact hg⟩
  obtain ⟨_, hrun⟩ := tplN_sim KvDGrow.append hi
  refine ⟨4625, tplN KvDGrow.s3 0 [], ⟨KvDGrow.S3.tab.map (SymE.eval (ρ3 o c r))⟩, ⟨?_, KvDGrow.off, ?_, ⟨_, KvDGrow.keysArr, KvDGrow.keysH⟩,
    ⟨_, KvDGrow.valuesArr, KvDGrow.valuesH⟩, ⟨1969, KvDGrow.ret, Nat.le_of_ble_eq_true KvDGrow.freshRet⟩, ⟨KvDGrow.g14, KvDGrow.g15, KvDGrow.g16, KvDGrow.g17⟩⟩, hrun⟩
  · exact framedW_of KvDGrow.heap KvDGrow.nextLe KvDGrow.small (by decide) KvDGrow.jobs KvDGrow.stores KvDGrow.trace
      ⟨liveDelta_setAll KvDGrow.arrs (by decide) (by decide), nodesKept_of KvDGrow.nodes KvDGrow.nsmall⟩
  · show natAt _ (.num (.ref 9)) = some (o + r)
    have hv := natAt_ref (C := ⟨KvDGrow.S3.tab.map (SymE.eval (ρ3 o c r))⟩) (by rw [nth_inst KvDGrow.offE]; exact congrArg some (eval_o1 o c r (by omega))) (n := (o + 1 : Nat)) (by omega)
    rw [hv] <;> (congr 1; omega)

kernel_rfl KvDGrow.arrs6 : KvDGrow.s6.aux.ffi.arrs = KvDGrow.s4.aux.ffi.arrs
kernel_rfl KvDGrow.nodes6 : KvDGrow.s6.aux.ffi.nodes = KvDGrow.s4.aux.ffi.nodes
kernel_rfl KvDGrow.heap6 : KvDGrow.s6.heap = setAll KvDGrow.s4.heap (rangesOf KvDGrow.s6.heap [] ++ freshOf KvDGrow.s6.heap KvDGrow.s4.next KvDGrow.s6.next)
kernel_rfl KvDGrow.nextLe6 : Nat.ble KvDGrow.s4.next KvDGrow.s6.next = true
kernel_rfl KvDGrow.small6 : Nat.blt KvDGrow.s6.next 1048576 = true
kernel_rfl KvDGrow.jobs6 : KvDGrow.s6.aux.jobs = KvDGrow.s4.aux.jobs
kernel_rfl KvDGrow.stores6 : KvDGrow.s6.aux.stores = KvDGrow.s4.aux.stores
kernel_rfl KvDGrow.trace6 : KvDGrow.s6.aux.trace = KvDGrow.s6.aux.trace.take 3 ++ KvDGrow.s4.aux.trace
kernel_rfl KvDGrow.syms6 : (KvDGrow.s6.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl KvDGrow.vec6 : KvDGrow.s6.aux.ffi.objs.get KvDGrow.s4.aux.ffi.next = some (.vec [9, 10])

/-- **`evalCacheState` after the append of class `KvDGrow`** (parameter: the valuation). -/
def KvDGrow.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN KvDGrow.s4 0 [] ∧ Inst ρ KvDGrow.S4 C
  Post ρ t _ t' C' := EvalPost [9, 10] t t' ∧ Inst ρ KvDGrow.S6 C'

theorem KvDGrow.evalHolds : KvDGrow.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim KvDGrow.eval hi
  exact ⟨946, tplN KvDGrow.s6 0 [], _, ⟨⟨framedW_of KvDGrow.heap6 KvDGrow.nextLe6 KvDGrow.small6 (by decide) KvDGrow.jobs6 KvDGrow.stores6 KvDGrow.trace6
    ⟨KvDGrow.arrs6, KvDGrow.nodes6⟩, KvDGrow.syms6, KvDGrow.vec6⟩, hi'⟩, hrun⟩

/-! ## Class `KvDFirst`: a decode row into a null buffer (`keys = null`, offset 0) -/

/-- The inputs of class `KvDFirst`. -/
def KvDFirst.Dom (o c r : Nat) : Prop := o = 0 ∧ c = 0 ∧ r = 1

/-- The graph of class `KvDFirst`'s new handles. -/
def KvDFirst.G (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.lit 1), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [3, 1], [(.lit 1), (.lit 4), (.lit 256), (.lit 256)], 12⟩ ∧
    y.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.lit 1), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [4, 2], [(.lit 1), (.lit 4), (.lit 256), (.lit 256)], 12⟩ ∧
    y.node? 10 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.lit 1), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [5], [(.lit 1), (.lit 4), (.lit 1), (.lit 256)], 12⟩ ∧
    y.node? 11 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.lit 1), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [6], [(.lit 1), (.lit 4), (.lit 1), (.lit 256)], 12⟩

kernel_rfl KvDFirst.srv1 : KvDFirst.S1.oracle = KvDFirst.O
kernel_rfl KvDFirst.arrs : KvDFirst.s3.aux.ffi.arrs = setAll KvDFirst.s1.aux.ffi.arrs [(6, 0), (7, 0), (8, 5), (9, 6), (10, 7), (11, 8)]
kernel_rfl KvDFirst.nodes : KvDFirst.s3.aux.ffi.nodes = setAll KvDFirst.s1.aux.ffi.nodes (freshOf KvDFirst.s3.aux.ffi.nodes KvDFirst.s1.aux.ffi.nnext KvDFirst.s3.aux.ffi.nnext)
kernel_rfl KvDFirst.nsmall : Nat.blt KvDFirst.s3.aux.ffi.nnext 1048576 = true
kernel_rfl KvDFirst.heap : KvDFirst.s3.heap = setAll KvDFirst.s1.heap (rangesOf KvDFirst.s3.heap [(1378, 1379)] ++ freshOf KvDFirst.s3.heap KvDFirst.s1.next KvDFirst.s3.next)
kernel_rfl KvDFirst.nextLe : Nat.ble KvDFirst.s1.next KvDFirst.s3.next = true
kernel_rfl KvDFirst.small : Nat.blt KvDFirst.s3.next 1048576 = true
kernel_rfl KvDFirst.jobs : KvDFirst.s3.aux.jobs = KvDFirst.s1.aux.jobs
kernel_rfl KvDFirst.stores : KvDFirst.s3.aux.stores = KvDFirst.s1.aux.stores
kernel_rfl KvDFirst.trace : KvDFirst.s3.aux.trace = KvDFirst.s3.aux.trace.take (KvDFirst.s3.aux.trace.length - KvDFirst.s1.aux.trace.length) ++ KvDFirst.s1.aux.trace
kernel_rfl KvDFirst.off : propOf (KvDFirst.s3.obj? 1378) chars!"offset" = some (.num (.lit (.fin false 1 0)))
kernel_rfl KvDFirst.keysArr : propOf (KvDFirst.s3.obj? 1378) chars!"keys" = some (.obj 1637)
kernel_rfl KvDFirst.keysH : handleOf (KvDFirst.s3.obj? 1637) = some 8
kernel_rfl KvDFirst.valuesArr : propOf (KvDFirst.s3.obj? 1378) chars!"values" = some (.obj 1689)
kernel_rfl KvDFirst.valuesH : handleOf (KvDFirst.s3.obj? 1689) = some 9
kernel_rfl KvDFirst.ret : KvDFirst.s3.ctl = .ret (.obj 1801)
kernel_rfl KvDFirst.freshRet : Nat.ble KvDFirst.s1.next 1801 = true
kernel_rfl KvDFirst.g8 : KvDFirst.s3.aux.ffi.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.lit 1), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [3, 1], [(.lit 1), (.lit 4), (.lit 256), (.lit 256)], 12⟩
kernel_rfl KvDFirst.g9 : KvDFirst.s3.aux.ffi.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.lit 1), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [4, 2], [(.lit 1), (.lit 4), (.lit 256), (.lit 256)], 12⟩
kernel_rfl KvDFirst.g10 : KvDFirst.s3.aux.ffi.node? 10 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.lit 1), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [5], [(.lit 1), (.lit 4), (.lit 1), (.lit 256)], 12⟩
kernel_rfl KvDFirst.g11 : KvDFirst.s3.aux.ffi.node? 11 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.lit 1), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [6], [(.lit 1), (.lit 4), (.lit 1), (.lit 256)], 12⟩

def KvDFirst.ps : List Lin.Prm := []
def KvDFirst.V : List (Nat × Lin.Aff) := []
theorem KvDFirst.lin : Lin.goodLin KvDFirst.ps KvDFirst.V KvDFirst.O = true := by decide +kernel

/-- **The KV append of class `KvDFirst`.** -/
def KvDFirst.stage : Stage MF where
  Par := Nat × Nat × Nat
  Pre q t C := KvDFirst.Dom q.1 q.2.1 q.2.2 ∧ t = tplN KvDFirst.s1 0 [] ∧ C = ⟨KvDFirst.S1.tab.map (SymE.eval (ρ3 q.1 q.2.1 q.2.2))⟩
  Post q t _ t' C' := KvPost 1378 [(1378, 1379)] [(6, 0), (7, 0), (8, 5), (9, 6), (10, 7), (11, 8)] 8 9 (.num (.lit (.fin false 1 0))) (q.1 + q.2.2) KvDFirst.G t t' C'

theorem KvDFirst.holds : KvDFirst.stage.Holds := by
  rintro ⟨o, c, r⟩ t Cs ⟨hd, rfl, rfl⟩
  dsimp only [KvDFirst.Dom] at hd
  obtain ⟨h1, h2, h3⟩ := hd
  have hg : Good (ρ3 o c r) KvDFirst.O :=
    Lin.goodLin_sound KvDFirst.lin (x := Lin.vx []) (by simp only [KvDFirst.ps]; lin_mem) (by simp only [KvDFirst.V]; lin_mem [ρ3])
  have hi : Inst (ρ3 o c r) KvDFirst.S1 ⟨KvDFirst.S1.tab.map (SymE.eval (ρ3 o c r))⟩ := ⟨rfl, by rw [KvDFirst.srv1]; exact hg⟩
  obtain ⟨_, hrun⟩ := tplN_sim KvDFirst.append hi
  refine ⟨3452, tplN KvDFirst.s3 0 [], ⟨KvDFirst.S3.tab.map (SymE.eval (ρ3 o c r))⟩, ⟨?_, KvDFirst.off, ?_, ⟨_, KvDFirst.keysArr, KvDFirst.keysH⟩,
    ⟨_, KvDFirst.valuesArr, KvDFirst.valuesH⟩, ⟨1801, KvDFirst.ret, Nat.le_of_ble_eq_true KvDFirst.freshRet⟩, ⟨KvDFirst.g8, KvDFirst.g9, KvDFirst.g10, KvDFirst.g11⟩⟩, hrun⟩
  · exact framedW_of KvDFirst.heap KvDFirst.nextLe KvDFirst.small (by decide) KvDFirst.jobs KvDFirst.stores KvDFirst.trace
      ⟨liveDelta_setAll KvDFirst.arrs (by decide) (by decide), nodesKept_of KvDFirst.nodes KvDFirst.nsmall⟩
  · show natAt _ (.num (.lit (.fin false 1 0))) = some (o + r)
    rw [h1, h3]; rfl

kernel_rfl KvDFirst.arrs6 : KvDFirst.s6.aux.ffi.arrs = KvDFirst.s4.aux.ffi.arrs
kernel_rfl KvDFirst.nodes6 : KvDFirst.s6.aux.ffi.nodes = KvDFirst.s4.aux.ffi.nodes
kernel_rfl KvDFirst.heap6 : KvDFirst.s6.heap = setAll KvDFirst.s4.heap (rangesOf KvDFirst.s6.heap [] ++ freshOf KvDFirst.s6.heap KvDFirst.s4.next KvDFirst.s6.next)
kernel_rfl KvDFirst.nextLe6 : Nat.ble KvDFirst.s4.next KvDFirst.s6.next = true
kernel_rfl KvDFirst.small6 : Nat.blt KvDFirst.s6.next 1048576 = true
kernel_rfl KvDFirst.jobs6 : KvDFirst.s6.aux.jobs = KvDFirst.s4.aux.jobs
kernel_rfl KvDFirst.stores6 : KvDFirst.s6.aux.stores = KvDFirst.s4.aux.stores
kernel_rfl KvDFirst.trace6 : KvDFirst.s6.aux.trace = KvDFirst.s6.aux.trace.take 3 ++ KvDFirst.s4.aux.trace
kernel_rfl KvDFirst.syms6 : (KvDFirst.s6.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl KvDFirst.vec6 : KvDFirst.s6.aux.ffi.objs.get KvDFirst.s4.aux.ffi.next = some (.vec [5, 6])

/-- **`evalCacheState` after the append of class `KvDFirst`** (parameter: the valuation). -/
def KvDFirst.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN KvDFirst.s4 0 [] ∧ Inst ρ KvDFirst.S4 C
  Post ρ t _ t' C' := EvalPost [5, 6] t t' ∧ Inst ρ KvDFirst.S6 C'

theorem KvDFirst.evalHolds : KvDFirst.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim KvDFirst.eval hi
  exact ⟨946, tplN KvDFirst.s6 0 [], _, ⟨⟨framedW_of KvDFirst.heap6 KvDFirst.nextLe6 KvDFirst.small6 (by decide) KvDFirst.jobs6 KvDFirst.stores6 KvDFirst.trace6
    ⟨KvDFirst.arrs6, KvDFirst.nodes6⟩, KvDFirst.syms6, KvDFirst.vec6⟩, hi'⟩, hrun⟩

/-! ## Class `KvWFit`: a window of `r` rows into room (`o + r < cap`) -/

/-- The inputs of class `KvWFit`. -/
def KvWFit.Dom (o c r : Nat) : Prop := 1 ≤ o ∧ 1 ≤ r ∧ r ≤ 1048576 ∧ o + r < c ∧ c ≤ 536870912

/-- The graph of class `KvWFit`'s new handles. -/
def KvWFit.G (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 9)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩ ∧
    y.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 12)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 13)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩ ∧
    y.node? 10 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 15)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [5], [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)], 12⟩ ∧
    y.node? 11 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 17)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [6], [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)], 12⟩

kernel_rfl KvWFit.srv1 : KvWFit.S1.oracle = KvWFit.O
kernel_rfl KvWFit.arrs : KvWFit.s3.aux.ffi.arrs = setAll KvWFit.s1.aux.ffi.arrs [(4, 0), (5, 0), (8, 5), (9, 6), (10, 7), (11, 8)]
kernel_rfl KvWFit.nodes : KvWFit.s3.aux.ffi.nodes = setAll KvWFit.s1.aux.ffi.nodes (freshOf KvWFit.s3.aux.ffi.nodes KvWFit.s1.aux.ffi.nnext KvWFit.s3.aux.ffi.nnext)
kernel_rfl KvWFit.nsmall : Nat.blt KvWFit.s3.aux.ffi.nnext 1048576 = true
kernel_rfl KvWFit.heap : KvWFit.s3.heap = setAll KvWFit.s1.heap (rangesOf KvWFit.s3.heap [(1378, 1379), (1408, 1409), (1434, 1435)] ++ freshOf KvWFit.s3.heap KvWFit.s1.next KvWFit.s3.next)
kernel_rfl KvWFit.nextLe : Nat.ble KvWFit.s1.next KvWFit.s3.next = true
kernel_rfl KvWFit.small : Nat.blt KvWFit.s3.next 1048576 = true
kernel_rfl KvWFit.jobs : KvWFit.s3.aux.jobs = KvWFit.s1.aux.jobs
kernel_rfl KvWFit.stores : KvWFit.s3.aux.stores = KvWFit.s1.aux.stores
kernel_rfl KvWFit.trace : KvWFit.s3.aux.trace = KvWFit.s3.aux.trace.take (KvWFit.s3.aux.trace.length - KvWFit.s1.aux.trace.length) ++ KvWFit.s1.aux.trace
kernel_rfl KvWFit.off : propOf (KvWFit.s3.obj? 1378) chars!"offset" = some (.num (.ref 8))
kernel_rfl KvWFit.offE : nth? KvWFit.S3.tab 8 = some (Host.Ts.SymE.bin (Host.Ts.NBin.add) (Host.Ts.SymE.var 0) (Host.Ts.SymE.un (Host.Ts.NUn.int32) (Host.Ts.SymE.var 2)))
kernel_rfl KvWFit.keysArr : propOf (KvWFit.s3.obj? 1378) chars!"keys" = some (.obj 1609)
kernel_rfl KvWFit.keysH : handleOf (KvWFit.s3.obj? 1609) = some 8
kernel_rfl KvWFit.valuesArr : propOf (KvWFit.s3.obj? 1378) chars!"values" = some (.obj 1661)
kernel_rfl KvWFit.valuesH : handleOf (KvWFit.s3.obj? 1661) = some 9
kernel_rfl KvWFit.ret : KvWFit.s3.ctl = .ret (.obj 1773)
kernel_rfl KvWFit.freshRet : Nat.ble KvWFit.s1.next 1773 = true
kernel_rfl KvWFit.g8 : KvWFit.s3.aux.ffi.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 9)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩
kernel_rfl KvWFit.g9 : KvWFit.s3.aux.ffi.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 12)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 13)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩
kernel_rfl KvWFit.g10 : KvWFit.s3.aux.ffi.node? 10 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 15)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [5], [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)], 12⟩
kernel_rfl KvWFit.g11 : KvWFit.s3.aux.ffi.node? 11 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 17)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [6], [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)], 12⟩

def KvWFit.ps : List Lin.Prm := [{ lo := 1, hi := 536870912 }, { lo := 0, hi := 1048576 }, { lo := 0, hi := 536870912 }]
def KvWFit.V : List (Nat × Lin.Aff) := [(0, Lin.P 0), (1, Lin.P 0 + Lin.P 1 + Lin.P 2 + 2), (2, Lin.P 1 + 1)]
theorem KvWFit.lin : Lin.goodLin KvWFit.ps KvWFit.V KvWFit.O = true := by decide +kernel

/-- **The KV append of class `KvWFit`.** -/
def KvWFit.stage : Stage MF where
  Par := Nat × Nat × Nat
  Pre q t C := KvWFit.Dom q.1 q.2.1 q.2.2 ∧ t = tplN KvWFit.s1 0 [] ∧ C = ⟨KvWFit.S1.tab.map (SymE.eval (ρ3 q.1 q.2.1 q.2.2))⟩
  Post q t _ t' C' := KvPost 1378 [(1378, 1379), (1408, 1409), (1434, 1435)] [(4, 0), (5, 0), (8, 5), (9, 6), (10, 7), (11, 8)] 8 9 (.num (.ref 8)) (q.1 + q.2.2) KvWFit.G t t' C'

theorem KvWFit.holds : KvWFit.stage.Holds := by
  rintro ⟨o, c, r⟩ t Cs ⟨hd, rfl, rfl⟩
  dsimp only [KvWFit.Dom] at hd
  obtain ⟨h0, h1, h2, h3, h4⟩ := hd
  have hg : Good (ρ3 o c r) KvWFit.O :=
    Lin.goodLin_sound KvWFit.lin (x := Lin.vx [(o : Int), (r : Int) - 1, (c : Int) - o - r - 1]) (by simp only [KvWFit.ps]; lin_mem) (by simp only [KvWFit.V]; lin_mem [ρ3])
  have hi : Inst (ρ3 o c r) KvWFit.S1 ⟨KvWFit.S1.tab.map (SymE.eval (ρ3 o c r))⟩ := ⟨rfl, by rw [KvWFit.srv1]; exact hg⟩
  obtain ⟨_, hrun⟩ := tplN_sim KvWFit.append hi
  refine ⟨2761, tplN KvWFit.s3 0 [], ⟨KvWFit.S3.tab.map (SymE.eval (ρ3 o c r))⟩, ⟨?_, KvWFit.off, ?_, ⟨_, KvWFit.keysArr, KvWFit.keysH⟩,
    ⟨_, KvWFit.valuesArr, KvWFit.valuesH⟩, ⟨1773, KvWFit.ret, Nat.le_of_ble_eq_true KvWFit.freshRet⟩, ⟨KvWFit.g8, KvWFit.g9, KvWFit.g10, KvWFit.g11⟩⟩, hrun⟩
  · exact framedW_of KvWFit.heap KvWFit.nextLe KvWFit.small (by decide) KvWFit.jobs KvWFit.stores KvWFit.trace
      ⟨liveDelta_setAll KvWFit.arrs (by decide) (by decide), nodesKept_of KvWFit.nodes KvWFit.nsmall⟩
  · show natAt _ (.num (.ref 8)) = some (o + r)
    have hv := natAt_ref (C := ⟨KvWFit.S3.tab.map (SymE.eval (ρ3 o c r))⟩) (by rw [nth_inst KvWFit.offE]; exact congrArg some (eval_or o c r (by omega) (by omega))) (n := (o + r : Nat)) (by omega)
    rw [hv] <;> (congr 1; omega)

kernel_rfl KvWFit.arrs6 : KvWFit.s6.aux.ffi.arrs = KvWFit.s4.aux.ffi.arrs
kernel_rfl KvWFit.nodes6 : KvWFit.s6.aux.ffi.nodes = KvWFit.s4.aux.ffi.nodes
kernel_rfl KvWFit.heap6 : KvWFit.s6.heap = setAll KvWFit.s4.heap (rangesOf KvWFit.s6.heap [] ++ freshOf KvWFit.s6.heap KvWFit.s4.next KvWFit.s6.next)
kernel_rfl KvWFit.nextLe6 : Nat.ble KvWFit.s4.next KvWFit.s6.next = true
kernel_rfl KvWFit.small6 : Nat.blt KvWFit.s6.next 1048576 = true
kernel_rfl KvWFit.jobs6 : KvWFit.s6.aux.jobs = KvWFit.s4.aux.jobs
kernel_rfl KvWFit.stores6 : KvWFit.s6.aux.stores = KvWFit.s4.aux.stores
kernel_rfl KvWFit.trace6 : KvWFit.s6.aux.trace = KvWFit.s6.aux.trace.take 3 ++ KvWFit.s4.aux.trace
kernel_rfl KvWFit.syms6 : (KvWFit.s6.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl KvWFit.vec6 : KvWFit.s6.aux.ffi.objs.get KvWFit.s4.aux.ffi.next = some (.vec [5, 6])

/-- **`evalCacheState` after the append of class `KvWFit`** (parameter: the valuation). -/
def KvWFit.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN KvWFit.s4 0 [] ∧ Inst ρ KvWFit.S4 C
  Post ρ t _ t' C' := EvalPost [5, 6] t t' ∧ Inst ρ KvWFit.S6 C'

theorem KvWFit.evalHolds : KvWFit.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim KvWFit.eval hi
  exact ⟨946, tplN KvWFit.s6 0 [], _, ⟨⟨framedW_of KvWFit.heap6 KvWFit.nextLe6 KvWFit.small6 (by decide) KvWFit.jobs6 KvWFit.stores6 KvWFit.trace6
    ⟨KvWFit.arrs6, KvWFit.nodes6⟩, KvWFit.syms6, KvWFit.vec6⟩, hi'⟩, hrun⟩

/-! ## Class `KvWFill`: a window of `r` rows filling the buffer (`o + r = cap`) -/

/-- The inputs of class `KvWFill`. -/
def KvWFill.Dom (o c r : Nat) : Prop := 1 ≤ o ∧ 1 ≤ r ∧ r ≤ 1048576 ∧ c = o + r ∧ c ≤ 536870912

/-- The graph of class `KvWFill`'s new handles. -/
def KvWFill.G (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 9)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩ ∧
    y.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 12)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 13)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩ ∧
    y.node? 10 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 9)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩ ∧
    y.node? 11 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 12)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 13)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩

kernel_rfl KvWFill.srv1 : KvWFill.S1.oracle = KvWFill.O
kernel_rfl KvWFill.arrs : KvWFill.s3.aux.ffi.arrs = setAll KvWFill.s1.aux.ffi.arrs [(4, 0), (5, 0), (8, 5), (9, 6), (10, 5), (11, 6)]
kernel_rfl KvWFill.nodes : KvWFill.s3.aux.ffi.nodes = setAll KvWFill.s1.aux.ffi.nodes (freshOf KvWFill.s3.aux.ffi.nodes KvWFill.s1.aux.ffi.nnext KvWFill.s3.aux.ffi.nnext)
kernel_rfl KvWFill.nsmall : Nat.blt KvWFill.s3.aux.ffi.nnext 1048576 = true
kernel_rfl KvWFill.heap : KvWFill.s3.heap = setAll KvWFill.s1.heap (rangesOf KvWFill.s3.heap [(1378, 1379), (1408, 1409), (1434, 1435)] ++ freshOf KvWFill.s3.heap KvWFill.s1.next KvWFill.s3.next)
kernel_rfl KvWFill.nextLe : Nat.ble KvWFill.s1.next KvWFill.s3.next = true
kernel_rfl KvWFill.small : Nat.blt KvWFill.s3.next 1048576 = true
kernel_rfl KvWFill.jobs : KvWFill.s3.aux.jobs = KvWFill.s1.aux.jobs
kernel_rfl KvWFill.stores : KvWFill.s3.aux.stores = KvWFill.s1.aux.stores
kernel_rfl KvWFill.trace : KvWFill.s3.aux.trace = KvWFill.s3.aux.trace.take (KvWFill.s3.aux.trace.length - KvWFill.s1.aux.trace.length) ++ KvWFill.s1.aux.trace
kernel_rfl KvWFill.off : propOf (KvWFill.s3.obj? 1378) chars!"offset" = some (.num (.ref 8))
kernel_rfl KvWFill.offE : nth? KvWFill.S3.tab 8 = some (Host.Ts.SymE.bin (Host.Ts.NBin.add) (Host.Ts.SymE.var 0) (Host.Ts.SymE.un (Host.Ts.NUn.int32) (Host.Ts.SymE.var 2)))
kernel_rfl KvWFill.keysArr : propOf (KvWFill.s3.obj? 1378) chars!"keys" = some (.obj 1609)
kernel_rfl KvWFill.keysH : handleOf (KvWFill.s3.obj? 1609) = some 8
kernel_rfl KvWFill.valuesArr : propOf (KvWFill.s3.obj? 1378) chars!"values" = some (.obj 1661)
kernel_rfl KvWFill.valuesH : handleOf (KvWFill.s3.obj? 1661) = some 9
kernel_rfl KvWFill.ret : KvWFill.s3.ctl = .ret (.obj 1773)
kernel_rfl KvWFill.freshRet : Nat.ble KvWFill.s1.next 1773 = true
kernel_rfl KvWFill.g8 : KvWFill.s3.aux.ffi.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 9)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩
kernel_rfl KvWFill.g9 : KvWFill.s3.aux.ffi.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 12)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 13)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩
kernel_rfl KvWFill.g10 : KvWFill.s3.aux.ffi.node? 10 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 9)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [1, 3], [(.lit 1), (.lit 4), (.sym (.ref 3)), (.lit 256)], 12⟩
kernel_rfl KvWFill.g11 : KvWFill.s3.aux.ffi.node? 11 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 12)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 13)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [2, 4], [(.lit 1), (.lit 4), (.sym (.ref 4)), (.lit 256)], 12⟩

def KvWFill.ps : List Lin.Prm := [{ lo := 1, hi := 536870912 }, { lo := 0, hi := 1048576 }]
def KvWFill.V : List (Nat × Lin.Aff) := [(0, Lin.P 0), (1, Lin.P 0 + Lin.P 1 + 1), (2, Lin.P 1 + 1)]
theorem KvWFill.lin : Lin.goodLin KvWFill.ps KvWFill.V KvWFill.O = true := by decide +kernel

/-- **The KV append of class `KvWFill`.** -/
def KvWFill.stage : Stage MF where
  Par := Nat × Nat × Nat
  Pre q t C := KvWFill.Dom q.1 q.2.1 q.2.2 ∧ t = tplN KvWFill.s1 0 [] ∧ C = ⟨KvWFill.S1.tab.map (SymE.eval (ρ3 q.1 q.2.1 q.2.2))⟩
  Post q t _ t' C' := KvPost 1378 [(1378, 1379), (1408, 1409), (1434, 1435)] [(4, 0), (5, 0), (8, 5), (9, 6), (10, 5), (11, 6)] 8 9 (.num (.ref 8)) (q.1 + q.2.2) KvWFill.G t t' C'

theorem KvWFill.holds : KvWFill.stage.Holds := by
  rintro ⟨o, c, r⟩ t Cs ⟨hd, rfl, rfl⟩
  dsimp only [KvWFill.Dom] at hd
  obtain ⟨h0, h1, h2, h3, h4⟩ := hd
  have hg : Good (ρ3 o c r) KvWFill.O :=
    Lin.goodLin_sound KvWFill.lin (x := Lin.vx [(o : Int), (r : Int) - 1]) (by simp only [KvWFill.ps]; lin_mem) (by simp only [KvWFill.V]; lin_mem [ρ3])
  have hi : Inst (ρ3 o c r) KvWFill.S1 ⟨KvWFill.S1.tab.map (SymE.eval (ρ3 o c r))⟩ := ⟨rfl, by rw [KvWFill.srv1]; exact hg⟩
  obtain ⟨_, hrun⟩ := tplN_sim KvWFill.append hi
  refine ⟨2761, tplN KvWFill.s3 0 [], ⟨KvWFill.S3.tab.map (SymE.eval (ρ3 o c r))⟩, ⟨?_, KvWFill.off, ?_, ⟨_, KvWFill.keysArr, KvWFill.keysH⟩,
    ⟨_, KvWFill.valuesArr, KvWFill.valuesH⟩, ⟨1773, KvWFill.ret, Nat.le_of_ble_eq_true KvWFill.freshRet⟩, ⟨KvWFill.g8, KvWFill.g9, KvWFill.g10, KvWFill.g11⟩⟩, hrun⟩
  · exact framedW_of KvWFill.heap KvWFill.nextLe KvWFill.small (by decide) KvWFill.jobs KvWFill.stores KvWFill.trace
      ⟨liveDelta_setAll KvWFill.arrs (by decide) (by decide), nodesKept_of KvWFill.nodes KvWFill.nsmall⟩
  · show natAt _ (.num (.ref 8)) = some (o + r)
    have hv := natAt_ref (C := ⟨KvWFill.S3.tab.map (SymE.eval (ρ3 o c r))⟩) (by rw [nth_inst KvWFill.offE]; exact congrArg some (eval_or o c r (by omega) (by omega))) (n := (o + r : Nat)) (by omega)
    rw [hv] <;> (congr 1; omega)

kernel_rfl KvWFill.arrs6 : KvWFill.s6.aux.ffi.arrs = KvWFill.s4.aux.ffi.arrs
kernel_rfl KvWFill.nodes6 : KvWFill.s6.aux.ffi.nodes = KvWFill.s4.aux.ffi.nodes
kernel_rfl KvWFill.heap6 : KvWFill.s6.heap = setAll KvWFill.s4.heap (rangesOf KvWFill.s6.heap [] ++ freshOf KvWFill.s6.heap KvWFill.s4.next KvWFill.s6.next)
kernel_rfl KvWFill.nextLe6 : Nat.ble KvWFill.s4.next KvWFill.s6.next = true
kernel_rfl KvWFill.small6 : Nat.blt KvWFill.s6.next 1048576 = true
kernel_rfl KvWFill.jobs6 : KvWFill.s6.aux.jobs = KvWFill.s4.aux.jobs
kernel_rfl KvWFill.stores6 : KvWFill.s6.aux.stores = KvWFill.s4.aux.stores
kernel_rfl KvWFill.trace6 : KvWFill.s6.aux.trace = KvWFill.s6.aux.trace.take 3 ++ KvWFill.s4.aux.trace
kernel_rfl KvWFill.syms6 : (KvWFill.s6.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl KvWFill.vec6 : KvWFill.s6.aux.ffi.objs.get KvWFill.s4.aux.ffi.next = some (.vec [5, 6])

/-- **`evalCacheState` after the append of class `KvWFill`** (parameter: the valuation). -/
def KvWFill.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN KvWFill.s4 0 [] ∧ Inst ρ KvWFill.S4 C
  Post ρ t _ t' C' := EvalPost [5, 6] t t' ∧ Inst ρ KvWFill.S6 C'

theorem KvWFill.evalHolds : KvWFill.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim KvWFill.eval hi
  exact ⟨946, tplN KvWFill.s6 0 [], _, ⟨⟨framedW_of KvWFill.heap6 KvWFill.nextLe6 KvWFill.small6 (by decide) KvWFill.jobs6 KvWFill.stores6 KvWFill.trace6
    ⟨KvWFill.arrs6, KvWFill.nodes6⟩, KvWFill.syms6, KvWFill.vec6⟩, hi'⟩, hrun⟩

/-! ## Class `KvWGrow`: a window of `r` rows (`r % 256 ≠ 0`, a tail) at a full buffer: grows by `256·⌈r/256⌉` -/

/-- The inputs of class `KvWGrow`. -/
def KvWGrow.Dom (o c r : Nat) : Prop := 256 ≤ o ∧ o % 256 = 0 ∧ c = o ∧ o ≤ 536870912 ∧ 1 ≤ r ∧ r ≤ 1048576 ∧ r % 256 ≠ 0

/-- The graph of class `KvWGrow`'s new handles. -/
def KvWGrow.G (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 14 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 20)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 21)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [7, 3], [(.lit 1), (.lit 4), (.sym (.ref 17)), (.lit 256)], 12⟩ ∧
    y.node? 15 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 23)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 24)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [8, 4], [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)], 12⟩ ∧
    y.node? 16 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 26)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [9], [(.lit 1), (.lit 4), (.sym (.ref 27)), (.lit 256)], 12⟩ ∧
    y.node? 17 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 28)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [10], [(.lit 1), (.lit 4), (.sym (.ref 29)), (.lit 256)], 12⟩

kernel_rfl KvWGrow.srv1 : KvWGrow.S1.oracle = KvWGrow.O
kernel_rfl KvWGrow.arrs : KvWGrow.s3.aux.ffi.arrs = setAll KvWGrow.s1.aux.ffi.arrs [(4, 0), (5, 0), (8, 0), (9, 0), (11, 0), (13, 0), (14, 9), (15, 10), (16, 11), (17, 12)]
kernel_rfl KvWGrow.nodes : KvWGrow.s3.aux.ffi.nodes = setAll KvWGrow.s1.aux.ffi.nodes (freshOf KvWGrow.s3.aux.ffi.nodes KvWGrow.s1.aux.ffi.nnext KvWGrow.s3.aux.ffi.nnext)
kernel_rfl KvWGrow.nsmall : Nat.blt KvWGrow.s3.aux.ffi.nnext 1048576 = true
kernel_rfl KvWGrow.heap : KvWGrow.s3.heap = setAll KvWGrow.s1.heap (rangesOf KvWGrow.s3.heap [(1378, 1379), (1408, 1409), (1434, 1435)] ++ freshOf KvWGrow.s3.heap KvWGrow.s1.next KvWGrow.s3.next)
kernel_rfl KvWGrow.nextLe : Nat.ble KvWGrow.s1.next KvWGrow.s3.next = true
kernel_rfl KvWGrow.small : Nat.blt KvWGrow.s3.next 1048576 = true
kernel_rfl KvWGrow.jobs : KvWGrow.s3.aux.jobs = KvWGrow.s1.aux.jobs
kernel_rfl KvWGrow.stores : KvWGrow.s3.aux.stores = KvWGrow.s1.aux.stores
kernel_rfl KvWGrow.trace : KvWGrow.s3.aux.trace = KvWGrow.s3.aux.trace.take (KvWGrow.s3.aux.trace.length - KvWGrow.s1.aux.trace.length) ++ KvWGrow.s1.aux.trace
kernel_rfl KvWGrow.off : propOf (KvWGrow.s3.obj? 1378) chars!"offset" = some (.num (.ref 19))
kernel_rfl KvWGrow.offE : nth? KvWGrow.S3.tab 19 = some (Host.Ts.SymE.bin (Host.Ts.NBin.add) (Host.Ts.SymE.var 0) (Host.Ts.SymE.un (Host.Ts.NUn.int32) (Host.Ts.SymE.var 2)))
kernel_rfl KvWGrow.keysArr : propOf (KvWGrow.s3.obj? 1378) chars!"keys" = some (.obj 1805)
kernel_rfl KvWGrow.keysH : handleOf (KvWGrow.s3.obj? 1805) = some 14
kernel_rfl KvWGrow.valuesArr : propOf (KvWGrow.s3.obj? 1378) chars!"values" = some (.obj 1857)
kernel_rfl KvWGrow.valuesH : handleOf (KvWGrow.s3.obj? 1857) = some 15
kernel_rfl KvWGrow.ret : KvWGrow.s3.ctl = .ret (.obj 1969)
kernel_rfl KvWGrow.freshRet : Nat.ble KvWGrow.s1.next 1969 = true
kernel_rfl KvWGrow.g14 : KvWGrow.s3.aux.ffi.node? 14 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 20)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 21)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [7, 3], [(.lit 1), (.lit 4), (.sym (.ref 17)), (.lit 256)], 12⟩
kernel_rfl KvWGrow.g15 : KvWGrow.s3.aux.ffi.node? 15 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 23)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 24)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [8, 4], [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)], 12⟩
kernel_rfl KvWGrow.g16 : KvWGrow.s3.aux.ffi.node? 16 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 26)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [9], [(.lit 1), (.lit 4), (.sym (.ref 27)), (.lit 256)], 12⟩
kernel_rfl KvWGrow.g17 : KvWGrow.s3.aux.ffi.node? 17 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 28)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [10], [(.lit 1), (.lit 4), (.sym (.ref 29)), (.lit 256)], 12⟩

def KvWGrow.ps : List Lin.Prm := [{ lo := 1, hi := 2097152 }, { lo := 0, hi := 4096 }, { lo := 1, hi := 255 }]
def KvWGrow.V : List (Nat × Lin.Aff) := [(0, (256 : Nat) • Lin.P 0), (1, (256 : Nat) • Lin.P 0), (2, (256 : Nat) • Lin.P 1 + Lin.P 2)]
theorem KvWGrow.lin : Lin.goodLin KvWGrow.ps KvWGrow.V KvWGrow.O = true := by decide +kernel

/-- **The KV append of class `KvWGrow`.** -/
def KvWGrow.stage : Stage MF where
  Par := Nat × Nat × Nat
  Pre q t C := KvWGrow.Dom q.1 q.2.1 q.2.2 ∧ t = tplN KvWGrow.s1 0 [] ∧ C = ⟨KvWGrow.S1.tab.map (SymE.eval (ρ3 q.1 q.2.1 q.2.2))⟩
  Post q t _ t' C' := KvPost 1378 [(1378, 1379), (1408, 1409), (1434, 1435)] [(4, 0), (5, 0), (8, 0), (9, 0), (11, 0), (13, 0), (14, 9), (15, 10), (16, 11), (17, 12)] 14 15 (.num (.ref 19)) (q.1 + q.2.2) KvWGrow.G t t' C'

theorem KvWGrow.holds : KvWGrow.stage.Holds := by
  rintro ⟨o, c, r⟩ t Cs ⟨hd, rfl, rfl⟩
  dsimp only [KvWGrow.Dom] at hd
  obtain ⟨h0, h1, h2, h3, h4, h5, h6⟩ := hd
  have hg : Good (ρ3 o c r) KvWGrow.O :=
    Lin.goodLin_sound KvWGrow.lin (x := Lin.vx [(o : Int) / 256, (r : Int) / 256, (r : Int) % 256]) (by simp only [KvWGrow.ps]; lin_mem) (by simp only [KvWGrow.V]; lin_mem [ρ3])
  have hi : Inst (ρ3 o c r) KvWGrow.S1 ⟨KvWGrow.S1.tab.map (SymE.eval (ρ3 o c r))⟩ := ⟨rfl, by rw [KvWGrow.srv1]; exact hg⟩
  obtain ⟨_, hrun⟩ := tplN_sim KvWGrow.append hi
  refine ⟨4626, tplN KvWGrow.s3 0 [], ⟨KvWGrow.S3.tab.map (SymE.eval (ρ3 o c r))⟩, ⟨?_, KvWGrow.off, ?_, ⟨_, KvWGrow.keysArr, KvWGrow.keysH⟩,
    ⟨_, KvWGrow.valuesArr, KvWGrow.valuesH⟩, ⟨1969, KvWGrow.ret, Nat.le_of_ble_eq_true KvWGrow.freshRet⟩, ⟨KvWGrow.g14, KvWGrow.g15, KvWGrow.g16, KvWGrow.g17⟩⟩, hrun⟩
  · exact framedW_of KvWGrow.heap KvWGrow.nextLe KvWGrow.small (by decide) KvWGrow.jobs KvWGrow.stores KvWGrow.trace
      ⟨liveDelta_setAll KvWGrow.arrs (by decide) (by decide), nodesKept_of KvWGrow.nodes KvWGrow.nsmall⟩
  · show natAt _ (.num (.ref 19)) = some (o + r)
    have hv := natAt_ref (C := ⟨KvWGrow.S3.tab.map (SymE.eval (ρ3 o c r))⟩) (by rw [nth_inst KvWGrow.offE]; exact congrArg some (eval_or o c r (by omega) (by omega))) (n := (o + r : Nat)) (by omega)
    rw [hv] <;> (congr 1; omega)

kernel_rfl KvWGrow.arrs6 : KvWGrow.s6.aux.ffi.arrs = KvWGrow.s4.aux.ffi.arrs
kernel_rfl KvWGrow.nodes6 : KvWGrow.s6.aux.ffi.nodes = KvWGrow.s4.aux.ffi.nodes
kernel_rfl KvWGrow.heap6 : KvWGrow.s6.heap = setAll KvWGrow.s4.heap (rangesOf KvWGrow.s6.heap [] ++ freshOf KvWGrow.s6.heap KvWGrow.s4.next KvWGrow.s6.next)
kernel_rfl KvWGrow.nextLe6 : Nat.ble KvWGrow.s4.next KvWGrow.s6.next = true
kernel_rfl KvWGrow.small6 : Nat.blt KvWGrow.s6.next 1048576 = true
kernel_rfl KvWGrow.jobs6 : KvWGrow.s6.aux.jobs = KvWGrow.s4.aux.jobs
kernel_rfl KvWGrow.stores6 : KvWGrow.s6.aux.stores = KvWGrow.s4.aux.stores
kernel_rfl KvWGrow.trace6 : KvWGrow.s6.aux.trace = KvWGrow.s6.aux.trace.take 3 ++ KvWGrow.s4.aux.trace
kernel_rfl KvWGrow.syms6 : (KvWGrow.s6.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl KvWGrow.vec6 : KvWGrow.s6.aux.ffi.objs.get KvWGrow.s4.aux.ffi.next = some (.vec [9, 10])

/-- **`evalCacheState` after the append of class `KvWGrow`** (parameter: the valuation). -/
def KvWGrow.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN KvWGrow.s4 0 [] ∧ Inst ρ KvWGrow.S4 C
  Post ρ t _ t' C' := EvalPost [9, 10] t t' ∧ Inst ρ KvWGrow.S6 C'

theorem KvWGrow.evalHolds : KvWGrow.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim KvWGrow.eval hi
  exact ⟨946, tplN KvWGrow.s6 0 [], _, ⟨⟨framedW_of KvWGrow.heap6 KvWGrow.nextLe6 KvWGrow.small6 (by decide) KvWGrow.jobs6 KvWGrow.stores6 KvWGrow.trace6
    ⟨KvWGrow.arrs6, KvWGrow.nodes6⟩, KvWGrow.syms6, KvWGrow.vec6⟩, hi'⟩, hrun⟩

/-! ## Class `KvWGrow256`: a whole chunk (`r % 256 = 0`) at a full buffer: grows by `r`, the views are the buffer -/

/-- The inputs of class `KvWGrow256`. -/
def KvWGrow256.Dom (o c r : Nat) : Prop := 256 ≤ o ∧ o % 256 = 0 ∧ c = o ∧ o ≤ 536870912 ∧ 256 ≤ r ∧ r ≤ 1048576 ∧ r % 256 = 0

/-- The graph of class `KvWGrow256`'s new handles. -/
def KvWGrow256.G (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 14 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 20)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 21)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [7, 3], [(.lit 1), (.lit 4), (.sym (.ref 17)), (.lit 256)], 12⟩ ∧
    y.node? 15 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 23)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 24)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [8, 4], [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)], 12⟩ ∧
    y.node? 16 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 20)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 21)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [7, 3], [(.lit 1), (.lit 4), (.sym (.ref 17)), (.lit 256)], 12⟩ ∧
    y.node? 17 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 23)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 24)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [8, 4], [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)], 12⟩

kernel_rfl KvWGrow256.srv1 : KvWGrow256.S1.oracle = KvWGrow256.O
kernel_rfl KvWGrow256.arrs : KvWGrow256.s3.aux.ffi.arrs = setAll KvWGrow256.s1.aux.ffi.arrs [(4, 0), (5, 0), (8, 0), (9, 0), (11, 0), (13, 0), (14, 9), (15, 10), (16, 9), (17, 10)]
kernel_rfl KvWGrow256.nodes : KvWGrow256.s3.aux.ffi.nodes = setAll KvWGrow256.s1.aux.ffi.nodes (freshOf KvWGrow256.s3.aux.ffi.nodes KvWGrow256.s1.aux.ffi.nnext KvWGrow256.s3.aux.ffi.nnext)
kernel_rfl KvWGrow256.nsmall : Nat.blt KvWGrow256.s3.aux.ffi.nnext 1048576 = true
kernel_rfl KvWGrow256.heap : KvWGrow256.s3.heap = setAll KvWGrow256.s1.heap (rangesOf KvWGrow256.s3.heap [(1378, 1379), (1408, 1409), (1434, 1435)] ++ freshOf KvWGrow256.s3.heap KvWGrow256.s1.next KvWGrow256.s3.next)
kernel_rfl KvWGrow256.nextLe : Nat.ble KvWGrow256.s1.next KvWGrow256.s3.next = true
kernel_rfl KvWGrow256.small : Nat.blt KvWGrow256.s3.next 1048576 = true
kernel_rfl KvWGrow256.jobs : KvWGrow256.s3.aux.jobs = KvWGrow256.s1.aux.jobs
kernel_rfl KvWGrow256.stores : KvWGrow256.s3.aux.stores = KvWGrow256.s1.aux.stores
kernel_rfl KvWGrow256.trace : KvWGrow256.s3.aux.trace = KvWGrow256.s3.aux.trace.take (KvWGrow256.s3.aux.trace.length - KvWGrow256.s1.aux.trace.length) ++ KvWGrow256.s1.aux.trace
kernel_rfl KvWGrow256.off : propOf (KvWGrow256.s3.obj? 1378) chars!"offset" = some (.num (.ref 19))
kernel_rfl KvWGrow256.offE : nth? KvWGrow256.S3.tab 19 = some (Host.Ts.SymE.bin (Host.Ts.NBin.add) (Host.Ts.SymE.var 0) (Host.Ts.SymE.un (Host.Ts.NUn.int32) (Host.Ts.SymE.var 2)))
kernel_rfl KvWGrow256.keysArr : propOf (KvWGrow256.s3.obj? 1378) chars!"keys" = some (.obj 1805)
kernel_rfl KvWGrow256.keysH : handleOf (KvWGrow256.s3.obj? 1805) = some 14
kernel_rfl KvWGrow256.valuesArr : propOf (KvWGrow256.s3.obj? 1378) chars!"values" = some (.obj 1857)
kernel_rfl KvWGrow256.valuesH : handleOf (KvWGrow256.s3.obj? 1857) = some 15
kernel_rfl KvWGrow256.ret : KvWGrow256.s3.ctl = .ret (.obj 1969)
kernel_rfl KvWGrow256.freshRet : Nat.ble KvWGrow256.s1.next 1969 = true
kernel_rfl KvWGrow256.g14 : KvWGrow256.s3.aux.ffi.node? 14 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 20)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 21)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [7, 3], [(.lit 1), (.lit 4), (.sym (.ref 17)), (.lit 256)], 12⟩
kernel_rfl KvWGrow256.g15 : KvWGrow256.s3.aux.ffi.node? 15 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 23)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 24)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [8, 4], [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)], 12⟩
kernel_rfl KvWGrow256.g16 : KvWGrow256.s3.aux.ffi.node? 16 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 20)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 21)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [7, 3], [(.lit 1), (.lit 4), (.sym (.ref 17)), (.lit 256)], 12⟩
kernel_rfl KvWGrow256.g17 : KvWGrow256.s3.aux.ffi.node? 17 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.sym (.ref 23)), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 24)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [8, 4], [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)], 12⟩

def KvWGrow256.ps : List Lin.Prm := [{ lo := 1, hi := 2097152 }, { lo := 1, hi := 4096 }]
def KvWGrow256.V : List (Nat × Lin.Aff) := [(0, (256 : Nat) • Lin.P 0), (1, (256 : Nat) • Lin.P 0), (2, (256 : Nat) • Lin.P 1)]
theorem KvWGrow256.lin : Lin.goodLin KvWGrow256.ps KvWGrow256.V KvWGrow256.O = true := by decide +kernel

/-- **The KV append of class `KvWGrow256`.** -/
def KvWGrow256.stage : Stage MF where
  Par := Nat × Nat × Nat
  Pre q t C := KvWGrow256.Dom q.1 q.2.1 q.2.2 ∧ t = tplN KvWGrow256.s1 0 [] ∧ C = ⟨KvWGrow256.S1.tab.map (SymE.eval (ρ3 q.1 q.2.1 q.2.2))⟩
  Post q t _ t' C' := KvPost 1378 [(1378, 1379), (1408, 1409), (1434, 1435)] [(4, 0), (5, 0), (8, 0), (9, 0), (11, 0), (13, 0), (14, 9), (15, 10), (16, 9), (17, 10)] 14 15 (.num (.ref 19)) (q.1 + q.2.2) KvWGrow256.G t t' C'

theorem KvWGrow256.holds : KvWGrow256.stage.Holds := by
  rintro ⟨o, c, r⟩ t Cs ⟨hd, rfl, rfl⟩
  dsimp only [KvWGrow256.Dom] at hd
  obtain ⟨h0, h1, h2, h3, h4, h5, h6⟩ := hd
  have hg : Good (ρ3 o c r) KvWGrow256.O :=
    Lin.goodLin_sound KvWGrow256.lin (x := Lin.vx [(o : Int) / 256, (r : Int) / 256]) (by simp only [KvWGrow256.ps]; lin_mem) (by simp only [KvWGrow256.V]; lin_mem [ρ3])
  have hi : Inst (ρ3 o c r) KvWGrow256.S1 ⟨KvWGrow256.S1.tab.map (SymE.eval (ρ3 o c r))⟩ := ⟨rfl, by rw [KvWGrow256.srv1]; exact hg⟩
  obtain ⟨_, hrun⟩ := tplN_sim KvWGrow256.append hi
  refine ⟨4626, tplN KvWGrow256.s3 0 [], ⟨KvWGrow256.S3.tab.map (SymE.eval (ρ3 o c r))⟩, ⟨?_, KvWGrow256.off, ?_, ⟨_, KvWGrow256.keysArr, KvWGrow256.keysH⟩,
    ⟨_, KvWGrow256.valuesArr, KvWGrow256.valuesH⟩, ⟨1969, KvWGrow256.ret, Nat.le_of_ble_eq_true KvWGrow256.freshRet⟩, ⟨KvWGrow256.g14, KvWGrow256.g15, KvWGrow256.g16, KvWGrow256.g17⟩⟩, hrun⟩
  · exact framedW_of KvWGrow256.heap KvWGrow256.nextLe KvWGrow256.small (by decide) KvWGrow256.jobs KvWGrow256.stores KvWGrow256.trace
      ⟨liveDelta_setAll KvWGrow256.arrs (by decide) (by decide), nodesKept_of KvWGrow256.nodes KvWGrow256.nsmall⟩
  · show natAt _ (.num (.ref 19)) = some (o + r)
    have hv := natAt_ref (C := ⟨KvWGrow256.S3.tab.map (SymE.eval (ρ3 o c r))⟩) (by rw [nth_inst KvWGrow256.offE]; exact congrArg some (eval_or o c r (by omega) (by omega))) (n := (o + r : Nat)) (by omega)
    rw [hv] <;> (congr 1; omega)

kernel_rfl KvWGrow256.arrs6 : KvWGrow256.s6.aux.ffi.arrs = KvWGrow256.s4.aux.ffi.arrs
kernel_rfl KvWGrow256.nodes6 : KvWGrow256.s6.aux.ffi.nodes = KvWGrow256.s4.aux.ffi.nodes
kernel_rfl KvWGrow256.heap6 : KvWGrow256.s6.heap = setAll KvWGrow256.s4.heap (rangesOf KvWGrow256.s6.heap [] ++ freshOf KvWGrow256.s6.heap KvWGrow256.s4.next KvWGrow256.s6.next)
kernel_rfl KvWGrow256.nextLe6 : Nat.ble KvWGrow256.s4.next KvWGrow256.s6.next = true
kernel_rfl KvWGrow256.small6 : Nat.blt KvWGrow256.s6.next 1048576 = true
kernel_rfl KvWGrow256.jobs6 : KvWGrow256.s6.aux.jobs = KvWGrow256.s4.aux.jobs
kernel_rfl KvWGrow256.stores6 : KvWGrow256.s6.aux.stores = KvWGrow256.s4.aux.stores
kernel_rfl KvWGrow256.trace6 : KvWGrow256.s6.aux.trace = KvWGrow256.s6.aux.trace.take 3 ++ KvWGrow256.s4.aux.trace
kernel_rfl KvWGrow256.syms6 : (KvWGrow256.s6.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl KvWGrow256.vec6 : KvWGrow256.s6.aux.ffi.objs.get KvWGrow256.s4.aux.ffi.next = some (.vec [9, 10])

/-- **`evalCacheState` after the append of class `KvWGrow256`** (parameter: the valuation). -/
def KvWGrow256.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN KvWGrow256.s4 0 [] ∧ Inst ρ KvWGrow256.S4 C
  Post ρ t _ t' C' := EvalPost [9, 10] t t' ∧ Inst ρ KvWGrow256.S6 C'

theorem KvWGrow256.evalHolds : KvWGrow256.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim KvWGrow256.eval hi
  exact ⟨946, tplN KvWGrow256.s6 0 [], _, ⟨⟨framedW_of KvWGrow256.heap6 KvWGrow256.nextLe6 KvWGrow256.small6 (by decide) KvWGrow256.jobs6 KvWGrow256.stores6 KvWGrow256.trace6
    ⟨KvWGrow256.arrs6, KvWGrow256.nodes6⟩, KvWGrow256.syms6, KvWGrow256.vec6⟩, hi'⟩, hrun⟩

/-! ## Class `KvWFirst`: the first window (`r % 256 ≠ 0`) into a null buffer -/

/-- The inputs of class `KvWFirst`. -/
def KvWFirst.Dom (o c r : Nat) : Prop := o = 0 ∧ c = 0 ∧ 1 ≤ r ∧ r ≤ 1048576 ∧ r % 256 ≠ 0

/-- The graph of class `KvWFirst`'s new handles. -/
def KvWFirst.G (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 14)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [3, 1], [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)], 12⟩ ∧
    y.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [4, 2], [(.lit 1), (.lit 4), (.sym (.ref 12)), (.lit 256)], 12⟩ ∧
    y.node? 10 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [5], [(.lit 1), (.lit 4), (.sym (.ref 19)), (.lit 256)], 12⟩ ∧
    y.node? 11 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 20)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [6], [(.lit 1), (.lit 4), (.sym (.ref 21)), (.lit 256)], 12⟩

kernel_rfl KvWFirst.srv1 : KvWFirst.S1.oracle = KvWFirst.O
kernel_rfl KvWFirst.arrs : KvWFirst.s3.aux.ffi.arrs = setAll KvWFirst.s1.aux.ffi.arrs [(6, 0), (7, 0), (8, 5), (9, 6), (10, 7), (11, 8)]
kernel_rfl KvWFirst.nodes : KvWFirst.s3.aux.ffi.nodes = setAll KvWFirst.s1.aux.ffi.nodes (freshOf KvWFirst.s3.aux.ffi.nodes KvWFirst.s1.aux.ffi.nnext KvWFirst.s3.aux.ffi.nnext)
kernel_rfl KvWFirst.nsmall : Nat.blt KvWFirst.s3.aux.ffi.nnext 1048576 = true
kernel_rfl KvWFirst.heap : KvWFirst.s3.heap = setAll KvWFirst.s1.heap (rangesOf KvWFirst.s3.heap [(1378, 1379)] ++ freshOf KvWFirst.s3.heap KvWFirst.s1.next KvWFirst.s3.next)
kernel_rfl KvWFirst.nextLe : Nat.ble KvWFirst.s1.next KvWFirst.s3.next = true
kernel_rfl KvWFirst.small : Nat.blt KvWFirst.s3.next 1048576 = true
kernel_rfl KvWFirst.jobs : KvWFirst.s3.aux.jobs = KvWFirst.s1.aux.jobs
kernel_rfl KvWFirst.stores : KvWFirst.s3.aux.stores = KvWFirst.s1.aux.stores
kernel_rfl KvWFirst.trace : KvWFirst.s3.aux.trace = KvWFirst.s3.aux.trace.take (KvWFirst.s3.aux.trace.length - KvWFirst.s1.aux.trace.length) ++ KvWFirst.s1.aux.trace
kernel_rfl KvWFirst.off : propOf (KvWFirst.s3.obj? 1378) chars!"offset" = some (.num (.ref 13))
kernel_rfl KvWFirst.offE : nth? KvWFirst.S3.tab 13 = some (Host.Ts.SymE.bin (Host.Ts.NBin.add) (Host.Ts.SymE.lit (Host.Ts.F64.zero false)) (Host.Ts.SymE.un (Host.Ts.NUn.int32) (Host.Ts.SymE.var 2)))
kernel_rfl KvWFirst.keysArr : propOf (KvWFirst.s3.obj? 1378) chars!"keys" = some (.obj 1637)
kernel_rfl KvWFirst.keysH : handleOf (KvWFirst.s3.obj? 1637) = some 8
kernel_rfl KvWFirst.valuesArr : propOf (KvWFirst.s3.obj? 1378) chars!"values" = some (.obj 1689)
kernel_rfl KvWFirst.valuesH : handleOf (KvWFirst.s3.obj? 1689) = some 9
kernel_rfl KvWFirst.ret : KvWFirst.s3.ctl = .ret (.obj 1801)
kernel_rfl KvWFirst.freshRet : Nat.ble KvWFirst.s1.next 1801 = true
kernel_rfl KvWFirst.g8 : KvWFirst.s3.aux.ffi.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 14)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [3, 1], [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)], 12⟩
kernel_rfl KvWFirst.g9 : KvWFirst.s3.aux.ffi.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [4, 2], [(.lit 1), (.lit 4), (.sym (.ref 12)), (.lit 256)], 12⟩
kernel_rfl KvWFirst.g10 : KvWFirst.s3.aux.ffi.node? 10 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 18)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [5], [(.lit 1), (.lit 4), (.sym (.ref 19)), (.lit 256)], 12⟩
kernel_rfl KvWFirst.g11 : KvWFirst.s3.aux.ffi.node? 11 = some ⟨(.slice [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 20)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [6], [(.lit 1), (.lit 4), (.sym (.ref 21)), (.lit 256)], 12⟩

def KvWFirst.ps : List Lin.Prm := [{ lo := 0, hi := 4096 }, { lo := 1, hi := 255 }]
def KvWFirst.V : List (Nat × Lin.Aff) := [(0, 0), (1, 0), (2, (256 : Nat) • Lin.P 0 + Lin.P 1)]
theorem KvWFirst.lin : Lin.goodLin KvWFirst.ps KvWFirst.V KvWFirst.O = true := by decide +kernel

/-- **The KV append of class `KvWFirst`.** -/
def KvWFirst.stage : Stage MF where
  Par := Nat × Nat × Nat
  Pre q t C := KvWFirst.Dom q.1 q.2.1 q.2.2 ∧ t = tplN KvWFirst.s1 0 [] ∧ C = ⟨KvWFirst.S1.tab.map (SymE.eval (ρ3 q.1 q.2.1 q.2.2))⟩
  Post q t _ t' C' := KvPost 1378 [(1378, 1379)] [(6, 0), (7, 0), (8, 5), (9, 6), (10, 7), (11, 8)] 8 9 (.num (.ref 13)) (q.1 + q.2.2) KvWFirst.G t t' C'

theorem KvWFirst.holds : KvWFirst.stage.Holds := by
  rintro ⟨o, c, r⟩ t Cs ⟨hd, rfl, rfl⟩
  dsimp only [KvWFirst.Dom] at hd
  obtain ⟨h1, h2, h3, h4, h5⟩ := hd
  have hg : Good (ρ3 o c r) KvWFirst.O :=
    Lin.goodLin_sound KvWFirst.lin (x := Lin.vx [(r : Int) / 256, (r : Int) % 256]) (by simp only [KvWFirst.ps]; lin_mem) (by simp only [KvWFirst.V]; lin_mem [ρ3])
  have hi : Inst (ρ3 o c r) KvWFirst.S1 ⟨KvWFirst.S1.tab.map (SymE.eval (ρ3 o c r))⟩ := ⟨rfl, by rw [KvWFirst.srv1]; exact hg⟩
  obtain ⟨_, hrun⟩ := tplN_sim KvWFirst.append hi
  refine ⟨3453, tplN KvWFirst.s3 0 [], ⟨KvWFirst.S3.tab.map (SymE.eval (ρ3 o c r))⟩, ⟨?_, KvWFirst.off, ?_, ⟨_, KvWFirst.keysArr, KvWFirst.keysH⟩,
    ⟨_, KvWFirst.valuesArr, KvWFirst.valuesH⟩, ⟨1801, KvWFirst.ret, Nat.le_of_ble_eq_true KvWFirst.freshRet⟩, ⟨KvWFirst.g8, KvWFirst.g9, KvWFirst.g10, KvWFirst.g11⟩⟩, hrun⟩
  · exact framedW_of KvWFirst.heap KvWFirst.nextLe KvWFirst.small (by decide) KvWFirst.jobs KvWFirst.stores KvWFirst.trace
      ⟨liveDelta_setAll KvWFirst.arrs (by decide) (by decide), nodesKept_of KvWFirst.nodes KvWFirst.nsmall⟩
  · show natAt _ (.num (.ref 13)) = some (o + r)
    have hv := natAt_ref (C := ⟨KvWFirst.S3.tab.map (SymE.eval (ρ3 o c r))⟩) (by rw [nth_inst KvWFirst.offE]; exact congrArg some (eval_0r o c r (by omega))) (n := (0 + r : Nat)) (by omega)
    rw [hv] <;> (congr 1; omega)

kernel_rfl KvWFirst.arrs6 : KvWFirst.s6.aux.ffi.arrs = KvWFirst.s4.aux.ffi.arrs
kernel_rfl KvWFirst.nodes6 : KvWFirst.s6.aux.ffi.nodes = KvWFirst.s4.aux.ffi.nodes
kernel_rfl KvWFirst.heap6 : KvWFirst.s6.heap = setAll KvWFirst.s4.heap (rangesOf KvWFirst.s6.heap [] ++ freshOf KvWFirst.s6.heap KvWFirst.s4.next KvWFirst.s6.next)
kernel_rfl KvWFirst.nextLe6 : Nat.ble KvWFirst.s4.next KvWFirst.s6.next = true
kernel_rfl KvWFirst.small6 : Nat.blt KvWFirst.s6.next 1048576 = true
kernel_rfl KvWFirst.jobs6 : KvWFirst.s6.aux.jobs = KvWFirst.s4.aux.jobs
kernel_rfl KvWFirst.stores6 : KvWFirst.s6.aux.stores = KvWFirst.s4.aux.stores
kernel_rfl KvWFirst.trace6 : KvWFirst.s6.aux.trace = KvWFirst.s6.aux.trace.take 3 ++ KvWFirst.s4.aux.trace
kernel_rfl KvWFirst.syms6 : (KvWFirst.s6.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl KvWFirst.vec6 : KvWFirst.s6.aux.ffi.objs.get KvWFirst.s4.aux.ffi.next = some (.vec [5, 6])

/-- **`evalCacheState` after the append of class `KvWFirst`** (parameter: the valuation). -/
def KvWFirst.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN KvWFirst.s4 0 [] ∧ Inst ρ KvWFirst.S4 C
  Post ρ t _ t' C' := EvalPost [5, 6] t t' ∧ Inst ρ KvWFirst.S6 C'

theorem KvWFirst.evalHolds : KvWFirst.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim KvWFirst.eval hi
  exact ⟨946, tplN KvWFirst.s6 0 [], _, ⟨⟨framedW_of KvWFirst.heap6 KvWFirst.nextLe6 KvWFirst.small6 (by decide) KvWFirst.jobs6 KvWFirst.stores6 KvWFirst.trace6
    ⟨KvWFirst.arrs6, KvWFirst.nodes6⟩, KvWFirst.syms6, KvWFirst.vec6⟩, hi'⟩, hrun⟩

/-! ## Class `KvWFirst256`: the first whole chunk (`r % 256 = 0`) into a null buffer -/

/-- The inputs of class `KvWFirst256`. -/
def KvWFirst256.Dom (o c r : Nat) : Prop := o = 0 ∧ c = 0 ∧ 256 ≤ r ∧ r ≤ 1048576 ∧ r % 256 = 0

/-- The graph of class `KvWFirst256`'s new handles. -/
def KvWFirst256.G (y : Host.Mlx.Ffi.St) : Prop :=
  y.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 14)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [3, 1], [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)], 12⟩ ∧
    y.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [4, 2], [(.lit 1), (.lit 4), (.sym (.ref 12)), (.lit 256)], 12⟩ ∧
    y.node? 10 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 14)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [3, 1], [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)], 12⟩ ∧
    y.node? 11 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [4, 2], [(.lit 1), (.lit 4), (.sym (.ref 12)), (.lit 256)], 12⟩

kernel_rfl KvWFirst256.srv1 : KvWFirst256.S1.oracle = KvWFirst256.O
kernel_rfl KvWFirst256.arrs : KvWFirst256.s3.aux.ffi.arrs = setAll KvWFirst256.s1.aux.ffi.arrs [(6, 0), (7, 0), (8, 5), (9, 6), (10, 5), (11, 6)]
kernel_rfl KvWFirst256.nodes : KvWFirst256.s3.aux.ffi.nodes = setAll KvWFirst256.s1.aux.ffi.nodes (freshOf KvWFirst256.s3.aux.ffi.nodes KvWFirst256.s1.aux.ffi.nnext KvWFirst256.s3.aux.ffi.nnext)
kernel_rfl KvWFirst256.nsmall : Nat.blt KvWFirst256.s3.aux.ffi.nnext 1048576 = true
kernel_rfl KvWFirst256.heap : KvWFirst256.s3.heap = setAll KvWFirst256.s1.heap (rangesOf KvWFirst256.s3.heap [(1378, 1379)] ++ freshOf KvWFirst256.s3.heap KvWFirst256.s1.next KvWFirst256.s3.next)
kernel_rfl KvWFirst256.nextLe : Nat.ble KvWFirst256.s1.next KvWFirst256.s3.next = true
kernel_rfl KvWFirst256.small : Nat.blt KvWFirst256.s3.next 1048576 = true
kernel_rfl KvWFirst256.jobs : KvWFirst256.s3.aux.jobs = KvWFirst256.s1.aux.jobs
kernel_rfl KvWFirst256.stores : KvWFirst256.s3.aux.stores = KvWFirst256.s1.aux.stores
kernel_rfl KvWFirst256.trace : KvWFirst256.s3.aux.trace = KvWFirst256.s3.aux.trace.take (KvWFirst256.s3.aux.trace.length - KvWFirst256.s1.aux.trace.length) ++ KvWFirst256.s1.aux.trace
kernel_rfl KvWFirst256.off : propOf (KvWFirst256.s3.obj? 1378) chars!"offset" = some (.num (.ref 13))
kernel_rfl KvWFirst256.offE : nth? KvWFirst256.S3.tab 13 = some (Host.Ts.SymE.bin (Host.Ts.NBin.add) (Host.Ts.SymE.lit (Host.Ts.F64.zero false)) (Host.Ts.SymE.un (Host.Ts.NUn.int32) (Host.Ts.SymE.var 2)))
kernel_rfl KvWFirst256.keysArr : propOf (KvWFirst256.s3.obj? 1378) chars!"keys" = some (.obj 1637)
kernel_rfl KvWFirst256.keysH : handleOf (KvWFirst256.s3.obj? 1637) = some 8
kernel_rfl KvWFirst256.valuesArr : propOf (KvWFirst256.s3.obj? 1378) chars!"values" = some (.obj 1689)
kernel_rfl KvWFirst256.valuesH : handleOf (KvWFirst256.s3.obj? 1689) = some 9
kernel_rfl KvWFirst256.ret : KvWFirst256.s3.ctl = .ret (.obj 1801)
kernel_rfl KvWFirst256.freshRet : Nat.ble KvWFirst256.s1.next 1801 = true
kernel_rfl KvWFirst256.g8 : KvWFirst256.s3.aux.ffi.node? 8 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 14)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [3, 1], [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)], 12⟩
kernel_rfl KvWFirst256.g9 : KvWFirst256.s3.aux.ffi.node? 9 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [4, 2], [(.lit 1), (.lit 4), (.sym (.ref 12)), (.lit 256)], 12⟩
kernel_rfl KvWFirst256.g10 : KvWFirst256.s3.aux.ffi.node? 10 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 14)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [3, 1], [(.lit 1), (.lit 4), (.sym (.ref 10)), (.lit 256)], 12⟩
kernel_rfl KvWFirst256.g11 : KvWFirst256.s3.aux.ffi.node? 11 = some ⟨(.sliceUpdate [(.lit 0), (.lit 0), (.lit 0), (.lit 0)] [(.lit 1), (.lit 4), (.sym (.ref 16)), (.lit 256)] [(.lit 1), (.lit 1), (.lit 1), (.lit 1)]), [4, 2], [(.lit 1), (.lit 4), (.sym (.ref 12)), (.lit 256)], 12⟩

def KvWFirst256.ps : List Lin.Prm := [{ lo := 1, hi := 4096 }]
def KvWFirst256.V : List (Nat × Lin.Aff) := [(0, 0), (1, 0), (2, (256 : Nat) • Lin.P 0)]
theorem KvWFirst256.lin : Lin.goodLin KvWFirst256.ps KvWFirst256.V KvWFirst256.O = true := by decide +kernel

/-- **The KV append of class `KvWFirst256`.** -/
def KvWFirst256.stage : Stage MF where
  Par := Nat × Nat × Nat
  Pre q t C := KvWFirst256.Dom q.1 q.2.1 q.2.2 ∧ t = tplN KvWFirst256.s1 0 [] ∧ C = ⟨KvWFirst256.S1.tab.map (SymE.eval (ρ3 q.1 q.2.1 q.2.2))⟩
  Post q t _ t' C' := KvPost 1378 [(1378, 1379)] [(6, 0), (7, 0), (8, 5), (9, 6), (10, 5), (11, 6)] 8 9 (.num (.ref 13)) (q.1 + q.2.2) KvWFirst256.G t t' C'

theorem KvWFirst256.holds : KvWFirst256.stage.Holds := by
  rintro ⟨o, c, r⟩ t Cs ⟨hd, rfl, rfl⟩
  dsimp only [KvWFirst256.Dom] at hd
  obtain ⟨h1, h2, h3, h4, h5⟩ := hd
  have hg : Good (ρ3 o c r) KvWFirst256.O :=
    Lin.goodLin_sound KvWFirst256.lin (x := Lin.vx [(r : Int) / 256]) (by simp only [KvWFirst256.ps]; lin_mem) (by simp only [KvWFirst256.V]; lin_mem [ρ3])
  have hi : Inst (ρ3 o c r) KvWFirst256.S1 ⟨KvWFirst256.S1.tab.map (SymE.eval (ρ3 o c r))⟩ := ⟨rfl, by rw [KvWFirst256.srv1]; exact hg⟩
  obtain ⟨_, hrun⟩ := tplN_sim KvWFirst256.append hi
  refine ⟨3453, tplN KvWFirst256.s3 0 [], ⟨KvWFirst256.S3.tab.map (SymE.eval (ρ3 o c r))⟩, ⟨?_, KvWFirst256.off, ?_, ⟨_, KvWFirst256.keysArr, KvWFirst256.keysH⟩,
    ⟨_, KvWFirst256.valuesArr, KvWFirst256.valuesH⟩, ⟨1801, KvWFirst256.ret, Nat.le_of_ble_eq_true KvWFirst256.freshRet⟩, ⟨KvWFirst256.g8, KvWFirst256.g9, KvWFirst256.g10, KvWFirst256.g11⟩⟩, hrun⟩
  · exact framedW_of KvWFirst256.heap KvWFirst256.nextLe KvWFirst256.small (by decide) KvWFirst256.jobs KvWFirst256.stores KvWFirst256.trace
      ⟨liveDelta_setAll KvWFirst256.arrs (by decide) (by decide), nodesKept_of KvWFirst256.nodes KvWFirst256.nsmall⟩
  · show natAt _ (.num (.ref 13)) = some (o + r)
    have hv := natAt_ref (C := ⟨KvWFirst256.S3.tab.map (SymE.eval (ρ3 o c r))⟩) (by rw [nth_inst KvWFirst256.offE]; exact congrArg some (eval_0r o c r (by omega))) (n := (0 + r : Nat)) (by omega)
    rw [hv] <;> (congr 1; omega)

kernel_rfl KvWFirst256.arrs6 : KvWFirst256.s6.aux.ffi.arrs = KvWFirst256.s4.aux.ffi.arrs
kernel_rfl KvWFirst256.nodes6 : KvWFirst256.s6.aux.ffi.nodes = KvWFirst256.s4.aux.ffi.nodes
kernel_rfl KvWFirst256.heap6 : KvWFirst256.s6.heap = setAll KvWFirst256.s4.heap (rangesOf KvWFirst256.s6.heap [] ++ freshOf KvWFirst256.s6.heap KvWFirst256.s4.next KvWFirst256.s6.next)
kernel_rfl KvWFirst256.nextLe6 : Nat.ble KvWFirst256.s4.next KvWFirst256.s6.next = true
kernel_rfl KvWFirst256.small6 : Nat.blt KvWFirst256.s6.next 1048576 = true
kernel_rfl KvWFirst256.jobs6 : KvWFirst256.s6.aux.jobs = KvWFirst256.s4.aux.jobs
kernel_rfl KvWFirst256.stores6 : KvWFirst256.s6.aux.stores = KvWFirst256.s4.aux.stores
kernel_rfl KvWFirst256.trace6 : KvWFirst256.s6.aux.trace = KvWFirst256.s6.aux.trace.take 3 ++ KvWFirst256.s4.aux.trace
kernel_rfl KvWFirst256.syms6 : (KvWFirst256.s6.aux.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"]
kernel_rfl KvWFirst256.vec6 : KvWFirst256.s6.aux.ffi.objs.get KvWFirst256.s4.aux.ffi.next = some (.vec [5, 6])

/-- **`evalCacheState` after the append of class `KvWFirst256`** (parameter: the valuation). -/
def KvWFirst256.evalStage : Stage MF where
  Par := Nat → F64
  Pre ρ t C := t = tplN KvWFirst256.s4 0 [] ∧ Inst ρ KvWFirst256.S4 C
  Post ρ t _ t' C' := EvalPost [5, 6] t t' ∧ Inst ρ KvWFirst256.S6 C'

theorem KvWFirst256.evalHolds : KvWFirst256.evalStage.Holds := by
  rintro ρ t Cs ⟨rfl, hi⟩
  obtain ⟨hi', hrun⟩ := tplN_sim KvWFirst256.eval hi
  exact ⟨946, tplN KvWFirst256.s6 0 [], _, ⟨⟨framedW_of KvWFirst256.heap6 KvWFirst256.nextLe6 KvWFirst256.small6 (by decide) KvWFirst256.jobs6 KvWFirst256.stores6 KvWFirst256.trace6
    ⟨KvWFirst256.arrs6, KvWFirst256.nodes6⟩, KvWFirst256.syms6, KvWFirst256.vec6⟩, hi'⟩, hrun⟩

/-! ## The route's appends fall in the classes -/

/-- **Every window append of the route is in a class**: at offset `o ≥ 1` with capacity `capL o` and the
no-trim fact (`route_noTrim`), `r` rows fit, fill, or grow (tail or whole chunk). -/
theorem kv_route_window {o r : Nat} (ho : 1 ≤ o) (hr : 1 ≤ r) (hr2 : r ≤ 1048576) (hc : capL o ≤ 536870912)
    (h : o % 256 = 0 ∨ o + r ≤ capL o) :
    KvWFit.Dom o (capL o) r ∨ KvWFill.Dom o (capL o) r ∨ KvWGrow.Dom o (capL o) r ∨ KvWGrow256.Dom o (capL o) r := by
  unfold KvWFit.Dom KvWFill.Dom KvWGrow.Dom KvWGrow256.Dom capL at *
  by_cases h0 : o % 256 = 0
  · by_cases h1 : r % 256 = 0
    · right; right; right; omega
    · right; right; left; omega
  · rcases h with h | h
    · exact absurd h h0
    · by_cases h2 : o + r = 256 * ((o + 255) / 256)
      · right; left; omega
      · left; omega

/-- **Every decode-row append of the route is in a class** (`route_noTrim_one`). -/
theorem kv_route_decode {o : Nat} (ho : 1 ≤ o) (hc : capL o ≤ 536870912) :
    KvDFit.Dom o (capL o) 1 ∨ KvDFill.Dom o (capL o) 1 ∨ KvDGrow.Dom o (capL o) 1 := by
  unfold KvDFit.Dom KvDFill.Dom KvDGrow.Dom capL at *
  by_cases h0 : o % 256 = 0
  · right; right; omega
  · by_cases h2 : o + 1 = 256 * ((o + 255) / 256)
    · right; left; omega
    · left; omega

/-- **The first append** (a null buffer): a whole first chunk or a shorter first window. -/
theorem kv_route_first {r : Nat} (hr : 1 ≤ r) (hr2 : r ≤ 1048576) :
    KvWFirst.Dom 0 0 r ∨ KvWFirst256.Dom 0 0 r := by
  unfold KvWFirst.Dom KvWFirst256.Dom
  by_cases h1 : r % 256 = 0
  · right; omega
  · left; omega

end Host.Ts.Sim.Stage.Cache
