import host.sim.native.Args
namespace Host.Ts.Sim.G

/-- **The order `MRw.norder` keeps at `i`**: `M` puts node 0 and `i`'s inputs below `i`. Two closures' traces can come in either
order, so nodes joined by no edge have no order here. -/
abbrev NOrd (M : Map) (x : NSt) (i j : Nat) : Prop :=
  (j = 0 ∨ ∃ nd, x.nodes.get i = some nd ∧ j ∈ nd.ins) → M.node j < M.node i

end Host.Ts.Sim.G
