import host.mlx.GraphBuildCommand

namespace Host.Mlx.FfiEval
namespace GraphBuildChecks

def original : List (RNode Int InKey) :=
  (run (do
    let x ← inp InKey.tokenIds
    discard <| emit (.reshape [1, 1]) [x]) []).2

ffi_graph_literal staged : original
ffi_graph_literal_eq staged : original

ffi_value_literal embedded : run (embedG (δ := Int) (κ := InKey) id) []
ffi_value_literal_eq embedded : run (embedG (δ := Int) (κ := InKey) id) []

theorem node_count : staged.length = 2 := rfl

end GraphBuildChecks
end Host.Mlx.FfiEval
