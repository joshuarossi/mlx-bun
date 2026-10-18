import host.mlx.NativeVectorGetRetained

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorRetainedTest
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles

/-- The producer payload is renamed by node role, independently of handle IDs. -/
theorem size_payload_rebase (R : Ren) (entries : List Nat) :
    len (entries.map R.node) = len entries := Host.Load.Owned.vector_length_map R.node entries

theorem selected_payload_rebase (R : Ren) (entries : List Nat) (index node : Nat)
    (selected : nth? entries index = some node) :
    nth? (entries.map R.node) index = some (R.node node) := by
  rw [Host.Load.Owned.vector_nth_map,selected]; rfl

/-- Extracting a producer adds an array handle but leaves the graph unchanged. -/
theorem element_counters (s : LSt) (node : Nat) :
    (Host.Load.Owned.vectorElement s node).mlx.next = s.mlx.next+1 ∧
    (Host.Load.Owned.vectorElement s node).mlx.nnext = s.mlx.nnext ∧
    (Host.Load.Owned.vectorElement s node).mlx.nodes = s.mlx.nodes := ⟨rfl,rfl,rfl⟩

theorem factory_counters (s : LSt) :
    (Host.Load.Owned.newVector s).mlx.next = s.mlx.next+1 ∧
    (Host.Load.Owned.newVector s).mlx.nnext = s.mlx.nnext := ⟨rfl,rfl⟩

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "theorem reject_node_allocation (s : Host.Load.LSt) (node : Nat) : (Host.Load.Owned.vectorElement s node).mlx.nnext = s.mlx.nnext+1 := by host_kernel_rfl"
  finally Lean.setEnv saved
end Host.Load.Run.Full.Ordinary.VectorRetainedTest
