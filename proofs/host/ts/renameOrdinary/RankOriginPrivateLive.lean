import host.ts.renameOrdinary.RankOriginPrivateSeed
import host.ts.renameOrdinary.RankOriginNativeFacts

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin.PrivateSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- Initialized private-handle notes refer to allocated native handles and
existing allocated producers in the same checked native correspondence seed. -/
theorem selected_native_live (owner : Nat) (note : PrivateNote)
    (selected : notes.owners owner = some note) :
    ∃ handle node producingNode, note.role = .handle handle ∧
      NativeSeed.handles handle ∧ NativeSeed.nodes node ∧
      native.arrs.get handle = some node ∧ native.nodes.get node = some producingNode := by
  obtain ⟨_,handle,node,object,w,e,rfl,_,_,_,_,arrRead,producingNode,nodeRead⟩ := ownership owner note selected
  have arrayRead : NativeSeed.native.arrs.get handle = some node := arrRead
  have handleBound := PTrie.bound_of_check NativeSeed.native.arrs NativeSeed.native.next
    NativeSeed.source_array_keys handle node arrayRead
  have nodeBound := Nat.blt_eq.mp (Host.Mlx.Ffi.Annotated.Initial.allPaged_get _ NativeSeed.native.arrs
    NativeSeed.source_array_nodes handle node arrayRead)
  exact ⟨handle,node,producingNode,rfl,handleBound,nodeBound,arrRead,nodeRead⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.PrivateSeed
