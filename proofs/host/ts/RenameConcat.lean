import host.ts.RenameOutputs
import host.ts.RenameReadback
namespace Host.Mlx.Ffi
open Host.Ts
set_option maxRecDepth 1000000

theorem symOf_concat : symOf chars!"mlx_concatenate_axis" = some .concat := by decide +kernel

theorem call_concat_eq (s : St) (o v a stream : Arg) :
    call s chars!"mlx_concatenate_axis" [o, v, a, stream] =
      match (argNat v).bind s.obj?, argInt a with
      | some (.vec ns), some ax => match ns with
        | n :: _ => match s.nodes.get n with
          | some nd => match axisOf ax (len nd.shape) with
            | some k => opOut s o (.concat k) ns
            | none => stuck
          | none => stuck
        | [] => stuck
      | _, _ => stuck := by
  unfold call
  rw [symOf_concat]
  rfl

/-- The actual MLX concat dispatch over a live vector commutes with resource renaming,
including shape arithmetic, fresh output node/handle, and the JS result-slot write. -/
theorem call_concat_renamed {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') (hr : Function.Injective R.n)
    (o o' stream : Arg) (b off vh first : Nat) (rest : List Nat) (nd : Node)
    (af : F64) (ax : Int) (axis : Nat) (sh : List (List Dim × Nat))
    (hv : H vh) (hvec : s.obj? vh = some (.vec (first :: rest)))
    (hnd : s.nodes.get first = some nd) (ha : F64.toInt? af = some ax)
    (haxis : axisOf ax (len nd.shape) = some axis)
    (hs : shapesOf s (first :: rest) = some sh) (hi : ∀ i ∈ first :: rest, N i)
    (ho : slotOf o = some (b, off, 0)) (ho' : slotOf o' = some (R.a b, off, 0))
    (hn : s.nnext / 4096 < 4 ^ 31) (hn' : s'.nnext / 4096 < 4 ^ 31)
    (hh : s.next / 4096 < 4 ^ 31) (hh' : s'.next / 4096 < 4 ^ 31) :
    ComputationR R (OutputR R H N O tail s)
      (call s chars!"mlx_concatenate_axis" [o, .big (Int.ofNat vh), .num (.lit af), stream])
      (call s' chars!"mlx_concatenate_axis"
        [o', R.arg (.big (Int.ofNat vh)), R.arg (.num (.lit af)), R.arg stream]) := by
  have hvec' : s'.obj? (R.handle vh) = some (.vec ((first :: rest).map R.node)) := by
    unfold St.obj? at hvec ⊢
    rw [h.objs vh hv, hvec]
    rfl
  obtain ⟨nd', hnd', hvnd⟩ := h.node_view (hi first (by simp)) hnd
  have haxis' : axisOf ax (len nd'.shape) = some axis := by rw [hvnd.shape, len_map]; exact haxis
  rw [call_concat_eq, call_concat_eq]
  simp only [argNat_big_nat, argNat_renamed_handle R vh (h.handleNonneg vh hv)]
  simp only [Option.bind_some, hvec, hvec', Ren.arg, Ren.num, argInt, ha,
    List.map_cons, hnd, hnd', haxis, haxis']
  exact opOut_concat_renamed h hr o o' b off axis (first :: rest) sh hs hi ho ho' hn hn' hh hh'

end Host.Mlx.Ffi
