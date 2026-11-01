import host.sim.template.a4pre_d1_body.TraceStep
import host.sim.template.a4pre_d1_body.m.B00
import host.sim.Chunk
import host.sim.template.a4pre_d1_body.SizeLift

section -- SN40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel40 : nth? D1BodySized.ks 40 = some 10000
kernel_rfl D1BodySized.checked40 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s40 D1BodySized.S40) =
    fun _ => some (D1BodySized.s41, D1BodySized.S41)

theorem D1BodySized.k40 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s40 D1BodySized.S40 =
      some (D1BodySized.s41, D1BodySized.S41) := congrFun D1BodySized.checked40 bs

end Host.Load.Run.Tpl
end

section -- SN41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel41 : nth? D1BodySized.ks 41 = some 4850
kernel_rfl D1BodySized.checked41 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 4850 D1BodySized.s41 D1BodySized.S41) =
    fun _ => some (D1BodySized.s42, D1BodySized.S42)

theorem D1BodySized.k41 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 4850 D1BodySized.s41 D1BodySized.S41 =
      some (D1BodySized.s42, D1BodySized.S42) := congrFun D1BodySized.checked41 bs

end Host.Load.Run.Tpl
end

section -- SB11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment11 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 14850 D1BodySized.s40 D1BodySized.S40 =
      some (D1BodySized.s42, D1BodySized.S42) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 4850 D1BodySized.s40 D1BodySized.s41 D1BodySized.s42 D1BodySized.S40 D1BodySized.S41 D1BodySized.S42 (D1BodySized.k40 bs) (D1BodySized.k41 bs)

kernel_rfl D1BodySized.accepted11 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s40 D1BodySized.S40) = fun _ => true
kernel_rfl D1BodySized.oracle11 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S40.oracle = true
kernel_rfl D1BodySized.fuelA12 : nth? D1BodySized.ks 42 = some 1
kernel_rfl D1BodySized.fuelB12 : nth? D1BodySized.ks 43 = some 3
kernel_rfl D1BodySized.stepA12 : interpS (step D1BodySized.F D1BodySized.s42).run D1BodySized.S42 =
  some (D1BodySized.s43, D1BodySized.S43)
kernel_rfl D1BodySized.patchB12 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s43).run D1BodySized.S43 =
  some (D1BodySized.s44, D1BodySized.S44)
kernel_rfl D1BodySized.acceptedP12 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s42 D1BodySized.S42) = fun _ => true
kernel_rfl D1BodySized.haltP12 : isHalt D1BodySized.s42.ctl = false
kernel_rfl D1BodySized.topA12 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s43 = true
kernel_rfl D1BodySized.inactive12 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s43.ffi).active = false
/-- Bridge 12's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys12 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s43 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs12 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s43 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA12 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s43 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys12, D1BodySized.sizeArgs12)
kernel_rfl D1BodySized.sizeArgsA12 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s43 = true
kernel_rfl D1BodySized.sizeSymA12 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA12 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA12 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA12 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec12 := interpS (decodeArgs D1BodySized.F D1BodySized.s43 D1BodySized.sizeTys12 D1BodySized.sizeArgs12).run D1BodySized.S43
noncomputable def D1BodySized.sizeAs12 : List Arg := match D1BodySized.sizeDec12 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS012 : SSrv := match D1BodySized.sizeDec12 with | some (_, S) => S | none => D1BodySized.S43
kernel_rfl D1BodySized.sizeDecA12 : interpS (decodeArgs D1BodySized.F D1BodySized.s43 D1BodySized.sizeTys12 D1BodySized.sizeArgs12).run D1BodySized.S43 =
  some (some D1BodySized.sizeAs12, D1BodySized.sizeS012)
kernel_rfl D1BodySized.sizePreA12 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS012 D1BodySized.s43.ffi D1BodySized.sizeAs12 = true

end Host.Load.Run.Tpl
end

section -- SN44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel44 : nth? D1BodySized.ks 44 = some 7716
kernel_rfl D1BodySized.checked44 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s44 D1BodySized.S44) =
    fun _ => some (D1BodySized.s45, D1BodySized.S45)

theorem D1BodySized.k44 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s44 D1BodySized.S44 =
      some (D1BodySized.s45, D1BodySized.S45) := congrFun D1BodySized.checked44 bs

end Host.Load.Run.Tpl
end

section -- SB12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment12 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s44 D1BodySized.S44 =
      some (D1BodySized.s45, D1BodySized.S45) := D1BodySized.k44 bs

kernel_rfl D1BodySized.accepted12 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s44 D1BodySized.S44) = fun _ => true
kernel_rfl D1BodySized.oracle12 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S44.oracle = true
kernel_rfl D1BodySized.fuelA13 : nth? D1BodySized.ks 45 = some 1
kernel_rfl D1BodySized.fuelB13 : nth? D1BodySized.ks 46 = some 3
kernel_rfl D1BodySized.stepA13 : interpS (step D1BodySized.F D1BodySized.s45).run D1BodySized.S45 =
  some (D1BodySized.s46, D1BodySized.S46)
kernel_rfl D1BodySized.patchB13 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s46).run D1BodySized.S46 =
  some (D1BodySized.s47, D1BodySized.S47)
kernel_rfl D1BodySized.acceptedP13 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s45 D1BodySized.S45) = fun _ => true
kernel_rfl D1BodySized.haltP13 : isHalt D1BodySized.s45.ctl = false
kernel_rfl D1BodySized.topA13 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s46 = true
kernel_rfl D1BodySized.inactive13 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s46.ffi).active = false
/-- Bridge 13's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys13 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s46 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs13 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s46 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA13 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s46 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys13, D1BodySized.sizeArgs13)
kernel_rfl D1BodySized.sizeArgsA13 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s46 = true
kernel_rfl D1BodySized.sizeSymA13 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA13 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA13 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA13 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec13 := interpS (decodeArgs D1BodySized.F D1BodySized.s46 D1BodySized.sizeTys13 D1BodySized.sizeArgs13).run D1BodySized.S46
noncomputable def D1BodySized.sizeAs13 : List Arg := match D1BodySized.sizeDec13 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS013 : SSrv := match D1BodySized.sizeDec13 with | some (_, S) => S | none => D1BodySized.S46
kernel_rfl D1BodySized.sizeDecA13 : interpS (decodeArgs D1BodySized.F D1BodySized.s46 D1BodySized.sizeTys13 D1BodySized.sizeArgs13).run D1BodySized.S46 =
  some (some D1BodySized.sizeAs13, D1BodySized.sizeS013)
kernel_rfl D1BodySized.sizePreA13 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS013 D1BodySized.s46.ffi D1BodySized.sizeAs13 = true

end Host.Load.Run.Tpl
end

section -- SN47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel47 : nth? D1BodySized.ks 47 = some 10000
kernel_rfl D1BodySized.checked47 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s47 D1BodySized.S47) =
    fun _ => some (D1BodySized.s48, D1BodySized.S48)

theorem D1BodySized.k47 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s47 D1BodySized.S47 =
      some (D1BodySized.s48, D1BodySized.S48) := congrFun D1BodySized.checked47 bs

end Host.Load.Run.Tpl
end

section -- SN48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel48 : nth? D1BodySized.ks 48 = some 4850
kernel_rfl D1BodySized.checked48 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 4850 D1BodySized.s48 D1BodySized.S48) =
    fun _ => some (D1BodySized.s49, D1BodySized.S49)

theorem D1BodySized.k48 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 4850 D1BodySized.s48 D1BodySized.S48 =
      some (D1BodySized.s49, D1BodySized.S49) := congrFun D1BodySized.checked48 bs

end Host.Load.Run.Tpl
end

section -- SB13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment13 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 14850 D1BodySized.s47 D1BodySized.S47 =
      some (D1BodySized.s49, D1BodySized.S49) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 4850 D1BodySized.s47 D1BodySized.s48 D1BodySized.s49 D1BodySized.S47 D1BodySized.S48 D1BodySized.S49 (D1BodySized.k47 bs) (D1BodySized.k48 bs)

kernel_rfl D1BodySized.accepted13 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s47 D1BodySized.S47) = fun _ => true
kernel_rfl D1BodySized.oracle13 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S47.oracle = true
kernel_rfl D1BodySized.fuelA14 : nth? D1BodySized.ks 49 = some 1
kernel_rfl D1BodySized.fuelB14 : nth? D1BodySized.ks 50 = some 3
kernel_rfl D1BodySized.stepA14 : interpS (step D1BodySized.F D1BodySized.s49).run D1BodySized.S49 =
  some (D1BodySized.s50, D1BodySized.S50)
kernel_rfl D1BodySized.patchB14 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s50).run D1BodySized.S50 =
  some (D1BodySized.s51, D1BodySized.S51)
kernel_rfl D1BodySized.acceptedP14 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s49 D1BodySized.S49) = fun _ => true
kernel_rfl D1BodySized.haltP14 : isHalt D1BodySized.s49.ctl = false
kernel_rfl D1BodySized.topA14 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s50 = true
kernel_rfl D1BodySized.inactive14 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s50.ffi).active = false
/-- Bridge 14's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys14 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s50 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs14 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s50 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA14 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s50 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys14, D1BodySized.sizeArgs14)
kernel_rfl D1BodySized.sizeArgsA14 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s50 = true
kernel_rfl D1BodySized.sizeSymA14 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA14 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA14 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA14 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec14 := interpS (decodeArgs D1BodySized.F D1BodySized.s50 D1BodySized.sizeTys14 D1BodySized.sizeArgs14).run D1BodySized.S50
noncomputable def D1BodySized.sizeAs14 : List Arg := match D1BodySized.sizeDec14 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS014 : SSrv := match D1BodySized.sizeDec14 with | some (_, S) => S | none => D1BodySized.S50
kernel_rfl D1BodySized.sizeDecA14 : interpS (decodeArgs D1BodySized.F D1BodySized.s50 D1BodySized.sizeTys14 D1BodySized.sizeArgs14).run D1BodySized.S50 =
  some (some D1BodySized.sizeAs14, D1BodySized.sizeS014)
kernel_rfl D1BodySized.sizePreA14 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS014 D1BodySized.s50.ffi D1BodySized.sizeAs14 = true

end Host.Load.Run.Tpl
end

section -- SN51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel51 : nth? D1BodySized.ks 51 = some 7716
kernel_rfl D1BodySized.checked51 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s51 D1BodySized.S51) =
    fun _ => some (D1BodySized.s52, D1BodySized.S52)

theorem D1BodySized.k51 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s51 D1BodySized.S51 =
      some (D1BodySized.s52, D1BodySized.S52) := congrFun D1BodySized.checked51 bs

end Host.Load.Run.Tpl
end

section -- SB14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment14 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s51 D1BodySized.S51 =
      some (D1BodySized.s52, D1BodySized.S52) := D1BodySized.k51 bs

kernel_rfl D1BodySized.accepted14 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s51 D1BodySized.S51) = fun _ => true
kernel_rfl D1BodySized.oracle14 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S51.oracle = true
kernel_rfl D1BodySized.fuelA15 : nth? D1BodySized.ks 52 = some 1
kernel_rfl D1BodySized.fuelB15 : nth? D1BodySized.ks 53 = some 3
kernel_rfl D1BodySized.stepA15 : interpS (step D1BodySized.F D1BodySized.s52).run D1BodySized.S52 =
  some (D1BodySized.s53, D1BodySized.S53)
kernel_rfl D1BodySized.patchB15 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s53).run D1BodySized.S53 =
  some (D1BodySized.s54, D1BodySized.S54)
kernel_rfl D1BodySized.acceptedP15 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s52 D1BodySized.S52) = fun _ => true
kernel_rfl D1BodySized.haltP15 : isHalt D1BodySized.s52.ctl = false
kernel_rfl D1BodySized.topA15 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s53 = true
kernel_rfl D1BodySized.inactive15 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s53.ffi).active = false
/-- Bridge 15's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys15 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s53 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs15 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s53 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA15 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s53 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys15, D1BodySized.sizeArgs15)
kernel_rfl D1BodySized.sizeArgsA15 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s53 = true
kernel_rfl D1BodySized.sizeSymA15 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA15 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA15 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA15 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec15 := interpS (decodeArgs D1BodySized.F D1BodySized.s53 D1BodySized.sizeTys15 D1BodySized.sizeArgs15).run D1BodySized.S53
noncomputable def D1BodySized.sizeAs15 : List Arg := match D1BodySized.sizeDec15 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS015 : SSrv := match D1BodySized.sizeDec15 with | some (_, S) => S | none => D1BodySized.S53
kernel_rfl D1BodySized.sizeDecA15 : interpS (decodeArgs D1BodySized.F D1BodySized.s53 D1BodySized.sizeTys15 D1BodySized.sizeArgs15).run D1BodySized.S53 =
  some (some D1BodySized.sizeAs15, D1BodySized.sizeS015)
kernel_rfl D1BodySized.sizePreA15 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS015 D1BodySized.s53.ffi D1BodySized.sizeAs15 = true

end Host.Load.Run.Tpl
end

section -- SN54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel54 : nth? D1BodySized.ks 54 = some 1936
kernel_rfl D1BodySized.checked54 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s54 D1BodySized.S54) =
    fun _ => some (D1BodySized.s55, D1BodySized.S55)

theorem D1BodySized.k54 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s54 D1BodySized.S54 =
      some (D1BodySized.s55, D1BodySized.S55) := congrFun D1BodySized.checked54 bs

end Host.Load.Run.Tpl
end

section -- SB15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment15 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s54 D1BodySized.S54 =
      some (D1BodySized.s55, D1BodySized.S55) := D1BodySized.k54 bs

kernel_rfl D1BodySized.accepted15 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s54 D1BodySized.S54) = fun _ => true
kernel_rfl D1BodySized.oracle15 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S54.oracle = true
kernel_rfl D1BodySized.fuelA16 : nth? D1BodySized.ks 55 = some 1
kernel_rfl D1BodySized.fuelB16 : nth? D1BodySized.ks 56 = some 3
kernel_rfl D1BodySized.stepA16 : interpS (step D1BodySized.F D1BodySized.s55).run D1BodySized.S55 =
  some (D1BodySized.s56, D1BodySized.S56)
kernel_rfl D1BodySized.patchB16 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s56).run D1BodySized.S56 =
  some (D1BodySized.s57, D1BodySized.S57)
kernel_rfl D1BodySized.acceptedP16 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s55 D1BodySized.S55) = fun _ => true
kernel_rfl D1BodySized.haltP16 : isHalt D1BodySized.s55.ctl = false
kernel_rfl D1BodySized.topA16 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s56 = true
kernel_rfl D1BodySized.inactive16 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s56.ffi).active = false
/-- Bridge 16's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys16 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s56 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs16 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s56 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA16 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s56 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys16, D1BodySized.sizeArgs16)
kernel_rfl D1BodySized.sizeArgsA16 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s56 = true
kernel_rfl D1BodySized.sizeSymA16 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA16 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA16 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA16 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec16 := interpS (decodeArgs D1BodySized.F D1BodySized.s56 D1BodySized.sizeTys16 D1BodySized.sizeArgs16).run D1BodySized.S56
noncomputable def D1BodySized.sizeAs16 : List Arg := match D1BodySized.sizeDec16 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS016 : SSrv := match D1BodySized.sizeDec16 with | some (_, S) => S | none => D1BodySized.S56
kernel_rfl D1BodySized.sizeDecA16 : interpS (decodeArgs D1BodySized.F D1BodySized.s56 D1BodySized.sizeTys16 D1BodySized.sizeArgs16).run D1BodySized.S56 =
  some (some D1BodySized.sizeAs16, D1BodySized.sizeS016)
kernel_rfl D1BodySized.sizePreA16 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS016 D1BodySized.s56.ffi D1BodySized.sizeAs16 = true

end Host.Load.Run.Tpl
end

section -- SN57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel57 : nth? D1BodySized.ks 57 = some 10000
kernel_rfl D1BodySized.checked57 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s57 D1BodySized.S57) =
    fun _ => some (D1BodySized.s58, D1BodySized.S58)

theorem D1BodySized.k57 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s57 D1BodySized.S57 =
      some (D1BodySized.s58, D1BodySized.S58) := congrFun D1BodySized.checked57 bs

end Host.Load.Run.Tpl
end

section -- SN58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel58 : nth? D1BodySized.ks 58 = some 2570
kernel_rfl D1BodySized.checked58 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s58 D1BodySized.S58) =
    fun _ => some (D1BodySized.s59, D1BodySized.S59)

theorem D1BodySized.k58 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s58 D1BodySized.S58 =
      some (D1BodySized.s59, D1BodySized.S59) := congrFun D1BodySized.checked58 bs

end Host.Load.Run.Tpl
end

section -- SB16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment16 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s57 D1BodySized.S57 =
      some (D1BodySized.s59, D1BodySized.S59) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s57 D1BodySized.s58 D1BodySized.s59 D1BodySized.S57 D1BodySized.S58 D1BodySized.S59 (D1BodySized.k57 bs) (D1BodySized.k58 bs)

kernel_rfl D1BodySized.accepted16 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s57 D1BodySized.S57) = fun _ => true
kernel_rfl D1BodySized.oracle16 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S57.oracle = true
kernel_rfl D1BodySized.fuelA17 : nth? D1BodySized.ks 59 = some 1
kernel_rfl D1BodySized.fuelB17 : nth? D1BodySized.ks 60 = some 3
kernel_rfl D1BodySized.stepA17 : interpS (step D1BodySized.F D1BodySized.s59).run D1BodySized.S59 =
  some (D1BodySized.s60, D1BodySized.S60)
kernel_rfl D1BodySized.patchB17 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s60).run D1BodySized.S60 =
  some (D1BodySized.s61, D1BodySized.S61)
kernel_rfl D1BodySized.acceptedP17 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s59 D1BodySized.S59) = fun _ => true
kernel_rfl D1BodySized.haltP17 : isHalt D1BodySized.s59.ctl = false
kernel_rfl D1BodySized.topA17 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s60 = true
kernel_rfl D1BodySized.inactive17 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s60.ffi).active = false
/-- Bridge 17's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys17 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s60 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs17 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s60 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA17 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s60 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys17, D1BodySized.sizeArgs17)
kernel_rfl D1BodySized.sizeArgsA17 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s60 = true
kernel_rfl D1BodySized.sizeSymA17 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA17 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA17 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA17 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec17 := interpS (decodeArgs D1BodySized.F D1BodySized.s60 D1BodySized.sizeTys17 D1BodySized.sizeArgs17).run D1BodySized.S60
noncomputable def D1BodySized.sizeAs17 : List Arg := match D1BodySized.sizeDec17 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS017 : SSrv := match D1BodySized.sizeDec17 with | some (_, S) => S | none => D1BodySized.S60
kernel_rfl D1BodySized.sizeDecA17 : interpS (decodeArgs D1BodySized.F D1BodySized.s60 D1BodySized.sizeTys17 D1BodySized.sizeArgs17).run D1BodySized.S60 =
  some (some D1BodySized.sizeAs17, D1BodySized.sizeS017)
kernel_rfl D1BodySized.sizePreA17 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS017 D1BodySized.s60.ffi D1BodySized.sizeAs17 = true

end Host.Load.Run.Tpl
end

section -- SN61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel61 : nth? D1BodySized.ks 61 = some 2542
kernel_rfl D1BodySized.checked61 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s61 D1BodySized.S61) =
    fun _ => some (D1BodySized.s62, D1BodySized.S62)

theorem D1BodySized.k61 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s61 D1BodySized.S61 =
      some (D1BodySized.s62, D1BodySized.S62) := congrFun D1BodySized.checked61 bs

end Host.Load.Run.Tpl
end

section -- SB17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment17 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s61 D1BodySized.S61 =
      some (D1BodySized.s62, D1BodySized.S62) := D1BodySized.k61 bs

kernel_rfl D1BodySized.accepted17 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s61 D1BodySized.S61) = fun _ => true
kernel_rfl D1BodySized.oracle17 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S61.oracle = true
kernel_rfl D1BodySized.fuelA18 : nth? D1BodySized.ks 62 = some 1
kernel_rfl D1BodySized.fuelB18 : nth? D1BodySized.ks 63 = some 3
kernel_rfl D1BodySized.stepA18 : interpS (step D1BodySized.F D1BodySized.s62).run D1BodySized.S62 =
  some (D1BodySized.s63, D1BodySized.S63)
kernel_rfl D1BodySized.patchB18 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s63).run D1BodySized.S63 =
  some (D1BodySized.s64, D1BodySized.S64)
kernel_rfl D1BodySized.acceptedP18 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s62 D1BodySized.S62) = fun _ => true
kernel_rfl D1BodySized.haltP18 : isHalt D1BodySized.s62.ctl = false
kernel_rfl D1BodySized.topA18 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s63 = true
kernel_rfl D1BodySized.inactive18 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s63.ffi).active = false
/-- Bridge 18's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys18 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s63 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs18 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s63 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA18 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s63 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys18, D1BodySized.sizeArgs18)
kernel_rfl D1BodySized.sizeArgsA18 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s63 = true
kernel_rfl D1BodySized.sizeSymA18 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA18 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA18 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA18 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec18 := interpS (decodeArgs D1BodySized.F D1BodySized.s63 D1BodySized.sizeTys18 D1BodySized.sizeArgs18).run D1BodySized.S63
noncomputable def D1BodySized.sizeAs18 : List Arg := match D1BodySized.sizeDec18 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS018 : SSrv := match D1BodySized.sizeDec18 with | some (_, S) => S | none => D1BodySized.S63
kernel_rfl D1BodySized.sizeDecA18 : interpS (decodeArgs D1BodySized.F D1BodySized.s63 D1BodySized.sizeTys18 D1BodySized.sizeArgs18).run D1BodySized.S63 =
  some (some D1BodySized.sizeAs18, D1BodySized.sizeS018)
kernel_rfl D1BodySized.sizePreA18 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS018 D1BodySized.s63.ffi D1BodySized.sizeAs18 = true

end Host.Load.Run.Tpl
end

section -- SN64
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel64 : nth? D1BodySized.ks 64 = some 10000
kernel_rfl D1BodySized.checked64 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s64 D1BodySized.S64) =
    fun _ => some (D1BodySized.s65, D1BodySized.S65)

theorem D1BodySized.k64 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s64 D1BodySized.S64 =
      some (D1BodySized.s65, D1BodySized.S65) := congrFun D1BodySized.checked64 bs

end Host.Load.Run.Tpl
end

section -- SN65
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel65 : nth? D1BodySized.ks 65 = some 10000
kernel_rfl D1BodySized.checked65 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s65 D1BodySized.S65) =
    fun _ => some (D1BodySized.s66, D1BodySized.S66)

theorem D1BodySized.k65 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s65 D1BodySized.S65 =
      some (D1BodySized.s66, D1BodySized.S66) := congrFun D1BodySized.checked65 bs

end Host.Load.Run.Tpl
end

section -- SN66
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel66 : nth? D1BodySized.ks 66 = some 2287
kernel_rfl D1BodySized.checked66 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s66 D1BodySized.S66) =
    fun _ => some (D1BodySized.s67, D1BodySized.S67)

theorem D1BodySized.k66 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s66 D1BodySized.S66 =
      some (D1BodySized.s67, D1BodySized.S67) := congrFun D1BodySized.checked66 bs

end Host.Load.Run.Tpl
end

section -- SB18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment18 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22287 D1BodySized.s64 D1BodySized.S64 =
      some (D1BodySized.s67, D1BodySized.S67) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2287 D1BodySized.s64 D1BodySized.s66 D1BodySized.s67 D1BodySized.S64 D1BodySized.S66 D1BodySized.S67 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s64 D1BodySized.s65 D1BodySized.s66 D1BodySized.S64 D1BodySized.S65 D1BodySized.S66 (D1BodySized.k64 bs) (D1BodySized.k65 bs)) (D1BodySized.k66 bs)

kernel_rfl D1BodySized.accepted18 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s64 D1BodySized.S64) = fun _ => true
kernel_rfl D1BodySized.oracle18 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S64.oracle = true
kernel_rfl D1BodySized.fuelA19 : nth? D1BodySized.ks 67 = some 1
kernel_rfl D1BodySized.fuelB19 : nth? D1BodySized.ks 68 = some 3
kernel_rfl D1BodySized.stepA19 : interpS (step D1BodySized.F D1BodySized.s67).run D1BodySized.S67 =
  some (D1BodySized.s68, D1BodySized.S68)
kernel_rfl D1BodySized.patchB19 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s68).run D1BodySized.S68 =
  some (D1BodySized.s69, D1BodySized.S69)
kernel_rfl D1BodySized.acceptedP19 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s67 D1BodySized.S67) = fun _ => true
kernel_rfl D1BodySized.haltP19 : isHalt D1BodySized.s67.ctl = false
kernel_rfl D1BodySized.topA19 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s68 = true
kernel_rfl D1BodySized.inactive19 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s68.ffi).active = false
/-- Bridge 19's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys19 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s68 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs19 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s68 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA19 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s68 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys19, D1BodySized.sizeArgs19)
kernel_rfl D1BodySized.sizeArgsA19 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s68 = true
kernel_rfl D1BodySized.sizeSymA19 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA19 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA19 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA19 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec19 := interpS (decodeArgs D1BodySized.F D1BodySized.s68 D1BodySized.sizeTys19 D1BodySized.sizeArgs19).run D1BodySized.S68
noncomputable def D1BodySized.sizeAs19 : List Arg := match D1BodySized.sizeDec19 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS019 : SSrv := match D1BodySized.sizeDec19 with | some (_, S) => S | none => D1BodySized.S68
kernel_rfl D1BodySized.sizeDecA19 : interpS (decodeArgs D1BodySized.F D1BodySized.s68 D1BodySized.sizeTys19 D1BodySized.sizeArgs19).run D1BodySized.S68 =
  some (some D1BodySized.sizeAs19, D1BodySized.sizeS019)
kernel_rfl D1BodySized.sizePreA19 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS019 D1BodySized.s68.ffi D1BodySized.sizeAs19 = true

end Host.Load.Run.Tpl
end

section -- SN69
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel69 : nth? D1BodySized.ks 69 = some 7934
kernel_rfl D1BodySized.checked69 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s69 D1BodySized.S69) =
    fun _ => some (D1BodySized.s70, D1BodySized.S70)

theorem D1BodySized.k69 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s69 D1BodySized.S69 =
      some (D1BodySized.s70, D1BodySized.S70) := congrFun D1BodySized.checked69 bs

end Host.Load.Run.Tpl
end

section -- SB19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment19 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s69 D1BodySized.S69 =
      some (D1BodySized.s70, D1BodySized.S70) := D1BodySized.k69 bs

kernel_rfl D1BodySized.accepted19 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s69 D1BodySized.S69) = fun _ => true
kernel_rfl D1BodySized.oracle19 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S69.oracle = true
kernel_rfl D1BodySized.fuelA20 : nth? D1BodySized.ks 70 = some 1
kernel_rfl D1BodySized.fuelB20 : nth? D1BodySized.ks 71 = some 3
kernel_rfl D1BodySized.stepA20 : interpS (step D1BodySized.F D1BodySized.s70).run D1BodySized.S70 =
  some (D1BodySized.s71, D1BodySized.S71)
kernel_rfl D1BodySized.patchB20 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s71).run D1BodySized.S71 =
  some (D1BodySized.s72, D1BodySized.S72)
kernel_rfl D1BodySized.acceptedP20 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s70 D1BodySized.S70) = fun _ => true
kernel_rfl D1BodySized.haltP20 : isHalt D1BodySized.s70.ctl = false
kernel_rfl D1BodySized.topA20 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s71 = true
kernel_rfl D1BodySized.inactive20 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s71.ffi).active = false
/-- Bridge 20's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys20 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s71 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs20 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s71 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA20 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s71 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys20, D1BodySized.sizeArgs20)
kernel_rfl D1BodySized.sizeArgsA20 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s71 = true
kernel_rfl D1BodySized.sizeSymA20 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA20 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA20 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA20 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec20 := interpS (decodeArgs D1BodySized.F D1BodySized.s71 D1BodySized.sizeTys20 D1BodySized.sizeArgs20).run D1BodySized.S71
noncomputable def D1BodySized.sizeAs20 : List Arg := match D1BodySized.sizeDec20 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS020 : SSrv := match D1BodySized.sizeDec20 with | some (_, S) => S | none => D1BodySized.S71
kernel_rfl D1BodySized.sizeDecA20 : interpS (decodeArgs D1BodySized.F D1BodySized.s71 D1BodySized.sizeTys20 D1BodySized.sizeArgs20).run D1BodySized.S71 =
  some (some D1BodySized.sizeAs20, D1BodySized.sizeS020)
kernel_rfl D1BodySized.sizePreA20 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS020 D1BodySized.s71.ffi D1BodySized.sizeAs20 = true

end Host.Load.Run.Tpl
end

section -- SN72
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel72 : nth? D1BodySized.ks 72 = some 1936
kernel_rfl D1BodySized.checked72 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s72 D1BodySized.S72) =
    fun _ => some (D1BodySized.s73, D1BodySized.S73)

theorem D1BodySized.k72 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s72 D1BodySized.S72 =
      some (D1BodySized.s73, D1BodySized.S73) := congrFun D1BodySized.checked72 bs

end Host.Load.Run.Tpl
end

section -- SB20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment20 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s72 D1BodySized.S72 =
      some (D1BodySized.s73, D1BodySized.S73) := D1BodySized.k72 bs

kernel_rfl D1BodySized.accepted20 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s72 D1BodySized.S72) = fun _ => true
kernel_rfl D1BodySized.oracle20 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S72.oracle = true
kernel_rfl D1BodySized.fuelA21 : nth? D1BodySized.ks 73 = some 1
kernel_rfl D1BodySized.fuelB21 : nth? D1BodySized.ks 74 = some 3
kernel_rfl D1BodySized.stepA21 : interpS (step D1BodySized.F D1BodySized.s73).run D1BodySized.S73 =
  some (D1BodySized.s74, D1BodySized.S74)
kernel_rfl D1BodySized.patchB21 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s74).run D1BodySized.S74 =
  some (D1BodySized.s75, D1BodySized.S75)
kernel_rfl D1BodySized.acceptedP21 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s73 D1BodySized.S73) = fun _ => true
kernel_rfl D1BodySized.haltP21 : isHalt D1BodySized.s73.ctl = false
kernel_rfl D1BodySized.topA21 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s74 = true
kernel_rfl D1BodySized.inactive21 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s74.ffi).active = false
/-- Bridge 21's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys21 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s74 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs21 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s74 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA21 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s74 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys21, D1BodySized.sizeArgs21)
kernel_rfl D1BodySized.sizeArgsA21 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s74 = true
kernel_rfl D1BodySized.sizeSymA21 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA21 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA21 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA21 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec21 := interpS (decodeArgs D1BodySized.F D1BodySized.s74 D1BodySized.sizeTys21 D1BodySized.sizeArgs21).run D1BodySized.S74
noncomputable def D1BodySized.sizeAs21 : List Arg := match D1BodySized.sizeDec21 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS021 : SSrv := match D1BodySized.sizeDec21 with | some (_, S) => S | none => D1BodySized.S74
kernel_rfl D1BodySized.sizeDecA21 : interpS (decodeArgs D1BodySized.F D1BodySized.s74 D1BodySized.sizeTys21 D1BodySized.sizeArgs21).run D1BodySized.S74 =
  some (some D1BodySized.sizeAs21, D1BodySized.sizeS021)
kernel_rfl D1BodySized.sizePreA21 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS021 D1BodySized.s74.ffi D1BodySized.sizeAs21 = true

end Host.Load.Run.Tpl
end

section -- SN75
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel75 : nth? D1BodySized.ks 75 = some 10000
kernel_rfl D1BodySized.checked75 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s75 D1BodySized.S75) =
    fun _ => some (D1BodySized.s76, D1BodySized.S76)

theorem D1BodySized.k75 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s75 D1BodySized.S75 =
      some (D1BodySized.s76, D1BodySized.S76) := congrFun D1BodySized.checked75 bs

end Host.Load.Run.Tpl
end

section -- SN76
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel76 : nth? D1BodySized.ks 76 = some 2570
kernel_rfl D1BodySized.checked76 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s76 D1BodySized.S76) =
    fun _ => some (D1BodySized.s77, D1BodySized.S77)

theorem D1BodySized.k76 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s76 D1BodySized.S76 =
      some (D1BodySized.s77, D1BodySized.S77) := congrFun D1BodySized.checked76 bs

end Host.Load.Run.Tpl
end

section -- SB21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment21 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s75 D1BodySized.S75 =
      some (D1BodySized.s77, D1BodySized.S77) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s75 D1BodySized.s76 D1BodySized.s77 D1BodySized.S75 D1BodySized.S76 D1BodySized.S77 (D1BodySized.k75 bs) (D1BodySized.k76 bs)

kernel_rfl D1BodySized.accepted21 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s75 D1BodySized.S75) = fun _ => true
kernel_rfl D1BodySized.oracle21 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S75.oracle = true
kernel_rfl D1BodySized.fuelA22 : nth? D1BodySized.ks 77 = some 1
kernel_rfl D1BodySized.fuelB22 : nth? D1BodySized.ks 78 = some 3
kernel_rfl D1BodySized.stepA22 : interpS (step D1BodySized.F D1BodySized.s77).run D1BodySized.S77 =
  some (D1BodySized.s78, D1BodySized.S78)
kernel_rfl D1BodySized.patchB22 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s78).run D1BodySized.S78 =
  some (D1BodySized.s79, D1BodySized.S79)
kernel_rfl D1BodySized.acceptedP22 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s77 D1BodySized.S77) = fun _ => true
kernel_rfl D1BodySized.haltP22 : isHalt D1BodySized.s77.ctl = false
kernel_rfl D1BodySized.topA22 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s78 = true
kernel_rfl D1BodySized.inactive22 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s78.ffi).active = false
/-- Bridge 22's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys22 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s78 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs22 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s78 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA22 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s78 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys22, D1BodySized.sizeArgs22)
kernel_rfl D1BodySized.sizeArgsA22 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s78 = true
kernel_rfl D1BodySized.sizeSymA22 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA22 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA22 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA22 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec22 := interpS (decodeArgs D1BodySized.F D1BodySized.s78 D1BodySized.sizeTys22 D1BodySized.sizeArgs22).run D1BodySized.S78
noncomputable def D1BodySized.sizeAs22 : List Arg := match D1BodySized.sizeDec22 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS022 : SSrv := match D1BodySized.sizeDec22 with | some (_, S) => S | none => D1BodySized.S78
kernel_rfl D1BodySized.sizeDecA22 : interpS (decodeArgs D1BodySized.F D1BodySized.s78 D1BodySized.sizeTys22 D1BodySized.sizeArgs22).run D1BodySized.S78 =
  some (some D1BodySized.sizeAs22, D1BodySized.sizeS022)
kernel_rfl D1BodySized.sizePreA22 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS022 D1BodySized.s78.ffi D1BodySized.sizeAs22 = true

end Host.Load.Run.Tpl
end

section -- SN79
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel79 : nth? D1BodySized.ks 79 = some 2542
kernel_rfl D1BodySized.checked79 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s79 D1BodySized.S79) =
    fun _ => some (D1BodySized.s80, D1BodySized.S80)

theorem D1BodySized.k79 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s79 D1BodySized.S79 =
      some (D1BodySized.s80, D1BodySized.S80) := congrFun D1BodySized.checked79 bs

end Host.Load.Run.Tpl
end

section -- SB22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment22 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s79 D1BodySized.S79 =
      some (D1BodySized.s80, D1BodySized.S80) := D1BodySized.k79 bs

kernel_rfl D1BodySized.accepted22 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s79 D1BodySized.S79) = fun _ => true
kernel_rfl D1BodySized.oracle22 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S79.oracle = true
kernel_rfl D1BodySized.fuelA23 : nth? D1BodySized.ks 80 = some 1
kernel_rfl D1BodySized.fuelB23 : nth? D1BodySized.ks 81 = some 3
kernel_rfl D1BodySized.stepA23 : interpS (step D1BodySized.F D1BodySized.s80).run D1BodySized.S80 =
  some (D1BodySized.s81, D1BodySized.S81)
kernel_rfl D1BodySized.patchB23 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s81).run D1BodySized.S81 =
  some (D1BodySized.s82, D1BodySized.S82)
kernel_rfl D1BodySized.acceptedP23 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s80 D1BodySized.S80) = fun _ => true
kernel_rfl D1BodySized.haltP23 : isHalt D1BodySized.s80.ctl = false
kernel_rfl D1BodySized.topA23 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s81 = true
kernel_rfl D1BodySized.inactive23 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s81.ffi).active = false
/-- Bridge 23's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys23 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s81 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs23 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s81 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA23 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s81 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys23, D1BodySized.sizeArgs23)
kernel_rfl D1BodySized.sizeArgsA23 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s81 = true
kernel_rfl D1BodySized.sizeSymA23 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA23 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA23 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA23 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec23 := interpS (decodeArgs D1BodySized.F D1BodySized.s81 D1BodySized.sizeTys23 D1BodySized.sizeArgs23).run D1BodySized.S81
noncomputable def D1BodySized.sizeAs23 : List Arg := match D1BodySized.sizeDec23 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS023 : SSrv := match D1BodySized.sizeDec23 with | some (_, S) => S | none => D1BodySized.S81
kernel_rfl D1BodySized.sizeDecA23 : interpS (decodeArgs D1BodySized.F D1BodySized.s81 D1BodySized.sizeTys23 D1BodySized.sizeArgs23).run D1BodySized.S81 =
  some (some D1BodySized.sizeAs23, D1BodySized.sizeS023)
kernel_rfl D1BodySized.sizePreA23 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS023 D1BodySized.s81.ffi D1BodySized.sizeAs23 = true

end Host.Load.Run.Tpl
end

section -- SN82
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel82 : nth? D1BodySized.ks 82 = some 7716
kernel_rfl D1BodySized.checked82 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s82 D1BodySized.S82) =
    fun _ => some (D1BodySized.s83, D1BodySized.S83)

theorem D1BodySized.k82 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s82 D1BodySized.S82 =
      some (D1BodySized.s83, D1BodySized.S83) := congrFun D1BodySized.checked82 bs

end Host.Load.Run.Tpl
end

section -- SB23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment23 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s82 D1BodySized.S82 =
      some (D1BodySized.s83, D1BodySized.S83) := D1BodySized.k82 bs

kernel_rfl D1BodySized.accepted23 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s82 D1BodySized.S82) = fun _ => true
kernel_rfl D1BodySized.oracle23 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S82.oracle = true
kernel_rfl D1BodySized.fuelA24 : nth? D1BodySized.ks 83 = some 1
kernel_rfl D1BodySized.fuelB24 : nth? D1BodySized.ks 84 = some 3
kernel_rfl D1BodySized.stepA24 : interpS (step D1BodySized.F D1BodySized.s83).run D1BodySized.S83 =
  some (D1BodySized.s84, D1BodySized.S84)
kernel_rfl D1BodySized.patchB24 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s84).run D1BodySized.S84 =
  some (D1BodySized.s85, D1BodySized.S85)
kernel_rfl D1BodySized.acceptedP24 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s83 D1BodySized.S83) = fun _ => true
kernel_rfl D1BodySized.haltP24 : isHalt D1BodySized.s83.ctl = false
kernel_rfl D1BodySized.topA24 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s84 = true
kernel_rfl D1BodySized.inactive24 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s84.ffi).active = false
/-- Bridge 24's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys24 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s84 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs24 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s84 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA24 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s84 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys24, D1BodySized.sizeArgs24)
kernel_rfl D1BodySized.sizeArgsA24 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s84 = true
kernel_rfl D1BodySized.sizeSymA24 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA24 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA24 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA24 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec24 := interpS (decodeArgs D1BodySized.F D1BodySized.s84 D1BodySized.sizeTys24 D1BodySized.sizeArgs24).run D1BodySized.S84
noncomputable def D1BodySized.sizeAs24 : List Arg := match D1BodySized.sizeDec24 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS024 : SSrv := match D1BodySized.sizeDec24 with | some (_, S) => S | none => D1BodySized.S84
kernel_rfl D1BodySized.sizeDecA24 : interpS (decodeArgs D1BodySized.F D1BodySized.s84 D1BodySized.sizeTys24 D1BodySized.sizeArgs24).run D1BodySized.S84 =
  some (some D1BodySized.sizeAs24, D1BodySized.sizeS024)
kernel_rfl D1BodySized.sizePreA24 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS024 D1BodySized.s84.ffi D1BodySized.sizeAs24 = true

end Host.Load.Run.Tpl
end

section -- SN85
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel85 : nth? D1BodySized.ks 85 = some 1936
kernel_rfl D1BodySized.checked85 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s85 D1BodySized.S85) =
    fun _ => some (D1BodySized.s86, D1BodySized.S86)

theorem D1BodySized.k85 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s85 D1BodySized.S85 =
      some (D1BodySized.s86, D1BodySized.S86) := congrFun D1BodySized.checked85 bs

end Host.Load.Run.Tpl
end

section -- SB24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment24 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s85 D1BodySized.S85 =
      some (D1BodySized.s86, D1BodySized.S86) := D1BodySized.k85 bs

kernel_rfl D1BodySized.accepted24 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s85 D1BodySized.S85) = fun _ => true
kernel_rfl D1BodySized.oracle24 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S85.oracle = true
kernel_rfl D1BodySized.fuelA25 : nth? D1BodySized.ks 86 = some 1
kernel_rfl D1BodySized.fuelB25 : nth? D1BodySized.ks 87 = some 3
kernel_rfl D1BodySized.stepA25 : interpS (step D1BodySized.F D1BodySized.s86).run D1BodySized.S86 =
  some (D1BodySized.s87, D1BodySized.S87)
kernel_rfl D1BodySized.patchB25 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s87).run D1BodySized.S87 =
  some (D1BodySized.s88, D1BodySized.S88)
kernel_rfl D1BodySized.acceptedP25 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s86 D1BodySized.S86) = fun _ => true
kernel_rfl D1BodySized.haltP25 : isHalt D1BodySized.s86.ctl = false
kernel_rfl D1BodySized.topA25 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s87 = true
kernel_rfl D1BodySized.inactive25 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s87.ffi).active = false
/-- Bridge 25's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys25 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s87 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs25 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s87 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA25 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s87 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys25, D1BodySized.sizeArgs25)
kernel_rfl D1BodySized.sizeArgsA25 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s87 = true
kernel_rfl D1BodySized.sizeSymA25 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA25 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA25 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA25 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec25 := interpS (decodeArgs D1BodySized.F D1BodySized.s87 D1BodySized.sizeTys25 D1BodySized.sizeArgs25).run D1BodySized.S87
noncomputable def D1BodySized.sizeAs25 : List Arg := match D1BodySized.sizeDec25 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS025 : SSrv := match D1BodySized.sizeDec25 with | some (_, S) => S | none => D1BodySized.S87
kernel_rfl D1BodySized.sizeDecA25 : interpS (decodeArgs D1BodySized.F D1BodySized.s87 D1BodySized.sizeTys25 D1BodySized.sizeArgs25).run D1BodySized.S87 =
  some (some D1BodySized.sizeAs25, D1BodySized.sizeS025)
kernel_rfl D1BodySized.sizePreA25 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS025 D1BodySized.s87.ffi D1BodySized.sizeAs25 = true

end Host.Load.Run.Tpl
end

section -- SN88
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel88 : nth? D1BodySized.ks 88 = some 10000
kernel_rfl D1BodySized.checked88 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s88 D1BodySized.S88) =
    fun _ => some (D1BodySized.s89, D1BodySized.S89)

theorem D1BodySized.k88 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s88 D1BodySized.S88 =
      some (D1BodySized.s89, D1BodySized.S89) := congrFun D1BodySized.checked88 bs

end Host.Load.Run.Tpl
end

section -- SN89
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel89 : nth? D1BodySized.ks 89 = some 2570
kernel_rfl D1BodySized.checked89 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s89 D1BodySized.S89) =
    fun _ => some (D1BodySized.s90, D1BodySized.S90)

theorem D1BodySized.k89 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s89 D1BodySized.S89 =
      some (D1BodySized.s90, D1BodySized.S90) := congrFun D1BodySized.checked89 bs

end Host.Load.Run.Tpl
end

section -- SB25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment25 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s88 D1BodySized.S88 =
      some (D1BodySized.s90, D1BodySized.S90) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s88 D1BodySized.s89 D1BodySized.s90 D1BodySized.S88 D1BodySized.S89 D1BodySized.S90 (D1BodySized.k88 bs) (D1BodySized.k89 bs)

kernel_rfl D1BodySized.accepted25 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s88 D1BodySized.S88) = fun _ => true
kernel_rfl D1BodySized.oracle25 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S88.oracle = true
kernel_rfl D1BodySized.fuelA26 : nth? D1BodySized.ks 90 = some 1
kernel_rfl D1BodySized.fuelB26 : nth? D1BodySized.ks 91 = some 3
kernel_rfl D1BodySized.stepA26 : interpS (step D1BodySized.F D1BodySized.s90).run D1BodySized.S90 =
  some (D1BodySized.s91, D1BodySized.S91)
kernel_rfl D1BodySized.patchB26 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s91).run D1BodySized.S91 =
  some (D1BodySized.s92, D1BodySized.S92)
kernel_rfl D1BodySized.acceptedP26 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s90 D1BodySized.S90) = fun _ => true
kernel_rfl D1BodySized.haltP26 : isHalt D1BodySized.s90.ctl = false
kernel_rfl D1BodySized.topA26 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s91 = true
kernel_rfl D1BodySized.inactive26 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s91.ffi).active = false
/-- Bridge 26's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys26 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s91 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs26 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s91 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA26 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s91 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys26, D1BodySized.sizeArgs26)
kernel_rfl D1BodySized.sizeArgsA26 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s91 = true
kernel_rfl D1BodySized.sizeSymA26 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA26 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA26 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA26 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec26 := interpS (decodeArgs D1BodySized.F D1BodySized.s91 D1BodySized.sizeTys26 D1BodySized.sizeArgs26).run D1BodySized.S91
noncomputable def D1BodySized.sizeAs26 : List Arg := match D1BodySized.sizeDec26 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS026 : SSrv := match D1BodySized.sizeDec26 with | some (_, S) => S | none => D1BodySized.S91
kernel_rfl D1BodySized.sizeDecA26 : interpS (decodeArgs D1BodySized.F D1BodySized.s91 D1BodySized.sizeTys26 D1BodySized.sizeArgs26).run D1BodySized.S91 =
  some (some D1BodySized.sizeAs26, D1BodySized.sizeS026)
kernel_rfl D1BodySized.sizePreA26 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS026 D1BodySized.s91.ffi D1BodySized.sizeAs26 = true

end Host.Load.Run.Tpl
end

section -- SN92
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel92 : nth? D1BodySized.ks 92 = some 2542
kernel_rfl D1BodySized.checked92 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s92 D1BodySized.S92) =
    fun _ => some (D1BodySized.s93, D1BodySized.S93)

theorem D1BodySized.k92 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s92 D1BodySized.S92 =
      some (D1BodySized.s93, D1BodySized.S93) := congrFun D1BodySized.checked92 bs

end Host.Load.Run.Tpl
end

section -- SB26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment26 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s92 D1BodySized.S92 =
      some (D1BodySized.s93, D1BodySized.S93) := D1BodySized.k92 bs

kernel_rfl D1BodySized.accepted26 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s92 D1BodySized.S92) = fun _ => true
kernel_rfl D1BodySized.oracle26 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S92.oracle = true
kernel_rfl D1BodySized.fuelA27 : nth? D1BodySized.ks 93 = some 1
kernel_rfl D1BodySized.fuelB27 : nth? D1BodySized.ks 94 = some 3
kernel_rfl D1BodySized.stepA27 : interpS (step D1BodySized.F D1BodySized.s93).run D1BodySized.S93 =
  some (D1BodySized.s94, D1BodySized.S94)
kernel_rfl D1BodySized.patchB27 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s94).run D1BodySized.S94 =
  some (D1BodySized.s95, D1BodySized.S95)
kernel_rfl D1BodySized.acceptedP27 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s93 D1BodySized.S93) = fun _ => true
kernel_rfl D1BodySized.haltP27 : isHalt D1BodySized.s93.ctl = false
kernel_rfl D1BodySized.topA27 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s94 = true
kernel_rfl D1BodySized.inactive27 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s94.ffi).active = false
/-- Bridge 27's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys27 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s94 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs27 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s94 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA27 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s94 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys27, D1BodySized.sizeArgs27)
kernel_rfl D1BodySized.sizeArgsA27 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s94 = true
kernel_rfl D1BodySized.sizeSymA27 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA27 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA27 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA27 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec27 := interpS (decodeArgs D1BodySized.F D1BodySized.s94 D1BodySized.sizeTys27 D1BodySized.sizeArgs27).run D1BodySized.S94
noncomputable def D1BodySized.sizeAs27 : List Arg := match D1BodySized.sizeDec27 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS027 : SSrv := match D1BodySized.sizeDec27 with | some (_, S) => S | none => D1BodySized.S94
kernel_rfl D1BodySized.sizeDecA27 : interpS (decodeArgs D1BodySized.F D1BodySized.s94 D1BodySized.sizeTys27 D1BodySized.sizeArgs27).run D1BodySized.S94 =
  some (some D1BodySized.sizeAs27, D1BodySized.sizeS027)
kernel_rfl D1BodySized.sizePreA27 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS027 D1BodySized.s94.ffi D1BodySized.sizeAs27 = true

end Host.Load.Run.Tpl
end

section -- SN95
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel95 : nth? D1BodySized.ks 95 = some 7716
kernel_rfl D1BodySized.checked95 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s95 D1BodySized.S95) =
    fun _ => some (D1BodySized.s96, D1BodySized.S96)

theorem D1BodySized.k95 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s95 D1BodySized.S95 =
      some (D1BodySized.s96, D1BodySized.S96) := congrFun D1BodySized.checked95 bs

end Host.Load.Run.Tpl
end

section -- SB27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment27 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s95 D1BodySized.S95 =
      some (D1BodySized.s96, D1BodySized.S96) := D1BodySized.k95 bs

kernel_rfl D1BodySized.accepted27 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s95 D1BodySized.S95) = fun _ => true
kernel_rfl D1BodySized.oracle27 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S95.oracle = true
kernel_rfl D1BodySized.fuelA28 : nth? D1BodySized.ks 96 = some 1
kernel_rfl D1BodySized.fuelB28 : nth? D1BodySized.ks 97 = some 3
kernel_rfl D1BodySized.stepA28 : interpS (step D1BodySized.F D1BodySized.s96).run D1BodySized.S96 =
  some (D1BodySized.s97, D1BodySized.S97)
kernel_rfl D1BodySized.patchB28 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s97).run D1BodySized.S97 =
  some (D1BodySized.s98, D1BodySized.S98)
kernel_rfl D1BodySized.acceptedP28 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s96 D1BodySized.S96) = fun _ => true
kernel_rfl D1BodySized.haltP28 : isHalt D1BodySized.s96.ctl = false
kernel_rfl D1BodySized.topA28 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s97 = true
kernel_rfl D1BodySized.inactive28 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s97.ffi).active = false
/-- Bridge 28's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys28 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s97 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs28 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s97 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA28 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s97 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys28, D1BodySized.sizeArgs28)
kernel_rfl D1BodySized.sizeArgsA28 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s97 = true
kernel_rfl D1BodySized.sizeSymA28 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA28 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA28 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA28 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec28 := interpS (decodeArgs D1BodySized.F D1BodySized.s97 D1BodySized.sizeTys28 D1BodySized.sizeArgs28).run D1BodySized.S97
noncomputable def D1BodySized.sizeAs28 : List Arg := match D1BodySized.sizeDec28 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS028 : SSrv := match D1BodySized.sizeDec28 with | some (_, S) => S | none => D1BodySized.S97
kernel_rfl D1BodySized.sizeDecA28 : interpS (decodeArgs D1BodySized.F D1BodySized.s97 D1BodySized.sizeTys28 D1BodySized.sizeArgs28).run D1BodySized.S97 =
  some (some D1BodySized.sizeAs28, D1BodySized.sizeS028)
kernel_rfl D1BodySized.sizePreA28 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS028 D1BodySized.s97.ffi D1BodySized.sizeAs28 = true

end Host.Load.Run.Tpl
end

section -- SN98
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel98 : nth? D1BodySized.ks 98 = some 1936
kernel_rfl D1BodySized.checked98 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s98 D1BodySized.S98) =
    fun _ => some (D1BodySized.s99, D1BodySized.S99)

theorem D1BodySized.k98 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s98 D1BodySized.S98 =
      some (D1BodySized.s99, D1BodySized.S99) := congrFun D1BodySized.checked98 bs

end Host.Load.Run.Tpl
end

section -- SB28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment28 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s98 D1BodySized.S98 =
      some (D1BodySized.s99, D1BodySized.S99) := D1BodySized.k98 bs

kernel_rfl D1BodySized.accepted28 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s98 D1BodySized.S98) = fun _ => true
kernel_rfl D1BodySized.oracle28 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S98.oracle = true
kernel_rfl D1BodySized.fuelA29 : nth? D1BodySized.ks 99 = some 1
kernel_rfl D1BodySized.fuelB29 : nth? D1BodySized.ks 100 = some 3
kernel_rfl D1BodySized.stepA29 : interpS (step D1BodySized.F D1BodySized.s99).run D1BodySized.S99 =
  some (D1BodySized.s100, D1BodySized.S100)
kernel_rfl D1BodySized.patchB29 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s100).run D1BodySized.S100 =
  some (D1BodySized.s101, D1BodySized.S101)
kernel_rfl D1BodySized.acceptedP29 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s99 D1BodySized.S99) = fun _ => true
kernel_rfl D1BodySized.haltP29 : isHalt D1BodySized.s99.ctl = false
kernel_rfl D1BodySized.topA29 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s100 = true
kernel_rfl D1BodySized.inactive29 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s100.ffi).active = false
/-- Bridge 29's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys29 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s100 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs29 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s100 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA29 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s100 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys29, D1BodySized.sizeArgs29)
kernel_rfl D1BodySized.sizeArgsA29 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s100 = true
kernel_rfl D1BodySized.sizeSymA29 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA29 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA29 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA29 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec29 := interpS (decodeArgs D1BodySized.F D1BodySized.s100 D1BodySized.sizeTys29 D1BodySized.sizeArgs29).run D1BodySized.S100
noncomputable def D1BodySized.sizeAs29 : List Arg := match D1BodySized.sizeDec29 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS029 : SSrv := match D1BodySized.sizeDec29 with | some (_, S) => S | none => D1BodySized.S100
kernel_rfl D1BodySized.sizeDecA29 : interpS (decodeArgs D1BodySized.F D1BodySized.s100 D1BodySized.sizeTys29 D1BodySized.sizeArgs29).run D1BodySized.S100 =
  some (some D1BodySized.sizeAs29, D1BodySized.sizeS029)
kernel_rfl D1BodySized.sizePreA29 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS029 D1BodySized.s100.ffi D1BodySized.sizeAs29 = true

end Host.Load.Run.Tpl
end

section -- SN101
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel101 : nth? D1BodySized.ks 101 = some 10000
kernel_rfl D1BodySized.checked101 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s101 D1BodySized.S101) =
    fun _ => some (D1BodySized.s102, D1BodySized.S102)

theorem D1BodySized.k101 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s101 D1BodySized.S101 =
      some (D1BodySized.s102, D1BodySized.S102) := congrFun D1BodySized.checked101 bs

end Host.Load.Run.Tpl
end
