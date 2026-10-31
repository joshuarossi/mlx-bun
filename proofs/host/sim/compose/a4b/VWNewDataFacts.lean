import host.sim.compose.a4b.VWTypedData
import host.sim.template.a4pre_first_tail_x15_r0.K8
import host.sim.template.a4pre_d1_dispatch.GenericDecode
import host.sim.template.a4pre_d1_dispatch.GenericPre
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.ND
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
noncomputable def ndTys : List Val := [.str chars!"ptr", .str chars!"i32", .str chars!"i32"]
noncomputable def ndRest : List Val := [.ptr (.js 2673481) 0, natV 2, natV 7]
noncomputable def ndDecoded := interpS (decodeArgs FF PRE_first_tail_x15_r0.s33 ndTys ndRest).run PRE_first_tail_x15_r0.S33
noncomputable def ndArgs : List Arg := match ndDecoded with | some (some asR, _) => asR | _ => []
noncomputable def ndSrv : SSrv := match ndDecoded with | some (_, S) => S | _ => PRE_first_tail_x15_r0.S33
kernel_rfl ndExact : Bridge.ndParts PRE_first_tail_x15_r0.s33 = some (chars!"mlx_array_new_data", chars!"u64", ndTys, ndRest, 2673472)
kernel_rfl ndDecode : interpS (decodeArgs FF PRE_first_tail_x15_r0.s33 ndTys ndRest).run PRE_first_tail_x15_r0.S33 = some (some ndArgs, ndSrv)
kernel_rfl ndOk : G.dataOk setupP (mlxOf PRE_first_tail_x15_r0.s33.ffi) ndArgs = true
kernel_rfl ndSmall : (G.dataRefs ndArgs).all (refSmallB loopVB ndSrv) = true
kernel_rfl ndBuffers : (fun (bs : List Byte) (n : Nat) => Disp.allB (Disp.argBufB (VWFrames.typedJ bs n) PRE_first_tail_x15_r0.s33 PRE_first_tail_x15_r0.S33.tab.length) ndRest) = fun _ _ => true
kernel_rfl ndBools : (fun (bs : List Byte) (n : Nat) => Disp.boolsPB (VWFrames.typedJ bs n) ndTys ndRest) = fun _ _ => true
noncomputable def sym : Nat := match PRE_first_tail_x15_r0.s33.ctl with
  | .call (.obj a) _ _ => a
  | _ => 0
noncomputable def self : Val := match PRE_first_tail_x15_r0.s33.ctl with
  | .call _ this _ => this
  | _ => .undef
noncomputable def sig : Nat := match (Host.Ts.Sim.Template.objOf PRE_first_tail_x15_r0.s33 sym).kind with
  | .fn (.native (.ffi .symbol) [.str _, .obj a, .str _]) => a
  | _ => 0
kernel_rfl ctl : PRE_first_tail_x15_r0.s33.ctl = .call (.obj sym) self (.ptr (.js VWFrames.buffer) 0 :: ndRest)
kernel_rfl fo : PRE_first_tail_x15_r0.s33.obj? sym = some (Host.Ts.Sim.Template.objOf PRE_first_tail_x15_r0.s33 sym)
kernel_rfl kind : (Host.Ts.Sim.Template.objOf PRE_first_tail_x15_r0.s33 sym).kind =
  .fn (.native (.ffi .symbol) [.str chars!"mlx_array_new_data", .obj sig, .str chars!"u64"])
kernel_rfl signature : PRE_first_tail_x15_r0.s33.obj? sig = some (Host.Ts.Sim.Template.objOf PRE_first_tail_x15_r0.s33 sig)
kernel_rfl types : (Host.Ts.Sim.Template.objOf PRE_first_tail_x15_r0.s33 sig).kind = .array (.str chars!"ptr" :: ndTys)
kernel_rfl sigUnframed : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].contains sig = false

theorem bools (K : Host.Ts.Sim.Ctx) :
    ∀ ty v, Val.str ty ∈ ndTys → v ∈ ndRest → BufSim.BoolOK K ty v := by
  intro ty v ht _
  simp only [ndTys, List.mem_cons, List.not_mem_nil, or_false, Val.str.injEq] at ht
  rcases ht with rfl | rfl | rfl <;> intro h <;> cases h

theorem sourceRun : interpS (Disp.newDataS FF PRE_first_tail_x15_r0.s33 (chars!"mlx_array_new_data")
  (chars!"u64") ndTys ndRest VWFrames.buffer []).run PRE_first_tail_x15_r0.S33 =
  some (PRE_first_tail_x15_r0.s34, PRE_first_tail_x15_r0.S34) := PRE_first_tail_x15_r0.patchB11

end Host.Ts.Sim.Compose.VWFirst.ND
