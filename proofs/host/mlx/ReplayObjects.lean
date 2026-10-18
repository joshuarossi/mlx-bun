import host.mlx.CachedReplay
import host.mlx.NativeObjectAnnotations

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem Live.withObjects {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel ObjRel' : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s')
    (objects : ∀ i, H i → OptionR (ObjRel' i) (s.objs.get i) (s'.objs.get (R.handle i))) :
    Live NR R NodeRel ObjRel' H N tail s s' := {h with objs := objects}

/-- Updating one object may replace its fixed annotation. Every other selected
object keeps its previous annotation and its original ordered payload. -/
theorem Live.setObjectRoles {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel ObjRel' : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s') (a : Nat) (ha : H a)
    (o o' : Obj) (created : ObjRel' a o o')
    (frame : ∀ i, i ≠ a → ∀ x y, ObjRel i x y → ObjRel' i x y)
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    Live NR R NodeRel ObjRel' H N tail (s.setObj a o) (s'.setObj (R.handle a) o') := by
  refine {h with objs := ?_,sourceObjsBound := ?_,targetObjsBound := ?_}
  · intro b hbl
    change OptionR (ObjRel' b) ((s.objs.set a o).get b) ((s'.objs.set (R.handle a) o').get (R.handle b))
    rw [PTrie.get_set_u64 _ _ _ bs,PTrie.get_set_u64 _ _ _ bt]
    by_cases he : b = a
    · subst b; simp only [ite_true]; exact .some created
    · have ht : R.handle b ≠ R.handle a := fun eq => he
        (h.handleMap.injective b a (h.liveHandleBound b hbl) (h.liveHandleBound a ha) eq)
      rw [ite_eq_right he,ite_eq_right ht]
      exact (h.objs b hbl).mono (frame b he)
  · intro b obj hb
    change (s.objs.set a o).get b = some obj at hb
    rw [PTrie.get_set_u64 _ _ _ bs] at hb
    by_cases he : b = a
    · subst b; exact h.liveHandleBound a ha
    · rw [ite_eq_right he] at hb; exact h.sourceObjsBound b obj hb
  · intro b obj hb
    change (s'.objs.set (R.handle a) o').get b = some obj at hb
    rw [PTrie.get_set_u64 _ _ _ bt] at hb
    by_cases he : b = R.handle a
    · subst b; exact h.handleMap.bound a (h.liveHandleBound a ha)
    · rw [ite_eq_right he] at hb; exact h.targetObjsBound b obj hb

/-- Replay's checked object-store frame restores the complete fixed object
relation after the local shape proof uses its binary projection. -/
theorem ReplayPlan.replay_objects {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {cls : Nat} {N K : Nat → Prop} {s final : St} {result : List (Nat × Nat)}
    {t t' : Trace} {xs : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s (t.ins.zip xs) t.order K final result)
    (base : ∀ i n n', NodeRel i n n' → NodeR NR R (PrimR NR R) boundary i n n')
    (objects : ∀ i x y, ObjRel i x y → ObjectR NR R x y)
    {H : Nat → Prop} {tail : List NumV} {s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s') (trace : TraceR R t t')
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) result)
    (outputs : listSupport (· < final.nnext) t.outs)
    (bs : s.nnext + t.order.length < 2^64) (bt : s'.nnext + t.order.length < 2^64) :
    ∃ final' : St, Ffi.replay s cls t xs = M.pure (some (final,t.outs.map (substOf result))) ∧
      Ffi.replay s' (R.handle cls) t' (xs.map R.node) =
        M.pure (some (final',(t.outs.map (substOf result)).map R.node)) ∧
      Live NR R NodeRel ObjRel H K tail final final' ∧ final'.objs = s'.objs ∧ final'.next = s'.next := by
  obtain ⟨final',hs,ht,hl,ho,hn⟩ := plan.replay base (h.mono (fun _ _ p => p) (fun _ _ _ p => p) objects)
    trace keys outputs bs bt
  refine ⟨final',hs,ht,hl.withObjects ?_,ho,hn⟩
  intro i hi
  rw [plan.frames.1,ho]
  exact h.objs i hi

theorem ReplayPlan.applyDone_objects {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel ObjRel' : Nat → Obj → Obj → Prop}
    {cls : Nat} {N K : Nat → Prop} {s final : St} {result : List (Nat × Nat)}
    {t t' : Trace} {xs : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s (t.ins.zip xs) t.order K final result)
    (base : ∀ i n n', NodeRel i n n' → NodeR NR R (PrimR NR R) boundary i n n')
    (objects : ∀ i x y, ObjRel i x y → ObjectR NR R x y)
    {H : Nat → Prop} {tail : List NumV} {s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s') (trace : TraceR R t t')
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) result)
    (outputs : listSupport (· < final.nnext) t.outs)
    (b off slot : Nat) (old : List Nat) (hslot : H slot) (hv : final.obj? slot = some (.vec old))
    (created : ObjRel' slot (.vec (t.outs.map (substOf result))) (.vec ((t.outs.map (substOf result)).map R.node)))
    (frame : ∀ i, i ≠ slot → ∀ x y, ObjRel i x y → ObjRel' i x y)
    (ns : s.nnext + t.order.length < 2^64) (nt : s'.nnext + t.order.length < 2^64)
    (bs : slot < 2^64) (bt : R.handle slot < 2^64) :
    ∃ final' : St, applyDone s cls b off slot t xs =
        okW (final.setObj slot (.vec (t.outs.map (substOf result)))) status0 [u64Write b off slot] ∧
      applyDone s' (R.handle cls) (R.a b) off (R.handle slot) t' (xs.map R.node) =
        okW (final'.setObj (R.handle slot) (.vec ((t.outs.map (substOf result)).map R.node)))
          status0 [u64Write (R.a b) off (R.handle slot)] ∧
      Live NR R NodeRel ObjRel' H K tail (final.setObj slot (.vec (t.outs.map (substOf result))))
        (final'.setObj (R.handle slot) (.vec ((t.outs.map (substOf result)).map R.node))) ∧
      ListR (Parametric.ByteR NR R) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
        (cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0) ∧
      final'.objs = s'.objs ∧ final'.next = s'.next := by
  obtain ⟨final',hs,ht,hl,ho,hn⟩ := plan.replay_objects base objects h trace keys outputs ns nt
  have hb := hl.mono (fun _ _ p => p) (fun _ _ _ p => p) objects
  exact ⟨final',NativeRoles.applyDone_existing s final cls b off slot t xs old _ hs hv,
    NativeRoles.applyDone_existing s' final' (R.handle cls) (R.a b) off (R.handle slot) t' (xs.map R.node)
      (old.map R.node) _ ht (hb.vec_view slot hslot old hv),
    hl.setObjectRoles slot hslot _ _ created frame bs bt,
    Parametric.cellParts_roles (.handle slot) .u64 8 0,ho,hn⟩

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts

def objectWrite (roles : Nat → Object) (slot : Nat) (value : Object) : Nat → Object :=
  fun i => if i = slot then value else roles i

theorem ObjectRel.write_frame {roles : Nat → Object} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {slot i : Nat} {value : Object} {x y : Obj}
    (ne : i ≠ slot) (h : ObjectRel roles ν₀ ν C₀ C R i x y) :
    ObjectRel (objectWrite roles slot value) ν₀ ν C₀ C R i x y := by
  exact ⟨by simpa only [objectWrite,ite_eq_right ne] using h.source,
    by simpa only [objectWrite,ite_eq_right ne] using h.target⟩

theorem ObjectRel.write_vec (roles : Nat → Object) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (slot : Nat) (nodes : List Nat) :
    ObjectRel (objectWrite roles slot (.vec nodes)) ν₀ ν C₀ C R slot (.vec nodes) (.vec (nodes.map R.node)) := by
  refine ⟨?_,?_⟩
  · simp only [objectWrite,ite_true]
    simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using
      (Object.Holds.vec (ν := ν₀) (C := C₀) (R := Owned.Annotated.identity) nodes)
  · simp only [objectWrite,ite_true]
    exact .vec nodes

end Host.Mlx.Ffi.Annotated
