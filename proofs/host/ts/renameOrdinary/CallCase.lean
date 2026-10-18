import host.ts.renameOrdinary.HostCuts
import host.ts.RenameParametricCallStep
import host.ts.RenameParametricHoist
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def callInput := P.RestStream.micro0.micro0.s39
noncomputable def callOutput := P.RestStream.micro0.micro0.s40
noncomputable def callObject : Obj := match callInput.heap.get 2790 with
 | some (.obj o) => o
 | _ => ⟨.ordinary,.null,[],[],true⟩
noncomputable def callEnv : Env := match callObject.kind with
 | .fn (.closure _ env _ _) => env
 | _ => []
theorem call_control : callInput.ctl = .call (.obj 2790) (.obj 607) [.obj 3126664,natV 1] := rfl
theorem call_heap : callInput.heap.get 2790 = some (.obj callObject) := rfl
theorem call_kind : callObject.kind = .fn (.closure Host.Ts.Sources.Mlx.Ops.ast_n172 callEnv false .undef) := rfl
theorem call_source_run (C : CSrv) : interpC (step P.F callInput).run C = some (callOutput,C) := rfl

/-- Apply live-heap closure dispatch at the exact first ordinary call. The
target closure, environment, arguments, allocations and entry are derived. -/
theorem call_source_transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' callInput s)
    (this : Val) (args : List Val)
    (hc : s.ctl = .call (.obj (R.a 2790)) this args)
    (ht : s.next + 2 + (paramNames Host.Ts.Sources.Mlx.Ops.ast_n172).length ≤ 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R (ClosureLive live callInput.next false .undef Host.Ts.Sources.Mlx.Ops.ast_n172)
        framed before after old old' callOutput result := by
  obtain ⟨result₀,result,hr₀,hr,hpost⟩ := step_closure_from_state P.F NR FR R C₀ C live framed
    before after old old' callInput s h 2790 callObject Host.Ts.Sources.Mlx.Ops.ast_n172 callEnv
    false .undef (.obj 607) this [.obj 3126664,natV 1] args call_control hc call_heap call_kind (by decide) ht
  rw [call_source_run] at hr₀
  have heq : callOutput = result₀ := congrArg Prod.fst (Option.some.inj hr₀)
  exact ⟨result,hr,heq.symm ▸ hpost⟩
def functionStatements : Func → List Stmt
 | .mk _ _ _ body _ _ _ => bodyStmts body
noncomputable def calledFunctions : List Func := [Host.Ts.Sources.Mlx.Ops.ast_n172,
 Host.Ts.Prelude.ast_n7,
 Host.Ts.Sources.Mlx.CustomVjp.ast_n12,
 Host.Ts.Sources.Mlx.Array.ast_n59,
 Host.Ts.Sources.Mlx.Ffi.ast_n54,
 Host.Ts.Sources.Mlx.Ops.ast_n168,
 Host.Ts.Sources.Mlx.Array.ast_n67,
 Host.Ts.Sources.Mlx.Array.ast_n61,
 Host.Ts.Sources.Inference.State.Ssm.ast_n17,
 Host.Ts.Sources.Mlx.Array.ast_n157,
 Host.Ts.Sources.Mlx.Array.ast_n153,
 Host.Ts.Sources.Mlx.Array.ast_n155,
 Host.Ts.Sources.Mlx.Materialize.ast_n11,
 Host.Ts.Sources.Mlx.Ops.ast_n360,
 Host.Ts.Sources.Mlx.Ops.ast_n358,
 Host.Ts.Sources.Mlx.Array.ast_n172,
 Host.Ts.Sources.Mlx.Array.ast_n170,
 Host.Ts.Sources.Mlx.Ops.ast_n506,
 Host.Ts.Sources.Mlx.Ops.ast_n504,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n59,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n223,
 Host.Ts.Sources.Inference.Layers.DeltaHeads.ast_n11,
 Host.Ts.Sources.Mlx.Compile.ast_n91,
 Host.Ts.Sources.Inference.Kernels.Delta.Gated.ast_n132,
 Host.Ts.Sources.Mlx.Ops.ast_n31,
 Host.Ts.Sources.Mlx.Ops.ast_n29,
 Host.Ts.Sources.Inference.Kernels.Delta.Gated.ast_n34,
 Host.Ts.Sources.Inference.Kernels.Delta.Gated.ast_n45,
 Host.Ts.Sources.Mlx.Array.ast_n47,
 Host.Ts.Sources.Mlx.Array.ast_n3,
 Host.Ts.Sources.Inference.Kernels.Delta.Gated.ast_n8,
 Host.Ts.Sources.Mlx.Array.ast_n69,
 Host.Ts.Sources.Mlx.MetalKernel.ast_n73,
 Host.Ts.Sources.Inference.State.Ssm.ast_n112,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n215,
 Host.Ts.Sources.Inference.Layers.CompiledNormalization.ast_n22,
 Host.Ts.Sources.Mlx.Ops.ast_n154,
 Host.Ts.Sources.Mlx.Ops.ast_n152,
 Host.Ts.Sources.Inference.Layers.QuantizedLinear.ast_n64,
 Host.Ts.Sources.Inference.Layers.QuantizedLinear.ast_n18,
 Host.Ts.Sources.Inference.Layers.QuantizedLinear.ast_n20,
 Host.Ts.Sources.Inference.Layers.QuantizedLinear.ast_n22,
 Host.Ts.Sources.Inference.Layers.QuantizedLinear.ast_n24,
 Host.Ts.Sources.Mlx.Ops.ast_n133,
 Host.Ts.Sources.Mlx.Ops.ast_n131,
 Host.Ts.Sources.Mlx.Ffi.ast_n33,
 Host.Ts.Sources.Mlx.Ops.ast_n7,
 Host.Ts.Sources.Inference.Layers.QuantizedLinear.ast_n57,
 Host.Ts.Sources.Inference.Layers.Lora.ast_n72,
 Host.Ts.Sources.Inference.Layers.Lora.ast_n34,
 Host.Ts.Sources.Inference.Layers.CompiledNormalization.ast_n11,
 Host.Ts.Sources.Inference.Layers.Lora.ast_n99,
 Host.Ts.Sources.Inference.Models.Qwen.WrittenLayers.ast_n36,
 Host.Ts.Sources.Inference.Models.Qwen.WrittenLayers.ast_n51,
 Host.Ts.Sources.Inference.Layers.TrellisCodebookGateUp.ast_n20,
 Host.Ts.Sources.Inference.Kernels.Trellis.GateUpCodebook.ast_n18,
 Host.Ts.Sources.Mlx.Array.ast_n73,
 Host.Ts.Sources.Inference.Layers.TrellisCodebookDown.ast_n31,
 Host.Ts.Sources.Inference.Layers.TrellisCodebookDown.ast_n5,
 Host.Ts.Prelude.ast_n55,
 Host.Ts.Sources.Inference.Artifacts.Safetensors.ast_n26,
 Host.Ts.Sources.Inference.Layers.TrellisCodebookDown.ast_n29,
 Host.Ts.Sources.Inference.Kernels.Trellis.DownCodebook.ast_n26,
 Host.Ts.Sources.Inference.Kernels.Trellis.DownCodebook.ast_n16,
 Host.Ts.Sources.Mlx.Ops.ast_n11,
 Host.Ts.Sources.Mlx.Ops.ast_n9,
 Host.Ts.Sources.Inference.Runtime.GraphForward.ast_n39,
 Host.Ts.Sources.Inference.Runtime.GraphForward.ast_n6,
 Host.Ts.Sources.Inference.Runtime.GraphForward.ast_n3,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n322,
 Host.Ts.Sources.Inference.Layers.Normalization.ast_n2,
 Host.Ts.Sources.Mlx.Ops.ast_n71,
 Host.Ts.Sources.Mlx.Ops.ast_n69,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n113,
 Host.Ts.Sources.Inference.Layers.AffineVerifyLinear.ast_n14,
 Host.Ts.Sources.Inference.Kernels.Quantization.AffineRow.ast_n16,
 Host.Ts.Sources.Inference.Layers.Helpers.ast_n2,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n5,
 Host.Ts.Sources.Inference.State.Ssm.ast_n42,
 Host.Ts.Sources.Inference.State.Ssm.ast_n83,
 Host.Ts.Sources.Inference.State.Ssm.ast_n104,
 Host.Ts.Sources.Inference.State.Ssm.ast_n6,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n325,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n200,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n143,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n194,
 Host.Ts.Sources.Mlx.Ops.ast_n529,
 Host.Ts.Sources.Mlx.Ops.ast_n521,
 Host.Ts.Sources.Mlx.Ops.ast_n159,
 Host.Ts.Sources.Mlx.Ops.ast_n157,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n140,
 Host.Ts.Sources.Mlx.Ops.ast_n95,
 Host.Ts.Sources.Mlx.Ops.ast_n93,
 Host.Ts.Sources.Mlx.Ffi.ast_n39,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n155,
 Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast_n121,
 Host.Ts.Sources.Inference.Models.Gemma4.Blocks.ast_n0,
 Host.Ts.Sources.Inference.State.Kv.ast_n5,
 Host.Ts.Sources.Inference.State.Kv.ast_n72,
 Host.Ts.Sources.Mlx.Ops.ast_n354,
 Host.Ts.Sources.Mlx.Ops.ast_n352,
 Host.Ts.Sources.Inference.State.AttentionRead.ast_n67,
 Host.Ts.Sources.Inference.State.AttentionRead.ast_n61,
 Host.Ts.Sources.Mlx.Ops.ast_n111,
 Host.Ts.Sources.Mlx.Ops.ast_n109,
 Host.Ts.Sources.Inference.State.AttentionRead.ast_n65,
 Host.Ts.Sources.Inference.Generation.Scopes.ast_n20,
 Host.Ts.Sources.Mlx.Ops.ast_n19,
 Host.Ts.Sources.Mlx.Ops.ast_n17,
 Host.Ts.Sources.Inference.Runtime.GraphForward.ast_n18,
 Host.Ts.Sources.Mlx.Ops.ast_n395,
 Host.Ts.Sources.Inference.Layers.TrellisCodebookDown.ast_n24,
 Host.Ts.Sources.Inference.Layers.TrellisCodebookDown.ast_n22,
 Host.Ts.Sources.Inference.Kernels.Trellis.DownCodebook.ast_n21,
 Host.Ts.Sources.Inference.Runtime.GraphForward.ast_n25,
 Host.Ts.Sources.Inference.Runtime.GraphForward.ast_n27,
 Host.Ts.Sources.Inference.Generation.PhaseDispatch.ast_n54,
 Host.Ts.Sources.Inference.Generation.PhaseDispatch.ast_n18,
 Host.Ts.Sources.Inference.Runtime.RowOperations.ast_n8,
 Host.Ts.Sources.Inference.Models.Qwen.Qwen3827bTrellisM1max.ast_n194,
 Host.Ts.Sources.Inference.Generation.Autoregressive.ast_n68,
 Host.Ts.Sources.Inference.Sampling.Step.ast_n202,
 Host.Ts.Sources.Inference.Sampling.Step.ast_n113,
 Host.Ts.Sources.Inference.Kernels.Sampling.NormalizedArgmax.ast_n28,
 Host.Ts.Sources.Mlx.Compile.ast_n4,
 Host.Ts.Sources.Inference.Sampling.Extras.ast_n9,
 Host.Ts.Sources.Inference.Sampling.Extras.ast_n2,
 Host.Ts.Sources.Mlx.Ops.ast_n403,
 Host.Ts.Sources.Mlx.Array.ast_n79]
theorem called_functions_no_initializers : calledFunctions.all (fun f => noInitFunctions (functionStatements f)) = true := rfl
theorem concatAxis_no_initializers : noInitFunctions (functionStatements Host.Ts.Sources.Mlx.Ops.ast_n172) = true := rfl
end Host.Load.Run.Full.Ordinary
