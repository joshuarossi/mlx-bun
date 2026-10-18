import host.mlx.NativeReplaySupport
import host.mlx.NativeAnnotationPolicy

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

private theorem policy_lift {α : Type} {P Q : α → Prop} (inclusion : ∀ i, P i → Q i) :
    ∀ values : List α, listSupport P values → listSupport Q values
  | [], _ => True.intro
  | value::values, held => ⟨inclusion value held.1,policy_lift inclusion values held.2⟩

private theorem policy_nth {N : Nat → Prop} : ∀ values : List Nat, ∀ i value,
    listSupport N values → nth? values i = some value → N value := by
  intro values
  induction values with
  | nil => intro i value _ read; cases i <;> cases read
  | cons value values ih =>
    intro i output held read
    cases i with
    | zero => cases read; exact held.1
    | succ i => exact ih i output held.2 read

private def NewNodeSupport (original current : Nat → Prop) (s : St) : Prop :=
  ∀ i, current i → ¬ original i → ∃ node, s.nodes.get i = some node ∧ listSupport current node.ins

private theorem NewNodeSupport.addNode {original current : Nat → Prop} {s : St}
    (held : NewNodeSupport original current s) (node : Node) (inputs : listSupport current node.ins)
    (bound : s.nnext < 2^64) : NewNodeSupport original (fun i => i = s.nnext ∨ current i) (s.addNode node).2 := by
  intro i selected added
  by_cases equal : i = s.nnext
  · subst i
    refine ⟨node,?_,policy_lift (fun _ support => Or.inr support) node.ins inputs⟩
    change (s.nodes.set s.nnext node).get s.nnext = some node
    rw [PTrie.get_set_u64 _ _ _ bound,ite_eq_left rfl]
  · obtain ⟨old,read,supported⟩ := held i (selected.resolve_left equal) added
    refine ⟨old,?_,policy_lift (fun _ support => Or.inr support) old.ins supported⟩
    change (s.nodes.set s.nnext node).get i = some old
    rw [PTrie.get_set_u64 _ _ _ bound,ite_eq_right equal]
    exact read

private theorem ReplayPlan.preserve_new_support {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {original N K : Nat → Prop}
    {s final : St} {m result : List (Nat × Nat)} {order : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s m order K final result)
    (held : NewNodeSupport original N s) (values : listSupport (fun p : Nat × Nat => N p.2) m)
    (bound : s.nnext + order.length < 2^64) : NewNodeSupport original K final := by
  induction plan with
  | done => exact held
  | leaf nd live full node leaf rest ih => exact ih held values (by simp only [List.length_cons] at bound; omega)
  | unchanged nd live full node kernel same inputs keys rest ih => exact ih held values (by simp only [List.length_cons] at bound; omega)
  | @kernel N K s final m result n ns nd live full node kernel inputs keys create rest ih =>
    have current := held.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),nd.shape,nd.dtype⟩
      (substOf_support_list m values nd.ins inputs) (by omega)
    have lifted := policy_lift (P := fun p : Nat × Nat => N p.2)
      (Q := fun p : Nat × Nat => p.2 = s.nnext ∨ N p.2) (fun _ support => Or.inr support) m values
    exact ih current ⟨Or.inl rfl,lifted⟩ (by simp only [St.addNode,List.length_cons] at bound ⊢; omega)
  | @node N K s final m result n ns nd live full node leaf kernel changed inputs substituted keys metadata shape dtype read infer transport rest ih =>
    have current := held.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),shape,dtype⟩ substituted (by omega)
    have lifted := policy_lift (P := fun p : Nat × Nat => N p.2)
      (Q := fun p : Nat × Nat => p.2 = s.nnext ∨ N p.2) (fun _ support => Or.inr support) m values
    exact ih current ⟨Or.inl rfl,lifted⟩ (by simp only [St.addNode,List.length_cons] at bound ⊢; omega)
  | @same N K s final m result n ns nd live full node leaf kernel changed inputs substituted keys metadata index output read infer outputAt transport rest ih =>
    exact ih held ⟨policy_nth _ index output substituted outputAt,values⟩ (by simp only [List.length_cons] at bound; omega)

/-- Every newly supported producer is an actual source allocation and its
inputs remain supported. Alias results introduce no phantom graph nodes. -/
theorem ReplayPlan.new_nodes {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {N K : Nat → Prop}
    {s final : St} {m result : List (Nat × Nat)} {order : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s m order K final result)
    (values : listSupport (fun p : Nat × Nat => N p.2) m) (bound : s.nnext + order.length < 2^64) :
    ∀ i, K i → ¬ N i → ∃ node, final.nodes.get i = some node ∧ listSupport K node.ins :=
  plan.preserve_new_support (fun _ supported absent => False.elim (absent supported)) values bound

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric NativeRoles

/-- The checked source replay grows the pure annotation policy. Its actual
allocated nodes and their derived source annotations determine producer edges;
no final policy, target lookup, or target replay is assumed. -/
theorem ProducerAnnotations.replay {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {objects : Nat → Object} {boundary roots H N K : Nat → Prop}
    {cls : Nat} {s final : Ffi.St} {m result : List (Nat × Nat)} {order : List Nat}
    (policy : ProducerAnnotations roots H N roles objects)
    (plan : ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary cls (NodeRel roles ν₀ ν C₀ C R boundary)
      N s m order K final result)
    (values : listSupport (fun p : Nat × Nat => N p.2) m) (bound : s.nnext + order.length < 2^64)
    (sourceRoles : ∀ i node, K i → final.nodes.get i = some node → (roles i).Holds ν₀ C₀ Owned.Annotated.identity node) :
    ProducerAnnotations roots H K roles objects := by
  have inclusion := (plan.support values).1
  refine ⟨fun i selected => (policy.objects i selected).mono inclusion,policy.roots,?_⟩
  intro i selected primitive inputs graph
  by_cases previous : N i
  · exact policy_lift inclusion inputs (policy.nodes i previous primitive inputs graph)
  · obtain ⟨node,read,supported⟩ := plan.new_nodes values bound i selected previous
    have interpreted := (sourceRoles i node selected read).graph primitive inputs graph
    have exactInputs : node.ins = inputs := by
      simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using interpreted.2
    rw [exactInputs] at supported
    exact supported

end Host.Mlx.Ffi.Annotated
