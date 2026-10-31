import host.sim.compose.a4b.D1TypedData
import host.sim.template.a4pre_d1_stage_split.K3
import host.sim.template.a4pre_d1_dispatch.GenericDecode
import host.sim.template.a4pre_d1_dispatch.GenericPre
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split.ND
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
noncomputable def ndTys : List Val := [.str chars!"ptr", .str chars!"i32", .str chars!"i32"]
noncomputable def ndRest : List Val := [.ptr (.js 2673493) 0, natV 2, natV 7]
noncomputable def ndDecoded := interpS (decodeArgs FF D1StageSplit.s15 ndTys ndRest).run D1StageSplit.S15
noncomputable def ndArgs : List Arg := match ndDecoded with | some (some asR, _) => asR | _ => []
noncomputable def ndSrv : SSrv := match ndDecoded with | some (_, S) => S | _ => D1StageSplit.S15
kernel_rfl ndExact : Bridge.ndParts D1StageSplit.s15 = some (chars!"mlx_array_new_data", chars!"u64", ndTys, ndRest, 2673484)
kernel_rfl ndDecode : interpS (decodeArgs FF D1StageSplit.s15 ndTys ndRest).run D1StageSplit.S15 = some (some ndArgs, ndSrv)
kernel_rfl ndOk : G.dataOk setupP (mlxOf D1StageSplit.s15.ffi) ndArgs = true
kernel_rfl ndSmall : (G.dataRefs ndArgs).all (refSmallB loopVB ndSrv) = true
kernel_rfl ndBuffers : (fun bs : List Byte => Disp.allB (Disp.argBufB (D1Frames.typedJ bs) D1StageSplit.s15 D1StageSplit.S15.tab.length) ndRest) = fun _ => true
kernel_rfl ndBools : (fun bs : List Byte => Disp.boolsPB (D1Frames.typedJ bs) ndTys ndRest) = fun _ => true
noncomputable def sym : Nat := match D1StageSplit.s15.ctl with
  | .call (.obj a) _ _ => a
  | _ => 0
noncomputable def self : Val := match D1StageSplit.s15.ctl with
  | .call _ this _ => this
  | _ => .undef
noncomputable def sig : Nat := match (Host.Ts.Sim.Template.objOf D1StageSplit.s15 sym).kind with
  | .fn (.native (.ffi .symbol) [.str _, .obj a, .str _]) => a
  | _ => 0
kernel_rfl ctl : D1StageSplit.s15.ctl = .call (.obj sym) self (.ptr (.js D1Frames.buffer) 0 :: ndRest)
kernel_rfl fo : D1StageSplit.s15.obj? sym = some (Host.Ts.Sim.Template.objOf D1StageSplit.s15 sym)
kernel_rfl kind : (Host.Ts.Sim.Template.objOf D1StageSplit.s15 sym).kind =
  .fn (.native (.ffi .symbol) [.str chars!"mlx_array_new_data", .obj sig, .str chars!"u64"])
kernel_rfl signature : D1StageSplit.s15.obj? sig = some (Host.Ts.Sim.Template.objOf D1StageSplit.s15 sig)
kernel_rfl types : (Host.Ts.Sim.Template.objOf D1StageSplit.s15 sig).kind = .array (.str chars!"ptr" :: ndTys)
kernel_rfl sigUnframed : [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view].contains sig = false

theorem bools (K : Host.Ts.Sim.Ctx) :
    ∀ ty v, Val.str ty ∈ ndTys → v ∈ ndRest → BufSim.BoolOK K ty v := by
  intro ty v ht _
  simp only [ndTys, List.mem_cons, List.not_mem_nil, or_false, Val.str.injEq] at ht
  rcases ht with rfl | rfl | rfl <;> intro h <;> cases h

kernel_rfl oracle : Host.Ts.Sim.Lin.goodEnum Host.Ts.Sim.Lin.Cls.final_cold.r0.ps
  (Host.Ts.Sim.Lin.Cls.varsOf Host.Ts.Sim.Lin.Cls.final_cold.r0.V [(9, .L)]) D1StageSplit.S15.oracle = true

theorem sourceRun : interpS (Disp.newDataS FF D1StageSplit.s15 (chars!"mlx_array_new_data")
  (chars!"u64") ndTys ndRest D1Frames.buffer []).run D1StageSplit.S15 =
  some (D1StageSplit.s16, D1StageSplit.S16) := D1StageSplit.patchB6

end Host.Ts.Sim.Compose.D1Split.ND
