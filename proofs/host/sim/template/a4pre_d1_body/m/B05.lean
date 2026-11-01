import host.sim.template.a4pre_d1_body.m.B00
import host.sim.template.a4pre_d1_body.TraceStep
import host.sim.Chunk
import host.sim.template.a4pre_d1_body.SizeLift

section -- SN292
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel292 : nth? D1BodySized.ks 292 = some 10000
kernel_rfl D1BodySized.checked292 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s292 D1BodySized.S292) =
    fun _ => some (D1BodySized.s293, D1BodySized.S293)

theorem D1BodySized.k292 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s292 D1BodySized.S292 =
      some (D1BodySized.s293, D1BodySized.S293) := congrFun D1BodySized.checked292 bs

end Host.Load.Run.Tpl
end

section -- SN293
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel293 : nth? D1BodySized.ks 293 = some 2570
kernel_rfl D1BodySized.checked293 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s293 D1BodySized.S293) =
    fun _ => some (D1BodySized.s294, D1BodySized.S294)

theorem D1BodySized.k293 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s293 D1BodySized.S293 =
      some (D1BodySized.s294, D1BodySized.S294) := congrFun D1BodySized.checked293 bs

end Host.Load.Run.Tpl
end

section -- SB85
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment85 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s292 D1BodySized.S292 =
      some (D1BodySized.s294, D1BodySized.S294) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s292 D1BodySized.s293 D1BodySized.s294 D1BodySized.S292 D1BodySized.S293 D1BodySized.S294 (D1BodySized.k292 bs) (D1BodySized.k293 bs)

kernel_rfl D1BodySized.accepted85 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s292 D1BodySized.S292) = fun _ => true
kernel_rfl D1BodySized.oracle85 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S292.oracle = true
kernel_rfl D1BodySized.fuelA86 : nth? D1BodySized.ks 294 = some 1
kernel_rfl D1BodySized.fuelB86 : nth? D1BodySized.ks 295 = some 3
kernel_rfl D1BodySized.stepA86 : interpS (step D1BodySized.F D1BodySized.s294).run D1BodySized.S294 =
  some (D1BodySized.s295, D1BodySized.S295)
kernel_rfl D1BodySized.patchB86 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s295).run D1BodySized.S295 =
  some (D1BodySized.s296, D1BodySized.S296)
kernel_rfl D1BodySized.acceptedP86 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s294 D1BodySized.S294) = fun _ => true
kernel_rfl D1BodySized.haltP86 : isHalt D1BodySized.s294.ctl = false
kernel_rfl D1BodySized.topA86 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s295 = true
kernel_rfl D1BodySized.inactive86 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s295.ffi).active = false
/-- Bridge 86's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys86 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s295 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs86 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s295 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA86 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s295 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys86, D1BodySized.sizeArgs86)
kernel_rfl D1BodySized.sizeArgsA86 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s295 = true
kernel_rfl D1BodySized.sizeSymA86 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA86 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA86 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA86 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec86 := interpS (decodeArgs D1BodySized.F D1BodySized.s295 D1BodySized.sizeTys86 D1BodySized.sizeArgs86).run D1BodySized.S295
noncomputable def D1BodySized.sizeAs86 : List Arg := match D1BodySized.sizeDec86 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS086 : SSrv := match D1BodySized.sizeDec86 with | some (_, S) => S | none => D1BodySized.S295
kernel_rfl D1BodySized.sizeDecA86 : interpS (decodeArgs D1BodySized.F D1BodySized.s295 D1BodySized.sizeTys86 D1BodySized.sizeArgs86).run D1BodySized.S295 =
  some (some D1BodySized.sizeAs86, D1BodySized.sizeS086)
kernel_rfl D1BodySized.sizePreA86 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS086 D1BodySized.s295.ffi D1BodySized.sizeAs86 = true

end Host.Load.Run.Tpl
end

section -- SN296
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel296 : nth? D1BodySized.ks 296 = some 2542
kernel_rfl D1BodySized.checked296 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s296 D1BodySized.S296) =
    fun _ => some (D1BodySized.s297, D1BodySized.S297)

theorem D1BodySized.k296 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s296 D1BodySized.S296 =
      some (D1BodySized.s297, D1BodySized.S297) := congrFun D1BodySized.checked296 bs

end Host.Load.Run.Tpl
end

section -- SB86
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment86 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s296 D1BodySized.S296 =
      some (D1BodySized.s297, D1BodySized.S297) := D1BodySized.k296 bs

kernel_rfl D1BodySized.accepted86 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s296 D1BodySized.S296) = fun _ => true
kernel_rfl D1BodySized.oracle86 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S296.oracle = true
kernel_rfl D1BodySized.fuelA87 : nth? D1BodySized.ks 297 = some 1
kernel_rfl D1BodySized.fuelB87 : nth? D1BodySized.ks 298 = some 3
kernel_rfl D1BodySized.stepA87 : interpS (step D1BodySized.F D1BodySized.s297).run D1BodySized.S297 =
  some (D1BodySized.s298, D1BodySized.S298)
kernel_rfl D1BodySized.patchB87 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s298).run D1BodySized.S298 =
  some (D1BodySized.s299, D1BodySized.S299)
kernel_rfl D1BodySized.acceptedP87 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s297 D1BodySized.S297) = fun _ => true
kernel_rfl D1BodySized.haltP87 : isHalt D1BodySized.s297.ctl = false
kernel_rfl D1BodySized.topA87 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s298 = true
kernel_rfl D1BodySized.inactive87 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s298.ffi).active = false
/-- Bridge 87's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys87 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s298 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs87 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s298 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA87 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s298 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys87, D1BodySized.sizeArgs87)
kernel_rfl D1BodySized.sizeArgsA87 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s298 = true
kernel_rfl D1BodySized.sizeSymA87 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA87 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA87 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA87 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec87 := interpS (decodeArgs D1BodySized.F D1BodySized.s298 D1BodySized.sizeTys87 D1BodySized.sizeArgs87).run D1BodySized.S298
noncomputable def D1BodySized.sizeAs87 : List Arg := match D1BodySized.sizeDec87 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS087 : SSrv := match D1BodySized.sizeDec87 with | some (_, S) => S | none => D1BodySized.S298
kernel_rfl D1BodySized.sizeDecA87 : interpS (decodeArgs D1BodySized.F D1BodySized.s298 D1BodySized.sizeTys87 D1BodySized.sizeArgs87).run D1BodySized.S298 =
  some (some D1BodySized.sizeAs87, D1BodySized.sizeS087)
kernel_rfl D1BodySized.sizePreA87 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS087 D1BodySized.s298.ffi D1BodySized.sizeAs87 = true

end Host.Load.Run.Tpl
end

section -- SN299
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel299 : nth? D1BodySized.ks 299 = some 7716
kernel_rfl D1BodySized.checked299 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s299 D1BodySized.S299) =
    fun _ => some (D1BodySized.s300, D1BodySized.S300)

theorem D1BodySized.k299 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s299 D1BodySized.S299 =
      some (D1BodySized.s300, D1BodySized.S300) := congrFun D1BodySized.checked299 bs

end Host.Load.Run.Tpl
end

section -- SB87
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment87 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s299 D1BodySized.S299 =
      some (D1BodySized.s300, D1BodySized.S300) := D1BodySized.k299 bs

kernel_rfl D1BodySized.accepted87 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s299 D1BodySized.S299) = fun _ => true
kernel_rfl D1BodySized.oracle87 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S299.oracle = true
kernel_rfl D1BodySized.fuelA88 : nth? D1BodySized.ks 300 = some 1
kernel_rfl D1BodySized.fuelB88 : nth? D1BodySized.ks 301 = some 3
kernel_rfl D1BodySized.stepA88 : interpS (step D1BodySized.F D1BodySized.s300).run D1BodySized.S300 =
  some (D1BodySized.s301, D1BodySized.S301)
kernel_rfl D1BodySized.patchB88 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s301).run D1BodySized.S301 =
  some (D1BodySized.s302, D1BodySized.S302)
kernel_rfl D1BodySized.acceptedP88 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s300 D1BodySized.S300) = fun _ => true
kernel_rfl D1BodySized.haltP88 : isHalt D1BodySized.s300.ctl = false
kernel_rfl D1BodySized.topA88 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s301 = true
kernel_rfl D1BodySized.inactive88 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s301.ffi).active = false
/-- Bridge 88's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys88 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s301 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs88 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s301 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA88 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s301 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys88, D1BodySized.sizeArgs88)
kernel_rfl D1BodySized.sizeArgsA88 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s301 = true
kernel_rfl D1BodySized.sizeSymA88 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA88 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA88 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA88 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec88 := interpS (decodeArgs D1BodySized.F D1BodySized.s301 D1BodySized.sizeTys88 D1BodySized.sizeArgs88).run D1BodySized.S301
noncomputable def D1BodySized.sizeAs88 : List Arg := match D1BodySized.sizeDec88 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS088 : SSrv := match D1BodySized.sizeDec88 with | some (_, S) => S | none => D1BodySized.S301
kernel_rfl D1BodySized.sizeDecA88 : interpS (decodeArgs D1BodySized.F D1BodySized.s301 D1BodySized.sizeTys88 D1BodySized.sizeArgs88).run D1BodySized.S301 =
  some (some D1BodySized.sizeAs88, D1BodySized.sizeS088)
kernel_rfl D1BodySized.sizePreA88 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS088 D1BodySized.s301.ffi D1BodySized.sizeAs88 = true

end Host.Load.Run.Tpl
end

section -- SN302
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel302 : nth? D1BodySized.ks 302 = some 1936
kernel_rfl D1BodySized.checked302 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s302 D1BodySized.S302) =
    fun _ => some (D1BodySized.s303, D1BodySized.S303)

theorem D1BodySized.k302 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s302 D1BodySized.S302 =
      some (D1BodySized.s303, D1BodySized.S303) := congrFun D1BodySized.checked302 bs

end Host.Load.Run.Tpl
end

section -- SB88
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment88 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s302 D1BodySized.S302 =
      some (D1BodySized.s303, D1BodySized.S303) := D1BodySized.k302 bs

kernel_rfl D1BodySized.accepted88 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s302 D1BodySized.S302) = fun _ => true
kernel_rfl D1BodySized.oracle88 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S302.oracle = true
kernel_rfl D1BodySized.fuelA89 : nth? D1BodySized.ks 303 = some 1
kernel_rfl D1BodySized.fuelB89 : nth? D1BodySized.ks 304 = some 3
kernel_rfl D1BodySized.stepA89 : interpS (step D1BodySized.F D1BodySized.s303).run D1BodySized.S303 =
  some (D1BodySized.s304, D1BodySized.S304)
kernel_rfl D1BodySized.patchB89 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s304).run D1BodySized.S304 =
  some (D1BodySized.s305, D1BodySized.S305)
kernel_rfl D1BodySized.acceptedP89 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s303 D1BodySized.S303) = fun _ => true
kernel_rfl D1BodySized.haltP89 : isHalt D1BodySized.s303.ctl = false
kernel_rfl D1BodySized.topA89 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s304 = true
kernel_rfl D1BodySized.inactive89 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s304.ffi).active = false
/-- Bridge 89's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys89 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s304 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs89 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s304 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA89 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s304 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys89, D1BodySized.sizeArgs89)
kernel_rfl D1BodySized.sizeArgsA89 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s304 = true
kernel_rfl D1BodySized.sizeSymA89 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA89 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA89 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA89 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec89 := interpS (decodeArgs D1BodySized.F D1BodySized.s304 D1BodySized.sizeTys89 D1BodySized.sizeArgs89).run D1BodySized.S304
noncomputable def D1BodySized.sizeAs89 : List Arg := match D1BodySized.sizeDec89 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS089 : SSrv := match D1BodySized.sizeDec89 with | some (_, S) => S | none => D1BodySized.S304
kernel_rfl D1BodySized.sizeDecA89 : interpS (decodeArgs D1BodySized.F D1BodySized.s304 D1BodySized.sizeTys89 D1BodySized.sizeArgs89).run D1BodySized.S304 =
  some (some D1BodySized.sizeAs89, D1BodySized.sizeS089)
kernel_rfl D1BodySized.sizePreA89 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS089 D1BodySized.s304.ffi D1BodySized.sizeAs89 = true

end Host.Load.Run.Tpl
end

section -- SN305
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel305 : nth? D1BodySized.ks 305 = some 10000
kernel_rfl D1BodySized.checked305 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s305 D1BodySized.S305) =
    fun _ => some (D1BodySized.s306, D1BodySized.S306)

theorem D1BodySized.k305 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s305 D1BodySized.S305 =
      some (D1BodySized.s306, D1BodySized.S306) := congrFun D1BodySized.checked305 bs

end Host.Load.Run.Tpl
end

section -- SN306
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel306 : nth? D1BodySized.ks 306 = some 2570
kernel_rfl D1BodySized.checked306 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s306 D1BodySized.S306) =
    fun _ => some (D1BodySized.s307, D1BodySized.S307)

theorem D1BodySized.k306 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s306 D1BodySized.S306 =
      some (D1BodySized.s307, D1BodySized.S307) := congrFun D1BodySized.checked306 bs

end Host.Load.Run.Tpl
end

section -- SB89
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment89 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s305 D1BodySized.S305 =
      some (D1BodySized.s307, D1BodySized.S307) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s305 D1BodySized.s306 D1BodySized.s307 D1BodySized.S305 D1BodySized.S306 D1BodySized.S307 (D1BodySized.k305 bs) (D1BodySized.k306 bs)

kernel_rfl D1BodySized.accepted89 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s305 D1BodySized.S305) = fun _ => true
kernel_rfl D1BodySized.oracle89 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S305.oracle = true
kernel_rfl D1BodySized.fuelA90 : nth? D1BodySized.ks 307 = some 1
kernel_rfl D1BodySized.fuelB90 : nth? D1BodySized.ks 308 = some 3
kernel_rfl D1BodySized.stepA90 : interpS (step D1BodySized.F D1BodySized.s307).run D1BodySized.S307 =
  some (D1BodySized.s308, D1BodySized.S308)
kernel_rfl D1BodySized.patchB90 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s308).run D1BodySized.S308 =
  some (D1BodySized.s309, D1BodySized.S309)
kernel_rfl D1BodySized.acceptedP90 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s307 D1BodySized.S307) = fun _ => true
kernel_rfl D1BodySized.haltP90 : isHalt D1BodySized.s307.ctl = false
kernel_rfl D1BodySized.topA90 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s308 = true
kernel_rfl D1BodySized.inactive90 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s308.ffi).active = false
/-- Bridge 90's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys90 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s308 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs90 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s308 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA90 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s308 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys90, D1BodySized.sizeArgs90)
kernel_rfl D1BodySized.sizeArgsA90 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s308 = true
kernel_rfl D1BodySized.sizeSymA90 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA90 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA90 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA90 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec90 := interpS (decodeArgs D1BodySized.F D1BodySized.s308 D1BodySized.sizeTys90 D1BodySized.sizeArgs90).run D1BodySized.S308
noncomputable def D1BodySized.sizeAs90 : List Arg := match D1BodySized.sizeDec90 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS090 : SSrv := match D1BodySized.sizeDec90 with | some (_, S) => S | none => D1BodySized.S308
kernel_rfl D1BodySized.sizeDecA90 : interpS (decodeArgs D1BodySized.F D1BodySized.s308 D1BodySized.sizeTys90 D1BodySized.sizeArgs90).run D1BodySized.S308 =
  some (some D1BodySized.sizeAs90, D1BodySized.sizeS090)
kernel_rfl D1BodySized.sizePreA90 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS090 D1BodySized.s308.ffi D1BodySized.sizeAs90 = true

end Host.Load.Run.Tpl
end

section -- SN309
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel309 : nth? D1BodySized.ks 309 = some 2542
kernel_rfl D1BodySized.checked309 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s309 D1BodySized.S309) =
    fun _ => some (D1BodySized.s310, D1BodySized.S310)

theorem D1BodySized.k309 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s309 D1BodySized.S309 =
      some (D1BodySized.s310, D1BodySized.S310) := congrFun D1BodySized.checked309 bs

end Host.Load.Run.Tpl
end

section -- SB90
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment90 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s309 D1BodySized.S309 =
      some (D1BodySized.s310, D1BodySized.S310) := D1BodySized.k309 bs

kernel_rfl D1BodySized.accepted90 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s309 D1BodySized.S309) = fun _ => true
kernel_rfl D1BodySized.oracle90 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S309.oracle = true
kernel_rfl D1BodySized.fuelA91 : nth? D1BodySized.ks 310 = some 1
kernel_rfl D1BodySized.fuelB91 : nth? D1BodySized.ks 311 = some 3
kernel_rfl D1BodySized.stepA91 : interpS (step D1BodySized.F D1BodySized.s310).run D1BodySized.S310 =
  some (D1BodySized.s311, D1BodySized.S311)
kernel_rfl D1BodySized.patchB91 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s311).run D1BodySized.S311 =
  some (D1BodySized.s312, D1BodySized.S312)
kernel_rfl D1BodySized.acceptedP91 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s310 D1BodySized.S310) = fun _ => true
kernel_rfl D1BodySized.haltP91 : isHalt D1BodySized.s310.ctl = false
kernel_rfl D1BodySized.topA91 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s311 = true
kernel_rfl D1BodySized.inactive91 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s311.ffi).active = false
/-- Bridge 91's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys91 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s311 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs91 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s311 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA91 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s311 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys91, D1BodySized.sizeArgs91)
kernel_rfl D1BodySized.sizeArgsA91 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s311 = true
kernel_rfl D1BodySized.sizeSymA91 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA91 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA91 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA91 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec91 := interpS (decodeArgs D1BodySized.F D1BodySized.s311 D1BodySized.sizeTys91 D1BodySized.sizeArgs91).run D1BodySized.S311
noncomputable def D1BodySized.sizeAs91 : List Arg := match D1BodySized.sizeDec91 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS091 : SSrv := match D1BodySized.sizeDec91 with | some (_, S) => S | none => D1BodySized.S311
kernel_rfl D1BodySized.sizeDecA91 : interpS (decodeArgs D1BodySized.F D1BodySized.s311 D1BodySized.sizeTys91 D1BodySized.sizeArgs91).run D1BodySized.S311 =
  some (some D1BodySized.sizeAs91, D1BodySized.sizeS091)
kernel_rfl D1BodySized.sizePreA91 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS091 D1BodySized.s311.ffi D1BodySized.sizeAs91 = true

end Host.Load.Run.Tpl
end

section -- SN312
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel312 : nth? D1BodySized.ks 312 = some 7762
kernel_rfl D1BodySized.checked312 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s312 D1BodySized.S312) =
    fun _ => some (D1BodySized.s313, D1BodySized.S313)

theorem D1BodySized.k312 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s312 D1BodySized.S312 =
      some (D1BodySized.s313, D1BodySized.S313) := congrFun D1BodySized.checked312 bs

end Host.Load.Run.Tpl
end

section -- SB91
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment91 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s312 D1BodySized.S312 =
      some (D1BodySized.s313, D1BodySized.S313) := D1BodySized.k312 bs

kernel_rfl D1BodySized.accepted91 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s312 D1BodySized.S312) = fun _ => true
kernel_rfl D1BodySized.oracle91 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S312.oracle = true
kernel_rfl D1BodySized.fuelA92 : nth? D1BodySized.ks 313 = some 1
kernel_rfl D1BodySized.fuelB92 : nth? D1BodySized.ks 314 = some 3
kernel_rfl D1BodySized.stepA92 : interpS (step D1BodySized.F D1BodySized.s313).run D1BodySized.S313 =
  some (D1BodySized.s314, D1BodySized.S314)
kernel_rfl D1BodySized.patchB92 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s314).run D1BodySized.S314 =
  some (D1BodySized.s315, D1BodySized.S315)
kernel_rfl D1BodySized.acceptedP92 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s313 D1BodySized.S313) = fun _ => true
kernel_rfl D1BodySized.haltP92 : isHalt D1BodySized.s313.ctl = false
kernel_rfl D1BodySized.topA92 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s314 = true
kernel_rfl D1BodySized.inactive92 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s314.ffi).active = false
/-- Bridge 92's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys92 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s314 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs92 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s314 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA92 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s314 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys92, D1BodySized.sizeArgs92)
kernel_rfl D1BodySized.sizeArgsA92 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s314 = true
kernel_rfl D1BodySized.sizeSymA92 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA92 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA92 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA92 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec92 := interpS (decodeArgs D1BodySized.F D1BodySized.s314 D1BodySized.sizeTys92 D1BodySized.sizeArgs92).run D1BodySized.S314
noncomputable def D1BodySized.sizeAs92 : List Arg := match D1BodySized.sizeDec92 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS092 : SSrv := match D1BodySized.sizeDec92 with | some (_, S) => S | none => D1BodySized.S314
kernel_rfl D1BodySized.sizeDecA92 : interpS (decodeArgs D1BodySized.F D1BodySized.s314 D1BodySized.sizeTys92 D1BodySized.sizeArgs92).run D1BodySized.S314 =
  some (some D1BodySized.sizeAs92, D1BodySized.sizeS092)
kernel_rfl D1BodySized.sizePreA92 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS092 D1BodySized.s314.ffi D1BodySized.sizeAs92 = true

end Host.Load.Run.Tpl
end

section -- SN315
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel315 : nth? D1BodySized.ks 315 = some 1936
kernel_rfl D1BodySized.checked315 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s315 D1BodySized.S315) =
    fun _ => some (D1BodySized.s316, D1BodySized.S316)

theorem D1BodySized.k315 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s315 D1BodySized.S315 =
      some (D1BodySized.s316, D1BodySized.S316) := congrFun D1BodySized.checked315 bs

end Host.Load.Run.Tpl
end

section -- SB92
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment92 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s315 D1BodySized.S315 =
      some (D1BodySized.s316, D1BodySized.S316) := D1BodySized.k315 bs

kernel_rfl D1BodySized.accepted92 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s315 D1BodySized.S315) = fun _ => true
kernel_rfl D1BodySized.oracle92 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S315.oracle = true
kernel_rfl D1BodySized.fuelA93 : nth? D1BodySized.ks 316 = some 1
kernel_rfl D1BodySized.fuelB93 : nth? D1BodySized.ks 317 = some 3
kernel_rfl D1BodySized.stepA93 : interpS (step D1BodySized.F D1BodySized.s316).run D1BodySized.S316 =
  some (D1BodySized.s317, D1BodySized.S317)
kernel_rfl D1BodySized.patchB93 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s317).run D1BodySized.S317 =
  some (D1BodySized.s318, D1BodySized.S318)
kernel_rfl D1BodySized.acceptedP93 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s316 D1BodySized.S316) = fun _ => true
kernel_rfl D1BodySized.haltP93 : isHalt D1BodySized.s316.ctl = false
kernel_rfl D1BodySized.topA93 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s317 = true
kernel_rfl D1BodySized.inactive93 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s317.ffi).active = false
/-- Bridge 93's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys93 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s317 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs93 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s317 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA93 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s317 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys93, D1BodySized.sizeArgs93)
kernel_rfl D1BodySized.sizeArgsA93 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s317 = true
kernel_rfl D1BodySized.sizeSymA93 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA93 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA93 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA93 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec93 := interpS (decodeArgs D1BodySized.F D1BodySized.s317 D1BodySized.sizeTys93 D1BodySized.sizeArgs93).run D1BodySized.S317
noncomputable def D1BodySized.sizeAs93 : List Arg := match D1BodySized.sizeDec93 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS093 : SSrv := match D1BodySized.sizeDec93 with | some (_, S) => S | none => D1BodySized.S317
kernel_rfl D1BodySized.sizeDecA93 : interpS (decodeArgs D1BodySized.F D1BodySized.s317 D1BodySized.sizeTys93 D1BodySized.sizeArgs93).run D1BodySized.S317 =
  some (some D1BodySized.sizeAs93, D1BodySized.sizeS093)
kernel_rfl D1BodySized.sizePreA93 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS093 D1BodySized.s317.ffi D1BodySized.sizeAs93 = true

end Host.Load.Run.Tpl
end

section -- SN318
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel318 : nth? D1BodySized.ks 318 = some 10000
kernel_rfl D1BodySized.checked318 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s318 D1BodySized.S318) =
    fun _ => some (D1BodySized.s319, D1BodySized.S319)

theorem D1BodySized.k318 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s318 D1BodySized.S318 =
      some (D1BodySized.s319, D1BodySized.S319) := congrFun D1BodySized.checked318 bs

end Host.Load.Run.Tpl
end

section -- SN319
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel319 : nth? D1BodySized.ks 319 = some 2570
kernel_rfl D1BodySized.checked319 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s319 D1BodySized.S319) =
    fun _ => some (D1BodySized.s320, D1BodySized.S320)

theorem D1BodySized.k319 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s319 D1BodySized.S319 =
      some (D1BodySized.s320, D1BodySized.S320) := congrFun D1BodySized.checked319 bs

end Host.Load.Run.Tpl
end

section -- SB93
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment93 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s318 D1BodySized.S318 =
      some (D1BodySized.s320, D1BodySized.S320) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s318 D1BodySized.s319 D1BodySized.s320 D1BodySized.S318 D1BodySized.S319 D1BodySized.S320 (D1BodySized.k318 bs) (D1BodySized.k319 bs)

kernel_rfl D1BodySized.accepted93 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s318 D1BodySized.S318) = fun _ => true
kernel_rfl D1BodySized.oracle93 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S318.oracle = true
kernel_rfl D1BodySized.fuelA94 : nth? D1BodySized.ks 320 = some 1
kernel_rfl D1BodySized.fuelB94 : nth? D1BodySized.ks 321 = some 3
kernel_rfl D1BodySized.stepA94 : interpS (step D1BodySized.F D1BodySized.s320).run D1BodySized.S320 =
  some (D1BodySized.s321, D1BodySized.S321)
kernel_rfl D1BodySized.patchB94 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s321).run D1BodySized.S321 =
  some (D1BodySized.s322, D1BodySized.S322)
kernel_rfl D1BodySized.acceptedP94 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s320 D1BodySized.S320) = fun _ => true
kernel_rfl D1BodySized.haltP94 : isHalt D1BodySized.s320.ctl = false
kernel_rfl D1BodySized.topA94 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s321 = true
kernel_rfl D1BodySized.inactive94 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s321.ffi).active = false
/-- Bridge 94's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys94 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s321 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs94 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s321 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA94 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s321 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys94, D1BodySized.sizeArgs94)
kernel_rfl D1BodySized.sizeArgsA94 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s321 = true
kernel_rfl D1BodySized.sizeSymA94 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA94 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA94 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA94 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec94 := interpS (decodeArgs D1BodySized.F D1BodySized.s321 D1BodySized.sizeTys94 D1BodySized.sizeArgs94).run D1BodySized.S321
noncomputable def D1BodySized.sizeAs94 : List Arg := match D1BodySized.sizeDec94 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS094 : SSrv := match D1BodySized.sizeDec94 with | some (_, S) => S | none => D1BodySized.S321
kernel_rfl D1BodySized.sizeDecA94 : interpS (decodeArgs D1BodySized.F D1BodySized.s321 D1BodySized.sizeTys94 D1BodySized.sizeArgs94).run D1BodySized.S321 =
  some (some D1BodySized.sizeAs94, D1BodySized.sizeS094)
kernel_rfl D1BodySized.sizePreA94 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS094 D1BodySized.s321.ffi D1BodySized.sizeAs94 = true

end Host.Load.Run.Tpl
end

section -- SN322
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel322 : nth? D1BodySized.ks 322 = some 2542
kernel_rfl D1BodySized.checked322 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s322 D1BodySized.S322) =
    fun _ => some (D1BodySized.s323, D1BodySized.S323)

theorem D1BodySized.k322 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s322 D1BodySized.S322 =
      some (D1BodySized.s323, D1BodySized.S323) := congrFun D1BodySized.checked322 bs

end Host.Load.Run.Tpl
end

section -- SB94
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment94 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s322 D1BodySized.S322 =
      some (D1BodySized.s323, D1BodySized.S323) := D1BodySized.k322 bs

kernel_rfl D1BodySized.accepted94 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s322 D1BodySized.S322) = fun _ => true
kernel_rfl D1BodySized.oracle94 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S322.oracle = true
kernel_rfl D1BodySized.fuelA95 : nth? D1BodySized.ks 323 = some 1
kernel_rfl D1BodySized.fuelB95 : nth? D1BodySized.ks 324 = some 3
kernel_rfl D1BodySized.stepA95 : interpS (step D1BodySized.F D1BodySized.s323).run D1BodySized.S323 =
  some (D1BodySized.s324, D1BodySized.S324)
kernel_rfl D1BodySized.patchB95 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s324).run D1BodySized.S324 =
  some (D1BodySized.s325, D1BodySized.S325)
kernel_rfl D1BodySized.acceptedP95 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s323 D1BodySized.S323) = fun _ => true
kernel_rfl D1BodySized.haltP95 : isHalt D1BodySized.s323.ctl = false
kernel_rfl D1BodySized.topA95 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s324 = true
kernel_rfl D1BodySized.inactive95 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s324.ffi).active = false
/-- Bridge 95's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys95 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s324 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs95 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s324 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA95 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s324 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys95, D1BodySized.sizeArgs95)
kernel_rfl D1BodySized.sizeArgsA95 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s324 = true
kernel_rfl D1BodySized.sizeSymA95 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA95 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA95 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA95 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec95 := interpS (decodeArgs D1BodySized.F D1BodySized.s324 D1BodySized.sizeTys95 D1BodySized.sizeArgs95).run D1BodySized.S324
noncomputable def D1BodySized.sizeAs95 : List Arg := match D1BodySized.sizeDec95 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS095 : SSrv := match D1BodySized.sizeDec95 with | some (_, S) => S | none => D1BodySized.S324
kernel_rfl D1BodySized.sizeDecA95 : interpS (decodeArgs D1BodySized.F D1BodySized.s324 D1BodySized.sizeTys95 D1BodySized.sizeArgs95).run D1BodySized.S324 =
  some (some D1BodySized.sizeAs95, D1BodySized.sizeS095)
kernel_rfl D1BodySized.sizePreA95 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS095 D1BodySized.s324.ffi D1BodySized.sizeAs95 = true

end Host.Load.Run.Tpl
end

section -- SN325
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel325 : nth? D1BodySized.ks 325 = some 10000
kernel_rfl D1BodySized.checked325 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s325 D1BodySized.S325) =
    fun _ => some (D1BodySized.s326, D1BodySized.S326)

theorem D1BodySized.k325 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s325 D1BodySized.S325 =
      some (D1BodySized.s326, D1BodySized.S326) := congrFun D1BodySized.checked325 bs

end Host.Load.Run.Tpl
end

section -- SN326
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel326 : nth? D1BodySized.ks 326 = some 10000
kernel_rfl D1BodySized.checked326 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s326 D1BodySized.S326) =
    fun _ => some (D1BodySized.s327, D1BodySized.S327)

theorem D1BodySized.k326 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s326 D1BodySized.S326 =
      some (D1BodySized.s327, D1BodySized.S327) := congrFun D1BodySized.checked326 bs

end Host.Load.Run.Tpl
end

section -- SN327
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel327 : nth? D1BodySized.ks 327 = some 2287
kernel_rfl D1BodySized.checked327 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s327 D1BodySized.S327) =
    fun _ => some (D1BodySized.s328, D1BodySized.S328)

theorem D1BodySized.k327 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s327 D1BodySized.S327 =
      some (D1BodySized.s328, D1BodySized.S328) := congrFun D1BodySized.checked327 bs

end Host.Load.Run.Tpl
end

section -- SB95
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment95 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22287 D1BodySized.s325 D1BodySized.S325 =
      some (D1BodySized.s328, D1BodySized.S328) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2287 D1BodySized.s325 D1BodySized.s327 D1BodySized.s328 D1BodySized.S325 D1BodySized.S327 D1BodySized.S328 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s325 D1BodySized.s326 D1BodySized.s327 D1BodySized.S325 D1BodySized.S326 D1BodySized.S327 (D1BodySized.k325 bs) (D1BodySized.k326 bs)) (D1BodySized.k327 bs)

kernel_rfl D1BodySized.accepted95 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s325 D1BodySized.S325) = fun _ => true
kernel_rfl D1BodySized.oracle95 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S325.oracle = true
kernel_rfl D1BodySized.fuelA96 : nth? D1BodySized.ks 328 = some 1
kernel_rfl D1BodySized.fuelB96 : nth? D1BodySized.ks 329 = some 3
kernel_rfl D1BodySized.stepA96 : interpS (step D1BodySized.F D1BodySized.s328).run D1BodySized.S328 =
  some (D1BodySized.s329, D1BodySized.S329)
kernel_rfl D1BodySized.patchB96 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s329).run D1BodySized.S329 =
  some (D1BodySized.s330, D1BodySized.S330)
kernel_rfl D1BodySized.acceptedP96 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s328 D1BodySized.S328) = fun _ => true
kernel_rfl D1BodySized.haltP96 : isHalt D1BodySized.s328.ctl = false
kernel_rfl D1BodySized.topA96 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s329 = true
kernel_rfl D1BodySized.inactive96 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s329.ffi).active = false
/-- Bridge 96's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys96 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s329 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs96 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s329 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA96 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s329 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys96, D1BodySized.sizeArgs96)
kernel_rfl D1BodySized.sizeArgsA96 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s329 = true
kernel_rfl D1BodySized.sizeSymA96 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA96 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA96 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA96 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec96 := interpS (decodeArgs D1BodySized.F D1BodySized.s329 D1BodySized.sizeTys96 D1BodySized.sizeArgs96).run D1BodySized.S329
noncomputable def D1BodySized.sizeAs96 : List Arg := match D1BodySized.sizeDec96 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS096 : SSrv := match D1BodySized.sizeDec96 with | some (_, S) => S | none => D1BodySized.S329
kernel_rfl D1BodySized.sizeDecA96 : interpS (decodeArgs D1BodySized.F D1BodySized.s329 D1BodySized.sizeTys96 D1BodySized.sizeArgs96).run D1BodySized.S329 =
  some (some D1BodySized.sizeAs96, D1BodySized.sizeS096)
kernel_rfl D1BodySized.sizePreA96 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS096 D1BodySized.s329.ffi D1BodySized.sizeAs96 = true

end Host.Load.Run.Tpl
end

section -- SN330
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel330 : nth? D1BodySized.ks 330 = some 7980
kernel_rfl D1BodySized.checked330 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7980 D1BodySized.s330 D1BodySized.S330) =
    fun _ => some (D1BodySized.s331, D1BodySized.S331)

theorem D1BodySized.k330 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7980 D1BodySized.s330 D1BodySized.S330 =
      some (D1BodySized.s331, D1BodySized.S331) := congrFun D1BodySized.checked330 bs

end Host.Load.Run.Tpl
end

section -- SB96
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment96 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7980 D1BodySized.s330 D1BodySized.S330 =
      some (D1BodySized.s331, D1BodySized.S331) := D1BodySized.k330 bs

kernel_rfl D1BodySized.accepted96 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s330 D1BodySized.S330) = fun _ => true
kernel_rfl D1BodySized.oracle96 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S330.oracle = true
kernel_rfl D1BodySized.fuelA97 : nth? D1BodySized.ks 331 = some 1
kernel_rfl D1BodySized.fuelB97 : nth? D1BodySized.ks 332 = some 3
kernel_rfl D1BodySized.stepA97 : interpS (step D1BodySized.F D1BodySized.s331).run D1BodySized.S331 =
  some (D1BodySized.s332, D1BodySized.S332)
kernel_rfl D1BodySized.patchB97 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s332).run D1BodySized.S332 =
  some (D1BodySized.s333, D1BodySized.S333)
kernel_rfl D1BodySized.acceptedP97 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s331 D1BodySized.S331) = fun _ => true
kernel_rfl D1BodySized.haltP97 : isHalt D1BodySized.s331.ctl = false
kernel_rfl D1BodySized.topA97 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s332 = true
kernel_rfl D1BodySized.inactive97 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s332.ffi).active = false
/-- Bridge 97's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys97 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s332 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs97 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s332 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA97 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s332 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys97, D1BodySized.sizeArgs97)
kernel_rfl D1BodySized.sizeArgsA97 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s332 = true
kernel_rfl D1BodySized.sizeSymA97 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA97 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA97 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA97 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec97 := interpS (decodeArgs D1BodySized.F D1BodySized.s332 D1BodySized.sizeTys97 D1BodySized.sizeArgs97).run D1BodySized.S332
noncomputable def D1BodySized.sizeAs97 : List Arg := match D1BodySized.sizeDec97 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS097 : SSrv := match D1BodySized.sizeDec97 with | some (_, S) => S | none => D1BodySized.S332
kernel_rfl D1BodySized.sizeDecA97 : interpS (decodeArgs D1BodySized.F D1BodySized.s332 D1BodySized.sizeTys97 D1BodySized.sizeArgs97).run D1BodySized.S332 =
  some (some D1BodySized.sizeAs97, D1BodySized.sizeS097)
kernel_rfl D1BodySized.sizePreA97 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS097 D1BodySized.s332.ffi D1BodySized.sizeAs97 = true

end Host.Load.Run.Tpl
end

section -- SN333
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel333 : nth? D1BodySized.ks 333 = some 1936
kernel_rfl D1BodySized.checked333 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s333 D1BodySized.S333) =
    fun _ => some (D1BodySized.s334, D1BodySized.S334)

theorem D1BodySized.k333 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s333 D1BodySized.S333 =
      some (D1BodySized.s334, D1BodySized.S334) := congrFun D1BodySized.checked333 bs

end Host.Load.Run.Tpl
end

section -- SB97
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment97 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s333 D1BodySized.S333 =
      some (D1BodySized.s334, D1BodySized.S334) := D1BodySized.k333 bs

kernel_rfl D1BodySized.accepted97 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s333 D1BodySized.S333) = fun _ => true
kernel_rfl D1BodySized.oracle97 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S333.oracle = true
kernel_rfl D1BodySized.fuelA98 : nth? D1BodySized.ks 334 = some 1
kernel_rfl D1BodySized.fuelB98 : nth? D1BodySized.ks 335 = some 3
kernel_rfl D1BodySized.stepA98 : interpS (step D1BodySized.F D1BodySized.s334).run D1BodySized.S334 =
  some (D1BodySized.s335, D1BodySized.S335)
kernel_rfl D1BodySized.patchB98 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s335).run D1BodySized.S335 =
  some (D1BodySized.s336, D1BodySized.S336)
kernel_rfl D1BodySized.acceptedP98 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s334 D1BodySized.S334) = fun _ => true
kernel_rfl D1BodySized.haltP98 : isHalt D1BodySized.s334.ctl = false
kernel_rfl D1BodySized.topA98 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s335 = true
kernel_rfl D1BodySized.inactive98 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s335.ffi).active = false
/-- Bridge 98's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys98 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s335 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs98 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s335 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA98 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s335 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys98, D1BodySized.sizeArgs98)
kernel_rfl D1BodySized.sizeArgsA98 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s335 = true
kernel_rfl D1BodySized.sizeSymA98 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA98 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA98 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA98 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec98 := interpS (decodeArgs D1BodySized.F D1BodySized.s335 D1BodySized.sizeTys98 D1BodySized.sizeArgs98).run D1BodySized.S335
noncomputable def D1BodySized.sizeAs98 : List Arg := match D1BodySized.sizeDec98 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS098 : SSrv := match D1BodySized.sizeDec98 with | some (_, S) => S | none => D1BodySized.S335
kernel_rfl D1BodySized.sizeDecA98 : interpS (decodeArgs D1BodySized.F D1BodySized.s335 D1BodySized.sizeTys98 D1BodySized.sizeArgs98).run D1BodySized.S335 =
  some (some D1BodySized.sizeAs98, D1BodySized.sizeS098)
kernel_rfl D1BodySized.sizePreA98 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS098 D1BodySized.s335.ffi D1BodySized.sizeAs98 = true

end Host.Load.Run.Tpl
end

section -- SN336
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel336 : nth? D1BodySized.ks 336 = some 10000
kernel_rfl D1BodySized.checked336 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s336 D1BodySized.S336) =
    fun _ => some (D1BodySized.s337, D1BodySized.S337)

theorem D1BodySized.k336 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s336 D1BodySized.S336 =
      some (D1BodySized.s337, D1BodySized.S337) := congrFun D1BodySized.checked336 bs

end Host.Load.Run.Tpl
end

section -- SN337
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel337 : nth? D1BodySized.ks 337 = some 2570
kernel_rfl D1BodySized.checked337 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s337 D1BodySized.S337) =
    fun _ => some (D1BodySized.s338, D1BodySized.S338)

theorem D1BodySized.k337 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s337 D1BodySized.S337 =
      some (D1BodySized.s338, D1BodySized.S338) := congrFun D1BodySized.checked337 bs

end Host.Load.Run.Tpl
end

section -- SB98
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment98 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s336 D1BodySized.S336 =
      some (D1BodySized.s338, D1BodySized.S338) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s336 D1BodySized.s337 D1BodySized.s338 D1BodySized.S336 D1BodySized.S337 D1BodySized.S338 (D1BodySized.k336 bs) (D1BodySized.k337 bs)

kernel_rfl D1BodySized.accepted98 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s336 D1BodySized.S336) = fun _ => true
kernel_rfl D1BodySized.oracle98 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S336.oracle = true
kernel_rfl D1BodySized.fuelA99 : nth? D1BodySized.ks 338 = some 1
kernel_rfl D1BodySized.fuelB99 : nth? D1BodySized.ks 339 = some 3
kernel_rfl D1BodySized.stepA99 : interpS (step D1BodySized.F D1BodySized.s338).run D1BodySized.S338 =
  some (D1BodySized.s339, D1BodySized.S339)
kernel_rfl D1BodySized.patchB99 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s339).run D1BodySized.S339 =
  some (D1BodySized.s340, D1BodySized.S340)
kernel_rfl D1BodySized.acceptedP99 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s338 D1BodySized.S338) = fun _ => true
kernel_rfl D1BodySized.haltP99 : isHalt D1BodySized.s338.ctl = false
kernel_rfl D1BodySized.topA99 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s339 = true
kernel_rfl D1BodySized.inactive99 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s339.ffi).active = false
/-- Bridge 99's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys99 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s339 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs99 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s339 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA99 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s339 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys99, D1BodySized.sizeArgs99)
kernel_rfl D1BodySized.sizeArgsA99 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s339 = true
kernel_rfl D1BodySized.sizeSymA99 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA99 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA99 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA99 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec99 := interpS (decodeArgs D1BodySized.F D1BodySized.s339 D1BodySized.sizeTys99 D1BodySized.sizeArgs99).run D1BodySized.S339
noncomputable def D1BodySized.sizeAs99 : List Arg := match D1BodySized.sizeDec99 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS099 : SSrv := match D1BodySized.sizeDec99 with | some (_, S) => S | none => D1BodySized.S339
kernel_rfl D1BodySized.sizeDecA99 : interpS (decodeArgs D1BodySized.F D1BodySized.s339 D1BodySized.sizeTys99 D1BodySized.sizeArgs99).run D1BodySized.S339 =
  some (some D1BodySized.sizeAs99, D1BodySized.sizeS099)
kernel_rfl D1BodySized.sizePreA99 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS099 D1BodySized.s339.ffi D1BodySized.sizeAs99 = true

end Host.Load.Run.Tpl
end

section -- SN340
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel340 : nth? D1BodySized.ks 340 = some 2542
kernel_rfl D1BodySized.checked340 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s340 D1BodySized.S340) =
    fun _ => some (D1BodySized.s341, D1BodySized.S341)

theorem D1BodySized.k340 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s340 D1BodySized.S340 =
      some (D1BodySized.s341, D1BodySized.S341) := congrFun D1BodySized.checked340 bs

end Host.Load.Run.Tpl
end

section -- SB99
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment99 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s340 D1BodySized.S340 =
      some (D1BodySized.s341, D1BodySized.S341) := D1BodySized.k340 bs

kernel_rfl D1BodySized.accepted99 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s340 D1BodySized.S340) = fun _ => true
kernel_rfl D1BodySized.oracle99 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S340.oracle = true
kernel_rfl D1BodySized.fuelA100 : nth? D1BodySized.ks 341 = some 1
kernel_rfl D1BodySized.fuelB100 : nth? D1BodySized.ks 342 = some 3
kernel_rfl D1BodySized.stepA100 : interpS (step D1BodySized.F D1BodySized.s341).run D1BodySized.S341 =
  some (D1BodySized.s342, D1BodySized.S342)
kernel_rfl D1BodySized.patchB100 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s342).run D1BodySized.S342 =
  some (D1BodySized.s343, D1BodySized.S343)
kernel_rfl D1BodySized.acceptedP100 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s341 D1BodySized.S341) = fun _ => true
kernel_rfl D1BodySized.haltP100 : isHalt D1BodySized.s341.ctl = false
kernel_rfl D1BodySized.topA100 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s342 = true
kernel_rfl D1BodySized.inactive100 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s342.ffi).active = false
/-- Bridge 100's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys100 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s342 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs100 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s342 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA100 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s342 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys100, D1BodySized.sizeArgs100)
kernel_rfl D1BodySized.sizeArgsA100 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s342 = true
kernel_rfl D1BodySized.sizeSymA100 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA100 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA100 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA100 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec100 := interpS (decodeArgs D1BodySized.F D1BodySized.s342 D1BodySized.sizeTys100 D1BodySized.sizeArgs100).run D1BodySized.S342
noncomputable def D1BodySized.sizeAs100 : List Arg := match D1BodySized.sizeDec100 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0100 : SSrv := match D1BodySized.sizeDec100 with | some (_, S) => S | none => D1BodySized.S342
kernel_rfl D1BodySized.sizeDecA100 : interpS (decodeArgs D1BodySized.F D1BodySized.s342 D1BodySized.sizeTys100 D1BodySized.sizeArgs100).run D1BodySized.S342 =
  some (some D1BodySized.sizeAs100, D1BodySized.sizeS0100)
kernel_rfl D1BodySized.sizePreA100 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0100 D1BodySized.s342.ffi D1BodySized.sizeAs100 = true

end Host.Load.Run.Tpl
end

section -- SN343
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel343 : nth? D1BodySized.ks 343 = some 7762
kernel_rfl D1BodySized.checked343 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s343 D1BodySized.S343) =
    fun _ => some (D1BodySized.s344, D1BodySized.S344)

theorem D1BodySized.k343 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s343 D1BodySized.S343 =
      some (D1BodySized.s344, D1BodySized.S344) := congrFun D1BodySized.checked343 bs

end Host.Load.Run.Tpl
end

section -- SB100
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment100 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s343 D1BodySized.S343 =
      some (D1BodySized.s344, D1BodySized.S344) := D1BodySized.k343 bs

kernel_rfl D1BodySized.accepted100 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s343 D1BodySized.S343) = fun _ => true
kernel_rfl D1BodySized.oracle100 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S343.oracle = true
kernel_rfl D1BodySized.fuelA101 : nth? D1BodySized.ks 344 = some 1
kernel_rfl D1BodySized.fuelB101 : nth? D1BodySized.ks 345 = some 3
kernel_rfl D1BodySized.stepA101 : interpS (step D1BodySized.F D1BodySized.s344).run D1BodySized.S344 =
  some (D1BodySized.s345, D1BodySized.S345)
kernel_rfl D1BodySized.patchB101 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s345).run D1BodySized.S345 =
  some (D1BodySized.s346, D1BodySized.S346)
kernel_rfl D1BodySized.acceptedP101 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s344 D1BodySized.S344) = fun _ => true
kernel_rfl D1BodySized.haltP101 : isHalt D1BodySized.s344.ctl = false
kernel_rfl D1BodySized.topA101 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s345 = true
kernel_rfl D1BodySized.inactive101 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s345.ffi).active = false
/-- Bridge 101's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys101 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s345 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs101 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s345 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA101 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s345 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys101, D1BodySized.sizeArgs101)
kernel_rfl D1BodySized.sizeArgsA101 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s345 = true
kernel_rfl D1BodySized.sizeSymA101 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA101 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA101 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA101 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec101 := interpS (decodeArgs D1BodySized.F D1BodySized.s345 D1BodySized.sizeTys101 D1BodySized.sizeArgs101).run D1BodySized.S345
noncomputable def D1BodySized.sizeAs101 : List Arg := match D1BodySized.sizeDec101 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0101 : SSrv := match D1BodySized.sizeDec101 with | some (_, S) => S | none => D1BodySized.S345
kernel_rfl D1BodySized.sizeDecA101 : interpS (decodeArgs D1BodySized.F D1BodySized.s345 D1BodySized.sizeTys101 D1BodySized.sizeArgs101).run D1BodySized.S345 =
  some (some D1BodySized.sizeAs101, D1BodySized.sizeS0101)
kernel_rfl D1BodySized.sizePreA101 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0101 D1BodySized.s345.ffi D1BodySized.sizeAs101 = true

end Host.Load.Run.Tpl
end

section -- SN346
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel346 : nth? D1BodySized.ks 346 = some 1936
kernel_rfl D1BodySized.checked346 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s346 D1BodySized.S346) =
    fun _ => some (D1BodySized.s347, D1BodySized.S347)

theorem D1BodySized.k346 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s346 D1BodySized.S346 =
      some (D1BodySized.s347, D1BodySized.S347) := congrFun D1BodySized.checked346 bs

end Host.Load.Run.Tpl
end

section -- SB101
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment101 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s346 D1BodySized.S346 =
      some (D1BodySized.s347, D1BodySized.S347) := D1BodySized.k346 bs

kernel_rfl D1BodySized.accepted101 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s346 D1BodySized.S346) = fun _ => true
kernel_rfl D1BodySized.oracle101 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S346.oracle = true
kernel_rfl D1BodySized.fuelA102 : nth? D1BodySized.ks 347 = some 1
kernel_rfl D1BodySized.fuelB102 : nth? D1BodySized.ks 348 = some 3
kernel_rfl D1BodySized.stepA102 : interpS (step D1BodySized.F D1BodySized.s347).run D1BodySized.S347 =
  some (D1BodySized.s348, D1BodySized.S348)
kernel_rfl D1BodySized.patchB102 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s348).run D1BodySized.S348 =
  some (D1BodySized.s349, D1BodySized.S349)
kernel_rfl D1BodySized.acceptedP102 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s347 D1BodySized.S347) = fun _ => true
kernel_rfl D1BodySized.haltP102 : isHalt D1BodySized.s347.ctl = false
kernel_rfl D1BodySized.topA102 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s348 = true
kernel_rfl D1BodySized.inactive102 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s348.ffi).active = false
/-- Bridge 102's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys102 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s348 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs102 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s348 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA102 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s348 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys102, D1BodySized.sizeArgs102)
kernel_rfl D1BodySized.sizeArgsA102 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s348 = true
kernel_rfl D1BodySized.sizeSymA102 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA102 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA102 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA102 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec102 := interpS (decodeArgs D1BodySized.F D1BodySized.s348 D1BodySized.sizeTys102 D1BodySized.sizeArgs102).run D1BodySized.S348
noncomputable def D1BodySized.sizeAs102 : List Arg := match D1BodySized.sizeDec102 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0102 : SSrv := match D1BodySized.sizeDec102 with | some (_, S) => S | none => D1BodySized.S348
kernel_rfl D1BodySized.sizeDecA102 : interpS (decodeArgs D1BodySized.F D1BodySized.s348 D1BodySized.sizeTys102 D1BodySized.sizeArgs102).run D1BodySized.S348 =
  some (some D1BodySized.sizeAs102, D1BodySized.sizeS0102)
kernel_rfl D1BodySized.sizePreA102 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0102 D1BodySized.s348.ffi D1BodySized.sizeAs102 = true

end Host.Load.Run.Tpl
end

section -- SN349
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel349 : nth? D1BodySized.ks 349 = some 10000
kernel_rfl D1BodySized.checked349 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s349 D1BodySized.S349) =
    fun _ => some (D1BodySized.s350, D1BodySized.S350)

theorem D1BodySized.k349 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s349 D1BodySized.S349 =
      some (D1BodySized.s350, D1BodySized.S350) := congrFun D1BodySized.checked349 bs

end Host.Load.Run.Tpl
end

section -- SN350
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel350 : nth? D1BodySized.ks 350 = some 2570
kernel_rfl D1BodySized.checked350 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s350 D1BodySized.S350) =
    fun _ => some (D1BodySized.s351, D1BodySized.S351)

theorem D1BodySized.k350 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s350 D1BodySized.S350 =
      some (D1BodySized.s351, D1BodySized.S351) := congrFun D1BodySized.checked350 bs

end Host.Load.Run.Tpl
end

section -- SB102
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment102 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s349 D1BodySized.S349 =
      some (D1BodySized.s351, D1BodySized.S351) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s349 D1BodySized.s350 D1BodySized.s351 D1BodySized.S349 D1BodySized.S350 D1BodySized.S351 (D1BodySized.k349 bs) (D1BodySized.k350 bs)

kernel_rfl D1BodySized.accepted102 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s349 D1BodySized.S349) = fun _ => true
kernel_rfl D1BodySized.oracle102 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S349.oracle = true
kernel_rfl D1BodySized.fuelA103 : nth? D1BodySized.ks 351 = some 1
kernel_rfl D1BodySized.fuelB103 : nth? D1BodySized.ks 352 = some 3
kernel_rfl D1BodySized.stepA103 : interpS (step D1BodySized.F D1BodySized.s351).run D1BodySized.S351 =
  some (D1BodySized.s352, D1BodySized.S352)
kernel_rfl D1BodySized.patchB103 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s352).run D1BodySized.S352 =
  some (D1BodySized.s353, D1BodySized.S353)
kernel_rfl D1BodySized.acceptedP103 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s351 D1BodySized.S351) = fun _ => true
kernel_rfl D1BodySized.haltP103 : isHalt D1BodySized.s351.ctl = false
kernel_rfl D1BodySized.topA103 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s352 = true
kernel_rfl D1BodySized.inactive103 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s352.ffi).active = false
/-- Bridge 103's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys103 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s352 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs103 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s352 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA103 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s352 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys103, D1BodySized.sizeArgs103)
kernel_rfl D1BodySized.sizeArgsA103 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s352 = true
kernel_rfl D1BodySized.sizeSymA103 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA103 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA103 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA103 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec103 := interpS (decodeArgs D1BodySized.F D1BodySized.s352 D1BodySized.sizeTys103 D1BodySized.sizeArgs103).run D1BodySized.S352
noncomputable def D1BodySized.sizeAs103 : List Arg := match D1BodySized.sizeDec103 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0103 : SSrv := match D1BodySized.sizeDec103 with | some (_, S) => S | none => D1BodySized.S352
kernel_rfl D1BodySized.sizeDecA103 : interpS (decodeArgs D1BodySized.F D1BodySized.s352 D1BodySized.sizeTys103 D1BodySized.sizeArgs103).run D1BodySized.S352 =
  some (some D1BodySized.sizeAs103, D1BodySized.sizeS0103)
kernel_rfl D1BodySized.sizePreA103 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0103 D1BodySized.s352.ffi D1BodySized.sizeAs103 = true

end Host.Load.Run.Tpl
end

section -- SN353
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel353 : nth? D1BodySized.ks 353 = some 2542
kernel_rfl D1BodySized.checked353 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s353 D1BodySized.S353) =
    fun _ => some (D1BodySized.s354, D1BodySized.S354)

theorem D1BodySized.k353 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s353 D1BodySized.S353 =
      some (D1BodySized.s354, D1BodySized.S354) := congrFun D1BodySized.checked353 bs

end Host.Load.Run.Tpl
end

section -- SB103
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment103 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s353 D1BodySized.S353 =
      some (D1BodySized.s354, D1BodySized.S354) := D1BodySized.k353 bs

kernel_rfl D1BodySized.accepted103 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s353 D1BodySized.S353) = fun _ => true
kernel_rfl D1BodySized.oracle103 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S353.oracle = true
kernel_rfl D1BodySized.fuelA104 : nth? D1BodySized.ks 354 = some 1
kernel_rfl D1BodySized.fuelB104 : nth? D1BodySized.ks 355 = some 3
kernel_rfl D1BodySized.stepA104 : interpS (step D1BodySized.F D1BodySized.s354).run D1BodySized.S354 =
  some (D1BodySized.s355, D1BodySized.S355)
kernel_rfl D1BodySized.patchB104 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s355).run D1BodySized.S355 =
  some (D1BodySized.s356, D1BodySized.S356)
kernel_rfl D1BodySized.acceptedP104 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s354 D1BodySized.S354) = fun _ => true
kernel_rfl D1BodySized.haltP104 : isHalt D1BodySized.s354.ctl = false
kernel_rfl D1BodySized.topA104 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s355 = true
kernel_rfl D1BodySized.inactive104 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s355.ffi).active = false
/-- Bridge 104's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys104 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s355 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs104 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s355 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA104 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s355 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys104, D1BodySized.sizeArgs104)
kernel_rfl D1BodySized.sizeArgsA104 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s355 = true
kernel_rfl D1BodySized.sizeSymA104 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA104 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA104 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA104 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec104 := interpS (decodeArgs D1BodySized.F D1BodySized.s355 D1BodySized.sizeTys104 D1BodySized.sizeArgs104).run D1BodySized.S355
noncomputable def D1BodySized.sizeAs104 : List Arg := match D1BodySized.sizeDec104 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0104 : SSrv := match D1BodySized.sizeDec104 with | some (_, S) => S | none => D1BodySized.S355
kernel_rfl D1BodySized.sizeDecA104 : interpS (decodeArgs D1BodySized.F D1BodySized.s355 D1BodySized.sizeTys104 D1BodySized.sizeArgs104).run D1BodySized.S355 =
  some (some D1BodySized.sizeAs104, D1BodySized.sizeS0104)
kernel_rfl D1BodySized.sizePreA104 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0104 D1BodySized.s355.ffi D1BodySized.sizeAs104 = true

end Host.Load.Run.Tpl
end
