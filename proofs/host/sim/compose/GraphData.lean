import host.simgraph.Carriers
import host.simgraph.world.Lift
import host.sim.world.IterCut

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Iter (TplInputs)

section
variable {Wd : World} (pr : GraphProj Wd)

/-- **The decode template start's graph facts**: the projection's constants, the carriers of the
template start (unread, present, below the native counter), the look-ahead token. -/
structure StartGM (A : Addr) (P : Wd.Par) (s0 : St Wd.F.S) (tab0 : List SymE) (I : TplInputs) : Prop where
  hPNL : ∀ r, (pr.lp P r).NL = A.NL
  hPN0 : ∀ r, (pr.lp P r).N0 = A.N0
  hPE : Wd.E P ≤ A.rope
  hrope : A.rope < 2 ^ 56
  htv : ∃ j, nth? tab0 j = some (.var A.tvar)
  carR : I.read < (Wd.toMlx s0.ffi).nnext
  carF : I.fed < (Wd.toMlx s0.ffi).nnext
  carC : ∀ p ∈ I.caches, ∀ j, (p.1 = some j ∨ p.2 = some j) → j < (Wd.toMlx s0.ffi).nnext
  sread : (Wd.toMlx s0.ffi).items.get I.read = none
  pread : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true
  sfed : (Wd.toMlx s0.ffi).items.get I.fed = none
  pfed : ((Wd.toMlx s0.ffi).nodes.get I.fed).isSome = true
  ne : I.read ≠ I.fed
  s0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]
  tokv : nth? tab0 A.tok = some (.var A.kvar)

/-- **A decode case end's graph facts**: its restart map's carriers (the read carrier to the fed
one, the fed one to the output node `outT`, the caches to `outs`), the readback at the end, the
output node and caches present. -/
structure EndGM {A : Addr} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} (I : TplInputs)
    (e : Prefill.IterEndW Wd A P s0 tab0 fixA) where
  outT : Nat
  outs : List (Option Nat × Option Nat)
  read : e.σ.node I.read = I.fed
  fed : e.σ.node I.fed = outT
  caches : I.caches.map (fun p => (p.1.map e.σ.node, p.2.map e.σ.node)) = outs
  h1read : (Wd.toMlx e.s1.ffi).items.get I.read = some (.ref A.tok)
  h1pread : ((Wd.toMlx e.s1.ffi).nodes.get I.read).isSome = true
  s1tok : (Wd.toMlx e.s1.ffi).tokens = []
  pout : ((Wd.toMlx e.s1.ffi).nodes.get outT).isSome = true
  pouts : ∀ p ∈ outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → ((Wd.toMlx e.s1.ffi).nodes.get j).isSome = true

end
end Host.Ts.Sim.Compose
