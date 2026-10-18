import host.mlx.ReplayPlan
import host.mlx.NativeVector

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem mapSubst_zip (f : Nat → Nat) : ∀ xs ys : List Nat,
    mapSubst f (xs.zip ys) = (xs.map f).zip (ys.map f) := by
  intro xs
  induction xs with
  | nil => intro ys; cases ys <;> rfl
  | cons x xs ih =>
    intro ys
    cases ys with
    | nil => rfl
    | cons y ys => simpa only [mapSubst,List.zip_cons_cons,List.map_cons] using congrArg ((f x,f y) :: ·) (ih ys)

/-- Output substitution and both recursive replay executions follow from the
source plan. The final substitution keys and captured output IDs are bounded
source graph facts, independent of numeric meanings. -/
theorem ReplayPlan.replay {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {N K : Nat → Prop}
    {s final : St} {result : List (Nat × Nat)} {t t' : Trace} {xs : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s (t.ins.zip xs) t.order K final result)
    (base : ∀ i n n', NodeRel i n n' → NodeR NR R (PrimR NR R) boundary i n n')
    {H : Nat → Prop} {tail : List NumV} {s' : St}
    (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s')
    (trace : TraceR R t t')
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) result)
    (outputs : listSupport (· < final.nnext) t.outs)
    (bs : s.nnext + t.order.length < 2^64) (bt : s'.nnext + t.order.length < 2^64) :
    ∃ final',
      replay s cls t xs = M.pure (some (final,t.outs.map (substOf result))) ∧
      replay s' (R.handle cls) t' (xs.map R.node) =
        M.pure (some (final',(t.outs.map (substOf result)).map R.node)) ∧
      Live NR R NodeRel (fun _ => ObjectR NR R) H K tail final final' ∧
      final'.objs = s'.objs ∧ final'.next = s'.next := by
  obtain ⟨final',hs,ht,hl,ho,hn⟩ := plan.paired base h bs bt
  have initial : mapSubst R.node (t.ins.zip xs) = t'.ins.zip (xs.map R.node) := by
    rw [mapSubst_zip,trace.ins]
  have mapped : t'.outs.map (substOf (mapSubst R.node result)) =
      (t.outs.map (substOf result)).map R.node := by
    rw [trace.outs]
    exact subst_inputs_map R.node final.nnext hl.nodeMap.injective result keys t.outs outputs
  rw [initial,← trace.order] at ht
  refine ⟨final',?_,?_,hl,ho,hn⟩
  · unfold Ffi.replay
    rw [hs]
    rfl
  · unfold Ffi.replay
    rw [ht]
    change M.pure (some (final',t'.outs.map (substOf (mapSubst R.node result)))) = _
    rw [mapped]

theorem applyDone_existing (s final : St) (cls b off slot : Nat) (t : Trace) (xs old outputs : List Nat)
    (hr : replay s cls t xs = M.pure (some (final,outputs)))
    (hv : final.obj? slot = some (.vec old)) :
    applyDone s cls b off slot t xs =
      okW (final.setObj slot (.vec outputs)) status0 [u64Write b off slot] := by
  unfold applyDone
  rw [hr]
  change (let result := setVec final slot outputs
    ; okW result.2 status0 [u64Write b off result.1]) = _
  rw [setVec_existing final slot old outputs hv]

theorem applyDone_fresh (s final : St) (cls b off slot : Nat) (t : Trace) (xs outputs : List Nat)
    (hr : replay s cls t xs = M.pure (some (final,outputs))) (hv : final.obj? slot = none) :
    applyDone s cls b off slot t xs =
      okW (final.newObj (.vec outputs)).2 status0 [u64Write b off final.next] := by
  unfold applyDone
  rw [hr]
  change (let result := setVec final slot outputs
    ; okW result.2 status0 [u64Write b off result.1]) = _
  rw [setVec_fresh final slot outputs hv]
  rfl

end Host.Mlx.Ffi.NativeRoles
