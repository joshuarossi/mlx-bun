import host.mlx.NativeProducerSupport
import host.mlx.NativeKernelRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

private theorem lift_support {α : Type} {P Q : α → Prop} (f : ∀ i, P i → Q i) :
    ∀ xs, listSupport P xs → listSupport Q xs
  | [], _ => True.intro
  | i::is, h => ⟨f i h.1,lift_support f is h.2⟩

theorem support_member {α : Type} {P : α → Prop} (xs : List α) (support : listSupport P xs) :
    ∀ i, i ∈ xs → P i := by
  induction xs with
  | nil => intro i member; cases member
  | cons x xs ih =>
    intro i member
    cases List.mem_cons.mp member with
    | inl equal => subst i; exact support.1
    | inr member => exact ih support.2 i member

theorem ProducerSupport.reindex {roots H N K : Nat → Prop} {s : St}
    (h : ProducerSupport roots H N s) (same : ∀ i, N i ↔ K i) : ProducerSupport roots H K s := by
  constructor
  · intro i obj held read
    exact (h.objects i obj held read).mono (fun i hi => (same i).mp hi)
  · intro i node held read full
    exact lift_support (fun i hi => (same i).mp hi) node.ins (h.nodes i node ((same i).mpr held) read full)

/-- Shrinking graph support keeps all live handles when their decoded array
producers remain selected. Native object annotations are unchanged. -/
theorem Live.restrictSupport {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N K : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s')
    (selected : ∀ i, K i → N i)
    (arrayProducers : ∀ a i, H a → s.arrs.get a = some i → K i) :
    Live NR R NodeRel ObjRel H K tail s s' := by
  exact {h with nodes := fun i hi => h.nodes i (selected i hi),arrLive := arrayProducers,items := fun i hi => h.items i (selected i hi),liveNodeBound := fun i hi => h.liveNodeBound i (selected i hi)}

def outputSupport (N : Nat → Prop) (outputs : List Nat) (i : Nat) : Prop := i ∈ outputs ∨ N i

theorem outputSupport_old {N : Nat → Prop} (outputs : List Nat) : ∀ i, N i → outputSupport N outputs i :=
  fun _ hi => Or.inr hi

theorem outputSupport_outputs (N : Nat → Prop) (outputs : List Nat) : listSupport (outputSupport N outputs) outputs := by
  have all : ∀ xs : List Nat, (∀ i, i ∈ xs → outputSupport N outputs i) → listSupport (outputSupport N outputs) xs := by
    intro xs
    induction xs with
    | nil => intro _; trivial
    | cons i xs ih => intro held; exact ⟨held i (by simp),ih (fun j hj => held j (by simp only [List.mem_cons]; exact Or.inr hj))⟩
  exact all outputs (fun _ hi => Or.inl hi)

theorem kernel_outputs_arrs (handle : Nat) (inputs : List Nat) (config : Cfg) :
    ∀ outputs s index, (kernelApply.outs handle inputs config s index outputs).1.arrs = s.arrs := by
  intro outputs
  induction outputs with
  | nil => intro s index; rfl
  | cons output outputs ih =>
    intro s index
    exact ih (s.addNode ⟨.kernel handle config index,inputs,output.1,output.2⟩).2 (index+1)

/-- Every original Metal output has the same supported input producers. The
post-support is precisely the old support plus the actual returned node IDs. -/
theorem kernel_outputs_producer_support {roots H : Nat → Prop} (handle : Nat) (inputs : List Nat) (config : Cfg) :
    ∀ outputs (N : Nat → Prop) s index, ProducerSupport roots H N s → listSupport N inputs →
      s.nnext + outputs.length < 2^64 →
      let result := kernelApply.outs handle inputs config s index outputs
      ProducerSupport roots H (outputSupport N result.2) result.1 := by
  intro outputs
  induction outputs with
  | nil =>
    intro N s index support held _
    change ProducerSupport roots H (outputSupport N []) s
    exact support.reindex (fun i => by simp only [outputSupport,List.not_mem_nil,false_or])
  | cons output outputs ih =>
    intro N s index support held bound
    let node : Node := ⟨.kernel handle config index,inputs,output.1,output.2⟩
    have post := support.addNode node held (by simp only [List.length_cons] at bound; omega)
    have inputHeld := lift_support (fun i hi => (Or.inr hi : i = s.nnext ∨ N i)) inputs held
    have rest := ih (fun i => i = s.nnext ∨ N i) (s.addNode node).2 (index+1) post inputHeld
      (by simp only [St.addNode,List.length_cons] at bound ⊢; omega)
    apply rest.reindex
    intro i
    change (i ∈ (kernelApply.outs handle inputs config (s.addNode node).2 (index+1) outputs).2 ∨ i = s.nnext ∨ N i) ↔
      (i ∈ s.nnext :: (kernelApply.outs handle inputs config (s.addNode node).2 (index+1) outputs).2 ∨ N i)
    rw [List.mem_cons]
    exact or_left_comm.trans or_assoc.symm

private theorem metadata_length {α β : Type} {rel : α → β → Prop} {xs : List α} {ys : List β}
    (h : ListR rel xs ys) : xs.length = ys.length := by
  induction h with
  | nil => rfl
  | cons _ _ ih => exact congrArg Nat.succ ih

/-- The checked Metal native call retains producer closure with a canonical
post-support, in addition to every fixed node/object annotation. Array-handle
support is derived from the original store frame rather than dropped. -/
theorem Live.kernelApply_existing_supported {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary roots : Nat → Prop} {roles : Nat → GraphNode} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (support : ProducerSupport roots H N s)
    (out out' : Arg) (b off slot handle inv cfg : Nat) (name source header : Name)
    (nIn nOut : Nat) (inputs old : List Nat) (config : Config) (c : Cfg)
    (hslot : H slot) (hkernel : H handle) (hinputs : H inv) (hconfig : H cfg)
    (ho : slotOf out = some (b,off,slot)) (ho' : slotOf out' = some (R.a b,off,R.handle slot))
    (hk : s.obj? handle = some (.kernel name source header nIn nOut))
    (hi : s.obj? inv = some (.vec inputs)) (hv : s.obj? slot = some (.vec old))
    (hc : s.obj? cfg = some (.cfg c)) (configRole : objects cfg = .config config)
    (sourceNodes : s.nnext + config.outs.length < 2^64) (targetNodes : s'.nnext + config.outs.length < 2^64)
    (sourceSlot : slot < 2^64) (targetSlot : R.handle slot < 2^64) :
    ∃ c', s'.obj? (R.handle cfg) = some (.cfg c') ∧
      let result := kernelApply.outs handle inputs c s 0 c.outs
      let result' := kernelApply.outs (R.handle handle) (inputs.map R.node) c' s' 0 c'.outs
      kernelApply s out (.big (Int.ofNat handle)) (.big (Int.ofNat inv)) (.big (Int.ofNat cfg)) =
        okW (result.1.setObj slot (.vec result.2)) status0 [u64Write b off slot] ∧
      kernelApply s' out' (.big (Int.ofNat (R.handle handle))) (.big (Int.ofNat (R.handle inv)))
          (.big (Int.ofNat (R.handle cfg))) =
        okW (result'.1.setObj (R.handle slot) (.vec result'.2)) status0 [u64Write (R.a b) off (R.handle slot)] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (kernelOutputRoles roles handle inputs config s.nnext 0 config.outs) ν₀ ν C₀ C R boundary)
        (ObjectRel (objectWrite objects slot (.vec result.2)) ν₀ ν C₀ C R) H (outputSupport N result.2) tail
        (result.1.setObj slot (.vec result.2)) (result'.1.setObj (R.handle slot) (.vec result'.2)) ∧
      ProducerSupport roots H (outputSupport N result.2) (result.1.setObj slot (.vec result.2)) ∧
      result'.2 = result.2.map R.node ∧
      ListR (ByteR (NumberRoles ν₀ ν C₀ C) R)
        (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0) := by
  obtain ⟨_,_,sourceConfig,_⟩ := h.config_view_roles cfg hconfig config c configRole hc
  have sourceBound : s.nnext + c.outs.length < 2^64 := by
    rw [← metadata_length sourceConfig.output]
    exact sourceNodes
  obtain ⟨c',K,targetConfig,sourceCall,targetCall,nativeAfter,mapped,inclusion,outputs,bytes⟩ :=
    h.kernelApply_existing_roles out out' b off slot handle inv cfg name source header nIn nOut inputs old config c
      hslot hkernel hinputs hconfig ho ho' hk hi hv hc configRole sourceNodes targetNodes sourceSlot targetSlot
  let result := kernelApply.outs handle inputs c s 0 c.outs
  let result' := kernelApply.outs (R.handle handle) (inputs.map R.node) c' s' 0 c'.outs
  have selected : ∀ i, outputSupport N result.2 i → K i := by
    intro i held
    cases held with
    | inl member => exact support_member result.2 outputs i member
    | inr held => exact inclusion i held
  have arraySupport : ∀ a i, H a → (result.1.setObj slot (.vec result.2)).arrs.get a = some i → outputSupport N result.2 i := by
    intro a i held read
    change result.1.arrs.get a = some i at read
    rw [kernel_outputs_arrs] at read
    exact Or.inr (h.arrLive a i held read)
  have inputSupport := support.vector inv inputs hinputs hi
  have producers := kernel_outputs_producer_support handle inputs c c.outs N s 0 support inputSupport sourceBound
  have post := producers.setObj slot (.vec result.2) (outputSupport_outputs N result.2) sourceSlot
  refine ⟨c',targetConfig,sourceCall,targetCall,?_,post,mapped,bytes⟩
  exact nativeAfter.restrictSupport selected arraySupport

end Host.Mlx.Ffi.NativeRoles
