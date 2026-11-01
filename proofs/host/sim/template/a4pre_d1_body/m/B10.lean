import host.sim.template.a4pre_d1_body.TraceStep
import host.sim.template.a4pre_d1_body.m.B09
import host.sim.template.a4pre_d1_body.m.B00
import host.sim.template.a4pre_d1_body.SizeLift
import host.sim.Chunk
import host.sim.template.a4pre_d1_body.SizeAdvance
import host.sim.template.a4pre_d1_body.TraceAdvance
import host.sim.template.a4pre_d1_body.m.B01
import host.sim.template.a4pre_d1_body.m.B02
import host.sim.template.a4pre_d1_body.m.B03
import host.sim.template.a4pre_d1_body.m.B04

section -- SB174
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment174 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s600 D1BodySized.S600 =
      some (D1BodySized.s601, D1BodySized.S601) := D1BodySized.k600 bs

kernel_rfl D1BodySized.accepted174 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s600 D1BodySized.S600) = fun _ => true
kernel_rfl D1BodySized.oracle174 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S600.oracle = true
kernel_rfl D1BodySized.fuelA175 : nth? D1BodySized.ks 601 = some 1
kernel_rfl D1BodySized.fuelB175 : nth? D1BodySized.ks 602 = some 3
kernel_rfl D1BodySized.stepA175 : interpS (step D1BodySized.F D1BodySized.s601).run D1BodySized.S601 =
  some (D1BodySized.s602, D1BodySized.S602)
kernel_rfl D1BodySized.patchB175 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s602).run D1BodySized.S602 =
  some (D1BodySized.s603, D1BodySized.S603)
kernel_rfl D1BodySized.acceptedP175 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s601 D1BodySized.S601) = fun _ => true
kernel_rfl D1BodySized.haltP175 : isHalt D1BodySized.s601.ctl = false
kernel_rfl D1BodySized.topA175 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s602 = true
kernel_rfl D1BodySized.inactive175 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s602.ffi).active = false
/-- Bridge 175's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys175 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s602 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs175 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s602 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA175 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s602 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys175, D1BodySized.sizeArgs175)
kernel_rfl D1BodySized.sizeArgsA175 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s602 = true
kernel_rfl D1BodySized.sizeSymA175 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA175 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA175 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA175 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec175 := interpS (decodeArgs D1BodySized.F D1BodySized.s602 D1BodySized.sizeTys175 D1BodySized.sizeArgs175).run D1BodySized.S602
noncomputable def D1BodySized.sizeAs175 : List Arg := match D1BodySized.sizeDec175 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0175 : SSrv := match D1BodySized.sizeDec175 with | some (_, S) => S | none => D1BodySized.S602
kernel_rfl D1BodySized.sizeDecA175 : interpS (decodeArgs D1BodySized.F D1BodySized.s602 D1BodySized.sizeTys175 D1BodySized.sizeArgs175).run D1BodySized.S602 =
  some (some D1BodySized.sizeAs175, D1BodySized.sizeS0175)
kernel_rfl D1BodySized.sizePreA175 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0175 D1BodySized.s602.ffi D1BodySized.sizeAs175 = true

end Host.Load.Run.Tpl
end

section -- SN603
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel603 : nth? D1BodySized.ks 603 = some 10000
kernel_rfl D1BodySized.checked603 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s603 D1BodySized.S603) =
    fun _ => some (D1BodySized.s604, D1BodySized.S604)

theorem D1BodySized.k603 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s603 D1BodySized.S603 =
      some (D1BodySized.s604, D1BodySized.S604) := congrFun D1BodySized.checked603 bs

end Host.Load.Run.Tpl
end

section -- SN604
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel604 : nth? D1BodySized.ks 604 = some 10000
kernel_rfl D1BodySized.checked604 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s604 D1BodySized.S604) =
    fun _ => some (D1BodySized.s605, D1BodySized.S605)

theorem D1BodySized.k604 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s604 D1BodySized.S604 =
      some (D1BodySized.s605, D1BodySized.S605) := congrFun D1BodySized.checked604 bs

end Host.Load.Run.Tpl
end

section -- SN605
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel605 : nth? D1BodySized.ks 605 = some 2340
kernel_rfl D1BodySized.checked605 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2340 D1BodySized.s605 D1BodySized.S605) =
    fun _ => some (D1BodySized.s606, D1BodySized.S606)

theorem D1BodySized.k605 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2340 D1BodySized.s605 D1BodySized.S605 =
      some (D1BodySized.s606, D1BodySized.S606) := congrFun D1BodySized.checked605 bs

end Host.Load.Run.Tpl
end

section -- SB175
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment175 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22340 D1BodySized.s603 D1BodySized.S603 =
      some (D1BodySized.s606, D1BodySized.S606) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2340 D1BodySized.s603 D1BodySized.s605 D1BodySized.s606 D1BodySized.S603 D1BodySized.S605 D1BodySized.S606 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s603 D1BodySized.s604 D1BodySized.s605 D1BodySized.S603 D1BodySized.S604 D1BodySized.S605 (D1BodySized.k603 bs) (D1BodySized.k604 bs)) (D1BodySized.k605 bs)

kernel_rfl D1BodySized.accepted175 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s603 D1BodySized.S603) = fun _ => true
kernel_rfl D1BodySized.oracle175 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S603.oracle = true
kernel_rfl D1BodySized.fuelA176 : nth? D1BodySized.ks 606 = some 1
kernel_rfl D1BodySized.fuelB176 : nth? D1BodySized.ks 607 = some 3
kernel_rfl D1BodySized.stepA176 : interpS (step D1BodySized.F D1BodySized.s606).run D1BodySized.S606 =
  some (D1BodySized.s607, D1BodySized.S607)
kernel_rfl D1BodySized.patchB176 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s607).run D1BodySized.S607 =
  some (D1BodySized.s608, D1BodySized.S608)
kernel_rfl D1BodySized.acceptedP176 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s606 D1BodySized.S606) = fun _ => true
kernel_rfl D1BodySized.haltP176 : isHalt D1BodySized.s606.ctl = false
kernel_rfl D1BodySized.topA176 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s607 = true
kernel_rfl D1BodySized.inactive176 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s607.ffi).active = false
/-- Bridge 176's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys176 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s607 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs176 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s607 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA176 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s607 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys176, D1BodySized.sizeArgs176)
kernel_rfl D1BodySized.sizeArgsA176 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s607 = true
kernel_rfl D1BodySized.sizeSymA176 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA176 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA176 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA176 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec176 := interpS (decodeArgs D1BodySized.F D1BodySized.s607 D1BodySized.sizeTys176 D1BodySized.sizeArgs176).run D1BodySized.S607
noncomputable def D1BodySized.sizeAs176 : List Arg := match D1BodySized.sizeDec176 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0176 : SSrv := match D1BodySized.sizeDec176 with | some (_, S) => S | none => D1BodySized.S607
kernel_rfl D1BodySized.sizeDecA176 : interpS (decodeArgs D1BodySized.F D1BodySized.s607 D1BodySized.sizeTys176 D1BodySized.sizeArgs176).run D1BodySized.S607 =
  some (some D1BodySized.sizeAs176, D1BodySized.sizeS0176)
kernel_rfl D1BodySized.sizePreA176 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0176 D1BodySized.s607.ffi D1BodySized.sizeAs176 = true

end Host.Load.Run.Tpl
end

section -- SN608
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel608 : nth? D1BodySized.ks 608 = some 10000
kernel_rfl D1BodySized.checked608 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s608 D1BodySized.S608) =
    fun _ => some (D1BodySized.s609, D1BodySized.S609)

theorem D1BodySized.k608 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s608 D1BodySized.S608 =
      some (D1BodySized.s609, D1BodySized.S609) := congrFun D1BodySized.checked608 bs

end Host.Load.Run.Tpl
end

section -- SN609
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel609 : nth? D1BodySized.ks 609 = some 10000
kernel_rfl D1BodySized.checked609 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s609 D1BodySized.S609) =
    fun _ => some (D1BodySized.s610, D1BodySized.S610)

theorem D1BodySized.k609 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s609 D1BodySized.S609 =
      some (D1BodySized.s610, D1BodySized.S610) := congrFun D1BodySized.checked609 bs

end Host.Load.Run.Tpl
end

section -- SN610
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel610 : nth? D1BodySized.ks 610 = some 295
kernel_rfl D1BodySized.checked610 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 295 D1BodySized.s610 D1BodySized.S610) =
    fun _ => some (D1BodySized.s611, D1BodySized.S611)

theorem D1BodySized.k610 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 295 D1BodySized.s610 D1BodySized.S610 =
      some (D1BodySized.s611, D1BodySized.S611) := congrFun D1BodySized.checked610 bs

end Host.Load.Run.Tpl
end

section -- SB176
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment176 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 20295 D1BodySized.s608 D1BodySized.S608 =
      some (D1BodySized.s611, D1BodySized.S611) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 295 D1BodySized.s608 D1BodySized.s610 D1BodySized.s611 D1BodySized.S608 D1BodySized.S610 D1BodySized.S611 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s608 D1BodySized.s609 D1BodySized.s610 D1BodySized.S608 D1BodySized.S609 D1BodySized.S610 (D1BodySized.k608 bs) (D1BodySized.k609 bs)) (D1BodySized.k610 bs)

kernel_rfl D1BodySized.accepted176 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s608 D1BodySized.S608) = fun _ => true
kernel_rfl D1BodySized.oracle176 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S608.oracle = true
kernel_rfl D1BodySized.fuelA177 : nth? D1BodySized.ks 611 = some 1
kernel_rfl D1BodySized.fuelB177 : nth? D1BodySized.ks 612 = some 3
kernel_rfl D1BodySized.stepA177 : interpS (step D1BodySized.F D1BodySized.s611).run D1BodySized.S611 =
  some (D1BodySized.s612, D1BodySized.S612)
kernel_rfl D1BodySized.patchB177 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s612).run D1BodySized.S612 =
  some (D1BodySized.s613, D1BodySized.S613)
kernel_rfl D1BodySized.acceptedP177 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s611 D1BodySized.S611) = fun _ => true
kernel_rfl D1BodySized.haltP177 : isHalt D1BodySized.s611.ctl = false
kernel_rfl D1BodySized.topA177 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s612 = true
kernel_rfl D1BodySized.inactive177 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s612.ffi).active = false
/-- Bridge 177's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys177 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s612 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs177 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s612 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA177 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s612 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys177, D1BodySized.sizeArgs177)
kernel_rfl D1BodySized.sizeArgsA177 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s612 = true
kernel_rfl D1BodySized.sizeSymA177 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA177 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA177 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA177 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec177 := interpS (decodeArgs D1BodySized.F D1BodySized.s612 D1BodySized.sizeTys177 D1BodySized.sizeArgs177).run D1BodySized.S612
noncomputable def D1BodySized.sizeAs177 : List Arg := match D1BodySized.sizeDec177 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0177 : SSrv := match D1BodySized.sizeDec177 with | some (_, S) => S | none => D1BodySized.S612
kernel_rfl D1BodySized.sizeDecA177 : interpS (decodeArgs D1BodySized.F D1BodySized.s612 D1BodySized.sizeTys177 D1BodySized.sizeArgs177).run D1BodySized.S612 =
  some (some D1BodySized.sizeAs177, D1BodySized.sizeS0177)
kernel_rfl D1BodySized.sizePreA177 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0177 D1BodySized.s612.ffi D1BodySized.sizeAs177 = true

end Host.Load.Run.Tpl
end

section -- SN613
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel613 : nth? D1BodySized.ks 613 = some 2542
kernel_rfl D1BodySized.checked613 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s613 D1BodySized.S613) =
    fun _ => some (D1BodySized.s614, D1BodySized.S614)

theorem D1BodySized.k613 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s613 D1BodySized.S613 =
      some (D1BodySized.s614, D1BodySized.S614) := congrFun D1BodySized.checked613 bs

end Host.Load.Run.Tpl
end

section -- SB177
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment177 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s613 D1BodySized.S613 =
      some (D1BodySized.s614, D1BodySized.S614) := D1BodySized.k613 bs

kernel_rfl D1BodySized.accepted177 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s613 D1BodySized.S613) = fun _ => true
kernel_rfl D1BodySized.oracle177 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S613.oracle = true
kernel_rfl D1BodySized.fuelA178 : nth? D1BodySized.ks 614 = some 1
kernel_rfl D1BodySized.fuelB178 : nth? D1BodySized.ks 615 = some 3
kernel_rfl D1BodySized.stepA178 : interpS (step D1BodySized.F D1BodySized.s614).run D1BodySized.S614 =
  some (D1BodySized.s615, D1BodySized.S615)
kernel_rfl D1BodySized.patchB178 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s615).run D1BodySized.S615 =
  some (D1BodySized.s616, D1BodySized.S616)
kernel_rfl D1BodySized.acceptedP178 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s614 D1BodySized.S614) = fun _ => true
kernel_rfl D1BodySized.haltP178 : isHalt D1BodySized.s614.ctl = false
kernel_rfl D1BodySized.topA178 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s615 = true
kernel_rfl D1BodySized.inactive178 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s615.ffi).active = false
/-- Bridge 178's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys178 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s615 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs178 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s615 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA178 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s615 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys178, D1BodySized.sizeArgs178)
kernel_rfl D1BodySized.sizeArgsA178 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s615 = true
kernel_rfl D1BodySized.sizeSymA178 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA178 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA178 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA178 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec178 := interpS (decodeArgs D1BodySized.F D1BodySized.s615 D1BodySized.sizeTys178 D1BodySized.sizeArgs178).run D1BodySized.S615
noncomputable def D1BodySized.sizeAs178 : List Arg := match D1BodySized.sizeDec178 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0178 : SSrv := match D1BodySized.sizeDec178 with | some (_, S) => S | none => D1BodySized.S615
kernel_rfl D1BodySized.sizeDecA178 : interpS (decodeArgs D1BodySized.F D1BodySized.s615 D1BodySized.sizeTys178 D1BodySized.sizeArgs178).run D1BodySized.S615 =
  some (some D1BodySized.sizeAs178, D1BodySized.sizeS0178)
kernel_rfl D1BodySized.sizePreA178 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0178 D1BodySized.s615.ffi D1BodySized.sizeAs178 = true

end Host.Load.Run.Tpl
end

section -- SN616
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel616 : nth? D1BodySized.ks 616 = some 10000
kernel_rfl D1BodySized.checked616 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s616 D1BodySized.S616) =
    fun _ => some (D1BodySized.s617, D1BodySized.S617)

theorem D1BodySized.k616 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s616 D1BodySized.S616 =
      some (D1BodySized.s617, D1BodySized.S617) := congrFun D1BodySized.checked616 bs

end Host.Load.Run.Tpl
end

section -- SN617
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel617 : nth? D1BodySized.ks 617 = some 10000
kernel_rfl D1BodySized.checked617 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s617 D1BodySized.S617) =
    fun _ => some (D1BodySized.s618, D1BodySized.S618)

theorem D1BodySized.k617 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s617 D1BodySized.S617 =
      some (D1BodySized.s618, D1BodySized.S618) := congrFun D1BodySized.checked617 bs

end Host.Load.Run.Tpl
end

section -- SN618
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel618 : nth? D1BodySized.ks 618 = some 1520
kernel_rfl D1BodySized.checked618 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1520 D1BodySized.s618 D1BodySized.S618) =
    fun _ => some (D1BodySized.s619, D1BodySized.S619)

theorem D1BodySized.k618 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1520 D1BodySized.s618 D1BodySized.S618 =
      some (D1BodySized.s619, D1BodySized.S619) := congrFun D1BodySized.checked618 bs

end Host.Load.Run.Tpl
end

section -- SB178
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment178 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 21520 D1BodySized.s616 D1BodySized.S616 =
      some (D1BodySized.s619, D1BodySized.S619) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 1520 D1BodySized.s616 D1BodySized.s618 D1BodySized.s619 D1BodySized.S616 D1BodySized.S618 D1BodySized.S619 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s616 D1BodySized.s617 D1BodySized.s618 D1BodySized.S616 D1BodySized.S617 D1BodySized.S618 (D1BodySized.k616 bs) (D1BodySized.k617 bs)) (D1BodySized.k618 bs)

kernel_rfl D1BodySized.accepted178 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s616 D1BodySized.S616) = fun _ => true
kernel_rfl D1BodySized.oracle178 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S616.oracle = true
kernel_rfl D1BodySized.fuelA179 : nth? D1BodySized.ks 619 = some 1
kernel_rfl D1BodySized.fuelB179 : nth? D1BodySized.ks 620 = some 3
kernel_rfl D1BodySized.stepA179 : interpS (step D1BodySized.F D1BodySized.s619).run D1BodySized.S619 =
  some (D1BodySized.s620, D1BodySized.S620)
kernel_rfl D1BodySized.patchB179 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s620).run D1BodySized.S620 =
  some (D1BodySized.s621, D1BodySized.S621)
kernel_rfl D1BodySized.acceptedP179 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s619 D1BodySized.S619) = fun _ => true
kernel_rfl D1BodySized.haltP179 : isHalt D1BodySized.s619.ctl = false
kernel_rfl D1BodySized.topA179 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s620 = true
kernel_rfl D1BodySized.inactive179 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s620.ffi).active = false
/-- Bridge 179's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys179 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s620 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs179 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s620 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA179 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s620 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys179, D1BodySized.sizeArgs179)
kernel_rfl D1BodySized.sizeArgsA179 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s620 = true
kernel_rfl D1BodySized.sizeSymA179 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA179 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA179 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA179 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec179 := interpS (decodeArgs D1BodySized.F D1BodySized.s620 D1BodySized.sizeTys179 D1BodySized.sizeArgs179).run D1BodySized.S620
noncomputable def D1BodySized.sizeAs179 : List Arg := match D1BodySized.sizeDec179 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0179 : SSrv := match D1BodySized.sizeDec179 with | some (_, S) => S | none => D1BodySized.S620
kernel_rfl D1BodySized.sizeDecA179 : interpS (decodeArgs D1BodySized.F D1BodySized.s620 D1BodySized.sizeTys179 D1BodySized.sizeArgs179).run D1BodySized.S620 =
  some (some D1BodySized.sizeAs179, D1BodySized.sizeS0179)
kernel_rfl D1BodySized.sizePreA179 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0179 D1BodySized.s620.ffi D1BodySized.sizeAs179 = true

end Host.Load.Run.Tpl
end

section -- SN621
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel621 : nth? D1BodySized.ks 621 = some 10000
kernel_rfl D1BodySized.checked621 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s621 D1BodySized.S621) =
    fun _ => some (D1BodySized.s622, D1BodySized.S622)

theorem D1BodySized.k621 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s621 D1BodySized.S621 =
      some (D1BodySized.s622, D1BodySized.S622) := congrFun D1BodySized.checked621 bs

end Host.Load.Run.Tpl
end

section -- SN622
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel622 : nth? D1BodySized.ks 622 = some 10000
kernel_rfl D1BodySized.checked622 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s622 D1BodySized.S622) =
    fun _ => some (D1BodySized.s623, D1BodySized.S623)

theorem D1BodySized.k622 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s622 D1BodySized.S622 =
      some (D1BodySized.s623, D1BodySized.S623) := congrFun D1BodySized.checked622 bs

end Host.Load.Run.Tpl
end

section -- SN623
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel623 : nth? D1BodySized.ks 623 = some 77
kernel_rfl D1BodySized.checked623 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 77 D1BodySized.s623 D1BodySized.S623) =
    fun _ => some (D1BodySized.s624, D1BodySized.S624)

theorem D1BodySized.k623 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 77 D1BodySized.s623 D1BodySized.S623 =
      some (D1BodySized.s624, D1BodySized.S624) := congrFun D1BodySized.checked623 bs

end Host.Load.Run.Tpl
end

section -- SB179
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment179 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 20077 D1BodySized.s621 D1BodySized.S621 =
      some (D1BodySized.s624, D1BodySized.S624) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 77 D1BodySized.s621 D1BodySized.s623 D1BodySized.s624 D1BodySized.S621 D1BodySized.S623 D1BodySized.S624 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s621 D1BodySized.s622 D1BodySized.s623 D1BodySized.S621 D1BodySized.S622 D1BodySized.S623 (D1BodySized.k621 bs) (D1BodySized.k622 bs)) (D1BodySized.k623 bs)

kernel_rfl D1BodySized.accepted179 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s621 D1BodySized.S621) = fun _ => true
kernel_rfl D1BodySized.oracle179 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S621.oracle = true
kernel_rfl D1BodySized.fuelA180 : nth? D1BodySized.ks 624 = some 1
kernel_rfl D1BodySized.fuelB180 : nth? D1BodySized.ks 625 = some 3
kernel_rfl D1BodySized.stepA180 : interpS (step D1BodySized.F D1BodySized.s624).run D1BodySized.S624 =
  some (D1BodySized.s625, D1BodySized.S625)
kernel_rfl D1BodySized.patchB180 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s625).run D1BodySized.S625 =
  some (D1BodySized.s626, D1BodySized.S626)
kernel_rfl D1BodySized.acceptedP180 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s624 D1BodySized.S624) = fun _ => true
kernel_rfl D1BodySized.haltP180 : isHalt D1BodySized.s624.ctl = false
kernel_rfl D1BodySized.topA180 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s625 = true
kernel_rfl D1BodySized.inactive180 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s625.ffi).active = false
/-- Bridge 180's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys180 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s625 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs180 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s625 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA180 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s625 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys180, D1BodySized.sizeArgs180)
kernel_rfl D1BodySized.sizeArgsA180 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s625 = true
kernel_rfl D1BodySized.sizeSymA180 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA180 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA180 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA180 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec180 := interpS (decodeArgs D1BodySized.F D1BodySized.s625 D1BodySized.sizeTys180 D1BodySized.sizeArgs180).run D1BodySized.S625
noncomputable def D1BodySized.sizeAs180 : List Arg := match D1BodySized.sizeDec180 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0180 : SSrv := match D1BodySized.sizeDec180 with | some (_, S) => S | none => D1BodySized.S625
kernel_rfl D1BodySized.sizeDecA180 : interpS (decodeArgs D1BodySized.F D1BodySized.s625 D1BodySized.sizeTys180 D1BodySized.sizeArgs180).run D1BodySized.S625 =
  some (some D1BodySized.sizeAs180, D1BodySized.sizeS0180)
kernel_rfl D1BodySized.sizePreA180 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0180 D1BodySized.s625.ffi D1BodySized.sizeAs180 = true

end Host.Load.Run.Tpl
end

section -- SN626
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel626 : nth? D1BodySized.ks 626 = some 2542
kernel_rfl D1BodySized.checked626 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s626 D1BodySized.S626) =
    fun _ => some (D1BodySized.s627, D1BodySized.S627)

theorem D1BodySized.k626 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s626 D1BodySized.S626 =
      some (D1BodySized.s627, D1BodySized.S627) := congrFun D1BodySized.checked626 bs

end Host.Load.Run.Tpl
end

section -- SB180
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment180 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s626 D1BodySized.S626 =
      some (D1BodySized.s627, D1BodySized.S627) := D1BodySized.k626 bs

kernel_rfl D1BodySized.accepted180 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s626 D1BodySized.S626) = fun _ => true
kernel_rfl D1BodySized.oracle180 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S626.oracle = true
kernel_rfl D1BodySized.fuelA181 : nth? D1BodySized.ks 627 = some 1
kernel_rfl D1BodySized.fuelB181 : nth? D1BodySized.ks 628 = some 3
kernel_rfl D1BodySized.stepA181 : interpS (step D1BodySized.F D1BodySized.s627).run D1BodySized.S627 =
  some (D1BodySized.s628, D1BodySized.S628)
kernel_rfl D1BodySized.patchB181 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s628).run D1BodySized.S628 =
  some (D1BodySized.s629, D1BodySized.S629)
kernel_rfl D1BodySized.acceptedP181 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s627 D1BodySized.S627) = fun _ => true
kernel_rfl D1BodySized.haltP181 : isHalt D1BodySized.s627.ctl = false
kernel_rfl D1BodySized.topA181 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s628 = true
kernel_rfl D1BodySized.inactive181 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s628.ffi).active = false
/-- Bridge 181's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys181 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s628 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs181 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s628 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA181 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s628 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys181, D1BodySized.sizeArgs181)
kernel_rfl D1BodySized.sizeArgsA181 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s628 = true
kernel_rfl D1BodySized.sizeSymA181 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA181 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA181 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA181 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec181 := interpS (decodeArgs D1BodySized.F D1BodySized.s628 D1BodySized.sizeTys181 D1BodySized.sizeArgs181).run D1BodySized.S628
noncomputable def D1BodySized.sizeAs181 : List Arg := match D1BodySized.sizeDec181 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0181 : SSrv := match D1BodySized.sizeDec181 with | some (_, S) => S | none => D1BodySized.S628
kernel_rfl D1BodySized.sizeDecA181 : interpS (decodeArgs D1BodySized.F D1BodySized.s628 D1BodySized.sizeTys181 D1BodySized.sizeArgs181).run D1BodySized.S628 =
  some (some D1BodySized.sizeAs181, D1BodySized.sizeS0181)
kernel_rfl D1BodySized.sizePreA181 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0181 D1BodySized.s628.ffi D1BodySized.sizeAs181 = true

end Host.Load.Run.Tpl
end

section -- SN629
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel629 : nth? D1BodySized.ks 629 = some 10000
kernel_rfl D1BodySized.checked629 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s629 D1BodySized.S629) =
    fun _ => some (D1BodySized.s630, D1BodySized.S630)

theorem D1BodySized.k629 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s629 D1BodySized.S629 =
      some (D1BodySized.s630, D1BodySized.S630) := congrFun D1BodySized.checked629 bs

end Host.Load.Run.Tpl
end

section -- SN630
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel630 : nth? D1BodySized.ks 630 = some 10000
kernel_rfl D1BodySized.checked630 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s630 D1BodySized.S630) =
    fun _ => some (D1BodySized.s631, D1BodySized.S631)

theorem D1BodySized.k630 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s630 D1BodySized.S630 =
      some (D1BodySized.s631, D1BodySized.S631) := congrFun D1BodySized.checked630 bs

end Host.Load.Run.Tpl
end

section -- SN631
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel631 : nth? D1BodySized.ks 631 = some 2292
kernel_rfl D1BodySized.checked631 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2292 D1BodySized.s631 D1BodySized.S631) =
    fun _ => some (D1BodySized.s632, D1BodySized.S632)

theorem D1BodySized.k631 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2292 D1BodySized.s631 D1BodySized.S631 =
      some (D1BodySized.s632, D1BodySized.S632) := congrFun D1BodySized.checked631 bs

end Host.Load.Run.Tpl
end

section -- SB181
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment181 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22292 D1BodySized.s629 D1BodySized.S629 =
      some (D1BodySized.s632, D1BodySized.S632) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2292 D1BodySized.s629 D1BodySized.s631 D1BodySized.s632 D1BodySized.S629 D1BodySized.S631 D1BodySized.S632 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s629 D1BodySized.s630 D1BodySized.s631 D1BodySized.S629 D1BodySized.S630 D1BodySized.S631 (D1BodySized.k629 bs) (D1BodySized.k630 bs)) (D1BodySized.k631 bs)

kernel_rfl D1BodySized.accepted181 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s629 D1BodySized.S629) = fun _ => true
kernel_rfl D1BodySized.oracle181 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S629.oracle = true
kernel_rfl D1BodySized.fuelA182 : nth? D1BodySized.ks 632 = some 1
kernel_rfl D1BodySized.fuelB182 : nth? D1BodySized.ks 633 = some 3
kernel_rfl D1BodySized.stepA182 : interpS (step D1BodySized.F D1BodySized.s632).run D1BodySized.S632 =
  some (D1BodySized.s633, D1BodySized.S633)
kernel_rfl D1BodySized.patchB182 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s633).run D1BodySized.S633 =
  some (D1BodySized.s634, D1BodySized.S634)
kernel_rfl D1BodySized.acceptedP182 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s632 D1BodySized.S632) = fun _ => true
kernel_rfl D1BodySized.haltP182 : isHalt D1BodySized.s632.ctl = false
kernel_rfl D1BodySized.topA182 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s633 = true
kernel_rfl D1BodySized.inactive182 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s633.ffi).active = false
/-- Bridge 182's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys182 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s633 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs182 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s633 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA182 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s633 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys182, D1BodySized.sizeArgs182)
kernel_rfl D1BodySized.sizeArgsA182 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s633 = true
kernel_rfl D1BodySized.sizeSymA182 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA182 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA182 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA182 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec182 := interpS (decodeArgs D1BodySized.F D1BodySized.s633 D1BodySized.sizeTys182 D1BodySized.sizeArgs182).run D1BodySized.S633
noncomputable def D1BodySized.sizeAs182 : List Arg := match D1BodySized.sizeDec182 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0182 : SSrv := match D1BodySized.sizeDec182 with | some (_, S) => S | none => D1BodySized.S633
kernel_rfl D1BodySized.sizeDecA182 : interpS (decodeArgs D1BodySized.F D1BodySized.s633 D1BodySized.sizeTys182 D1BodySized.sizeArgs182).run D1BodySized.S633 =
  some (some D1BodySized.sizeAs182, D1BodySized.sizeS0182)
kernel_rfl D1BodySized.sizePreA182 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0182 D1BodySized.s633.ffi D1BodySized.sizeAs182 = true

end Host.Load.Run.Tpl
end

section -- SN634
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel634 : nth? D1BodySized.ks 634 = some 7368
kernel_rfl D1BodySized.checked634 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7368 D1BodySized.s634 D1BodySized.S634) =
    fun _ => some (D1BodySized.s635, D1BodySized.S635)

theorem D1BodySized.k634 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7368 D1BodySized.s634 D1BodySized.S634 =
      some (D1BodySized.s635, D1BodySized.S635) := congrFun D1BodySized.checked634 bs

end Host.Load.Run.Tpl
end

section -- SB182
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment182 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7368 D1BodySized.s634 D1BodySized.S634 =
      some (D1BodySized.s635, D1BodySized.S635) := D1BodySized.k634 bs

kernel_rfl D1BodySized.accepted182 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s634 D1BodySized.S634) = fun _ => true
kernel_rfl D1BodySized.oracle182 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S634.oracle = true

end Host.Load.Run.Tpl
end

section -- SQ0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive0 : (bridgeOf D1BodySized.s0.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check0 : decide (20 ≤ D1BodySized.S0.tab.length) = true
theorem D1BodySized.fromTable20_0 : 20 ≤ D1BodySized.S0.tab.length := of_decide_eq_true D1BodySized.fromTable20Check0
kernel_rfl D1BodySized.bridgeInto0 : bridgeOf D1BodySized.s4.ffi = bridgeOf D1BodySized.s0.ffi
kernel_rfl D1BodySized.bridgeOut0 : bridgeOf D1BodySized.s5.ffi = bridgeOf D1BodySized.s4.ffi
kernel_rfl D1BodySized.sizeTable20Check0 : decide (20 ≤ D1BodySized.S4.tab.length) = true
theorem D1BodySized.sizeTable20_0 : 20 ≤ D1BodySized.S4.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check0
kernel_rfl D1BodySized.sizeOracle0 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S4.oracle = true

end Host.Load.Run.Tpl
end

section -- SP0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece0 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s0 D1BodySized.S0) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s5 D1BodySized.S5) 24384 := by
  have h1 := D1BodyAdvance.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted0 D1BodySized.segment0 D1BodySized.acceptedP1
    D1BodySized.haltP1 D1BodySized.stepA1 D1BodySized.topA1
    D1BodySized.oracle0 D1BodySized.fromInactive0 D1BodySized.bridgeInto0 D1BodySized.fromTable20_0
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA1 D1BodySized.sizeArgsA1 D1BodySized.sizeSymA1
    D1BodySized.sizeMlxA1 D1BodySized.sizePayA1 (by decide)
    D1BodySized.sizeDecA1 D1BodySized.sizePreA1 D1BodySized.patchB1
    D1BodySized.sizeOracle0 D1BodySized.inactive1 D1BodySized.bridgeOut0 D1BodySized.sizeTable20_0
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive1 : (bridgeOf D1BodySized.s5.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check1 : decide (20 ≤ D1BodySized.S5.tab.length) = true
theorem D1BodySized.fromTable20_1 : 20 ≤ D1BodySized.S5.tab.length := of_decide_eq_true D1BodySized.fromTable20Check1
kernel_rfl D1BodySized.bridgeInto1 : bridgeOf D1BodySized.s7.ffi = bridgeOf D1BodySized.s5.ffi
kernel_rfl D1BodySized.bridgeOut1 : bridgeOf D1BodySized.s8.ffi = bridgeOf D1BodySized.s7.ffi
kernel_rfl D1BodySized.sizeTable20Check1 : decide (20 ≤ D1BodySized.S7.tab.length) = true
theorem D1BodySized.sizeTable20_1 : 20 ≤ D1BodySized.S7.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check1
kernel_rfl D1BodySized.sizeOracle1 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S7.oracle = true

end Host.Load.Run.Tpl
end

section -- SP1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece1 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s5 D1BodySized.S5) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s8 D1BodySized.S8) 5102 := by
  have h1 := D1BodyAdvance.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted1 D1BodySized.segment1 D1BodySized.acceptedP2
    D1BodySized.haltP2 D1BodySized.stepA2 D1BodySized.topA2
    D1BodySized.oracle1 D1BodySized.fromInactive1 D1BodySized.bridgeInto1 D1BodySized.fromTable20_1
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA2 D1BodySized.sizeArgsA2 D1BodySized.sizeSymA2
    D1BodySized.sizeMlxA2 D1BodySized.sizePayA2 (by decide)
    D1BodySized.sizeDecA2 D1BodySized.sizePreA2 D1BodySized.patchB2
    D1BodySized.sizeOracle1 D1BodySized.inactive2 D1BodySized.bridgeOut1 D1BodySized.sizeTable20_1
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive2 : (bridgeOf D1BodySized.s8.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check2 : decide (20 ≤ D1BodySized.S8.tab.length) = true
theorem D1BodySized.fromTable20_2 : 20 ≤ D1BodySized.S8.tab.length := of_decide_eq_true D1BodySized.fromTable20Check2
kernel_rfl D1BodySized.bridgeInto2 : bridgeOf D1BodySized.s10.ffi = bridgeOf D1BodySized.s8.ffi
kernel_rfl D1BodySized.bridgeOut2 : bridgeOf D1BodySized.s11.ffi = bridgeOf D1BodySized.s10.ffi
kernel_rfl D1BodySized.sizeTable20Check2 : decide (20 ≤ D1BodySized.S10.tab.length) = true
theorem D1BodySized.sizeTable20_2 : 20 ≤ D1BodySized.S10.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check2
kernel_rfl D1BodySized.sizeOracle2 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S10.oracle = true

end Host.Load.Run.Tpl
end

section -- SP2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece2 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s8 D1BodySized.S8) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s11 D1BodySized.S11) 2307 := by
  have h1 := D1BodyAdvance.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted2 D1BodySized.segment2 D1BodySized.acceptedP3
    D1BodySized.haltP3 D1BodySized.stepA3 D1BodySized.topA3
    D1BodySized.oracle2 D1BodySized.fromInactive2 D1BodySized.bridgeInto2 D1BodySized.fromTable20_2
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA3 D1BodySized.sizeArgsA3 D1BodySized.sizeSymA3
    D1BodySized.sizeMlxA3 D1BodySized.sizePayA3 (by decide)
    D1BodySized.sizeDecA3 D1BodySized.sizePreA3 D1BodySized.patchB3
    D1BodySized.sizeOracle2 D1BodySized.inactive3 D1BodySized.bridgeOut2 D1BodySized.sizeTable20_2
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive3 : (bridgeOf D1BodySized.s11.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check3 : decide (20 ≤ D1BodySized.S11.tab.length) = true
theorem D1BodySized.fromTable20_3 : 20 ≤ D1BodySized.S11.tab.length := of_decide_eq_true D1BodySized.fromTable20Check3
kernel_rfl D1BodySized.bridgeInto3 : bridgeOf D1BodySized.s14.ffi = bridgeOf D1BodySized.s11.ffi
kernel_rfl D1BodySized.bridgeOut3 : bridgeOf D1BodySized.s15.ffi = bridgeOf D1BodySized.s14.ffi
kernel_rfl D1BodySized.sizeTable20Check3 : decide (20 ≤ D1BodySized.S14.tab.length) = true
theorem D1BodySized.sizeTable20_3 : 20 ≤ D1BodySized.S14.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check3
kernel_rfl D1BodySized.sizeOracle3 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S14.oracle = true

end Host.Load.Run.Tpl
end

section -- SP3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece3 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s11 D1BodySized.S11) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s15 D1BodySized.S15) 10521 := by
  have h1 := D1BodyAdvance.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted3 D1BodySized.segment3 D1BodySized.acceptedP4
    D1BodySized.haltP4 D1BodySized.stepA4 D1BodySized.topA4
    D1BodySized.oracle3 D1BodySized.fromInactive3 D1BodySized.bridgeInto3 D1BodySized.fromTable20_3
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA4 D1BodySized.sizeArgsA4 D1BodySized.sizeSymA4
    D1BodySized.sizeMlxA4 D1BodySized.sizePayA4 (by decide)
    D1BodySized.sizeDecA4 D1BodySized.sizePreA4 D1BodySized.patchB4
    D1BodySized.sizeOracle3 D1BodySized.inactive4 D1BodySized.bridgeOut3 D1BodySized.sizeTable20_3
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive4 : (bridgeOf D1BodySized.s15.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check4 : decide (20 ≤ D1BodySized.S15.tab.length) = true
theorem D1BodySized.fromTable20_4 : 20 ≤ D1BodySized.S15.tab.length := of_decide_eq_true D1BodySized.fromTable20Check4
kernel_rfl D1BodySized.bridgeInto4 : bridgeOf D1BodySized.s17.ffi = bridgeOf D1BodySized.s15.ffi
kernel_rfl D1BodySized.bridgeOut4 : bridgeOf D1BodySized.s18.ffi = bridgeOf D1BodySized.s17.ffi
kernel_rfl D1BodySized.sizeTable20Check4 : decide (20 ≤ D1BodySized.S17.tab.length) = true
theorem D1BodySized.sizeTable20_4 : 20 ≤ D1BodySized.S17.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check4
kernel_rfl D1BodySized.sizeOracle4 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S17.oracle = true

end Host.Load.Run.Tpl
end

section -- SP4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece4 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s15 D1BodySized.S15) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s18 D1BodySized.S18) 2956 := by
  have h1 := D1BodyAdvance.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted4 D1BodySized.segment4 D1BodySized.acceptedP5
    D1BodySized.haltP5 D1BodySized.stepA5 D1BodySized.topA5
    D1BodySized.oracle4 D1BodySized.fromInactive4 D1BodySized.bridgeInto4 D1BodySized.fromTable20_4
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA5 D1BodySized.sizeArgsA5 D1BodySized.sizeSymA5
    D1BodySized.sizeMlxA5 D1BodySized.sizePayA5 (by decide)
    D1BodySized.sizeDecA5 D1BodySized.sizePreA5 D1BodySized.patchB5
    D1BodySized.sizeOracle4 D1BodySized.inactive5 D1BodySized.bridgeOut4 D1BodySized.sizeTable20_4
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive5 : (bridgeOf D1BodySized.s18.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check5 : decide (20 ≤ D1BodySized.S18.tab.length) = true
theorem D1BodySized.fromTable20_5 : 20 ≤ D1BodySized.S18.tab.length := of_decide_eq_true D1BodySized.fromTable20Check5
kernel_rfl D1BodySized.bridgeInto5 : bridgeOf D1BodySized.s21.ffi = bridgeOf D1BodySized.s18.ffi
kernel_rfl D1BodySized.bridgeOut5 : bridgeOf D1BodySized.s22.ffi = bridgeOf D1BodySized.s21.ffi
kernel_rfl D1BodySized.sizeTable20Check5 : decide (20 ≤ D1BodySized.S21.tab.length) = true
theorem D1BodySized.sizeTable20_5 : 20 ≤ D1BodySized.S21.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check5
kernel_rfl D1BodySized.sizeOracle5 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S21.oracle = true

end Host.Load.Run.Tpl
end

section -- SP5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece5 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s18 D1BodySized.S18) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s22 D1BodySized.S22) 14017 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted5 D1BodySized.segment5 D1BodySized.acceptedP6
    D1BodySized.haltP6 D1BodySized.stepA6 D1BodySized.topA6
    D1BodySized.oracle5 D1BodySized.fromInactive5 D1BodySized.bridgeInto5 D1BodySized.fromTable20_5
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA6 D1BodySized.sizeArgsA6 D1BodySized.sizeSymA6
    D1BodySized.sizeMlxA6 D1BodySized.sizePayA6 (by decide)
    D1BodySized.sizeDecA6 D1BodySized.sizePreA6 D1BodySized.patchB6
    D1BodySized.sizeOracle5 D1BodySized.inactive6 D1BodySized.bridgeOut5 D1BodySized.sizeTable20_5
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive6 : (bridgeOf D1BodySized.s22.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check6 : decide (20 ≤ D1BodySized.S22.tab.length) = true
theorem D1BodySized.fromTable20_6 : 20 ≤ D1BodySized.S22.tab.length := of_decide_eq_true D1BodySized.fromTable20Check6
kernel_rfl D1BodySized.bridgeInto6 : bridgeOf D1BodySized.s24.ffi = bridgeOf D1BodySized.s22.ffi
kernel_rfl D1BodySized.bridgeOut6 : bridgeOf D1BodySized.s25.ffi = bridgeOf D1BodySized.s24.ffi
kernel_rfl D1BodySized.sizeTable20Check6 : decide (20 ≤ D1BodySized.S24.tab.length) = true
theorem D1BodySized.sizeTable20_6 : 20 ≤ D1BodySized.S24.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check6
kernel_rfl D1BodySized.sizeOracle6 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S24.oracle = true

end Host.Load.Run.Tpl
end

section -- SP6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece6 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s22 D1BodySized.S22) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s25 D1BodySized.S25) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted6 D1BodySized.segment6 D1BodySized.acceptedP7
    D1BodySized.haltP7 D1BodySized.stepA7 D1BodySized.topA7
    D1BodySized.oracle6 D1BodySized.fromInactive6 D1BodySized.bridgeInto6 D1BodySized.fromTable20_6
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA7 D1BodySized.sizeArgsA7 D1BodySized.sizeSymA7
    D1BodySized.sizeMlxA7 D1BodySized.sizePayA7 (by decide)
    D1BodySized.sizeDecA7 D1BodySized.sizePreA7 D1BodySized.patchB7
    D1BodySized.sizeOracle6 D1BodySized.inactive7 D1BodySized.bridgeOut6 D1BodySized.sizeTable20_6
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive7 : (bridgeOf D1BodySized.s25.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check7 : decide (20 ≤ D1BodySized.S25.tab.length) = true
theorem D1BodySized.fromTable20_7 : 20 ≤ D1BodySized.S25.tab.length := of_decide_eq_true D1BodySized.fromTable20Check7
kernel_rfl D1BodySized.bridgeInto7 : bridgeOf D1BodySized.s27.ffi = bridgeOf D1BodySized.s25.ffi
kernel_rfl D1BodySized.bridgeOut7 : bridgeOf D1BodySized.s28.ffi = bridgeOf D1BodySized.s27.ffi
kernel_rfl D1BodySized.sizeTable20Check7 : decide (20 ≤ D1BodySized.S27.tab.length) = true
theorem D1BodySized.sizeTable20_7 : 20 ≤ D1BodySized.S27.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check7
kernel_rfl D1BodySized.sizeOracle7 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S27.oracle = true

end Host.Load.Run.Tpl
end

section -- SP7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece7 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s25 D1BodySized.S25) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s28 D1BodySized.S28) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted7 D1BodySized.segment7 D1BodySized.acceptedP8
    D1BodySized.haltP8 D1BodySized.stepA8 D1BodySized.topA8
    D1BodySized.oracle7 D1BodySized.fromInactive7 D1BodySized.bridgeInto7 D1BodySized.fromTable20_7
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA8 D1BodySized.sizeArgsA8 D1BodySized.sizeSymA8
    D1BodySized.sizeMlxA8 D1BodySized.sizePayA8 (by decide)
    D1BodySized.sizeDecA8 D1BodySized.sizePreA8 D1BodySized.patchB8
    D1BodySized.sizeOracle7 D1BodySized.inactive8 D1BodySized.bridgeOut7 D1BodySized.sizeTable20_7
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive8 : (bridgeOf D1BodySized.s28.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check8 : decide (20 ≤ D1BodySized.S28.tab.length) = true
theorem D1BodySized.fromTable20_8 : 20 ≤ D1BodySized.S28.tab.length := of_decide_eq_true D1BodySized.fromTable20Check8
kernel_rfl D1BodySized.bridgeInto8 : bridgeOf D1BodySized.s31.ffi = bridgeOf D1BodySized.s28.ffi
kernel_rfl D1BodySized.bridgeOut8 : bridgeOf D1BodySized.s32.ffi = bridgeOf D1BodySized.s31.ffi
kernel_rfl D1BodySized.sizeTable20Check8 : decide (20 ≤ D1BodySized.S31.tab.length) = true
theorem D1BodySized.sizeTable20_8 : 20 ≤ D1BodySized.S31.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check8
kernel_rfl D1BodySized.sizeOracle8 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S31.oracle = true

end Host.Load.Run.Tpl
end

section -- SP8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece8 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s28 D1BodySized.S28) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s32 D1BodySized.S32) 14017 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted8 D1BodySized.segment8 D1BodySized.acceptedP9
    D1BodySized.haltP9 D1BodySized.stepA9 D1BodySized.topA9
    D1BodySized.oracle8 D1BodySized.fromInactive8 D1BodySized.bridgeInto8 D1BodySized.fromTable20_8
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA9 D1BodySized.sizeArgsA9 D1BodySized.sizeSymA9
    D1BodySized.sizeMlxA9 D1BodySized.sizePayA9 (by decide)
    D1BodySized.sizeDecA9 D1BodySized.sizePreA9 D1BodySized.patchB9
    D1BodySized.sizeOracle8 D1BodySized.inactive9 D1BodySized.bridgeOut8 D1BodySized.sizeTable20_8
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive9 : (bridgeOf D1BodySized.s32.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check9 : decide (20 ≤ D1BodySized.S32.tab.length) = true
theorem D1BodySized.fromTable20_9 : 20 ≤ D1BodySized.S32.tab.length := of_decide_eq_true D1BodySized.fromTable20Check9
kernel_rfl D1BodySized.bridgeInto9 : bridgeOf D1BodySized.s36.ffi = bridgeOf D1BodySized.s32.ffi
kernel_rfl D1BodySized.bridgeOut9 : bridgeOf D1BodySized.s37.ffi = bridgeOf D1BodySized.s36.ffi
kernel_rfl D1BodySized.sizeTable20Check9 : decide (20 ≤ D1BodySized.S36.tab.length) = true
theorem D1BodySized.sizeTable20_9 : 20 ≤ D1BodySized.S36.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check9
kernel_rfl D1BodySized.sizeOracle9 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S36.oracle = true

end Host.Load.Run.Tpl
end

section -- SP9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece9 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s32 D1BodySized.S32) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s37 D1BodySized.S37) 22322 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted9 D1BodySized.segment9 D1BodySized.acceptedP10
    D1BodySized.haltP10 D1BodySized.stepA10 D1BodySized.topA10
    D1BodySized.oracle9 D1BodySized.fromInactive9 D1BodySized.bridgeInto9 D1BodySized.fromTable20_9
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA10 D1BodySized.sizeArgsA10 D1BodySized.sizeSymA10
    D1BodySized.sizeMlxA10 D1BodySized.sizePayA10 (by decide)
    D1BodySized.sizeDecA10 D1BodySized.sizePreA10 D1BodySized.patchB10
    D1BodySized.sizeOracle9 D1BodySized.inactive10 D1BodySized.bridgeOut9 D1BodySized.sizeTable20_9
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive10 : (bridgeOf D1BodySized.s37.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check10 : decide (20 ≤ D1BodySized.S37.tab.length) = true
theorem D1BodySized.fromTable20_10 : 20 ≤ D1BodySized.S37.tab.length := of_decide_eq_true D1BodySized.fromTable20Check10
kernel_rfl D1BodySized.bridgeInto10 : bridgeOf D1BodySized.s39.ffi = bridgeOf D1BodySized.s37.ffi
kernel_rfl D1BodySized.bridgeOut10 : bridgeOf D1BodySized.s40.ffi = bridgeOf D1BodySized.s39.ffi
kernel_rfl D1BodySized.sizeTable20Check10 : decide (20 ≤ D1BodySized.S39.tab.length) = true
theorem D1BodySized.sizeTable20_10 : 20 ≤ D1BodySized.S39.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check10
kernel_rfl D1BodySized.sizeOracle10 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S39.oracle = true

end Host.Load.Run.Tpl
end

section -- SP10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece10 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s37 D1BodySized.S37) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s40 D1BodySized.S40) 7938 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted10 D1BodySized.segment10 D1BodySized.acceptedP11
    D1BodySized.haltP11 D1BodySized.stepA11 D1BodySized.topA11
    D1BodySized.oracle10 D1BodySized.fromInactive10 D1BodySized.bridgeInto10 D1BodySized.fromTable20_10
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA11 D1BodySized.sizeArgsA11 D1BodySized.sizeSymA11
    D1BodySized.sizeMlxA11 D1BodySized.sizePayA11 (by decide)
    D1BodySized.sizeDecA11 D1BodySized.sizePreA11 D1BodySized.patchB11
    D1BodySized.sizeOracle10 D1BodySized.inactive11 D1BodySized.bridgeOut10 D1BodySized.sizeTable20_10
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive11 : (bridgeOf D1BodySized.s40.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check11 : decide (20 ≤ D1BodySized.S40.tab.length) = true
theorem D1BodySized.fromTable20_11 : 20 ≤ D1BodySized.S40.tab.length := of_decide_eq_true D1BodySized.fromTable20Check11
kernel_rfl D1BodySized.bridgeInto11 : bridgeOf D1BodySized.s43.ffi = bridgeOf D1BodySized.s40.ffi
kernel_rfl D1BodySized.bridgeOut11 : bridgeOf D1BodySized.s44.ffi = bridgeOf D1BodySized.s43.ffi
kernel_rfl D1BodySized.sizeTable20Check11 : decide (20 ≤ D1BodySized.S43.tab.length) = true
theorem D1BodySized.sizeTable20_11 : 20 ≤ D1BodySized.S43.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check11
kernel_rfl D1BodySized.sizeOracle11 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S43.oracle = true

end Host.Load.Run.Tpl
end

section -- SP11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece11 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s40 D1BodySized.S40) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s44 D1BodySized.S44) 14854 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted11 D1BodySized.segment11 D1BodySized.acceptedP12
    D1BodySized.haltP12 D1BodySized.stepA12 D1BodySized.topA12
    D1BodySized.oracle11 D1BodySized.fromInactive11 D1BodySized.bridgeInto11 D1BodySized.fromTable20_11
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA12 D1BodySized.sizeArgsA12 D1BodySized.sizeSymA12
    D1BodySized.sizeMlxA12 D1BodySized.sizePayA12 (by decide)
    D1BodySized.sizeDecA12 D1BodySized.sizePreA12 D1BodySized.patchB12
    D1BodySized.sizeOracle11 D1BodySized.inactive12 D1BodySized.bridgeOut11 D1BodySized.sizeTable20_11
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive12 : (bridgeOf D1BodySized.s44.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check12 : decide (20 ≤ D1BodySized.S44.tab.length) = true
theorem D1BodySized.fromTable20_12 : 20 ≤ D1BodySized.S44.tab.length := of_decide_eq_true D1BodySized.fromTable20Check12
kernel_rfl D1BodySized.bridgeInto12 : bridgeOf D1BodySized.s46.ffi = bridgeOf D1BodySized.s44.ffi
kernel_rfl D1BodySized.bridgeOut12 : bridgeOf D1BodySized.s47.ffi = bridgeOf D1BodySized.s46.ffi
kernel_rfl D1BodySized.sizeTable20Check12 : decide (20 ≤ D1BodySized.S46.tab.length) = true
theorem D1BodySized.sizeTable20_12 : 20 ≤ D1BodySized.S46.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check12
kernel_rfl D1BodySized.sizeOracle12 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S46.oracle = true

end Host.Load.Run.Tpl
end

section -- SP12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece12 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s44 D1BodySized.S44) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s47 D1BodySized.S47) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted12 D1BodySized.segment12 D1BodySized.acceptedP13
    D1BodySized.haltP13 D1BodySized.stepA13 D1BodySized.topA13
    D1BodySized.oracle12 D1BodySized.fromInactive12 D1BodySized.bridgeInto12 D1BodySized.fromTable20_12
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA13 D1BodySized.sizeArgsA13 D1BodySized.sizeSymA13
    D1BodySized.sizeMlxA13 D1BodySized.sizePayA13 (by decide)
    D1BodySized.sizeDecA13 D1BodySized.sizePreA13 D1BodySized.patchB13
    D1BodySized.sizeOracle12 D1BodySized.inactive13 D1BodySized.bridgeOut12 D1BodySized.sizeTable20_12
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive13 : (bridgeOf D1BodySized.s47.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check13 : decide (20 ≤ D1BodySized.S47.tab.length) = true
theorem D1BodySized.fromTable20_13 : 20 ≤ D1BodySized.S47.tab.length := of_decide_eq_true D1BodySized.fromTable20Check13
kernel_rfl D1BodySized.bridgeInto13 : bridgeOf D1BodySized.s50.ffi = bridgeOf D1BodySized.s47.ffi
kernel_rfl D1BodySized.bridgeOut13 : bridgeOf D1BodySized.s51.ffi = bridgeOf D1BodySized.s50.ffi
kernel_rfl D1BodySized.sizeTable20Check13 : decide (20 ≤ D1BodySized.S50.tab.length) = true
theorem D1BodySized.sizeTable20_13 : 20 ≤ D1BodySized.S50.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check13
kernel_rfl D1BodySized.sizeOracle13 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S50.oracle = true

end Host.Load.Run.Tpl
end

section -- SP13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece13 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s47 D1BodySized.S47) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s51 D1BodySized.S51) 14854 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted13 D1BodySized.segment13 D1BodySized.acceptedP14
    D1BodySized.haltP14 D1BodySized.stepA14 D1BodySized.topA14
    D1BodySized.oracle13 D1BodySized.fromInactive13 D1BodySized.bridgeInto13 D1BodySized.fromTable20_13
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA14 D1BodySized.sizeArgsA14 D1BodySized.sizeSymA14
    D1BodySized.sizeMlxA14 D1BodySized.sizePayA14 (by decide)
    D1BodySized.sizeDecA14 D1BodySized.sizePreA14 D1BodySized.patchB14
    D1BodySized.sizeOracle13 D1BodySized.inactive14 D1BodySized.bridgeOut13 D1BodySized.sizeTable20_13
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive14 : (bridgeOf D1BodySized.s51.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check14 : decide (20 ≤ D1BodySized.S51.tab.length) = true
theorem D1BodySized.fromTable20_14 : 20 ≤ D1BodySized.S51.tab.length := of_decide_eq_true D1BodySized.fromTable20Check14
kernel_rfl D1BodySized.bridgeInto14 : bridgeOf D1BodySized.s53.ffi = bridgeOf D1BodySized.s51.ffi
kernel_rfl D1BodySized.bridgeOut14 : bridgeOf D1BodySized.s54.ffi = bridgeOf D1BodySized.s53.ffi
kernel_rfl D1BodySized.sizeTable20Check14 : decide (20 ≤ D1BodySized.S53.tab.length) = true
theorem D1BodySized.sizeTable20_14 : 20 ≤ D1BodySized.S53.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check14
kernel_rfl D1BodySized.sizeOracle14 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S53.oracle = true

end Host.Load.Run.Tpl
end

section -- SP14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece14 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s51 D1BodySized.S51) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s54 D1BodySized.S54) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted14 D1BodySized.segment14 D1BodySized.acceptedP15
    D1BodySized.haltP15 D1BodySized.stepA15 D1BodySized.topA15
    D1BodySized.oracle14 D1BodySized.fromInactive14 D1BodySized.bridgeInto14 D1BodySized.fromTable20_14
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA15 D1BodySized.sizeArgsA15 D1BodySized.sizeSymA15
    D1BodySized.sizeMlxA15 D1BodySized.sizePayA15 (by decide)
    D1BodySized.sizeDecA15 D1BodySized.sizePreA15 D1BodySized.patchB15
    D1BodySized.sizeOracle14 D1BodySized.inactive15 D1BodySized.bridgeOut14 D1BodySized.sizeTable20_14
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive15 : (bridgeOf D1BodySized.s54.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check15 : decide (20 ≤ D1BodySized.S54.tab.length) = true
theorem D1BodySized.fromTable20_15 : 20 ≤ D1BodySized.S54.tab.length := of_decide_eq_true D1BodySized.fromTable20Check15
kernel_rfl D1BodySized.bridgeInto15 : bridgeOf D1BodySized.s56.ffi = bridgeOf D1BodySized.s54.ffi
kernel_rfl D1BodySized.bridgeOut15 : bridgeOf D1BodySized.s57.ffi = bridgeOf D1BodySized.s56.ffi
kernel_rfl D1BodySized.sizeTable20Check15 : decide (20 ≤ D1BodySized.S56.tab.length) = true
theorem D1BodySized.sizeTable20_15 : 20 ≤ D1BodySized.S56.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check15
kernel_rfl D1BodySized.sizeOracle15 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S56.oracle = true

end Host.Load.Run.Tpl
end

section -- SP15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece15 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s54 D1BodySized.S54) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s57 D1BodySized.S57) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted15 D1BodySized.segment15 D1BodySized.acceptedP16
    D1BodySized.haltP16 D1BodySized.stepA16 D1BodySized.topA16
    D1BodySized.oracle15 D1BodySized.fromInactive15 D1BodySized.bridgeInto15 D1BodySized.fromTable20_15
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA16 D1BodySized.sizeArgsA16 D1BodySized.sizeSymA16
    D1BodySized.sizeMlxA16 D1BodySized.sizePayA16 (by decide)
    D1BodySized.sizeDecA16 D1BodySized.sizePreA16 D1BodySized.patchB16
    D1BodySized.sizeOracle15 D1BodySized.inactive16 D1BodySized.bridgeOut15 D1BodySized.sizeTable20_15
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive16 : (bridgeOf D1BodySized.s57.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check16 : decide (20 ≤ D1BodySized.S57.tab.length) = true
theorem D1BodySized.fromTable20_16 : 20 ≤ D1BodySized.S57.tab.length := of_decide_eq_true D1BodySized.fromTable20Check16
kernel_rfl D1BodySized.bridgeInto16 : bridgeOf D1BodySized.s60.ffi = bridgeOf D1BodySized.s57.ffi
kernel_rfl D1BodySized.bridgeOut16 : bridgeOf D1BodySized.s61.ffi = bridgeOf D1BodySized.s60.ffi
kernel_rfl D1BodySized.sizeTable20Check16 : decide (20 ≤ D1BodySized.S60.tab.length) = true
theorem D1BodySized.sizeTable20_16 : 20 ≤ D1BodySized.S60.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check16
kernel_rfl D1BodySized.sizeOracle16 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S60.oracle = true

end Host.Load.Run.Tpl
end

section -- SP16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece16 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s57 D1BodySized.S57) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s61 D1BodySized.S61) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted16 D1BodySized.segment16 D1BodySized.acceptedP17
    D1BodySized.haltP17 D1BodySized.stepA17 D1BodySized.topA17
    D1BodySized.oracle16 D1BodySized.fromInactive16 D1BodySized.bridgeInto16 D1BodySized.fromTable20_16
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA17 D1BodySized.sizeArgsA17 D1BodySized.sizeSymA17
    D1BodySized.sizeMlxA17 D1BodySized.sizePayA17 (by decide)
    D1BodySized.sizeDecA17 D1BodySized.sizePreA17 D1BodySized.patchB17
    D1BodySized.sizeOracle16 D1BodySized.inactive17 D1BodySized.bridgeOut16 D1BodySized.sizeTable20_16
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive17 : (bridgeOf D1BodySized.s61.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check17 : decide (20 ≤ D1BodySized.S61.tab.length) = true
theorem D1BodySized.fromTable20_17 : 20 ≤ D1BodySized.S61.tab.length := of_decide_eq_true D1BodySized.fromTable20Check17
kernel_rfl D1BodySized.bridgeInto17 : bridgeOf D1BodySized.s63.ffi = bridgeOf D1BodySized.s61.ffi
kernel_rfl D1BodySized.bridgeOut17 : bridgeOf D1BodySized.s64.ffi = bridgeOf D1BodySized.s63.ffi
kernel_rfl D1BodySized.sizeTable20Check17 : decide (20 ≤ D1BodySized.S63.tab.length) = true
theorem D1BodySized.sizeTable20_17 : 20 ≤ D1BodySized.S63.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check17
kernel_rfl D1BodySized.sizeOracle17 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S63.oracle = true

end Host.Load.Run.Tpl
end

section -- SP17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece17 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s61 D1BodySized.S61) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s64 D1BodySized.S64) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted17 D1BodySized.segment17 D1BodySized.acceptedP18
    D1BodySized.haltP18 D1BodySized.stepA18 D1BodySized.topA18
    D1BodySized.oracle17 D1BodySized.fromInactive17 D1BodySized.bridgeInto17 D1BodySized.fromTable20_17
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA18 D1BodySized.sizeArgsA18 D1BodySized.sizeSymA18
    D1BodySized.sizeMlxA18 D1BodySized.sizePayA18 (by decide)
    D1BodySized.sizeDecA18 D1BodySized.sizePreA18 D1BodySized.patchB18
    D1BodySized.sizeOracle17 D1BodySized.inactive18 D1BodySized.bridgeOut17 D1BodySized.sizeTable20_17
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive18 : (bridgeOf D1BodySized.s64.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check18 : decide (20 ≤ D1BodySized.S64.tab.length) = true
theorem D1BodySized.fromTable20_18 : 20 ≤ D1BodySized.S64.tab.length := of_decide_eq_true D1BodySized.fromTable20Check18
kernel_rfl D1BodySized.bridgeInto18 : bridgeOf D1BodySized.s68.ffi = bridgeOf D1BodySized.s64.ffi
kernel_rfl D1BodySized.bridgeOut18 : bridgeOf D1BodySized.s69.ffi = bridgeOf D1BodySized.s68.ffi
kernel_rfl D1BodySized.sizeTable20Check18 : decide (20 ≤ D1BodySized.S68.tab.length) = true
theorem D1BodySized.sizeTable20_18 : 20 ≤ D1BodySized.S68.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check18
kernel_rfl D1BodySized.sizeOracle18 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S68.oracle = true

end Host.Load.Run.Tpl
end

section -- SP18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece18 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s64 D1BodySized.S64) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s69 D1BodySized.S69) 22291 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted18 D1BodySized.segment18 D1BodySized.acceptedP19
    D1BodySized.haltP19 D1BodySized.stepA19 D1BodySized.topA19
    D1BodySized.oracle18 D1BodySized.fromInactive18 D1BodySized.bridgeInto18 D1BodySized.fromTable20_18
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA19 D1BodySized.sizeArgsA19 D1BodySized.sizeSymA19
    D1BodySized.sizeMlxA19 D1BodySized.sizePayA19 (by decide)
    D1BodySized.sizeDecA19 D1BodySized.sizePreA19 D1BodySized.patchB19
    D1BodySized.sizeOracle18 D1BodySized.inactive19 D1BodySized.bridgeOut18 D1BodySized.sizeTable20_18
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive19 : (bridgeOf D1BodySized.s69.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check19 : decide (20 ≤ D1BodySized.S69.tab.length) = true
theorem D1BodySized.fromTable20_19 : 20 ≤ D1BodySized.S69.tab.length := of_decide_eq_true D1BodySized.fromTable20Check19
kernel_rfl D1BodySized.bridgeInto19 : bridgeOf D1BodySized.s71.ffi = bridgeOf D1BodySized.s69.ffi
kernel_rfl D1BodySized.bridgeOut19 : bridgeOf D1BodySized.s72.ffi = bridgeOf D1BodySized.s71.ffi
kernel_rfl D1BodySized.sizeTable20Check19 : decide (20 ≤ D1BodySized.S71.tab.length) = true
theorem D1BodySized.sizeTable20_19 : 20 ≤ D1BodySized.S71.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check19
kernel_rfl D1BodySized.sizeOracle19 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S71.oracle = true

end Host.Load.Run.Tpl
end

section -- SP19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece19 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s69 D1BodySized.S69) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s72 D1BodySized.S72) 7938 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted19 D1BodySized.segment19 D1BodySized.acceptedP20
    D1BodySized.haltP20 D1BodySized.stepA20 D1BodySized.topA20
    D1BodySized.oracle19 D1BodySized.fromInactive19 D1BodySized.bridgeInto19 D1BodySized.fromTable20_19
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA20 D1BodySized.sizeArgsA20 D1BodySized.sizeSymA20
    D1BodySized.sizeMlxA20 D1BodySized.sizePayA20 (by decide)
    D1BodySized.sizeDecA20 D1BodySized.sizePreA20 D1BodySized.patchB20
    D1BodySized.sizeOracle19 D1BodySized.inactive20 D1BodySized.bridgeOut19 D1BodySized.sizeTable20_19
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive20 : (bridgeOf D1BodySized.s72.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check20 : decide (20 ≤ D1BodySized.S72.tab.length) = true
theorem D1BodySized.fromTable20_20 : 20 ≤ D1BodySized.S72.tab.length := of_decide_eq_true D1BodySized.fromTable20Check20
kernel_rfl D1BodySized.bridgeInto20 : bridgeOf D1BodySized.s74.ffi = bridgeOf D1BodySized.s72.ffi
kernel_rfl D1BodySized.bridgeOut20 : bridgeOf D1BodySized.s75.ffi = bridgeOf D1BodySized.s74.ffi
kernel_rfl D1BodySized.sizeTable20Check20 : decide (20 ≤ D1BodySized.S74.tab.length) = true
theorem D1BodySized.sizeTable20_20 : 20 ≤ D1BodySized.S74.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check20
kernel_rfl D1BodySized.sizeOracle20 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S74.oracle = true

end Host.Load.Run.Tpl
end

section -- SP20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece20 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s72 D1BodySized.S72) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s75 D1BodySized.S75) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted20 D1BodySized.segment20 D1BodySized.acceptedP21
    D1BodySized.haltP21 D1BodySized.stepA21 D1BodySized.topA21
    D1BodySized.oracle20 D1BodySized.fromInactive20 D1BodySized.bridgeInto20 D1BodySized.fromTable20_20
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA21 D1BodySized.sizeArgsA21 D1BodySized.sizeSymA21
    D1BodySized.sizeMlxA21 D1BodySized.sizePayA21 (by decide)
    D1BodySized.sizeDecA21 D1BodySized.sizePreA21 D1BodySized.patchB21
    D1BodySized.sizeOracle20 D1BodySized.inactive21 D1BodySized.bridgeOut20 D1BodySized.sizeTable20_20
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive21 : (bridgeOf D1BodySized.s75.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check21 : decide (20 ≤ D1BodySized.S75.tab.length) = true
theorem D1BodySized.fromTable20_21 : 20 ≤ D1BodySized.S75.tab.length := of_decide_eq_true D1BodySized.fromTable20Check21
kernel_rfl D1BodySized.bridgeInto21 : bridgeOf D1BodySized.s78.ffi = bridgeOf D1BodySized.s75.ffi
kernel_rfl D1BodySized.bridgeOut21 : bridgeOf D1BodySized.s79.ffi = bridgeOf D1BodySized.s78.ffi
kernel_rfl D1BodySized.sizeTable20Check21 : decide (20 ≤ D1BodySized.S78.tab.length) = true
theorem D1BodySized.sizeTable20_21 : 20 ≤ D1BodySized.S78.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check21
kernel_rfl D1BodySized.sizeOracle21 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S78.oracle = true

end Host.Load.Run.Tpl
end

section -- SP21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece21 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s75 D1BodySized.S75) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s79 D1BodySized.S79) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted21 D1BodySized.segment21 D1BodySized.acceptedP22
    D1BodySized.haltP22 D1BodySized.stepA22 D1BodySized.topA22
    D1BodySized.oracle21 D1BodySized.fromInactive21 D1BodySized.bridgeInto21 D1BodySized.fromTable20_21
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA22 D1BodySized.sizeArgsA22 D1BodySized.sizeSymA22
    D1BodySized.sizeMlxA22 D1BodySized.sizePayA22 (by decide)
    D1BodySized.sizeDecA22 D1BodySized.sizePreA22 D1BodySized.patchB22
    D1BodySized.sizeOracle21 D1BodySized.inactive22 D1BodySized.bridgeOut21 D1BodySized.sizeTable20_21
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive22 : (bridgeOf D1BodySized.s79.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check22 : decide (20 ≤ D1BodySized.S79.tab.length) = true
theorem D1BodySized.fromTable20_22 : 20 ≤ D1BodySized.S79.tab.length := of_decide_eq_true D1BodySized.fromTable20Check22
kernel_rfl D1BodySized.bridgeInto22 : bridgeOf D1BodySized.s81.ffi = bridgeOf D1BodySized.s79.ffi
kernel_rfl D1BodySized.bridgeOut22 : bridgeOf D1BodySized.s82.ffi = bridgeOf D1BodySized.s81.ffi
kernel_rfl D1BodySized.sizeTable20Check22 : decide (20 ≤ D1BodySized.S81.tab.length) = true
theorem D1BodySized.sizeTable20_22 : 20 ≤ D1BodySized.S81.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check22
kernel_rfl D1BodySized.sizeOracle22 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S81.oracle = true

end Host.Load.Run.Tpl
end

section -- SP22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece22 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s79 D1BodySized.S79) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s82 D1BodySized.S82) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted22 D1BodySized.segment22 D1BodySized.acceptedP23
    D1BodySized.haltP23 D1BodySized.stepA23 D1BodySized.topA23
    D1BodySized.oracle22 D1BodySized.fromInactive22 D1BodySized.bridgeInto22 D1BodySized.fromTable20_22
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA23 D1BodySized.sizeArgsA23 D1BodySized.sizeSymA23
    D1BodySized.sizeMlxA23 D1BodySized.sizePayA23 (by decide)
    D1BodySized.sizeDecA23 D1BodySized.sizePreA23 D1BodySized.patchB23
    D1BodySized.sizeOracle22 D1BodySized.inactive23 D1BodySized.bridgeOut22 D1BodySized.sizeTable20_22
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive23 : (bridgeOf D1BodySized.s82.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check23 : decide (20 ≤ D1BodySized.S82.tab.length) = true
theorem D1BodySized.fromTable20_23 : 20 ≤ D1BodySized.S82.tab.length := of_decide_eq_true D1BodySized.fromTable20Check23
kernel_rfl D1BodySized.bridgeInto23 : bridgeOf D1BodySized.s84.ffi = bridgeOf D1BodySized.s82.ffi
kernel_rfl D1BodySized.bridgeOut23 : bridgeOf D1BodySized.s85.ffi = bridgeOf D1BodySized.s84.ffi
kernel_rfl D1BodySized.sizeTable20Check23 : decide (20 ≤ D1BodySized.S84.tab.length) = true
theorem D1BodySized.sizeTable20_23 : 20 ≤ D1BodySized.S84.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check23
kernel_rfl D1BodySized.sizeOracle23 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S84.oracle = true

end Host.Load.Run.Tpl
end

section -- SP23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece23 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s82 D1BodySized.S82) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s85 D1BodySized.S85) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted23 D1BodySized.segment23 D1BodySized.acceptedP24
    D1BodySized.haltP24 D1BodySized.stepA24 D1BodySized.topA24
    D1BodySized.oracle23 D1BodySized.fromInactive23 D1BodySized.bridgeInto23 D1BodySized.fromTable20_23
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA24 D1BodySized.sizeArgsA24 D1BodySized.sizeSymA24
    D1BodySized.sizeMlxA24 D1BodySized.sizePayA24 (by decide)
    D1BodySized.sizeDecA24 D1BodySized.sizePreA24 D1BodySized.patchB24
    D1BodySized.sizeOracle23 D1BodySized.inactive24 D1BodySized.bridgeOut23 D1BodySized.sizeTable20_23
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive24 : (bridgeOf D1BodySized.s85.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check24 : decide (20 ≤ D1BodySized.S85.tab.length) = true
theorem D1BodySized.fromTable20_24 : 20 ≤ D1BodySized.S85.tab.length := of_decide_eq_true D1BodySized.fromTable20Check24
kernel_rfl D1BodySized.bridgeInto24 : bridgeOf D1BodySized.s87.ffi = bridgeOf D1BodySized.s85.ffi
kernel_rfl D1BodySized.bridgeOut24 : bridgeOf D1BodySized.s88.ffi = bridgeOf D1BodySized.s87.ffi
kernel_rfl D1BodySized.sizeTable20Check24 : decide (20 ≤ D1BodySized.S87.tab.length) = true
theorem D1BodySized.sizeTable20_24 : 20 ≤ D1BodySized.S87.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check24
kernel_rfl D1BodySized.sizeOracle24 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S87.oracle = true

end Host.Load.Run.Tpl
end

section -- SP24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece24 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s85 D1BodySized.S85) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s88 D1BodySized.S88) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted24 D1BodySized.segment24 D1BodySized.acceptedP25
    D1BodySized.haltP25 D1BodySized.stepA25 D1BodySized.topA25
    D1BodySized.oracle24 D1BodySized.fromInactive24 D1BodySized.bridgeInto24 D1BodySized.fromTable20_24
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA25 D1BodySized.sizeArgsA25 D1BodySized.sizeSymA25
    D1BodySized.sizeMlxA25 D1BodySized.sizePayA25 (by decide)
    D1BodySized.sizeDecA25 D1BodySized.sizePreA25 D1BodySized.patchB25
    D1BodySized.sizeOracle24 D1BodySized.inactive25 D1BodySized.bridgeOut24 D1BodySized.sizeTable20_24
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive25 : (bridgeOf D1BodySized.s88.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check25 : decide (20 ≤ D1BodySized.S88.tab.length) = true
theorem D1BodySized.fromTable20_25 : 20 ≤ D1BodySized.S88.tab.length := of_decide_eq_true D1BodySized.fromTable20Check25
kernel_rfl D1BodySized.bridgeInto25 : bridgeOf D1BodySized.s91.ffi = bridgeOf D1BodySized.s88.ffi
kernel_rfl D1BodySized.bridgeOut25 : bridgeOf D1BodySized.s92.ffi = bridgeOf D1BodySized.s91.ffi
kernel_rfl D1BodySized.sizeTable20Check25 : decide (20 ≤ D1BodySized.S91.tab.length) = true
theorem D1BodySized.sizeTable20_25 : 20 ≤ D1BodySized.S91.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check25
kernel_rfl D1BodySized.sizeOracle25 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S91.oracle = true

end Host.Load.Run.Tpl
end

section -- SP25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece25 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s88 D1BodySized.S88) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s92 D1BodySized.S92) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted25 D1BodySized.segment25 D1BodySized.acceptedP26
    D1BodySized.haltP26 D1BodySized.stepA26 D1BodySized.topA26
    D1BodySized.oracle25 D1BodySized.fromInactive25 D1BodySized.bridgeInto25 D1BodySized.fromTable20_25
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA26 D1BodySized.sizeArgsA26 D1BodySized.sizeSymA26
    D1BodySized.sizeMlxA26 D1BodySized.sizePayA26 (by decide)
    D1BodySized.sizeDecA26 D1BodySized.sizePreA26 D1BodySized.patchB26
    D1BodySized.sizeOracle25 D1BodySized.inactive26 D1BodySized.bridgeOut25 D1BodySized.sizeTable20_25
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive26 : (bridgeOf D1BodySized.s92.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check26 : decide (20 ≤ D1BodySized.S92.tab.length) = true
theorem D1BodySized.fromTable20_26 : 20 ≤ D1BodySized.S92.tab.length := of_decide_eq_true D1BodySized.fromTable20Check26
kernel_rfl D1BodySized.bridgeInto26 : bridgeOf D1BodySized.s94.ffi = bridgeOf D1BodySized.s92.ffi
kernel_rfl D1BodySized.bridgeOut26 : bridgeOf D1BodySized.s95.ffi = bridgeOf D1BodySized.s94.ffi
kernel_rfl D1BodySized.sizeTable20Check26 : decide (20 ≤ D1BodySized.S94.tab.length) = true
theorem D1BodySized.sizeTable20_26 : 20 ≤ D1BodySized.S94.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check26
kernel_rfl D1BodySized.sizeOracle26 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S94.oracle = true

end Host.Load.Run.Tpl
end

section -- SP26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece26 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s92 D1BodySized.S92) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s95 D1BodySized.S95) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted26 D1BodySized.segment26 D1BodySized.acceptedP27
    D1BodySized.haltP27 D1BodySized.stepA27 D1BodySized.topA27
    D1BodySized.oracle26 D1BodySized.fromInactive26 D1BodySized.bridgeInto26 D1BodySized.fromTable20_26
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA27 D1BodySized.sizeArgsA27 D1BodySized.sizeSymA27
    D1BodySized.sizeMlxA27 D1BodySized.sizePayA27 (by decide)
    D1BodySized.sizeDecA27 D1BodySized.sizePreA27 D1BodySized.patchB27
    D1BodySized.sizeOracle26 D1BodySized.inactive27 D1BodySized.bridgeOut26 D1BodySized.sizeTable20_26
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive27 : (bridgeOf D1BodySized.s95.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check27 : decide (20 ≤ D1BodySized.S95.tab.length) = true
theorem D1BodySized.fromTable20_27 : 20 ≤ D1BodySized.S95.tab.length := of_decide_eq_true D1BodySized.fromTable20Check27
kernel_rfl D1BodySized.bridgeInto27 : bridgeOf D1BodySized.s97.ffi = bridgeOf D1BodySized.s95.ffi
kernel_rfl D1BodySized.bridgeOut27 : bridgeOf D1BodySized.s98.ffi = bridgeOf D1BodySized.s97.ffi
kernel_rfl D1BodySized.sizeTable20Check27 : decide (20 ≤ D1BodySized.S97.tab.length) = true
theorem D1BodySized.sizeTable20_27 : 20 ≤ D1BodySized.S97.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check27
kernel_rfl D1BodySized.sizeOracle27 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S97.oracle = true

end Host.Load.Run.Tpl
end

section -- SP27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece27 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s95 D1BodySized.S95) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s98 D1BodySized.S98) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted27 D1BodySized.segment27 D1BodySized.acceptedP28
    D1BodySized.haltP28 D1BodySized.stepA28 D1BodySized.topA28
    D1BodySized.oracle27 D1BodySized.fromInactive27 D1BodySized.bridgeInto27 D1BodySized.fromTable20_27
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA28 D1BodySized.sizeArgsA28 D1BodySized.sizeSymA28
    D1BodySized.sizeMlxA28 D1BodySized.sizePayA28 (by decide)
    D1BodySized.sizeDecA28 D1BodySized.sizePreA28 D1BodySized.patchB28
    D1BodySized.sizeOracle27 D1BodySized.inactive28 D1BodySized.bridgeOut27 D1BodySized.sizeTable20_27
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive28 : (bridgeOf D1BodySized.s98.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check28 : decide (20 ≤ D1BodySized.S98.tab.length) = true
theorem D1BodySized.fromTable20_28 : 20 ≤ D1BodySized.S98.tab.length := of_decide_eq_true D1BodySized.fromTable20Check28
kernel_rfl D1BodySized.bridgeInto28 : bridgeOf D1BodySized.s100.ffi = bridgeOf D1BodySized.s98.ffi
kernel_rfl D1BodySized.bridgeOut28 : bridgeOf D1BodySized.s101.ffi = bridgeOf D1BodySized.s100.ffi
kernel_rfl D1BodySized.sizeTable20Check28 : decide (20 ≤ D1BodySized.S100.tab.length) = true
theorem D1BodySized.sizeTable20_28 : 20 ≤ D1BodySized.S100.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check28
kernel_rfl D1BodySized.sizeOracle28 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S100.oracle = true

end Host.Load.Run.Tpl
end

section -- SP28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece28 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s98 D1BodySized.S98) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s101 D1BodySized.S101) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted28 D1BodySized.segment28 D1BodySized.acceptedP29
    D1BodySized.haltP29 D1BodySized.stepA29 D1BodySized.topA29
    D1BodySized.oracle28 D1BodySized.fromInactive28 D1BodySized.bridgeInto28 D1BodySized.fromTable20_28
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA29 D1BodySized.sizeArgsA29 D1BodySized.sizeSymA29
    D1BodySized.sizeMlxA29 D1BodySized.sizePayA29 (by decide)
    D1BodySized.sizeDecA29 D1BodySized.sizePreA29 D1BodySized.patchB29
    D1BodySized.sizeOracle28 D1BodySized.inactive29 D1BodySized.bridgeOut28 D1BodySized.sizeTable20_28
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive29 : (bridgeOf D1BodySized.s101.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check29 : decide (20 ≤ D1BodySized.S101.tab.length) = true
theorem D1BodySized.fromTable20_29 : 20 ≤ D1BodySized.S101.tab.length := of_decide_eq_true D1BodySized.fromTable20Check29
kernel_rfl D1BodySized.bridgeInto29 : bridgeOf D1BodySized.s104.ffi = bridgeOf D1BodySized.s101.ffi
kernel_rfl D1BodySized.bridgeOut29 : bridgeOf D1BodySized.s105.ffi = bridgeOf D1BodySized.s104.ffi
kernel_rfl D1BodySized.sizeTable20Check29 : decide (20 ≤ D1BodySized.S104.tab.length) = true
theorem D1BodySized.sizeTable20_29 : 20 ≤ D1BodySized.S104.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check29
kernel_rfl D1BodySized.sizeOracle29 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S104.oracle = true

end Host.Load.Run.Tpl
end

section -- SP29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece29 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s101 D1BodySized.S101) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s105 D1BodySized.S105) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted29 D1BodySized.segment29 D1BodySized.acceptedP30
    D1BodySized.haltP30 D1BodySized.stepA30 D1BodySized.topA30
    D1BodySized.oracle29 D1BodySized.fromInactive29 D1BodySized.bridgeInto29 D1BodySized.fromTable20_29
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA30 D1BodySized.sizeArgsA30 D1BodySized.sizeSymA30
    D1BodySized.sizeMlxA30 D1BodySized.sizePayA30 (by decide)
    D1BodySized.sizeDecA30 D1BodySized.sizePreA30 D1BodySized.patchB30
    D1BodySized.sizeOracle29 D1BodySized.inactive30 D1BodySized.bridgeOut29 D1BodySized.sizeTable20_29
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive30 : (bridgeOf D1BodySized.s105.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check30 : decide (20 ≤ D1BodySized.S105.tab.length) = true
theorem D1BodySized.fromTable20_30 : 20 ≤ D1BodySized.S105.tab.length := of_decide_eq_true D1BodySized.fromTable20Check30
kernel_rfl D1BodySized.bridgeInto30 : bridgeOf D1BodySized.s107.ffi = bridgeOf D1BodySized.s105.ffi
kernel_rfl D1BodySized.bridgeOut30 : bridgeOf D1BodySized.s108.ffi = bridgeOf D1BodySized.s107.ffi
kernel_rfl D1BodySized.sizeTable20Check30 : decide (20 ≤ D1BodySized.S107.tab.length) = true
theorem D1BodySized.sizeTable20_30 : 20 ≤ D1BodySized.S107.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check30
kernel_rfl D1BodySized.sizeOracle30 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S107.oracle = true

end Host.Load.Run.Tpl
end

section -- SP30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece30 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s105 D1BodySized.S105) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s108 D1BodySized.S108) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted30 D1BodySized.segment30 D1BodySized.acceptedP31
    D1BodySized.haltP31 D1BodySized.stepA31 D1BodySized.topA31
    D1BodySized.oracle30 D1BodySized.fromInactive30 D1BodySized.bridgeInto30 D1BodySized.fromTable20_30
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA31 D1BodySized.sizeArgsA31 D1BodySized.sizeSymA31
    D1BodySized.sizeMlxA31 D1BodySized.sizePayA31 (by decide)
    D1BodySized.sizeDecA31 D1BodySized.sizePreA31 D1BodySized.patchB31
    D1BodySized.sizeOracle30 D1BodySized.inactive31 D1BodySized.bridgeOut30 D1BodySized.sizeTable20_30
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive31 : (bridgeOf D1BodySized.s108.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check31 : decide (20 ≤ D1BodySized.S108.tab.length) = true
theorem D1BodySized.fromTable20_31 : 20 ≤ D1BodySized.S108.tab.length := of_decide_eq_true D1BodySized.fromTable20Check31
kernel_rfl D1BodySized.bridgeInto31 : bridgeOf D1BodySized.s112.ffi = bridgeOf D1BodySized.s108.ffi
kernel_rfl D1BodySized.bridgeOut31 : bridgeOf D1BodySized.s113.ffi = bridgeOf D1BodySized.s112.ffi
kernel_rfl D1BodySized.sizeTable20Check31 : decide (20 ≤ D1BodySized.S112.tab.length) = true
theorem D1BodySized.sizeTable20_31 : 20 ≤ D1BodySized.S112.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check31
kernel_rfl D1BodySized.sizeOracle31 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S112.oracle = true

end Host.Load.Run.Tpl
end

section -- SP31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece31 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s108 D1BodySized.S108) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s113 D1BodySized.S113) 22291 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted31 D1BodySized.segment31 D1BodySized.acceptedP32
    D1BodySized.haltP32 D1BodySized.stepA32 D1BodySized.topA32
    D1BodySized.oracle31 D1BodySized.fromInactive31 D1BodySized.bridgeInto31 D1BodySized.fromTable20_31
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA32 D1BodySized.sizeArgsA32 D1BodySized.sizeSymA32
    D1BodySized.sizeMlxA32 D1BodySized.sizePayA32 (by decide)
    D1BodySized.sizeDecA32 D1BodySized.sizePreA32 D1BodySized.patchB32
    D1BodySized.sizeOracle31 D1BodySized.inactive32 D1BodySized.bridgeOut31 D1BodySized.sizeTable20_31
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive32 : (bridgeOf D1BodySized.s113.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check32 : decide (20 ≤ D1BodySized.S113.tab.length) = true
theorem D1BodySized.fromTable20_32 : 20 ≤ D1BodySized.S113.tab.length := of_decide_eq_true D1BodySized.fromTable20Check32
kernel_rfl D1BodySized.bridgeInto32 : bridgeOf D1BodySized.s115.ffi = bridgeOf D1BodySized.s113.ffi
kernel_rfl D1BodySized.bridgeOut32 : bridgeOf D1BodySized.s116.ffi = bridgeOf D1BodySized.s115.ffi
kernel_rfl D1BodySized.sizeTable20Check32 : decide (20 ≤ D1BodySized.S115.tab.length) = true
theorem D1BodySized.sizeTable20_32 : 20 ≤ D1BodySized.S115.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check32
kernel_rfl D1BodySized.sizeOracle32 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S115.oracle = true

end Host.Load.Run.Tpl
end

section -- SP32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece32 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s113 D1BodySized.S113) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s116 D1BodySized.S116) 7984 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted32 D1BodySized.segment32 D1BodySized.acceptedP33
    D1BodySized.haltP33 D1BodySized.stepA33 D1BodySized.topA33
    D1BodySized.oracle32 D1BodySized.fromInactive32 D1BodySized.bridgeInto32 D1BodySized.fromTable20_32
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA33 D1BodySized.sizeArgsA33 D1BodySized.sizeSymA33
    D1BodySized.sizeMlxA33 D1BodySized.sizePayA33 (by decide)
    D1BodySized.sizeDecA33 D1BodySized.sizePreA33 D1BodySized.patchB33
    D1BodySized.sizeOracle32 D1BodySized.inactive33 D1BodySized.bridgeOut32 D1BodySized.sizeTable20_32
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive33 : (bridgeOf D1BodySized.s116.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check33 : decide (20 ≤ D1BodySized.S116.tab.length) = true
theorem D1BodySized.fromTable20_33 : 20 ≤ D1BodySized.S116.tab.length := of_decide_eq_true D1BodySized.fromTable20Check33
kernel_rfl D1BodySized.bridgeInto33 : bridgeOf D1BodySized.s118.ffi = bridgeOf D1BodySized.s116.ffi
kernel_rfl D1BodySized.bridgeOut33 : bridgeOf D1BodySized.s119.ffi = bridgeOf D1BodySized.s118.ffi
kernel_rfl D1BodySized.sizeTable20Check33 : decide (20 ≤ D1BodySized.S118.tab.length) = true
theorem D1BodySized.sizeTable20_33 : 20 ≤ D1BodySized.S118.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check33
kernel_rfl D1BodySized.sizeOracle33 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S118.oracle = true

end Host.Load.Run.Tpl
end

section -- SP33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece33 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s116 D1BodySized.S116) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s119 D1BodySized.S119) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted33 D1BodySized.segment33 D1BodySized.acceptedP34
    D1BodySized.haltP34 D1BodySized.stepA34 D1BodySized.topA34
    D1BodySized.oracle33 D1BodySized.fromInactive33 D1BodySized.bridgeInto33 D1BodySized.fromTable20_33
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA34 D1BodySized.sizeArgsA34 D1BodySized.sizeSymA34
    D1BodySized.sizeMlxA34 D1BodySized.sizePayA34 (by decide)
    D1BodySized.sizeDecA34 D1BodySized.sizePreA34 D1BodySized.patchB34
    D1BodySized.sizeOracle33 D1BodySized.inactive34 D1BodySized.bridgeOut33 D1BodySized.sizeTable20_33
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ34
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive34 : (bridgeOf D1BodySized.s119.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check34 : decide (20 ≤ D1BodySized.S119.tab.length) = true
theorem D1BodySized.fromTable20_34 : 20 ≤ D1BodySized.S119.tab.length := of_decide_eq_true D1BodySized.fromTable20Check34
kernel_rfl D1BodySized.bridgeInto34 : bridgeOf D1BodySized.s122.ffi = bridgeOf D1BodySized.s119.ffi
kernel_rfl D1BodySized.bridgeOut34 : bridgeOf D1BodySized.s123.ffi = bridgeOf D1BodySized.s122.ffi
kernel_rfl D1BodySized.sizeTable20Check34 : decide (20 ≤ D1BodySized.S122.tab.length) = true
theorem D1BodySized.sizeTable20_34 : 20 ≤ D1BodySized.S122.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check34
kernel_rfl D1BodySized.sizeOracle34 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S122.oracle = true

end Host.Load.Run.Tpl
end

section -- SP34
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece34 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s119 D1BodySized.S119) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s123 D1BodySized.S123) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted34 D1BodySized.segment34 D1BodySized.acceptedP35
    D1BodySized.haltP35 D1BodySized.stepA35 D1BodySized.topA35
    D1BodySized.oracle34 D1BodySized.fromInactive34 D1BodySized.bridgeInto34 D1BodySized.fromTable20_34
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA35 D1BodySized.sizeArgsA35 D1BodySized.sizeSymA35
    D1BodySized.sizeMlxA35 D1BodySized.sizePayA35 (by decide)
    D1BodySized.sizeDecA35 D1BodySized.sizePreA35 D1BodySized.patchB35
    D1BodySized.sizeOracle34 D1BodySized.inactive35 D1BodySized.bridgeOut34 D1BodySized.sizeTable20_34
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ35
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive35 : (bridgeOf D1BodySized.s123.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check35 : decide (20 ≤ D1BodySized.S123.tab.length) = true
theorem D1BodySized.fromTable20_35 : 20 ≤ D1BodySized.S123.tab.length := of_decide_eq_true D1BodySized.fromTable20Check35
kernel_rfl D1BodySized.bridgeInto35 : bridgeOf D1BodySized.s125.ffi = bridgeOf D1BodySized.s123.ffi
kernel_rfl D1BodySized.bridgeOut35 : bridgeOf D1BodySized.s126.ffi = bridgeOf D1BodySized.s125.ffi
kernel_rfl D1BodySized.sizeTable20Check35 : decide (20 ≤ D1BodySized.S125.tab.length) = true
theorem D1BodySized.sizeTable20_35 : 20 ≤ D1BodySized.S125.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check35
kernel_rfl D1BodySized.sizeOracle35 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S125.oracle = true

end Host.Load.Run.Tpl
end

section -- SP35
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece35 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s123 D1BodySized.S123) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s126 D1BodySized.S126) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted35 D1BodySized.segment35 D1BodySized.acceptedP36
    D1BodySized.haltP36 D1BodySized.stepA36 D1BodySized.topA36
    D1BodySized.oracle35 D1BodySized.fromInactive35 D1BodySized.bridgeInto35 D1BodySized.fromTable20_35
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA36 D1BodySized.sizeArgsA36 D1BodySized.sizeSymA36
    D1BodySized.sizeMlxA36 D1BodySized.sizePayA36 (by decide)
    D1BodySized.sizeDecA36 D1BodySized.sizePreA36 D1BodySized.patchB36
    D1BodySized.sizeOracle35 D1BodySized.inactive36 D1BodySized.bridgeOut35 D1BodySized.sizeTable20_35
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ36
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive36 : (bridgeOf D1BodySized.s126.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check36 : decide (20 ≤ D1BodySized.S126.tab.length) = true
theorem D1BodySized.fromTable20_36 : 20 ≤ D1BodySized.S126.tab.length := of_decide_eq_true D1BodySized.fromTable20Check36
kernel_rfl D1BodySized.bridgeInto36 : bridgeOf D1BodySized.s128.ffi = bridgeOf D1BodySized.s126.ffi
kernel_rfl D1BodySized.bridgeOut36 : bridgeOf D1BodySized.s129.ffi = bridgeOf D1BodySized.s128.ffi
kernel_rfl D1BodySized.sizeTable20Check36 : decide (20 ≤ D1BodySized.S128.tab.length) = true
theorem D1BodySized.sizeTable20_36 : 20 ≤ D1BodySized.S128.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check36
kernel_rfl D1BodySized.sizeOracle36 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S128.oracle = true

end Host.Load.Run.Tpl
end

section -- SP36
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece36 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s126 D1BodySized.S126) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s129 D1BodySized.S129) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted36 D1BodySized.segment36 D1BodySized.acceptedP37
    D1BodySized.haltP37 D1BodySized.stepA37 D1BodySized.topA37
    D1BodySized.oracle36 D1BodySized.fromInactive36 D1BodySized.bridgeInto36 D1BodySized.fromTable20_36
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA37 D1BodySized.sizeArgsA37 D1BodySized.sizeSymA37
    D1BodySized.sizeMlxA37 D1BodySized.sizePayA37 (by decide)
    D1BodySized.sizeDecA37 D1BodySized.sizePreA37 D1BodySized.patchB37
    D1BodySized.sizeOracle36 D1BodySized.inactive37 D1BodySized.bridgeOut36 D1BodySized.sizeTable20_36
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ37
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive37 : (bridgeOf D1BodySized.s129.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check37 : decide (20 ≤ D1BodySized.S129.tab.length) = true
theorem D1BodySized.fromTable20_37 : 20 ≤ D1BodySized.S129.tab.length := of_decide_eq_true D1BodySized.fromTable20Check37
kernel_rfl D1BodySized.bridgeInto37 : bridgeOf D1BodySized.s131.ffi = bridgeOf D1BodySized.s129.ffi
kernel_rfl D1BodySized.bridgeOut37 : bridgeOf D1BodySized.s132.ffi = bridgeOf D1BodySized.s131.ffi
kernel_rfl D1BodySized.sizeTable20Check37 : decide (20 ≤ D1BodySized.S131.tab.length) = true
theorem D1BodySized.sizeTable20_37 : 20 ≤ D1BodySized.S131.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check37
kernel_rfl D1BodySized.sizeOracle37 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S131.oracle = true

end Host.Load.Run.Tpl
end

section -- SP37
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece37 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s129 D1BodySized.S129) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s132 D1BodySized.S132) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted37 D1BodySized.segment37 D1BodySized.acceptedP38
    D1BodySized.haltP38 D1BodySized.stepA38 D1BodySized.topA38
    D1BodySized.oracle37 D1BodySized.fromInactive37 D1BodySized.bridgeInto37 D1BodySized.fromTable20_37
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA38 D1BodySized.sizeArgsA38 D1BodySized.sizeSymA38
    D1BodySized.sizeMlxA38 D1BodySized.sizePayA38 (by decide)
    D1BodySized.sizeDecA38 D1BodySized.sizePreA38 D1BodySized.patchB38
    D1BodySized.sizeOracle37 D1BodySized.inactive38 D1BodySized.bridgeOut37 D1BodySized.sizeTable20_37
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ38
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive38 : (bridgeOf D1BodySized.s132.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check38 : decide (20 ≤ D1BodySized.S132.tab.length) = true
theorem D1BodySized.fromTable20_38 : 20 ≤ D1BodySized.S132.tab.length := of_decide_eq_true D1BodySized.fromTable20Check38
kernel_rfl D1BodySized.bridgeInto38 : bridgeOf D1BodySized.s135.ffi = bridgeOf D1BodySized.s132.ffi
kernel_rfl D1BodySized.bridgeOut38 : bridgeOf D1BodySized.s136.ffi = bridgeOf D1BodySized.s135.ffi
kernel_rfl D1BodySized.sizeTable20Check38 : decide (20 ≤ D1BodySized.S135.tab.length) = true
theorem D1BodySized.sizeTable20_38 : 20 ≤ D1BodySized.S135.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check38
kernel_rfl D1BodySized.sizeOracle38 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S135.oracle = true

end Host.Load.Run.Tpl
end

section -- SP38
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece38 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s132 D1BodySized.S132) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s136 D1BodySized.S136) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted38 D1BodySized.segment38 D1BodySized.acceptedP39
    D1BodySized.haltP39 D1BodySized.stepA39 D1BodySized.topA39
    D1BodySized.oracle38 D1BodySized.fromInactive38 D1BodySized.bridgeInto38 D1BodySized.fromTable20_38
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA39 D1BodySized.sizeArgsA39 D1BodySized.sizeSymA39
    D1BodySized.sizeMlxA39 D1BodySized.sizePayA39 (by decide)
    D1BodySized.sizeDecA39 D1BodySized.sizePreA39 D1BodySized.patchB39
    D1BodySized.sizeOracle38 D1BodySized.inactive39 D1BodySized.bridgeOut38 D1BodySized.sizeTable20_38
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ39
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive39 : (bridgeOf D1BodySized.s136.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check39 : decide (20 ≤ D1BodySized.S136.tab.length) = true
theorem D1BodySized.fromTable20_39 : 20 ≤ D1BodySized.S136.tab.length := of_decide_eq_true D1BodySized.fromTable20Check39
kernel_rfl D1BodySized.bridgeInto39 : bridgeOf D1BodySized.s138.ffi = bridgeOf D1BodySized.s136.ffi
kernel_rfl D1BodySized.bridgeOut39 : bridgeOf D1BodySized.s139.ffi = bridgeOf D1BodySized.s138.ffi
kernel_rfl D1BodySized.sizeTable20Check39 : decide (20 ≤ D1BodySized.S138.tab.length) = true
theorem D1BodySized.sizeTable20_39 : 20 ≤ D1BodySized.S138.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check39
kernel_rfl D1BodySized.sizeOracle39 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S138.oracle = true

end Host.Load.Run.Tpl
end

section -- SP39
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece39 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s136 D1BodySized.S136) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s139 D1BodySized.S139) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted39 D1BodySized.segment39 D1BodySized.acceptedP40
    D1BodySized.haltP40 D1BodySized.stepA40 D1BodySized.topA40
    D1BodySized.oracle39 D1BodySized.fromInactive39 D1BodySized.bridgeInto39 D1BodySized.fromTable20_39
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA40 D1BodySized.sizeArgsA40 D1BodySized.sizeSymA40
    D1BodySized.sizeMlxA40 D1BodySized.sizePayA40 (by decide)
    D1BodySized.sizeDecA40 D1BodySized.sizePreA40 D1BodySized.patchB40
    D1BodySized.sizeOracle39 D1BodySized.inactive40 D1BodySized.bridgeOut39 D1BodySized.sizeTable20_39
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive40 : (bridgeOf D1BodySized.s139.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check40 : decide (20 ≤ D1BodySized.S139.tab.length) = true
theorem D1BodySized.fromTable20_40 : 20 ≤ D1BodySized.S139.tab.length := of_decide_eq_true D1BodySized.fromTable20Check40
kernel_rfl D1BodySized.bridgeInto40 : bridgeOf D1BodySized.s141.ffi = bridgeOf D1BodySized.s139.ffi
kernel_rfl D1BodySized.bridgeOut40 : bridgeOf D1BodySized.s142.ffi = bridgeOf D1BodySized.s141.ffi
kernel_rfl D1BodySized.sizeTable20Check40 : decide (20 ≤ D1BodySized.S141.tab.length) = true
theorem D1BodySized.sizeTable20_40 : 20 ≤ D1BodySized.S141.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check40
kernel_rfl D1BodySized.sizeOracle40 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S141.oracle = true

end Host.Load.Run.Tpl
end

section -- SP40
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece40 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s139 D1BodySized.S139) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s142 D1BodySized.S142) 7766 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted40 D1BodySized.segment40 D1BodySized.acceptedP41
    D1BodySized.haltP41 D1BodySized.stepA41 D1BodySized.topA41
    D1BodySized.oracle40 D1BodySized.fromInactive40 D1BodySized.bridgeInto40 D1BodySized.fromTable20_40
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA41 D1BodySized.sizeArgsA41 D1BodySized.sizeSymA41
    D1BodySized.sizeMlxA41 D1BodySized.sizePayA41 (by decide)
    D1BodySized.sizeDecA41 D1BodySized.sizePreA41 D1BodySized.patchB41
    D1BodySized.sizeOracle40 D1BodySized.inactive41 D1BodySized.bridgeOut40 D1BodySized.sizeTable20_40
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive41 : (bridgeOf D1BodySized.s142.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check41 : decide (20 ≤ D1BodySized.S142.tab.length) = true
theorem D1BodySized.fromTable20_41 : 20 ≤ D1BodySized.S142.tab.length := of_decide_eq_true D1BodySized.fromTable20Check41
kernel_rfl D1BodySized.bridgeInto41 : bridgeOf D1BodySized.s144.ffi = bridgeOf D1BodySized.s142.ffi
kernel_rfl D1BodySized.bridgeOut41 : bridgeOf D1BodySized.s145.ffi = bridgeOf D1BodySized.s144.ffi
kernel_rfl D1BodySized.sizeTable20Check41 : decide (20 ≤ D1BodySized.S144.tab.length) = true
theorem D1BodySized.sizeTable20_41 : 20 ≤ D1BodySized.S144.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check41
kernel_rfl D1BodySized.sizeOracle41 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S144.oracle = true

end Host.Load.Run.Tpl
end

section -- SP41
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece41 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s142 D1BodySized.S142) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s145 D1BodySized.S145) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted41 D1BodySized.segment41 D1BodySized.acceptedP42
    D1BodySized.haltP42 D1BodySized.stepA42 D1BodySized.topA42
    D1BodySized.oracle41 D1BodySized.fromInactive41 D1BodySized.bridgeInto41 D1BodySized.fromTable20_41
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA42 D1BodySized.sizeArgsA42 D1BodySized.sizeSymA42
    D1BodySized.sizeMlxA42 D1BodySized.sizePayA42 (by decide)
    D1BodySized.sizeDecA42 D1BodySized.sizePreA42 D1BodySized.patchB42
    D1BodySized.sizeOracle41 D1BodySized.inactive42 D1BodySized.bridgeOut41 D1BodySized.sizeTable20_41
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ42
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive42 : (bridgeOf D1BodySized.s145.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check42 : decide (20 ≤ D1BodySized.S145.tab.length) = true
theorem D1BodySized.fromTable20_42 : 20 ≤ D1BodySized.S145.tab.length := of_decide_eq_true D1BodySized.fromTable20Check42
kernel_rfl D1BodySized.bridgeInto42 : bridgeOf D1BodySized.s148.ffi = bridgeOf D1BodySized.s145.ffi
kernel_rfl D1BodySized.bridgeOut42 : bridgeOf D1BodySized.s149.ffi = bridgeOf D1BodySized.s148.ffi
kernel_rfl D1BodySized.sizeTable20Check42 : decide (20 ≤ D1BodySized.S148.tab.length) = true
theorem D1BodySized.sizeTable20_42 : 20 ≤ D1BodySized.S148.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check42
kernel_rfl D1BodySized.sizeOracle42 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S148.oracle = true

end Host.Load.Run.Tpl
end

section -- SP42
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece42 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s145 D1BodySized.S145) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s149 D1BodySized.S149) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted42 D1BodySized.segment42 D1BodySized.acceptedP43
    D1BodySized.haltP43 D1BodySized.stepA43 D1BodySized.topA43
    D1BodySized.oracle42 D1BodySized.fromInactive42 D1BodySized.bridgeInto42 D1BodySized.fromTable20_42
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA43 D1BodySized.sizeArgsA43 D1BodySized.sizeSymA43
    D1BodySized.sizeMlxA43 D1BodySized.sizePayA43 (by decide)
    D1BodySized.sizeDecA43 D1BodySized.sizePreA43 D1BodySized.patchB43
    D1BodySized.sizeOracle42 D1BodySized.inactive43 D1BodySized.bridgeOut42 D1BodySized.sizeTable20_42
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ43
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive43 : (bridgeOf D1BodySized.s149.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check43 : decide (20 ≤ D1BodySized.S149.tab.length) = true
theorem D1BodySized.fromTable20_43 : 20 ≤ D1BodySized.S149.tab.length := of_decide_eq_true D1BodySized.fromTable20Check43
kernel_rfl D1BodySized.bridgeInto43 : bridgeOf D1BodySized.s151.ffi = bridgeOf D1BodySized.s149.ffi
kernel_rfl D1BodySized.bridgeOut43 : bridgeOf D1BodySized.s152.ffi = bridgeOf D1BodySized.s151.ffi
kernel_rfl D1BodySized.sizeTable20Check43 : decide (20 ≤ D1BodySized.S151.tab.length) = true
theorem D1BodySized.sizeTable20_43 : 20 ≤ D1BodySized.S151.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check43
kernel_rfl D1BodySized.sizeOracle43 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S151.oracle = true

end Host.Load.Run.Tpl
end

section -- SP43
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece43 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s149 D1BodySized.S149) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s152 D1BodySized.S152) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted43 D1BodySized.segment43 D1BodySized.acceptedP44
    D1BodySized.haltP44 D1BodySized.stepA44 D1BodySized.topA44
    D1BodySized.oracle43 D1BodySized.fromInactive43 D1BodySized.bridgeInto43 D1BodySized.fromTable20_43
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA44 D1BodySized.sizeArgsA44 D1BodySized.sizeSymA44
    D1BodySized.sizeMlxA44 D1BodySized.sizePayA44 (by decide)
    D1BodySized.sizeDecA44 D1BodySized.sizePreA44 D1BodySized.patchB44
    D1BodySized.sizeOracle43 D1BodySized.inactive44 D1BodySized.bridgeOut43 D1BodySized.sizeTable20_43
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive44 : (bridgeOf D1BodySized.s152.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check44 : decide (20 ≤ D1BodySized.S152.tab.length) = true
theorem D1BodySized.fromTable20_44 : 20 ≤ D1BodySized.S152.tab.length := of_decide_eq_true D1BodySized.fromTable20Check44
kernel_rfl D1BodySized.bridgeInto44 : bridgeOf D1BodySized.s156.ffi = bridgeOf D1BodySized.s152.ffi
kernel_rfl D1BodySized.bridgeOut44 : bridgeOf D1BodySized.s157.ffi = bridgeOf D1BodySized.s156.ffi
kernel_rfl D1BodySized.sizeTable20Check44 : decide (20 ≤ D1BodySized.S156.tab.length) = true
theorem D1BodySized.sizeTable20_44 : 20 ≤ D1BodySized.S156.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check44
kernel_rfl D1BodySized.sizeOracle44 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S156.oracle = true

end Host.Load.Run.Tpl
end

section -- SP44
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece44 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s152 D1BodySized.S152) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s157 D1BodySized.S157) 22291 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted44 D1BodySized.segment44 D1BodySized.acceptedP45
    D1BodySized.haltP45 D1BodySized.stepA45 D1BodySized.topA45
    D1BodySized.oracle44 D1BodySized.fromInactive44 D1BodySized.bridgeInto44 D1BodySized.fromTable20_44
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA45 D1BodySized.sizeArgsA45 D1BodySized.sizeSymA45
    D1BodySized.sizeMlxA45 D1BodySized.sizePayA45 (by decide)
    D1BodySized.sizeDecA45 D1BodySized.sizePreA45 D1BodySized.patchB45
    D1BodySized.sizeOracle44 D1BodySized.inactive45 D1BodySized.bridgeOut44 D1BodySized.sizeTable20_44
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ45
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive45 : (bridgeOf D1BodySized.s157.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check45 : decide (20 ≤ D1BodySized.S157.tab.length) = true
theorem D1BodySized.fromTable20_45 : 20 ≤ D1BodySized.S157.tab.length := of_decide_eq_true D1BodySized.fromTable20Check45
kernel_rfl D1BodySized.bridgeInto45 : bridgeOf D1BodySized.s159.ffi = bridgeOf D1BodySized.s157.ffi
kernel_rfl D1BodySized.bridgeOut45 : bridgeOf D1BodySized.s160.ffi = bridgeOf D1BodySized.s159.ffi
kernel_rfl D1BodySized.sizeTable20Check45 : decide (20 ≤ D1BodySized.S159.tab.length) = true
theorem D1BodySized.sizeTable20_45 : 20 ≤ D1BodySized.S159.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check45
kernel_rfl D1BodySized.sizeOracle45 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S159.oracle = true

end Host.Load.Run.Tpl
end

section -- SP45
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece45 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s157 D1BodySized.S157) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s160 D1BodySized.S160) 7989 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted45 D1BodySized.segment45 D1BodySized.acceptedP46
    D1BodySized.haltP46 D1BodySized.stepA46 D1BodySized.topA46
    D1BodySized.oracle45 D1BodySized.fromInactive45 D1BodySized.bridgeInto45 D1BodySized.fromTable20_45
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA46 D1BodySized.sizeArgsA46 D1BodySized.sizeSymA46
    D1BodySized.sizeMlxA46 D1BodySized.sizePayA46 (by decide)
    D1BodySized.sizeDecA46 D1BodySized.sizePreA46 D1BodySized.patchB46
    D1BodySized.sizeOracle45 D1BodySized.inactive46 D1BodySized.bridgeOut45 D1BodySized.sizeTable20_45
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive46 : (bridgeOf D1BodySized.s160.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check46 : decide (20 ≤ D1BodySized.S160.tab.length) = true
theorem D1BodySized.fromTable20_46 : 20 ≤ D1BodySized.S160.tab.length := of_decide_eq_true D1BodySized.fromTable20Check46
kernel_rfl D1BodySized.bridgeInto46 : bridgeOf D1BodySized.s162.ffi = bridgeOf D1BodySized.s160.ffi
kernel_rfl D1BodySized.bridgeOut46 : bridgeOf D1BodySized.s163.ffi = bridgeOf D1BodySized.s162.ffi
kernel_rfl D1BodySized.sizeTable20Check46 : decide (20 ≤ D1BodySized.S162.tab.length) = true
theorem D1BodySized.sizeTable20_46 : 20 ≤ D1BodySized.S162.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check46
kernel_rfl D1BodySized.sizeOracle46 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S162.oracle = true

end Host.Load.Run.Tpl
end

section -- SP46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece46 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s160 D1BodySized.S160) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s163 D1BodySized.S163) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted46 D1BodySized.segment46 D1BodySized.acceptedP47
    D1BodySized.haltP47 D1BodySized.stepA47 D1BodySized.topA47
    D1BodySized.oracle46 D1BodySized.fromInactive46 D1BodySized.bridgeInto46 D1BodySized.fromTable20_46
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA47 D1BodySized.sizeArgsA47 D1BodySized.sizeSymA47
    D1BodySized.sizeMlxA47 D1BodySized.sizePayA47 (by decide)
    D1BodySized.sizeDecA47 D1BodySized.sizePreA47 D1BodySized.patchB47
    D1BodySized.sizeOracle46 D1BodySized.inactive47 D1BodySized.bridgeOut46 D1BodySized.sizeTable20_46
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive47 : (bridgeOf D1BodySized.s163.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check47 : decide (20 ≤ D1BodySized.S163.tab.length) = true
theorem D1BodySized.fromTable20_47 : 20 ≤ D1BodySized.S163.tab.length := of_decide_eq_true D1BodySized.fromTable20Check47
kernel_rfl D1BodySized.bridgeInto47 : bridgeOf D1BodySized.s166.ffi = bridgeOf D1BodySized.s163.ffi
kernel_rfl D1BodySized.bridgeOut47 : bridgeOf D1BodySized.s167.ffi = bridgeOf D1BodySized.s166.ffi
kernel_rfl D1BodySized.sizeTable20Check47 : decide (20 ≤ D1BodySized.S166.tab.length) = true
theorem D1BodySized.sizeTable20_47 : 20 ≤ D1BodySized.S166.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check47
kernel_rfl D1BodySized.sizeOracle47 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S166.oracle = true

end Host.Load.Run.Tpl
end

section -- SP47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece47 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s163 D1BodySized.S163) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s167 D1BodySized.S167) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted47 D1BodySized.segment47 D1BodySized.acceptedP48
    D1BodySized.haltP48 D1BodySized.stepA48 D1BodySized.topA48
    D1BodySized.oracle47 D1BodySized.fromInactive47 D1BodySized.bridgeInto47 D1BodySized.fromTable20_47
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA48 D1BodySized.sizeArgsA48 D1BodySized.sizeSymA48
    D1BodySized.sizeMlxA48 D1BodySized.sizePayA48 (by decide)
    D1BodySized.sizeDecA48 D1BodySized.sizePreA48 D1BodySized.patchB48
    D1BodySized.sizeOracle47 D1BodySized.inactive48 D1BodySized.bridgeOut47 D1BodySized.sizeTable20_47
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive48 : (bridgeOf D1BodySized.s167.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check48 : decide (20 ≤ D1BodySized.S167.tab.length) = true
theorem D1BodySized.fromTable20_48 : 20 ≤ D1BodySized.S167.tab.length := of_decide_eq_true D1BodySized.fromTable20Check48
kernel_rfl D1BodySized.bridgeInto48 : bridgeOf D1BodySized.s169.ffi = bridgeOf D1BodySized.s167.ffi
kernel_rfl D1BodySized.bridgeOut48 : bridgeOf D1BodySized.s170.ffi = bridgeOf D1BodySized.s169.ffi
kernel_rfl D1BodySized.sizeTable20Check48 : decide (20 ≤ D1BodySized.S169.tab.length) = true
theorem D1BodySized.sizeTable20_48 : 20 ≤ D1BodySized.S169.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check48
kernel_rfl D1BodySized.sizeOracle48 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S169.oracle = true

end Host.Load.Run.Tpl
end

section -- SP48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece48 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s167 D1BodySized.S167) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s170 D1BodySized.S170) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted48 D1BodySized.segment48 D1BodySized.acceptedP49
    D1BodySized.haltP49 D1BodySized.stepA49 D1BodySized.topA49
    D1BodySized.oracle48 D1BodySized.fromInactive48 D1BodySized.bridgeInto48 D1BodySized.fromTable20_48
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA49 D1BodySized.sizeArgsA49 D1BodySized.sizeSymA49
    D1BodySized.sizeMlxA49 D1BodySized.sizePayA49 (by decide)
    D1BodySized.sizeDecA49 D1BodySized.sizePreA49 D1BodySized.patchB49
    D1BodySized.sizeOracle48 D1BodySized.inactive49 D1BodySized.bridgeOut48 D1BodySized.sizeTable20_48
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ49
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive49 : (bridgeOf D1BodySized.s170.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check49 : decide (20 ≤ D1BodySized.S170.tab.length) = true
theorem D1BodySized.fromTable20_49 : 20 ≤ D1BodySized.S170.tab.length := of_decide_eq_true D1BodySized.fromTable20Check49
kernel_rfl D1BodySized.bridgeInto49 : bridgeOf D1BodySized.s172.ffi = bridgeOf D1BodySized.s170.ffi
kernel_rfl D1BodySized.bridgeOut49 : bridgeOf D1BodySized.s173.ffi = bridgeOf D1BodySized.s172.ffi
kernel_rfl D1BodySized.sizeTable20Check49 : decide (20 ≤ D1BodySized.S172.tab.length) = true
theorem D1BodySized.sizeTable20_49 : 20 ≤ D1BodySized.S172.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check49
kernel_rfl D1BodySized.sizeOracle49 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S172.oracle = true

end Host.Load.Run.Tpl
end

section -- SP49
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece49 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s170 D1BodySized.S170) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s173 D1BodySized.S173) 7766 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted49 D1BodySized.segment49 D1BodySized.acceptedP50
    D1BodySized.haltP50 D1BodySized.stepA50 D1BodySized.topA50
    D1BodySized.oracle49 D1BodySized.fromInactive49 D1BodySized.bridgeInto49 D1BodySized.fromTable20_49
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA50 D1BodySized.sizeArgsA50 D1BodySized.sizeSymA50
    D1BodySized.sizeMlxA50 D1BodySized.sizePayA50 (by decide)
    D1BodySized.sizeDecA50 D1BodySized.sizePreA50 D1BodySized.patchB50
    D1BodySized.sizeOracle49 D1BodySized.inactive50 D1BodySized.bridgeOut49 D1BodySized.sizeTable20_49
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ50
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive50 : (bridgeOf D1BodySized.s173.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check50 : decide (20 ≤ D1BodySized.S173.tab.length) = true
theorem D1BodySized.fromTable20_50 : 20 ≤ D1BodySized.S173.tab.length := of_decide_eq_true D1BodySized.fromTable20Check50
kernel_rfl D1BodySized.bridgeInto50 : bridgeOf D1BodySized.s175.ffi = bridgeOf D1BodySized.s173.ffi
kernel_rfl D1BodySized.bridgeOut50 : bridgeOf D1BodySized.s176.ffi = bridgeOf D1BodySized.s175.ffi
kernel_rfl D1BodySized.sizeTable20Check50 : decide (20 ≤ D1BodySized.S175.tab.length) = true
theorem D1BodySized.sizeTable20_50 : 20 ≤ D1BodySized.S175.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check50
kernel_rfl D1BodySized.sizeOracle50 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S175.oracle = true

end Host.Load.Run.Tpl
end

section -- SP50
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece50 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s173 D1BodySized.S173) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s176 D1BodySized.S176) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted50 D1BodySized.segment50 D1BodySized.acceptedP51
    D1BodySized.haltP51 D1BodySized.stepA51 D1BodySized.topA51
    D1BodySized.oracle50 D1BodySized.fromInactive50 D1BodySized.bridgeInto50 D1BodySized.fromTable20_50
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA51 D1BodySized.sizeArgsA51 D1BodySized.sizeSymA51
    D1BodySized.sizeMlxA51 D1BodySized.sizePayA51 (by decide)
    D1BodySized.sizeDecA51 D1BodySized.sizePreA51 D1BodySized.patchB51
    D1BodySized.sizeOracle50 D1BodySized.inactive51 D1BodySized.bridgeOut50 D1BodySized.sizeTable20_50
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive51 : (bridgeOf D1BodySized.s176.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check51 : decide (20 ≤ D1BodySized.S176.tab.length) = true
theorem D1BodySized.fromTable20_51 : 20 ≤ D1BodySized.S176.tab.length := of_decide_eq_true D1BodySized.fromTable20Check51
kernel_rfl D1BodySized.bridgeInto51 : bridgeOf D1BodySized.s179.ffi = bridgeOf D1BodySized.s176.ffi
kernel_rfl D1BodySized.bridgeOut51 : bridgeOf D1BodySized.s180.ffi = bridgeOf D1BodySized.s179.ffi
kernel_rfl D1BodySized.sizeTable20Check51 : decide (20 ≤ D1BodySized.S179.tab.length) = true
theorem D1BodySized.sizeTable20_51 : 20 ≤ D1BodySized.S179.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check51
kernel_rfl D1BodySized.sizeOracle51 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S179.oracle = true

end Host.Load.Run.Tpl
end

section -- SP51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece51 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s176 D1BodySized.S176) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s180 D1BodySized.S180) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted51 D1BodySized.segment51 D1BodySized.acceptedP52
    D1BodySized.haltP52 D1BodySized.stepA52 D1BodySized.topA52
    D1BodySized.oracle51 D1BodySized.fromInactive51 D1BodySized.bridgeInto51 D1BodySized.fromTable20_51
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA52 D1BodySized.sizeArgsA52 D1BodySized.sizeSymA52
    D1BodySized.sizeMlxA52 D1BodySized.sizePayA52 (by decide)
    D1BodySized.sizeDecA52 D1BodySized.sizePreA52 D1BodySized.patchB52
    D1BodySized.sizeOracle51 D1BodySized.inactive52 D1BodySized.bridgeOut51 D1BodySized.sizeTable20_51
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ52
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive52 : (bridgeOf D1BodySized.s180.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check52 : decide (20 ≤ D1BodySized.S180.tab.length) = true
theorem D1BodySized.fromTable20_52 : 20 ≤ D1BodySized.S180.tab.length := of_decide_eq_true D1BodySized.fromTable20Check52
kernel_rfl D1BodySized.bridgeInto52 : bridgeOf D1BodySized.s182.ffi = bridgeOf D1BodySized.s180.ffi
kernel_rfl D1BodySized.bridgeOut52 : bridgeOf D1BodySized.s183.ffi = bridgeOf D1BodySized.s182.ffi
kernel_rfl D1BodySized.sizeTable20Check52 : decide (20 ≤ D1BodySized.S182.tab.length) = true
theorem D1BodySized.sizeTable20_52 : 20 ≤ D1BodySized.S182.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check52
kernel_rfl D1BodySized.sizeOracle52 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S182.oracle = true

end Host.Load.Run.Tpl
end

section -- SP52
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece52 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s180 D1BodySized.S180) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s183 D1BodySized.S183) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted52 D1BodySized.segment52 D1BodySized.acceptedP53
    D1BodySized.haltP53 D1BodySized.stepA53 D1BodySized.topA53
    D1BodySized.oracle52 D1BodySized.fromInactive52 D1BodySized.bridgeInto52 D1BodySized.fromTable20_52
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA53 D1BodySized.sizeArgsA53 D1BodySized.sizeSymA53
    D1BodySized.sizeMlxA53 D1BodySized.sizePayA53 (by decide)
    D1BodySized.sizeDecA53 D1BodySized.sizePreA53 D1BodySized.patchB53
    D1BodySized.sizeOracle52 D1BodySized.inactive53 D1BodySized.bridgeOut52 D1BodySized.sizeTable20_52
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ53
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive53 : (bridgeOf D1BodySized.s183.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check53 : decide (20 ≤ D1BodySized.S183.tab.length) = true
theorem D1BodySized.fromTable20_53 : 20 ≤ D1BodySized.S183.tab.length := of_decide_eq_true D1BodySized.fromTable20Check53
kernel_rfl D1BodySized.bridgeInto53 : bridgeOf D1BodySized.s185.ffi = bridgeOf D1BodySized.s183.ffi
kernel_rfl D1BodySized.bridgeOut53 : bridgeOf D1BodySized.s186.ffi = bridgeOf D1BodySized.s185.ffi
kernel_rfl D1BodySized.sizeTable20Check53 : decide (20 ≤ D1BodySized.S185.tab.length) = true
theorem D1BodySized.sizeTable20_53 : 20 ≤ D1BodySized.S185.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check53
kernel_rfl D1BodySized.sizeOracle53 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S185.oracle = true

end Host.Load.Run.Tpl
end

section -- SP53
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece53 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s183 D1BodySized.S183) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s186 D1BodySized.S186) 7766 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted53 D1BodySized.segment53 D1BodySized.acceptedP54
    D1BodySized.haltP54 D1BodySized.stepA54 D1BodySized.topA54
    D1BodySized.oracle53 D1BodySized.fromInactive53 D1BodySized.bridgeInto53 D1BodySized.fromTable20_53
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA54 D1BodySized.sizeArgsA54 D1BodySized.sizeSymA54
    D1BodySized.sizeMlxA54 D1BodySized.sizePayA54 (by decide)
    D1BodySized.sizeDecA54 D1BodySized.sizePreA54 D1BodySized.patchB54
    D1BodySized.sizeOracle53 D1BodySized.inactive54 D1BodySized.bridgeOut53 D1BodySized.sizeTable20_53
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive54 : (bridgeOf D1BodySized.s186.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check54 : decide (20 ≤ D1BodySized.S186.tab.length) = true
theorem D1BodySized.fromTable20_54 : 20 ≤ D1BodySized.S186.tab.length := of_decide_eq_true D1BodySized.fromTable20Check54
kernel_rfl D1BodySized.bridgeInto54 : bridgeOf D1BodySized.s188.ffi = bridgeOf D1BodySized.s186.ffi
kernel_rfl D1BodySized.bridgeOut54 : bridgeOf D1BodySized.s189.ffi = bridgeOf D1BodySized.s188.ffi
kernel_rfl D1BodySized.sizeTable20Check54 : decide (20 ≤ D1BodySized.S188.tab.length) = true
theorem D1BodySized.sizeTable20_54 : 20 ≤ D1BodySized.S188.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check54
kernel_rfl D1BodySized.sizeOracle54 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S188.oracle = true

end Host.Load.Run.Tpl
end

section -- SP54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece54 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s186 D1BodySized.S186) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s189 D1BodySized.S189) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted54 D1BodySized.segment54 D1BodySized.acceptedP55
    D1BodySized.haltP55 D1BodySized.stepA55 D1BodySized.topA55
    D1BodySized.oracle54 D1BodySized.fromInactive54 D1BodySized.bridgeInto54 D1BodySized.fromTable20_54
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA55 D1BodySized.sizeArgsA55 D1BodySized.sizeSymA55
    D1BodySized.sizeMlxA55 D1BodySized.sizePayA55 (by decide)
    D1BodySized.sizeDecA55 D1BodySized.sizePreA55 D1BodySized.patchB55
    D1BodySized.sizeOracle54 D1BodySized.inactive55 D1BodySized.bridgeOut54 D1BodySized.sizeTable20_54
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ55
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive55 : (bridgeOf D1BodySized.s189.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check55 : decide (20 ≤ D1BodySized.S189.tab.length) = true
theorem D1BodySized.fromTable20_55 : 20 ≤ D1BodySized.S189.tab.length := of_decide_eq_true D1BodySized.fromTable20Check55
kernel_rfl D1BodySized.bridgeInto55 : bridgeOf D1BodySized.s192.ffi = bridgeOf D1BodySized.s189.ffi
kernel_rfl D1BodySized.bridgeOut55 : bridgeOf D1BodySized.s193.ffi = bridgeOf D1BodySized.s192.ffi
kernel_rfl D1BodySized.sizeTable20Check55 : decide (20 ≤ D1BodySized.S192.tab.length) = true
theorem D1BodySized.sizeTable20_55 : 20 ≤ D1BodySized.S192.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check55
kernel_rfl D1BodySized.sizeOracle55 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S192.oracle = true

end Host.Load.Run.Tpl
end

section -- SP55
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece55 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s189 D1BodySized.S189) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s193 D1BodySized.S193) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted55 D1BodySized.segment55 D1BodySized.acceptedP56
    D1BodySized.haltP56 D1BodySized.stepA56 D1BodySized.topA56
    D1BodySized.oracle55 D1BodySized.fromInactive55 D1BodySized.bridgeInto55 D1BodySized.fromTable20_55
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA56 D1BodySized.sizeArgsA56 D1BodySized.sizeSymA56
    D1BodySized.sizeMlxA56 D1BodySized.sizePayA56 (by decide)
    D1BodySized.sizeDecA56 D1BodySized.sizePreA56 D1BodySized.patchB56
    D1BodySized.sizeOracle55 D1BodySized.inactive56 D1BodySized.bridgeOut55 D1BodySized.sizeTable20_55
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive56 : (bridgeOf D1BodySized.s193.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check56 : decide (20 ≤ D1BodySized.S193.tab.length) = true
theorem D1BodySized.fromTable20_56 : 20 ≤ D1BodySized.S193.tab.length := of_decide_eq_true D1BodySized.fromTable20Check56
kernel_rfl D1BodySized.bridgeInto56 : bridgeOf D1BodySized.s195.ffi = bridgeOf D1BodySized.s193.ffi
kernel_rfl D1BodySized.bridgeOut56 : bridgeOf D1BodySized.s196.ffi = bridgeOf D1BodySized.s195.ffi
kernel_rfl D1BodySized.sizeTable20Check56 : decide (20 ≤ D1BodySized.S195.tab.length) = true
theorem D1BodySized.sizeTable20_56 : 20 ≤ D1BodySized.S195.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check56
kernel_rfl D1BodySized.sizeOracle56 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S195.oracle = true

end Host.Load.Run.Tpl
end

section -- SP56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece56 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s193 D1BodySized.S193) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s196 D1BodySized.S196) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted56 D1BodySized.segment56 D1BodySized.acceptedP57
    D1BodySized.haltP57 D1BodySized.stepA57 D1BodySized.topA57
    D1BodySized.oracle56 D1BodySized.fromInactive56 D1BodySized.bridgeInto56 D1BodySized.fromTable20_56
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA57 D1BodySized.sizeArgsA57 D1BodySized.sizeSymA57
    D1BodySized.sizeMlxA57 D1BodySized.sizePayA57 (by decide)
    D1BodySized.sizeDecA57 D1BodySized.sizePreA57 D1BodySized.patchB57
    D1BodySized.sizeOracle56 D1BodySized.inactive57 D1BodySized.bridgeOut56 D1BodySized.sizeTable20_56
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive57 : (bridgeOf D1BodySized.s196.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check57 : decide (20 ≤ D1BodySized.S196.tab.length) = true
theorem D1BodySized.fromTable20_57 : 20 ≤ D1BodySized.S196.tab.length := of_decide_eq_true D1BodySized.fromTable20Check57
kernel_rfl D1BodySized.bridgeInto57 : bridgeOf D1BodySized.s200.ffi = bridgeOf D1BodySized.s196.ffi
kernel_rfl D1BodySized.bridgeOut57 : bridgeOf D1BodySized.s201.ffi = bridgeOf D1BodySized.s200.ffi
kernel_rfl D1BodySized.sizeTable20Check57 : decide (20 ≤ D1BodySized.S200.tab.length) = true
theorem D1BodySized.sizeTable20_57 : 20 ≤ D1BodySized.S200.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check57
kernel_rfl D1BodySized.sizeOracle57 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S200.oracle = true

end Host.Load.Run.Tpl
end

section -- SP57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece57 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s196 D1BodySized.S196) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s201 D1BodySized.S201) 22337 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted57 D1BodySized.segment57 D1BodySized.acceptedP58
    D1BodySized.haltP58 D1BodySized.stepA58 D1BodySized.topA58
    D1BodySized.oracle57 D1BodySized.fromInactive57 D1BodySized.bridgeInto57 D1BodySized.fromTable20_57
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA58 D1BodySized.sizeArgsA58 D1BodySized.sizeSymA58
    D1BodySized.sizeMlxA58 D1BodySized.sizePayA58 (by decide)
    D1BodySized.sizeDecA58 D1BodySized.sizePreA58 D1BodySized.patchB58
    D1BodySized.sizeOracle57 D1BodySized.inactive58 D1BodySized.bridgeOut57 D1BodySized.sizeTable20_57
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive58 : (bridgeOf D1BodySized.s201.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check58 : decide (20 ≤ D1BodySized.S201.tab.length) = true
theorem D1BodySized.fromTable20_58 : 20 ≤ D1BodySized.S201.tab.length := of_decide_eq_true D1BodySized.fromTable20Check58
kernel_rfl D1BodySized.bridgeInto58 : bridgeOf D1BodySized.s203.ffi = bridgeOf D1BodySized.s201.ffi
kernel_rfl D1BodySized.bridgeOut58 : bridgeOf D1BodySized.s204.ffi = bridgeOf D1BodySized.s203.ffi
kernel_rfl D1BodySized.sizeTable20Check58 : decide (20 ≤ D1BodySized.S203.tab.length) = true
theorem D1BodySized.sizeTable20_58 : 20 ≤ D1BodySized.S203.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check58
kernel_rfl D1BodySized.sizeOracle58 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S203.oracle = true

end Host.Load.Run.Tpl
end

section -- SP58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece58 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s201 D1BodySized.S201) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s204 D1BodySized.S204) 7938 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted58 D1BodySized.segment58 D1BodySized.acceptedP59
    D1BodySized.haltP59 D1BodySized.stepA59 D1BodySized.topA59
    D1BodySized.oracle58 D1BodySized.fromInactive58 D1BodySized.bridgeInto58 D1BodySized.fromTable20_58
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA59 D1BodySized.sizeArgsA59 D1BodySized.sizeSymA59
    D1BodySized.sizeMlxA59 D1BodySized.sizePayA59 (by decide)
    D1BodySized.sizeDecA59 D1BodySized.sizePreA59 D1BodySized.patchB59
    D1BodySized.sizeOracle58 D1BodySized.inactive59 D1BodySized.bridgeOut58 D1BodySized.sizeTable20_58
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ59
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive59 : (bridgeOf D1BodySized.s204.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check59 : decide (20 ≤ D1BodySized.S204.tab.length) = true
theorem D1BodySized.fromTable20_59 : 20 ≤ D1BodySized.S204.tab.length := of_decide_eq_true D1BodySized.fromTable20Check59
kernel_rfl D1BodySized.bridgeInto59 : bridgeOf D1BodySized.s206.ffi = bridgeOf D1BodySized.s204.ffi
kernel_rfl D1BodySized.bridgeOut59 : bridgeOf D1BodySized.s207.ffi = bridgeOf D1BodySized.s206.ffi
kernel_rfl D1BodySized.sizeTable20Check59 : decide (20 ≤ D1BodySized.S206.tab.length) = true
theorem D1BodySized.sizeTable20_59 : 20 ≤ D1BodySized.S206.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check59
kernel_rfl D1BodySized.sizeOracle59 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S206.oracle = true

end Host.Load.Run.Tpl
end

section -- SP59
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece59 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s204 D1BodySized.S204) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s207 D1BodySized.S207) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted59 D1BodySized.segment59 D1BodySized.acceptedP60
    D1BodySized.haltP60 D1BodySized.stepA60 D1BodySized.topA60
    D1BodySized.oracle59 D1BodySized.fromInactive59 D1BodySized.bridgeInto59 D1BodySized.fromTable20_59
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA60 D1BodySized.sizeArgsA60 D1BodySized.sizeSymA60
    D1BodySized.sizeMlxA60 D1BodySized.sizePayA60 (by decide)
    D1BodySized.sizeDecA60 D1BodySized.sizePreA60 D1BodySized.patchB60
    D1BodySized.sizeOracle59 D1BodySized.inactive60 D1BodySized.bridgeOut59 D1BodySized.sizeTable20_59
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ60
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive60 : (bridgeOf D1BodySized.s207.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check60 : decide (20 ≤ D1BodySized.S207.tab.length) = true
theorem D1BodySized.fromTable20_60 : 20 ≤ D1BodySized.S207.tab.length := of_decide_eq_true D1BodySized.fromTable20Check60
kernel_rfl D1BodySized.bridgeInto60 : bridgeOf D1BodySized.s210.ffi = bridgeOf D1BodySized.s207.ffi
kernel_rfl D1BodySized.bridgeOut60 : bridgeOf D1BodySized.s211.ffi = bridgeOf D1BodySized.s210.ffi
kernel_rfl D1BodySized.sizeTable20Check60 : decide (20 ≤ D1BodySized.S210.tab.length) = true
theorem D1BodySized.sizeTable20_60 : 20 ≤ D1BodySized.S210.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check60
kernel_rfl D1BodySized.sizeOracle60 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S210.oracle = true

end Host.Load.Run.Tpl
end

section -- SP60
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece60 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s207 D1BodySized.S207) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s211 D1BodySized.S211) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted60 D1BodySized.segment60 D1BodySized.acceptedP61
    D1BodySized.haltP61 D1BodySized.stepA61 D1BodySized.topA61
    D1BodySized.oracle60 D1BodySized.fromInactive60 D1BodySized.bridgeInto60 D1BodySized.fromTable20_60
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA61 D1BodySized.sizeArgsA61 D1BodySized.sizeSymA61
    D1BodySized.sizeMlxA61 D1BodySized.sizePayA61 (by decide)
    D1BodySized.sizeDecA61 D1BodySized.sizePreA61 D1BodySized.patchB61
    D1BodySized.sizeOracle60 D1BodySized.inactive61 D1BodySized.bridgeOut60 D1BodySized.sizeTable20_60
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive61 : (bridgeOf D1BodySized.s211.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check61 : decide (20 ≤ D1BodySized.S211.tab.length) = true
theorem D1BodySized.fromTable20_61 : 20 ≤ D1BodySized.S211.tab.length := of_decide_eq_true D1BodySized.fromTable20Check61
kernel_rfl D1BodySized.bridgeInto61 : bridgeOf D1BodySized.s213.ffi = bridgeOf D1BodySized.s211.ffi
kernel_rfl D1BodySized.bridgeOut61 : bridgeOf D1BodySized.s214.ffi = bridgeOf D1BodySized.s213.ffi
kernel_rfl D1BodySized.sizeTable20Check61 : decide (20 ≤ D1BodySized.S213.tab.length) = true
theorem D1BodySized.sizeTable20_61 : 20 ≤ D1BodySized.S213.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check61
kernel_rfl D1BodySized.sizeOracle61 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S213.oracle = true

end Host.Load.Run.Tpl
end

section -- SP61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece61 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s211 D1BodySized.S211) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s214 D1BodySized.S214) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted61 D1BodySized.segment61 D1BodySized.acceptedP62
    D1BodySized.haltP62 D1BodySized.stepA62 D1BodySized.topA62
    D1BodySized.oracle61 D1BodySized.fromInactive61 D1BodySized.bridgeInto61 D1BodySized.fromTable20_61
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA62 D1BodySized.sizeArgsA62 D1BodySized.sizeSymA62
    D1BodySized.sizeMlxA62 D1BodySized.sizePayA62 (by decide)
    D1BodySized.sizeDecA62 D1BodySized.sizePreA62 D1BodySized.patchB62
    D1BodySized.sizeOracle61 D1BodySized.inactive62 D1BodySized.bridgeOut61 D1BodySized.sizeTable20_61
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ62
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive62 : (bridgeOf D1BodySized.s214.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check62 : decide (20 ≤ D1BodySized.S214.tab.length) = true
theorem D1BodySized.fromTable20_62 : 20 ≤ D1BodySized.S214.tab.length := of_decide_eq_true D1BodySized.fromTable20Check62
kernel_rfl D1BodySized.bridgeInto62 : bridgeOf D1BodySized.s216.ffi = bridgeOf D1BodySized.s214.ffi
kernel_rfl D1BodySized.bridgeOut62 : bridgeOf D1BodySized.s217.ffi = bridgeOf D1BodySized.s216.ffi
kernel_rfl D1BodySized.sizeTable20Check62 : decide (20 ≤ D1BodySized.S216.tab.length) = true
theorem D1BodySized.sizeTable20_62 : 20 ≤ D1BodySized.S216.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check62
kernel_rfl D1BodySized.sizeOracle62 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S216.oracle = true

end Host.Load.Run.Tpl
end

section -- SP62
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece62 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s214 D1BodySized.S214) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s217 D1BodySized.S217) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted62 D1BodySized.segment62 D1BodySized.acceptedP63
    D1BodySized.haltP63 D1BodySized.stepA63 D1BodySized.topA63
    D1BodySized.oracle62 D1BodySized.fromInactive62 D1BodySized.bridgeInto62 D1BodySized.fromTable20_62
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA63 D1BodySized.sizeArgsA63 D1BodySized.sizeSymA63
    D1BodySized.sizeMlxA63 D1BodySized.sizePayA63 (by decide)
    D1BodySized.sizeDecA63 D1BodySized.sizePreA63 D1BodySized.patchB63
    D1BodySized.sizeOracle62 D1BodySized.inactive63 D1BodySized.bridgeOut62 D1BodySized.sizeTable20_62
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive63 : (bridgeOf D1BodySized.s217.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check63 : decide (20 ≤ D1BodySized.S217.tab.length) = true
theorem D1BodySized.fromTable20_63 : 20 ≤ D1BodySized.S217.tab.length := of_decide_eq_true D1BodySized.fromTable20Check63
kernel_rfl D1BodySized.bridgeInto63 : bridgeOf D1BodySized.s219.ffi = bridgeOf D1BodySized.s217.ffi
kernel_rfl D1BodySized.bridgeOut63 : bridgeOf D1BodySized.s220.ffi = bridgeOf D1BodySized.s219.ffi
kernel_rfl D1BodySized.sizeTable20Check63 : decide (20 ≤ D1BodySized.S219.tab.length) = true
theorem D1BodySized.sizeTable20_63 : 20 ≤ D1BodySized.S219.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check63
kernel_rfl D1BodySized.sizeOracle63 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S219.oracle = true

end Host.Load.Run.Tpl
end

section -- SP63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece63 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s217 D1BodySized.S217) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s220 D1BodySized.S220) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted63 D1BodySized.segment63 D1BodySized.acceptedP64
    D1BodySized.haltP64 D1BodySized.stepA64 D1BodySized.topA64
    D1BodySized.oracle63 D1BodySized.fromInactive63 D1BodySized.bridgeInto63 D1BodySized.fromTable20_63
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA64 D1BodySized.sizeArgsA64 D1BodySized.sizeSymA64
    D1BodySized.sizeMlxA64 D1BodySized.sizePayA64 (by decide)
    D1BodySized.sizeDecA64 D1BodySized.sizePreA64 D1BodySized.patchB64
    D1BodySized.sizeOracle63 D1BodySized.inactive64 D1BodySized.bridgeOut63 D1BodySized.sizeTable20_63
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ64
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive64 : (bridgeOf D1BodySized.s220.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check64 : decide (20 ≤ D1BodySized.S220.tab.length) = true
theorem D1BodySized.fromTable20_64 : 20 ≤ D1BodySized.S220.tab.length := of_decide_eq_true D1BodySized.fromTable20Check64
kernel_rfl D1BodySized.bridgeInto64 : bridgeOf D1BodySized.s223.ffi = bridgeOf D1BodySized.s220.ffi
kernel_rfl D1BodySized.bridgeOut64 : bridgeOf D1BodySized.s224.ffi = bridgeOf D1BodySized.s223.ffi
kernel_rfl D1BodySized.sizeTable20Check64 : decide (20 ≤ D1BodySized.S223.tab.length) = true
theorem D1BodySized.sizeTable20_64 : 20 ≤ D1BodySized.S223.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check64
kernel_rfl D1BodySized.sizeOracle64 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S223.oracle = true

end Host.Load.Run.Tpl
end

section -- SP64
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece64 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s220 D1BodySized.S220) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s224 D1BodySized.S224) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted64 D1BodySized.segment64 D1BodySized.acceptedP65
    D1BodySized.haltP65 D1BodySized.stepA65 D1BodySized.topA65
    D1BodySized.oracle64 D1BodySized.fromInactive64 D1BodySized.bridgeInto64 D1BodySized.fromTable20_64
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA65 D1BodySized.sizeArgsA65 D1BodySized.sizeSymA65
    D1BodySized.sizeMlxA65 D1BodySized.sizePayA65 (by decide)
    D1BodySized.sizeDecA65 D1BodySized.sizePreA65 D1BodySized.patchB65
    D1BodySized.sizeOracle64 D1BodySized.inactive65 D1BodySized.bridgeOut64 D1BodySized.sizeTable20_64
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ65
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive65 : (bridgeOf D1BodySized.s224.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check65 : decide (20 ≤ D1BodySized.S224.tab.length) = true
theorem D1BodySized.fromTable20_65 : 20 ≤ D1BodySized.S224.tab.length := of_decide_eq_true D1BodySized.fromTable20Check65
kernel_rfl D1BodySized.bridgeInto65 : bridgeOf D1BodySized.s226.ffi = bridgeOf D1BodySized.s224.ffi
kernel_rfl D1BodySized.bridgeOut65 : bridgeOf D1BodySized.s227.ffi = bridgeOf D1BodySized.s226.ffi
kernel_rfl D1BodySized.sizeTable20Check65 : decide (20 ≤ D1BodySized.S226.tab.length) = true
theorem D1BodySized.sizeTable20_65 : 20 ≤ D1BodySized.S226.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check65
kernel_rfl D1BodySized.sizeOracle65 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S226.oracle = true

end Host.Load.Run.Tpl
end

section -- SP65
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece65 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s224 D1BodySized.S224) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s227 D1BodySized.S227) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted65 D1BodySized.segment65 D1BodySized.acceptedP66
    D1BodySized.haltP66 D1BodySized.stepA66 D1BodySized.topA66
    D1BodySized.oracle65 D1BodySized.fromInactive65 D1BodySized.bridgeInto65 D1BodySized.fromTable20_65
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA66 D1BodySized.sizeArgsA66 D1BodySized.sizeSymA66
    D1BodySized.sizeMlxA66 D1BodySized.sizePayA66 (by decide)
    D1BodySized.sizeDecA66 D1BodySized.sizePreA66 D1BodySized.patchB66
    D1BodySized.sizeOracle65 D1BodySized.inactive66 D1BodySized.bridgeOut65 D1BodySized.sizeTable20_65
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ66
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive66 : (bridgeOf D1BodySized.s227.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check66 : decide (20 ≤ D1BodySized.S227.tab.length) = true
theorem D1BodySized.fromTable20_66 : 20 ≤ D1BodySized.S227.tab.length := of_decide_eq_true D1BodySized.fromTable20Check66
kernel_rfl D1BodySized.bridgeInto66 : bridgeOf D1BodySized.s229.ffi = bridgeOf D1BodySized.s227.ffi
kernel_rfl D1BodySized.bridgeOut66 : bridgeOf D1BodySized.s230.ffi = bridgeOf D1BodySized.s229.ffi
kernel_rfl D1BodySized.sizeTable20Check66 : decide (20 ≤ D1BodySized.S229.tab.length) = true
theorem D1BodySized.sizeTable20_66 : 20 ≤ D1BodySized.S229.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check66
kernel_rfl D1BodySized.sizeOracle66 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S229.oracle = true

end Host.Load.Run.Tpl
end

section -- SP66
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece66 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s227 D1BodySized.S227) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s230 D1BodySized.S230) 7725 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted66 D1BodySized.segment66 D1BodySized.acceptedP67
    D1BodySized.haltP67 D1BodySized.stepA67 D1BodySized.topA67
    D1BodySized.oracle66 D1BodySized.fromInactive66 D1BodySized.bridgeInto66 D1BodySized.fromTable20_66
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA67 D1BodySized.sizeArgsA67 D1BodySized.sizeSymA67
    D1BodySized.sizeMlxA67 D1BodySized.sizePayA67 (by decide)
    D1BodySized.sizeDecA67 D1BodySized.sizePreA67 D1BodySized.patchB67
    D1BodySized.sizeOracle66 D1BodySized.inactive67 D1BodySized.bridgeOut66 D1BodySized.sizeTable20_66
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ67
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive67 : (bridgeOf D1BodySized.s230.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check67 : decide (20 ≤ D1BodySized.S230.tab.length) = true
theorem D1BodySized.fromTable20_67 : 20 ≤ D1BodySized.S230.tab.length := of_decide_eq_true D1BodySized.fromTable20Check67
kernel_rfl D1BodySized.bridgeInto67 : bridgeOf D1BodySized.s232.ffi = bridgeOf D1BodySized.s230.ffi
kernel_rfl D1BodySized.bridgeOut67 : bridgeOf D1BodySized.s233.ffi = bridgeOf D1BodySized.s232.ffi
kernel_rfl D1BodySized.sizeTable20Check67 : decide (20 ≤ D1BodySized.S232.tab.length) = true
theorem D1BodySized.sizeTable20_67 : 20 ≤ D1BodySized.S232.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check67
kernel_rfl D1BodySized.sizeOracle67 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S232.oracle = true

end Host.Load.Run.Tpl
end

section -- SP67
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece67 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s230 D1BodySized.S230) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s233 D1BodySized.S233) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted67 D1BodySized.segment67 D1BodySized.acceptedP68
    D1BodySized.haltP68 D1BodySized.stepA68 D1BodySized.topA68
    D1BodySized.oracle67 D1BodySized.fromInactive67 D1BodySized.bridgeInto67 D1BodySized.fromTable20_67
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA68 D1BodySized.sizeArgsA68 D1BodySized.sizeSymA68
    D1BodySized.sizeMlxA68 D1BodySized.sizePayA68 (by decide)
    D1BodySized.sizeDecA68 D1BodySized.sizePreA68 D1BodySized.patchB68
    D1BodySized.sizeOracle67 D1BodySized.inactive68 D1BodySized.bridgeOut67 D1BodySized.sizeTable20_67
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ68
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive68 : (bridgeOf D1BodySized.s233.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check68 : decide (20 ≤ D1BodySized.S233.tab.length) = true
theorem D1BodySized.fromTable20_68 : 20 ≤ D1BodySized.S233.tab.length := of_decide_eq_true D1BodySized.fromTable20Check68
kernel_rfl D1BodySized.bridgeInto68 : bridgeOf D1BodySized.s236.ffi = bridgeOf D1BodySized.s233.ffi
kernel_rfl D1BodySized.bridgeOut68 : bridgeOf D1BodySized.s237.ffi = bridgeOf D1BodySized.s236.ffi
kernel_rfl D1BodySized.sizeTable20Check68 : decide (20 ≤ D1BodySized.S236.tab.length) = true
theorem D1BodySized.sizeTable20_68 : 20 ≤ D1BodySized.S236.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check68
kernel_rfl D1BodySized.sizeOracle68 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S236.oracle = true

end Host.Load.Run.Tpl
end

section -- SP68
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece68 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s233 D1BodySized.S233) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s237 D1BodySized.S237) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted68 D1BodySized.segment68 D1BodySized.acceptedP69
    D1BodySized.haltP69 D1BodySized.stepA69 D1BodySized.topA69
    D1BodySized.oracle68 D1BodySized.fromInactive68 D1BodySized.bridgeInto68 D1BodySized.fromTable20_68
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA69 D1BodySized.sizeArgsA69 D1BodySized.sizeSymA69
    D1BodySized.sizeMlxA69 D1BodySized.sizePayA69 (by decide)
    D1BodySized.sizeDecA69 D1BodySized.sizePreA69 D1BodySized.patchB69
    D1BodySized.sizeOracle68 D1BodySized.inactive69 D1BodySized.bridgeOut68 D1BodySized.sizeTable20_68
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ69
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive69 : (bridgeOf D1BodySized.s237.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check69 : decide (20 ≤ D1BodySized.S237.tab.length) = true
theorem D1BodySized.fromTable20_69 : 20 ≤ D1BodySized.S237.tab.length := of_decide_eq_true D1BodySized.fromTable20Check69
kernel_rfl D1BodySized.bridgeInto69 : bridgeOf D1BodySized.s239.ffi = bridgeOf D1BodySized.s237.ffi
kernel_rfl D1BodySized.bridgeOut69 : bridgeOf D1BodySized.s240.ffi = bridgeOf D1BodySized.s239.ffi
kernel_rfl D1BodySized.sizeTable20Check69 : decide (20 ≤ D1BodySized.S239.tab.length) = true
theorem D1BodySized.sizeTable20_69 : 20 ≤ D1BodySized.S239.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check69
kernel_rfl D1BodySized.sizeOracle69 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S239.oracle = true

end Host.Load.Run.Tpl
end

section -- SP69
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece69 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s237 D1BodySized.S237) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s240 D1BodySized.S240) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted69 D1BodySized.segment69 D1BodySized.acceptedP70
    D1BodySized.haltP70 D1BodySized.stepA70 D1BodySized.topA70
    D1BodySized.oracle69 D1BodySized.fromInactive69 D1BodySized.bridgeInto69 D1BodySized.fromTable20_69
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA70 D1BodySized.sizeArgsA70 D1BodySized.sizeSymA70
    D1BodySized.sizeMlxA70 D1BodySized.sizePayA70 (by decide)
    D1BodySized.sizeDecA70 D1BodySized.sizePreA70 D1BodySized.patchB70
    D1BodySized.sizeOracle69 D1BodySized.inactive70 D1BodySized.bridgeOut69 D1BodySized.sizeTable20_69
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ70
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive70 : (bridgeOf D1BodySized.s240.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check70 : decide (20 ≤ D1BodySized.S240.tab.length) = true
theorem D1BodySized.fromTable20_70 : 20 ≤ D1BodySized.S240.tab.length := of_decide_eq_true D1BodySized.fromTable20Check70
kernel_rfl D1BodySized.bridgeInto70 : bridgeOf D1BodySized.s244.ffi = bridgeOf D1BodySized.s240.ffi
kernel_rfl D1BodySized.bridgeOut70 : bridgeOf D1BodySized.s245.ffi = bridgeOf D1BodySized.s244.ffi
kernel_rfl D1BodySized.sizeTable20Check70 : decide (20 ≤ D1BodySized.S244.tab.length) = true
theorem D1BodySized.sizeTable20_70 : 20 ≤ D1BodySized.S244.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check70
kernel_rfl D1BodySized.sizeOracle70 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S244.oracle = true

end Host.Load.Run.Tpl
end

section -- SP70
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece70 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s240 D1BodySized.S240) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s245 D1BodySized.S245) 22291 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted70 D1BodySized.segment70 D1BodySized.acceptedP71
    D1BodySized.haltP71 D1BodySized.stepA71 D1BodySized.topA71
    D1BodySized.oracle70 D1BodySized.fromInactive70 D1BodySized.bridgeInto70 D1BodySized.fromTable20_70
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA71 D1BodySized.sizeArgsA71 D1BodySized.sizeSymA71
    D1BodySized.sizeMlxA71 D1BodySized.sizePayA71 (by decide)
    D1BodySized.sizeDecA71 D1BodySized.sizePreA71 D1BodySized.patchB71
    D1BodySized.sizeOracle70 D1BodySized.inactive71 D1BodySized.bridgeOut70 D1BodySized.sizeTable20_70
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ71
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive71 : (bridgeOf D1BodySized.s245.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check71 : decide (20 ≤ D1BodySized.S245.tab.length) = true
theorem D1BodySized.fromTable20_71 : 20 ≤ D1BodySized.S245.tab.length := of_decide_eq_true D1BodySized.fromTable20Check71
kernel_rfl D1BodySized.bridgeInto71 : bridgeOf D1BodySized.s247.ffi = bridgeOf D1BodySized.s245.ffi
kernel_rfl D1BodySized.bridgeOut71 : bridgeOf D1BodySized.s248.ffi = bridgeOf D1BodySized.s247.ffi
kernel_rfl D1BodySized.sizeTable20Check71 : decide (20 ≤ D1BodySized.S247.tab.length) = true
theorem D1BodySized.sizeTable20_71 : 20 ≤ D1BodySized.S247.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check71
kernel_rfl D1BodySized.sizeOracle71 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S247.oracle = true

end Host.Load.Run.Tpl
end

section -- SP71
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece71 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s245 D1BodySized.S245) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s248 D1BodySized.S248) 7938 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted71 D1BodySized.segment71 D1BodySized.acceptedP72
    D1BodySized.haltP72 D1BodySized.stepA72 D1BodySized.topA72
    D1BodySized.oracle71 D1BodySized.fromInactive71 D1BodySized.bridgeInto71 D1BodySized.fromTable20_71
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA72 D1BodySized.sizeArgsA72 D1BodySized.sizeSymA72
    D1BodySized.sizeMlxA72 D1BodySized.sizePayA72 (by decide)
    D1BodySized.sizeDecA72 D1BodySized.sizePreA72 D1BodySized.patchB72
    D1BodySized.sizeOracle71 D1BodySized.inactive72 D1BodySized.bridgeOut71 D1BodySized.sizeTable20_71
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ72
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive72 : (bridgeOf D1BodySized.s248.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check72 : decide (20 ≤ D1BodySized.S248.tab.length) = true
theorem D1BodySized.fromTable20_72 : 20 ≤ D1BodySized.S248.tab.length := of_decide_eq_true D1BodySized.fromTable20Check72
kernel_rfl D1BodySized.bridgeInto72 : bridgeOf D1BodySized.s250.ffi = bridgeOf D1BodySized.s248.ffi
kernel_rfl D1BodySized.bridgeOut72 : bridgeOf D1BodySized.s251.ffi = bridgeOf D1BodySized.s250.ffi
kernel_rfl D1BodySized.sizeTable20Check72 : decide (20 ≤ D1BodySized.S250.tab.length) = true
theorem D1BodySized.sizeTable20_72 : 20 ≤ D1BodySized.S250.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check72
kernel_rfl D1BodySized.sizeOracle72 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S250.oracle = true

end Host.Load.Run.Tpl
end

section -- SP72
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece72 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s248 D1BodySized.S248) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s251 D1BodySized.S251) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted72 D1BodySized.segment72 D1BodySized.acceptedP73
    D1BodySized.haltP73 D1BodySized.stepA73 D1BodySized.topA73
    D1BodySized.oracle72 D1BodySized.fromInactive72 D1BodySized.bridgeInto72 D1BodySized.fromTable20_72
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA73 D1BodySized.sizeArgsA73 D1BodySized.sizeSymA73
    D1BodySized.sizeMlxA73 D1BodySized.sizePayA73 (by decide)
    D1BodySized.sizeDecA73 D1BodySized.sizePreA73 D1BodySized.patchB73
    D1BodySized.sizeOracle72 D1BodySized.inactive73 D1BodySized.bridgeOut72 D1BodySized.sizeTable20_72
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ73
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive73 : (bridgeOf D1BodySized.s251.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check73 : decide (20 ≤ D1BodySized.S251.tab.length) = true
theorem D1BodySized.fromTable20_73 : 20 ≤ D1BodySized.S251.tab.length := of_decide_eq_true D1BodySized.fromTable20Check73
kernel_rfl D1BodySized.bridgeInto73 : bridgeOf D1BodySized.s254.ffi = bridgeOf D1BodySized.s251.ffi
kernel_rfl D1BodySized.bridgeOut73 : bridgeOf D1BodySized.s255.ffi = bridgeOf D1BodySized.s254.ffi
kernel_rfl D1BodySized.sizeTable20Check73 : decide (20 ≤ D1BodySized.S254.tab.length) = true
theorem D1BodySized.sizeTable20_73 : 20 ≤ D1BodySized.S254.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check73
kernel_rfl D1BodySized.sizeOracle73 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S254.oracle = true

end Host.Load.Run.Tpl
end

section -- SP73
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece73 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s251 D1BodySized.S251) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s255 D1BodySized.S255) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted73 D1BodySized.segment73 D1BodySized.acceptedP74
    D1BodySized.haltP74 D1BodySized.stepA74 D1BodySized.topA74
    D1BodySized.oracle73 D1BodySized.fromInactive73 D1BodySized.bridgeInto73 D1BodySized.fromTable20_73
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA74 D1BodySized.sizeArgsA74 D1BodySized.sizeSymA74
    D1BodySized.sizeMlxA74 D1BodySized.sizePayA74 (by decide)
    D1BodySized.sizeDecA74 D1BodySized.sizePreA74 D1BodySized.patchB74
    D1BodySized.sizeOracle73 D1BodySized.inactive74 D1BodySized.bridgeOut73 D1BodySized.sizeTable20_73
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ74
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive74 : (bridgeOf D1BodySized.s255.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check74 : decide (20 ≤ D1BodySized.S255.tab.length) = true
theorem D1BodySized.fromTable20_74 : 20 ≤ D1BodySized.S255.tab.length := of_decide_eq_true D1BodySized.fromTable20Check74
kernel_rfl D1BodySized.bridgeInto74 : bridgeOf D1BodySized.s257.ffi = bridgeOf D1BodySized.s255.ffi
kernel_rfl D1BodySized.bridgeOut74 : bridgeOf D1BodySized.s258.ffi = bridgeOf D1BodySized.s257.ffi
kernel_rfl D1BodySized.sizeTable20Check74 : decide (20 ≤ D1BodySized.S257.tab.length) = true
theorem D1BodySized.sizeTable20_74 : 20 ≤ D1BodySized.S257.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check74
kernel_rfl D1BodySized.sizeOracle74 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S257.oracle = true

end Host.Load.Run.Tpl
end

section -- SP74
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece74 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s255 D1BodySized.S255) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s258 D1BodySized.S258) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted74 D1BodySized.segment74 D1BodySized.acceptedP75
    D1BodySized.haltP75 D1BodySized.stepA75 D1BodySized.topA75
    D1BodySized.oracle74 D1BodySized.fromInactive74 D1BodySized.bridgeInto74 D1BodySized.fromTable20_74
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA75 D1BodySized.sizeArgsA75 D1BodySized.sizeSymA75
    D1BodySized.sizeMlxA75 D1BodySized.sizePayA75 (by decide)
    D1BodySized.sizeDecA75 D1BodySized.sizePreA75 D1BodySized.patchB75
    D1BodySized.sizeOracle74 D1BodySized.inactive75 D1BodySized.bridgeOut74 D1BodySized.sizeTable20_74
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ75
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive75 : (bridgeOf D1BodySized.s258.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check75 : decide (20 ≤ D1BodySized.S258.tab.length) = true
theorem D1BodySized.fromTable20_75 : 20 ≤ D1BodySized.S258.tab.length := of_decide_eq_true D1BodySized.fromTable20Check75
kernel_rfl D1BodySized.bridgeInto75 : bridgeOf D1BodySized.s260.ffi = bridgeOf D1BodySized.s258.ffi
kernel_rfl D1BodySized.bridgeOut75 : bridgeOf D1BodySized.s261.ffi = bridgeOf D1BodySized.s260.ffi
kernel_rfl D1BodySized.sizeTable20Check75 : decide (20 ≤ D1BodySized.S260.tab.length) = true
theorem D1BodySized.sizeTable20_75 : 20 ≤ D1BodySized.S260.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check75
kernel_rfl D1BodySized.sizeOracle75 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S260.oracle = true

end Host.Load.Run.Tpl
end

section -- SP75
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece75 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s258 D1BodySized.S258) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s261 D1BodySized.S261) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted75 D1BodySized.segment75 D1BodySized.acceptedP76
    D1BodySized.haltP76 D1BodySized.stepA76 D1BodySized.topA76
    D1BodySized.oracle75 D1BodySized.fromInactive75 D1BodySized.bridgeInto75 D1BodySized.fromTable20_75
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA76 D1BodySized.sizeArgsA76 D1BodySized.sizeSymA76
    D1BodySized.sizeMlxA76 D1BodySized.sizePayA76 (by decide)
    D1BodySized.sizeDecA76 D1BodySized.sizePreA76 D1BodySized.patchB76
    D1BodySized.sizeOracle75 D1BodySized.inactive76 D1BodySized.bridgeOut75 D1BodySized.sizeTable20_75
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ76
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive76 : (bridgeOf D1BodySized.s261.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check76 : decide (20 ≤ D1BodySized.S261.tab.length) = true
theorem D1BodySized.fromTable20_76 : 20 ≤ D1BodySized.S261.tab.length := of_decide_eq_true D1BodySized.fromTable20Check76
kernel_rfl D1BodySized.bridgeInto76 : bridgeOf D1BodySized.s264.ffi = bridgeOf D1BodySized.s261.ffi
kernel_rfl D1BodySized.bridgeOut76 : bridgeOf D1BodySized.s265.ffi = bridgeOf D1BodySized.s264.ffi
kernel_rfl D1BodySized.sizeTable20Check76 : decide (20 ≤ D1BodySized.S264.tab.length) = true
theorem D1BodySized.sizeTable20_76 : 20 ≤ D1BodySized.S264.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check76
kernel_rfl D1BodySized.sizeOracle76 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S264.oracle = true

end Host.Load.Run.Tpl
end

section -- SP76
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece76 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s261 D1BodySized.S261) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s265 D1BodySized.S265) 13411 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted76 D1BodySized.segment76 D1BodySized.acceptedP77
    D1BodySized.haltP77 D1BodySized.stepA77 D1BodySized.topA77
    D1BodySized.oracle76 D1BodySized.fromInactive76 D1BodySized.bridgeInto76 D1BodySized.fromTable20_76
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA77 D1BodySized.sizeArgsA77 D1BodySized.sizeSymA77
    D1BodySized.sizeMlxA77 D1BodySized.sizePayA77 (by decide)
    D1BodySized.sizeDecA77 D1BodySized.sizePreA77 D1BodySized.patchB77
    D1BodySized.sizeOracle76 D1BodySized.inactive77 D1BodySized.bridgeOut76 D1BodySized.sizeTable20_76
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ77
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive77 : (bridgeOf D1BodySized.s265.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check77 : decide (20 ≤ D1BodySized.S265.tab.length) = true
theorem D1BodySized.fromTable20_77 : 20 ≤ D1BodySized.S265.tab.length := of_decide_eq_true D1BodySized.fromTable20Check77
kernel_rfl D1BodySized.bridgeInto77 : bridgeOf D1BodySized.s267.ffi = bridgeOf D1BodySized.s265.ffi
kernel_rfl D1BodySized.bridgeOut77 : bridgeOf D1BodySized.s268.ffi = bridgeOf D1BodySized.s267.ffi
kernel_rfl D1BodySized.sizeTable20Check77 : decide (20 ≤ D1BodySized.S267.tab.length) = true
theorem D1BodySized.sizeTable20_77 : 20 ≤ D1BodySized.S267.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check77
kernel_rfl D1BodySized.sizeOracle77 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S267.oracle = true

end Host.Load.Run.Tpl
end

section -- SP77
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece77 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s265 D1BodySized.S265) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s268 D1BodySized.S268) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted77 D1BodySized.segment77 D1BodySized.acceptedP78
    D1BodySized.haltP78 D1BodySized.stepA78 D1BodySized.topA78
    D1BodySized.oracle77 D1BodySized.fromInactive77 D1BodySized.bridgeInto77 D1BodySized.fromTable20_77
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA78 D1BodySized.sizeArgsA78 D1BodySized.sizeSymA78
    D1BodySized.sizeMlxA78 D1BodySized.sizePayA78 (by decide)
    D1BodySized.sizeDecA78 D1BodySized.sizePreA78 D1BodySized.patchB78
    D1BodySized.sizeOracle77 D1BodySized.inactive78 D1BodySized.bridgeOut77 D1BodySized.sizeTable20_77
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ78
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive78 : (bridgeOf D1BodySized.s268.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check78 : decide (20 ≤ D1BodySized.S268.tab.length) = true
theorem D1BodySized.fromTable20_78 : 20 ≤ D1BodySized.S268.tab.length := of_decide_eq_true D1BodySized.fromTable20Check78
kernel_rfl D1BodySized.bridgeInto78 : bridgeOf D1BodySized.s270.ffi = bridgeOf D1BodySized.s268.ffi
kernel_rfl D1BodySized.bridgeOut78 : bridgeOf D1BodySized.s271.ffi = bridgeOf D1BodySized.s270.ffi
kernel_rfl D1BodySized.sizeTable20Check78 : decide (20 ≤ D1BodySized.S270.tab.length) = true
theorem D1BodySized.sizeTable20_78 : 20 ≤ D1BodySized.S270.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check78
kernel_rfl D1BodySized.sizeOracle78 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S270.oracle = true

end Host.Load.Run.Tpl
end

section -- SP78
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece78 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s268 D1BodySized.S268) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s271 D1BodySized.S271) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted78 D1BodySized.segment78 D1BodySized.acceptedP79
    D1BodySized.haltP79 D1BodySized.stepA79 D1BodySized.topA79
    D1BodySized.oracle78 D1BodySized.fromInactive78 D1BodySized.bridgeInto78 D1BodySized.fromTable20_78
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA79 D1BodySized.sizeArgsA79 D1BodySized.sizeSymA79
    D1BodySized.sizeMlxA79 D1BodySized.sizePayA79 (by decide)
    D1BodySized.sizeDecA79 D1BodySized.sizePreA79 D1BodySized.patchB79
    D1BodySized.sizeOracle78 D1BodySized.inactive79 D1BodySized.bridgeOut78 D1BodySized.sizeTable20_78
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ79
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive79 : (bridgeOf D1BodySized.s271.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check79 : decide (20 ≤ D1BodySized.S271.tab.length) = true
theorem D1BodySized.fromTable20_79 : 20 ≤ D1BodySized.S271.tab.length := of_decide_eq_true D1BodySized.fromTable20Check79
kernel_rfl D1BodySized.bridgeInto79 : bridgeOf D1BodySized.s273.ffi = bridgeOf D1BodySized.s271.ffi
kernel_rfl D1BodySized.bridgeOut79 : bridgeOf D1BodySized.s274.ffi = bridgeOf D1BodySized.s273.ffi
kernel_rfl D1BodySized.sizeTable20Check79 : decide (20 ≤ D1BodySized.S273.tab.length) = true
theorem D1BodySized.sizeTable20_79 : 20 ≤ D1BodySized.S273.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check79
kernel_rfl D1BodySized.sizeOracle79 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S273.oracle = true

end Host.Load.Run.Tpl
end

section -- SP79
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece79 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s271 D1BodySized.S271) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s274 D1BodySized.S274) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted79 D1BodySized.segment79 D1BodySized.acceptedP80
    D1BodySized.haltP80 D1BodySized.stepA80 D1BodySized.topA80
    D1BodySized.oracle79 D1BodySized.fromInactive79 D1BodySized.bridgeInto79 D1BodySized.fromTable20_79
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA80 D1BodySized.sizeArgsA80 D1BodySized.sizeSymA80
    D1BodySized.sizeMlxA80 D1BodySized.sizePayA80 (by decide)
    D1BodySized.sizeDecA80 D1BodySized.sizePreA80 D1BodySized.patchB80
    D1BodySized.sizeOracle79 D1BodySized.inactive80 D1BodySized.bridgeOut79 D1BodySized.sizeTable20_79
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ80
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive80 : (bridgeOf D1BodySized.s274.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check80 : decide (20 ≤ D1BodySized.S274.tab.length) = true
theorem D1BodySized.fromTable20_80 : 20 ≤ D1BodySized.S274.tab.length := of_decide_eq_true D1BodySized.fromTable20Check80
kernel_rfl D1BodySized.bridgeInto80 : bridgeOf D1BodySized.s277.ffi = bridgeOf D1BodySized.s274.ffi
kernel_rfl D1BodySized.bridgeOut80 : bridgeOf D1BodySized.s278.ffi = bridgeOf D1BodySized.s277.ffi
kernel_rfl D1BodySized.sizeTable20Check80 : decide (20 ≤ D1BodySized.S277.tab.length) = true
theorem D1BodySized.sizeTable20_80 : 20 ≤ D1BodySized.S277.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check80
kernel_rfl D1BodySized.sizeOracle80 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S277.oracle = true

end Host.Load.Run.Tpl
end

section -- SP80
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece80 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s274 D1BodySized.S274) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s278 D1BodySized.S278) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted80 D1BodySized.segment80 D1BodySized.acceptedP81
    D1BodySized.haltP81 D1BodySized.stepA81 D1BodySized.topA81
    D1BodySized.oracle80 D1BodySized.fromInactive80 D1BodySized.bridgeInto80 D1BodySized.fromTable20_80
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA81 D1BodySized.sizeArgsA81 D1BodySized.sizeSymA81
    D1BodySized.sizeMlxA81 D1BodySized.sizePayA81 (by decide)
    D1BodySized.sizeDecA81 D1BodySized.sizePreA81 D1BodySized.patchB81
    D1BodySized.sizeOracle80 D1BodySized.inactive81 D1BodySized.bridgeOut80 D1BodySized.sizeTable20_80
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ81
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive81 : (bridgeOf D1BodySized.s278.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check81 : decide (20 ≤ D1BodySized.S278.tab.length) = true
theorem D1BodySized.fromTable20_81 : 20 ≤ D1BodySized.S278.tab.length := of_decide_eq_true D1BodySized.fromTable20Check81
kernel_rfl D1BodySized.bridgeInto81 : bridgeOf D1BodySized.s280.ffi = bridgeOf D1BodySized.s278.ffi
kernel_rfl D1BodySized.bridgeOut81 : bridgeOf D1BodySized.s281.ffi = bridgeOf D1BodySized.s280.ffi
kernel_rfl D1BodySized.sizeTable20Check81 : decide (20 ≤ D1BodySized.S280.tab.length) = true
theorem D1BodySized.sizeTable20_81 : 20 ≤ D1BodySized.S280.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check81
kernel_rfl D1BodySized.sizeOracle81 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S280.oracle = true

end Host.Load.Run.Tpl
end

section -- SP81
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece81 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s278 D1BodySized.S278) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s281 D1BodySized.S281) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted81 D1BodySized.segment81 D1BodySized.acceptedP82
    D1BodySized.haltP82 D1BodySized.stepA82 D1BodySized.topA82
    D1BodySized.oracle81 D1BodySized.fromInactive81 D1BodySized.bridgeInto81 D1BodySized.fromTable20_81
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA82 D1BodySized.sizeArgsA82 D1BodySized.sizeSymA82
    D1BodySized.sizeMlxA82 D1BodySized.sizePayA82 (by decide)
    D1BodySized.sizeDecA82 D1BodySized.sizePreA82 D1BodySized.patchB82
    D1BodySized.sizeOracle81 D1BodySized.inactive82 D1BodySized.bridgeOut81 D1BodySized.sizeTable20_81
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ82
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive82 : (bridgeOf D1BodySized.s281.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check82 : decide (20 ≤ D1BodySized.S281.tab.length) = true
theorem D1BodySized.fromTable20_82 : 20 ≤ D1BodySized.S281.tab.length := of_decide_eq_true D1BodySized.fromTable20Check82
kernel_rfl D1BodySized.bridgeInto82 : bridgeOf D1BodySized.s285.ffi = bridgeOf D1BodySized.s281.ffi
kernel_rfl D1BodySized.bridgeOut82 : bridgeOf D1BodySized.s286.ffi = bridgeOf D1BodySized.s285.ffi
kernel_rfl D1BodySized.sizeTable20Check82 : decide (20 ≤ D1BodySized.S285.tab.length) = true
theorem D1BodySized.sizeTable20_82 : 20 ≤ D1BodySized.S285.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check82
kernel_rfl D1BodySized.sizeOracle82 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S285.oracle = true

end Host.Load.Run.Tpl
end

section -- SP82
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece82 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s281 D1BodySized.S281) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s286 D1BodySized.S286) 22291 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted82 D1BodySized.segment82 D1BodySized.acceptedP83
    D1BodySized.haltP83 D1BodySized.stepA83 D1BodySized.topA83
    D1BodySized.oracle82 D1BodySized.fromInactive82 D1BodySized.bridgeInto82 D1BodySized.fromTable20_82
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA83 D1BodySized.sizeArgsA83 D1BodySized.sizeSymA83
    D1BodySized.sizeMlxA83 D1BodySized.sizePayA83 (by decide)
    D1BodySized.sizeDecA83 D1BodySized.sizePreA83 D1BodySized.patchB83
    D1BodySized.sizeOracle82 D1BodySized.inactive83 D1BodySized.bridgeOut82 D1BodySized.sizeTable20_82
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ83
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive83 : (bridgeOf D1BodySized.s286.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check83 : decide (20 ≤ D1BodySized.S286.tab.length) = true
theorem D1BodySized.fromTable20_83 : 20 ≤ D1BodySized.S286.tab.length := of_decide_eq_true D1BodySized.fromTable20Check83
kernel_rfl D1BodySized.bridgeInto83 : bridgeOf D1BodySized.s288.ffi = bridgeOf D1BodySized.s286.ffi
kernel_rfl D1BodySized.bridgeOut83 : bridgeOf D1BodySized.s289.ffi = bridgeOf D1BodySized.s288.ffi
kernel_rfl D1BodySized.sizeTable20Check83 : decide (20 ≤ D1BodySized.S288.tab.length) = true
theorem D1BodySized.sizeTable20_83 : 20 ≤ D1BodySized.S288.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check83
kernel_rfl D1BodySized.sizeOracle83 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S288.oracle = true

end Host.Load.Run.Tpl
end
