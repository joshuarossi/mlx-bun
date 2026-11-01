import host.sim.template.a4pre_d1_body.m.B00
import host.sim.template.a4pre_d1_body.TraceStep
import host.sim.Chunk
import host.sim.template.a4pre_d1_body.SizeLift

section -- SN418
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel418 : nth? D1BodySized.ks 418 = some 7934
kernel_rfl D1BodySized.checked418 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s418 D1BodySized.S418) =
    fun _ => some (D1BodySized.s419, D1BodySized.S419)

theorem D1BodySized.k418 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s418 D1BodySized.S418 =
      some (D1BodySized.s419, D1BodySized.S419) := congrFun D1BodySized.checked418 bs

end Host.Load.Run.Tpl
end

section -- SB122
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment122 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s418 D1BodySized.S418 =
      some (D1BodySized.s419, D1BodySized.S419) := D1BodySized.k418 bs

kernel_rfl D1BodySized.accepted122 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s418 D1BodySized.S418) = fun _ => true
kernel_rfl D1BodySized.oracle122 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S418.oracle = true
kernel_rfl D1BodySized.fuelA123 : nth? D1BodySized.ks 419 = some 1
kernel_rfl D1BodySized.fuelB123 : nth? D1BodySized.ks 420 = some 3
kernel_rfl D1BodySized.stepA123 : interpS (step D1BodySized.F D1BodySized.s419).run D1BodySized.S419 =
  some (D1BodySized.s420, D1BodySized.S420)
kernel_rfl D1BodySized.patchB123 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s420).run D1BodySized.S420 =
  some (D1BodySized.s421, D1BodySized.S421)
kernel_rfl D1BodySized.acceptedP123 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s419 D1BodySized.S419) = fun _ => true
kernel_rfl D1BodySized.haltP123 : isHalt D1BodySized.s419.ctl = false
kernel_rfl D1BodySized.topA123 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s420 = true
kernel_rfl D1BodySized.inactive123 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s420.ffi).active = false
/-- Bridge 123's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys123 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s420 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs123 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s420 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA123 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s420 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys123, D1BodySized.sizeArgs123)
kernel_rfl D1BodySized.sizeArgsA123 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s420 = true
kernel_rfl D1BodySized.sizeSymA123 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA123 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA123 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA123 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec123 := interpS (decodeArgs D1BodySized.F D1BodySized.s420 D1BodySized.sizeTys123 D1BodySized.sizeArgs123).run D1BodySized.S420
noncomputable def D1BodySized.sizeAs123 : List Arg := match D1BodySized.sizeDec123 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0123 : SSrv := match D1BodySized.sizeDec123 with | some (_, S) => S | none => D1BodySized.S420
kernel_rfl D1BodySized.sizeDecA123 : interpS (decodeArgs D1BodySized.F D1BodySized.s420 D1BodySized.sizeTys123 D1BodySized.sizeArgs123).run D1BodySized.S420 =
  some (some D1BodySized.sizeAs123, D1BodySized.sizeS0123)
kernel_rfl D1BodySized.sizePreA123 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0123 D1BodySized.s420.ffi D1BodySized.sizeAs123 = true

end Host.Load.Run.Tpl
end

section -- SN421
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel421 : nth? D1BodySized.ks 421 = some 1936
kernel_rfl D1BodySized.checked421 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s421 D1BodySized.S421) =
    fun _ => some (D1BodySized.s422, D1BodySized.S422)

theorem D1BodySized.k421 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s421 D1BodySized.S421 =
      some (D1BodySized.s422, D1BodySized.S422) := congrFun D1BodySized.checked421 bs

end Host.Load.Run.Tpl
end

section -- SB123
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment123 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s421 D1BodySized.S421 =
      some (D1BodySized.s422, D1BodySized.S422) := D1BodySized.k421 bs

kernel_rfl D1BodySized.accepted123 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s421 D1BodySized.S421) = fun _ => true
kernel_rfl D1BodySized.oracle123 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S421.oracle = true
kernel_rfl D1BodySized.fuelA124 : nth? D1BodySized.ks 422 = some 1
kernel_rfl D1BodySized.fuelB124 : nth? D1BodySized.ks 423 = some 3
kernel_rfl D1BodySized.stepA124 : interpS (step D1BodySized.F D1BodySized.s422).run D1BodySized.S422 =
  some (D1BodySized.s423, D1BodySized.S423)
kernel_rfl D1BodySized.patchB124 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s423).run D1BodySized.S423 =
  some (D1BodySized.s424, D1BodySized.S424)
kernel_rfl D1BodySized.acceptedP124 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s422 D1BodySized.S422) = fun _ => true
kernel_rfl D1BodySized.haltP124 : isHalt D1BodySized.s422.ctl = false
kernel_rfl D1BodySized.topA124 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s423 = true
kernel_rfl D1BodySized.inactive124 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s423.ffi).active = false
/-- Bridge 124's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys124 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s423 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs124 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s423 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA124 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s423 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys124, D1BodySized.sizeArgs124)
kernel_rfl D1BodySized.sizeArgsA124 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s423 = true
kernel_rfl D1BodySized.sizeSymA124 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA124 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA124 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA124 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec124 := interpS (decodeArgs D1BodySized.F D1BodySized.s423 D1BodySized.sizeTys124 D1BodySized.sizeArgs124).run D1BodySized.S423
noncomputable def D1BodySized.sizeAs124 : List Arg := match D1BodySized.sizeDec124 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0124 : SSrv := match D1BodySized.sizeDec124 with | some (_, S) => S | none => D1BodySized.S423
kernel_rfl D1BodySized.sizeDecA124 : interpS (decodeArgs D1BodySized.F D1BodySized.s423 D1BodySized.sizeTys124 D1BodySized.sizeArgs124).run D1BodySized.S423 =
  some (some D1BodySized.sizeAs124, D1BodySized.sizeS0124)
kernel_rfl D1BodySized.sizePreA124 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0124 D1BodySized.s423.ffi D1BodySized.sizeAs124 = true

end Host.Load.Run.Tpl
end

section -- SN424
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel424 : nth? D1BodySized.ks 424 = some 10000
kernel_rfl D1BodySized.checked424 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s424 D1BodySized.S424) =
    fun _ => some (D1BodySized.s425, D1BodySized.S425)

theorem D1BodySized.k424 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s424 D1BodySized.S424 =
      some (D1BodySized.s425, D1BodySized.S425) := congrFun D1BodySized.checked424 bs

end Host.Load.Run.Tpl
end

section -- SN425
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel425 : nth? D1BodySized.ks 425 = some 2570
kernel_rfl D1BodySized.checked425 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s425 D1BodySized.S425) =
    fun _ => some (D1BodySized.s426, D1BodySized.S426)

theorem D1BodySized.k425 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s425 D1BodySized.S425 =
      some (D1BodySized.s426, D1BodySized.S426) := congrFun D1BodySized.checked425 bs

end Host.Load.Run.Tpl
end

section -- SB124
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment124 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s424 D1BodySized.S424 =
      some (D1BodySized.s426, D1BodySized.S426) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s424 D1BodySized.s425 D1BodySized.s426 D1BodySized.S424 D1BodySized.S425 D1BodySized.S426 (D1BodySized.k424 bs) (D1BodySized.k425 bs)

kernel_rfl D1BodySized.accepted124 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s424 D1BodySized.S424) = fun _ => true
kernel_rfl D1BodySized.oracle124 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S424.oracle = true
kernel_rfl D1BodySized.fuelA125 : nth? D1BodySized.ks 426 = some 1
kernel_rfl D1BodySized.fuelB125 : nth? D1BodySized.ks 427 = some 3
kernel_rfl D1BodySized.stepA125 : interpS (step D1BodySized.F D1BodySized.s426).run D1BodySized.S426 =
  some (D1BodySized.s427, D1BodySized.S427)
kernel_rfl D1BodySized.patchB125 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s427).run D1BodySized.S427 =
  some (D1BodySized.s428, D1BodySized.S428)
kernel_rfl D1BodySized.acceptedP125 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s426 D1BodySized.S426) = fun _ => true
kernel_rfl D1BodySized.haltP125 : isHalt D1BodySized.s426.ctl = false
kernel_rfl D1BodySized.topA125 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s427 = true
kernel_rfl D1BodySized.inactive125 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s427.ffi).active = false
/-- Bridge 125's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys125 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s427 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs125 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s427 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA125 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s427 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys125, D1BodySized.sizeArgs125)
kernel_rfl D1BodySized.sizeArgsA125 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s427 = true
kernel_rfl D1BodySized.sizeSymA125 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA125 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA125 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA125 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec125 := interpS (decodeArgs D1BodySized.F D1BodySized.s427 D1BodySized.sizeTys125 D1BodySized.sizeArgs125).run D1BodySized.S427
noncomputable def D1BodySized.sizeAs125 : List Arg := match D1BodySized.sizeDec125 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0125 : SSrv := match D1BodySized.sizeDec125 with | some (_, S) => S | none => D1BodySized.S427
kernel_rfl D1BodySized.sizeDecA125 : interpS (decodeArgs D1BodySized.F D1BodySized.s427 D1BodySized.sizeTys125 D1BodySized.sizeArgs125).run D1BodySized.S427 =
  some (some D1BodySized.sizeAs125, D1BodySized.sizeS0125)
kernel_rfl D1BodySized.sizePreA125 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0125 D1BodySized.s427.ffi D1BodySized.sizeAs125 = true

end Host.Load.Run.Tpl
end

section -- SN428
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel428 : nth? D1BodySized.ks 428 = some 2542
kernel_rfl D1BodySized.checked428 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s428 D1BodySized.S428) =
    fun _ => some (D1BodySized.s429, D1BodySized.S429)

theorem D1BodySized.k428 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s428 D1BodySized.S428 =
      some (D1BodySized.s429, D1BodySized.S429) := congrFun D1BodySized.checked428 bs

end Host.Load.Run.Tpl
end

section -- SB125
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment125 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s428 D1BodySized.S428 =
      some (D1BodySized.s429, D1BodySized.S429) := D1BodySized.k428 bs

kernel_rfl D1BodySized.accepted125 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s428 D1BodySized.S428) = fun _ => true
kernel_rfl D1BodySized.oracle125 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S428.oracle = true
kernel_rfl D1BodySized.fuelA126 : nth? D1BodySized.ks 429 = some 1
kernel_rfl D1BodySized.fuelB126 : nth? D1BodySized.ks 430 = some 3
kernel_rfl D1BodySized.stepA126 : interpS (step D1BodySized.F D1BodySized.s429).run D1BodySized.S429 =
  some (D1BodySized.s430, D1BodySized.S430)
kernel_rfl D1BodySized.patchB126 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s430).run D1BodySized.S430 =
  some (D1BodySized.s431, D1BodySized.S431)
kernel_rfl D1BodySized.acceptedP126 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s429 D1BodySized.S429) = fun _ => true
kernel_rfl D1BodySized.haltP126 : isHalt D1BodySized.s429.ctl = false
kernel_rfl D1BodySized.topA126 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s430 = true
kernel_rfl D1BodySized.inactive126 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s430.ffi).active = false
/-- Bridge 126's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys126 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s430 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs126 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s430 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA126 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s430 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys126, D1BodySized.sizeArgs126)
kernel_rfl D1BodySized.sizeArgsA126 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s430 = true
kernel_rfl D1BodySized.sizeSymA126 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA126 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA126 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA126 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec126 := interpS (decodeArgs D1BodySized.F D1BodySized.s430 D1BodySized.sizeTys126 D1BodySized.sizeArgs126).run D1BodySized.S430
noncomputable def D1BodySized.sizeAs126 : List Arg := match D1BodySized.sizeDec126 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0126 : SSrv := match D1BodySized.sizeDec126 with | some (_, S) => S | none => D1BodySized.S430
kernel_rfl D1BodySized.sizeDecA126 : interpS (decodeArgs D1BodySized.F D1BodySized.s430 D1BodySized.sizeTys126 D1BodySized.sizeArgs126).run D1BodySized.S430 =
  some (some D1BodySized.sizeAs126, D1BodySized.sizeS0126)
kernel_rfl D1BodySized.sizePreA126 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0126 D1BodySized.s430.ffi D1BodySized.sizeAs126 = true

end Host.Load.Run.Tpl
end

section -- SN431
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel431 : nth? D1BodySized.ks 431 = some 7716
kernel_rfl D1BodySized.checked431 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s431 D1BodySized.S431) =
    fun _ => some (D1BodySized.s432, D1BodySized.S432)

theorem D1BodySized.k431 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s431 D1BodySized.S431 =
      some (D1BodySized.s432, D1BodySized.S432) := congrFun D1BodySized.checked431 bs

end Host.Load.Run.Tpl
end

section -- SB126
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment126 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s431 D1BodySized.S431 =
      some (D1BodySized.s432, D1BodySized.S432) := D1BodySized.k431 bs

kernel_rfl D1BodySized.accepted126 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s431 D1BodySized.S431) = fun _ => true
kernel_rfl D1BodySized.oracle126 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S431.oracle = true
kernel_rfl D1BodySized.fuelA127 : nth? D1BodySized.ks 432 = some 1
kernel_rfl D1BodySized.fuelB127 : nth? D1BodySized.ks 433 = some 3
kernel_rfl D1BodySized.stepA127 : interpS (step D1BodySized.F D1BodySized.s432).run D1BodySized.S432 =
  some (D1BodySized.s433, D1BodySized.S433)
kernel_rfl D1BodySized.patchB127 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s433).run D1BodySized.S433 =
  some (D1BodySized.s434, D1BodySized.S434)
kernel_rfl D1BodySized.acceptedP127 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s432 D1BodySized.S432) = fun _ => true
kernel_rfl D1BodySized.haltP127 : isHalt D1BodySized.s432.ctl = false
kernel_rfl D1BodySized.topA127 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s433 = true
kernel_rfl D1BodySized.inactive127 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s433.ffi).active = false
/-- Bridge 127's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys127 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s433 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs127 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s433 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA127 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s433 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys127, D1BodySized.sizeArgs127)
kernel_rfl D1BodySized.sizeArgsA127 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s433 = true
kernel_rfl D1BodySized.sizeSymA127 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA127 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA127 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA127 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec127 := interpS (decodeArgs D1BodySized.F D1BodySized.s433 D1BodySized.sizeTys127 D1BodySized.sizeArgs127).run D1BodySized.S433
noncomputable def D1BodySized.sizeAs127 : List Arg := match D1BodySized.sizeDec127 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0127 : SSrv := match D1BodySized.sizeDec127 with | some (_, S) => S | none => D1BodySized.S433
kernel_rfl D1BodySized.sizeDecA127 : interpS (decodeArgs D1BodySized.F D1BodySized.s433 D1BodySized.sizeTys127 D1BodySized.sizeArgs127).run D1BodySized.S433 =
  some (some D1BodySized.sizeAs127, D1BodySized.sizeS0127)
kernel_rfl D1BodySized.sizePreA127 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0127 D1BodySized.s433.ffi D1BodySized.sizeAs127 = true

end Host.Load.Run.Tpl
end

section -- SN434
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel434 : nth? D1BodySized.ks 434 = some 1936
kernel_rfl D1BodySized.checked434 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s434 D1BodySized.S434) =
    fun _ => some (D1BodySized.s435, D1BodySized.S435)

theorem D1BodySized.k434 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s434 D1BodySized.S434 =
      some (D1BodySized.s435, D1BodySized.S435) := congrFun D1BodySized.checked434 bs

end Host.Load.Run.Tpl
end

section -- SB127
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment127 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s434 D1BodySized.S434 =
      some (D1BodySized.s435, D1BodySized.S435) := D1BodySized.k434 bs

kernel_rfl D1BodySized.accepted127 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s434 D1BodySized.S434) = fun _ => true
kernel_rfl D1BodySized.oracle127 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S434.oracle = true
kernel_rfl D1BodySized.fuelA128 : nth? D1BodySized.ks 435 = some 1
kernel_rfl D1BodySized.fuelB128 : nth? D1BodySized.ks 436 = some 3
kernel_rfl D1BodySized.stepA128 : interpS (step D1BodySized.F D1BodySized.s435).run D1BodySized.S435 =
  some (D1BodySized.s436, D1BodySized.S436)
kernel_rfl D1BodySized.patchB128 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s436).run D1BodySized.S436 =
  some (D1BodySized.s437, D1BodySized.S437)
kernel_rfl D1BodySized.acceptedP128 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s435 D1BodySized.S435) = fun _ => true
kernel_rfl D1BodySized.haltP128 : isHalt D1BodySized.s435.ctl = false
kernel_rfl D1BodySized.topA128 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s436 = true
kernel_rfl D1BodySized.inactive128 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s436.ffi).active = false
/-- Bridge 128's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys128 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s436 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs128 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s436 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA128 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s436 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys128, D1BodySized.sizeArgs128)
kernel_rfl D1BodySized.sizeArgsA128 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s436 = true
kernel_rfl D1BodySized.sizeSymA128 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA128 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA128 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA128 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec128 := interpS (decodeArgs D1BodySized.F D1BodySized.s436 D1BodySized.sizeTys128 D1BodySized.sizeArgs128).run D1BodySized.S436
noncomputable def D1BodySized.sizeAs128 : List Arg := match D1BodySized.sizeDec128 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0128 : SSrv := match D1BodySized.sizeDec128 with | some (_, S) => S | none => D1BodySized.S436
kernel_rfl D1BodySized.sizeDecA128 : interpS (decodeArgs D1BodySized.F D1BodySized.s436 D1BodySized.sizeTys128 D1BodySized.sizeArgs128).run D1BodySized.S436 =
  some (some D1BodySized.sizeAs128, D1BodySized.sizeS0128)
kernel_rfl D1BodySized.sizePreA128 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0128 D1BodySized.s436.ffi D1BodySized.sizeAs128 = true

end Host.Load.Run.Tpl
end

section -- SN437
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel437 : nth? D1BodySized.ks 437 = some 10000
kernel_rfl D1BodySized.checked437 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s437 D1BodySized.S437) =
    fun _ => some (D1BodySized.s438, D1BodySized.S438)

theorem D1BodySized.k437 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s437 D1BodySized.S437 =
      some (D1BodySized.s438, D1BodySized.S438) := congrFun D1BodySized.checked437 bs

end Host.Load.Run.Tpl
end

section -- SN438
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel438 : nth? D1BodySized.ks 438 = some 2570
kernel_rfl D1BodySized.checked438 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s438 D1BodySized.S438) =
    fun _ => some (D1BodySized.s439, D1BodySized.S439)

theorem D1BodySized.k438 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s438 D1BodySized.S438 =
      some (D1BodySized.s439, D1BodySized.S439) := congrFun D1BodySized.checked438 bs

end Host.Load.Run.Tpl
end

section -- SB128
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment128 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s437 D1BodySized.S437 =
      some (D1BodySized.s439, D1BodySized.S439) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s437 D1BodySized.s438 D1BodySized.s439 D1BodySized.S437 D1BodySized.S438 D1BodySized.S439 (D1BodySized.k437 bs) (D1BodySized.k438 bs)

kernel_rfl D1BodySized.accepted128 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s437 D1BodySized.S437) = fun _ => true
kernel_rfl D1BodySized.oracle128 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S437.oracle = true
kernel_rfl D1BodySized.fuelA129 : nth? D1BodySized.ks 439 = some 1
kernel_rfl D1BodySized.fuelB129 : nth? D1BodySized.ks 440 = some 3
kernel_rfl D1BodySized.stepA129 : interpS (step D1BodySized.F D1BodySized.s439).run D1BodySized.S439 =
  some (D1BodySized.s440, D1BodySized.S440)
kernel_rfl D1BodySized.patchB129 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s440).run D1BodySized.S440 =
  some (D1BodySized.s441, D1BodySized.S441)
kernel_rfl D1BodySized.acceptedP129 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s439 D1BodySized.S439) = fun _ => true
kernel_rfl D1BodySized.haltP129 : isHalt D1BodySized.s439.ctl = false
kernel_rfl D1BodySized.topA129 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s440 = true
kernel_rfl D1BodySized.inactive129 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s440.ffi).active = false
/-- Bridge 129's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys129 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s440 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs129 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s440 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA129 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s440 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys129, D1BodySized.sizeArgs129)
kernel_rfl D1BodySized.sizeArgsA129 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s440 = true
kernel_rfl D1BodySized.sizeSymA129 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA129 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA129 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA129 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec129 := interpS (decodeArgs D1BodySized.F D1BodySized.s440 D1BodySized.sizeTys129 D1BodySized.sizeArgs129).run D1BodySized.S440
noncomputable def D1BodySized.sizeAs129 : List Arg := match D1BodySized.sizeDec129 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0129 : SSrv := match D1BodySized.sizeDec129 with | some (_, S) => S | none => D1BodySized.S440
kernel_rfl D1BodySized.sizeDecA129 : interpS (decodeArgs D1BodySized.F D1BodySized.s440 D1BodySized.sizeTys129 D1BodySized.sizeArgs129).run D1BodySized.S440 =
  some (some D1BodySized.sizeAs129, D1BodySized.sizeS0129)
kernel_rfl D1BodySized.sizePreA129 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0129 D1BodySized.s440.ffi D1BodySized.sizeAs129 = true

end Host.Load.Run.Tpl
end

section -- SN441
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel441 : nth? D1BodySized.ks 441 = some 2542
kernel_rfl D1BodySized.checked441 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s441 D1BodySized.S441) =
    fun _ => some (D1BodySized.s442, D1BodySized.S442)

theorem D1BodySized.k441 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s441 D1BodySized.S441 =
      some (D1BodySized.s442, D1BodySized.S442) := congrFun D1BodySized.checked441 bs

end Host.Load.Run.Tpl
end

section -- SB129
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment129 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s441 D1BodySized.S441 =
      some (D1BodySized.s442, D1BodySized.S442) := D1BodySized.k441 bs

kernel_rfl D1BodySized.accepted129 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s441 D1BodySized.S441) = fun _ => true
kernel_rfl D1BodySized.oracle129 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S441.oracle = true
kernel_rfl D1BodySized.fuelA130 : nth? D1BodySized.ks 442 = some 1
kernel_rfl D1BodySized.fuelB130 : nth? D1BodySized.ks 443 = some 3
kernel_rfl D1BodySized.stepA130 : interpS (step D1BodySized.F D1BodySized.s442).run D1BodySized.S442 =
  some (D1BodySized.s443, D1BodySized.S443)
kernel_rfl D1BodySized.patchB130 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s443).run D1BodySized.S443 =
  some (D1BodySized.s444, D1BodySized.S444)
kernel_rfl D1BodySized.acceptedP130 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s442 D1BodySized.S442) = fun _ => true
kernel_rfl D1BodySized.haltP130 : isHalt D1BodySized.s442.ctl = false
kernel_rfl D1BodySized.topA130 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s443 = true
kernel_rfl D1BodySized.inactive130 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s443.ffi).active = false
/-- Bridge 130's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys130 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s443 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs130 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s443 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA130 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s443 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys130, D1BodySized.sizeArgs130)
kernel_rfl D1BodySized.sizeArgsA130 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s443 = true
kernel_rfl D1BodySized.sizeSymA130 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA130 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA130 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA130 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec130 := interpS (decodeArgs D1BodySized.F D1BodySized.s443 D1BodySized.sizeTys130 D1BodySized.sizeArgs130).run D1BodySized.S443
noncomputable def D1BodySized.sizeAs130 : List Arg := match D1BodySized.sizeDec130 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0130 : SSrv := match D1BodySized.sizeDec130 with | some (_, S) => S | none => D1BodySized.S443
kernel_rfl D1BodySized.sizeDecA130 : interpS (decodeArgs D1BodySized.F D1BodySized.s443 D1BodySized.sizeTys130 D1BodySized.sizeArgs130).run D1BodySized.S443 =
  some (some D1BodySized.sizeAs130, D1BodySized.sizeS0130)
kernel_rfl D1BodySized.sizePreA130 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0130 D1BodySized.s443.ffi D1BodySized.sizeAs130 = true

end Host.Load.Run.Tpl
end

section -- SN444
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel444 : nth? D1BodySized.ks 444 = some 7716
kernel_rfl D1BodySized.checked444 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s444 D1BodySized.S444) =
    fun _ => some (D1BodySized.s445, D1BodySized.S445)

theorem D1BodySized.k444 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s444 D1BodySized.S444 =
      some (D1BodySized.s445, D1BodySized.S445) := congrFun D1BodySized.checked444 bs

end Host.Load.Run.Tpl
end

section -- SB130
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment130 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s444 D1BodySized.S444 =
      some (D1BodySized.s445, D1BodySized.S445) := D1BodySized.k444 bs

kernel_rfl D1BodySized.accepted130 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s444 D1BodySized.S444) = fun _ => true
kernel_rfl D1BodySized.oracle130 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S444.oracle = true
kernel_rfl D1BodySized.fuelA131 : nth? D1BodySized.ks 445 = some 1
kernel_rfl D1BodySized.fuelB131 : nth? D1BodySized.ks 446 = some 3
kernel_rfl D1BodySized.stepA131 : interpS (step D1BodySized.F D1BodySized.s445).run D1BodySized.S445 =
  some (D1BodySized.s446, D1BodySized.S446)
kernel_rfl D1BodySized.patchB131 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s446).run D1BodySized.S446 =
  some (D1BodySized.s447, D1BodySized.S447)
kernel_rfl D1BodySized.acceptedP131 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s445 D1BodySized.S445) = fun _ => true
kernel_rfl D1BodySized.haltP131 : isHalt D1BodySized.s445.ctl = false
kernel_rfl D1BodySized.topA131 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s446 = true
kernel_rfl D1BodySized.inactive131 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s446.ffi).active = false
/-- Bridge 131's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys131 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s446 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs131 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s446 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA131 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s446 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys131, D1BodySized.sizeArgs131)
kernel_rfl D1BodySized.sizeArgsA131 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s446 = true
kernel_rfl D1BodySized.sizeSymA131 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA131 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA131 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA131 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec131 := interpS (decodeArgs D1BodySized.F D1BodySized.s446 D1BodySized.sizeTys131 D1BodySized.sizeArgs131).run D1BodySized.S446
noncomputable def D1BodySized.sizeAs131 : List Arg := match D1BodySized.sizeDec131 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0131 : SSrv := match D1BodySized.sizeDec131 with | some (_, S) => S | none => D1BodySized.S446
kernel_rfl D1BodySized.sizeDecA131 : interpS (decodeArgs D1BodySized.F D1BodySized.s446 D1BodySized.sizeTys131 D1BodySized.sizeArgs131).run D1BodySized.S446 =
  some (some D1BodySized.sizeAs131, D1BodySized.sizeS0131)
kernel_rfl D1BodySized.sizePreA131 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0131 D1BodySized.s446.ffi D1BodySized.sizeAs131 = true

end Host.Load.Run.Tpl
end

section -- SN447
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel447 : nth? D1BodySized.ks 447 = some 1936
kernel_rfl D1BodySized.checked447 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s447 D1BodySized.S447) =
    fun _ => some (D1BodySized.s448, D1BodySized.S448)

theorem D1BodySized.k447 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s447 D1BodySized.S447 =
      some (D1BodySized.s448, D1BodySized.S448) := congrFun D1BodySized.checked447 bs

end Host.Load.Run.Tpl
end

section -- SB131
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment131 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s447 D1BodySized.S447 =
      some (D1BodySized.s448, D1BodySized.S448) := D1BodySized.k447 bs

kernel_rfl D1BodySized.accepted131 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s447 D1BodySized.S447) = fun _ => true
kernel_rfl D1BodySized.oracle131 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S447.oracle = true
kernel_rfl D1BodySized.fuelA132 : nth? D1BodySized.ks 448 = some 1
kernel_rfl D1BodySized.fuelB132 : nth? D1BodySized.ks 449 = some 3
kernel_rfl D1BodySized.stepA132 : interpS (step D1BodySized.F D1BodySized.s448).run D1BodySized.S448 =
  some (D1BodySized.s449, D1BodySized.S449)
kernel_rfl D1BodySized.patchB132 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s449).run D1BodySized.S449 =
  some (D1BodySized.s450, D1BodySized.S450)
kernel_rfl D1BodySized.acceptedP132 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s448 D1BodySized.S448) = fun _ => true
kernel_rfl D1BodySized.haltP132 : isHalt D1BodySized.s448.ctl = false
kernel_rfl D1BodySized.topA132 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s449 = true
kernel_rfl D1BodySized.inactive132 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s449.ffi).active = false
/-- Bridge 132's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys132 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s449 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs132 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s449 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA132 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s449 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys132, D1BodySized.sizeArgs132)
kernel_rfl D1BodySized.sizeArgsA132 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s449 = true
kernel_rfl D1BodySized.sizeSymA132 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA132 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA132 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA132 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec132 := interpS (decodeArgs D1BodySized.F D1BodySized.s449 D1BodySized.sizeTys132 D1BodySized.sizeArgs132).run D1BodySized.S449
noncomputable def D1BodySized.sizeAs132 : List Arg := match D1BodySized.sizeDec132 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0132 : SSrv := match D1BodySized.sizeDec132 with | some (_, S) => S | none => D1BodySized.S449
kernel_rfl D1BodySized.sizeDecA132 : interpS (decodeArgs D1BodySized.F D1BodySized.s449 D1BodySized.sizeTys132 D1BodySized.sizeArgs132).run D1BodySized.S449 =
  some (some D1BodySized.sizeAs132, D1BodySized.sizeS0132)
kernel_rfl D1BodySized.sizePreA132 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0132 D1BodySized.s449.ffi D1BodySized.sizeAs132 = true

end Host.Load.Run.Tpl
end

section -- SN450
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel450 : nth? D1BodySized.ks 450 = some 10000
kernel_rfl D1BodySized.checked450 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s450 D1BodySized.S450) =
    fun _ => some (D1BodySized.s451, D1BodySized.S451)

theorem D1BodySized.k450 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s450 D1BodySized.S450 =
      some (D1BodySized.s451, D1BodySized.S451) := congrFun D1BodySized.checked450 bs

end Host.Load.Run.Tpl
end

section -- SN451
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel451 : nth? D1BodySized.ks 451 = some 2570
kernel_rfl D1BodySized.checked451 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s451 D1BodySized.S451) =
    fun _ => some (D1BodySized.s452, D1BodySized.S452)

theorem D1BodySized.k451 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s451 D1BodySized.S451 =
      some (D1BodySized.s452, D1BodySized.S452) := congrFun D1BodySized.checked451 bs

end Host.Load.Run.Tpl
end

section -- SB132
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment132 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s450 D1BodySized.S450 =
      some (D1BodySized.s452, D1BodySized.S452) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s450 D1BodySized.s451 D1BodySized.s452 D1BodySized.S450 D1BodySized.S451 D1BodySized.S452 (D1BodySized.k450 bs) (D1BodySized.k451 bs)

kernel_rfl D1BodySized.accepted132 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s450 D1BodySized.S450) = fun _ => true
kernel_rfl D1BodySized.oracle132 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S450.oracle = true
kernel_rfl D1BodySized.fuelA133 : nth? D1BodySized.ks 452 = some 1
kernel_rfl D1BodySized.fuelB133 : nth? D1BodySized.ks 453 = some 3
kernel_rfl D1BodySized.stepA133 : interpS (step D1BodySized.F D1BodySized.s452).run D1BodySized.S452 =
  some (D1BodySized.s453, D1BodySized.S453)
kernel_rfl D1BodySized.patchB133 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s453).run D1BodySized.S453 =
  some (D1BodySized.s454, D1BodySized.S454)
kernel_rfl D1BodySized.acceptedP133 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s452 D1BodySized.S452) = fun _ => true
kernel_rfl D1BodySized.haltP133 : isHalt D1BodySized.s452.ctl = false
kernel_rfl D1BodySized.topA133 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s453 = true
kernel_rfl D1BodySized.inactive133 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s453.ffi).active = false
/-- Bridge 133's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys133 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s453 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs133 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s453 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA133 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s453 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys133, D1BodySized.sizeArgs133)
kernel_rfl D1BodySized.sizeArgsA133 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s453 = true
kernel_rfl D1BodySized.sizeSymA133 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA133 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA133 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA133 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec133 := interpS (decodeArgs D1BodySized.F D1BodySized.s453 D1BodySized.sizeTys133 D1BodySized.sizeArgs133).run D1BodySized.S453
noncomputable def D1BodySized.sizeAs133 : List Arg := match D1BodySized.sizeDec133 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0133 : SSrv := match D1BodySized.sizeDec133 with | some (_, S) => S | none => D1BodySized.S453
kernel_rfl D1BodySized.sizeDecA133 : interpS (decodeArgs D1BodySized.F D1BodySized.s453 D1BodySized.sizeTys133 D1BodySized.sizeArgs133).run D1BodySized.S453 =
  some (some D1BodySized.sizeAs133, D1BodySized.sizeS0133)
kernel_rfl D1BodySized.sizePreA133 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0133 D1BodySized.s453.ffi D1BodySized.sizeAs133 = true

end Host.Load.Run.Tpl
end

section -- SN454
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel454 : nth? D1BodySized.ks 454 = some 2542
kernel_rfl D1BodySized.checked454 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s454 D1BodySized.S454) =
    fun _ => some (D1BodySized.s455, D1BodySized.S455)

theorem D1BodySized.k454 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s454 D1BodySized.S454 =
      some (D1BodySized.s455, D1BodySized.S455) := congrFun D1BodySized.checked454 bs

end Host.Load.Run.Tpl
end

section -- SB133
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment133 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s454 D1BodySized.S454 =
      some (D1BodySized.s455, D1BodySized.S455) := D1BodySized.k454 bs

kernel_rfl D1BodySized.accepted133 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s454 D1BodySized.S454) = fun _ => true
kernel_rfl D1BodySized.oracle133 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S454.oracle = true
kernel_rfl D1BodySized.fuelA134 : nth? D1BodySized.ks 455 = some 1
kernel_rfl D1BodySized.fuelB134 : nth? D1BodySized.ks 456 = some 3
kernel_rfl D1BodySized.stepA134 : interpS (step D1BodySized.F D1BodySized.s455).run D1BodySized.S455 =
  some (D1BodySized.s456, D1BodySized.S456)
kernel_rfl D1BodySized.patchB134 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s456).run D1BodySized.S456 =
  some (D1BodySized.s457, D1BodySized.S457)
kernel_rfl D1BodySized.acceptedP134 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s455 D1BodySized.S455) = fun _ => true
kernel_rfl D1BodySized.haltP134 : isHalt D1BodySized.s455.ctl = false
kernel_rfl D1BodySized.topA134 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s456 = true
kernel_rfl D1BodySized.inactive134 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s456.ffi).active = false
/-- Bridge 134's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys134 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s456 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs134 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s456 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA134 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s456 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys134, D1BodySized.sizeArgs134)
kernel_rfl D1BodySized.sizeArgsA134 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s456 = true
kernel_rfl D1BodySized.sizeSymA134 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA134 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA134 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA134 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec134 := interpS (decodeArgs D1BodySized.F D1BodySized.s456 D1BodySized.sizeTys134 D1BodySized.sizeArgs134).run D1BodySized.S456
noncomputable def D1BodySized.sizeAs134 : List Arg := match D1BodySized.sizeDec134 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0134 : SSrv := match D1BodySized.sizeDec134 with | some (_, S) => S | none => D1BodySized.S456
kernel_rfl D1BodySized.sizeDecA134 : interpS (decodeArgs D1BodySized.F D1BodySized.s456 D1BodySized.sizeTys134 D1BodySized.sizeArgs134).run D1BodySized.S456 =
  some (some D1BodySized.sizeAs134, D1BodySized.sizeS0134)
kernel_rfl D1BodySized.sizePreA134 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0134 D1BodySized.s456.ffi D1BodySized.sizeAs134 = true

end Host.Load.Run.Tpl
end

section -- SN457
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel457 : nth? D1BodySized.ks 457 = some 10000
kernel_rfl D1BodySized.checked457 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s457 D1BodySized.S457) =
    fun _ => some (D1BodySized.s458, D1BodySized.S458)

theorem D1BodySized.k457 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s457 D1BodySized.S457 =
      some (D1BodySized.s458, D1BodySized.S458) := congrFun D1BodySized.checked457 bs

end Host.Load.Run.Tpl
end

section -- SN458
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel458 : nth? D1BodySized.ks 458 = some 10000
kernel_rfl D1BodySized.checked458 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s458 D1BodySized.S458) =
    fun _ => some (D1BodySized.s459, D1BodySized.S459)

theorem D1BodySized.k458 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s458 D1BodySized.S458 =
      some (D1BodySized.s459, D1BodySized.S459) := congrFun D1BodySized.checked458 bs

end Host.Load.Run.Tpl
end

section -- SN459
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel459 : nth? D1BodySized.ks 459 = some 2287
kernel_rfl D1BodySized.checked459 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s459 D1BodySized.S459) =
    fun _ => some (D1BodySized.s460, D1BodySized.S460)

theorem D1BodySized.k459 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s459 D1BodySized.S459 =
      some (D1BodySized.s460, D1BodySized.S460) := congrFun D1BodySized.checked459 bs

end Host.Load.Run.Tpl
end

section -- SB134
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment134 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22287 D1BodySized.s457 D1BodySized.S457 =
      some (D1BodySized.s460, D1BodySized.S460) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2287 D1BodySized.s457 D1BodySized.s459 D1BodySized.s460 D1BodySized.S457 D1BodySized.S459 D1BodySized.S460 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s457 D1BodySized.s458 D1BodySized.s459 D1BodySized.S457 D1BodySized.S458 D1BodySized.S459 (D1BodySized.k457 bs) (D1BodySized.k458 bs)) (D1BodySized.k459 bs)

kernel_rfl D1BodySized.accepted134 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s457 D1BodySized.S457) = fun _ => true
kernel_rfl D1BodySized.oracle134 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S457.oracle = true
kernel_rfl D1BodySized.fuelA135 : nth? D1BodySized.ks 460 = some 1
kernel_rfl D1BodySized.fuelB135 : nth? D1BodySized.ks 461 = some 3
kernel_rfl D1BodySized.stepA135 : interpS (step D1BodySized.F D1BodySized.s460).run D1BodySized.S460 =
  some (D1BodySized.s461, D1BodySized.S461)
kernel_rfl D1BodySized.patchB135 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s461).run D1BodySized.S461 =
  some (D1BodySized.s462, D1BodySized.S462)
kernel_rfl D1BodySized.acceptedP135 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s460 D1BodySized.S460) = fun _ => true
kernel_rfl D1BodySized.haltP135 : isHalt D1BodySized.s460.ctl = false
kernel_rfl D1BodySized.topA135 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s461 = true
kernel_rfl D1BodySized.inactive135 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s461.ffi).active = false
/-- Bridge 135's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys135 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s461 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs135 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s461 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA135 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s461 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys135, D1BodySized.sizeArgs135)
kernel_rfl D1BodySized.sizeArgsA135 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s461 = true
kernel_rfl D1BodySized.sizeSymA135 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA135 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA135 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA135 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec135 := interpS (decodeArgs D1BodySized.F D1BodySized.s461 D1BodySized.sizeTys135 D1BodySized.sizeArgs135).run D1BodySized.S461
noncomputable def D1BodySized.sizeAs135 : List Arg := match D1BodySized.sizeDec135 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0135 : SSrv := match D1BodySized.sizeDec135 with | some (_, S) => S | none => D1BodySized.S461
kernel_rfl D1BodySized.sizeDecA135 : interpS (decodeArgs D1BodySized.F D1BodySized.s461 D1BodySized.sizeTys135 D1BodySized.sizeArgs135).run D1BodySized.S461 =
  some (some D1BodySized.sizeAs135, D1BodySized.sizeS0135)
kernel_rfl D1BodySized.sizePreA135 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0135 D1BodySized.s461.ffi D1BodySized.sizeAs135 = true

end Host.Load.Run.Tpl
end

section -- SN462
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel462 : nth? D1BodySized.ks 462 = some 7939
kernel_rfl D1BodySized.checked462 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7939 D1BodySized.s462 D1BodySized.S462) =
    fun _ => some (D1BodySized.s463, D1BodySized.S463)

theorem D1BodySized.k462 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7939 D1BodySized.s462 D1BodySized.S462 =
      some (D1BodySized.s463, D1BodySized.S463) := congrFun D1BodySized.checked462 bs

end Host.Load.Run.Tpl
end

section -- SB135
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment135 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7939 D1BodySized.s462 D1BodySized.S462 =
      some (D1BodySized.s463, D1BodySized.S463) := D1BodySized.k462 bs

kernel_rfl D1BodySized.accepted135 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s462 D1BodySized.S462) = fun _ => true
kernel_rfl D1BodySized.oracle135 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S462.oracle = true
kernel_rfl D1BodySized.fuelA136 : nth? D1BodySized.ks 463 = some 1
kernel_rfl D1BodySized.fuelB136 : nth? D1BodySized.ks 464 = some 3
kernel_rfl D1BodySized.stepA136 : interpS (step D1BodySized.F D1BodySized.s463).run D1BodySized.S463 =
  some (D1BodySized.s464, D1BodySized.S464)
kernel_rfl D1BodySized.patchB136 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s464).run D1BodySized.S464 =
  some (D1BodySized.s465, D1BodySized.S465)
kernel_rfl D1BodySized.acceptedP136 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s463 D1BodySized.S463) = fun _ => true
kernel_rfl D1BodySized.haltP136 : isHalt D1BodySized.s463.ctl = false
kernel_rfl D1BodySized.topA136 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s464 = true
kernel_rfl D1BodySized.inactive136 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s464.ffi).active = false
/-- Bridge 136's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys136 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s464 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs136 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s464 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA136 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s464 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys136, D1BodySized.sizeArgs136)
kernel_rfl D1BodySized.sizeArgsA136 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s464 = true
kernel_rfl D1BodySized.sizeSymA136 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA136 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA136 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA136 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec136 := interpS (decodeArgs D1BodySized.F D1BodySized.s464 D1BodySized.sizeTys136 D1BodySized.sizeArgs136).run D1BodySized.S464
noncomputable def D1BodySized.sizeAs136 : List Arg := match D1BodySized.sizeDec136 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0136 : SSrv := match D1BodySized.sizeDec136 with | some (_, S) => S | none => D1BodySized.S464
kernel_rfl D1BodySized.sizeDecA136 : interpS (decodeArgs D1BodySized.F D1BodySized.s464 D1BodySized.sizeTys136 D1BodySized.sizeArgs136).run D1BodySized.S464 =
  some (some D1BodySized.sizeAs136, D1BodySized.sizeS0136)
kernel_rfl D1BodySized.sizePreA136 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0136 D1BodySized.s464.ffi D1BodySized.sizeAs136 = true

end Host.Load.Run.Tpl
end

section -- SN465
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel465 : nth? D1BodySized.ks 465 = some 1936
kernel_rfl D1BodySized.checked465 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s465 D1BodySized.S465) =
    fun _ => some (D1BodySized.s466, D1BodySized.S466)

theorem D1BodySized.k465 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s465 D1BodySized.S465 =
      some (D1BodySized.s466, D1BodySized.S466) := congrFun D1BodySized.checked465 bs

end Host.Load.Run.Tpl
end

section -- SB136
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment136 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s465 D1BodySized.S465 =
      some (D1BodySized.s466, D1BodySized.S466) := D1BodySized.k465 bs

kernel_rfl D1BodySized.accepted136 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s465 D1BodySized.S465) = fun _ => true
kernel_rfl D1BodySized.oracle136 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S465.oracle = true
kernel_rfl D1BodySized.fuelA137 : nth? D1BodySized.ks 466 = some 1
kernel_rfl D1BodySized.fuelB137 : nth? D1BodySized.ks 467 = some 3
kernel_rfl D1BodySized.stepA137 : interpS (step D1BodySized.F D1BodySized.s466).run D1BodySized.S466 =
  some (D1BodySized.s467, D1BodySized.S467)
kernel_rfl D1BodySized.patchB137 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s467).run D1BodySized.S467 =
  some (D1BodySized.s468, D1BodySized.S468)
kernel_rfl D1BodySized.acceptedP137 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s466 D1BodySized.S466) = fun _ => true
kernel_rfl D1BodySized.haltP137 : isHalt D1BodySized.s466.ctl = false
kernel_rfl D1BodySized.topA137 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s467 = true
kernel_rfl D1BodySized.inactive137 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s467.ffi).active = false
/-- Bridge 137's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys137 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s467 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs137 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s467 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA137 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s467 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys137, D1BodySized.sizeArgs137)
kernel_rfl D1BodySized.sizeArgsA137 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s467 = true
kernel_rfl D1BodySized.sizeSymA137 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA137 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA137 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA137 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec137 := interpS (decodeArgs D1BodySized.F D1BodySized.s467 D1BodySized.sizeTys137 D1BodySized.sizeArgs137).run D1BodySized.S467
noncomputable def D1BodySized.sizeAs137 : List Arg := match D1BodySized.sizeDec137 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0137 : SSrv := match D1BodySized.sizeDec137 with | some (_, S) => S | none => D1BodySized.S467
kernel_rfl D1BodySized.sizeDecA137 : interpS (decodeArgs D1BodySized.F D1BodySized.s467 D1BodySized.sizeTys137 D1BodySized.sizeArgs137).run D1BodySized.S467 =
  some (some D1BodySized.sizeAs137, D1BodySized.sizeS0137)
kernel_rfl D1BodySized.sizePreA137 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0137 D1BodySized.s467.ffi D1BodySized.sizeAs137 = true

end Host.Load.Run.Tpl
end

section -- SN468
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel468 : nth? D1BodySized.ks 468 = some 10000
kernel_rfl D1BodySized.checked468 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s468 D1BodySized.S468) =
    fun _ => some (D1BodySized.s469, D1BodySized.S469)

theorem D1BodySized.k468 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s468 D1BodySized.S468 =
      some (D1BodySized.s469, D1BodySized.S469) := congrFun D1BodySized.checked468 bs

end Host.Load.Run.Tpl
end

section -- SN469
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel469 : nth? D1BodySized.ks 469 = some 2570
kernel_rfl D1BodySized.checked469 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s469 D1BodySized.S469) =
    fun _ => some (D1BodySized.s470, D1BodySized.S470)

theorem D1BodySized.k469 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s469 D1BodySized.S469 =
      some (D1BodySized.s470, D1BodySized.S470) := congrFun D1BodySized.checked469 bs

end Host.Load.Run.Tpl
end

section -- SB137
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment137 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s468 D1BodySized.S468 =
      some (D1BodySized.s470, D1BodySized.S470) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s468 D1BodySized.s469 D1BodySized.s470 D1BodySized.S468 D1BodySized.S469 D1BodySized.S470 (D1BodySized.k468 bs) (D1BodySized.k469 bs)

kernel_rfl D1BodySized.accepted137 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s468 D1BodySized.S468) = fun _ => true
kernel_rfl D1BodySized.oracle137 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S468.oracle = true
kernel_rfl D1BodySized.fuelA138 : nth? D1BodySized.ks 470 = some 1
kernel_rfl D1BodySized.fuelB138 : nth? D1BodySized.ks 471 = some 3
kernel_rfl D1BodySized.stepA138 : interpS (step D1BodySized.F D1BodySized.s470).run D1BodySized.S470 =
  some (D1BodySized.s471, D1BodySized.S471)
kernel_rfl D1BodySized.patchB138 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s471).run D1BodySized.S471 =
  some (D1BodySized.s472, D1BodySized.S472)
kernel_rfl D1BodySized.acceptedP138 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s470 D1BodySized.S470) = fun _ => true
kernel_rfl D1BodySized.haltP138 : isHalt D1BodySized.s470.ctl = false
kernel_rfl D1BodySized.topA138 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s471 = true
kernel_rfl D1BodySized.inactive138 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s471.ffi).active = false
/-- Bridge 138's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys138 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s471 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs138 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s471 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA138 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s471 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys138, D1BodySized.sizeArgs138)
kernel_rfl D1BodySized.sizeArgsA138 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s471 = true
kernel_rfl D1BodySized.sizeSymA138 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA138 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA138 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA138 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec138 := interpS (decodeArgs D1BodySized.F D1BodySized.s471 D1BodySized.sizeTys138 D1BodySized.sizeArgs138).run D1BodySized.S471
noncomputable def D1BodySized.sizeAs138 : List Arg := match D1BodySized.sizeDec138 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0138 : SSrv := match D1BodySized.sizeDec138 with | some (_, S) => S | none => D1BodySized.S471
kernel_rfl D1BodySized.sizeDecA138 : interpS (decodeArgs D1BodySized.F D1BodySized.s471 D1BodySized.sizeTys138 D1BodySized.sizeArgs138).run D1BodySized.S471 =
  some (some D1BodySized.sizeAs138, D1BodySized.sizeS0138)
kernel_rfl D1BodySized.sizePreA138 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0138 D1BodySized.s471.ffi D1BodySized.sizeAs138 = true

end Host.Load.Run.Tpl
end

section -- SN472
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel472 : nth? D1BodySized.ks 472 = some 2542
kernel_rfl D1BodySized.checked472 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s472 D1BodySized.S472) =
    fun _ => some (D1BodySized.s473, D1BodySized.S473)

theorem D1BodySized.k472 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s472 D1BodySized.S472 =
      some (D1BodySized.s473, D1BodySized.S473) := congrFun D1BodySized.checked472 bs

end Host.Load.Run.Tpl
end

section -- SB138
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment138 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s472 D1BodySized.S472 =
      some (D1BodySized.s473, D1BodySized.S473) := D1BodySized.k472 bs

kernel_rfl D1BodySized.accepted138 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s472 D1BodySized.S472) = fun _ => true
kernel_rfl D1BodySized.oracle138 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S472.oracle = true
kernel_rfl D1BodySized.fuelA139 : nth? D1BodySized.ks 473 = some 1
kernel_rfl D1BodySized.fuelB139 : nth? D1BodySized.ks 474 = some 3
kernel_rfl D1BodySized.stepA139 : interpS (step D1BodySized.F D1BodySized.s473).run D1BodySized.S473 =
  some (D1BodySized.s474, D1BodySized.S474)
kernel_rfl D1BodySized.patchB139 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s474).run D1BodySized.S474 =
  some (D1BodySized.s475, D1BodySized.S475)
kernel_rfl D1BodySized.acceptedP139 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s473 D1BodySized.S473) = fun _ => true
kernel_rfl D1BodySized.haltP139 : isHalt D1BodySized.s473.ctl = false
kernel_rfl D1BodySized.topA139 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s474 = true
kernel_rfl D1BodySized.inactive139 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s474.ffi).active = false
/-- Bridge 139's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys139 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s474 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs139 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s474 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA139 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s474 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys139, D1BodySized.sizeArgs139)
kernel_rfl D1BodySized.sizeArgsA139 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s474 = true
kernel_rfl D1BodySized.sizeSymA139 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA139 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA139 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA139 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec139 := interpS (decodeArgs D1BodySized.F D1BodySized.s474 D1BodySized.sizeTys139 D1BodySized.sizeArgs139).run D1BodySized.S474
noncomputable def D1BodySized.sizeAs139 : List Arg := match D1BodySized.sizeDec139 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0139 : SSrv := match D1BodySized.sizeDec139 with | some (_, S) => S | none => D1BodySized.S474
kernel_rfl D1BodySized.sizeDecA139 : interpS (decodeArgs D1BodySized.F D1BodySized.s474 D1BodySized.sizeTys139 D1BodySized.sizeArgs139).run D1BodySized.S474 =
  some (some D1BodySized.sizeAs139, D1BodySized.sizeS0139)
kernel_rfl D1BodySized.sizePreA139 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0139 D1BodySized.s474.ffi D1BodySized.sizeAs139 = true

end Host.Load.Run.Tpl
end

section -- SN475
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel475 : nth? D1BodySized.ks 475 = some 7716
kernel_rfl D1BodySized.checked475 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s475 D1BodySized.S475) =
    fun _ => some (D1BodySized.s476, D1BodySized.S476)

theorem D1BodySized.k475 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s475 D1BodySized.S475 =
      some (D1BodySized.s476, D1BodySized.S476) := congrFun D1BodySized.checked475 bs

end Host.Load.Run.Tpl
end

section -- SB139
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment139 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s475 D1BodySized.S475 =
      some (D1BodySized.s476, D1BodySized.S476) := D1BodySized.k475 bs

kernel_rfl D1BodySized.accepted139 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s475 D1BodySized.S475) = fun _ => true
kernel_rfl D1BodySized.oracle139 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S475.oracle = true
kernel_rfl D1BodySized.fuelA140 : nth? D1BodySized.ks 476 = some 1
kernel_rfl D1BodySized.fuelB140 : nth? D1BodySized.ks 477 = some 3
kernel_rfl D1BodySized.stepA140 : interpS (step D1BodySized.F D1BodySized.s476).run D1BodySized.S476 =
  some (D1BodySized.s477, D1BodySized.S477)
kernel_rfl D1BodySized.patchB140 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s477).run D1BodySized.S477 =
  some (D1BodySized.s478, D1BodySized.S478)
kernel_rfl D1BodySized.acceptedP140 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s476 D1BodySized.S476) = fun _ => true
kernel_rfl D1BodySized.haltP140 : isHalt D1BodySized.s476.ctl = false
kernel_rfl D1BodySized.topA140 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s477 = true
kernel_rfl D1BodySized.inactive140 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s477.ffi).active = false
/-- Bridge 140's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys140 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s477 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs140 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s477 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA140 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s477 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys140, D1BodySized.sizeArgs140)
kernel_rfl D1BodySized.sizeArgsA140 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s477 = true
kernel_rfl D1BodySized.sizeSymA140 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA140 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA140 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA140 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec140 := interpS (decodeArgs D1BodySized.F D1BodySized.s477 D1BodySized.sizeTys140 D1BodySized.sizeArgs140).run D1BodySized.S477
noncomputable def D1BodySized.sizeAs140 : List Arg := match D1BodySized.sizeDec140 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0140 : SSrv := match D1BodySized.sizeDec140 with | some (_, S) => S | none => D1BodySized.S477
kernel_rfl D1BodySized.sizeDecA140 : interpS (decodeArgs D1BodySized.F D1BodySized.s477 D1BodySized.sizeTys140 D1BodySized.sizeArgs140).run D1BodySized.S477 =
  some (some D1BodySized.sizeAs140, D1BodySized.sizeS0140)
kernel_rfl D1BodySized.sizePreA140 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0140 D1BodySized.s477.ffi D1BodySized.sizeAs140 = true

end Host.Load.Run.Tpl
end

section -- SN478
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel478 : nth? D1BodySized.ks 478 = some 1936
kernel_rfl D1BodySized.checked478 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s478 D1BodySized.S478) =
    fun _ => some (D1BodySized.s479, D1BodySized.S479)

theorem D1BodySized.k478 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s478 D1BodySized.S478 =
      some (D1BodySized.s479, D1BodySized.S479) := congrFun D1BodySized.checked478 bs

end Host.Load.Run.Tpl
end

section -- SB140
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment140 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s478 D1BodySized.S478 =
      some (D1BodySized.s479, D1BodySized.S479) := D1BodySized.k478 bs

kernel_rfl D1BodySized.accepted140 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s478 D1BodySized.S478) = fun _ => true
kernel_rfl D1BodySized.oracle140 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S478.oracle = true
kernel_rfl D1BodySized.fuelA141 : nth? D1BodySized.ks 479 = some 1
kernel_rfl D1BodySized.fuelB141 : nth? D1BodySized.ks 480 = some 3
kernel_rfl D1BodySized.stepA141 : interpS (step D1BodySized.F D1BodySized.s479).run D1BodySized.S479 =
  some (D1BodySized.s480, D1BodySized.S480)
kernel_rfl D1BodySized.patchB141 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s480).run D1BodySized.S480 =
  some (D1BodySized.s481, D1BodySized.S481)
kernel_rfl D1BodySized.acceptedP141 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s479 D1BodySized.S479) = fun _ => true
kernel_rfl D1BodySized.haltP141 : isHalt D1BodySized.s479.ctl = false
kernel_rfl D1BodySized.topA141 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s480 = true
kernel_rfl D1BodySized.inactive141 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s480.ffi).active = false
/-- Bridge 141's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys141 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s480 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs141 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s480 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA141 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s480 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys141, D1BodySized.sizeArgs141)
kernel_rfl D1BodySized.sizeArgsA141 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s480 = true
kernel_rfl D1BodySized.sizeSymA141 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA141 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA141 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA141 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec141 := interpS (decodeArgs D1BodySized.F D1BodySized.s480 D1BodySized.sizeTys141 D1BodySized.sizeArgs141).run D1BodySized.S480
noncomputable def D1BodySized.sizeAs141 : List Arg := match D1BodySized.sizeDec141 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0141 : SSrv := match D1BodySized.sizeDec141 with | some (_, S) => S | none => D1BodySized.S480
kernel_rfl D1BodySized.sizeDecA141 : interpS (decodeArgs D1BodySized.F D1BodySized.s480 D1BodySized.sizeTys141 D1BodySized.sizeArgs141).run D1BodySized.S480 =
  some (some D1BodySized.sizeAs141, D1BodySized.sizeS0141)
kernel_rfl D1BodySized.sizePreA141 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0141 D1BodySized.s480.ffi D1BodySized.sizeAs141 = true

end Host.Load.Run.Tpl
end

section -- SN481
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel481 : nth? D1BodySized.ks 481 = some 10000
kernel_rfl D1BodySized.checked481 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s481 D1BodySized.S481) =
    fun _ => some (D1BodySized.s482, D1BodySized.S482)

theorem D1BodySized.k481 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s481 D1BodySized.S481 =
      some (D1BodySized.s482, D1BodySized.S482) := congrFun D1BodySized.checked481 bs

end Host.Load.Run.Tpl
end
