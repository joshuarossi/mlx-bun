import host.mlx.ReplayPlan

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

/-- Restrict the graph witness used by a local metadata calculation. The
calculation owns no native handles; the surrounding execution retains them. -/
theorem Live.onlyNodes {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N K : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s') (keep : ∀ i, K i → N i) :
    Live NR R NodeRel ObjRel (fun _ => False) K tail s s' := by
  refine {
    arrs := fun _ h => False.elim h, objs := fun _ h => False.elim h,
    nodes := fun i hi => h.nodes i (keep i hi),
    arrLive := fun _ _ h => False.elim h,
    items := fun i hi => h.items i (keep i hi),
    tokens := h.tokens, pending := h.pending, errh := h.errh, files := h.files,
    arch := h.arch, deviceSizes := h.deviceSizes, wired := h.wired,
    liveHandleBound := fun _ h => False.elim h,
    liveNodeBound := fun i hi => h.liveNodeBound i (keep i hi),
    handleMap := h.handleMap, nodeMap := h.nodeMap,
    sourceItemsBound := h.sourceItemsBound, targetItemsBound := h.targetItemsBound,
    sourceObjsBound := h.sourceObjsBound, targetObjsBound := h.targetObjsBound,
    sourceArrsBound := h.sourceArrsBound, targetArrsBound := h.targetArrsBound,
    handleZero := h.handleZero }

private theorem support_frame {N F : Nat → Prop} : ∀ xs : List Nat,
    listSupport N xs → listSupport (fun i => N i ∨ F i) xs
  | [], _ => True.intro
  | _::xs, h => ⟨.inl h.1,support_frame xs h.2⟩

/-- Replay preserves arbitrary additional live graph roots, including roots
owned by other cache-array handles. Only local inference witnesses use the
smaller support recorded by the source plan. -/
theorem ReplayPlan.frame {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {N K : Nat → Prop}
    {s final : St} {m result : List (Nat × Nat)} {order : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s m order K final result) (F : Nat → Prop) :
    ReplayPlan NR R boundary cls NodeRel (fun i => N i ∨ F i) s m order
      (fun i => K i ∨ F i) final result := by
  induction plan with
  | done => exact .done _ _ _
  | leaf nd live full node leaf rest ih =>
    exact .leaf nd (.inl live) full node leaf ih
  | unchanged nd live full node kernel same inputs keys rest ih =>
    exact .unchanged nd (.inl live) full node kernel same (support_frame _ inputs) keys ih
  | kernel nd live full node kernel inputs keys create rest ih =>
    apply ReplayPlan.kernel nd (.inl live) full node kernel (support_frame _ inputs) keys create
    simpa only [or_assoc] using ih
  | node nd live full node leaf kernel changed inputs substituted keys metadata shape dt read infer transport rest ih =>
    apply ReplayPlan.node nd (.inl live) full node leaf kernel changed (support_frame _ inputs)
      (support_frame _ substituted) keys metadata shape dt read infer
    · intro H tail target h nd' metadata' hr hm ht
      exact transport (h.onlyNodes (fun _ hi => .inl hi)) nd' metadata' hr hm ht
    · simpa only [or_assoc] using ih
  | same nd live full node leaf kernel changed inputs substituted keys metadata index output read infer outputAt transport rest ih =>
    apply ReplayPlan.same nd (.inl live) full node leaf kernel changed (support_frame _ inputs)
      (support_frame _ substituted) keys metadata index output read infer outputAt
    · intro H tail target h nd' metadata' hr hm ht
      exact transport (h.onlyNodes (fun _ hi => .inl hi)) nd' metadata' hr hm ht
    · exact ih

end Host.Mlx.Ffi.NativeRoles
