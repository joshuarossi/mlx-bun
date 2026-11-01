import host.sim.template.a4pre_d1_body.TraceStep
import host.sim.template.a4pre_d1_body.m.B00
import host.sim.Chunk
import host.sim.template.a4pre_d1_body.SizeLift

section -- SN230
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel230 : nth? D1BodySized.ks 230 = some 1936
kernel_rfl D1BodySized.checked230 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s230 D1BodySized.S230) =
    fun _ => some (D1BodySized.s231, D1BodySized.S231)

theorem D1BodySized.k230 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s230 D1BodySized.S230 =
      some (D1BodySized.s231, D1BodySized.S231) := congrFun D1BodySized.checked230 bs

end Host.Load.Run.Tpl
end

section -- SB67
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment67 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s230 D1BodySized.S230 =
      some (D1BodySized.s231, D1BodySized.S231) := D1BodySized.k230 bs

kernel_rfl D1BodySized.accepted67 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s230 D1BodySized.S230) = fun _ => true
kernel_rfl D1BodySized.oracle67 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S230.oracle = true
kernel_rfl D1BodySized.fuelA68 : nth? D1BodySized.ks 231 = some 1
kernel_rfl D1BodySized.fuelB68 : nth? D1BodySized.ks 232 = some 3
kernel_rfl D1BodySized.stepA68 : interpS (step D1BodySized.F D1BodySized.s231).run D1BodySized.S231 =
  some (D1BodySized.s232, D1BodySized.S232)
kernel_rfl D1BodySized.patchB68 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s232).run D1BodySized.S232 =
  some (D1BodySized.s233, D1BodySized.S233)
kernel_rfl D1BodySized.acceptedP68 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s231 D1BodySized.S231) = fun _ => true
kernel_rfl D1BodySized.haltP68 : isHalt D1BodySized.s231.ctl = false
kernel_rfl D1BodySized.topA68 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s232 = true
kernel_rfl D1BodySized.inactive68 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s232.ffi).active = false
/-- Bridge 68's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys68 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s232 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs68 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s232 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA68 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s232 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys68, D1BodySized.sizeArgs68)
kernel_rfl D1BodySized.sizeArgsA68 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s232 = true
kernel_rfl D1BodySized.sizeSymA68 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA68 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA68 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA68 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec68 := interpS (decodeArgs D1BodySized.F D1BodySized.s232 D1BodySized.sizeTys68 D1BodySized.sizeArgs68).run D1BodySized.S232
noncomputable def D1BodySized.sizeAs68 : List Arg := match D1BodySized.sizeDec68 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS068 : SSrv := match D1BodySized.sizeDec68 with | some (_, S) => S | none => D1BodySized.S232
kernel_rfl D1BodySized.sizeDecA68 : interpS (decodeArgs D1BodySized.F D1BodySized.s232 D1BodySized.sizeTys68 D1BodySized.sizeArgs68).run D1BodySized.S232 =
  some (some D1BodySized.sizeAs68, D1BodySized.sizeS068)
kernel_rfl D1BodySized.sizePreA68 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS068 D1BodySized.s232.ffi D1BodySized.sizeAs68 = true

end Host.Load.Run.Tpl
end

section -- SN233
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel233 : nth? D1BodySized.ks 233 = some 10000
kernel_rfl D1BodySized.checked233 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s233 D1BodySized.S233) =
    fun _ => some (D1BodySized.s234, D1BodySized.S234)

theorem D1BodySized.k233 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s233 D1BodySized.S233 =
      some (D1BodySized.s234, D1BodySized.S234) := congrFun D1BodySized.checked233 bs

end Host.Load.Run.Tpl
end

section -- SN234
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel234 : nth? D1BodySized.ks 234 = some 2570
kernel_rfl D1BodySized.checked234 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s234 D1BodySized.S234) =
    fun _ => some (D1BodySized.s235, D1BodySized.S235)

theorem D1BodySized.k234 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s234 D1BodySized.S234 =
      some (D1BodySized.s235, D1BodySized.S235) := congrFun D1BodySized.checked234 bs

end Host.Load.Run.Tpl
end

section -- SB68
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment68 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s233 D1BodySized.S233 =
      some (D1BodySized.s235, D1BodySized.S235) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s233 D1BodySized.s234 D1BodySized.s235 D1BodySized.S233 D1BodySized.S234 D1BodySized.S235 (D1BodySized.k233 bs) (D1BodySized.k234 bs)

kernel_rfl D1BodySized.accepted68 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s233 D1BodySized.S233) = fun _ => true
kernel_rfl D1BodySized.oracle68 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S233.oracle = true
kernel_rfl D1BodySized.fuelA69 : nth? D1BodySized.ks 235 = some 1
kernel_rfl D1BodySized.fuelB69 : nth? D1BodySized.ks 236 = some 3
kernel_rfl D1BodySized.stepA69 : interpS (step D1BodySized.F D1BodySized.s235).run D1BodySized.S235 =
  some (D1BodySized.s236, D1BodySized.S236)
kernel_rfl D1BodySized.patchB69 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s236).run D1BodySized.S236 =
  some (D1BodySized.s237, D1BodySized.S237)
kernel_rfl D1BodySized.acceptedP69 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s235 D1BodySized.S235) = fun _ => true
kernel_rfl D1BodySized.haltP69 : isHalt D1BodySized.s235.ctl = false
kernel_rfl D1BodySized.topA69 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s236 = true
kernel_rfl D1BodySized.inactive69 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s236.ffi).active = false
/-- Bridge 69's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys69 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s236 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs69 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s236 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA69 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s236 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys69, D1BodySized.sizeArgs69)
kernel_rfl D1BodySized.sizeArgsA69 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s236 = true
kernel_rfl D1BodySized.sizeSymA69 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA69 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA69 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA69 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec69 := interpS (decodeArgs D1BodySized.F D1BodySized.s236 D1BodySized.sizeTys69 D1BodySized.sizeArgs69).run D1BodySized.S236
noncomputable def D1BodySized.sizeAs69 : List Arg := match D1BodySized.sizeDec69 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS069 : SSrv := match D1BodySized.sizeDec69 with | some (_, S) => S | none => D1BodySized.S236
kernel_rfl D1BodySized.sizeDecA69 : interpS (decodeArgs D1BodySized.F D1BodySized.s236 D1BodySized.sizeTys69 D1BodySized.sizeArgs69).run D1BodySized.S236 =
  some (some D1BodySized.sizeAs69, D1BodySized.sizeS069)
kernel_rfl D1BodySized.sizePreA69 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS069 D1BodySized.s236.ffi D1BodySized.sizeAs69 = true

end Host.Load.Run.Tpl
end

section -- SN237
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel237 : nth? D1BodySized.ks 237 = some 2542
kernel_rfl D1BodySized.checked237 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s237 D1BodySized.S237) =
    fun _ => some (D1BodySized.s238, D1BodySized.S238)

theorem D1BodySized.k237 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s237 D1BodySized.S237 =
      some (D1BodySized.s238, D1BodySized.S238) := congrFun D1BodySized.checked237 bs

end Host.Load.Run.Tpl
end

section -- SB69
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment69 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s237 D1BodySized.S237 =
      some (D1BodySized.s238, D1BodySized.S238) := D1BodySized.k237 bs

kernel_rfl D1BodySized.accepted69 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s237 D1BodySized.S237) = fun _ => true
kernel_rfl D1BodySized.oracle69 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S237.oracle = true
kernel_rfl D1BodySized.fuelA70 : nth? D1BodySized.ks 238 = some 1
kernel_rfl D1BodySized.fuelB70 : nth? D1BodySized.ks 239 = some 3
kernel_rfl D1BodySized.stepA70 : interpS (step D1BodySized.F D1BodySized.s238).run D1BodySized.S238 =
  some (D1BodySized.s239, D1BodySized.S239)
kernel_rfl D1BodySized.patchB70 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s239).run D1BodySized.S239 =
  some (D1BodySized.s240, D1BodySized.S240)
kernel_rfl D1BodySized.acceptedP70 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s238 D1BodySized.S238) = fun _ => true
kernel_rfl D1BodySized.haltP70 : isHalt D1BodySized.s238.ctl = false
kernel_rfl D1BodySized.topA70 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s239 = true
kernel_rfl D1BodySized.inactive70 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s239.ffi).active = false
/-- Bridge 70's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys70 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s239 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs70 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s239 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA70 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s239 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys70, D1BodySized.sizeArgs70)
kernel_rfl D1BodySized.sizeArgsA70 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s239 = true
kernel_rfl D1BodySized.sizeSymA70 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA70 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA70 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA70 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec70 := interpS (decodeArgs D1BodySized.F D1BodySized.s239 D1BodySized.sizeTys70 D1BodySized.sizeArgs70).run D1BodySized.S239
noncomputable def D1BodySized.sizeAs70 : List Arg := match D1BodySized.sizeDec70 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS070 : SSrv := match D1BodySized.sizeDec70 with | some (_, S) => S | none => D1BodySized.S239
kernel_rfl D1BodySized.sizeDecA70 : interpS (decodeArgs D1BodySized.F D1BodySized.s239 D1BodySized.sizeTys70 D1BodySized.sizeArgs70).run D1BodySized.S239 =
  some (some D1BodySized.sizeAs70, D1BodySized.sizeS070)
kernel_rfl D1BodySized.sizePreA70 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS070 D1BodySized.s239.ffi D1BodySized.sizeAs70 = true

end Host.Load.Run.Tpl
end

section -- SN240
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel240 : nth? D1BodySized.ks 240 = some 10000
kernel_rfl D1BodySized.checked240 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s240 D1BodySized.S240) =
    fun _ => some (D1BodySized.s241, D1BodySized.S241)

theorem D1BodySized.k240 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s240 D1BodySized.S240 =
      some (D1BodySized.s241, D1BodySized.S241) := congrFun D1BodySized.checked240 bs

end Host.Load.Run.Tpl
end

section -- SN241
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel241 : nth? D1BodySized.ks 241 = some 10000
kernel_rfl D1BodySized.checked241 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s241 D1BodySized.S241) =
    fun _ => some (D1BodySized.s242, D1BodySized.S242)

theorem D1BodySized.k241 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s241 D1BodySized.S241 =
      some (D1BodySized.s242, D1BodySized.S242) := congrFun D1BodySized.checked241 bs

end Host.Load.Run.Tpl
end

section -- SN242
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel242 : nth? D1BodySized.ks 242 = some 2287
kernel_rfl D1BodySized.checked242 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s242 D1BodySized.S242) =
    fun _ => some (D1BodySized.s243, D1BodySized.S243)

theorem D1BodySized.k242 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s242 D1BodySized.S242 =
      some (D1BodySized.s243, D1BodySized.S243) := congrFun D1BodySized.checked242 bs

end Host.Load.Run.Tpl
end

section -- SB70
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment70 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22287 D1BodySized.s240 D1BodySized.S240 =
      some (D1BodySized.s243, D1BodySized.S243) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2287 D1BodySized.s240 D1BodySized.s242 D1BodySized.s243 D1BodySized.S240 D1BodySized.S242 D1BodySized.S243 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s240 D1BodySized.s241 D1BodySized.s242 D1BodySized.S240 D1BodySized.S241 D1BodySized.S242 (D1BodySized.k240 bs) (D1BodySized.k241 bs)) (D1BodySized.k242 bs)

kernel_rfl D1BodySized.accepted70 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s240 D1BodySized.S240) = fun _ => true
kernel_rfl D1BodySized.oracle70 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S240.oracle = true
kernel_rfl D1BodySized.fuelA71 : nth? D1BodySized.ks 243 = some 1
kernel_rfl D1BodySized.fuelB71 : nth? D1BodySized.ks 244 = some 3
kernel_rfl D1BodySized.stepA71 : interpS (step D1BodySized.F D1BodySized.s243).run D1BodySized.S243 =
  some (D1BodySized.s244, D1BodySized.S244)
kernel_rfl D1BodySized.patchB71 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s244).run D1BodySized.S244 =
  some (D1BodySized.s245, D1BodySized.S245)
kernel_rfl D1BodySized.acceptedP71 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s243 D1BodySized.S243) = fun _ => true
kernel_rfl D1BodySized.haltP71 : isHalt D1BodySized.s243.ctl = false
kernel_rfl D1BodySized.topA71 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s244 = true
kernel_rfl D1BodySized.inactive71 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s244.ffi).active = false
/-- Bridge 71's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys71 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s244 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs71 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s244 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA71 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s244 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys71, D1BodySized.sizeArgs71)
kernel_rfl D1BodySized.sizeArgsA71 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s244 = true
kernel_rfl D1BodySized.sizeSymA71 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA71 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA71 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA71 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec71 := interpS (decodeArgs D1BodySized.F D1BodySized.s244 D1BodySized.sizeTys71 D1BodySized.sizeArgs71).run D1BodySized.S244
noncomputable def D1BodySized.sizeAs71 : List Arg := match D1BodySized.sizeDec71 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS071 : SSrv := match D1BodySized.sizeDec71 with | some (_, S) => S | none => D1BodySized.S244
kernel_rfl D1BodySized.sizeDecA71 : interpS (decodeArgs D1BodySized.F D1BodySized.s244 D1BodySized.sizeTys71 D1BodySized.sizeArgs71).run D1BodySized.S244 =
  some (some D1BodySized.sizeAs71, D1BodySized.sizeS071)
kernel_rfl D1BodySized.sizePreA71 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS071 D1BodySized.s244.ffi D1BodySized.sizeAs71 = true

end Host.Load.Run.Tpl
end

section -- SN245
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel245 : nth? D1BodySized.ks 245 = some 7934
kernel_rfl D1BodySized.checked245 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s245 D1BodySized.S245) =
    fun _ => some (D1BodySized.s246, D1BodySized.S246)

theorem D1BodySized.k245 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s245 D1BodySized.S245 =
      some (D1BodySized.s246, D1BodySized.S246) := congrFun D1BodySized.checked245 bs

end Host.Load.Run.Tpl
end

section -- SB71
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment71 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s245 D1BodySized.S245 =
      some (D1BodySized.s246, D1BodySized.S246) := D1BodySized.k245 bs

kernel_rfl D1BodySized.accepted71 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s245 D1BodySized.S245) = fun _ => true
kernel_rfl D1BodySized.oracle71 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S245.oracle = true
kernel_rfl D1BodySized.fuelA72 : nth? D1BodySized.ks 246 = some 1
kernel_rfl D1BodySized.fuelB72 : nth? D1BodySized.ks 247 = some 3
kernel_rfl D1BodySized.stepA72 : interpS (step D1BodySized.F D1BodySized.s246).run D1BodySized.S246 =
  some (D1BodySized.s247, D1BodySized.S247)
kernel_rfl D1BodySized.patchB72 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s247).run D1BodySized.S247 =
  some (D1BodySized.s248, D1BodySized.S248)
kernel_rfl D1BodySized.acceptedP72 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s246 D1BodySized.S246) = fun _ => true
kernel_rfl D1BodySized.haltP72 : isHalt D1BodySized.s246.ctl = false
kernel_rfl D1BodySized.topA72 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s247 = true
kernel_rfl D1BodySized.inactive72 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s247.ffi).active = false
/-- Bridge 72's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys72 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s247 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs72 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s247 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA72 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s247 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys72, D1BodySized.sizeArgs72)
kernel_rfl D1BodySized.sizeArgsA72 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s247 = true
kernel_rfl D1BodySized.sizeSymA72 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA72 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA72 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA72 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec72 := interpS (decodeArgs D1BodySized.F D1BodySized.s247 D1BodySized.sizeTys72 D1BodySized.sizeArgs72).run D1BodySized.S247
noncomputable def D1BodySized.sizeAs72 : List Arg := match D1BodySized.sizeDec72 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS072 : SSrv := match D1BodySized.sizeDec72 with | some (_, S) => S | none => D1BodySized.S247
kernel_rfl D1BodySized.sizeDecA72 : interpS (decodeArgs D1BodySized.F D1BodySized.s247 D1BodySized.sizeTys72 D1BodySized.sizeArgs72).run D1BodySized.S247 =
  some (some D1BodySized.sizeAs72, D1BodySized.sizeS072)
kernel_rfl D1BodySized.sizePreA72 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS072 D1BodySized.s247.ffi D1BodySized.sizeAs72 = true

end Host.Load.Run.Tpl
end

section -- SN248
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel248 : nth? D1BodySized.ks 248 = some 1936
kernel_rfl D1BodySized.checked248 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s248 D1BodySized.S248) =
    fun _ => some (D1BodySized.s249, D1BodySized.S249)

theorem D1BodySized.k248 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s248 D1BodySized.S248 =
      some (D1BodySized.s249, D1BodySized.S249) := congrFun D1BodySized.checked248 bs

end Host.Load.Run.Tpl
end

section -- SB72
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment72 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s248 D1BodySized.S248 =
      some (D1BodySized.s249, D1BodySized.S249) := D1BodySized.k248 bs

kernel_rfl D1BodySized.accepted72 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s248 D1BodySized.S248) = fun _ => true
kernel_rfl D1BodySized.oracle72 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S248.oracle = true
kernel_rfl D1BodySized.fuelA73 : nth? D1BodySized.ks 249 = some 1
kernel_rfl D1BodySized.fuelB73 : nth? D1BodySized.ks 250 = some 3
kernel_rfl D1BodySized.stepA73 : interpS (step D1BodySized.F D1BodySized.s249).run D1BodySized.S249 =
  some (D1BodySized.s250, D1BodySized.S250)
kernel_rfl D1BodySized.patchB73 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s250).run D1BodySized.S250 =
  some (D1BodySized.s251, D1BodySized.S251)
kernel_rfl D1BodySized.acceptedP73 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s249 D1BodySized.S249) = fun _ => true
kernel_rfl D1BodySized.haltP73 : isHalt D1BodySized.s249.ctl = false
kernel_rfl D1BodySized.topA73 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s250 = true
kernel_rfl D1BodySized.inactive73 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s250.ffi).active = false
/-- Bridge 73's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys73 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s250 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs73 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s250 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA73 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s250 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys73, D1BodySized.sizeArgs73)
kernel_rfl D1BodySized.sizeArgsA73 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s250 = true
kernel_rfl D1BodySized.sizeSymA73 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA73 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA73 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA73 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec73 := interpS (decodeArgs D1BodySized.F D1BodySized.s250 D1BodySized.sizeTys73 D1BodySized.sizeArgs73).run D1BodySized.S250
noncomputable def D1BodySized.sizeAs73 : List Arg := match D1BodySized.sizeDec73 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS073 : SSrv := match D1BodySized.sizeDec73 with | some (_, S) => S | none => D1BodySized.S250
kernel_rfl D1BodySized.sizeDecA73 : interpS (decodeArgs D1BodySized.F D1BodySized.s250 D1BodySized.sizeTys73 D1BodySized.sizeArgs73).run D1BodySized.S250 =
  some (some D1BodySized.sizeAs73, D1BodySized.sizeS073)
kernel_rfl D1BodySized.sizePreA73 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS073 D1BodySized.s250.ffi D1BodySized.sizeAs73 = true

end Host.Load.Run.Tpl
end

section -- SN251
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel251 : nth? D1BodySized.ks 251 = some 10000
kernel_rfl D1BodySized.checked251 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s251 D1BodySized.S251) =
    fun _ => some (D1BodySized.s252, D1BodySized.S252)

theorem D1BodySized.k251 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s251 D1BodySized.S251 =
      some (D1BodySized.s252, D1BodySized.S252) := congrFun D1BodySized.checked251 bs

end Host.Load.Run.Tpl
end

section -- SN252
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel252 : nth? D1BodySized.ks 252 = some 2570
kernel_rfl D1BodySized.checked252 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s252 D1BodySized.S252) =
    fun _ => some (D1BodySized.s253, D1BodySized.S253)

theorem D1BodySized.k252 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s252 D1BodySized.S252 =
      some (D1BodySized.s253, D1BodySized.S253) := congrFun D1BodySized.checked252 bs

end Host.Load.Run.Tpl
end

section -- SB73
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment73 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s251 D1BodySized.S251 =
      some (D1BodySized.s253, D1BodySized.S253) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s251 D1BodySized.s252 D1BodySized.s253 D1BodySized.S251 D1BodySized.S252 D1BodySized.S253 (D1BodySized.k251 bs) (D1BodySized.k252 bs)

kernel_rfl D1BodySized.accepted73 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s251 D1BodySized.S251) = fun _ => true
kernel_rfl D1BodySized.oracle73 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S251.oracle = true
kernel_rfl D1BodySized.fuelA74 : nth? D1BodySized.ks 253 = some 1
kernel_rfl D1BodySized.fuelB74 : nth? D1BodySized.ks 254 = some 3
kernel_rfl D1BodySized.stepA74 : interpS (step D1BodySized.F D1BodySized.s253).run D1BodySized.S253 =
  some (D1BodySized.s254, D1BodySized.S254)
kernel_rfl D1BodySized.patchB74 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s254).run D1BodySized.S254 =
  some (D1BodySized.s255, D1BodySized.S255)
kernel_rfl D1BodySized.acceptedP74 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s253 D1BodySized.S253) = fun _ => true
kernel_rfl D1BodySized.haltP74 : isHalt D1BodySized.s253.ctl = false
kernel_rfl D1BodySized.topA74 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s254 = true
kernel_rfl D1BodySized.inactive74 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s254.ffi).active = false
/-- Bridge 74's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys74 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s254 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs74 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s254 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA74 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s254 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys74, D1BodySized.sizeArgs74)
kernel_rfl D1BodySized.sizeArgsA74 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s254 = true
kernel_rfl D1BodySized.sizeSymA74 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA74 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA74 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA74 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec74 := interpS (decodeArgs D1BodySized.F D1BodySized.s254 D1BodySized.sizeTys74 D1BodySized.sizeArgs74).run D1BodySized.S254
noncomputable def D1BodySized.sizeAs74 : List Arg := match D1BodySized.sizeDec74 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS074 : SSrv := match D1BodySized.sizeDec74 with | some (_, S) => S | none => D1BodySized.S254
kernel_rfl D1BodySized.sizeDecA74 : interpS (decodeArgs D1BodySized.F D1BodySized.s254 D1BodySized.sizeTys74 D1BodySized.sizeArgs74).run D1BodySized.S254 =
  some (some D1BodySized.sizeAs74, D1BodySized.sizeS074)
kernel_rfl D1BodySized.sizePreA74 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS074 D1BodySized.s254.ffi D1BodySized.sizeAs74 = true

end Host.Load.Run.Tpl
end

section -- SN255
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel255 : nth? D1BodySized.ks 255 = some 2542
kernel_rfl D1BodySized.checked255 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s255 D1BodySized.S255) =
    fun _ => some (D1BodySized.s256, D1BodySized.S256)

theorem D1BodySized.k255 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s255 D1BodySized.S255 =
      some (D1BodySized.s256, D1BodySized.S256) := congrFun D1BodySized.checked255 bs

end Host.Load.Run.Tpl
end

section -- SB74
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment74 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s255 D1BodySized.S255 =
      some (D1BodySized.s256, D1BodySized.S256) := D1BodySized.k255 bs

kernel_rfl D1BodySized.accepted74 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s255 D1BodySized.S255) = fun _ => true
kernel_rfl D1BodySized.oracle74 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S255.oracle = true
kernel_rfl D1BodySized.fuelA75 : nth? D1BodySized.ks 256 = some 1
kernel_rfl D1BodySized.fuelB75 : nth? D1BodySized.ks 257 = some 3
kernel_rfl D1BodySized.stepA75 : interpS (step D1BodySized.F D1BodySized.s256).run D1BodySized.S256 =
  some (D1BodySized.s257, D1BodySized.S257)
kernel_rfl D1BodySized.patchB75 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s257).run D1BodySized.S257 =
  some (D1BodySized.s258, D1BodySized.S258)
kernel_rfl D1BodySized.acceptedP75 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s256 D1BodySized.S256) = fun _ => true
kernel_rfl D1BodySized.haltP75 : isHalt D1BodySized.s256.ctl = false
kernel_rfl D1BodySized.topA75 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s257 = true
kernel_rfl D1BodySized.inactive75 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s257.ffi).active = false
/-- Bridge 75's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys75 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s257 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs75 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s257 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA75 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s257 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys75, D1BodySized.sizeArgs75)
kernel_rfl D1BodySized.sizeArgsA75 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s257 = true
kernel_rfl D1BodySized.sizeSymA75 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA75 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA75 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA75 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec75 := interpS (decodeArgs D1BodySized.F D1BodySized.s257 D1BodySized.sizeTys75 D1BodySized.sizeArgs75).run D1BodySized.S257
noncomputable def D1BodySized.sizeAs75 : List Arg := match D1BodySized.sizeDec75 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS075 : SSrv := match D1BodySized.sizeDec75 with | some (_, S) => S | none => D1BodySized.S257
kernel_rfl D1BodySized.sizeDecA75 : interpS (decodeArgs D1BodySized.F D1BodySized.s257 D1BodySized.sizeTys75 D1BodySized.sizeArgs75).run D1BodySized.S257 =
  some (some D1BodySized.sizeAs75, D1BodySized.sizeS075)
kernel_rfl D1BodySized.sizePreA75 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS075 D1BodySized.s257.ffi D1BodySized.sizeAs75 = true

end Host.Load.Run.Tpl
end

section -- SN258
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel258 : nth? D1BodySized.ks 258 = some 7716
kernel_rfl D1BodySized.checked258 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s258 D1BodySized.S258) =
    fun _ => some (D1BodySized.s259, D1BodySized.S259)

theorem D1BodySized.k258 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s258 D1BodySized.S258 =
      some (D1BodySized.s259, D1BodySized.S259) := congrFun D1BodySized.checked258 bs

end Host.Load.Run.Tpl
end

section -- SB75
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment75 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s258 D1BodySized.S258 =
      some (D1BodySized.s259, D1BodySized.S259) := D1BodySized.k258 bs

kernel_rfl D1BodySized.accepted75 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s258 D1BodySized.S258) = fun _ => true
kernel_rfl D1BodySized.oracle75 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S258.oracle = true
kernel_rfl D1BodySized.fuelA76 : nth? D1BodySized.ks 259 = some 1
kernel_rfl D1BodySized.fuelB76 : nth? D1BodySized.ks 260 = some 3
kernel_rfl D1BodySized.stepA76 : interpS (step D1BodySized.F D1BodySized.s259).run D1BodySized.S259 =
  some (D1BodySized.s260, D1BodySized.S260)
kernel_rfl D1BodySized.patchB76 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s260).run D1BodySized.S260 =
  some (D1BodySized.s261, D1BodySized.S261)
kernel_rfl D1BodySized.acceptedP76 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s259 D1BodySized.S259) = fun _ => true
kernel_rfl D1BodySized.haltP76 : isHalt D1BodySized.s259.ctl = false
kernel_rfl D1BodySized.topA76 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s260 = true
kernel_rfl D1BodySized.inactive76 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s260.ffi).active = false
/-- Bridge 76's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys76 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s260 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs76 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s260 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA76 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s260 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys76, D1BodySized.sizeArgs76)
kernel_rfl D1BodySized.sizeArgsA76 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s260 = true
kernel_rfl D1BodySized.sizeSymA76 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA76 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA76 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA76 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec76 := interpS (decodeArgs D1BodySized.F D1BodySized.s260 D1BodySized.sizeTys76 D1BodySized.sizeArgs76).run D1BodySized.S260
noncomputable def D1BodySized.sizeAs76 : List Arg := match D1BodySized.sizeDec76 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS076 : SSrv := match D1BodySized.sizeDec76 with | some (_, S) => S | none => D1BodySized.S260
kernel_rfl D1BodySized.sizeDecA76 : interpS (decodeArgs D1BodySized.F D1BodySized.s260 D1BodySized.sizeTys76 D1BodySized.sizeArgs76).run D1BodySized.S260 =
  some (some D1BodySized.sizeAs76, D1BodySized.sizeS076)
kernel_rfl D1BodySized.sizePreA76 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS076 D1BodySized.s260.ffi D1BodySized.sizeAs76 = true

end Host.Load.Run.Tpl
end

section -- SN261
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel261 : nth? D1BodySized.ks 261 = some 10000
kernel_rfl D1BodySized.checked261 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s261 D1BodySized.S261) =
    fun _ => some (D1BodySized.s262, D1BodySized.S262)

theorem D1BodySized.k261 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s261 D1BodySized.S261 =
      some (D1BodySized.s262, D1BodySized.S262) := congrFun D1BodySized.checked261 bs

end Host.Load.Run.Tpl
end

section -- SN262
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel262 : nth? D1BodySized.ks 262 = some 3407
kernel_rfl D1BodySized.checked262 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 3407 D1BodySized.s262 D1BodySized.S262) =
    fun _ => some (D1BodySized.s263, D1BodySized.S263)

theorem D1BodySized.k262 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 3407 D1BodySized.s262 D1BodySized.S262 =
      some (D1BodySized.s263, D1BodySized.S263) := congrFun D1BodySized.checked262 bs

end Host.Load.Run.Tpl
end

section -- SB76
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment76 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 13407 D1BodySized.s261 D1BodySized.S261 =
      some (D1BodySized.s263, D1BodySized.S263) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 3407 D1BodySized.s261 D1BodySized.s262 D1BodySized.s263 D1BodySized.S261 D1BodySized.S262 D1BodySized.S263 (D1BodySized.k261 bs) (D1BodySized.k262 bs)

kernel_rfl D1BodySized.accepted76 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s261 D1BodySized.S261) = fun _ => true
kernel_rfl D1BodySized.oracle76 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S261.oracle = true
kernel_rfl D1BodySized.fuelA77 : nth? D1BodySized.ks 263 = some 1
kernel_rfl D1BodySized.fuelB77 : nth? D1BodySized.ks 264 = some 3
kernel_rfl D1BodySized.stepA77 : interpS (step D1BodySized.F D1BodySized.s263).run D1BodySized.S263 =
  some (D1BodySized.s264, D1BodySized.S264)
kernel_rfl D1BodySized.patchB77 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s264).run D1BodySized.S264 =
  some (D1BodySized.s265, D1BodySized.S265)
kernel_rfl D1BodySized.acceptedP77 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s263 D1BodySized.S263) = fun _ => true
kernel_rfl D1BodySized.haltP77 : isHalt D1BodySized.s263.ctl = false
kernel_rfl D1BodySized.topA77 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s264 = true
kernel_rfl D1BodySized.inactive77 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s264.ffi).active = false
/-- Bridge 77's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys77 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s264 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs77 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s264 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA77 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s264 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys77, D1BodySized.sizeArgs77)
kernel_rfl D1BodySized.sizeArgsA77 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s264 = true
kernel_rfl D1BodySized.sizeSymA77 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA77 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA77 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA77 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec77 := interpS (decodeArgs D1BodySized.F D1BodySized.s264 D1BodySized.sizeTys77 D1BodySized.sizeArgs77).run D1BodySized.S264
noncomputable def D1BodySized.sizeAs77 : List Arg := match D1BodySized.sizeDec77 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS077 : SSrv := match D1BodySized.sizeDec77 with | some (_, S) => S | none => D1BodySized.S264
kernel_rfl D1BodySized.sizeDecA77 : interpS (decodeArgs D1BodySized.F D1BodySized.s264 D1BodySized.sizeTys77 D1BodySized.sizeArgs77).run D1BodySized.S264 =
  some (some D1BodySized.sizeAs77, D1BodySized.sizeS077)
kernel_rfl D1BodySized.sizePreA77 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS077 D1BodySized.s264.ffi D1BodySized.sizeAs77 = true

end Host.Load.Run.Tpl
end

section -- SN265
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel265 : nth? D1BodySized.ks 265 = some 2542
kernel_rfl D1BodySized.checked265 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s265 D1BodySized.S265) =
    fun _ => some (D1BodySized.s266, D1BodySized.S266)

theorem D1BodySized.k265 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s265 D1BodySized.S265 =
      some (D1BodySized.s266, D1BodySized.S266) := congrFun D1BodySized.checked265 bs

end Host.Load.Run.Tpl
end

section -- SB77
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment77 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s265 D1BodySized.S265 =
      some (D1BodySized.s266, D1BodySized.S266) := D1BodySized.k265 bs

kernel_rfl D1BodySized.accepted77 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s265 D1BodySized.S265) = fun _ => true
kernel_rfl D1BodySized.oracle77 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S265.oracle = true
kernel_rfl D1BodySized.fuelA78 : nth? D1BodySized.ks 266 = some 1
kernel_rfl D1BodySized.fuelB78 : nth? D1BodySized.ks 267 = some 3
kernel_rfl D1BodySized.stepA78 : interpS (step D1BodySized.F D1BodySized.s266).run D1BodySized.S266 =
  some (D1BodySized.s267, D1BodySized.S267)
kernel_rfl D1BodySized.patchB78 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s267).run D1BodySized.S267 =
  some (D1BodySized.s268, D1BodySized.S268)
kernel_rfl D1BodySized.acceptedP78 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s266 D1BodySized.S266) = fun _ => true
kernel_rfl D1BodySized.haltP78 : isHalt D1BodySized.s266.ctl = false
kernel_rfl D1BodySized.topA78 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s267 = true
kernel_rfl D1BodySized.inactive78 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s267.ffi).active = false
/-- Bridge 78's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys78 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s267 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs78 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s267 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA78 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s267 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys78, D1BodySized.sizeArgs78)
kernel_rfl D1BodySized.sizeArgsA78 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s267 = true
kernel_rfl D1BodySized.sizeSymA78 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA78 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA78 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA78 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec78 := interpS (decodeArgs D1BodySized.F D1BodySized.s267 D1BodySized.sizeTys78 D1BodySized.sizeArgs78).run D1BodySized.S267
noncomputable def D1BodySized.sizeAs78 : List Arg := match D1BodySized.sizeDec78 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS078 : SSrv := match D1BodySized.sizeDec78 with | some (_, S) => S | none => D1BodySized.S267
kernel_rfl D1BodySized.sizeDecA78 : interpS (decodeArgs D1BodySized.F D1BodySized.s267 D1BodySized.sizeTys78 D1BodySized.sizeArgs78).run D1BodySized.S267 =
  some (some D1BodySized.sizeAs78, D1BodySized.sizeS078)
kernel_rfl D1BodySized.sizePreA78 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS078 D1BodySized.s267.ffi D1BodySized.sizeAs78 = true

end Host.Load.Run.Tpl
end

section -- SN268
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel268 : nth? D1BodySized.ks 268 = some 7716
kernel_rfl D1BodySized.checked268 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s268 D1BodySized.S268) =
    fun _ => some (D1BodySized.s269, D1BodySized.S269)

theorem D1BodySized.k268 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s268 D1BodySized.S268 =
      some (D1BodySized.s269, D1BodySized.S269) := congrFun D1BodySized.checked268 bs

end Host.Load.Run.Tpl
end

section -- SB78
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment78 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s268 D1BodySized.S268 =
      some (D1BodySized.s269, D1BodySized.S269) := D1BodySized.k268 bs

kernel_rfl D1BodySized.accepted78 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s268 D1BodySized.S268) = fun _ => true
kernel_rfl D1BodySized.oracle78 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S268.oracle = true
kernel_rfl D1BodySized.fuelA79 : nth? D1BodySized.ks 269 = some 1
kernel_rfl D1BodySized.fuelB79 : nth? D1BodySized.ks 270 = some 3
kernel_rfl D1BodySized.stepA79 : interpS (step D1BodySized.F D1BodySized.s269).run D1BodySized.S269 =
  some (D1BodySized.s270, D1BodySized.S270)
kernel_rfl D1BodySized.patchB79 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s270).run D1BodySized.S270 =
  some (D1BodySized.s271, D1BodySized.S271)
kernel_rfl D1BodySized.acceptedP79 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s269 D1BodySized.S269) = fun _ => true
kernel_rfl D1BodySized.haltP79 : isHalt D1BodySized.s269.ctl = false
kernel_rfl D1BodySized.topA79 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s270 = true
kernel_rfl D1BodySized.inactive79 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s270.ffi).active = false
/-- Bridge 79's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys79 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s270 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs79 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s270 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA79 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s270 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys79, D1BodySized.sizeArgs79)
kernel_rfl D1BodySized.sizeArgsA79 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s270 = true
kernel_rfl D1BodySized.sizeSymA79 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA79 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA79 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA79 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec79 := interpS (decodeArgs D1BodySized.F D1BodySized.s270 D1BodySized.sizeTys79 D1BodySized.sizeArgs79).run D1BodySized.S270
noncomputable def D1BodySized.sizeAs79 : List Arg := match D1BodySized.sizeDec79 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS079 : SSrv := match D1BodySized.sizeDec79 with | some (_, S) => S | none => D1BodySized.S270
kernel_rfl D1BodySized.sizeDecA79 : interpS (decodeArgs D1BodySized.F D1BodySized.s270 D1BodySized.sizeTys79 D1BodySized.sizeArgs79).run D1BodySized.S270 =
  some (some D1BodySized.sizeAs79, D1BodySized.sizeS079)
kernel_rfl D1BodySized.sizePreA79 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS079 D1BodySized.s270.ffi D1BodySized.sizeAs79 = true

end Host.Load.Run.Tpl
end

section -- SN271
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel271 : nth? D1BodySized.ks 271 = some 1936
kernel_rfl D1BodySized.checked271 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s271 D1BodySized.S271) =
    fun _ => some (D1BodySized.s272, D1BodySized.S272)

theorem D1BodySized.k271 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s271 D1BodySized.S271 =
      some (D1BodySized.s272, D1BodySized.S272) := congrFun D1BodySized.checked271 bs

end Host.Load.Run.Tpl
end

section -- SB79
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment79 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s271 D1BodySized.S271 =
      some (D1BodySized.s272, D1BodySized.S272) := D1BodySized.k271 bs

kernel_rfl D1BodySized.accepted79 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s271 D1BodySized.S271) = fun _ => true
kernel_rfl D1BodySized.oracle79 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S271.oracle = true
kernel_rfl D1BodySized.fuelA80 : nth? D1BodySized.ks 272 = some 1
kernel_rfl D1BodySized.fuelB80 : nth? D1BodySized.ks 273 = some 3
kernel_rfl D1BodySized.stepA80 : interpS (step D1BodySized.F D1BodySized.s272).run D1BodySized.S272 =
  some (D1BodySized.s273, D1BodySized.S273)
kernel_rfl D1BodySized.patchB80 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s273).run D1BodySized.S273 =
  some (D1BodySized.s274, D1BodySized.S274)
kernel_rfl D1BodySized.acceptedP80 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s272 D1BodySized.S272) = fun _ => true
kernel_rfl D1BodySized.haltP80 : isHalt D1BodySized.s272.ctl = false
kernel_rfl D1BodySized.topA80 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s273 = true
kernel_rfl D1BodySized.inactive80 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s273.ffi).active = false
/-- Bridge 80's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys80 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s273 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs80 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s273 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA80 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s273 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys80, D1BodySized.sizeArgs80)
kernel_rfl D1BodySized.sizeArgsA80 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s273 = true
kernel_rfl D1BodySized.sizeSymA80 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA80 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA80 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA80 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec80 := interpS (decodeArgs D1BodySized.F D1BodySized.s273 D1BodySized.sizeTys80 D1BodySized.sizeArgs80).run D1BodySized.S273
noncomputable def D1BodySized.sizeAs80 : List Arg := match D1BodySized.sizeDec80 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS080 : SSrv := match D1BodySized.sizeDec80 with | some (_, S) => S | none => D1BodySized.S273
kernel_rfl D1BodySized.sizeDecA80 : interpS (decodeArgs D1BodySized.F D1BodySized.s273 D1BodySized.sizeTys80 D1BodySized.sizeArgs80).run D1BodySized.S273 =
  some (some D1BodySized.sizeAs80, D1BodySized.sizeS080)
kernel_rfl D1BodySized.sizePreA80 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS080 D1BodySized.s273.ffi D1BodySized.sizeAs80 = true

end Host.Load.Run.Tpl
end

section -- SN274
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel274 : nth? D1BodySized.ks 274 = some 10000
kernel_rfl D1BodySized.checked274 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s274 D1BodySized.S274) =
    fun _ => some (D1BodySized.s275, D1BodySized.S275)

theorem D1BodySized.k274 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s274 D1BodySized.S274 =
      some (D1BodySized.s275, D1BodySized.S275) := congrFun D1BodySized.checked274 bs

end Host.Load.Run.Tpl
end

section -- SN275
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel275 : nth? D1BodySized.ks 275 = some 2570
kernel_rfl D1BodySized.checked275 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s275 D1BodySized.S275) =
    fun _ => some (D1BodySized.s276, D1BodySized.S276)

theorem D1BodySized.k275 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s275 D1BodySized.S275 =
      some (D1BodySized.s276, D1BodySized.S276) := congrFun D1BodySized.checked275 bs

end Host.Load.Run.Tpl
end

section -- SB80
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment80 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s274 D1BodySized.S274 =
      some (D1BodySized.s276, D1BodySized.S276) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s274 D1BodySized.s275 D1BodySized.s276 D1BodySized.S274 D1BodySized.S275 D1BodySized.S276 (D1BodySized.k274 bs) (D1BodySized.k275 bs)

kernel_rfl D1BodySized.accepted80 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s274 D1BodySized.S274) = fun _ => true
kernel_rfl D1BodySized.oracle80 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S274.oracle = true
kernel_rfl D1BodySized.fuelA81 : nth? D1BodySized.ks 276 = some 1
kernel_rfl D1BodySized.fuelB81 : nth? D1BodySized.ks 277 = some 3
kernel_rfl D1BodySized.stepA81 : interpS (step D1BodySized.F D1BodySized.s276).run D1BodySized.S276 =
  some (D1BodySized.s277, D1BodySized.S277)
kernel_rfl D1BodySized.patchB81 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s277).run D1BodySized.S277 =
  some (D1BodySized.s278, D1BodySized.S278)
kernel_rfl D1BodySized.acceptedP81 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s276 D1BodySized.S276) = fun _ => true
kernel_rfl D1BodySized.haltP81 : isHalt D1BodySized.s276.ctl = false
kernel_rfl D1BodySized.topA81 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s277 = true
kernel_rfl D1BodySized.inactive81 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s277.ffi).active = false
/-- Bridge 81's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys81 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s277 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs81 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s277 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA81 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s277 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys81, D1BodySized.sizeArgs81)
kernel_rfl D1BodySized.sizeArgsA81 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s277 = true
kernel_rfl D1BodySized.sizeSymA81 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA81 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA81 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA81 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec81 := interpS (decodeArgs D1BodySized.F D1BodySized.s277 D1BodySized.sizeTys81 D1BodySized.sizeArgs81).run D1BodySized.S277
noncomputable def D1BodySized.sizeAs81 : List Arg := match D1BodySized.sizeDec81 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS081 : SSrv := match D1BodySized.sizeDec81 with | some (_, S) => S | none => D1BodySized.S277
kernel_rfl D1BodySized.sizeDecA81 : interpS (decodeArgs D1BodySized.F D1BodySized.s277 D1BodySized.sizeTys81 D1BodySized.sizeArgs81).run D1BodySized.S277 =
  some (some D1BodySized.sizeAs81, D1BodySized.sizeS081)
kernel_rfl D1BodySized.sizePreA81 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS081 D1BodySized.s277.ffi D1BodySized.sizeAs81 = true

end Host.Load.Run.Tpl
end

section -- SN278
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel278 : nth? D1BodySized.ks 278 = some 2542
kernel_rfl D1BodySized.checked278 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s278 D1BodySized.S278) =
    fun _ => some (D1BodySized.s279, D1BodySized.S279)

theorem D1BodySized.k278 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s278 D1BodySized.S278 =
      some (D1BodySized.s279, D1BodySized.S279) := congrFun D1BodySized.checked278 bs

end Host.Load.Run.Tpl
end

section -- SB81
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment81 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s278 D1BodySized.S278 =
      some (D1BodySized.s279, D1BodySized.S279) := D1BodySized.k278 bs

kernel_rfl D1BodySized.accepted81 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s278 D1BodySized.S278) = fun _ => true
kernel_rfl D1BodySized.oracle81 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S278.oracle = true
kernel_rfl D1BodySized.fuelA82 : nth? D1BodySized.ks 279 = some 1
kernel_rfl D1BodySized.fuelB82 : nth? D1BodySized.ks 280 = some 3
kernel_rfl D1BodySized.stepA82 : interpS (step D1BodySized.F D1BodySized.s279).run D1BodySized.S279 =
  some (D1BodySized.s280, D1BodySized.S280)
kernel_rfl D1BodySized.patchB82 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s280).run D1BodySized.S280 =
  some (D1BodySized.s281, D1BodySized.S281)
kernel_rfl D1BodySized.acceptedP82 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s279 D1BodySized.S279) = fun _ => true
kernel_rfl D1BodySized.haltP82 : isHalt D1BodySized.s279.ctl = false
kernel_rfl D1BodySized.topA82 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s280 = true
kernel_rfl D1BodySized.inactive82 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s280.ffi).active = false
/-- Bridge 82's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys82 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s280 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs82 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s280 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA82 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s280 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys82, D1BodySized.sizeArgs82)
kernel_rfl D1BodySized.sizeArgsA82 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s280 = true
kernel_rfl D1BodySized.sizeSymA82 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA82 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA82 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA82 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec82 := interpS (decodeArgs D1BodySized.F D1BodySized.s280 D1BodySized.sizeTys82 D1BodySized.sizeArgs82).run D1BodySized.S280
noncomputable def D1BodySized.sizeAs82 : List Arg := match D1BodySized.sizeDec82 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS082 : SSrv := match D1BodySized.sizeDec82 with | some (_, S) => S | none => D1BodySized.S280
kernel_rfl D1BodySized.sizeDecA82 : interpS (decodeArgs D1BodySized.F D1BodySized.s280 D1BodySized.sizeTys82 D1BodySized.sizeArgs82).run D1BodySized.S280 =
  some (some D1BodySized.sizeAs82, D1BodySized.sizeS082)
kernel_rfl D1BodySized.sizePreA82 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS082 D1BodySized.s280.ffi D1BodySized.sizeAs82 = true

end Host.Load.Run.Tpl
end

section -- SN281
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel281 : nth? D1BodySized.ks 281 = some 10000
kernel_rfl D1BodySized.checked281 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s281 D1BodySized.S281) =
    fun _ => some (D1BodySized.s282, D1BodySized.S282)

theorem D1BodySized.k281 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s281 D1BodySized.S281 =
      some (D1BodySized.s282, D1BodySized.S282) := congrFun D1BodySized.checked281 bs

end Host.Load.Run.Tpl
end

section -- SN282
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel282 : nth? D1BodySized.ks 282 = some 10000
kernel_rfl D1BodySized.checked282 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s282 D1BodySized.S282) =
    fun _ => some (D1BodySized.s283, D1BodySized.S283)

theorem D1BodySized.k282 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s282 D1BodySized.S282 =
      some (D1BodySized.s283, D1BodySized.S283) := congrFun D1BodySized.checked282 bs

end Host.Load.Run.Tpl
end

section -- SN283
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel283 : nth? D1BodySized.ks 283 = some 2287
kernel_rfl D1BodySized.checked283 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s283 D1BodySized.S283) =
    fun _ => some (D1BodySized.s284, D1BodySized.S284)

theorem D1BodySized.k283 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s283 D1BodySized.S283 =
      some (D1BodySized.s284, D1BodySized.S284) := congrFun D1BodySized.checked283 bs

end Host.Load.Run.Tpl
end

section -- SB82
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment82 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22287 D1BodySized.s281 D1BodySized.S281 =
      some (D1BodySized.s284, D1BodySized.S284) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2287 D1BodySized.s281 D1BodySized.s283 D1BodySized.s284 D1BodySized.S281 D1BodySized.S283 D1BodySized.S284 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s281 D1BodySized.s282 D1BodySized.s283 D1BodySized.S281 D1BodySized.S282 D1BodySized.S283 (D1BodySized.k281 bs) (D1BodySized.k282 bs)) (D1BodySized.k283 bs)

kernel_rfl D1BodySized.accepted82 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s281 D1BodySized.S281) = fun _ => true
kernel_rfl D1BodySized.oracle82 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S281.oracle = true
kernel_rfl D1BodySized.fuelA83 : nth? D1BodySized.ks 284 = some 1
kernel_rfl D1BodySized.fuelB83 : nth? D1BodySized.ks 285 = some 3
kernel_rfl D1BodySized.stepA83 : interpS (step D1BodySized.F D1BodySized.s284).run D1BodySized.S284 =
  some (D1BodySized.s285, D1BodySized.S285)
kernel_rfl D1BodySized.patchB83 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s285).run D1BodySized.S285 =
  some (D1BodySized.s286, D1BodySized.S286)
kernel_rfl D1BodySized.acceptedP83 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s284 D1BodySized.S284) = fun _ => true
kernel_rfl D1BodySized.haltP83 : isHalt D1BodySized.s284.ctl = false
kernel_rfl D1BodySized.topA83 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s285 = true
kernel_rfl D1BodySized.inactive83 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s285.ffi).active = false
/-- Bridge 83's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys83 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s285 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs83 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s285 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA83 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s285 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys83, D1BodySized.sizeArgs83)
kernel_rfl D1BodySized.sizeArgsA83 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s285 = true
kernel_rfl D1BodySized.sizeSymA83 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA83 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA83 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA83 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec83 := interpS (decodeArgs D1BodySized.F D1BodySized.s285 D1BodySized.sizeTys83 D1BodySized.sizeArgs83).run D1BodySized.S285
noncomputable def D1BodySized.sizeAs83 : List Arg := match D1BodySized.sizeDec83 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS083 : SSrv := match D1BodySized.sizeDec83 with | some (_, S) => S | none => D1BodySized.S285
kernel_rfl D1BodySized.sizeDecA83 : interpS (decodeArgs D1BodySized.F D1BodySized.s285 D1BodySized.sizeTys83 D1BodySized.sizeArgs83).run D1BodySized.S285 =
  some (some D1BodySized.sizeAs83, D1BodySized.sizeS083)
kernel_rfl D1BodySized.sizePreA83 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS083 D1BodySized.s285.ffi D1BodySized.sizeAs83 = true

end Host.Load.Run.Tpl
end

section -- SN286
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel286 : nth? D1BodySized.ks 286 = some 7934
kernel_rfl D1BodySized.checked286 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s286 D1BodySized.S286) =
    fun _ => some (D1BodySized.s287, D1BodySized.S287)

theorem D1BodySized.k286 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s286 D1BodySized.S286 =
      some (D1BodySized.s287, D1BodySized.S287) := congrFun D1BodySized.checked286 bs

end Host.Load.Run.Tpl
end

section -- SB83
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment83 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s286 D1BodySized.S286 =
      some (D1BodySized.s287, D1BodySized.S287) := D1BodySized.k286 bs

kernel_rfl D1BodySized.accepted83 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s286 D1BodySized.S286) = fun _ => true
kernel_rfl D1BodySized.oracle83 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S286.oracle = true
kernel_rfl D1BodySized.fuelA84 : nth? D1BodySized.ks 287 = some 1
kernel_rfl D1BodySized.fuelB84 : nth? D1BodySized.ks 288 = some 3
kernel_rfl D1BodySized.stepA84 : interpS (step D1BodySized.F D1BodySized.s287).run D1BodySized.S287 =
  some (D1BodySized.s288, D1BodySized.S288)
kernel_rfl D1BodySized.patchB84 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s288).run D1BodySized.S288 =
  some (D1BodySized.s289, D1BodySized.S289)
kernel_rfl D1BodySized.acceptedP84 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s287 D1BodySized.S287) = fun _ => true
kernel_rfl D1BodySized.haltP84 : isHalt D1BodySized.s287.ctl = false
kernel_rfl D1BodySized.topA84 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s288 = true
kernel_rfl D1BodySized.inactive84 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s288.ffi).active = false
/-- Bridge 84's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys84 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s288 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs84 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s288 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA84 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s288 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys84, D1BodySized.sizeArgs84)
kernel_rfl D1BodySized.sizeArgsA84 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s288 = true
kernel_rfl D1BodySized.sizeSymA84 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA84 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA84 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA84 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec84 := interpS (decodeArgs D1BodySized.F D1BodySized.s288 D1BodySized.sizeTys84 D1BodySized.sizeArgs84).run D1BodySized.S288
noncomputable def D1BodySized.sizeAs84 : List Arg := match D1BodySized.sizeDec84 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS084 : SSrv := match D1BodySized.sizeDec84 with | some (_, S) => S | none => D1BodySized.S288
kernel_rfl D1BodySized.sizeDecA84 : interpS (decodeArgs D1BodySized.F D1BodySized.s288 D1BodySized.sizeTys84 D1BodySized.sizeArgs84).run D1BodySized.S288 =
  some (some D1BodySized.sizeAs84, D1BodySized.sizeS084)
kernel_rfl D1BodySized.sizePreA84 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS084 D1BodySized.s288.ffi D1BodySized.sizeAs84 = true

end Host.Load.Run.Tpl
end

section -- SN289
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel289 : nth? D1BodySized.ks 289 = some 1936
kernel_rfl D1BodySized.checked289 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s289 D1BodySized.S289) =
    fun _ => some (D1BodySized.s290, D1BodySized.S290)

theorem D1BodySized.k289 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s289 D1BodySized.S289 =
      some (D1BodySized.s290, D1BodySized.S290) := congrFun D1BodySized.checked289 bs

end Host.Load.Run.Tpl
end

section -- SB84
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment84 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s289 D1BodySized.S289 =
      some (D1BodySized.s290, D1BodySized.S290) := D1BodySized.k289 bs

kernel_rfl D1BodySized.accepted84 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s289 D1BodySized.S289) = fun _ => true
kernel_rfl D1BodySized.oracle84 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S289.oracle = true
kernel_rfl D1BodySized.fuelA85 : nth? D1BodySized.ks 290 = some 1
kernel_rfl D1BodySized.fuelB85 : nth? D1BodySized.ks 291 = some 3
kernel_rfl D1BodySized.stepA85 : interpS (step D1BodySized.F D1BodySized.s290).run D1BodySized.S290 =
  some (D1BodySized.s291, D1BodySized.S291)
kernel_rfl D1BodySized.patchB85 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s291).run D1BodySized.S291 =
  some (D1BodySized.s292, D1BodySized.S292)
kernel_rfl D1BodySized.acceptedP85 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s290 D1BodySized.S290) = fun _ => true
kernel_rfl D1BodySized.haltP85 : isHalt D1BodySized.s290.ctl = false
kernel_rfl D1BodySized.topA85 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s291 = true
kernel_rfl D1BodySized.inactive85 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s291.ffi).active = false
/-- Bridge 85's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys85 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s291 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs85 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s291 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA85 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s291 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys85, D1BodySized.sizeArgs85)
kernel_rfl D1BodySized.sizeArgsA85 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s291 = true
kernel_rfl D1BodySized.sizeSymA85 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA85 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA85 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA85 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec85 := interpS (decodeArgs D1BodySized.F D1BodySized.s291 D1BodySized.sizeTys85 D1BodySized.sizeArgs85).run D1BodySized.S291
noncomputable def D1BodySized.sizeAs85 : List Arg := match D1BodySized.sizeDec85 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS085 : SSrv := match D1BodySized.sizeDec85 with | some (_, S) => S | none => D1BodySized.S291
kernel_rfl D1BodySized.sizeDecA85 : interpS (decodeArgs D1BodySized.F D1BodySized.s291 D1BodySized.sizeTys85 D1BodySized.sizeArgs85).run D1BodySized.S291 =
  some (some D1BodySized.sizeAs85, D1BodySized.sizeS085)
kernel_rfl D1BodySized.sizePreA85 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS085 D1BodySized.s291.ffi D1BodySized.sizeAs85 = true

end Host.Load.Run.Tpl
end
