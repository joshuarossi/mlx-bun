import host.sim.world.LF
import host.sim.native.gen.Rel
namespace Host.Mlx.SimGraph
open Host.Ts Host.Ts.Sim

/-! # The graph side over a world

The decode loop's graph invariant (`GxL`, `host.simgraph.iter.InvL`) reads the target only through
its mlx state (`t.ffi.mlx`), and its obligations read the native relation only through the general
relation of the load world's state (`Host.Ts.Sim.G.LoadR`: node correspondence, readback items, tokens). Over a
world `Wd`:

* `GraphProj Wd`: the load-world part `toLoad` of a world state (its mlx state the world's
  `toMlx`) and the projection of the world's relation to `Host.Ts.Sim.G.LoadR` there, its remaining
  readbacks the relation's (`lfProj`: the load world, `LoadR.toG`); `GraphProj.mr`, `GraphProj.loadR`:
  a related pair's general relations;
* `liftG Wd Gm`: an invariant `G` of the mlx state as the loop's further invariant over `Wd`
  (`GxL … = liftG lfWorld (fun i Mp x Cs => ∀ tab, CSrv.Le Cs ⟨tab⟩ → GIL … tab i Mp.node x)`,
  definitionally);
* `LoopGStepM`, `CutGStepM`, `LastGStepM`: the loop case's and the halts' graph obligations for a
  lifted invariant stated over the general relation only; `LoopGStepM.toW`, `CutGStepM.toW`,
  `LastGStepM.toW` give the world's obligations (`LoopGStepW`, `CutGStepW`, `LastGStepW`), so a
  graph proof against `Host.Ts.Sim.G.LoadR` serves every world with a projection. The obligations at
  the machine reference (`GxM`, `gstep_ofM`, …): `host.simgraph.world.Mach`. -/

/-- **The graph side's view of a world**: the load-world part of its states and the general
native relation there. -/
structure GraphProj (Wd : World) where
  toLoad : Wd.F.S → Host.Load.LSt
  mlx : ∀ x, (toLoad x).mlx = Wd.toMlx x
  lp : Wd.Par → List NumV → LoadP
  NB : Wd.Par → Nat
  load : ∀ {P : Wd.Par} {r : List NumV} {M : Map} {n : Nat} {x y : Wd.F.S}, Wd.R P r M n x y →
    Host.Ts.Sim.G.LoadR (lp P r) (NB P) M n (toLoad x) (toLoad y)
  rest : ∀ P r, (lp P r).rest = r

/-- The load world's projection: the state itself, `LoadR.toG`. -/
def lfProj : GraphProj lfWorld where
  toLoad x := x
  mlx _ := rfl
  lp P r := { P with rest := r }
  NB P := P.NL
  load h := LoadR.toG h
  rest _ _ := rfl

section
variable {Wd : World} (pr : GraphProj Wd)

/-- A related pair's general native relation at the load-world parts. -/
theorem GraphProj.loadR {P : Wd.Par} {r : List NumV} {W : Nat → Option WFrame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St Wd.F.S} {S : SSrv} {C : CSrv} (h : RelF Wd.F (Wd.R P r) W M ν K s S t C) :
    Host.Ts.Sim.G.LoadR (pr.lp P r) (pr.NB P) M S.tab.length (pr.toLoad s.ffi) (pr.toLoad t.ffi) :=
  pr.load h.ffi

/-- A related pair's general native relation at the mlx states. -/
theorem GraphProj.mr {P : Wd.Par} {r : List NumV} {W : Nat → Option WFrame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St Wd.F.S} {S : SSrv} {C : CSrv} (h : RelF Wd.F (Wd.R P r) W M ν K s S t C) :
    Host.Ts.Sim.G.MR (pr.lp P r) (pr.NB P) M S.tab.length (Wd.toMlx s.ffi) (Wd.toMlx t.ffi) := by
  rw [← pr.mlx, ← pr.mlx]; exact (pr.loadR h).mlx

end

/-- An invariant of the decode loop that reads the target only through its mlx state. -/
abbrev MlxInv := Nat → Map → Host.Mlx.Ffi.St → CSrv → Prop

/-- **The invariant over a world**, through `toMlx`. -/
def liftG (Wd : World) (Gm : MlxInv) : Nat → Map → St Wd.F.S → CSrv → Prop :=
  fun i M t C => Gm i M (Wd.toMlx t.ffi) C

theorem liftG_lf (Gm : MlxInv) : liftG lfWorld Gm = fun i M t C => Gm i M t.ffi.mlx C := rfl

section Steps
variable {Wd : World} (pr : GraphProj Wd) {A : Addr} {P : Wd.Par} {W : Nat → Option WFrame} {Fr : LoopFramesA A}
  {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat}

/-- **A loop case's graph obligation over the general relation** for a lifted invariant: from `G`
at the start, the general relation at the start and at the case's end, the table's numbers there,
the context's band, the server's growth, the mlx state's growth and the map's extension, `G` at the
next iteration under the case's restart map. -/
def LoopGStepM (Gm : MlxInv) (c : LoopCaseW Wd A P s0 tab0 fixA) (V : LoopVals) (toks : List NumV) (i : Nat) : Prop :=
  ∀ (hlen : i < toks.length) (nx : Nat) (M M1 : Map) (K : Ctx) (t t1 : St Wd.F.S) (C C1 : CSrv),
    Gm i M (Wd.toMlx t.ffi) C →
    Host.Ts.Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) M tab0.length (pr.toLoad s0.ffi) (pr.toLoad t.ffi) →
    NumOK M (V i nx) ⟨tab0, []⟩ C → K.lo = Wd.lo P → K.hi = Wd.E P → CSrv.Le C C1 →
    Host.Mlx.Ffi.NGrow (Wd.toMlx t.ffi) (Wd.toMlx t1.ffi) → Ext M M1 c.S0.tab.length →
    Host.Ts.Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) M1 c.S1.tab.length (pr.toLoad c.s1.ffi) (pr.toLoad t1.ffi) →
    NumOK M1 (V i nx) c.S1 C1 → (∀ j, BigFixed K.lo K.hi j → M1.big j = j) →
    Gm (i + 1) (c.rmap M1 toks[i] t1) (Wd.toMlx t1.ffi) C1

/-- **The loop case's obligation over the world** from the general one. -/
theorem LoopGStepM.toW {Gm : MlxInv} {c : LoopCaseW Wd A P s0 tab0 fixA} {V : LoopVals} {toks : List NumV} {i : Nat}
    (h : LoopGStepM pr Gm c V toks i) : LoopGStepW (liftG Wd Gm) (relW Wd P W) Fr c V toks i := by
  intro hlen nx M K t C M1 t1 C1 hG hst _ hlo hhi hrun hgr hext hend
  exact h hlen nx M M1 K t t1 C C1 hG (pr.loadR hst) hst.srv.num hlo hhi (runC_le _ _ _ _ _ hrun) hgr hext
    (pr.loadR hend) hend.srv.num hend.bigFixed

/-- **A halting chain's graph obligation at a cut over the general relation**, for a lifted
invariant and a goal `Gf` at the halted target. -/
def CutGStepM {toks : List NumV} {i : Nat} (Gm : MlxInv) (hs : HaltSegW Wd A W P (toks.drop i) s0 s0 tab0 [])
    (V : LoopVals) (Gf : St Wd.F.S → CSrv → Prop) : Prop :=
  ∀ (nx : Nat) (M : Map) (K : Ctx) (t : St Wd.F.S) (C : CSrv) (xF : SegInst Wd.F),
    Gm i M (Wd.toMlx t.ffi) C → (∀ a ∈ fixA, M.a a = a) →
    Host.Ts.Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) M tab0.length (pr.toLoad s0.ffi) (pr.toLoad t.ffi) →
    NumOK M (V i nx) ⟨tab0, []⟩ C → K.lo = Wd.lo P → K.hi = Wd.E P → CSrv.Le C xF.C →
    Host.Mlx.Ffi.NGrow (Wd.toMlx t.ffi) (Wd.toMlx xF.t.ffi) → Ext M xF.M tab0.length → xF.ν = V i nx →
    hs.case.Rend xF hs.case.sF hs.case.SF → Gf xF.t xF.C

theorem CutGStepM.toW {toks : List NumV} {i : Nat} {Gm : MlxInv} {hs : HaltSegW Wd A W P (toks.drop i) s0 s0 tab0 []}
    {V : LoopVals} {Gf : St Wd.F.S → CSrv → Prop} (h : CutGStepM pr (fixA := fixA) Gm hs V Gf) :
    CutGStepW A (liftG Wd Gm) P W Fr fixA hs V Gf := by
  intro nx M K t C xF hG hfix hst _ hlo hhi hrun hgr hext hν _ _ _ hend
  exact h nx M K t C xF hG hfix (pr.loadR hst) hst.srv.num hlo hhi (runC_le _ _ _ _ _ hrun) hgr hext hν hend

/-- **A halting chain's graph obligation from the final template start over the general
relation**, for a lifted invariant and a goal `Gf` at the halted target. -/
def LastGStepM {toks : List NumV} {T : Nat} {xs : List Val} (Gm : MlxInv)
    (hs : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) xs)
    (V : LoopVals) (tk : Nat → Nat) (Gf : St Wd.F.S → CSrv → Prop) : Prop :=
  ∀ (hlen : T - 2 < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St Wd.F.S) (C : CSrv) (xF : SegInst Wd.F),
    Gm (T - 2) M (Wd.toMlx t.ffi) C → (∀ a ∈ fixA, M.a a = a) →
    Host.Ts.Sim.G.LoadR (pr.lp P (toks.drop (T - 2))) (pr.NB P) M tab0.length (pr.toLoad s0.ffi) (pr.toLoad t.ffi) →
    NumOK M (V (T - 2) nx) ⟨tab0, []⟩ C → K.lo = Wd.lo P → K.hi = Wd.E P → CSrv.Le C xF.C →
    Host.Mlx.Ffi.NGrow (Wd.toMlx t.ffi) (Wd.toMlx xF.t.ffi) →
    Ext (M.setNum tab0.length toks[T - 2]) xF.M (tab0.length + 1) → xF.ν = V (T - 2) (tk T) →
    hs.case.Rend xF hs.case.sF hs.case.SF → Gf xF.t xF.C

theorem LastGStepM.toW {toks : List NumV} {T : Nat} {xs : List Val} {Gm : MlxInv}
    {hs : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) xs}
    {V : LoopVals} {tk : Nat → Nat} {Gf : St Wd.F.S → CSrv → Prop} (h : LastGStepM pr (fixA := fixA) Gm hs V tk Gf) :
    LastGStepW A (liftG Wd Gm) P W Fr fixA hs V tk Gf := by
  intro hlen nx M K t C xF hG hfix hst _ hlo hhi hrun hgr hext hν _ _ _ hend
  exact h hlen nx M K t C xF hG hfix (pr.loadR hst) hst.srv.num hlo hhi (runC_le _ _ _ _ _ hrun) hgr hext hν hend

end Steps

end Host.Mlx.SimGraph
