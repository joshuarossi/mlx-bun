import host.mlx.ReplayRoles

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem map_injective_bounded (f : Nat → Nat) (bound : Nat)
    (hinj : ∀ a b, a < bound → b < bound → f a = f b → a = b) :
    ∀ xs ys : List Nat, listSupport (· < bound) xs → listSupport (· < bound) ys →
      xs.map f = ys.map f → xs = ys := by
  intro xs
  induction xs with
  | nil => intro ys _ _ he; cases ys with
    | nil => rfl
    | cons y ys => cases he
  | cons x xs ih =>
    intro ys hx hy he
    cases ys with
    | nil => cases he
    | cons y ys =>
      have heads := List.cons.inj he
      have hxy := hinj x y hx.1 hy.1 heads.1
      have ht := ih ys hx.2 hy.2 heads.2
      rw [hxy,ht]

/-- A changed non-kernel operation follows the original shape inference.
The actual pure inference result is exposed as a premise for its primitive's
shape-role lemma, not replaced by an assumed machine simulation. -/
theorem replay_node_head (s : St) (cls n : Nat) (m : List (Nat × Nat)) (rest : List Nat)
    (nd : Node) (inputs : List (List Dim × Nat)) (shape : List Dim) (dt : Nat)
    (hn : s.nodes.get n = some nd) (leaf : replayLeaf nd.prim = false)
    (kernel : isKernel nd.prim = false) (changed : nd.ins.map (substOf m) ≠ nd.ins)
    (hs : shapesOf s (nd.ins.map (substOf m)) = some inputs)
    (hi : infer nd.prim inputs = M.pure (some (.node shape dt))) :
    replayOrder s cls m (n::rest) =
      replayOrder (s.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),shape,dt⟩).2
        cls ((n,s.nnext)::m) rest := by
  have hc : decide (nd.ins.map (substOf m) = nd.ins) = false := by
    simp only [decide_eq_false_iff_not]; exact changed
  rcases nd with ⟨p,ins,oldShape,oldDt⟩
  cases p <;> simp only [replayLeaf] at leaf <;> try cases leaf
  all_goals simp_all only [replayOrder,isKernel] <;> rfl

theorem replay_same_head (s : St) (cls n : Nat) (m : List (Nat × Nat)) (rest : List Nat)
    (nd : Node) (inputs : List (List Dim × Nat)) (index result : Nat)
    (hn : s.nodes.get n = some nd) (leaf : replayLeaf nd.prim = false)
    (kernel : isKernel nd.prim = false) (changed : nd.ins.map (substOf m) ≠ nd.ins)
    (hs : shapesOf s (nd.ins.map (substOf m)) = some inputs)
    (hi : infer nd.prim inputs = M.pure (some (.same index)))
    (hout : nth? (nd.ins.map (substOf m)) index = some result) :
    replayOrder s cls m (n::rest) = replayOrder s cls ((n,result)::m) rest := by
  have hc : decide (nd.ins.map (substOf m) = nd.ins) = false := by
    simp only [decide_eq_false_iff_not]; exact changed
  rcases nd with ⟨p,ins,oldShape,oldDt⟩
  cases p <;> simp only [replayLeaf] at leaf <;> try cases leaf
  all_goals
    simp_all only [replayOrder,isKernel]
    change (match nth? (ins.map (substOf m)) index with
      | some k => replayOrder s cls ((n,k)::m) rest
      | none => M.pure none) = _
    rw [hout]

/-- Paired changed-input replay, with the original pure shape computations
supplied by the primitive-specific inference lemmas. Branch preservation uses
only bounded resource injectivity, never injectivity of numeric meanings. -/
theorem Live.replay_node_head {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H N tail s s')
    (cls n : Nat) (nd nd' : Node) (m : List (Nat × Nat)) (rest : List Nat)
    (inputs inputs' : List (List Dim × Nat)) (shape shape' : List Dim) (dt : Nat)
    (hn : N n) (hnd : s.nodes.get n = some nd) (hnd' : s'.nodes.get (R.node n) = some nd')
    (full : ¬ boundary n) (leaf : replayLeaf nd.prim = false) (kernel : isKernel nd.prim = false)
    (changed : nd.ins.map (substOf m) ≠ nd.ins)
    (inputBounds : listSupport (· < s.nnext) nd.ins)
    (substBounds : listSupport (· < s.nnext) (nd.ins.map (substOf m)))
    (keys : listSupport (fun p : Nat × Nat => p.1 < s.nnext) m)
    (hs : Ffi.shapesOf s (nd.ins.map (substOf m)) = some inputs)
    (hs' : Ffi.shapesOf s' (nd'.ins.map (substOf (mapSubst R.node m))) = some inputs')
    (hi : infer nd.prim inputs = M.pure (some (.node shape dt)))
    (hi' : infer nd'.prim inputs' = M.pure (some (.node shape' dt)))
    (hshape : Parametric.ShapeR NR shape shape')
    (bs : s.nnext < 2^64) (bt : s'.nnext < 2^64) :
    replayOrder s cls m (n::rest) =
        replayOrder (s.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),shape,dt⟩).2
          cls ((n,s.nnext)::m) rest ∧
      replayOrder s' (R.handle cls) (mapSubst R.node m) (R.node n :: rest.map R.node) =
        replayOrder (s'.addNode ⟨.replayed (R.handle cls) nd'.prim,
          nd'.ins.map (substOf (mapSubst R.node m)),shape',dt⟩).2
          (R.handle cls) (mapSubst R.node ((n,s.nnext)::m)) (rest.map R.node) ∧
      Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R)
        H (fun i => i = s.nnext ∨ N i) tail
        (s.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),shape,dt⟩).2
        (s'.addNode ⟨.replayed (R.handle cls) nd'.prim,
          nd'.ins.map (substOf (mapSubst R.node m)),shape',dt⟩).2 := by
  obtain ⟨value,hv,hr⟩ := h.node_view hn hnd
  have heq : value = nd' := Option.some.inj (hv.symm.trans hnd')
  subst value
  have graph := hr.graph.resolve_left full
  have hsubst : nd'.ins.map (substOf (mapSubst R.node m)) = (nd.ins.map (substOf m)).map R.node := by
    rw [graph.2]
    exact subst_inputs_map R.node s.nnext h.nodeMap.injective m keys nd.ins inputBounds
  have changed' : nd'.ins.map (substOf (mapSubst R.node m)) ≠ nd'.ins := by
    intro he
    rw [hsubst,graph.2] at he
    exact changed (map_injective_bounded R.node s.nnext h.nodeMap.injective
      _ _ substBounds inputBounds he)
  have hnrole : NodeR NR R (PrimR NR R) boundary s.nnext
      ⟨.replayed cls nd.prim,nd.ins.map (substOf m),shape,dt⟩
      ⟨.replayed (R.handle cls) nd'.prim,nd'.ins.map (substOf (mapSubst R.node m)),shape',dt⟩ :=
    ⟨hshape,rfl,.inr ⟨.replayed cls graph.1,hsubst⟩⟩
  refine ⟨NativeRoles.replay_node_head s cls n m rest nd inputs shape dt hnd leaf kernel changed hs hi,
    ?_,h.addNode _ _ hnrole bs bt⟩
  rw [NativeRoles.replay_node_head s' (R.handle cls) (R.node n) (mapSubst R.node m)
    (rest.map R.node) nd' inputs' shape' dt hnd' (graph.1.replayLeaf.trans leaf)
    (graph.1.isKernel.trans kernel) changed' hs' hi']
  simp only [mapSubst,List.map_cons,h.nodeMap.head]

theorem Live.replay_same_head {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H N tail s s')
    (cls n : Nat) (nd nd' : Node) (m : List (Nat × Nat)) (rest : List Nat)
    (inputs inputs' : List (List Dim × Nat)) (index result : Nat)
    (hn : N n) (hnd : s.nodes.get n = some nd) (hnd' : s'.nodes.get (R.node n) = some nd')
    (full : ¬ boundary n) (leaf : replayLeaf nd.prim = false) (kernel : isKernel nd.prim = false)
    (changed : nd.ins.map (substOf m) ≠ nd.ins)
    (inputBounds : listSupport (· < s.nnext) nd.ins)
    (substBounds : listSupport (· < s.nnext) (nd.ins.map (substOf m)))
    (keys : listSupport (fun p : Nat × Nat => p.1 < s.nnext) m)
    (hs : Ffi.shapesOf s (nd.ins.map (substOf m)) = some inputs)
    (hs' : Ffi.shapesOf s' (nd'.ins.map (substOf (mapSubst R.node m))) = some inputs')
    (hi : infer nd.prim inputs = M.pure (some (.same index)))
    (hi' : infer nd'.prim inputs' = M.pure (some (.same index)))
    (hout : nth? (nd.ins.map (substOf m)) index = some result) :
    replayOrder s cls m (n::rest) = replayOrder s cls ((n,result)::m) rest ∧
      replayOrder s' (R.handle cls) (mapSubst R.node m) (R.node n :: rest.map R.node) =
        replayOrder s' (R.handle cls) (mapSubst R.node ((n,result)::m)) (rest.map R.node) := by
  obtain ⟨value,hv,hr⟩ := h.node_view hn hnd
  have heq : value = nd' := Option.some.inj (hv.symm.trans hnd')
  subst value
  have graph := hr.graph.resolve_left full
  have hsubst : nd'.ins.map (substOf (mapSubst R.node m)) = (nd.ins.map (substOf m)).map R.node := by
    rw [graph.2]
    exact subst_inputs_map R.node s.nnext h.nodeMap.injective m keys nd.ins inputBounds
  have changed' : nd'.ins.map (substOf (mapSubst R.node m)) ≠ nd'.ins := by
    intro he
    rw [hsubst,graph.2] at he
    exact changed (map_injective_bounded R.node s.nnext h.nodeMap.injective
      _ _ substBounds inputBounds he)
  have hout' : nth? (nd'.ins.map (substOf (mapSubst R.node m))) index = some (R.node result) := by
    rw [hsubst,nth?_map R.node (nd.ins.map (substOf m)) index,hout]
    rfl
  refine ⟨NativeRoles.replay_same_head s cls n m rest nd inputs index result hnd leaf kernel changed hs hi hout,?_⟩
  rw [NativeRoles.replay_same_head s' (R.handle cls) (R.node n) (mapSubst R.node m)
    (rest.map R.node) nd' inputs' index (R.node result) hnd' (graph.1.replayLeaf.trans leaf)
    (graph.1.isKernel.trans kernel) changed' hs' hi' hout']
  rfl

end Host.Mlx.Ffi.NativeRoles
