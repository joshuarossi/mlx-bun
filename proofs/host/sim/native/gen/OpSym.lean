import host.sim.native.OpSym
import host.sim.native.gen.Ops
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! `host.sim.native.OpSym` for the general native relation `G.MR` (`host.sim.native.gen.Rel`):
the same statements and proofs, with the pre-load band bound `NB` threaded through. -/

section

variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt}

/-- The relation survives the servers' growth. -/
theorem MR.grow {M1 : Map} {S1 : SSrv} {C1 : CSrv} (hr : MR P NB M S.tab.length x y)
    (g : Grow M ν S C M1 S1 C1) : MR P NB M1 S1.tab.length x y :=
  have h := hr.agree hr.cl (NAgree.ofExt g.ext)
  { h with cl := SSt.mono (fun i hi => Nat.lt_of_lt_of_le hi g.len) h.cl }

/-- A node with a symbolic shape at a slot. -/
theorem sim_nodeS (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y) {b off sl : Nat} (hsl : sl = 0 ∨ PH x sl)
    (hE : sl = 0 → x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE) (p : Prim) (ins : List Nat) (ds : List Dim)
    (d : Nat) (hp : SP (· < S.tab.length) p) (hsd : SDs (· < S.tab.length) ds) (hc : ∀ e ∈ ds, DimCanon M e) :
    MSim (MPost P NB M ν S C) S C
      (match x.addNode ⟨p, ins, ds, d⟩ with
        | (k, s) => match s.setArr sl k with
          | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h])
      (match y.addNode ⟨M.prim p, ins.map M.node, M.dims ds, d⟩ with
        | (k, s) => match s.setArr (M.handle sl) k with
          | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write (M.a b) off h]) := by
  have h1 := hr.addNode ⟨p, ins, ds, d⟩ hNE ⟨hp, hsd⟩ hc
  have hsl' : sl = 0 ∨ PH { x with nnext := x.nnext + 1, nodes := x.nodes.set x.nnext ⟨p, ins, ds, d⟩ } sl := hsl
  obtain ⟨h, x', h', y', e1, e2, hr', hb⟩ := h1.setArr_map hsl' hE x.nnext
  have hnn : (⟨M.prim p, ins.map M.node, M.dims ds, d⟩ : Node) = M.nnode ⟨p, ins, ds, d⟩ := rfl
  simp only [Host.Mlx.Ffi.St.addNode]
  rw [hr.node_next] at e2
  rw [hnn, e1, e2]
  exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr'

/-- **Operations with simulated shape inference.** -/
theorem sim_opOutS (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y) {o : Arg} {p : Prim} {ins : List Nat}
    {sh : List (List Dim × Nat)} (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (hp : SP (· < S.tab.length) p) (hsx : Host.Mlx.Ffi.shapesOf x ins = some sh)
    (hinf : MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer p sh) (Host.Mlx.Ffi.infer (M.prim p) (sh.map M.shp))) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.opOut x o p ins)
      (Host.Mlx.Ffi.opOut y (M.arg o) (M.prim p) (ins.map M.node)) := by
  obtain ⟨b, off, sl, h1, h2, hsl⟩ := hr.slot_map ho
  have hsy := hr.shapesOf_map hsx
  unfold Host.Mlx.Ffi.opOut
  simp only [h1, h2, hsx, hsy]
  refine MSim.bind hinf fun M1 S1 C1 r r' h => ?_
  obtain ⟨g1, hout⟩ := h
  have hs1 := g1.grow.srv
  have hr1 : MR P NB M1 S1.tab.length x y := hr.grow g1.grow
  have ea : M1.a = M.a := g1.grow.ext.a
  have en : M1.node = M.node := g1.grow.ext.node
  have eh : M1.handle sl = M.handle sl := by simp only [Map.handle, g1.grow.ext.big]
  have ep : M1.prim p = M.prim p := (NAgree.ofExt g1.grow.ext).prim hp
  have hp1 : SP (· < S1.tab.length) p := SP.mono (fun i hi => Nat.lt_of_lt_of_le hi g1.grow.len) hp
  refine MSim.mono (P := MPost P NB M1 ν S1 C1) ?_ fun M' S' C' r r' h => ⟨g1.grow.trans h.1, h.2⟩
  cases r with
  | none =>
    refine msim_stuck hs1 _ ?_
    rcases r' with _ | ⟨_ | _⟩
    · exact ⟨_, fun _ _ => rfl⟩
    · exact ⟨_, fun _ _ => rfl⟩
    · rename_i i
      dsimp only
      cases nth? (List.map M.node ins) i
      · exact ⟨_, fun _ _ => rfl⟩
      · exact ⟨_, fun _ _ => rfl⟩
  | some out =>
    cases out with
    | node shape dt =>
      cases r' with
      | none => exact hout.elim
      | some o' =>
        obtain ⟨rfl, hsd, hc⟩ := hout
        rw [← ep, ← en, ← eh, ← ea]
        exact sim_nodeS hs1 hr1 hsl (fun _ => hE) hNE p ins shape dt hp1 hsd hc
    | same i =>
      cases r' with
      | none => exact hout.elim
      | some o' =>
        cases hout
        show MSim _ S1 C1
          (match nth? ins i with
            | some n => match x.setArr sl n with
              | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h]
            | none => Host.Mlx.Ffi.stuck)
          (match nth? (ins.map M.node) i with
            | some n => match y.setArr (M.handle sl) n with
              | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write (M.a b) off h]
            | none => Host.Mlx.Ffi.stuck)
        rw [← en, ← eh, ← ea]
        simp only [nth?_map]
        cases hi : nth? ins i with
        | none => exact msim_stuck hs1 _ ⟨_, fun _ _ => rfl⟩
        | some k =>
          obtain ⟨h, x', h', y', e1, e2, hr', hb⟩ := hr1.setArr_map hsl (fun _ => hE) k
          simp only [Option.map_some, e1, e2]
          exact msim_okW' hs1 hr1 rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M1 hb]) hr'

end

end Host.Ts.Sim.G
