import host.ts.renameOrdinary.RankOriginNativeFacts

set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.NativeSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi

/-- The initialized native graph is paired with itself. All existing graph
nodes have checked indexed literal geometry and are explicit graph boundaries.
This theorem makes no claim about a shifted graph or future allocations. -/
theorem initial_live (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.micro3275.S1.tab.map (SymE.eval ρ)) :
    NativeRoles.Live (NumberRoles ρ ρ C C) identity
      (Host.Mlx.Ffi.Annotated.NodeRel roles ρ ρ C C identity boundary) objectRelation
      handles nodes [] native native := by
  have tableBound : 10 ≤ C.tab.length := by
    simpa only [table,List.length_map,InitialClosure.source_table_limit] using (Nat.le_refl 10)
  refine {
    arrs := ?_, objs := ?_, nodes := ?_, arrLive := ?_, items := ?_, tokens := ?_,
    pending := ?_, errh := ?_, files := rfl, arch := rfl, deviceSizes := rfl, wired := rfl,
    liveHandleBound := fun _ bound => bound, liveNodeBound := fun _ bound => bound,
    handleMap := ?_, nodeMap := ?_,
    sourceItemsBound := PTrie.bound_of_check _ _ source_item_keys,
    targetItemsBound := PTrie.bound_of_check _ _ source_item_keys,
    sourceObjsBound := PTrie.bound_of_check _ _ source_object_keys,
    targetObjsBound := PTrie.bound_of_check _ _ source_object_keys,
    sourceArrsBound := PTrie.bound_of_check _ _ source_array_keys,
    targetArrsBound := PTrie.bound_of_check _ _ source_array_keys,
    handleZero := rfl }
  · intro h _
    rw [Host.Mlx.Ffi.Annotated.Initial.identity_handle]
    change native.arrs.get h = (native.arrs.get h).map id
    exact (congrFun Option.map_id (native.arrs.get h)).symm
  · intro h _
    rw [Host.Mlx.Ffi.Annotated.Initial.identity_handle]
    cases read : native.objs.get h with
    | none => exact .none
    | some object => exact .some rfl
  · intro i _
    change NativeRoles.OptionR _ (native.nodes.get i) (native.nodes.get i)
    cases read : native.nodes.get i with
    | none => exact .none
    | some node => exact .some ⟨source_annotation ρ C i node read,source_annotation ρ C i node read,fun _ => trivial⟩
  · intro h i _ read
    exact Nat.blt_eq.mp (Host.Mlx.Ffi.Annotated.Initial.allPaged_get _ native.arrs source_array_nodes h i read)
  · intro i _
    change NativeRoles.OptionR _ (native.items.get i) (native.items.get i)
    cases read : native.items.get i with
    | none => exact .none
    | some number =>
      have safe := Host.Mlx.Ffi.Annotated.Initial.allPaged_get _ native.items source_item_numbers i number read
      exact .some (ClosureCheck.number_identity 10 ρ C tableBound number (ClosureCheck.number_sound 10 number safe))
  · exact ⟨native.tokens,Host.Mlx.Ffi.Annotated.Initial.numberList_identity 10 ρ C tableBound _ source_token_numbers,
      (List.append_nil _).symm⟩
  · rw [source_pending]; rfl
  · rw [source_error_handler]
    exact .some (.node _ (.cons (.region _) (.cons (.atom Nat 0) .nil)))
  · exact ⟨fun h bound => by simpa only [Host.Mlx.Ffi.Annotated.Initial.identity_handle] using bound,
      fun _ _ _ _ equal => by simpa only [Host.Mlx.Ffi.Annotated.Initial.identity_handle] using equal,
      fun _ => Host.Mlx.Ffi.Annotated.Initial.identity_handle _⟩
  · exact ⟨fun _ bound => bound,fun _ _ _ _ equal => equal,fun _ => rfl⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.NativeSeed
