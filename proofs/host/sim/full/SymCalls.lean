import host.sim.full.SymInfer2
import host.sim.native.gen.CallSim
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf)

/-! # The forward's operations over symbolic shapes: calls

The calls of the operations `host.sim.full.SymInfer`/`SymInfer2` infer over symbolic shapes, as
`host.sim.native.gen.OpCalls` makes the literal ones: arguments decoded on both sides as there,
the output through `sim_opOutS` (a node of symbolic shape at the slot) with the symbolic inference
simulation. Each lemma takes the decider's facts (`host.sim.full.SymAccept`). -/

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

theorem shOk_of {ins : List Nat} {sh : List (List Dim × Nat)} (h : Host.Mlx.Ffi.shapesOf x ins = some sh) :
    ShOk M S.tab.length sh := hr.shapesOf_props h

theorem sim_unaryX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.unary)
    {o a e : Arg} {ins : List Nat} {s : List Dim} {d : Nat} (ha : hdOk x a = true) (ho : slotOk P x o = true)
    (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE) (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins)
    (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, d)]) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1]
  exact sim_opOutS hs hr ho hE hNE trivial hsh (infer_unary_simS hs (shOk_of hs hr hsh))

theorem sim_astypeX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.astype)
    {o a dt e : Arg} {ins : List Nat} {s : List Dim} {d : Nat} (ha : hdOk x a = true) (hdt : natOk P dt = true)
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins) (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, d)]) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, dt, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg dt, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, hr.natOk_argNat hdt]
  cases hn : Host.Mlx.Ffi.argNat dt with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some dv =>
    exact sim_opOutS hs hr ho hE hNE trivial hsh (infer_astype_simS hs (shOk_of hs hr hsh))

theorem sim_contiguousX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.contiguous)
    {o a e1 e2 : Arg} {ins : List Nat} {s : List Dim} {d : Nat} (ha : hdOk x a = true)
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins) (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, d)]) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, e1, e2])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg e1, M.arg e2]) := by
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1]
  exact sim_opOutS hs hr ho hE hNE trivial hsh (infer_contiguous_simS hs (shOk_of hs hr hsh))

theorem sim_ropeX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.rope)
    {o a base freqs e : Arg} {dims : F64} {tr : Bool} {scale off : NumV} {ins : List Nat} {dd : Int}
    {s : List Dim} {d : Nat}
    (ha : hdOk x a = true) (hf : natOk P freqs = true) (hb : SA (· < S.tab.length) base)
    (hsc : SN (· < S.tab.length) scale) (hof : SN (· < S.tab.length) off)
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins) (hd : F64.toInt? dims = some dd) (hd0 : 0 < dd)
    (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, d)]) :
    MSim (MPost P NB M ν S C) S C
      (Host.Mlx.Ffi.call x name [o, a, .num (.lit dims), .bool tr, base, .num scale, .num off, freqs, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, .num (.lit dims), .bool tr, M.arg base, .num (M.nv scale),
        .num (M.nv off), M.arg freqs, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, hd, hr.natOk_argNat hf]
  cases hfr : Host.Mlx.Ffi.argNat freqs with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some fq =>
    cases fq with
    | succ _ => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | zero =>
      simp only [show decide (0 < dd) = true from decide_eq_true hd0, Bool.cond_true]
      exact sim_opOutS hs hr ho hE hNE ⟨hb, hsc, hof⟩ hsh (infer_rope_simS hs (shOk_of hs hr hsh))

theorem sim_logsumexpX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.logsumexp)
    {o a ax e : Arg} {keep : Bool} {ins : List Nat} {av : Int} {nd : Node} {b : Nat} {s : List Dim} {d : Nat}
    (ha : nodeOk x a = true) (hax : natOk P ax = true)
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins) (eax : Host.Mlx.Ffi.argInt ax = some av)
    (hn : (Host.Mlx.Ffi.argNat a).bind x.node? = some nd) (hb : Host.Mlx.Ffi.axisOf av (len nd.shape) = some b)
    (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, d)]) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, ax, .bool keep, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg ax, .bool keep, M.arg e]) := by
  have ha' : hdOk x a = true := by simp only [nodeOk, Bool.and_eq_true] at ha; exact ha.1
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha']) h1
  obtain ⟨k, j, nd0, nd', rfl, hm, hp, e1, e2, e3⟩ := hr.nodeArg ha
  rw [argNat_nat, Option.bind_some, e1] at hn
  cases hn
  simp only [List.map_cons, List.map_nil] at t1
  rw [hm] at t1 ⊢
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [h1, t1, hr.argInt_eq hax, eax, argNat_nat, Option.bind_some, e1, e2, e3.1, Map.dims,
    Native.len_map, hb]
  exact sim_opOutS hs hr ho hE hNE trivial hsh (infer_logsumexp_simS hs (shOk_of hs hr hsh))

theorem sim_transposeX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.transpose)
    {o a ax m e : Arg} {ins : List Nat} {ds : List Dim} {axes : List Nat} {s : List Dim} {d : Nat}
    (ha : hdOk x a = true) (hd : dimsOk P ax m = true)
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins)
    (h2 : Host.Mlx.Ffi.dimsArg ax m = some ds) (h3 : Host.Mlx.Ffi.natsOfDims ds = some axes)
    (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, d)]) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, ax, m, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg ax, M.arg m, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, h2, hr.dimsArg_map hd h2, Option.bind_some, h3, natsOfDims_map M h3]
  exact sim_opOutS hs hr ho hE hNE trivial hsh (infer_transpose_simS hs (shOk_of hs hr hsh))

theorem sim_takeX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.take)
    {o a i ax e : Arg} {ins : List Nat} {av : Int} {nd : Node} {b : Nat} {s si : List Dim} {d di : Nat}
    (ha : nodeOk x a = true) (hi : hdOk x i = true) (hax : natOk P ax = true)
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a, i] = some ins) (eax : Host.Mlx.Ffi.argInt ax = some av)
    (hn : (Host.Mlx.Ffi.argNat a).bind x.node? = some nd) (hb : Host.Mlx.Ffi.axisOf av (len nd.shape) = some b)
    (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, d), (si, di)]) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, i, ax, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg i, M.arg ax, M.arg e]) := by
  have ha' : hdOk x a = true := by simp only [nodeOk, Bool.and_eq_true] at ha; exact ha.1
  have t1 := hr.arrIns_some (as := [a, i]) (by simp [ha', hi]) h1
  obtain ⟨k, j, nd0, nd', rfl, hm, hp, e1, e2, e3⟩ := hr.nodeArg ha
  rw [argNat_nat, Option.bind_some, e1] at hn
  cases hn
  simp only [List.map_cons, List.map_nil] at t1
  rw [hm] at t1 ⊢
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [h1, t1, hr.argInt_eq hax, eax, argNat_nat, Option.bind_some, e1, e2, e3.1, Map.dims,
    Native.len_map, hb]
  exact sim_opOutS hs hr ho hE hNE trivial hsh (infer_take_simS hs (shOk_of hs hr hsh))

theorem sim_evalX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.eval) {a : Arg}
    (ha : vecOk x a = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  obtain ⟨k, ns, rfl, hm, hp, h1, h2⟩ := hr.vecArg ha
  rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [argNat_nat, Option.bind_some, h1, h2]
  exact msim_ok' hs hr rfl hr

end

end Host.Ts.Sim.G
