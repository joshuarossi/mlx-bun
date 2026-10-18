import host.mlx.AnnotatedInference

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned
open Host.Ts.Owned.Parametric

def inputRoles (roles : Nat → GraphNode) (inputs : List Nat) : Metadata :=
  inputs.map fun i => ((roles i).shape,(roles i).dtype)

/-- Reading live native input nodes retains their fixed per-node dimension
annotations. This is stronger than erasing them to a numeric binary relation. -/
theorem shapesOf_roles {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
      (NodeRel roles ν₀ ν C₀ C R boundary) (fun _ => NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R)
      H N tail s s') :
    ∀ (ins : List Nat) (metadata : List (List Dim × Nat)),
      listSupport N ins → shapesOf s ins = some metadata →
      ∃ metadata', shapesOf s' (ins.map R.node) = some metadata' ∧
        Metadata.Holds ν₀ C₀ (inputRoles roles ins) metadata ∧
        Metadata.Holds ν C (inputRoles roles ins) metadata' := by
  intro ins
  induction ins with
  | nil =>
    intro metadata _ hs
    have he : [] = metadata := Option.some.inj hs
    subst metadata
    exact ⟨[],rfl,.nil,.nil⟩
  | cons i ins ih =>
    intro metadata live hs
    cases hn : s.nodes.get i with
    | none => simp only [shapesOf,hn,Option.bind_none] at hs; cases hs
    | some nd =>
      obtain ⟨nd',hn',hr⟩ := h.node_view live.1 hn
      cases ht : shapesOf s ins with
      | none => simp only [shapesOf,hn,Option.bind_some,ht,Option.map_none] at hs; cases hs
      | some rest =>
        have he : (nd.shape,nd.dtype)::rest = metadata := by
          exact Option.some.inj (by simpa only [shapesOf,hn,Option.bind_some,ht,Option.map_some] using hs)
        subst metadata
        obtain ⟨rest',ht',ha,hb⟩ := ih rest live.2 ht
        refine ⟨(nd'.shape,nd'.dtype)::rest',?_,.cons ⟨hr.source.shape,hr.source.dtype⟩ ha,
          .cons ⟨hr.target.shape,hr.target.dtype⟩ hb⟩
        simp only [List.map_cons,shapesOf,hn',Option.bind_some,ht',Option.map_some]

end Host.Mlx.Ffi.Annotated
