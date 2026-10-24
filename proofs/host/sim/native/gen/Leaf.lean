import host.sim.native.Leaf
import host.sim.native.gen.Objects
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! `host.sim.native.Leaf` for the general native relation `G.MR` (`host.sim.native.gen.Rel`):
the same statements and proofs, with the pre-load band bound `NB` threaded through. -/

section

variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)

include hs hr

/-- A leaf node at a slot: add the node, set the slot. -/
theorem sim_leaf {b off sl : Nat} (hsl : sl = 0 ∨ PH x sl) (hE : sl = 0 → x.next + 1 ≤ P.E)
    (hNE : x.nnext + 1 ≤ P.NE) (p : Prim) (ds : List Dim) (d : Nat) (hp : SP (· < S.tab.length) p)
    (hl : ds.all dimLit = true) :
    MSim (MPost P NB M ν S C) S C
      (match x.addNode ⟨p, [], ds, d⟩ with
        | (k, s) => match s.setArr sl k with
          | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h])
      (match y.addNode ⟨M.prim p, [], ds, d⟩ with
        | (k, s) => match s.setArr (M.handle sl) k with
          | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write (M.a b) off h]) := by
  have h1 := hr.addNode ⟨p, [], ds, d⟩ hNE ⟨hp, SDs.of_lit hl⟩
    (fun e he => dimCanon_lit M (List.all_eq_true.mp hl e he))
  have hsl' : sl = 0 ∨ PH { x with nnext := x.nnext + 1, nodes := x.nodes.set x.nnext ⟨p, [], ds, d⟩ } sl := hsl
  obtain ⟨h, x', h', y', e1, e2, hr', hb⟩ := h1.setArr_map hsl' hE x.nnext
  have hnn : (⟨M.prim p, [], ds, d⟩ : Node) = M.nnode ⟨p, [], ds, d⟩ := by
    simp only [Map.nnode, dims_lit M hl, List.map_nil]
  simp only [Host.Mlx.Ffi.St.addNode]
  rw [hr.node_next] at e2
  rw [hnn, e1, e2]
  exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr'

theorem sim_arrayNewData (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.arrayNewData)
    {b0 o0 : Nat} {bytes : List Byte} {sh nd dt : Arg} (hd : dimsOk P sh nd = true) (hl : dimsLitOk sh nd = true)
    (hdt : natOk P dt = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (hb : SBs (· < S.tab.length) bytes) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [.jsPtr b0 o0 bytes, sh, nd, dt])
      (Host.Mlx.Ffi.call y name [.jsPtr (M.a b0) o0 (bytes.map M.byte), M.arg sh, M.arg nd, M.arg dt]) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [hr.natOk_argNat hdt]
  cases hds : Host.Mlx.Ffi.dimsArg sh nd with
  | none =>
    simp only
    exact msim_stuck' hs (by
      cases Host.Mlx.Ffi.dimsArg (M.arg sh) (M.arg nd) <;> cases Host.Mlx.Ffi.argNat dt <;>
        exact ⟨_, fun _ _ => rfl⟩)
  | some ds =>
    have hlit : ds.all dimLit = true := by simp only [dimsLitOk, hds] at hl; exact hl
    rw [hr.dimsArg_map hd hds, dims_lit M hlit]
    cases hn : Host.Mlx.Ffi.argNat dt with
    | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | some d =>
      simp only
      have key : ∀ bs : List Byte, SBs (· < S.tab.length) bs →
          MSim (MPost P NB M ν S C) S C
            (match x.addNode ⟨.data bs, [], ds, d⟩ with
              | (k, s) => match s.setArr 0 k with | (h, s) => Host.Mlx.Ffi.ok s (.big h))
            (match y.addNode ⟨.data (bs.map M.byte), [], ds, d⟩ with
              | (k, s) => match s.setArr 0 k with | (h, s) => Host.Mlx.Ffi.ok s (.big h)) := by
        intro bs hbs
        have h1 := hr.addNode ⟨.data bs, [], ds, d⟩ hNE ⟨hbs, SDs.of_lit hlit⟩
          (fun e he => dimCanon_lit M (List.all_eq_true.mp hlit e he))
        obtain ⟨h, x', h', y', e1, e2, hr', hb'⟩ := h1.setArr_map (.inl rfl) (fun _ => hE) x.nnext
        have hnn : (⟨.data (bs.map M.byte), [], ds, d⟩ : Node) = M.nnode ⟨.data bs, [], ds, d⟩ := by
          simp only [Map.nnode, Map.prim, dims_lit M hlit, List.map_nil]
        simp only [Host.Mlx.Ffi.St.addNode]
        rw [h1.handle0, hr.node_next] at e2
        rw [hnn, e1, e2]
        refine msim_ok' hs hr ?_ hr'
        show Ret.big _ = Ret.big (M.big _)
        rw [show ((h : Nat) : Int) = Int.ofNat h from rfl, hb']; rfl
      cases hns : Host.Mlx.Ffi.natsOfDims ds with
      | none => exact key bytes hb
      | some ns =>
        simp only
        rw [← List.map_take]
        exact key _ (fun b hm => hb b (List.mem_of_mem_take hm))

theorem sim_zeros (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.zeros)
    {o sh m dt e : Arg} (ho : slotOk P x o = true) (hd : dimsOk P sh m = true) (hl : dimsLitOk sh m = true)
    (hdt : natOk P dt = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, sh, m, dt, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg sh, M.arg m, M.arg dt, M.arg e]) := by
  obtain ⟨b, off, sl, h1, h2, hsl⟩ := hr.slot_map ho
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [hr.natOk_argNat hdt]
  cases hds : Host.Mlx.Ffi.dimsArg sh m with
  | none =>
    simp only
    exact msim_stuck' hs (by
      cases Host.Mlx.Ffi.dimsArg (M.arg sh) (M.arg m) <;> cases Host.Mlx.Ffi.argNat dt <;>
        first
        | exact ⟨_, fun _ _ => rfl⟩
        | (unfold Host.Mlx.Ffi.leafOut; rw [h2]; exact ⟨_, fun _ _ => rfl⟩))
  | some ds =>
    have hlit : ds.all dimLit = true := by simp only [dimsLitOk, hds] at hl; exact hl
    rw [hr.dimsArg_map hd hds, dims_lit M hlit]
    cases hn : Host.Mlx.Ffi.argNat dt with
    | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | some d =>
      simp only
      unfold Host.Mlx.Ffi.leafOut
      rw [h1, h2]
      exact sim_leaf hs hr hsl (fun _ => hE) hNE .zeros ds d trivial hlit

/-- `mlx_array_item_uint32`: the memo, else the next token. -/
theorem sim_itemU32 (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.itemU32)
    {b off : Nat} {bs : List Byte} {a : Arg} (ha : nodeOk x a = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [.jsPtr b off bs, a])
      (Host.Mlx.Ffi.call y name [.jsPtr (M.a b) off (bs.map M.byte), M.arg a]) := by
  obtain ⟨k, i, nd, nd', rfl, hm, hp, h1, h2, h3⟩ := hr.nodeArg ha
  unfold Host.Mlx.Ffi.St.node? at h1 h2
  cases hak : x.arrs.get k with
  | none => rw [hak] at h1; cases h1
  | some j =>
    rw [hak] at h1
    simp only [Option.bind_some] at h1
    have hpn : PN x j := by show (x.nodes.get j).isSome = true; rw [h1]; rfl
    have hid : x.nodeId? k = some j := by
      unfold Host.Mlx.Ffi.St.nodeId?
      rw [show Nat.beq k 0 = false by
        cases e : Nat.beq k 0
        · rfl
        · exact absurd (Nat.eq_of_beq_eq_true e) (hr.PH_ne_zero hp)]
      exact hak
    have hid' : y.nodeId? (M.handle k) = some (M.node j) := by rw [hr.nodeId? hp, hid]; rfl
    obtain ⟨nd'', hnd'', hnr⟩ := hr.nodes j nd h1
    have hyn : y.node? (M.handle k) = some nd'' := by
      unfold Host.Mlx.Ffi.St.node?; rw [hr.arrs k hp, hak]; exact hnd''
    have hxn : x.node? k = some nd := by unfold Host.Mlx.Ffi.St.node?; rw [hak]; exact h1
    rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
    simp only [argNat_nat, Option.bind_some, hid, hid', hyn, hxn, hnr.2.1]
    cases hdt : Nat.beq nd.dtype Host.Mlx.Ffi.dtUint32
    · simp only [Bool.cond_false]; exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    · simp only [Bool.cond_true]
      have hit := hr.items j hpn
      cases hx : x.items.get j with
      | some t =>
        rw [hx] at hit
        simp only [hit, Option.map_some]
        exact msim_okW' hs hr rfl (by simp [Map.write, Map.cellParts, Map.cell]) hr
      | none =>
        rw [hx] at hit
        simp only [hit, Option.map_none]
        cases htok : x.tokens with
        | nil =>
          exact msim_stuck' hs (by cases y.tokens <;> exact ⟨_, fun _ _ => rfl⟩)
        | cons t ts =>
          obtain ⟨ts', hy, hr'⟩ := hr.readToken hpn htok
          rw [hy]
          exact msim_okW' hs hr rfl (by simp [Map.write, Map.cellParts, Map.cell]) hr'

end

end Host.Ts.Sim.G
