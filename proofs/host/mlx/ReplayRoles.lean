import host.mlx.NativeKernelApply

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def mapSubst (f : Nat → Nat) (m : List (Nat × Nat)) : List (Nat × Nat) :=
  m.map (fun (a,b) => (f a,f b))

def replayLeaf : Prim → Bool
  | .data _ | .load _ _ | .zeros | .arange _ _ _ | .tracer _ => true
  | _ => false

/-- A replay substitution retains its first-match order. Only resource IDs
below the live allocation bound require injectivity; numeric values do not. -/
theorem substOf_map (f : Nat → Nat) (bound : Nat)
    (hinj : ∀ a b, a < bound → b < bound → f a = f b → a = b)
    (m : List (Nat × Nat)) (n : Nat) (hn : n < bound)
    (hm : listSupport (fun p : Nat × Nat => p.1 < bound) m) :
    substOf (mapSubst f m) (f n) = f (substOf m n) := by
  induction m with
  | nil => rfl
  | cons p m ih =>
    rcases p with ⟨a,b⟩
    have hb : Nat.beq (f a) (f n) = Nat.beq a n := by
      apply Bool.eq_iff_iff.mpr
      simp only [Nat.beq_eq]
      exact ⟨hinj a n hm.1 hn, congrArg f⟩
    simp only [substOf, mapSubst, List.map_cons, List.find?_cons]
    rw [hb]
    cases he : Nat.beq a n
    · exact ih hm.2
    · rfl

theorem PrimR.isKernel {NR : NumV → NumV → Prop} {R : Ren} {p p' : Prim}
    (h : PrimR NR R p p') : Ffi.isKernel p' = Ffi.isKernel p := by
  induction h <;> first | rfl | assumption

theorem PrimR.replayLeaf {NR : NumV → NumV → Prop} {R : Ren} {p p' : Prim}
    (h : PrimR NR R p p') : NativeRoles.replayLeaf p' = NativeRoles.replayLeaf p := by
  cases h <;> rfl

theorem subst_inputs_map (f : Nat → Nat) (bound : Nat)
    (hinj : ∀ a b, a < bound → b < bound → f a = f b → a = b)
    (m : List (Nat × Nat)) (hm : listSupport (fun p : Nat × Nat => p.1 < bound) m) :
    ∀ ins : List Nat, listSupport (fun i => i < bound) ins →
      (ins.map f).map (substOf (mapSubst f m)) = (ins.map (substOf m)).map f := by
  intro ins
  induction ins with
  | nil => intro _; rfl
  | cons i ins ih =>
    intro hi
    simp only [List.map_cons]
    rw [substOf_map f bound hinj m i hi.1 hm, ih hi.2]

/-- One actual replay-loop kernel step, before the recursive tail. Kernel
metadata is copied exactly as specified by the original replay implementation. -/
theorem replay_kernel_head (s : St) (cls n : Nat) (m : List (Nat × Nat)) (rest : List Nat)
    (nd : Node) (hn : s.nodes.get n = some nd) (hk : isKernel nd.prim = true) :
    replayOrder s cls m (n::rest) =
      replayOrder (s.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),nd.shape,nd.dtype⟩).2
        cls ((n,s.nnext)::m) rest := by
  rcases nd with ⟨p,ins,shape,dt⟩
  cases p <;> simp only [isKernel] at hk <;> try cases hk
  all_goals simp_all only [replayOrder,isKernel] <;> rfl

theorem replay_leaf_head (s : St) (cls n : Nat) (m : List (Nat × Nat)) (rest : List Nat)
    (nd : Node) (hn : s.nodes.get n = some nd) (leaf : replayLeaf nd.prim = true) :
    replayOrder s cls m (n::rest) = replayOrder s cls m rest := by
  rcases nd with ⟨p,ins,shape,dt⟩
  cases p <;> simp only [replayLeaf] at leaf <;> try cases leaf
  all_goals simp only [replayOrder,hn]

theorem replay_unchanged_head (s : St) (cls n : Nat) (m : List (Nat × Nat)) (rest : List Nat)
    (nd : Node) (hn : s.nodes.get n = some nd) (kernel : isKernel nd.prim = false)
    (same : nd.ins.map (substOf m) = nd.ins) :
    replayOrder s cls m (n::rest) = replayOrder s cls m rest := by
  rcases nd with ⟨p,ins,shape,dt⟩
  cases p <;> simp only [isKernel] at kernel <;> try cases kernel
  all_goals simp_all only [replayOrder,isKernel,decide_true] <;> rfl

/-- The real replay kernel branch transports its substitution and fresh node.
Opaque input roots are allowed elsewhere; a traced operation itself must retain
its primitive and input graph relation. -/
theorem Live.replay_kernel_head {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H N tail s s')
    (cls n : Nat) (nd : Node) (m : List (Nat × Nat)) (rest : List Nat)
    (hn : N n) (hnd : s.nodes.get n = some nd) (full : ¬ boundary n) (kernel : isKernel nd.prim = true)
    (inputs : listSupport (fun i => i < s.nnext) nd.ins)
    (keys : listSupport (fun p : Nat × Nat => p.1 < s.nnext) m)
    (bs : s.nnext < 2^64) (bt : s'.nnext < 2^64) :
    ∃ nd', s'.nodes.get (R.node n) = some nd' ∧
      replayOrder s cls m (n::rest) =
        replayOrder (s.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),nd.shape,nd.dtype⟩).2
          cls ((n,s.nnext)::m) rest ∧
      replayOrder s' (R.handle cls) (mapSubst R.node m) (R.node n :: rest.map R.node) =
        replayOrder (s'.addNode ⟨.replayed (R.handle cls) nd'.prim,
          nd'.ins.map (substOf (mapSubst R.node m)),nd'.shape,nd'.dtype⟩).2
          (R.handle cls) (mapSubst R.node ((n,s.nnext)::m)) (rest.map R.node) ∧
      Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R)
        H (fun i => i = s.nnext ∨ N i) tail
        (s.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),nd.shape,nd.dtype⟩).2
        (s'.addNode ⟨.replayed (R.handle cls) nd'.prim,
          nd'.ins.map (substOf (mapSubst R.node m)),nd'.shape,nd'.dtype⟩).2 := by
  obtain ⟨nd', ht, hr⟩ := h.node_view hn hnd
  have graph := hr.graph.resolve_left full
  have hk' : isKernel nd'.prim = true := graph.1.isKernel.trans kernel
  have hsubst : nd'.ins.map (substOf (mapSubst R.node m)) = (nd.ins.map (substOf m)).map R.node := by
    rw [graph.2]
    exact subst_inputs_map R.node s.nnext h.nodeMap.injective m keys nd.ins inputs
  have hnode : NodeR NR R (PrimR NR R) boundary s.nnext
      ⟨.replayed cls nd.prim,nd.ins.map (substOf m),nd.shape,nd.dtype⟩
      ⟨.replayed (R.handle cls) nd'.prim,nd'.ins.map (substOf (mapSubst R.node m)),nd'.shape,nd'.dtype⟩ :=
    ⟨hr.shape,hr.dtype,.inr ⟨.replayed cls graph.1,hsubst⟩⟩
  refine ⟨nd',ht,NativeRoles.replay_kernel_head s cls n m rest nd hnd kernel,?_,h.addNode _ _ hnode bs bt⟩
  rw [NativeRoles.replay_kernel_head s' (R.handle cls) (R.node n) (mapSubst R.node m)
    (rest.map R.node) nd' ht hk']
  simp only [mapSubst, List.map_cons, h.nodeMap.head]

theorem Live.replay_leaf_head {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H N tail s s')
    (cls n : Nat) (nd : Node) (m : List (Nat × Nat)) (rest : List Nat)
    (hn : N n) (hnd : s.nodes.get n = some nd) (full : ¬ boundary n) (leaf : replayLeaf nd.prim = true) :
    replayOrder s cls m (n::rest) = replayOrder s cls m rest ∧
      replayOrder s' (R.handle cls) (mapSubst R.node m) (R.node n :: rest.map R.node) =
        replayOrder s' (R.handle cls) (mapSubst R.node m) (rest.map R.node) := by
  obtain ⟨nd',ht,hr⟩ := h.node_view hn hnd
  have hp := (hr.graph.resolve_left full).1
  exact ⟨NativeRoles.replay_leaf_head s cls n m rest nd hnd leaf,
    NativeRoles.replay_leaf_head s' (R.handle cls) (R.node n) (mapSubst R.node m)
      (rest.map R.node) nd' ht (hp.replayLeaf.trans leaf)⟩

theorem Live.replay_unchanged_head {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H N tail s s')
    (cls n : Nat) (nd : Node) (m : List (Nat × Nat)) (rest : List Nat)
    (hn : N n) (hnd : s.nodes.get n = some nd) (full : ¬ boundary n) (kernel : isKernel nd.prim = false)
    (same : nd.ins.map (substOf m) = nd.ins)
    (inputs : listSupport (fun i => i < s.nnext) nd.ins)
    (keys : listSupport (fun p : Nat × Nat => p.1 < s.nnext) m) :
    replayOrder s cls m (n::rest) = replayOrder s cls m rest ∧
      replayOrder s' (R.handle cls) (mapSubst R.node m) (R.node n :: rest.map R.node) =
        replayOrder s' (R.handle cls) (mapSubst R.node m) (rest.map R.node) := by
  obtain ⟨nd',ht,hr⟩ := h.node_view hn hnd
  have graph := hr.graph.resolve_left full
  have mapped : nd'.ins.map (substOf (mapSubst R.node m)) = nd'.ins := by
    rw [graph.2, subst_inputs_map R.node s.nnext h.nodeMap.injective m keys nd.ins inputs, same]
  exact ⟨NativeRoles.replay_unchanged_head s cls n m rest nd hnd kernel same,
    NativeRoles.replay_unchanged_head s' (R.handle cls) (R.node n) (mapSubst R.node m)
      (rest.map R.node) nd' ht (graph.1.isKernel.trans kernel) mapped⟩

end Host.Mlx.Ffi.NativeRoles
