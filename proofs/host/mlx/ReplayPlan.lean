import host.mlx.ReplayInference

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

abbrev MetadataR (NR : NumV → NumV → Prop) :=
  ListR (fun a b : List Dim × Nat => Parametric.ShapeR NR a.1 b.1 ∧ b.2 = a.2)

/-- A source replay derivation records the original local branches. Its
inference premises quantify over related primitive inputs; they are supplied
by the primitive-specific shape and guard laws, rather than a target run. -/
inductive ReplayPlan (NR : NumV → NumV → Prop) (R : Ren) (boundary : Nat → Prop) (cls : Nat)
    (NodeRel : Nat → Node → Node → Prop) :
    (Nat → Prop) → St → List (Nat × Nat) → List Nat →
    (Nat → Prop) → St → List (Nat × Nat) → Prop where
  | done (N : Nat → Prop) (s : St) (m : List (Nat × Nat)) :
      ReplayPlan NR R boundary cls NodeRel N s m [] N s m
  | leaf {N K : Nat → Prop} {s final : St} {m result : List (Nat × Nat)} {n : Nat} {ns : List Nat}
      (nd : Node) (live : N n) (full : ¬ boundary n) (node : s.nodes.get n = some nd)
      (leaf : replayLeaf nd.prim = true)
      (rest : ReplayPlan NR R boundary cls NodeRel N s m ns K final result) :
      ReplayPlan NR R boundary cls NodeRel N s m (n::ns) K final result
  | unchanged {N K : Nat → Prop} {s final : St} {m result : List (Nat × Nat)} {n : Nat} {ns : List Nat}
      (nd : Node) (live : N n) (full : ¬ boundary n) (node : s.nodes.get n = some nd)
      (kernel : isKernel nd.prim = false) (same : nd.ins.map (substOf m) = nd.ins)
      (inputs : listSupport N nd.ins)
      (keys : listSupport (fun p : Nat × Nat => p.1 < s.nnext) m)
      (rest : ReplayPlan NR R boundary cls NodeRel N s m ns K final result) :
      ReplayPlan NR R boundary cls NodeRel N s m (n::ns) K final result
  | kernel {N K : Nat → Prop} {s final : St} {m result : List (Nat × Nat)} {n : Nat} {ns : List Nat}
      (nd : Node) (live : N n) (full : ¬ boundary n) (node : s.nodes.get n = some nd)
      (kernel : isKernel nd.prim = true) (inputs : listSupport N nd.ins)
      (keys : listSupport (fun p : Nat × Nat => p.1 < s.nnext) m)
      (create : ∀ nd', NodeRel n nd nd' →
        NodeRel s.nnext ⟨.replayed cls nd.prim,nd.ins.map (substOf m),nd.shape,nd.dtype⟩
          ⟨.replayed (R.handle cls) nd'.prim,nd'.ins.map (substOf (mapSubst R.node m)),nd'.shape,nd'.dtype⟩)
      (rest : ReplayPlan NR R boundary cls NodeRel (fun i => i = s.nnext ∨ N i)
        (s.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),nd.shape,nd.dtype⟩).2
        ((n,s.nnext)::m) ns K final result) :
      ReplayPlan NR R boundary cls NodeRel N s m (n::ns) K final result
  | node {N K : Nat → Prop} {s final : St} {m result : List (Nat × Nat)} {n : Nat} {ns : List Nat}
      (nd : Node) (live : N n) (full : ¬ boundary n) (node : s.nodes.get n = some nd)
      (leaf : replayLeaf nd.prim = false) (kernel : isKernel nd.prim = false)
      (changed : nd.ins.map (substOf m) ≠ nd.ins) (inputs : listSupport N nd.ins)
      (substituted : listSupport N (nd.ins.map (substOf m)))
      (keys : listSupport (fun p : Nat × Nat => p.1 < s.nnext) m)
      (metadata : List (List Dim × Nat)) (shape : List Dim) (dt : Nat)
      (read : shapesOf s (nd.ins.map (substOf m)) = some metadata)
      (infer : Ffi.infer nd.prim metadata = M.pure (some (.node shape dt)))
      (transport : ∀ {H : Nat → Prop} {tail : List NumV} {s' : St},
        Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s' →
        ∀ nd' metadata', NodeRel n nd nd' → MetadataR NR metadata metadata' →
          shapesOf s' (nd'.ins.map (substOf (mapSubst R.node m))) = some metadata' →
        ∃ shape', Ffi.infer nd'.prim metadata' = M.pure (some (.node shape' dt)) ∧
          NodeRel s.nnext ⟨.replayed cls nd.prim,nd.ins.map (substOf m),shape,dt⟩
            ⟨.replayed (R.handle cls) nd'.prim,nd'.ins.map (substOf (mapSubst R.node m)),shape',dt⟩)
      (rest : ReplayPlan NR R boundary cls NodeRel (fun i => i = s.nnext ∨ N i)
        (s.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),shape,dt⟩).2
        ((n,s.nnext)::m) ns K final result) :
      ReplayPlan NR R boundary cls NodeRel N s m (n::ns) K final result
  | same {N K : Nat → Prop} {s final : St} {m result : List (Nat × Nat)} {n : Nat} {ns : List Nat}
      (nd : Node) (live : N n) (full : ¬ boundary n) (node : s.nodes.get n = some nd)
      (leaf : replayLeaf nd.prim = false) (kernel : isKernel nd.prim = false)
      (changed : nd.ins.map (substOf m) ≠ nd.ins) (inputs : listSupport N nd.ins)
      (substituted : listSupport N (nd.ins.map (substOf m)))
      (keys : listSupport (fun p : Nat × Nat => p.1 < s.nnext) m)
      (metadata : List (List Dim × Nat)) (index output : Nat)
      (read : shapesOf s (nd.ins.map (substOf m)) = some metadata)
      (infer : Ffi.infer nd.prim metadata = M.pure (some (.same index)))
      (outputAt : nth? (nd.ins.map (substOf m)) index = some output)
      (transport : ∀ {H : Nat → Prop} {tail : List NumV} {s' : St},
        Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s' →
        ∀ nd' metadata', NodeRel n nd nd' → MetadataR NR metadata metadata' →
          shapesOf s' (nd'.ins.map (substOf (mapSubst R.node m))) = some metadata' →
        Ffi.infer nd'.prim metadata' = M.pure (some (.same index)))
      (rest : ReplayPlan NR R boundary cls NodeRel N s ((n,output)::m) ns K final result) :
      ReplayPlan NR R boundary cls NodeRel N s m (n::ns) K final result

private theorem support_bound {N : Nat → Prop} {s s' : St}
    {NR : NumV → NumV → Prop} {R : Ren} {H : Nat → Prop} {tail : List NumV}
    {NodeRel : Nat → Node → Node → Prop}
    (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s') :
    ∀ xs : List Nat, listSupport N xs → listSupport (· < s.nnext) xs
  | [], _ => True.intro
  | i::is, hi => ⟨h.liveNodeBound i hi.1,support_bound h is hi.2⟩

theorem ReplayPlan.frames {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {N K : Nat → Prop}
    {s final : St} {m result : List (Nat × Nat)} {order : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s m order K final result) :
    final.objs = s.objs ∧ final.next = s.next := by
  induction plan <;> first | exact ⟨rfl,rfl⟩ | assumption

/-- Every local source branch composes into both original recursive replay
runs. The target state is constructed by the proof; no target execution is a
premise. Numeric meanings remain related independently of resource identities. -/
theorem ReplayPlan.paired {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop}
    {cls : Nat} {N K : Nat → Prop} {s final : St} {m result : List (Nat × Nat)} {order : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s m order K final result)
    (base : ∀ i n n', NodeRel i n n' → NodeR NR R (PrimR NR R) boundary i n n')
    {H : Nat → Prop} {tail : List NumV} {s' : St}
    (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s')
    (bs : s.nnext + order.length < 2^64) (bt : s'.nnext + order.length < 2^64) :
    ∃ final', replayOrder s cls m order = M.pure (some (final,result)) ∧
      replayOrder s' (R.handle cls) (mapSubst R.node m) (order.map R.node) =
        M.pure (some (final',mapSubst R.node result)) ∧
      Live NR R NodeRel (fun _ => ObjectR NR R) H K tail final final' ∧ final'.objs = s'.objs ∧ final'.next = s'.next := by
  induction plan generalizing s' with
  | done N s m => exact ⟨s',rfl,rfl,h,rfl,rfl⟩
  | leaf nd live full node leaf rest ih =>
    have hb := h.mono (fun _ _ r => r) base (fun _ _ _ r => r)
    obtain ⟨hs,ht⟩ := hb.replay_leaf_head _ _ nd _ _ live node full leaf
    obtain ⟨final',hsrc,htgt,hfinal,hobjs,hnext⟩ := ih h (by simp only [List.length_cons] at bs; omega)
      (by simp only [List.length_cons] at bt; omega)
    exact ⟨final',hs.trans hsrc,ht.trans htgt,hfinal,hobjs,hnext⟩
  | unchanged nd live full node kernel same inputs keys rest ih =>
    have hb := h.mono (fun _ _ r => r) base (fun _ _ _ r => r)
    obtain ⟨hs,ht⟩ := hb.replay_unchanged_head _ _ nd _ _ live node full kernel same
      (support_bound h _ inputs) keys
    obtain ⟨final',hsrc,htgt,hfinal,hobjs,hnext⟩ := ih h (by simp only [List.length_cons] at bs; omega)
      (by simp only [List.length_cons] at bt; omega)
    exact ⟨final',hs.trans hsrc,ht.trans htgt,hfinal,hobjs,hnext⟩
  | kernel nd live full node kernel inputs keys create rest ih =>
    have hb := h.mono (fun _ _ r => r) base (fun _ _ _ r => r)
    obtain ⟨nd',hnd',hs,ht,_⟩ := hb.replay_kernel_head _ _ nd _ _ live node full kernel
      (support_bound h _ inputs) keys (by omega) (by omega)
    obtain ⟨nd'',hnd'',hr⟩ := h.node_view live node
    have he : nd'' = nd' := Option.some.inj (hnd''.symm.trans hnd')
    subst nd''
    have hl := h.addNode _ _ (create nd' hr) (by omega) (by omega)
    obtain ⟨final',hsrc,htgt,hfinal,hobjs,hnext⟩ := ih hl (by simp only [St.addNode,List.length_cons] at bs ⊢; omega)
      (by simp only [St.addNode,List.length_cons] at bt ⊢; omega)
    exact ⟨final',hs.trans hsrc,ht.trans htgt,hfinal,hobjs,hnext⟩
  | @node N K s final m result n ns nd live full node leaf kernel changed inputs substituted keys metadata shape dt read infer transport rest ih =>
    obtain ⟨nd',hnd',hr⟩ := h.node_view live node
    have hb := h.mono (fun _ _ r => r) base (fun _ _ _ r => r)
    have graph := (base _ _ _ hr).graph.resolve_left full
    have mapped : nd'.ins.map (substOf (mapSubst R.node m)) = (nd.ins.map (substOf m)).map R.node := by
      rw [graph.2]
      exact subst_inputs_map R.node _ h.nodeMap.injective _ keys nd.ins (support_bound h _ inputs)
    obtain ⟨metadata',hread',hmeta⟩ := h.shapesOf (fun i n n' r => ⟨(base i n n' r).shape,(base i n n' r).dtype⟩) _ _ substituted read
    rw [← mapped] at hread'
    obtain ⟨shape',hinfer',hnew⟩ := transport h nd' metadata' hr hmeta hread'
    obtain ⟨hs,ht,_⟩ := hb.replay_node_head _ _ nd nd' _ _ metadata metadata' shape shape' dt
      live node hnd' full leaf kernel changed (support_bound h _ inputs)
      (support_bound h _ substituted) keys read hread' infer hinfer' (base _ _ _ hnew).shape (by omega) (by omega)
    have hl := h.addNode _ _ hnew (by omega) (by omega)
    obtain ⟨final',hsrc,htgt,hfinal,hobjs,hnext⟩ := ih hl (by simp only [St.addNode,List.length_cons] at bs ⊢; omega)
      (by simp only [St.addNode,List.length_cons] at bt ⊢; omega)
    exact ⟨final',hs.trans hsrc,ht.trans htgt,hfinal,hobjs,hnext⟩
  | @same N K s final m result n ns nd live full node leaf kernel changed inputs substituted keys metadata index output read infer outputAt transport rest ih =>
    obtain ⟨nd',hnd',hr⟩ := h.node_view live node
    have hb := h.mono (fun _ _ r => r) base (fun _ _ _ r => r)
    have graph := (base _ _ _ hr).graph.resolve_left full
    have mapped : nd'.ins.map (substOf (mapSubst R.node m)) = (nd.ins.map (substOf m)).map R.node := by
      rw [graph.2]
      exact subst_inputs_map R.node _ h.nodeMap.injective _ keys nd.ins (support_bound h _ inputs)
    obtain ⟨metadata',hread',hmeta⟩ := h.shapesOf (fun i n n' r => ⟨(base i n n' r).shape,(base i n n' r).dtype⟩) _ _ substituted read
    rw [← mapped] at hread'
    have hinfer' := transport h nd' metadata' hr hmeta hread'
    obtain ⟨hs,ht⟩ := hb.replay_same_head _ _ nd nd' _ _ metadata metadata' index output
      live node hnd' full leaf kernel changed (support_bound h _ inputs)
      (support_bound h _ substituted) keys read hread' infer hinfer' outputAt
    obtain ⟨final',hsrc,htgt,hfinal,hobjs,hnext⟩ := ih h (by simp only [List.length_cons] at bs; omega)
      (by simp only [List.length_cons] at bt; omega)
    exact ⟨final',hs.trans hsrc,ht.trans htgt,hfinal,hobjs,hnext⟩

end Host.Mlx.Ffi.NativeRoles
