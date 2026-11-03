import host.sim.compose.a4b.fd_x4_L9.TypedData
import host.sim.template.a4pre_fd_x4_L9_r0.K0
import host.sim.template.a4pre_fd_x4_L9_r0.K1
import host.sim.template.a4pre_fd_x4_L9_r0.K2
import host.sim.template.a4pre_fd_x4_L9_r0.K3
import host.sim.template.a4pre_fd_x4_L9_r0.K4
import host.sim.template.a4pre_fd_x4_L9_r0.K5
import host.sim.template.a4pre_d1_dispatch.GenericDecode
import host.sim.template.a4pre_d1_dispatch.GenericPre
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L9.ND
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
noncomputable def ndTys : List Val := [.str chars!"ptr", .str chars!"i32", .str chars!"i32"]
noncomputable def ndRest : List Val := [.ptr (.js 2834745) 0, natV 2, natV 7]
noncomputable def ndDecoded := interpS (decodeArgs FF PRE_fd_x4_L9_r0.s16 ndTys ndRest).run PRE_fd_x4_L9_r0.S16
noncomputable def ndArgs : List Arg := match ndDecoded with | some (some asR, _) => asR | _ => []
noncomputable def ndSrv : SSrv := match ndDecoded with | some (_, S) => S | _ => PRE_fd_x4_L9_r0.S16
kernel_rfl ndExact : Bridge.ndParts PRE_fd_x4_L9_r0.s16 = some (chars!"mlx_array_new_data", chars!"u64", ndTys, ndRest, 2834736)
kernel_rfl ndDecode : interpS (decodeArgs FF PRE_fd_x4_L9_r0.s16 ndTys ndRest).run PRE_fd_x4_L9_r0.S16 = some (some ndArgs, ndSrv)
kernel_rfl ndOk : G.dataOk setupP (mlxOf PRE_fd_x4_L9_r0.s16.ffi) ndArgs = true
kernel_rfl ndSmall : (G.dataRefs ndArgs).all (refSmallB loopVB ndSrv) = true
kernel_rfl ndBuffers : (fun (bs : List Byte) (n : Nat) => Disp.allB (Disp.argBufB (FDX4L9Frames.typedJ bs n) PRE_fd_x4_L9_r0.s16 PRE_fd_x4_L9_r0.S16.tab.length) ndRest) = fun _ _ => true
kernel_rfl ndBools : (fun (bs : List Byte) (n : Nat) => Disp.boolsPB (FDX4L9Frames.typedJ bs n) ndTys ndRest) = fun _ _ => true
noncomputable def sym : Nat := match PRE_fd_x4_L9_r0.s16.ctl with
  | .call (.obj a) _ _ => a
  | _ => 0
noncomputable def self : Val := match PRE_fd_x4_L9_r0.s16.ctl with
  | .call _ this _ => this
  | _ => .undef
noncomputable def sig : Nat := match (Host.Ts.Sim.Template.objOf PRE_fd_x4_L9_r0.s16 sym).kind with
  | .fn (.native (.ffi .symbol) [.str _, .obj a, .str _]) => a
  | _ => 0
kernel_rfl ctl : PRE_fd_x4_L9_r0.s16.ctl = .call (.obj sym) self (.ptr (.js FDX4L9Frames.buffer) 0 :: ndRest)
kernel_rfl fo : PRE_fd_x4_L9_r0.s16.obj? sym = some (Host.Ts.Sim.Template.objOf PRE_fd_x4_L9_r0.s16 sym)
kernel_rfl kind : (Host.Ts.Sim.Template.objOf PRE_fd_x4_L9_r0.s16 sym).kind =
  .fn (.native (.ffi .symbol) [.str chars!"mlx_array_new_data", .obj sig, .str chars!"u64"])
kernel_rfl signature : PRE_fd_x4_L9_r0.s16.obj? sig = some (Host.Ts.Sim.Template.objOf PRE_fd_x4_L9_r0.s16 sig)
kernel_rfl types : (Host.Ts.Sim.Template.objOf PRE_fd_x4_L9_r0.s16 sig).kind = .array (.str chars!"ptr" :: ndTys)
kernel_rfl sigUnframed : (2665 :: 4910 :: (ghostPf ++ [FDX4L9Frames.chunk, FDX4L9Frames.buffer, FDX4L9Frames.view])).contains sig = false

theorem bools (K : Host.Ts.Sim.Ctx) :
    ∀ ty v, Val.str ty ∈ ndTys → v ∈ ndRest → BufSim.BoolOK K ty v := by
  intro ty v ht _
  simp only [ndTys, List.mem_cons, List.not_mem_nil, or_false, Val.str.injEq] at ht
  rcases ht with rfl | rfl | rfl <;> intro h <;> cases h

theorem sourceRun : interpS (Disp.newDataS FF PRE_fd_x4_L9_r0.s16 (chars!"mlx_array_new_data")
  (chars!"u64") ndTys ndRest FDX4L9Frames.buffer []).run PRE_fd_x4_L9_r0.S16 =
  some (PRE_fd_x4_L9_r0.s17, PRE_fd_x4_L9_r0.S17) := PRE_fd_x4_L9_r0.patchB6

end Host.Ts.Sim.Compose.FDX4L9.ND
