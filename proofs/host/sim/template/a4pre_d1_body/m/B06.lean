import host.sim.template.a4pre_d1_body.m.B00
import host.sim.template.a4pre_d1_body.TraceStep
import host.sim.Chunk
import host.sim.template.a4pre_d1_body.SizeLift

section -- SN356
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel356 : nth? D1BodySized.ks 356 = some 7762
kernel_rfl D1BodySized.checked356 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s356 D1BodySized.S356) =
    fun _ => some (D1BodySized.s357, D1BodySized.S357)

theorem D1BodySized.k356 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s356 D1BodySized.S356 =
      some (D1BodySized.s357, D1BodySized.S357) := congrFun D1BodySized.checked356 bs

end Host.Load.Run.Tpl
end

section -- SB104
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment104 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s356 D1BodySized.S356 =
      some (D1BodySized.s357, D1BodySized.S357) := D1BodySized.k356 bs

kernel_rfl D1BodySized.accepted104 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s356 D1BodySized.S356) = fun _ => true
kernel_rfl D1BodySized.oracle104 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S356.oracle = true
kernel_rfl D1BodySized.fuelA105 : nth? D1BodySized.ks 357 = some 1
kernel_rfl D1BodySized.fuelB105 : nth? D1BodySized.ks 358 = some 3
kernel_rfl D1BodySized.stepA105 : interpS (step D1BodySized.F D1BodySized.s357).run D1BodySized.S357 =
  some (D1BodySized.s358, D1BodySized.S358)
kernel_rfl D1BodySized.patchB105 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s358).run D1BodySized.S358 =
  some (D1BodySized.s359, D1BodySized.S359)
kernel_rfl D1BodySized.acceptedP105 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s357 D1BodySized.S357) = fun _ => true
kernel_rfl D1BodySized.haltP105 : isHalt D1BodySized.s357.ctl = false
kernel_rfl D1BodySized.topA105 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s358 = true
kernel_rfl D1BodySized.inactive105 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s358.ffi).active = false
/-- Bridge 105's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys105 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s358 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs105 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s358 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA105 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s358 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys105, D1BodySized.sizeArgs105)
kernel_rfl D1BodySized.sizeArgsA105 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s358 = true
kernel_rfl D1BodySized.sizeSymA105 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA105 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA105 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA105 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec105 := interpS (decodeArgs D1BodySized.F D1BodySized.s358 D1BodySized.sizeTys105 D1BodySized.sizeArgs105).run D1BodySized.S358
noncomputable def D1BodySized.sizeAs105 : List Arg := match D1BodySized.sizeDec105 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0105 : SSrv := match D1BodySized.sizeDec105 with | some (_, S) => S | none => D1BodySized.S358
kernel_rfl D1BodySized.sizeDecA105 : interpS (decodeArgs D1BodySized.F D1BodySized.s358 D1BodySized.sizeTys105 D1BodySized.sizeArgs105).run D1BodySized.S358 =
  some (some D1BodySized.sizeAs105, D1BodySized.sizeS0105)
kernel_rfl D1BodySized.sizePreA105 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0105 D1BodySized.s358.ffi D1BodySized.sizeAs105 = true

end Host.Load.Run.Tpl
end

section -- SN359
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel359 : nth? D1BodySized.ks 359 = some 1936
kernel_rfl D1BodySized.checked359 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s359 D1BodySized.S359) =
    fun _ => some (D1BodySized.s360, D1BodySized.S360)

theorem D1BodySized.k359 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s359 D1BodySized.S359 =
      some (D1BodySized.s360, D1BodySized.S360) := congrFun D1BodySized.checked359 bs

end Host.Load.Run.Tpl
end

section -- SB105
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment105 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s359 D1BodySized.S359 =
      some (D1BodySized.s360, D1BodySized.S360) := D1BodySized.k359 bs

kernel_rfl D1BodySized.accepted105 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s359 D1BodySized.S359) = fun _ => true
kernel_rfl D1BodySized.oracle105 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S359.oracle = true
kernel_rfl D1BodySized.fuelA106 : nth? D1BodySized.ks 360 = some 1
kernel_rfl D1BodySized.fuelB106 : nth? D1BodySized.ks 361 = some 3
kernel_rfl D1BodySized.stepA106 : interpS (step D1BodySized.F D1BodySized.s360).run D1BodySized.S360 =
  some (D1BodySized.s361, D1BodySized.S361)
kernel_rfl D1BodySized.patchB106 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s361).run D1BodySized.S361 =
  some (D1BodySized.s362, D1BodySized.S362)
kernel_rfl D1BodySized.acceptedP106 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s360 D1BodySized.S360) = fun _ => true
kernel_rfl D1BodySized.haltP106 : isHalt D1BodySized.s360.ctl = false
kernel_rfl D1BodySized.topA106 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s361 = true
kernel_rfl D1BodySized.inactive106 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s361.ffi).active = false
/-- Bridge 106's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys106 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s361 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs106 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s361 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA106 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s361 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys106, D1BodySized.sizeArgs106)
kernel_rfl D1BodySized.sizeArgsA106 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s361 = true
kernel_rfl D1BodySized.sizeSymA106 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA106 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA106 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA106 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec106 := interpS (decodeArgs D1BodySized.F D1BodySized.s361 D1BodySized.sizeTys106 D1BodySized.sizeArgs106).run D1BodySized.S361
noncomputable def D1BodySized.sizeAs106 : List Arg := match D1BodySized.sizeDec106 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0106 : SSrv := match D1BodySized.sizeDec106 with | some (_, S) => S | none => D1BodySized.S361
kernel_rfl D1BodySized.sizeDecA106 : interpS (decodeArgs D1BodySized.F D1BodySized.s361 D1BodySized.sizeTys106 D1BodySized.sizeArgs106).run D1BodySized.S361 =
  some (some D1BodySized.sizeAs106, D1BodySized.sizeS0106)
kernel_rfl D1BodySized.sizePreA106 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0106 D1BodySized.s361.ffi D1BodySized.sizeAs106 = true

end Host.Load.Run.Tpl
end

section -- SN362
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel362 : nth? D1BodySized.ks 362 = some 10000
kernel_rfl D1BodySized.checked362 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s362 D1BodySized.S362) =
    fun _ => some (D1BodySized.s363, D1BodySized.S363)

theorem D1BodySized.k362 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s362 D1BodySized.S362 =
      some (D1BodySized.s363, D1BodySized.S363) := congrFun D1BodySized.checked362 bs

end Host.Load.Run.Tpl
end

section -- SN363
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel363 : nth? D1BodySized.ks 363 = some 2570
kernel_rfl D1BodySized.checked363 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s363 D1BodySized.S363) =
    fun _ => some (D1BodySized.s364, D1BodySized.S364)

theorem D1BodySized.k363 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s363 D1BodySized.S363 =
      some (D1BodySized.s364, D1BodySized.S364) := congrFun D1BodySized.checked363 bs

end Host.Load.Run.Tpl
end

section -- SB106
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment106 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s362 D1BodySized.S362 =
      some (D1BodySized.s364, D1BodySized.S364) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s362 D1BodySized.s363 D1BodySized.s364 D1BodySized.S362 D1BodySized.S363 D1BodySized.S364 (D1BodySized.k362 bs) (D1BodySized.k363 bs)

kernel_rfl D1BodySized.accepted106 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s362 D1BodySized.S362) = fun _ => true
kernel_rfl D1BodySized.oracle106 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S362.oracle = true
kernel_rfl D1BodySized.fuelA107 : nth? D1BodySized.ks 364 = some 1
kernel_rfl D1BodySized.fuelB107 : nth? D1BodySized.ks 365 = some 3
kernel_rfl D1BodySized.stepA107 : interpS (step D1BodySized.F D1BodySized.s364).run D1BodySized.S364 =
  some (D1BodySized.s365, D1BodySized.S365)
kernel_rfl D1BodySized.patchB107 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s365).run D1BodySized.S365 =
  some (D1BodySized.s366, D1BodySized.S366)
kernel_rfl D1BodySized.acceptedP107 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s364 D1BodySized.S364) = fun _ => true
kernel_rfl D1BodySized.haltP107 : isHalt D1BodySized.s364.ctl = false
kernel_rfl D1BodySized.topA107 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s365 = true
kernel_rfl D1BodySized.inactive107 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s365.ffi).active = false
/-- Bridge 107's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys107 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s365 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs107 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s365 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA107 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s365 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys107, D1BodySized.sizeArgs107)
kernel_rfl D1BodySized.sizeArgsA107 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s365 = true
kernel_rfl D1BodySized.sizeSymA107 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA107 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA107 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA107 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec107 := interpS (decodeArgs D1BodySized.F D1BodySized.s365 D1BodySized.sizeTys107 D1BodySized.sizeArgs107).run D1BodySized.S365
noncomputable def D1BodySized.sizeAs107 : List Arg := match D1BodySized.sizeDec107 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0107 : SSrv := match D1BodySized.sizeDec107 with | some (_, S) => S | none => D1BodySized.S365
kernel_rfl D1BodySized.sizeDecA107 : interpS (decodeArgs D1BodySized.F D1BodySized.s365 D1BodySized.sizeTys107 D1BodySized.sizeArgs107).run D1BodySized.S365 =
  some (some D1BodySized.sizeAs107, D1BodySized.sizeS0107)
kernel_rfl D1BodySized.sizePreA107 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0107 D1BodySized.s365.ffi D1BodySized.sizeAs107 = true

end Host.Load.Run.Tpl
end

section -- SN366
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel366 : nth? D1BodySized.ks 366 = some 2542
kernel_rfl D1BodySized.checked366 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s366 D1BodySized.S366) =
    fun _ => some (D1BodySized.s367, D1BodySized.S367)

theorem D1BodySized.k366 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s366 D1BodySized.S366 =
      some (D1BodySized.s367, D1BodySized.S367) := congrFun D1BodySized.checked366 bs

end Host.Load.Run.Tpl
end

section -- SB107
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment107 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s366 D1BodySized.S366 =
      some (D1BodySized.s367, D1BodySized.S367) := D1BodySized.k366 bs

kernel_rfl D1BodySized.accepted107 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s366 D1BodySized.S366) = fun _ => true
kernel_rfl D1BodySized.oracle107 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S366.oracle = true
kernel_rfl D1BodySized.fuelA108 : nth? D1BodySized.ks 367 = some 1
kernel_rfl D1BodySized.fuelB108 : nth? D1BodySized.ks 368 = some 3
kernel_rfl D1BodySized.stepA108 : interpS (step D1BodySized.F D1BodySized.s367).run D1BodySized.S367 =
  some (D1BodySized.s368, D1BodySized.S368)
kernel_rfl D1BodySized.patchB108 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s368).run D1BodySized.S368 =
  some (D1BodySized.s369, D1BodySized.S369)
kernel_rfl D1BodySized.acceptedP108 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s367 D1BodySized.S367) = fun _ => true
kernel_rfl D1BodySized.haltP108 : isHalt D1BodySized.s367.ctl = false
kernel_rfl D1BodySized.topA108 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s368 = true
kernel_rfl D1BodySized.inactive108 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s368.ffi).active = false
/-- Bridge 108's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys108 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s368 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs108 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s368 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA108 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s368 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys108, D1BodySized.sizeArgs108)
kernel_rfl D1BodySized.sizeArgsA108 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s368 = true
kernel_rfl D1BodySized.sizeSymA108 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA108 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA108 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA108 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec108 := interpS (decodeArgs D1BodySized.F D1BodySized.s368 D1BodySized.sizeTys108 D1BodySized.sizeArgs108).run D1BodySized.S368
noncomputable def D1BodySized.sizeAs108 : List Arg := match D1BodySized.sizeDec108 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0108 : SSrv := match D1BodySized.sizeDec108 with | some (_, S) => S | none => D1BodySized.S368
kernel_rfl D1BodySized.sizeDecA108 : interpS (decodeArgs D1BodySized.F D1BodySized.s368 D1BodySized.sizeTys108 D1BodySized.sizeArgs108).run D1BodySized.S368 =
  some (some D1BodySized.sizeAs108, D1BodySized.sizeS0108)
kernel_rfl D1BodySized.sizePreA108 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0108 D1BodySized.s368.ffi D1BodySized.sizeAs108 = true

end Host.Load.Run.Tpl
end

section -- SN369
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel369 : nth? D1BodySized.ks 369 = some 10000
kernel_rfl D1BodySized.checked369 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s369 D1BodySized.S369) =
    fun _ => some (D1BodySized.s370, D1BodySized.S370)

theorem D1BodySized.k369 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s369 D1BodySized.S369 =
      some (D1BodySized.s370, D1BodySized.S370) := congrFun D1BodySized.checked369 bs

end Host.Load.Run.Tpl
end

section -- SN370
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel370 : nth? D1BodySized.ks 370 = some 10000
kernel_rfl D1BodySized.checked370 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s370 D1BodySized.S370) =
    fun _ => some (D1BodySized.s371, D1BodySized.S371)

theorem D1BodySized.k370 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s370 D1BodySized.S370 =
      some (D1BodySized.s371, D1BodySized.S371) := congrFun D1BodySized.checked370 bs

end Host.Load.Run.Tpl
end

section -- SN371
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel371 : nth? D1BodySized.ks 371 = some 2287
kernel_rfl D1BodySized.checked371 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s371 D1BodySized.S371) =
    fun _ => some (D1BodySized.s372, D1BodySized.S372)

theorem D1BodySized.k371 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s371 D1BodySized.S371 =
      some (D1BodySized.s372, D1BodySized.S372) := congrFun D1BodySized.checked371 bs

end Host.Load.Run.Tpl
end

section -- SB108
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment108 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22287 D1BodySized.s369 D1BodySized.S369 =
      some (D1BodySized.s372, D1BodySized.S372) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2287 D1BodySized.s369 D1BodySized.s371 D1BodySized.s372 D1BodySized.S369 D1BodySized.S371 D1BodySized.S372 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s369 D1BodySized.s370 D1BodySized.s371 D1BodySized.S369 D1BodySized.S370 D1BodySized.S371 (D1BodySized.k369 bs) (D1BodySized.k370 bs)) (D1BodySized.k371 bs)

kernel_rfl D1BodySized.accepted108 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s369 D1BodySized.S369) = fun _ => true
kernel_rfl D1BodySized.oracle108 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S369.oracle = true
kernel_rfl D1BodySized.fuelA109 : nth? D1BodySized.ks 372 = some 1
kernel_rfl D1BodySized.fuelB109 : nth? D1BodySized.ks 373 = some 3
kernel_rfl D1BodySized.stepA109 : interpS (step D1BodySized.F D1BodySized.s372).run D1BodySized.S372 =
  some (D1BodySized.s373, D1BodySized.S373)
kernel_rfl D1BodySized.patchB109 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s373).run D1BodySized.S373 =
  some (D1BodySized.s374, D1BodySized.S374)
kernel_rfl D1BodySized.acceptedP109 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s372 D1BodySized.S372) = fun _ => true
kernel_rfl D1BodySized.haltP109 : isHalt D1BodySized.s372.ctl = false
kernel_rfl D1BodySized.topA109 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s373 = true
kernel_rfl D1BodySized.inactive109 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s373.ffi).active = false
/-- Bridge 109's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys109 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s373 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs109 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s373 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA109 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s373 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys109, D1BodySized.sizeArgs109)
kernel_rfl D1BodySized.sizeArgsA109 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s373 = true
kernel_rfl D1BodySized.sizeSymA109 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA109 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA109 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA109 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec109 := interpS (decodeArgs D1BodySized.F D1BodySized.s373 D1BodySized.sizeTys109 D1BodySized.sizeArgs109).run D1BodySized.S373
noncomputable def D1BodySized.sizeAs109 : List Arg := match D1BodySized.sizeDec109 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0109 : SSrv := match D1BodySized.sizeDec109 with | some (_, S) => S | none => D1BodySized.S373
kernel_rfl D1BodySized.sizeDecA109 : interpS (decodeArgs D1BodySized.F D1BodySized.s373 D1BodySized.sizeTys109 D1BodySized.sizeArgs109).run D1BodySized.S373 =
  some (some D1BodySized.sizeAs109, D1BodySized.sizeS0109)
kernel_rfl D1BodySized.sizePreA109 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0109 D1BodySized.s373.ffi D1BodySized.sizeAs109 = true

end Host.Load.Run.Tpl
end

section -- SN374
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel374 : nth? D1BodySized.ks 374 = some 7939
kernel_rfl D1BodySized.checked374 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7939 D1BodySized.s374 D1BodySized.S374) =
    fun _ => some (D1BodySized.s375, D1BodySized.S375)

theorem D1BodySized.k374 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7939 D1BodySized.s374 D1BodySized.S374 =
      some (D1BodySized.s375, D1BodySized.S375) := congrFun D1BodySized.checked374 bs

end Host.Load.Run.Tpl
end

section -- SB109
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment109 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7939 D1BodySized.s374 D1BodySized.S374 =
      some (D1BodySized.s375, D1BodySized.S375) := D1BodySized.k374 bs

kernel_rfl D1BodySized.accepted109 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s374 D1BodySized.S374) = fun _ => true
kernel_rfl D1BodySized.oracle109 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S374.oracle = true
kernel_rfl D1BodySized.fuelA110 : nth? D1BodySized.ks 375 = some 1
kernel_rfl D1BodySized.fuelB110 : nth? D1BodySized.ks 376 = some 3
kernel_rfl D1BodySized.stepA110 : interpS (step D1BodySized.F D1BodySized.s375).run D1BodySized.S375 =
  some (D1BodySized.s376, D1BodySized.S376)
kernel_rfl D1BodySized.patchB110 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s376).run D1BodySized.S376 =
  some (D1BodySized.s377, D1BodySized.S377)
kernel_rfl D1BodySized.acceptedP110 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s375 D1BodySized.S375) = fun _ => true
kernel_rfl D1BodySized.haltP110 : isHalt D1BodySized.s375.ctl = false
kernel_rfl D1BodySized.topA110 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s376 = true
kernel_rfl D1BodySized.inactive110 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s376.ffi).active = false
/-- Bridge 110's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys110 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s376 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs110 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s376 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA110 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s376 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys110, D1BodySized.sizeArgs110)
kernel_rfl D1BodySized.sizeArgsA110 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s376 = true
kernel_rfl D1BodySized.sizeSymA110 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA110 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA110 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA110 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec110 := interpS (decodeArgs D1BodySized.F D1BodySized.s376 D1BodySized.sizeTys110 D1BodySized.sizeArgs110).run D1BodySized.S376
noncomputable def D1BodySized.sizeAs110 : List Arg := match D1BodySized.sizeDec110 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0110 : SSrv := match D1BodySized.sizeDec110 with | some (_, S) => S | none => D1BodySized.S376
kernel_rfl D1BodySized.sizeDecA110 : interpS (decodeArgs D1BodySized.F D1BodySized.s376 D1BodySized.sizeTys110 D1BodySized.sizeArgs110).run D1BodySized.S376 =
  some (some D1BodySized.sizeAs110, D1BodySized.sizeS0110)
kernel_rfl D1BodySized.sizePreA110 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0110 D1BodySized.s376.ffi D1BodySized.sizeAs110 = true

end Host.Load.Run.Tpl
end

section -- SN377
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel377 : nth? D1BodySized.ks 377 = some 1936
kernel_rfl D1BodySized.checked377 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s377 D1BodySized.S377) =
    fun _ => some (D1BodySized.s378, D1BodySized.S378)

theorem D1BodySized.k377 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s377 D1BodySized.S377 =
      some (D1BodySized.s378, D1BodySized.S378) := congrFun D1BodySized.checked377 bs

end Host.Load.Run.Tpl
end

section -- SB110
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment110 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s377 D1BodySized.S377 =
      some (D1BodySized.s378, D1BodySized.S378) := D1BodySized.k377 bs

kernel_rfl D1BodySized.accepted110 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s377 D1BodySized.S377) = fun _ => true
kernel_rfl D1BodySized.oracle110 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S377.oracle = true
kernel_rfl D1BodySized.fuelA111 : nth? D1BodySized.ks 378 = some 1
kernel_rfl D1BodySized.fuelB111 : nth? D1BodySized.ks 379 = some 3
kernel_rfl D1BodySized.stepA111 : interpS (step D1BodySized.F D1BodySized.s378).run D1BodySized.S378 =
  some (D1BodySized.s379, D1BodySized.S379)
kernel_rfl D1BodySized.patchB111 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s379).run D1BodySized.S379 =
  some (D1BodySized.s380, D1BodySized.S380)
kernel_rfl D1BodySized.acceptedP111 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s378 D1BodySized.S378) = fun _ => true
kernel_rfl D1BodySized.haltP111 : isHalt D1BodySized.s378.ctl = false
kernel_rfl D1BodySized.topA111 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s379 = true
kernel_rfl D1BodySized.inactive111 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s379.ffi).active = false
/-- Bridge 111's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys111 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s379 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs111 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s379 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA111 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s379 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys111, D1BodySized.sizeArgs111)
kernel_rfl D1BodySized.sizeArgsA111 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s379 = true
kernel_rfl D1BodySized.sizeSymA111 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA111 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA111 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA111 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec111 := interpS (decodeArgs D1BodySized.F D1BodySized.s379 D1BodySized.sizeTys111 D1BodySized.sizeArgs111).run D1BodySized.S379
noncomputable def D1BodySized.sizeAs111 : List Arg := match D1BodySized.sizeDec111 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0111 : SSrv := match D1BodySized.sizeDec111 with | some (_, S) => S | none => D1BodySized.S379
kernel_rfl D1BodySized.sizeDecA111 : interpS (decodeArgs D1BodySized.F D1BodySized.s379 D1BodySized.sizeTys111 D1BodySized.sizeArgs111).run D1BodySized.S379 =
  some (some D1BodySized.sizeAs111, D1BodySized.sizeS0111)
kernel_rfl D1BodySized.sizePreA111 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0111 D1BodySized.s379.ffi D1BodySized.sizeAs111 = true

end Host.Load.Run.Tpl
end

section -- SN380
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel380 : nth? D1BodySized.ks 380 = some 10000
kernel_rfl D1BodySized.checked380 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s380 D1BodySized.S380) =
    fun _ => some (D1BodySized.s381, D1BodySized.S381)

theorem D1BodySized.k380 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s380 D1BodySized.S380 =
      some (D1BodySized.s381, D1BodySized.S381) := congrFun D1BodySized.checked380 bs

end Host.Load.Run.Tpl
end

section -- SN381
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel381 : nth? D1BodySized.ks 381 = some 2570
kernel_rfl D1BodySized.checked381 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s381 D1BodySized.S381) =
    fun _ => some (D1BodySized.s382, D1BodySized.S382)

theorem D1BodySized.k381 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s381 D1BodySized.S381 =
      some (D1BodySized.s382, D1BodySized.S382) := congrFun D1BodySized.checked381 bs

end Host.Load.Run.Tpl
end

section -- SB111
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment111 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s380 D1BodySized.S380 =
      some (D1BodySized.s382, D1BodySized.S382) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s380 D1BodySized.s381 D1BodySized.s382 D1BodySized.S380 D1BodySized.S381 D1BodySized.S382 (D1BodySized.k380 bs) (D1BodySized.k381 bs)

kernel_rfl D1BodySized.accepted111 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s380 D1BodySized.S380) = fun _ => true
kernel_rfl D1BodySized.oracle111 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S380.oracle = true
kernel_rfl D1BodySized.fuelA112 : nth? D1BodySized.ks 382 = some 1
kernel_rfl D1BodySized.fuelB112 : nth? D1BodySized.ks 383 = some 3
kernel_rfl D1BodySized.stepA112 : interpS (step D1BodySized.F D1BodySized.s382).run D1BodySized.S382 =
  some (D1BodySized.s383, D1BodySized.S383)
kernel_rfl D1BodySized.patchB112 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s383).run D1BodySized.S383 =
  some (D1BodySized.s384, D1BodySized.S384)
kernel_rfl D1BodySized.acceptedP112 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s382 D1BodySized.S382) = fun _ => true
kernel_rfl D1BodySized.haltP112 : isHalt D1BodySized.s382.ctl = false
kernel_rfl D1BodySized.topA112 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s383 = true
kernel_rfl D1BodySized.inactive112 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s383.ffi).active = false
/-- Bridge 112's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys112 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s383 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs112 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s383 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA112 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s383 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys112, D1BodySized.sizeArgs112)
kernel_rfl D1BodySized.sizeArgsA112 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s383 = true
kernel_rfl D1BodySized.sizeSymA112 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA112 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA112 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA112 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec112 := interpS (decodeArgs D1BodySized.F D1BodySized.s383 D1BodySized.sizeTys112 D1BodySized.sizeArgs112).run D1BodySized.S383
noncomputable def D1BodySized.sizeAs112 : List Arg := match D1BodySized.sizeDec112 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0112 : SSrv := match D1BodySized.sizeDec112 with | some (_, S) => S | none => D1BodySized.S383
kernel_rfl D1BodySized.sizeDecA112 : interpS (decodeArgs D1BodySized.F D1BodySized.s383 D1BodySized.sizeTys112 D1BodySized.sizeArgs112).run D1BodySized.S383 =
  some (some D1BodySized.sizeAs112, D1BodySized.sizeS0112)
kernel_rfl D1BodySized.sizePreA112 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0112 D1BodySized.s383.ffi D1BodySized.sizeAs112 = true

end Host.Load.Run.Tpl
end

section -- SN384
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel384 : nth? D1BodySized.ks 384 = some 2542
kernel_rfl D1BodySized.checked384 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s384 D1BodySized.S384) =
    fun _ => some (D1BodySized.s385, D1BodySized.S385)

theorem D1BodySized.k384 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s384 D1BodySized.S384 =
      some (D1BodySized.s385, D1BodySized.S385) := congrFun D1BodySized.checked384 bs

end Host.Load.Run.Tpl
end

section -- SB112
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment112 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s384 D1BodySized.S384 =
      some (D1BodySized.s385, D1BodySized.S385) := D1BodySized.k384 bs

kernel_rfl D1BodySized.accepted112 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s384 D1BodySized.S384) = fun _ => true
kernel_rfl D1BodySized.oracle112 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S384.oracle = true
kernel_rfl D1BodySized.fuelA113 : nth? D1BodySized.ks 385 = some 1
kernel_rfl D1BodySized.fuelB113 : nth? D1BodySized.ks 386 = some 3
kernel_rfl D1BodySized.stepA113 : interpS (step D1BodySized.F D1BodySized.s385).run D1BodySized.S385 =
  some (D1BodySized.s386, D1BodySized.S386)
kernel_rfl D1BodySized.patchB113 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s386).run D1BodySized.S386 =
  some (D1BodySized.s387, D1BodySized.S387)
kernel_rfl D1BodySized.acceptedP113 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s385 D1BodySized.S385) = fun _ => true
kernel_rfl D1BodySized.haltP113 : isHalt D1BodySized.s385.ctl = false
kernel_rfl D1BodySized.topA113 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s386 = true
kernel_rfl D1BodySized.inactive113 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s386.ffi).active = false
/-- Bridge 113's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys113 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s386 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs113 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s386 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA113 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s386 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys113, D1BodySized.sizeArgs113)
kernel_rfl D1BodySized.sizeArgsA113 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s386 = true
kernel_rfl D1BodySized.sizeSymA113 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA113 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA113 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA113 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec113 := interpS (decodeArgs D1BodySized.F D1BodySized.s386 D1BodySized.sizeTys113 D1BodySized.sizeArgs113).run D1BodySized.S386
noncomputable def D1BodySized.sizeAs113 : List Arg := match D1BodySized.sizeDec113 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0113 : SSrv := match D1BodySized.sizeDec113 with | some (_, S) => S | none => D1BodySized.S386
kernel_rfl D1BodySized.sizeDecA113 : interpS (decodeArgs D1BodySized.F D1BodySized.s386 D1BodySized.sizeTys113 D1BodySized.sizeArgs113).run D1BodySized.S386 =
  some (some D1BodySized.sizeAs113, D1BodySized.sizeS0113)
kernel_rfl D1BodySized.sizePreA113 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0113 D1BodySized.s386.ffi D1BodySized.sizeAs113 = true

end Host.Load.Run.Tpl
end

section -- SN387
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel387 : nth? D1BodySized.ks 387 = some 7721
kernel_rfl D1BodySized.checked387 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7721 D1BodySized.s387 D1BodySized.S387) =
    fun _ => some (D1BodySized.s388, D1BodySized.S388)

theorem D1BodySized.k387 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7721 D1BodySized.s387 D1BodySized.S387 =
      some (D1BodySized.s388, D1BodySized.S388) := congrFun D1BodySized.checked387 bs

end Host.Load.Run.Tpl
end

section -- SB113
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment113 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7721 D1BodySized.s387 D1BodySized.S387 =
      some (D1BodySized.s388, D1BodySized.S388) := D1BodySized.k387 bs

kernel_rfl D1BodySized.accepted113 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s387 D1BodySized.S387) = fun _ => true
kernel_rfl D1BodySized.oracle113 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S387.oracle = true
kernel_rfl D1BodySized.fuelA114 : nth? D1BodySized.ks 388 = some 1
kernel_rfl D1BodySized.fuelB114 : nth? D1BodySized.ks 389 = some 3
kernel_rfl D1BodySized.stepA114 : interpS (step D1BodySized.F D1BodySized.s388).run D1BodySized.S388 =
  some (D1BodySized.s389, D1BodySized.S389)
kernel_rfl D1BodySized.patchB114 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s389).run D1BodySized.S389 =
  some (D1BodySized.s390, D1BodySized.S390)
kernel_rfl D1BodySized.acceptedP114 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s388 D1BodySized.S388) = fun _ => true
kernel_rfl D1BodySized.haltP114 : isHalt D1BodySized.s388.ctl = false
kernel_rfl D1BodySized.topA114 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s389 = true
kernel_rfl D1BodySized.inactive114 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s389.ffi).active = false
/-- Bridge 114's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys114 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s389 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs114 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s389 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA114 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s389 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys114, D1BodySized.sizeArgs114)
kernel_rfl D1BodySized.sizeArgsA114 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s389 = true
kernel_rfl D1BodySized.sizeSymA114 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA114 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA114 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA114 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec114 := interpS (decodeArgs D1BodySized.F D1BodySized.s389 D1BodySized.sizeTys114 D1BodySized.sizeArgs114).run D1BodySized.S389
noncomputable def D1BodySized.sizeAs114 : List Arg := match D1BodySized.sizeDec114 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0114 : SSrv := match D1BodySized.sizeDec114 with | some (_, S) => S | none => D1BodySized.S389
kernel_rfl D1BodySized.sizeDecA114 : interpS (decodeArgs D1BodySized.F D1BodySized.s389 D1BodySized.sizeTys114 D1BodySized.sizeArgs114).run D1BodySized.S389 =
  some (some D1BodySized.sizeAs114, D1BodySized.sizeS0114)
kernel_rfl D1BodySized.sizePreA114 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0114 D1BodySized.s389.ffi D1BodySized.sizeAs114 = true

end Host.Load.Run.Tpl
end

section -- SN390
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel390 : nth? D1BodySized.ks 390 = some 1936
kernel_rfl D1BodySized.checked390 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s390 D1BodySized.S390) =
    fun _ => some (D1BodySized.s391, D1BodySized.S391)

theorem D1BodySized.k390 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s390 D1BodySized.S390 =
      some (D1BodySized.s391, D1BodySized.S391) := congrFun D1BodySized.checked390 bs

end Host.Load.Run.Tpl
end

section -- SB114
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment114 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s390 D1BodySized.S390 =
      some (D1BodySized.s391, D1BodySized.S391) := D1BodySized.k390 bs

kernel_rfl D1BodySized.accepted114 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s390 D1BodySized.S390) = fun _ => true
kernel_rfl D1BodySized.oracle114 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S390.oracle = true
kernel_rfl D1BodySized.fuelA115 : nth? D1BodySized.ks 391 = some 1
kernel_rfl D1BodySized.fuelB115 : nth? D1BodySized.ks 392 = some 3
kernel_rfl D1BodySized.stepA115 : interpS (step D1BodySized.F D1BodySized.s391).run D1BodySized.S391 =
  some (D1BodySized.s392, D1BodySized.S392)
kernel_rfl D1BodySized.patchB115 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s392).run D1BodySized.S392 =
  some (D1BodySized.s393, D1BodySized.S393)
kernel_rfl D1BodySized.acceptedP115 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s391 D1BodySized.S391) = fun _ => true
kernel_rfl D1BodySized.haltP115 : isHalt D1BodySized.s391.ctl = false
kernel_rfl D1BodySized.topA115 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s392 = true
kernel_rfl D1BodySized.inactive115 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s392.ffi).active = false
/-- Bridge 115's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys115 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s392 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs115 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s392 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA115 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s392 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys115, D1BodySized.sizeArgs115)
kernel_rfl D1BodySized.sizeArgsA115 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s392 = true
kernel_rfl D1BodySized.sizeSymA115 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA115 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA115 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA115 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec115 := interpS (decodeArgs D1BodySized.F D1BodySized.s392 D1BodySized.sizeTys115 D1BodySized.sizeArgs115).run D1BodySized.S392
noncomputable def D1BodySized.sizeAs115 : List Arg := match D1BodySized.sizeDec115 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0115 : SSrv := match D1BodySized.sizeDec115 with | some (_, S) => S | none => D1BodySized.S392
kernel_rfl D1BodySized.sizeDecA115 : interpS (decodeArgs D1BodySized.F D1BodySized.s392 D1BodySized.sizeTys115 D1BodySized.sizeArgs115).run D1BodySized.S392 =
  some (some D1BodySized.sizeAs115, D1BodySized.sizeS0115)
kernel_rfl D1BodySized.sizePreA115 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0115 D1BodySized.s392.ffi D1BodySized.sizeAs115 = true

end Host.Load.Run.Tpl
end

section -- SN393
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel393 : nth? D1BodySized.ks 393 = some 10000
kernel_rfl D1BodySized.checked393 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s393 D1BodySized.S393) =
    fun _ => some (D1BodySized.s394, D1BodySized.S394)

theorem D1BodySized.k393 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s393 D1BodySized.S393 =
      some (D1BodySized.s394, D1BodySized.S394) := congrFun D1BodySized.checked393 bs

end Host.Load.Run.Tpl
end

section -- SN394
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel394 : nth? D1BodySized.ks 394 = some 2570
kernel_rfl D1BodySized.checked394 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s394 D1BodySized.S394) =
    fun _ => some (D1BodySized.s395, D1BodySized.S395)

theorem D1BodySized.k394 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s394 D1BodySized.S394 =
      some (D1BodySized.s395, D1BodySized.S395) := congrFun D1BodySized.checked394 bs

end Host.Load.Run.Tpl
end

section -- SB115
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment115 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s393 D1BodySized.S393 =
      some (D1BodySized.s395, D1BodySized.S395) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s393 D1BodySized.s394 D1BodySized.s395 D1BodySized.S393 D1BodySized.S394 D1BodySized.S395 (D1BodySized.k393 bs) (D1BodySized.k394 bs)

kernel_rfl D1BodySized.accepted115 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s393 D1BodySized.S393) = fun _ => true
kernel_rfl D1BodySized.oracle115 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S393.oracle = true
kernel_rfl D1BodySized.fuelA116 : nth? D1BodySized.ks 395 = some 1
kernel_rfl D1BodySized.fuelB116 : nth? D1BodySized.ks 396 = some 3
kernel_rfl D1BodySized.stepA116 : interpS (step D1BodySized.F D1BodySized.s395).run D1BodySized.S395 =
  some (D1BodySized.s396, D1BodySized.S396)
kernel_rfl D1BodySized.patchB116 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s396).run D1BodySized.S396 =
  some (D1BodySized.s397, D1BodySized.S397)
kernel_rfl D1BodySized.acceptedP116 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s395 D1BodySized.S395) = fun _ => true
kernel_rfl D1BodySized.haltP116 : isHalt D1BodySized.s395.ctl = false
kernel_rfl D1BodySized.topA116 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s396 = true
kernel_rfl D1BodySized.inactive116 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s396.ffi).active = false
/-- Bridge 116's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys116 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s396 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs116 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s396 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA116 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s396 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys116, D1BodySized.sizeArgs116)
kernel_rfl D1BodySized.sizeArgsA116 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s396 = true
kernel_rfl D1BodySized.sizeSymA116 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA116 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA116 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA116 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec116 := interpS (decodeArgs D1BodySized.F D1BodySized.s396 D1BodySized.sizeTys116 D1BodySized.sizeArgs116).run D1BodySized.S396
noncomputable def D1BodySized.sizeAs116 : List Arg := match D1BodySized.sizeDec116 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0116 : SSrv := match D1BodySized.sizeDec116 with | some (_, S) => S | none => D1BodySized.S396
kernel_rfl D1BodySized.sizeDecA116 : interpS (decodeArgs D1BodySized.F D1BodySized.s396 D1BodySized.sizeTys116 D1BodySized.sizeArgs116).run D1BodySized.S396 =
  some (some D1BodySized.sizeAs116, D1BodySized.sizeS0116)
kernel_rfl D1BodySized.sizePreA116 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0116 D1BodySized.s396.ffi D1BodySized.sizeAs116 = true

end Host.Load.Run.Tpl
end

section -- SN397
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel397 : nth? D1BodySized.ks 397 = some 2542
kernel_rfl D1BodySized.checked397 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s397 D1BodySized.S397) =
    fun _ => some (D1BodySized.s398, D1BodySized.S398)

theorem D1BodySized.k397 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s397 D1BodySized.S397 =
      some (D1BodySized.s398, D1BodySized.S398) := congrFun D1BodySized.checked397 bs

end Host.Load.Run.Tpl
end

section -- SB116
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment116 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s397 D1BodySized.S397 =
      some (D1BodySized.s398, D1BodySized.S398) := D1BodySized.k397 bs

kernel_rfl D1BodySized.accepted116 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s397 D1BodySized.S397) = fun _ => true
kernel_rfl D1BodySized.oracle116 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S397.oracle = true
kernel_rfl D1BodySized.fuelA117 : nth? D1BodySized.ks 398 = some 1
kernel_rfl D1BodySized.fuelB117 : nth? D1BodySized.ks 399 = some 3
kernel_rfl D1BodySized.stepA117 : interpS (step D1BodySized.F D1BodySized.s398).run D1BodySized.S398 =
  some (D1BodySized.s399, D1BodySized.S399)
kernel_rfl D1BodySized.patchB117 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s399).run D1BodySized.S399 =
  some (D1BodySized.s400, D1BodySized.S400)
kernel_rfl D1BodySized.acceptedP117 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s398 D1BodySized.S398) = fun _ => true
kernel_rfl D1BodySized.haltP117 : isHalt D1BodySized.s398.ctl = false
kernel_rfl D1BodySized.topA117 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s399 = true
kernel_rfl D1BodySized.inactive117 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s399.ffi).active = false
/-- Bridge 117's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys117 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s399 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs117 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s399 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA117 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s399 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys117, D1BodySized.sizeArgs117)
kernel_rfl D1BodySized.sizeArgsA117 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s399 = true
kernel_rfl D1BodySized.sizeSymA117 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA117 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA117 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA117 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec117 := interpS (decodeArgs D1BodySized.F D1BodySized.s399 D1BodySized.sizeTys117 D1BodySized.sizeArgs117).run D1BodySized.S399
noncomputable def D1BodySized.sizeAs117 : List Arg := match D1BodySized.sizeDec117 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0117 : SSrv := match D1BodySized.sizeDec117 with | some (_, S) => S | none => D1BodySized.S399
kernel_rfl D1BodySized.sizeDecA117 : interpS (decodeArgs D1BodySized.F D1BodySized.s399 D1BodySized.sizeTys117 D1BodySized.sizeArgs117).run D1BodySized.S399 =
  some (some D1BodySized.sizeAs117, D1BodySized.sizeS0117)
kernel_rfl D1BodySized.sizePreA117 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0117 D1BodySized.s399.ffi D1BodySized.sizeAs117 = true

end Host.Load.Run.Tpl
end

section -- SN400
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel400 : nth? D1BodySized.ks 400 = some 7716
kernel_rfl D1BodySized.checked400 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s400 D1BodySized.S400) =
    fun _ => some (D1BodySized.s401, D1BodySized.S401)

theorem D1BodySized.k400 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s400 D1BodySized.S400 =
      some (D1BodySized.s401, D1BodySized.S401) := congrFun D1BodySized.checked400 bs

end Host.Load.Run.Tpl
end

section -- SB117
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment117 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s400 D1BodySized.S400 =
      some (D1BodySized.s401, D1BodySized.S401) := D1BodySized.k400 bs

kernel_rfl D1BodySized.accepted117 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s400 D1BodySized.S400) = fun _ => true
kernel_rfl D1BodySized.oracle117 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S400.oracle = true
kernel_rfl D1BodySized.fuelA118 : nth? D1BodySized.ks 401 = some 1
kernel_rfl D1BodySized.fuelB118 : nth? D1BodySized.ks 402 = some 3
kernel_rfl D1BodySized.stepA118 : interpS (step D1BodySized.F D1BodySized.s401).run D1BodySized.S401 =
  some (D1BodySized.s402, D1BodySized.S402)
kernel_rfl D1BodySized.patchB118 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s402).run D1BodySized.S402 =
  some (D1BodySized.s403, D1BodySized.S403)
kernel_rfl D1BodySized.acceptedP118 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s401 D1BodySized.S401) = fun _ => true
kernel_rfl D1BodySized.haltP118 : isHalt D1BodySized.s401.ctl = false
kernel_rfl D1BodySized.topA118 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s402 = true
kernel_rfl D1BodySized.inactive118 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s402.ffi).active = false
/-- Bridge 118's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys118 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s402 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs118 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s402 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA118 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s402 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys118, D1BodySized.sizeArgs118)
kernel_rfl D1BodySized.sizeArgsA118 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s402 = true
kernel_rfl D1BodySized.sizeSymA118 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA118 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA118 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA118 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec118 := interpS (decodeArgs D1BodySized.F D1BodySized.s402 D1BodySized.sizeTys118 D1BodySized.sizeArgs118).run D1BodySized.S402
noncomputable def D1BodySized.sizeAs118 : List Arg := match D1BodySized.sizeDec118 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0118 : SSrv := match D1BodySized.sizeDec118 with | some (_, S) => S | none => D1BodySized.S402
kernel_rfl D1BodySized.sizeDecA118 : interpS (decodeArgs D1BodySized.F D1BodySized.s402 D1BodySized.sizeTys118 D1BodySized.sizeArgs118).run D1BodySized.S402 =
  some (some D1BodySized.sizeAs118, D1BodySized.sizeS0118)
kernel_rfl D1BodySized.sizePreA118 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0118 D1BodySized.s402.ffi D1BodySized.sizeAs118 = true

end Host.Load.Run.Tpl
end

section -- SN403
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel403 : nth? D1BodySized.ks 403 = some 1936
kernel_rfl D1BodySized.checked403 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s403 D1BodySized.S403) =
    fun _ => some (D1BodySized.s404, D1BodySized.S404)

theorem D1BodySized.k403 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s403 D1BodySized.S403 =
      some (D1BodySized.s404, D1BodySized.S404) := congrFun D1BodySized.checked403 bs

end Host.Load.Run.Tpl
end

section -- SB118
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment118 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s403 D1BodySized.S403 =
      some (D1BodySized.s404, D1BodySized.S404) := D1BodySized.k403 bs

kernel_rfl D1BodySized.accepted118 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s403 D1BodySized.S403) = fun _ => true
kernel_rfl D1BodySized.oracle118 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S403.oracle = true
kernel_rfl D1BodySized.fuelA119 : nth? D1BodySized.ks 404 = some 1
kernel_rfl D1BodySized.fuelB119 : nth? D1BodySized.ks 405 = some 3
kernel_rfl D1BodySized.stepA119 : interpS (step D1BodySized.F D1BodySized.s404).run D1BodySized.S404 =
  some (D1BodySized.s405, D1BodySized.S405)
kernel_rfl D1BodySized.patchB119 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s405).run D1BodySized.S405 =
  some (D1BodySized.s406, D1BodySized.S406)
kernel_rfl D1BodySized.acceptedP119 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s404 D1BodySized.S404) = fun _ => true
kernel_rfl D1BodySized.haltP119 : isHalt D1BodySized.s404.ctl = false
kernel_rfl D1BodySized.topA119 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s405 = true
kernel_rfl D1BodySized.inactive119 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s405.ffi).active = false
/-- Bridge 119's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys119 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s405 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs119 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s405 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA119 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s405 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys119, D1BodySized.sizeArgs119)
kernel_rfl D1BodySized.sizeArgsA119 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s405 = true
kernel_rfl D1BodySized.sizeSymA119 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA119 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA119 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA119 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec119 := interpS (decodeArgs D1BodySized.F D1BodySized.s405 D1BodySized.sizeTys119 D1BodySized.sizeArgs119).run D1BodySized.S405
noncomputable def D1BodySized.sizeAs119 : List Arg := match D1BodySized.sizeDec119 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0119 : SSrv := match D1BodySized.sizeDec119 with | some (_, S) => S | none => D1BodySized.S405
kernel_rfl D1BodySized.sizeDecA119 : interpS (decodeArgs D1BodySized.F D1BodySized.s405 D1BodySized.sizeTys119 D1BodySized.sizeArgs119).run D1BodySized.S405 =
  some (some D1BodySized.sizeAs119, D1BodySized.sizeS0119)
kernel_rfl D1BodySized.sizePreA119 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0119 D1BodySized.s405.ffi D1BodySized.sizeAs119 = true

end Host.Load.Run.Tpl
end

section -- SN406
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel406 : nth? D1BodySized.ks 406 = some 10000
kernel_rfl D1BodySized.checked406 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s406 D1BodySized.S406) =
    fun _ => some (D1BodySized.s407, D1BodySized.S407)

theorem D1BodySized.k406 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s406 D1BodySized.S406 =
      some (D1BodySized.s407, D1BodySized.S407) := congrFun D1BodySized.checked406 bs

end Host.Load.Run.Tpl
end

section -- SN407
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel407 : nth? D1BodySized.ks 407 = some 2570
kernel_rfl D1BodySized.checked407 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s407 D1BodySized.S407) =
    fun _ => some (D1BodySized.s408, D1BodySized.S408)

theorem D1BodySized.k407 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s407 D1BodySized.S407 =
      some (D1BodySized.s408, D1BodySized.S408) := congrFun D1BodySized.checked407 bs

end Host.Load.Run.Tpl
end

section -- SB119
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment119 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s406 D1BodySized.S406 =
      some (D1BodySized.s408, D1BodySized.S408) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s406 D1BodySized.s407 D1BodySized.s408 D1BodySized.S406 D1BodySized.S407 D1BodySized.S408 (D1BodySized.k406 bs) (D1BodySized.k407 bs)

kernel_rfl D1BodySized.accepted119 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s406 D1BodySized.S406) = fun _ => true
kernel_rfl D1BodySized.oracle119 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S406.oracle = true
kernel_rfl D1BodySized.fuelA120 : nth? D1BodySized.ks 408 = some 1
kernel_rfl D1BodySized.fuelB120 : nth? D1BodySized.ks 409 = some 3
kernel_rfl D1BodySized.stepA120 : interpS (step D1BodySized.F D1BodySized.s408).run D1BodySized.S408 =
  some (D1BodySized.s409, D1BodySized.S409)
kernel_rfl D1BodySized.patchB120 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s409).run D1BodySized.S409 =
  some (D1BodySized.s410, D1BodySized.S410)
kernel_rfl D1BodySized.acceptedP120 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s408 D1BodySized.S408) = fun _ => true
kernel_rfl D1BodySized.haltP120 : isHalt D1BodySized.s408.ctl = false
kernel_rfl D1BodySized.topA120 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s409 = true
kernel_rfl D1BodySized.inactive120 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s409.ffi).active = false
/-- Bridge 120's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys120 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s409 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs120 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s409 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA120 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s409 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys120, D1BodySized.sizeArgs120)
kernel_rfl D1BodySized.sizeArgsA120 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s409 = true
kernel_rfl D1BodySized.sizeSymA120 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA120 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA120 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA120 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec120 := interpS (decodeArgs D1BodySized.F D1BodySized.s409 D1BodySized.sizeTys120 D1BodySized.sizeArgs120).run D1BodySized.S409
noncomputable def D1BodySized.sizeAs120 : List Arg := match D1BodySized.sizeDec120 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0120 : SSrv := match D1BodySized.sizeDec120 with | some (_, S) => S | none => D1BodySized.S409
kernel_rfl D1BodySized.sizeDecA120 : interpS (decodeArgs D1BodySized.F D1BodySized.s409 D1BodySized.sizeTys120 D1BodySized.sizeArgs120).run D1BodySized.S409 =
  some (some D1BodySized.sizeAs120, D1BodySized.sizeS0120)
kernel_rfl D1BodySized.sizePreA120 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0120 D1BodySized.s409.ffi D1BodySized.sizeAs120 = true

end Host.Load.Run.Tpl
end

section -- SN410
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel410 : nth? D1BodySized.ks 410 = some 2542
kernel_rfl D1BodySized.checked410 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s410 D1BodySized.S410) =
    fun _ => some (D1BodySized.s411, D1BodySized.S411)

theorem D1BodySized.k410 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s410 D1BodySized.S410 =
      some (D1BodySized.s411, D1BodySized.S411) := congrFun D1BodySized.checked410 bs

end Host.Load.Run.Tpl
end

section -- SB120
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment120 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s410 D1BodySized.S410 =
      some (D1BodySized.s411, D1BodySized.S411) := D1BodySized.k410 bs

kernel_rfl D1BodySized.accepted120 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s410 D1BodySized.S410) = fun _ => true
kernel_rfl D1BodySized.oracle120 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S410.oracle = true
kernel_rfl D1BodySized.fuelA121 : nth? D1BodySized.ks 411 = some 1
kernel_rfl D1BodySized.fuelB121 : nth? D1BodySized.ks 412 = some 3
kernel_rfl D1BodySized.stepA121 : interpS (step D1BodySized.F D1BodySized.s411).run D1BodySized.S411 =
  some (D1BodySized.s412, D1BodySized.S412)
kernel_rfl D1BodySized.patchB121 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s412).run D1BodySized.S412 =
  some (D1BodySized.s413, D1BodySized.S413)
kernel_rfl D1BodySized.acceptedP121 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s411 D1BodySized.S411) = fun _ => true
kernel_rfl D1BodySized.haltP121 : isHalt D1BodySized.s411.ctl = false
kernel_rfl D1BodySized.topA121 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s412 = true
kernel_rfl D1BodySized.inactive121 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s412.ffi).active = false
/-- Bridge 121's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys121 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s412 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs121 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s412 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA121 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s412 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys121, D1BodySized.sizeArgs121)
kernel_rfl D1BodySized.sizeArgsA121 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s412 = true
kernel_rfl D1BodySized.sizeSymA121 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA121 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA121 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA121 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec121 := interpS (decodeArgs D1BodySized.F D1BodySized.s412 D1BodySized.sizeTys121 D1BodySized.sizeArgs121).run D1BodySized.S412
noncomputable def D1BodySized.sizeAs121 : List Arg := match D1BodySized.sizeDec121 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0121 : SSrv := match D1BodySized.sizeDec121 with | some (_, S) => S | none => D1BodySized.S412
kernel_rfl D1BodySized.sizeDecA121 : interpS (decodeArgs D1BodySized.F D1BodySized.s412 D1BodySized.sizeTys121 D1BodySized.sizeArgs121).run D1BodySized.S412 =
  some (some D1BodySized.sizeAs121, D1BodySized.sizeS0121)
kernel_rfl D1BodySized.sizePreA121 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0121 D1BodySized.s412.ffi D1BodySized.sizeAs121 = true

end Host.Load.Run.Tpl
end

section -- SN413
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel413 : nth? D1BodySized.ks 413 = some 10000
kernel_rfl D1BodySized.checked413 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s413 D1BodySized.S413) =
    fun _ => some (D1BodySized.s414, D1BodySized.S414)

theorem D1BodySized.k413 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s413 D1BodySized.S413 =
      some (D1BodySized.s414, D1BodySized.S414) := congrFun D1BodySized.checked413 bs

end Host.Load.Run.Tpl
end

section -- SN414
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel414 : nth? D1BodySized.ks 414 = some 10000
kernel_rfl D1BodySized.checked414 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s414 D1BodySized.S414) =
    fun _ => some (D1BodySized.s415, D1BodySized.S415)

theorem D1BodySized.k414 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s414 D1BodySized.S414 =
      some (D1BodySized.s415, D1BodySized.S415) := congrFun D1BodySized.checked414 bs

end Host.Load.Run.Tpl
end

section -- SN415
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel415 : nth? D1BodySized.ks 415 = some 2287
kernel_rfl D1BodySized.checked415 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s415 D1BodySized.S415) =
    fun _ => some (D1BodySized.s416, D1BodySized.S416)

theorem D1BodySized.k415 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s415 D1BodySized.S415 =
      some (D1BodySized.s416, D1BodySized.S416) := congrFun D1BodySized.checked415 bs

end Host.Load.Run.Tpl
end

section -- SB121
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment121 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22287 D1BodySized.s413 D1BodySized.S413 =
      some (D1BodySized.s416, D1BodySized.S416) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2287 D1BodySized.s413 D1BodySized.s415 D1BodySized.s416 D1BodySized.S413 D1BodySized.S415 D1BodySized.S416 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s413 D1BodySized.s414 D1BodySized.s415 D1BodySized.S413 D1BodySized.S414 D1BodySized.S415 (D1BodySized.k413 bs) (D1BodySized.k414 bs)) (D1BodySized.k415 bs)

kernel_rfl D1BodySized.accepted121 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s413 D1BodySized.S413) = fun _ => true
kernel_rfl D1BodySized.oracle121 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S413.oracle = true
kernel_rfl D1BodySized.fuelA122 : nth? D1BodySized.ks 416 = some 1
kernel_rfl D1BodySized.fuelB122 : nth? D1BodySized.ks 417 = some 3
kernel_rfl D1BodySized.stepA122 : interpS (step D1BodySized.F D1BodySized.s416).run D1BodySized.S416 =
  some (D1BodySized.s417, D1BodySized.S417)
kernel_rfl D1BodySized.patchB122 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s417).run D1BodySized.S417 =
  some (D1BodySized.s418, D1BodySized.S418)
kernel_rfl D1BodySized.acceptedP122 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s416 D1BodySized.S416) = fun _ => true
kernel_rfl D1BodySized.haltP122 : isHalt D1BodySized.s416.ctl = false
kernel_rfl D1BodySized.topA122 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s417 = true
kernel_rfl D1BodySized.inactive122 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s417.ffi).active = false
/-- Bridge 122's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys122 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s417 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs122 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s417 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA122 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s417 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys122, D1BodySized.sizeArgs122)
kernel_rfl D1BodySized.sizeArgsA122 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s417 = true
kernel_rfl D1BodySized.sizeSymA122 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA122 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA122 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA122 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec122 := interpS (decodeArgs D1BodySized.F D1BodySized.s417 D1BodySized.sizeTys122 D1BodySized.sizeArgs122).run D1BodySized.S417
noncomputable def D1BodySized.sizeAs122 : List Arg := match D1BodySized.sizeDec122 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0122 : SSrv := match D1BodySized.sizeDec122 with | some (_, S) => S | none => D1BodySized.S417
kernel_rfl D1BodySized.sizeDecA122 : interpS (decodeArgs D1BodySized.F D1BodySized.s417 D1BodySized.sizeTys122 D1BodySized.sizeArgs122).run D1BodySized.S417 =
  some (some D1BodySized.sizeAs122, D1BodySized.sizeS0122)
kernel_rfl D1BodySized.sizePreA122 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0122 D1BodySized.s417.ffi D1BodySized.sizeAs122 = true

end Host.Load.Run.Tpl
end
