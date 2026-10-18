import host.mlx.NativeRoles

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem nodeId_some_array (s : St) (a i : Nat) (h : s.nodeId? a = some i) : s.arrs.get a = some i := by
  unfold St.nodeId? at h
  cases hb : Nat.beq a 0
  · simpa only [hb,Bool.cond_false] using h
  · simp only [hb,Bool.cond_true] at h
    cases h

/-- The producer list of live array handles is already in selected graph
support. This follows from original handle decoding and the live array store. -/
theorem Live.nodesOf_support {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s') (handles : List Nat) :
    ∀ nodes, listSupport H handles → nodesOf s handles = some nodes → listSupport N nodes := by
  induction handles with
  | nil =>
    intro nodes _ hn
    simp only [nodesOf] at hn
    cases hn
    exact True.intro
  | cons handle handles ih =>
    intro nodes hl hn
    cases hh : s.nodeId? handle with
    | none => simp only [nodesOf,hh,Option.bind_none] at hn; cases hn
    | some i =>
      cases ht : nodesOf s handles with
      | none => simp only [nodesOf,hh,Option.bind_some,ht,Option.map_none] at hn; cases hn
      | some rest =>
        simp only [nodesOf,hh,Option.bind_some,ht,Option.map_some] at hn
        cases hn
        exact ⟨h.arrLive handle i hl.1 (nodeId_some_array s handle i hh),ih rest hl.2 ht⟩

end Host.Mlx.Ffi.NativeRoles
