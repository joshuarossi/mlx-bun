import host.mlx.NativeAnnotationSupport
import host.mlx.NativeKernelSupport

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open NativeRoles

private theorem policy_list_mono {α : Type} {P Q : α → Prop} (inclusion : ∀ i, P i → Q i) :
    ∀ (values : List α), listSupport P values → listSupport Q values
  | [], _ => True.intro
  | value::values, held => ⟨inclusion value held.1,policy_list_mono inclusion values held.2⟩

theorem Trace.Supported.mono {N K : Nat → Prop} {trace : Trace}
    (held : trace.Supported N) (inclusion : ∀ i, N i → K i) : trace.Supported K :=
  NativeRoles.TraceSupport.mono held inclusion

theorem Object.Supported.mono {N K : Nat → Prop} {object : Object}
    (held : object.Supported N) (inclusion : ∀ i, N i → K i) : object.Supported K := by
  cases object with
  | vec nodes => exact policy_list_mono inclusion nodes held
  | closure closure =>
    cases closure with
    | compiled callback shapeless payload traces => exact policy_list_mono (fun _ support => support.mono inclusion) traces held
    | _ => trivial
  | _ => trivial

theorem ProducerAnnotations.reindex {roots H N K : Nat → Prop} {roles : Nat → GraphNode} {objects : Nat → Object}
    (policy : ProducerAnnotations roots H N roles objects) (same : ∀ i, N i ↔ K i) :
    ProducerAnnotations roots H K roles objects := by
  refine ⟨fun i held => (policy.objects i held).mono (fun i selected => (same i).mp selected),policy.roots,?_⟩
  intro i selected primitive inputs graph
  exact policy_list_mono (fun i held => (same i).mp held) inputs
    (policy.nodes i ((same i).mpr selected) primitive inputs graph)

/-- Installing a concrete producer annotation extends support by that exact
node ID. Every old vector and captured trace keeps its producer dependencies. -/
theorem ProducerAnnotations.write_node {roots H N : Nat → Prop} {roles : Nat → GraphNode} {objects : Nat → Object}
    (policy : ProducerAnnotations roots H N roles objects) (fresh : Nat) (role : GraphNode)
    (primitive : Primitive) (inputs : List Nat) (graph : role.graph = some (primitive,inputs))
    (inputSupport : listSupport N inputs) :
    ProducerAnnotations roots H (fun i => i = fresh ∨ N i) (nodeWrite roles fresh role) objects := by
  constructor
  · intro i held
    exact (policy.objects i held).mono (fun _ selected => Or.inr selected)
  · intro i absent
    by_cases equal : i = fresh
    · simp only [nodeWrite,equal,ite_true,graph] at absent; cases absent
    · exact policy.roots i (by simpa only [nodeWrite,ite_eq_right equal] using absent)
  · intro i held p ins actual
    by_cases equal : i = fresh
    · simp only [nodeWrite,equal,ite_true,graph] at actual
      cases actual
      exact policy_list_mono (fun _ selected => Or.inr selected) inputs inputSupport
    · have previous : N i := held.resolve_left equal
      have previousGraph : (roles i).graph = some (p,ins) := by
        simpa only [nodeWrite,ite_eq_right equal] using actual
      exact policy_list_mono (fun _ selected => Or.inr selected) ins (policy.nodes i previous p ins previousGraph)

/-- Replacing a native object records its already determined producer list.
All node annotations and all other fixed object payloads are retained. -/
theorem ProducerAnnotations.write_object {roots H N : Nat → Prop} {roles : Nat → GraphNode} {objects : Nat → Object}
    (policy : ProducerAnnotations roots H N roles objects) (slot : Nat) (role : Object)
    (supported : role.Supported N) :
    ProducerAnnotations roots H N roles (objectWrite objects slot role) := by
  refine ⟨?_,policy.roots,policy.nodes⟩
  intro i held
  by_cases equal : i = slot
  · simpa only [objectWrite,equal,ite_true] using supported
  · simpa only [objectWrite,ite_eq_right equal] using policy.objects i held

theorem ProducerAnnotations.new_object {roots H N : Nat → Prop} {roles : Nat → GraphNode} {objects : Nat → Object}
    (policy : ProducerAnnotations roots H N roles objects) (slot : Nat) (role : Object)
    (supported : role.Supported N) :
    ProducerAnnotations roots (fun i => i = slot ∨ H i) N roles (objectWrite objects slot role) := by
  refine ⟨?_,policy.roots,policy.nodes⟩
  intro i held
  by_cases equal : i = slot
  · simpa only [objectWrite,equal,ite_true] using supported
  · simpa only [objectWrite,ite_eq_right equal] using policy.objects i (held.resolve_left equal)

/-- The original output loop preserves the pure annotation policy. The new
support is the old support plus exactly its returned source producer IDs. -/
theorem ProducerAnnotations.kernel_outputs {roots H : Nat → Prop} (handle : Nat) (inputs : List Nat) (config : Config)
    (sourceConfig : Cfg) : ∀ (outputRoles : List (Shape × Nat)) (outputs : List (List Dim × Nat)),
      outputRoles.length = outputs.length →
      ∀ (roles : Nat → GraphNode) (objects : Nat → Object) (N : Nat → Prop) (source : St) (index : Nat),
      ProducerAnnotations roots H N roles objects → listSupport N inputs →
      ProducerAnnotations roots H (outputSupport N (kernelApply.outs handle inputs sourceConfig source index outputs).2)
        (kernelOutputRoles roles handle inputs config source.nnext index outputRoles) objects := by
  intro outputRoles
  induction outputRoles with
  | nil =>
    intro outputs count roles objects N source index policy _
    have empty : outputs = [] := List.length_eq_zero_iff.mp count.symm
    subst outputs
    exact policy.reindex (fun _ => by simp only [kernelApply.outs,outputSupport,List.not_mem_nil,false_or])
  | cons role rest ih =>
    intro outputs count roles objects N source index policy supported
    cases outputs with
    | nil => simp only [List.length_cons,List.length_nil] at count; omega
    | cons output outputs =>
      have remaining : rest.length = outputs.length := Nat.succ.inj count
      let node : Node := ⟨.kernel handle sourceConfig index,inputs,output.1,output.2⟩
      have written := policy.write_node source.nnext (kernelNodeRole handle inputs config index role)
        (.kernel handle config index) inputs rfl supported
      have nextInputs := policy_list_mono (fun i held => (Or.inr held : i = source.nnext ∨ N i)) inputs supported
      have next := ih outputs remaining (nodeWrite roles source.nnext (kernelNodeRole handle inputs config index role))
        objects (fun i => i = source.nnext ∨ N i) (source.addNode node).2 (index+1) written nextInputs
      apply next.reindex
      intro i
      change (i ∈ (kernelApply.outs handle inputs sourceConfig (source.addNode node).2 (index+1) outputs).2 ∨
        i = source.nnext ∨ N i) ↔
        (i ∈ source.nnext::(kernelApply.outs handle inputs sourceConfig (source.addNode node).2 (index+1) outputs).2 ∨ N i)
      rw [List.mem_cons]
      exact or_left_comm.trans or_assoc.symm

end Host.Mlx.Ffi.Annotated
