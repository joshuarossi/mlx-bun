import host.ts.renameOrdinary.ParameterRoles
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
theorem concat_parameters_heap_frame (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s40 s)
    (targetBound : s.next + (blockNames Parameter48.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR NR FR R (CellsLive live P.RestStream.micro0.micro0.s48.next (blockNames Parameter48.sourceBody))
        framed before after old old' P.RestStream.micro0.micro0.s49 result ∧
      ∀ a, live a → a ≠ Parameter41.sourceAddress → a ≠ Parameter43.sourceAddress → a ≠ Parameter47.sourceAddress →
        result.heap.get (R.a a) = s.heap.get (R.a a) := by
  obtain ⟨initial,hctl,_⟩ := (h.control_view Parameter40.source_control).ret_view
  obtain ⟨frame,fs,hstack,hframe,_⟩ := h.stack_view Parameter40.source_frame
  obtain ⟨args,hframe,hargs⟩ := hframe.params_view
  have hpair : ∃ x y, args = [x,y] := by
    rw [concat_parameter_source_args] at hargs
    cases hargs with | cons hx ht =>
      cases ht with | cons hy ht =>
        cases ht
        exact ⟨_,_,rfl⟩
  obtain ⟨x,y,rfl⟩ := hpair
  rw [hframe,concat_parameter_source_params] at hstack
  have hl := h.stackLive
  change listSupport (fun f => treeSupport live (Encode.frame f)) Parameter40.input.stack at hl
  rw [Parameter40.source_frame] at hl
  have he := hl.1.1.2.2.2.1
  have ha := env_lookup_live _ _ _ he concat_parameter_lookup_arrays
  have hb := env_lookup_live _ _ _ he concat_parameter_lookup_axis
  have hc := env_lookup_live _ _ _ he concat_parameter_lookup_stream
  have hg := env_lookup_live _ _ _ he concat_parameter_lookup_gpu
  have hn : s.next ≤ 2^64 := Nat.le_trans (Nat.le_add_right _ _) targetBound
  have hab := Nat.lt_of_lt_of_le (h.heap.targetBound _ ha) hn
  have hbb := Nat.lt_of_lt_of_le (h.heap.targetBound _ hb) hn
  have hcb := Nat.lt_of_lt_of_le (h.heap.targetBound _ hc) hn
  have hga : R.a Parameter45.address ≠ R.a Parameter41.sourceAddress := by
    intro hh
    have heq := h.heap.inj _ _ hg ha hh
    exact (by decide +kernel : Parameter45.address ≠ Parameter41.sourceAddress) heq
  have hgb : R.a Parameter45.address ≠ R.a Parameter43.sourceAddress := by
    intro hh
    have heq := h.heap.inj _ _ hg hb hh
    exact (by decide +kernel : Parameter45.address ≠ Parameter43.sourceAddress) heq
  have hbc : R.a Parameter43.sourceAddress ≠ R.a Parameter47.sourceAddress := by
    intro hh
    have heq := h.heap.inj _ _ hb hc hh
    exact (by decide +kernel : Parameter43.sourceAddress ≠ Parameter47.sourceAddress) heq
  obtain ⟨gpu,hgpu,_,_⟩ := h.heap.readCell _ _ hg concat_parameter_gpu_cell
  have hl₁ : lookupEnv Parameter40.sourceName (R.env Parameter40.sourceEnv) = some (R.a Parameter41.sourceAddress) := by
    rw [lookupEnv_map,concat_parameter_lookup_arrays]; rfl
  have hl₂ : lookupEnv Parameter42.sourceName (R.env Parameter40.sourceEnv) = some (R.a Parameter43.sourceAddress) := by
    rw [lookupEnv_map,concat_parameter_lookup_axis]; rfl
  have hl₃ : lookupEnv Parameter47.sourceName (R.env Parameter40.sourceEnv) = some (R.a Parameter47.sourceAddress) := by
    rw [lookupEnv_map,concat_parameter_lookup_stream]; rfl
  have hlg : lookupEnv Parameter45.sourceName (R.env Parameter40.sourceEnv) = some (R.a Parameter45.address) := by
    rw [lookupEnv_map,concat_parameter_lookup_gpu]; rfl
  have hr := three_parameters_run P.F s C Parameter40.sourceFunction Parameter48.sourceName
    Parameter48.sourceParams Parameter48.sourceBody Parameter40.sourceName Parameter42.sourceName
    Parameter47.sourceName Parameter45.sourceName (R.env Parameter40.sourceEnv)
    (R.a Parameter41.sourceAddress) (R.a Parameter43.sourceAddress) (R.a Parameter47.sourceAddress)
    (R.a Parameter45.address) x y gpu initial fs hctl hstack concat_parameter_source_function
    hl₁ hl₂ hl₃ hlg hgpu hga hgb hab hbb
  obtain ⟨result,hresult,hpost⟩ := concat_parameters_transport NR FR R C₀ C live framed before after old old' s h targetBound
  have heq := congrArg Prod.fst (Option.some.inj (hresult.symm.trans hr))
  refine ⟨result,hresult,hpost,?_⟩
  intro a alive otherArrays otherAxis otherStream
  have ab := h.heap.targetBound a alive
  have ne₁ : R.a a ≠ R.a Parameter41.sourceAddress := fun he => otherArrays (h.heap.inj _ _ alive ha he)
  have ne₂ : R.a a ≠ R.a Parameter43.sourceAddress := fun he => otherAxis (h.heap.inj _ _ alive hb he)
  have ne₃ : R.a a ≠ R.a Parameter47.sourceAddress := fun he => otherStream (h.heap.inj _ _ alive hc he)
  dsimp only at heq
  rw [heq,enterBlock_heap_below {((s.setCell (R.a Parameter41.sourceAddress) x).setCell (R.a Parameter43.sourceAddress) y).setCell
    (R.a Parameter47.sourceAddress) gpu with ctl := .ret .undef, stack := fs}
    Parameter48.sourceBody (R.env Parameter40.sourceEnv) (R.a a) ab targetBound Parameter48.source_hoist]
  simp only [St.setCell,PTrie.get_set_u64 _ _ _ hcb,PTrie.get_set_u64 _ _ _ hbb,PTrie.get_set_u64 _ _ _ hab,
    ite_eq_right ne₁,ite_eq_right ne₂,ite_eq_right ne₃]

end Host.Load.Run.Full.Ordinary
