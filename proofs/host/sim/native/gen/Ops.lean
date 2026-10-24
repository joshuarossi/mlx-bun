import host.sim.native.Ops
import host.sim.native.gen.Leaf
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! `host.sim.native.Ops` for the general native relation `G.MR` (`host.sim.native.gen.Rel`):
the same statements and proofs, with the pre-load band bound `NB` threaded through. -/

section

variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)

include hr

theorem MR.shapesOf_map : ∀ {ins : List Nat} {sh : List (List Dim × Nat)},
    Host.Mlx.Ffi.shapesOf x ins = some sh → Host.Mlx.Ffi.shapesOf y (ins.map M.node) = some (sh.map M.shp)
  | [], sh, h => by simp only [Host.Mlx.Ffi.shapesOf, Option.some.injEq] at h; subst h; rfl
  | i :: ins, sh, h => by
    simp only [Host.Mlx.Ffi.shapesOf] at h
    cases hn : x.nodes.get i with
    | none => rw [hn] at h; cases h
    | some nd =>
      rw [hn] at h
      cases hs : Host.Mlx.Ffi.shapesOf x ins with
      | none => rw [hs] at h; cases h
      | some sh' =>
        rw [hs] at h
        simp only [Option.bind_some, Option.map_some, Option.some.injEq] at h
        subst h
        obtain ⟨nd', h1, h2, h3, -⟩ := hr.nodes i nd hn
        simp only [List.map_cons, Host.Mlx.Ffi.shapesOf, h1, Option.bind_some, shapesOf_map hs, Option.map_some,
          h2, h3]
        rfl

end

section

variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)

include hs hr

/-- A node with inputs at a slot. -/
theorem sim_node {b off sl : Nat} (hsl : sl = 0 ∨ PH x sl) (hE : sl = 0 → x.next + 1 ≤ P.E)
    (hNE : x.nnext + 1 ≤ P.NE) (p : Prim) (ins : List Nat) (ds : List Dim) (d : Nat)
    (hp : SP (· < S.tab.length) p) (hl : ds.all dimLit = true) :
    MSim (MPost P NB M ν S C) S C
      (match x.addNode ⟨p, ins, ds, d⟩ with
        | (k, s) => match s.setArr sl k with
          | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h])
      (match y.addNode ⟨M.prim p, ins.map M.node, ds, d⟩ with
        | (k, s) => match s.setArr (M.handle sl) k with
          | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write (M.a b) off h]) := by
  have h1 := hr.addNode ⟨p, ins, ds, d⟩ hNE ⟨hp, SDs.of_lit hl⟩
    (fun e he => dimCanon_lit M (List.all_eq_true.mp hl e he))
  have hsl' : sl = 0 ∨ PH { x with nnext := x.nnext + 1, nodes := x.nodes.set x.nnext ⟨p, ins, ds, d⟩ } sl := hsl
  obtain ⟨h, x', h', y', e1, e2, hr', hb⟩ := h1.setArr_map hsl' hE x.nnext
  have hnn : (⟨M.prim p, ins.map M.node, ds, d⟩ : Node) = M.nnode ⟨p, ins, ds, d⟩ := by
    simp only [Map.nnode, dims_lit M hl]
  simp only [Host.Mlx.Ffi.St.addNode]
  rw [hr.node_next] at e2
  rw [hnn, e1, e2]
  exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr'

theorem sim_opOut {o : Arg} {p : Prim} {ins : List Nat} (hop : opCheck P x o p ins = true)
    (hcl : SP (· < S.tab.length) p) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.opOut x o p ins)
      (Host.Mlx.Ffi.opOut y (M.arg o) (M.prim p) (ins.map M.node)) := by
  simp only [opCheck, Bool.and_eq_true, decide_eq_true_eq] at hop
  obtain ⟨⟨⟨⟨ho, hE⟩, hNE⟩, hpl⟩, hsh⟩ := hop
  obtain ⟨b, off, sl, h1, h2, hsl⟩ := hr.slot_map ho
  cases hsx : Host.Mlx.Ffi.shapesOf x ins with
  | none => rw [hsx] at hsh; cases hsh
  | some sh =>
    rw [hsx] at hsh
    have hl : ShLits sh := fun q hq => List.all_eq_true.mp hsh q hq
    have hsy : Host.Mlx.Ffi.shapesOf y (ins.map M.node) = some sh := by
      rw [hr.shapesOf_map hsx, shp_lits M hl]
    obtain ⟨r, hrl, e⟩ := infer_pure p hpl sh hl
    have e' : ∀ γ (k : Option Host.Mlx.Ffi.Out → Free γ), Host.Mlx.Ffi.infer (M.prim p) sh γ k = k r := by
      rw [infer_mprim M p hpl sh]; exact e
    unfold Host.Mlx.Ffi.opOut
    simp only [h1, h2, hsx, hsy]
    rw [bind_pureP e, bind_pureP e']
    cases r with
    | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | some out =>
      cases out with
      | node shape dt =>
        exact sim_node hs hr hsl (fun _ => hE) hNE p ins shape dt hcl hrl
      | same i =>
        simp only [nth?_map]
        cases hi : nth? ins i with
        | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
        | some k =>
          obtain ⟨h, x', h', y', e1, e2, hr', hb⟩ := hr.setArr_map hsl (fun _ => hE) k
          simp only [Option.map_some, e1, e2]
          exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr'

end

end Host.Ts.Sim.G
