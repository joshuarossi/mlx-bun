import host.mlx.NativeAlloc
import host.mlx.NativeConfig

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

/-- The actual Metal-output loop adds related nodes in the same output order.
The source and target may use different literal output shapes and handles. -/
theorem kernel_outputs {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {H : Nat → Prop} {tail : List NumV} (kh : Nat) (xs : List Nat) (c c' : Cfg)
    (hc : CfgR NR c c') {outputs outputs' : List (List Dim × Nat)}
    (ho : ListR (fun a b : List Dim × Nat => Parametric.ShapeR NR a.1 b.1 ∧ b.2 = a.2) outputs outputs') :
    ∀ (N : Nat → Prop) (s s' : St) (index : Nat),
      Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H N tail s s' →
      s.nnext + outputs.length < 2^64 → s'.nnext + outputs'.length < 2^64 →
      let out := kernelApply.outs kh xs c s index outputs
      let out' := kernelApply.outs (R.handle kh) (xs.map R.node) c' s' index outputs'
      ∃ K, Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R)
        H K tail out.1 out'.1 ∧ out'.2 = out.2.map R.node ∧
        (∀ i, N i → K i) ∧ listSupport K out.2 := by
  induction ho with
  | nil =>
    intro N s s' index h _ _
    exact ⟨N,h,rfl,fun _ hi => hi,True.intro⟩
  | @cons a b outputs outputs' hab hrest ih =>
    intro N s s' index h bs bt
    rcases a with ⟨shape,dt⟩
    rcases b with ⟨shape',dt'⟩
    rcases hab with ⟨hs,hd⟩
    dsimp only at hd
    subst dt'
    have ns : s.nnext < 2^64 := by simp only [List.length_cons] at bs; omega
    have nt : s'.nnext < 2^64 := by simp only [List.length_cons] at bt; omega
    let n : Node := ⟨.kernel kh c index,xs,shape,dt⟩
    let n' : Node := ⟨.kernel (R.handle kh) c' index,xs.map R.node,shape',dt⟩
    have hn : NodeR NR R (PrimR NR R) boundary s.nnext n n' :=
      ⟨hs,rfl,.inr ⟨.kernel kh index hc,rfl⟩⟩
    have hv := h.addNode n n' hn ns nt
    have bs' : (s.addNode n).2.nnext + outputs.length < 2^64 := by
      change s.nnext+1+outputs.length < 2^64
      simp only [List.length_cons] at bs
      omega
    have bt' : (s'.addNode n').2.nnext + outputs'.length < 2^64 := by
      change s'.nnext+1+outputs'.length < 2^64
      simp only [List.length_cons] at bt
      omega
    obtain ⟨K,hk,he,hinc,hl⟩ := ih _ (s.addNode n).2 (s'.addNode n').2 (index+1) hv bs' bt'
    refine ⟨K, ?_, ?_, ?_, ?_⟩
    · exact hk
    · change s'.nnext :: (kernelApply.outs (R.handle kh) (xs.map R.node) c' (s'.addNode n').2 (index+1) outputs').2 =
        R.node s.nnext :: ((kernelApply.outs kh xs c (s.addNode n).2 (index+1) outputs).2.map R.node)
      rw [he, h.nodeMap.head]
    · intro i hi; exact hinc i (.inr hi)
    · exact ⟨hinc s.nnext (.inl rfl),hl⟩

theorem kernel_outputs_objs (kh : Nat) (xs : List Nat) (c : Cfg) :
    ∀ (outputs : List (List Dim × Nat)) (s : St) (index : Nat),
      (kernelApply.outs kh xs c s index outputs).1.objs = s.objs := by
  intro outputs
  induction outputs with
  | nil => intro s index; rfl
  | cons a outputs ih =>
    intro s index
    rcases a with ⟨shape,dt⟩
    exact ih (s.addNode ⟨.kernel kh c index,xs,shape,dt⟩).2 (index+1)

theorem kernel_outputs_next (kh : Nat) (xs : List Nat) (c : Cfg) :
    ∀ (outputs : List (List Dim × Nat)) (s : St) (index : Nat),
      (kernelApply.outs kh xs c s index outputs).1.next = s.next := by
  intro outputs
  induction outputs with
  | nil => intro s index; rfl
  | cons a outputs ih =>
    intro s index
    rcases a with ⟨shape,dt⟩
    exact ih (s.addNode ⟨.kernel kh c index,xs,shape,dt⟩).2 (index+1)

theorem call_kernelApply (s : St) (out kernel inputs config stream : Arg) :
    call s chars!"mlx_fast_metal_kernel_apply" [out,kernel,inputs,config,stream] =
      kernelApply s out kernel inputs config := by
  have hs : symOf chars!"mlx_fast_metal_kernel_apply" = some .kernelApply := by decide +kernel
  unfold call
  rw [hs]

end Host.Mlx.Ffi.NativeRoles
