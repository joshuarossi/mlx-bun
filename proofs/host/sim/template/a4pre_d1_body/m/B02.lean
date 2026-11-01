import host.sim.template.a4pre_d1_body.TraceStep
import host.sim.template.a4pre_d1_body.m.B00
import host.sim.Chunk
import host.sim.template.a4pre_d1_body.m.B01
import host.sim.template.a4pre_d1_body.SizeLift

section -- SN102
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel102 : nth? D1BodySized.ks 102 = some 2570
kernel_rfl D1BodySized.checked102 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s102 D1BodySized.S102) =
    fun _ => some (D1BodySized.s103, D1BodySized.S103)

theorem D1BodySized.k102 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s102 D1BodySized.S102 =
      some (D1BodySized.s103, D1BodySized.S103) := congrFun D1BodySized.checked102 bs

end Host.Load.Run.Tpl
end

section -- SB29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment29 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s101 D1BodySized.S101 =
      some (D1BodySized.s103, D1BodySized.S103) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s101 D1BodySized.s102 D1BodySized.s103 D1BodySized.S101 D1BodySized.S102 D1BodySized.S103 (D1BodySized.k101 bs) (D1BodySized.k102 bs)

kernel_rfl D1BodySized.accepted29 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s101 D1BodySized.S101) = fun _ => true
kernel_rfl D1BodySized.oracle29 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S101.oracle = true
kernel_rfl D1BodySized.fuelA30 : nth? D1BodySized.ks 103 = some 1
kernel_rfl D1BodySized.fuelB30 : nth? D1BodySized.ks 104 = some 3
kernel_rfl D1BodySized.stepA30 : interpS (step D1BodySized.F D1BodySized.s103).run D1BodySized.S103 =
  some (D1BodySized.s104, D1BodySized.S104)
kernel_rfl D1BodySized.patchB30 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s104).run D1BodySized.S104 =
  some (D1BodySized.s105, D1BodySized.S105)
kernel_rfl D1BodySized.acceptedP30 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s103 D1BodySized.S103) = fun _ => true
kernel_rfl D1BodySized.haltP30 : isHalt D1BodySized.s103.ctl = false
kernel_rfl D1BodySized.topA30 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s104 = true
kernel_rfl D1BodySized.inactive30 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s104.ffi).active = false
/-- Bridge 30's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys30 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s104 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs30 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s104 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA30 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s104 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys30, D1BodySized.sizeArgs30)
kernel_rfl D1BodySized.sizeArgsA30 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s104 = true
kernel_rfl D1BodySized.sizeSymA30 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA30 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA30 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA30 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec30 := interpS (decodeArgs D1BodySized.F D1BodySized.s104 D1BodySized.sizeTys30 D1BodySized.sizeArgs30).run D1BodySized.S104
noncomputable def D1BodySized.sizeAs30 : List Arg := match D1BodySized.sizeDec30 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS030 : SSrv := match D1BodySized.sizeDec30 with | some (_, S) => S | none => D1BodySized.S104
kernel_rfl D1BodySized.sizeDecA30 : interpS (decodeArgs D1BodySized.F D1BodySized.s104 D1BodySized.sizeTys30 D1BodySized.sizeArgs30).run D1BodySized.S104 =
  some (some D1BodySized.sizeAs30, D1BodySized.sizeS030)
kernel_rfl D1BodySized.sizePreA30 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS030 D1BodySized.s104.ffi D1BodySized.sizeAs30 = true

end Host.Load.Run.Tpl
end

section -- SN105
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel105 : nth? D1BodySized.ks 105 = some 2542
kernel_rfl D1BodySized.checked105 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s105 D1BodySized.S105) =
    fun _ => some (D1BodySized.s106, D1BodySized.S106)

theorem D1BodySized.k105 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s105 D1BodySized.S105 =
      some (D1BodySized.s106, D1BodySized.S106) := congrFun D1BodySized.checked105 bs

end Host.Load.Run.Tpl
end

section -- SB30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment30 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s105 D1BodySized.S105 =
      some (D1BodySized.s106, D1BodySized.S106) := D1BodySized.k105 bs

kernel_rfl D1BodySized.accepted30 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s105 D1BodySized.S105) = fun _ => true
kernel_rfl D1BodySized.oracle30 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S105.oracle = true
kernel_rfl D1BodySized.fuelA31 : nth? D1BodySized.ks 106 = some 1
kernel_rfl D1BodySized.fuelB31 : nth? D1BodySized.ks 107 = some 3
kernel_rfl D1BodySized.stepA31 : interpS (step D1BodySized.F D1BodySized.s106).run D1BodySized.S106 =
  some (D1BodySized.s107, D1BodySized.S107)
kernel_rfl D1BodySized.patchB31 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s107).run D1BodySized.S107 =
  some (D1BodySized.s108, D1BodySized.S108)
kernel_rfl D1BodySized.acceptedP31 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s106 D1BodySized.S106) = fun _ => true
kernel_rfl D1BodySized.haltP31 : isHalt D1BodySized.s106.ctl = false
kernel_rfl D1BodySized.topA31 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s107 = true
kernel_rfl D1BodySized.inactive31 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s107.ffi).active = false
/-- Bridge 31's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys31 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s107 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs31 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s107 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA31 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s107 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys31, D1BodySized.sizeArgs31)
kernel_rfl D1BodySized.sizeArgsA31 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s107 = true
kernel_rfl D1BodySized.sizeSymA31 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA31 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA31 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA31 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec31 := interpS (decodeArgs D1BodySized.F D1BodySized.s107 D1BodySized.sizeTys31 D1BodySized.sizeArgs31).run D1BodySized.S107
noncomputable def D1BodySized.sizeAs31 : List Arg := match D1BodySized.sizeDec31 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS031 : SSrv := match D1BodySized.sizeDec31 with | some (_, S) => S | none => D1BodySized.S107
kernel_rfl D1BodySized.sizeDecA31 : interpS (decodeArgs D1BodySized.F D1BodySized.s107 D1BodySized.sizeTys31 D1BodySized.sizeArgs31).run D1BodySized.S107 =
  some (some D1BodySized.sizeAs31, D1BodySized.sizeS031)
kernel_rfl D1BodySized.sizePreA31 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS031 D1BodySized.s107.ffi D1BodySized.sizeAs31 = true

end Host.Load.Run.Tpl
end

section -- SN108
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel108 : nth? D1BodySized.ks 108 = some 10000
kernel_rfl D1BodySized.checked108 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s108 D1BodySized.S108) =
    fun _ => some (D1BodySized.s109, D1BodySized.S109)

theorem D1BodySized.k108 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s108 D1BodySized.S108 =
      some (D1BodySized.s109, D1BodySized.S109) := congrFun D1BodySized.checked108 bs

end Host.Load.Run.Tpl
end

section -- SN109
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel109 : nth? D1BodySized.ks 109 = some 10000
kernel_rfl D1BodySized.checked109 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s109 D1BodySized.S109) =
    fun _ => some (D1BodySized.s110, D1BodySized.S110)

theorem D1BodySized.k109 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s109 D1BodySized.S109 =
      some (D1BodySized.s110, D1BodySized.S110) := congrFun D1BodySized.checked109 bs

end Host.Load.Run.Tpl
end

section -- SN110
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel110 : nth? D1BodySized.ks 110 = some 2287
kernel_rfl D1BodySized.checked110 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s110 D1BodySized.S110) =
    fun _ => some (D1BodySized.s111, D1BodySized.S111)

theorem D1BodySized.k110 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s110 D1BodySized.S110 =
      some (D1BodySized.s111, D1BodySized.S111) := congrFun D1BodySized.checked110 bs

end Host.Load.Run.Tpl
end

section -- SB31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment31 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22287 D1BodySized.s108 D1BodySized.S108 =
      some (D1BodySized.s111, D1BodySized.S111) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2287 D1BodySized.s108 D1BodySized.s110 D1BodySized.s111 D1BodySized.S108 D1BodySized.S110 D1BodySized.S111 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s108 D1BodySized.s109 D1BodySized.s110 D1BodySized.S108 D1BodySized.S109 D1BodySized.S110 (D1BodySized.k108 bs) (D1BodySized.k109 bs)) (D1BodySized.k110 bs)

kernel_rfl D1BodySized.accepted31 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s108 D1BodySized.S108) = fun _ => true
kernel_rfl D1BodySized.oracle31 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S108.oracle = true
kernel_rfl D1BodySized.fuelA32 : nth? D1BodySized.ks 111 = some 1
kernel_rfl D1BodySized.fuelB32 : nth? D1BodySized.ks 112 = some 3
kernel_rfl D1BodySized.stepA32 : interpS (step D1BodySized.F D1BodySized.s111).run D1BodySized.S111 =
  some (D1BodySized.s112, D1BodySized.S112)
kernel_rfl D1BodySized.patchB32 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s112).run D1BodySized.S112 =
  some (D1BodySized.s113, D1BodySized.S113)
kernel_rfl D1BodySized.acceptedP32 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s111 D1BodySized.S111) = fun _ => true
kernel_rfl D1BodySized.haltP32 : isHalt D1BodySized.s111.ctl = false
kernel_rfl D1BodySized.topA32 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s112 = true
kernel_rfl D1BodySized.inactive32 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s112.ffi).active = false
/-- Bridge 32's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys32 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s112 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs32 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s112 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA32 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s112 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys32, D1BodySized.sizeArgs32)
kernel_rfl D1BodySized.sizeArgsA32 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s112 = true
kernel_rfl D1BodySized.sizeSymA32 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA32 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA32 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA32 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec32 := interpS (decodeArgs D1BodySized.F D1BodySized.s112 D1BodySized.sizeTys32 D1BodySized.sizeArgs32).run D1BodySized.S112
noncomputable def D1BodySized.sizeAs32 : List Arg := match D1BodySized.sizeDec32 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS032 : SSrv := match D1BodySized.sizeDec32 with | some (_, S) => S | none => D1BodySized.S112
kernel_rfl D1BodySized.sizeDecA32 : interpS (decodeArgs D1BodySized.F D1BodySized.s112 D1BodySized.sizeTys32 D1BodySized.sizeArgs32).run D1BodySized.S112 =
  some (some D1BodySized.sizeAs32, D1BodySized.sizeS032)
kernel_rfl D1BodySized.sizePreA32 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS032 D1BodySized.s112.ffi D1BodySized.sizeAs32 = true

end Host.Load.Run.Tpl
end

section -- SN113
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel113 : nth? D1BodySized.ks 113 = some 7980
kernel_rfl D1BodySized.checked113 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7980 D1BodySized.s113 D1BodySized.S113) =
    fun _ => some (D1BodySized.s114, D1BodySized.S114)

theorem D1BodySized.k113 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7980 D1BodySized.s113 D1BodySized.S113 =
      some (D1BodySized.s114, D1BodySized.S114) := congrFun D1BodySized.checked113 bs

end Host.Load.Run.Tpl
end

section -- SB32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment32 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7980 D1BodySized.s113 D1BodySized.S113 =
      some (D1BodySized.s114, D1BodySized.S114) := D1BodySized.k113 bs

kernel_rfl D1BodySized.accepted32 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s113 D1BodySized.S113) = fun _ => true
kernel_rfl D1BodySized.oracle32 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S113.oracle = true
kernel_rfl D1BodySized.fuelA33 : nth? D1BodySized.ks 114 = some 1
kernel_rfl D1BodySized.fuelB33 : nth? D1BodySized.ks 115 = some 3
kernel_rfl D1BodySized.stepA33 : interpS (step D1BodySized.F D1BodySized.s114).run D1BodySized.S114 =
  some (D1BodySized.s115, D1BodySized.S115)
kernel_rfl D1BodySized.patchB33 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s115).run D1BodySized.S115 =
  some (D1BodySized.s116, D1BodySized.S116)
kernel_rfl D1BodySized.acceptedP33 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s114 D1BodySized.S114) = fun _ => true
kernel_rfl D1BodySized.haltP33 : isHalt D1BodySized.s114.ctl = false
kernel_rfl D1BodySized.topA33 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s115 = true
kernel_rfl D1BodySized.inactive33 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s115.ffi).active = false
/-- Bridge 33's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys33 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s115 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs33 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s115 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA33 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s115 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys33, D1BodySized.sizeArgs33)
kernel_rfl D1BodySized.sizeArgsA33 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s115 = true
kernel_rfl D1BodySized.sizeSymA33 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA33 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA33 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA33 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec33 := interpS (decodeArgs D1BodySized.F D1BodySized.s115 D1BodySized.sizeTys33 D1BodySized.sizeArgs33).run D1BodySized.S115
noncomputable def D1BodySized.sizeAs33 : List Arg := match D1BodySized.sizeDec33 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS033 : SSrv := match D1BodySized.sizeDec33 with | some (_, S) => S | none => D1BodySized.S115
kernel_rfl D1BodySized.sizeDecA33 : interpS (decodeArgs D1BodySized.F D1BodySized.s115 D1BodySized.sizeTys33 D1BodySized.sizeArgs33).run D1BodySized.S115 =
  some (some D1BodySized.sizeAs33, D1BodySized.sizeS033)
kernel_rfl D1BodySized.sizePreA33 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS033 D1BodySized.s115.ffi D1BodySized.sizeAs33 = true

end Host.Load.Run.Tpl
end

section -- SN116
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel116 : nth? D1BodySized.ks 116 = some 1936
kernel_rfl D1BodySized.checked116 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s116 D1BodySized.S116) =
    fun _ => some (D1BodySized.s117, D1BodySized.S117)

theorem D1BodySized.k116 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s116 D1BodySized.S116 =
      some (D1BodySized.s117, D1BodySized.S117) := congrFun D1BodySized.checked116 bs

end Host.Load.Run.Tpl
end

section -- SB33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment33 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s116 D1BodySized.S116 =
      some (D1BodySized.s117, D1BodySized.S117) := D1BodySized.k116 bs

kernel_rfl D1BodySized.accepted33 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s116 D1BodySized.S116) = fun _ => true
kernel_rfl D1BodySized.oracle33 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S116.oracle = true
kernel_rfl D1BodySized.fuelA34 : nth? D1BodySized.ks 117 = some 1
kernel_rfl D1BodySized.fuelB34 : nth? D1BodySized.ks 118 = some 3
kernel_rfl D1BodySized.stepA34 : interpS (step D1BodySized.F D1BodySized.s117).run D1BodySized.S117 =
  some (D1BodySized.s118, D1BodySized.S118)
kernel_rfl D1BodySized.patchB34 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s118).run D1BodySized.S118 =
  some (D1BodySized.s119, D1BodySized.S119)
kernel_rfl D1BodySized.acceptedP34 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s117 D1BodySized.S117) = fun _ => true
kernel_rfl D1BodySized.haltP34 : isHalt D1BodySized.s117.ctl = false
kernel_rfl D1BodySized.topA34 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s118 = true
kernel_rfl D1BodySized.inactive34 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s118.ffi).active = false
/-- Bridge 34's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys34 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s118 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs34 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s118 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA34 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s118 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys34, D1BodySized.sizeArgs34)
kernel_rfl D1BodySized.sizeArgsA34 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s118 = true
kernel_rfl D1BodySized.sizeSymA34 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA34 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA34 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA34 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec34 := interpS (decodeArgs D1BodySized.F D1BodySized.s118 D1BodySized.sizeTys34 D1BodySized.sizeArgs34).run D1BodySized.S118
noncomputable def D1BodySized.sizeAs34 : List Arg := match D1BodySized.sizeDec34 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS034 : SSrv := match D1BodySized.sizeDec34 with | some (_, S) => S | none => D1BodySized.S118
kernel_rfl D1BodySized.sizeDecA34 : interpS (decodeArgs D1BodySized.F D1BodySized.s118 D1BodySized.sizeTys34 D1BodySized.sizeArgs34).run D1BodySized.S118 =
  some (some D1BodySized.sizeAs34, D1BodySized.sizeS034)
kernel_rfl D1BodySized.sizePreA34 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS034 D1BodySized.s118.ffi D1BodySized.sizeAs34 = true

end Host.Load.Run.Tpl
end

section -- SN119
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel119 : nth? D1BodySized.ks 119 = some 10000
kernel_rfl D1BodySized.checked119 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s119 D1BodySized.S119) =
    fun _ => some (D1BodySized.s120, D1BodySized.S120)

theorem D1BodySized.k119 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s119 D1BodySized.S119 =
      some (D1BodySized.s120, D1BodySized.S120) := congrFun D1BodySized.checked119 bs

end Host.Load.Run.Tpl
end

section -- SN120
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel120 : nth? D1BodySized.ks 120 = some 2570
kernel_rfl D1BodySized.checked120 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s120 D1BodySized.S120) =
    fun _ => some (D1BodySized.s121, D1BodySized.S121)

theorem D1BodySized.k120 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s120 D1BodySized.S120 =
      some (D1BodySized.s121, D1BodySized.S121) := congrFun D1BodySized.checked120 bs

end Host.Load.Run.Tpl
end

section -- SB34
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment34 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s119 D1BodySized.S119 =
      some (D1BodySized.s121, D1BodySized.S121) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s119 D1BodySized.s120 D1BodySized.s121 D1BodySized.S119 D1BodySized.S120 D1BodySized.S121 (D1BodySized.k119 bs) (D1BodySized.k120 bs)

kernel_rfl D1BodySized.accepted34 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s119 D1BodySized.S119) = fun _ => true
kernel_rfl D1BodySized.oracle34 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S119.oracle = true
kernel_rfl D1BodySized.fuelA35 : nth? D1BodySized.ks 121 = some 1
kernel_rfl D1BodySized.fuelB35 : nth? D1BodySized.ks 122 = some 3
kernel_rfl D1BodySized.stepA35 : interpS (step D1BodySized.F D1BodySized.s121).run D1BodySized.S121 =
  some (D1BodySized.s122, D1BodySized.S122)
kernel_rfl D1BodySized.patchB35 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s122).run D1BodySized.S122 =
  some (D1BodySized.s123, D1BodySized.S123)
kernel_rfl D1BodySized.acceptedP35 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s121 D1BodySized.S121) = fun _ => true
kernel_rfl D1BodySized.haltP35 : isHalt D1BodySized.s121.ctl = false
kernel_rfl D1BodySized.topA35 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s122 = true
kernel_rfl D1BodySized.inactive35 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s122.ffi).active = false
/-- Bridge 35's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys35 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s122 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs35 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s122 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA35 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s122 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys35, D1BodySized.sizeArgs35)
kernel_rfl D1BodySized.sizeArgsA35 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s122 = true
kernel_rfl D1BodySized.sizeSymA35 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA35 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA35 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA35 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec35 := interpS (decodeArgs D1BodySized.F D1BodySized.s122 D1BodySized.sizeTys35 D1BodySized.sizeArgs35).run D1BodySized.S122
noncomputable def D1BodySized.sizeAs35 : List Arg := match D1BodySized.sizeDec35 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS035 : SSrv := match D1BodySized.sizeDec35 with | some (_, S) => S | none => D1BodySized.S122
kernel_rfl D1BodySized.sizeDecA35 : interpS (decodeArgs D1BodySized.F D1BodySized.s122 D1BodySized.sizeTys35 D1BodySized.sizeArgs35).run D1BodySized.S122 =
  some (some D1BodySized.sizeAs35, D1BodySized.sizeS035)
kernel_rfl D1BodySized.sizePreA35 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS035 D1BodySized.s122.ffi D1BodySized.sizeAs35 = true

end Host.Load.Run.Tpl
end

section -- SN123
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel123 : nth? D1BodySized.ks 123 = some 2542
kernel_rfl D1BodySized.checked123 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s123 D1BodySized.S123) =
    fun _ => some (D1BodySized.s124, D1BodySized.S124)

theorem D1BodySized.k123 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s123 D1BodySized.S123 =
      some (D1BodySized.s124, D1BodySized.S124) := congrFun D1BodySized.checked123 bs

end Host.Load.Run.Tpl
end

section -- SB35
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment35 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s123 D1BodySized.S123 =
      some (D1BodySized.s124, D1BodySized.S124) := D1BodySized.k123 bs

kernel_rfl D1BodySized.accepted35 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s123 D1BodySized.S123) = fun _ => true
kernel_rfl D1BodySized.oracle35 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S123.oracle = true
kernel_rfl D1BodySized.fuelA36 : nth? D1BodySized.ks 124 = some 1
kernel_rfl D1BodySized.fuelB36 : nth? D1BodySized.ks 125 = some 3
kernel_rfl D1BodySized.stepA36 : interpS (step D1BodySized.F D1BodySized.s124).run D1BodySized.S124 =
  some (D1BodySized.s125, D1BodySized.S125)
kernel_rfl D1BodySized.patchB36 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s125).run D1BodySized.S125 =
  some (D1BodySized.s126, D1BodySized.S126)
kernel_rfl D1BodySized.acceptedP36 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s124 D1BodySized.S124) = fun _ => true
kernel_rfl D1BodySized.haltP36 : isHalt D1BodySized.s124.ctl = false
kernel_rfl D1BodySized.topA36 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s125 = true
kernel_rfl D1BodySized.inactive36 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s125.ffi).active = false
/-- Bridge 36's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys36 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s125 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs36 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s125 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA36 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s125 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys36, D1BodySized.sizeArgs36)
kernel_rfl D1BodySized.sizeArgsA36 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s125 = true
kernel_rfl D1BodySized.sizeSymA36 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA36 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA36 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA36 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec36 := interpS (decodeArgs D1BodySized.F D1BodySized.s125 D1BodySized.sizeTys36 D1BodySized.sizeArgs36).run D1BodySized.S125
noncomputable def D1BodySized.sizeAs36 : List Arg := match D1BodySized.sizeDec36 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS036 : SSrv := match D1BodySized.sizeDec36 with | some (_, S) => S | none => D1BodySized.S125
kernel_rfl D1BodySized.sizeDecA36 : interpS (decodeArgs D1BodySized.F D1BodySized.s125 D1BodySized.sizeTys36 D1BodySized.sizeArgs36).run D1BodySized.S125 =
  some (some D1BodySized.sizeAs36, D1BodySized.sizeS036)
kernel_rfl D1BodySized.sizePreA36 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS036 D1BodySized.s125.ffi D1BodySized.sizeAs36 = true

end Host.Load.Run.Tpl
end

section -- SN126
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel126 : nth? D1BodySized.ks 126 = some 7716
kernel_rfl D1BodySized.checked126 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s126 D1BodySized.S126) =
    fun _ => some (D1BodySized.s127, D1BodySized.S127)

theorem D1BodySized.k126 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s126 D1BodySized.S126 =
      some (D1BodySized.s127, D1BodySized.S127) := congrFun D1BodySized.checked126 bs

end Host.Load.Run.Tpl
end

section -- SB36
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment36 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s126 D1BodySized.S126 =
      some (D1BodySized.s127, D1BodySized.S127) := D1BodySized.k126 bs

kernel_rfl D1BodySized.accepted36 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s126 D1BodySized.S126) = fun _ => true
kernel_rfl D1BodySized.oracle36 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S126.oracle = true
kernel_rfl D1BodySized.fuelA37 : nth? D1BodySized.ks 127 = some 1
kernel_rfl D1BodySized.fuelB37 : nth? D1BodySized.ks 128 = some 3
kernel_rfl D1BodySized.stepA37 : interpS (step D1BodySized.F D1BodySized.s127).run D1BodySized.S127 =
  some (D1BodySized.s128, D1BodySized.S128)
kernel_rfl D1BodySized.patchB37 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s128).run D1BodySized.S128 =
  some (D1BodySized.s129, D1BodySized.S129)
kernel_rfl D1BodySized.acceptedP37 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s127 D1BodySized.S127) = fun _ => true
kernel_rfl D1BodySized.haltP37 : isHalt D1BodySized.s127.ctl = false
kernel_rfl D1BodySized.topA37 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s128 = true
kernel_rfl D1BodySized.inactive37 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s128.ffi).active = false
/-- Bridge 37's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys37 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s128 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs37 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s128 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA37 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s128 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys37, D1BodySized.sizeArgs37)
kernel_rfl D1BodySized.sizeArgsA37 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s128 = true
kernel_rfl D1BodySized.sizeSymA37 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA37 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA37 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA37 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec37 := interpS (decodeArgs D1BodySized.F D1BodySized.s128 D1BodySized.sizeTys37 D1BodySized.sizeArgs37).run D1BodySized.S128
noncomputable def D1BodySized.sizeAs37 : List Arg := match D1BodySized.sizeDec37 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS037 : SSrv := match D1BodySized.sizeDec37 with | some (_, S) => S | none => D1BodySized.S128
kernel_rfl D1BodySized.sizeDecA37 : interpS (decodeArgs D1BodySized.F D1BodySized.s128 D1BodySized.sizeTys37 D1BodySized.sizeArgs37).run D1BodySized.S128 =
  some (some D1BodySized.sizeAs37, D1BodySized.sizeS037)
kernel_rfl D1BodySized.sizePreA37 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS037 D1BodySized.s128.ffi D1BodySized.sizeAs37 = true

end Host.Load.Run.Tpl
end

section -- SN129
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel129 : nth? D1BodySized.ks 129 = some 1936
kernel_rfl D1BodySized.checked129 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s129 D1BodySized.S129) =
    fun _ => some (D1BodySized.s130, D1BodySized.S130)

theorem D1BodySized.k129 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s129 D1BodySized.S129 =
      some (D1BodySized.s130, D1BodySized.S130) := congrFun D1BodySized.checked129 bs

end Host.Load.Run.Tpl
end

section -- SB37
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment37 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s129 D1BodySized.S129 =
      some (D1BodySized.s130, D1BodySized.S130) := D1BodySized.k129 bs

kernel_rfl D1BodySized.accepted37 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s129 D1BodySized.S129) = fun _ => true
kernel_rfl D1BodySized.oracle37 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S129.oracle = true
kernel_rfl D1BodySized.fuelA38 : nth? D1BodySized.ks 130 = some 1
kernel_rfl D1BodySized.fuelB38 : nth? D1BodySized.ks 131 = some 3
kernel_rfl D1BodySized.stepA38 : interpS (step D1BodySized.F D1BodySized.s130).run D1BodySized.S130 =
  some (D1BodySized.s131, D1BodySized.S131)
kernel_rfl D1BodySized.patchB38 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s131).run D1BodySized.S131 =
  some (D1BodySized.s132, D1BodySized.S132)
kernel_rfl D1BodySized.acceptedP38 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s130 D1BodySized.S130) = fun _ => true
kernel_rfl D1BodySized.haltP38 : isHalt D1BodySized.s130.ctl = false
kernel_rfl D1BodySized.topA38 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s131 = true
kernel_rfl D1BodySized.inactive38 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s131.ffi).active = false
/-- Bridge 38's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys38 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s131 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs38 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s131 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA38 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s131 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys38, D1BodySized.sizeArgs38)
kernel_rfl D1BodySized.sizeArgsA38 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s131 = true
kernel_rfl D1BodySized.sizeSymA38 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA38 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA38 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA38 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec38 := interpS (decodeArgs D1BodySized.F D1BodySized.s131 D1BodySized.sizeTys38 D1BodySized.sizeArgs38).run D1BodySized.S131
noncomputable def D1BodySized.sizeAs38 : List Arg := match D1BodySized.sizeDec38 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS038 : SSrv := match D1BodySized.sizeDec38 with | some (_, S) => S | none => D1BodySized.S131
kernel_rfl D1BodySized.sizeDecA38 : interpS (decodeArgs D1BodySized.F D1BodySized.s131 D1BodySized.sizeTys38 D1BodySized.sizeArgs38).run D1BodySized.S131 =
  some (some D1BodySized.sizeAs38, D1BodySized.sizeS038)
kernel_rfl D1BodySized.sizePreA38 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS038 D1BodySized.s131.ffi D1BodySized.sizeAs38 = true

end Host.Load.Run.Tpl
end

section -- SN132
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel132 : nth? D1BodySized.ks 132 = some 10000
kernel_rfl D1BodySized.checked132 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s132 D1BodySized.S132) =
    fun _ => some (D1BodySized.s133, D1BodySized.S133)

theorem D1BodySized.k132 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s132 D1BodySized.S132 =
      some (D1BodySized.s133, D1BodySized.S133) := congrFun D1BodySized.checked132 bs

end Host.Load.Run.Tpl
end

section -- SN133
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel133 : nth? D1BodySized.ks 133 = some 2570
kernel_rfl D1BodySized.checked133 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s133 D1BodySized.S133) =
    fun _ => some (D1BodySized.s134, D1BodySized.S134)

theorem D1BodySized.k133 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s133 D1BodySized.S133 =
      some (D1BodySized.s134, D1BodySized.S134) := congrFun D1BodySized.checked133 bs

end Host.Load.Run.Tpl
end

section -- SB38
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment38 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s132 D1BodySized.S132 =
      some (D1BodySized.s134, D1BodySized.S134) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s132 D1BodySized.s133 D1BodySized.s134 D1BodySized.S132 D1BodySized.S133 D1BodySized.S134 (D1BodySized.k132 bs) (D1BodySized.k133 bs)

kernel_rfl D1BodySized.accepted38 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s132 D1BodySized.S132) = fun _ => true
kernel_rfl D1BodySized.oracle38 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S132.oracle = true
kernel_rfl D1BodySized.fuelA39 : nth? D1BodySized.ks 134 = some 1
kernel_rfl D1BodySized.fuelB39 : nth? D1BodySized.ks 135 = some 3
kernel_rfl D1BodySized.stepA39 : interpS (step D1BodySized.F D1BodySized.s134).run D1BodySized.S134 =
  some (D1BodySized.s135, D1BodySized.S135)
kernel_rfl D1BodySized.patchB39 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s135).run D1BodySized.S135 =
  some (D1BodySized.s136, D1BodySized.S136)
kernel_rfl D1BodySized.acceptedP39 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s134 D1BodySized.S134) = fun _ => true
kernel_rfl D1BodySized.haltP39 : isHalt D1BodySized.s134.ctl = false
kernel_rfl D1BodySized.topA39 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s135 = true
kernel_rfl D1BodySized.inactive39 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s135.ffi).active = false
/-- Bridge 39's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys39 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s135 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs39 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s135 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA39 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s135 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys39, D1BodySized.sizeArgs39)
kernel_rfl D1BodySized.sizeArgsA39 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s135 = true
kernel_rfl D1BodySized.sizeSymA39 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA39 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA39 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA39 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec39 := interpS (decodeArgs D1BodySized.F D1BodySized.s135 D1BodySized.sizeTys39 D1BodySized.sizeArgs39).run D1BodySized.S135
noncomputable def D1BodySized.sizeAs39 : List Arg := match D1BodySized.sizeDec39 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS039 : SSrv := match D1BodySized.sizeDec39 with | some (_, S) => S | none => D1BodySized.S135
kernel_rfl D1BodySized.sizeDecA39 : interpS (decodeArgs D1BodySized.F D1BodySized.s135 D1BodySized.sizeTys39 D1BodySized.sizeArgs39).run D1BodySized.S135 =
  some (some D1BodySized.sizeAs39, D1BodySized.sizeS039)
kernel_rfl D1BodySized.sizePreA39 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS039 D1BodySized.s135.ffi D1BodySized.sizeAs39 = true

end Host.Load.Run.Tpl
end

section -- SN136
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel136 : nth? D1BodySized.ks 136 = some 2542
kernel_rfl D1BodySized.checked136 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s136 D1BodySized.S136) =
    fun _ => some (D1BodySized.s137, D1BodySized.S137)

theorem D1BodySized.k136 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s136 D1BodySized.S136 =
      some (D1BodySized.s137, D1BodySized.S137) := congrFun D1BodySized.checked136 bs

end Host.Load.Run.Tpl
end

section -- SB39
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment39 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s136 D1BodySized.S136 =
      some (D1BodySized.s137, D1BodySized.S137) := D1BodySized.k136 bs

kernel_rfl D1BodySized.accepted39 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s136 D1BodySized.S136) = fun _ => true
kernel_rfl D1BodySized.oracle39 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S136.oracle = true
kernel_rfl D1BodySized.fuelA40 : nth? D1BodySized.ks 137 = some 1
kernel_rfl D1BodySized.fuelB40 : nth? D1BodySized.ks 138 = some 3
kernel_rfl D1BodySized.stepA40 : interpS (step D1BodySized.F D1BodySized.s137).run D1BodySized.S137 =
  some (D1BodySized.s138, D1BodySized.S138)
kernel_rfl D1BodySized.patchB40 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s138).run D1BodySized.S138 =
  some (D1BodySized.s139, D1BodySized.S139)
kernel_rfl D1BodySized.acceptedP40 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s137 D1BodySized.S137) = fun _ => true
kernel_rfl D1BodySized.haltP40 : isHalt D1BodySized.s137.ctl = false
kernel_rfl D1BodySized.topA40 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s138 = true
kernel_rfl D1BodySized.inactive40 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s138.ffi).active = false
/-- Bridge 40's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys40 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s138 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs40 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s138 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA40 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s138 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys40, D1BodySized.sizeArgs40)
kernel_rfl D1BodySized.sizeArgsA40 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s138 = true
kernel_rfl D1BodySized.sizeSymA40 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA40 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA40 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA40 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec40 := interpS (decodeArgs D1BodySized.F D1BodySized.s138 D1BodySized.sizeTys40 D1BodySized.sizeArgs40).run D1BodySized.S138
noncomputable def D1BodySized.sizeAs40 : List Arg := match D1BodySized.sizeDec40 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS040 : SSrv := match D1BodySized.sizeDec40 with | some (_, S) => S | none => D1BodySized.S138
kernel_rfl D1BodySized.sizeDecA40 : interpS (decodeArgs D1BodySized.F D1BodySized.s138 D1BodySized.sizeTys40 D1BodySized.sizeArgs40).run D1BodySized.S138 =
  some (some D1BodySized.sizeAs40, D1BodySized.sizeS040)
kernel_rfl D1BodySized.sizePreA40 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS040 D1BodySized.s138.ffi D1BodySized.sizeAs40 = true

end Host.Load.Run.Tpl
end

section -- SN139
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel139 : nth? D1BodySized.ks 139 = some 7762
kernel_rfl D1BodySized.checked139 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s139 D1BodySized.S139) =
    fun _ => some (D1BodySized.s140, D1BodySized.S140)

theorem D1BodySized.k139 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s139 D1BodySized.S139 =
      some (D1BodySized.s140, D1BodySized.S140) := congrFun D1BodySized.checked139 bs

end Host.Load.Run.Tpl
end

section -- SB40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment40 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s139 D1BodySized.S139 =
      some (D1BodySized.s140, D1BodySized.S140) := D1BodySized.k139 bs

kernel_rfl D1BodySized.accepted40 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s139 D1BodySized.S139) = fun _ => true
kernel_rfl D1BodySized.oracle40 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S139.oracle = true
kernel_rfl D1BodySized.fuelA41 : nth? D1BodySized.ks 140 = some 1
kernel_rfl D1BodySized.fuelB41 : nth? D1BodySized.ks 141 = some 3
kernel_rfl D1BodySized.stepA41 : interpS (step D1BodySized.F D1BodySized.s140).run D1BodySized.S140 =
  some (D1BodySized.s141, D1BodySized.S141)
kernel_rfl D1BodySized.patchB41 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s141).run D1BodySized.S141 =
  some (D1BodySized.s142, D1BodySized.S142)
kernel_rfl D1BodySized.acceptedP41 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s140 D1BodySized.S140) = fun _ => true
kernel_rfl D1BodySized.haltP41 : isHalt D1BodySized.s140.ctl = false
kernel_rfl D1BodySized.topA41 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s141 = true
kernel_rfl D1BodySized.inactive41 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s141.ffi).active = false
/-- Bridge 41's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys41 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s141 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs41 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s141 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA41 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s141 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys41, D1BodySized.sizeArgs41)
kernel_rfl D1BodySized.sizeArgsA41 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s141 = true
kernel_rfl D1BodySized.sizeSymA41 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA41 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA41 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA41 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec41 := interpS (decodeArgs D1BodySized.F D1BodySized.s141 D1BodySized.sizeTys41 D1BodySized.sizeArgs41).run D1BodySized.S141
noncomputable def D1BodySized.sizeAs41 : List Arg := match D1BodySized.sizeDec41 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS041 : SSrv := match D1BodySized.sizeDec41 with | some (_, S) => S | none => D1BodySized.S141
kernel_rfl D1BodySized.sizeDecA41 : interpS (decodeArgs D1BodySized.F D1BodySized.s141 D1BodySized.sizeTys41 D1BodySized.sizeArgs41).run D1BodySized.S141 =
  some (some D1BodySized.sizeAs41, D1BodySized.sizeS041)
kernel_rfl D1BodySized.sizePreA41 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS041 D1BodySized.s141.ffi D1BodySized.sizeAs41 = true

end Host.Load.Run.Tpl
end

section -- SN142
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel142 : nth? D1BodySized.ks 142 = some 1936
kernel_rfl D1BodySized.checked142 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s142 D1BodySized.S142) =
    fun _ => some (D1BodySized.s143, D1BodySized.S143)

theorem D1BodySized.k142 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s142 D1BodySized.S142 =
      some (D1BodySized.s143, D1BodySized.S143) := congrFun D1BodySized.checked142 bs

end Host.Load.Run.Tpl
end

section -- SB41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment41 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s142 D1BodySized.S142 =
      some (D1BodySized.s143, D1BodySized.S143) := D1BodySized.k142 bs

kernel_rfl D1BodySized.accepted41 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s142 D1BodySized.S142) = fun _ => true
kernel_rfl D1BodySized.oracle41 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S142.oracle = true
kernel_rfl D1BodySized.fuelA42 : nth? D1BodySized.ks 143 = some 1
kernel_rfl D1BodySized.fuelB42 : nth? D1BodySized.ks 144 = some 3
kernel_rfl D1BodySized.stepA42 : interpS (step D1BodySized.F D1BodySized.s143).run D1BodySized.S143 =
  some (D1BodySized.s144, D1BodySized.S144)
kernel_rfl D1BodySized.patchB42 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s144).run D1BodySized.S144 =
  some (D1BodySized.s145, D1BodySized.S145)
kernel_rfl D1BodySized.acceptedP42 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s143 D1BodySized.S143) = fun _ => true
kernel_rfl D1BodySized.haltP42 : isHalt D1BodySized.s143.ctl = false
kernel_rfl D1BodySized.topA42 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s144 = true
kernel_rfl D1BodySized.inactive42 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s144.ffi).active = false
/-- Bridge 42's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys42 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s144 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs42 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s144 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA42 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s144 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys42, D1BodySized.sizeArgs42)
kernel_rfl D1BodySized.sizeArgsA42 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s144 = true
kernel_rfl D1BodySized.sizeSymA42 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA42 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA42 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA42 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec42 := interpS (decodeArgs D1BodySized.F D1BodySized.s144 D1BodySized.sizeTys42 D1BodySized.sizeArgs42).run D1BodySized.S144
noncomputable def D1BodySized.sizeAs42 : List Arg := match D1BodySized.sizeDec42 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS042 : SSrv := match D1BodySized.sizeDec42 with | some (_, S) => S | none => D1BodySized.S144
kernel_rfl D1BodySized.sizeDecA42 : interpS (decodeArgs D1BodySized.F D1BodySized.s144 D1BodySized.sizeTys42 D1BodySized.sizeArgs42).run D1BodySized.S144 =
  some (some D1BodySized.sizeAs42, D1BodySized.sizeS042)
kernel_rfl D1BodySized.sizePreA42 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS042 D1BodySized.s144.ffi D1BodySized.sizeAs42 = true

end Host.Load.Run.Tpl
end

section -- SN145
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel145 : nth? D1BodySized.ks 145 = some 10000
kernel_rfl D1BodySized.checked145 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s145 D1BodySized.S145) =
    fun _ => some (D1BodySized.s146, D1BodySized.S146)

theorem D1BodySized.k145 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s145 D1BodySized.S145 =
      some (D1BodySized.s146, D1BodySized.S146) := congrFun D1BodySized.checked145 bs

end Host.Load.Run.Tpl
end

section -- SN146
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel146 : nth? D1BodySized.ks 146 = some 2570
kernel_rfl D1BodySized.checked146 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s146 D1BodySized.S146) =
    fun _ => some (D1BodySized.s147, D1BodySized.S147)

theorem D1BodySized.k146 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s146 D1BodySized.S146 =
      some (D1BodySized.s147, D1BodySized.S147) := congrFun D1BodySized.checked146 bs

end Host.Load.Run.Tpl
end

section -- SB42
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment42 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s145 D1BodySized.S145 =
      some (D1BodySized.s147, D1BodySized.S147) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s145 D1BodySized.s146 D1BodySized.s147 D1BodySized.S145 D1BodySized.S146 D1BodySized.S147 (D1BodySized.k145 bs) (D1BodySized.k146 bs)

kernel_rfl D1BodySized.accepted42 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s145 D1BodySized.S145) = fun _ => true
kernel_rfl D1BodySized.oracle42 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S145.oracle = true
kernel_rfl D1BodySized.fuelA43 : nth? D1BodySized.ks 147 = some 1
kernel_rfl D1BodySized.fuelB43 : nth? D1BodySized.ks 148 = some 3
kernel_rfl D1BodySized.stepA43 : interpS (step D1BodySized.F D1BodySized.s147).run D1BodySized.S147 =
  some (D1BodySized.s148, D1BodySized.S148)
kernel_rfl D1BodySized.patchB43 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s148).run D1BodySized.S148 =
  some (D1BodySized.s149, D1BodySized.S149)
kernel_rfl D1BodySized.acceptedP43 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s147 D1BodySized.S147) = fun _ => true
kernel_rfl D1BodySized.haltP43 : isHalt D1BodySized.s147.ctl = false
kernel_rfl D1BodySized.topA43 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s148 = true
kernel_rfl D1BodySized.inactive43 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s148.ffi).active = false
/-- Bridge 43's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys43 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s148 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs43 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s148 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA43 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s148 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys43, D1BodySized.sizeArgs43)
kernel_rfl D1BodySized.sizeArgsA43 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s148 = true
kernel_rfl D1BodySized.sizeSymA43 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA43 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA43 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA43 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec43 := interpS (decodeArgs D1BodySized.F D1BodySized.s148 D1BodySized.sizeTys43 D1BodySized.sizeArgs43).run D1BodySized.S148
noncomputable def D1BodySized.sizeAs43 : List Arg := match D1BodySized.sizeDec43 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS043 : SSrv := match D1BodySized.sizeDec43 with | some (_, S) => S | none => D1BodySized.S148
kernel_rfl D1BodySized.sizeDecA43 : interpS (decodeArgs D1BodySized.F D1BodySized.s148 D1BodySized.sizeTys43 D1BodySized.sizeArgs43).run D1BodySized.S148 =
  some (some D1BodySized.sizeAs43, D1BodySized.sizeS043)
kernel_rfl D1BodySized.sizePreA43 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS043 D1BodySized.s148.ffi D1BodySized.sizeAs43 = true

end Host.Load.Run.Tpl
end

section -- SN149
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel149 : nth? D1BodySized.ks 149 = some 2542
kernel_rfl D1BodySized.checked149 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s149 D1BodySized.S149) =
    fun _ => some (D1BodySized.s150, D1BodySized.S150)

theorem D1BodySized.k149 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s149 D1BodySized.S149 =
      some (D1BodySized.s150, D1BodySized.S150) := congrFun D1BodySized.checked149 bs

end Host.Load.Run.Tpl
end

section -- SB43
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment43 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s149 D1BodySized.S149 =
      some (D1BodySized.s150, D1BodySized.S150) := D1BodySized.k149 bs

kernel_rfl D1BodySized.accepted43 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s149 D1BodySized.S149) = fun _ => true
kernel_rfl D1BodySized.oracle43 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S149.oracle = true
kernel_rfl D1BodySized.fuelA44 : nth? D1BodySized.ks 150 = some 1
kernel_rfl D1BodySized.fuelB44 : nth? D1BodySized.ks 151 = some 3
kernel_rfl D1BodySized.stepA44 : interpS (step D1BodySized.F D1BodySized.s150).run D1BodySized.S150 =
  some (D1BodySized.s151, D1BodySized.S151)
kernel_rfl D1BodySized.patchB44 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s151).run D1BodySized.S151 =
  some (D1BodySized.s152, D1BodySized.S152)
kernel_rfl D1BodySized.acceptedP44 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s150 D1BodySized.S150) = fun _ => true
kernel_rfl D1BodySized.haltP44 : isHalt D1BodySized.s150.ctl = false
kernel_rfl D1BodySized.topA44 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s151 = true
kernel_rfl D1BodySized.inactive44 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s151.ffi).active = false
/-- Bridge 44's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys44 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s151 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs44 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s151 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA44 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s151 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys44, D1BodySized.sizeArgs44)
kernel_rfl D1BodySized.sizeArgsA44 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s151 = true
kernel_rfl D1BodySized.sizeSymA44 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA44 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA44 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA44 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec44 := interpS (decodeArgs D1BodySized.F D1BodySized.s151 D1BodySized.sizeTys44 D1BodySized.sizeArgs44).run D1BodySized.S151
noncomputable def D1BodySized.sizeAs44 : List Arg := match D1BodySized.sizeDec44 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS044 : SSrv := match D1BodySized.sizeDec44 with | some (_, S) => S | none => D1BodySized.S151
kernel_rfl D1BodySized.sizeDecA44 : interpS (decodeArgs D1BodySized.F D1BodySized.s151 D1BodySized.sizeTys44 D1BodySized.sizeArgs44).run D1BodySized.S151 =
  some (some D1BodySized.sizeAs44, D1BodySized.sizeS044)
kernel_rfl D1BodySized.sizePreA44 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS044 D1BodySized.s151.ffi D1BodySized.sizeAs44 = true

end Host.Load.Run.Tpl
end

section -- SN152
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel152 : nth? D1BodySized.ks 152 = some 10000
kernel_rfl D1BodySized.checked152 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s152 D1BodySized.S152) =
    fun _ => some (D1BodySized.s153, D1BodySized.S153)

theorem D1BodySized.k152 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s152 D1BodySized.S152 =
      some (D1BodySized.s153, D1BodySized.S153) := congrFun D1BodySized.checked152 bs

end Host.Load.Run.Tpl
end

section -- SN153
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel153 : nth? D1BodySized.ks 153 = some 10000
kernel_rfl D1BodySized.checked153 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s153 D1BodySized.S153) =
    fun _ => some (D1BodySized.s154, D1BodySized.S154)

theorem D1BodySized.k153 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s153 D1BodySized.S153 =
      some (D1BodySized.s154, D1BodySized.S154) := congrFun D1BodySized.checked153 bs

end Host.Load.Run.Tpl
end

section -- SN154
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel154 : nth? D1BodySized.ks 154 = some 2287
kernel_rfl D1BodySized.checked154 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s154 D1BodySized.S154) =
    fun _ => some (D1BodySized.s155, D1BodySized.S155)

theorem D1BodySized.k154 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2287 D1BodySized.s154 D1BodySized.S154 =
      some (D1BodySized.s155, D1BodySized.S155) := congrFun D1BodySized.checked154 bs

end Host.Load.Run.Tpl
end

section -- SB44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment44 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22287 D1BodySized.s152 D1BodySized.S152 =
      some (D1BodySized.s155, D1BodySized.S155) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2287 D1BodySized.s152 D1BodySized.s154 D1BodySized.s155 D1BodySized.S152 D1BodySized.S154 D1BodySized.S155 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s152 D1BodySized.s153 D1BodySized.s154 D1BodySized.S152 D1BodySized.S153 D1BodySized.S154 (D1BodySized.k152 bs) (D1BodySized.k153 bs)) (D1BodySized.k154 bs)

kernel_rfl D1BodySized.accepted44 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s152 D1BodySized.S152) = fun _ => true
kernel_rfl D1BodySized.oracle44 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S152.oracle = true
kernel_rfl D1BodySized.fuelA45 : nth? D1BodySized.ks 155 = some 1
kernel_rfl D1BodySized.fuelB45 : nth? D1BodySized.ks 156 = some 3
kernel_rfl D1BodySized.stepA45 : interpS (step D1BodySized.F D1BodySized.s155).run D1BodySized.S155 =
  some (D1BodySized.s156, D1BodySized.S156)
kernel_rfl D1BodySized.patchB45 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s156).run D1BodySized.S156 =
  some (D1BodySized.s157, D1BodySized.S157)
kernel_rfl D1BodySized.acceptedP45 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s155 D1BodySized.S155) = fun _ => true
kernel_rfl D1BodySized.haltP45 : isHalt D1BodySized.s155.ctl = false
kernel_rfl D1BodySized.topA45 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s156 = true
kernel_rfl D1BodySized.inactive45 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s156.ffi).active = false
/-- Bridge 45's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys45 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s156 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs45 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s156 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA45 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s156 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys45, D1BodySized.sizeArgs45)
kernel_rfl D1BodySized.sizeArgsA45 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s156 = true
kernel_rfl D1BodySized.sizeSymA45 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA45 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA45 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA45 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec45 := interpS (decodeArgs D1BodySized.F D1BodySized.s156 D1BodySized.sizeTys45 D1BodySized.sizeArgs45).run D1BodySized.S156
noncomputable def D1BodySized.sizeAs45 : List Arg := match D1BodySized.sizeDec45 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS045 : SSrv := match D1BodySized.sizeDec45 with | some (_, S) => S | none => D1BodySized.S156
kernel_rfl D1BodySized.sizeDecA45 : interpS (decodeArgs D1BodySized.F D1BodySized.s156 D1BodySized.sizeTys45 D1BodySized.sizeArgs45).run D1BodySized.S156 =
  some (some D1BodySized.sizeAs45, D1BodySized.sizeS045)
kernel_rfl D1BodySized.sizePreA45 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS045 D1BodySized.s156.ffi D1BodySized.sizeAs45 = true

end Host.Load.Run.Tpl
end

section -- SN157
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel157 : nth? D1BodySized.ks 157 = some 7985
kernel_rfl D1BodySized.checked157 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7985 D1BodySized.s157 D1BodySized.S157) =
    fun _ => some (D1BodySized.s158, D1BodySized.S158)

theorem D1BodySized.k157 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7985 D1BodySized.s157 D1BodySized.S157 =
      some (D1BodySized.s158, D1BodySized.S158) := congrFun D1BodySized.checked157 bs

end Host.Load.Run.Tpl
end

section -- SB45
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment45 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7985 D1BodySized.s157 D1BodySized.S157 =
      some (D1BodySized.s158, D1BodySized.S158) := D1BodySized.k157 bs

kernel_rfl D1BodySized.accepted45 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s157 D1BodySized.S157) = fun _ => true
kernel_rfl D1BodySized.oracle45 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S157.oracle = true
kernel_rfl D1BodySized.fuelA46 : nth? D1BodySized.ks 158 = some 1
kernel_rfl D1BodySized.fuelB46 : nth? D1BodySized.ks 159 = some 3
kernel_rfl D1BodySized.stepA46 : interpS (step D1BodySized.F D1BodySized.s158).run D1BodySized.S158 =
  some (D1BodySized.s159, D1BodySized.S159)
kernel_rfl D1BodySized.patchB46 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s159).run D1BodySized.S159 =
  some (D1BodySized.s160, D1BodySized.S160)
kernel_rfl D1BodySized.acceptedP46 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s158 D1BodySized.S158) = fun _ => true
kernel_rfl D1BodySized.haltP46 : isHalt D1BodySized.s158.ctl = false
kernel_rfl D1BodySized.topA46 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s159 = true
kernel_rfl D1BodySized.inactive46 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s159.ffi).active = false
/-- Bridge 46's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys46 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s159 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs46 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s159 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA46 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s159 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys46, D1BodySized.sizeArgs46)
kernel_rfl D1BodySized.sizeArgsA46 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s159 = true
kernel_rfl D1BodySized.sizeSymA46 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA46 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA46 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA46 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec46 := interpS (decodeArgs D1BodySized.F D1BodySized.s159 D1BodySized.sizeTys46 D1BodySized.sizeArgs46).run D1BodySized.S159
noncomputable def D1BodySized.sizeAs46 : List Arg := match D1BodySized.sizeDec46 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS046 : SSrv := match D1BodySized.sizeDec46 with | some (_, S) => S | none => D1BodySized.S159
kernel_rfl D1BodySized.sizeDecA46 : interpS (decodeArgs D1BodySized.F D1BodySized.s159 D1BodySized.sizeTys46 D1BodySized.sizeArgs46).run D1BodySized.S159 =
  some (some D1BodySized.sizeAs46, D1BodySized.sizeS046)
kernel_rfl D1BodySized.sizePreA46 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS046 D1BodySized.s159.ffi D1BodySized.sizeAs46 = true

end Host.Load.Run.Tpl
end

section -- SN160
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel160 : nth? D1BodySized.ks 160 = some 1936
kernel_rfl D1BodySized.checked160 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s160 D1BodySized.S160) =
    fun _ => some (D1BodySized.s161, D1BodySized.S161)

theorem D1BodySized.k160 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s160 D1BodySized.S160 =
      some (D1BodySized.s161, D1BodySized.S161) := congrFun D1BodySized.checked160 bs

end Host.Load.Run.Tpl
end

section -- SB46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment46 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s160 D1BodySized.S160 =
      some (D1BodySized.s161, D1BodySized.S161) := D1BodySized.k160 bs

kernel_rfl D1BodySized.accepted46 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s160 D1BodySized.S160) = fun _ => true
kernel_rfl D1BodySized.oracle46 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S160.oracle = true
kernel_rfl D1BodySized.fuelA47 : nth? D1BodySized.ks 161 = some 1
kernel_rfl D1BodySized.fuelB47 : nth? D1BodySized.ks 162 = some 3
kernel_rfl D1BodySized.stepA47 : interpS (step D1BodySized.F D1BodySized.s161).run D1BodySized.S161 =
  some (D1BodySized.s162, D1BodySized.S162)
kernel_rfl D1BodySized.patchB47 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s162).run D1BodySized.S162 =
  some (D1BodySized.s163, D1BodySized.S163)
kernel_rfl D1BodySized.acceptedP47 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s161 D1BodySized.S161) = fun _ => true
kernel_rfl D1BodySized.haltP47 : isHalt D1BodySized.s161.ctl = false
kernel_rfl D1BodySized.topA47 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s162 = true
kernel_rfl D1BodySized.inactive47 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s162.ffi).active = false
/-- Bridge 47's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys47 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s162 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs47 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s162 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA47 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s162 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys47, D1BodySized.sizeArgs47)
kernel_rfl D1BodySized.sizeArgsA47 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s162 = true
kernel_rfl D1BodySized.sizeSymA47 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA47 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA47 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA47 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec47 := interpS (decodeArgs D1BodySized.F D1BodySized.s162 D1BodySized.sizeTys47 D1BodySized.sizeArgs47).run D1BodySized.S162
noncomputable def D1BodySized.sizeAs47 : List Arg := match D1BodySized.sizeDec47 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS047 : SSrv := match D1BodySized.sizeDec47 with | some (_, S) => S | none => D1BodySized.S162
kernel_rfl D1BodySized.sizeDecA47 : interpS (decodeArgs D1BodySized.F D1BodySized.s162 D1BodySized.sizeTys47 D1BodySized.sizeArgs47).run D1BodySized.S162 =
  some (some D1BodySized.sizeAs47, D1BodySized.sizeS047)
kernel_rfl D1BodySized.sizePreA47 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS047 D1BodySized.s162.ffi D1BodySized.sizeAs47 = true

end Host.Load.Run.Tpl
end

section -- SN163
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel163 : nth? D1BodySized.ks 163 = some 10000
kernel_rfl D1BodySized.checked163 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s163 D1BodySized.S163) =
    fun _ => some (D1BodySized.s164, D1BodySized.S164)

theorem D1BodySized.k163 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s163 D1BodySized.S163 =
      some (D1BodySized.s164, D1BodySized.S164) := congrFun D1BodySized.checked163 bs

end Host.Load.Run.Tpl
end
