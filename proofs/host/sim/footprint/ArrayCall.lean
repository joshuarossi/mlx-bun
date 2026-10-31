import host.sim.footprint.Arrays
set_option maxRecDepth 20000
namespace Host.Mlx.Ffi.Footprint
open Host.Ts FullKeep
/-- Array operations with a first-argument output slot; metadata and fresh data constructors
are included. Object mutation, freeing, callbacks and token readback are separate families. -/
def ArraySym : Sym → Bool
  | .arrayNew | .arrayNewData | .arrayEval | .arrayNdim | .arrayShape | .arrayDtype | .arraySize
  | .reshape | .transpose | .slice | .sliceUpdate | .sliceDynamic | .concat | .zeros | .astype
  | .arange | .contiguous | .unary | .binary | .rmsNorm | .rope | .sdpa | .qmm | .dequantize
  | .take | .conv1d | .logsumexp | .graph _ => true
  | _ => false

macro "array_dispatch_w" : tactic => `(tactic|
  (unfold call
   rw [show symOf _ = some _ from by assumption]
   dsimp only
   repeat' (first
     | (allx_goal; reduce_call)
     | (allx_goal; case_call)
     | contradiction
     | with_reducible refine opOut_w (Writes.refl _) _ _ _ ?_
     | with_reducible refine leafOut_w (Writes.refl _) _ _ _ _ ?_
     | (intro b off slot he
        rcases slot_support he with hz | hp
        · exact Or.inl hz
        · exact Or.inr (output_cons _ _ _ hp))
     | with_reducible exact result_stuck
     | with_reducible refine result_okW ?_
     | with_reducible refine result_ok ?_
     | with_reducible exact Writes.refl _
     | with_reducible refine Writes.setArr ?_ 0 _ (Or.inl rfl)
     | with_reducible refine Writes.setArr ?_ _ _ (by
         rcases slot_support (by assumption) with hz | hp
         · exact Or.inl hz
         · exact Or.inr (output_cons _ _ _ hp))
     | with_reducible refine Writes.addNode ?_ _
     | with_reducible refine AllX.cond _ ?_ ?_
     | split_small
     | dsimp only)))

theorem call_arrayNew_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.arrayNew)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_arrayNewData_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.arrayNewData)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_arrayEval_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.arrayEval)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_arrayNdim_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.arrayNdim)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_arrayShape_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.arrayShape)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_arrayDtype_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.arrayDtype)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_arraySize_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.arraySize)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_reshape_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.reshape)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_transpose_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.transpose)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_slice_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.slice)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_sliceUpdate_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.sliceUpdate)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_sliceDynamic_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.sliceDynamic)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_concat_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.concat)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_zeros_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.zeros)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_astype_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.astype)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_arange_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.arange)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_contiguous_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.contiguous)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_unary_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.unary)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_binary_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.binary)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_rmsNorm_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.rmsNorm)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  unfold call
  rw [hsym]
  dsimp only
  repeat' (first | reduce_call | case_call)
  all_goals first
    | exact result_stuck
    | (split
       all_goals repeat' (first
         | with_reducible refine opOut_w (Writes.refl _) _ _ _ ?_
         | (intro b off slot he
            rcases slot_support he with hz | hp
            · exact Or.inl hz
            · exact Or.inr (output_cons _ _ _ hp))
         | with_reducible exact result_stuck
         | split))

theorem call_rope_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.rope)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_sdpa_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.sdpa)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_qmm_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.qmm)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_dequantize_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.dequantize)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_take_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.take)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_conv1d_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.conv1d)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_logsumexp_w (s : St) (name : Name) (args : List Arg)
    (hsym : symOf name = some (.logsumexp)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

theorem call_graph_w (s : St) (name : Name) (args : List Arg) (op : GraphOp)
    (hsym : symOf name = some (.graph op)) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  array_dispatch_w

/-- The actual native array dispatcher, assembled from individually checked cases. -/
theorem call_array_w (s : St) (name : Name) (args : List Arg)
    (ha : (symOf name).any ArraySym = true) :
    AllX (Result (Output args) (fun _ => False) s id) (call s name args) := by
  cases hn : symOf name with
  | none => simp only [hn, Option.any] at ha; contradiction
  | some x =>
    rw [hn] at ha
    cases x <;> simp only [Option.any, ArraySym] at ha <;> try contradiction
    all_goals first
      | exact call_arrayNew_w s name args hn
      | exact call_arrayNewData_w s name args hn
      | exact call_arrayEval_w s name args hn
      | exact call_arrayNdim_w s name args hn
      | exact call_arrayShape_w s name args hn
      | exact call_arrayDtype_w s name args hn
      | exact call_arraySize_w s name args hn
      | exact call_reshape_w s name args hn
      | exact call_transpose_w s name args hn
      | exact call_slice_w s name args hn
      | exact call_sliceUpdate_w s name args hn
      | exact call_sliceDynamic_w s name args hn
      | exact call_concat_w s name args hn
      | exact call_zeros_w s name args hn
      | exact call_astype_w s name args hn
      | exact call_arange_w s name args hn
      | exact call_contiguous_w s name args hn
      | exact call_unary_w s name args hn
      | exact call_binary_w s name args hn
      | exact call_rmsNorm_w s name args hn
      | exact call_rope_w s name args hn
      | exact call_sdpa_w s name args hn
      | exact call_qmm_w s name args hn
      | exact call_dequantize_w s name args hn
      | exact call_take_w s name args hn
      | exact call_conv1d_w s name args hn
      | exact call_logsumexp_w s name args hn
      | exact call_graph_w s name args _ hn

end Host.Mlx.Ffi.Footprint
