import host.sim.conv.CompactBridge
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Layers

/-! # A compaction's native shift with the bridge active

A compaction after the bridge went active that records none of the stage's new nodes keeps the bridge state
(`FullShiftQ.bridge`), and the node map fixes the nodes it records. So the shift's bridge part is the bridge relation at
the map from the generated checks (`brel_of_checks`, `hrel`), the map's injectivity below the counter from the shift
and the start's nodes present (`ninj_dense`). -/

theorem fullShiftQX_of_active {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : FF.S} (h : FullShiftQ P n0 σ x0 x1)
    (ha : (bridgeOf x0).active = true) (hF : ∀ i, Full P i) (hd : DenseN (mlxOf x0))
    (hrel : (∀ i j, i < (mlxOf x0).nnext → j < (mlxOf x0).nnext → σ.node i = σ.node j → i = j) →
      BRel σ (mlxOf x0).nnext (mlxOf x1).nnext (bridgeOf x0) (bridgeOf x1)) :
    FullShiftQX P n0 σ x0 x1 :=
  ⟨h.load, h.tokens, h.tokSupp, bridgeX_of_active ha (hrel (ninj_dense (x0 := (clearTokens (toLoad x0)).mlx) h.load.mlx hF ⟨hd.1, hd.2⟩)) hd, h.live, h.kern, h.pend⟩

end Host.Ts.Sim.Conv
