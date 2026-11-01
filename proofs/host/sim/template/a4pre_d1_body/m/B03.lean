import host.sim.template.a4pre_d1_body.TraceStep
import host.sim.template.a4pre_d1_body.m.B00
import host.sim.Chunk
import host.sim.template.a4pre_d1_body.m.B02
import host.sim.template.a4pre_d1_body.SizeLift

section -- SN164
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel164 : nth? D1BodySized.ks 164 = some 2570
kernel_rfl D1BodySized.checked164 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s164 D1BodySized.S164) =
    fun _ => some (D1BodySized.s165, D1BodySized.S165)

theorem D1BodySized.k164 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s164 D1BodySized.S164 =
      some (D1BodySized.s165, D1BodySized.S165) := congrFun D1BodySized.checked164 bs

end Host.Load.Run.Tpl
end

section -- SB47
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment47 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s163 D1BodySized.S163 =
      some (D1BodySized.s165, D1BodySized.S165) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s163 D1BodySized.s164 D1BodySized.s165 D1BodySized.S163 D1BodySized.S164 D1BodySized.S165 (D1BodySized.k163 bs) (D1BodySized.k164 bs)

kernel_rfl D1BodySized.accepted47 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s163 D1BodySized.S163) = fun _ => true
kernel_rfl D1BodySized.oracle47 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S163.oracle = true
kernel_rfl D1BodySized.fuelA48 : nth? D1BodySized.ks 165 = some 1
kernel_rfl D1BodySized.fuelB48 : nth? D1BodySized.ks 166 = some 3
kernel_rfl D1BodySized.stepA48 : interpS (step D1BodySized.F D1BodySized.s165).run D1BodySized.S165 =
  some (D1BodySized.s166, D1BodySized.S166)
kernel_rfl D1BodySized.patchB48 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s166).run D1BodySized.S166 =
  some (D1BodySized.s167, D1BodySized.S167)
kernel_rfl D1BodySized.acceptedP48 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s165 D1BodySized.S165) = fun _ => true
kernel_rfl D1BodySized.haltP48 : isHalt D1BodySized.s165.ctl = false
kernel_rfl D1BodySized.topA48 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s166 = true
kernel_rfl D1BodySized.inactive48 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s166.ffi).active = false
/-- Bridge 48's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys48 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s166 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs48 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s166 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA48 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s166 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys48, D1BodySized.sizeArgs48)
kernel_rfl D1BodySized.sizeArgsA48 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s166 = true
kernel_rfl D1BodySized.sizeSymA48 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA48 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA48 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA48 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec48 := interpS (decodeArgs D1BodySized.F D1BodySized.s166 D1BodySized.sizeTys48 D1BodySized.sizeArgs48).run D1BodySized.S166
noncomputable def D1BodySized.sizeAs48 : List Arg := match D1BodySized.sizeDec48 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS048 : SSrv := match D1BodySized.sizeDec48 with | some (_, S) => S | none => D1BodySized.S166
kernel_rfl D1BodySized.sizeDecA48 : interpS (decodeArgs D1BodySized.F D1BodySized.s166 D1BodySized.sizeTys48 D1BodySized.sizeArgs48).run D1BodySized.S166 =
  some (some D1BodySized.sizeAs48, D1BodySized.sizeS048)
kernel_rfl D1BodySized.sizePreA48 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS048 D1BodySized.s166.ffi D1BodySized.sizeAs48 = true

end Host.Load.Run.Tpl
end

section -- SN167
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel167 : nth? D1BodySized.ks 167 = some 2542
kernel_rfl D1BodySized.checked167 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s167 D1BodySized.S167) =
    fun _ => some (D1BodySized.s168, D1BodySized.S168)

theorem D1BodySized.k167 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s167 D1BodySized.S167 =
      some (D1BodySized.s168, D1BodySized.S168) := congrFun D1BodySized.checked167 bs

end Host.Load.Run.Tpl
end

section -- SB48
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment48 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s167 D1BodySized.S167 =
      some (D1BodySized.s168, D1BodySized.S168) := D1BodySized.k167 bs

kernel_rfl D1BodySized.accepted48 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s167 D1BodySized.S167) = fun _ => true
kernel_rfl D1BodySized.oracle48 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S167.oracle = true
kernel_rfl D1BodySized.fuelA49 : nth? D1BodySized.ks 168 = some 1
kernel_rfl D1BodySized.fuelB49 : nth? D1BodySized.ks 169 = some 3
kernel_rfl D1BodySized.stepA49 : interpS (step D1BodySized.F D1BodySized.s168).run D1BodySized.S168 =
  some (D1BodySized.s169, D1BodySized.S169)
kernel_rfl D1BodySized.patchB49 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s169).run D1BodySized.S169 =
  some (D1BodySized.s170, D1BodySized.S170)
kernel_rfl D1BodySized.acceptedP49 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s168 D1BodySized.S168) = fun _ => true
kernel_rfl D1BodySized.haltP49 : isHalt D1BodySized.s168.ctl = false
kernel_rfl D1BodySized.topA49 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s169 = true
kernel_rfl D1BodySized.inactive49 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s169.ffi).active = false
/-- Bridge 49's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys49 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s169 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs49 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s169 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA49 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s169 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys49, D1BodySized.sizeArgs49)
kernel_rfl D1BodySized.sizeArgsA49 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s169 = true
kernel_rfl D1BodySized.sizeSymA49 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA49 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA49 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA49 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec49 := interpS (decodeArgs D1BodySized.F D1BodySized.s169 D1BodySized.sizeTys49 D1BodySized.sizeArgs49).run D1BodySized.S169
noncomputable def D1BodySized.sizeAs49 : List Arg := match D1BodySized.sizeDec49 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS049 : SSrv := match D1BodySized.sizeDec49 with | some (_, S) => S | none => D1BodySized.S169
kernel_rfl D1BodySized.sizeDecA49 : interpS (decodeArgs D1BodySized.F D1BodySized.s169 D1BodySized.sizeTys49 D1BodySized.sizeArgs49).run D1BodySized.S169 =
  some (some D1BodySized.sizeAs49, D1BodySized.sizeS049)
kernel_rfl D1BodySized.sizePreA49 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS049 D1BodySized.s169.ffi D1BodySized.sizeAs49 = true

end Host.Load.Run.Tpl
end

section -- SN170
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel170 : nth? D1BodySized.ks 170 = some 7762
kernel_rfl D1BodySized.checked170 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s170 D1BodySized.S170) =
    fun _ => some (D1BodySized.s171, D1BodySized.S171)

theorem D1BodySized.k170 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s170 D1BodySized.S170 =
      some (D1BodySized.s171, D1BodySized.S171) := congrFun D1BodySized.checked170 bs

end Host.Load.Run.Tpl
end

section -- SB49
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment49 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s170 D1BodySized.S170 =
      some (D1BodySized.s171, D1BodySized.S171) := D1BodySized.k170 bs

kernel_rfl D1BodySized.accepted49 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s170 D1BodySized.S170) = fun _ => true
kernel_rfl D1BodySized.oracle49 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S170.oracle = true
kernel_rfl D1BodySized.fuelA50 : nth? D1BodySized.ks 171 = some 1
kernel_rfl D1BodySized.fuelB50 : nth? D1BodySized.ks 172 = some 3
kernel_rfl D1BodySized.stepA50 : interpS (step D1BodySized.F D1BodySized.s171).run D1BodySized.S171 =
  some (D1BodySized.s172, D1BodySized.S172)
kernel_rfl D1BodySized.patchB50 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s172).run D1BodySized.S172 =
  some (D1BodySized.s173, D1BodySized.S173)
kernel_rfl D1BodySized.acceptedP50 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s171 D1BodySized.S171) = fun _ => true
kernel_rfl D1BodySized.haltP50 : isHalt D1BodySized.s171.ctl = false
kernel_rfl D1BodySized.topA50 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s172 = true
kernel_rfl D1BodySized.inactive50 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s172.ffi).active = false
/-- Bridge 50's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys50 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s172 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs50 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s172 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA50 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s172 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys50, D1BodySized.sizeArgs50)
kernel_rfl D1BodySized.sizeArgsA50 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s172 = true
kernel_rfl D1BodySized.sizeSymA50 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA50 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA50 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA50 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec50 := interpS (decodeArgs D1BodySized.F D1BodySized.s172 D1BodySized.sizeTys50 D1BodySized.sizeArgs50).run D1BodySized.S172
noncomputable def D1BodySized.sizeAs50 : List Arg := match D1BodySized.sizeDec50 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS050 : SSrv := match D1BodySized.sizeDec50 with | some (_, S) => S | none => D1BodySized.S172
kernel_rfl D1BodySized.sizeDecA50 : interpS (decodeArgs D1BodySized.F D1BodySized.s172 D1BodySized.sizeTys50 D1BodySized.sizeArgs50).run D1BodySized.S172 =
  some (some D1BodySized.sizeAs50, D1BodySized.sizeS050)
kernel_rfl D1BodySized.sizePreA50 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS050 D1BodySized.s172.ffi D1BodySized.sizeAs50 = true

end Host.Load.Run.Tpl
end

section -- SN173
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel173 : nth? D1BodySized.ks 173 = some 1936
kernel_rfl D1BodySized.checked173 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s173 D1BodySized.S173) =
    fun _ => some (D1BodySized.s174, D1BodySized.S174)

theorem D1BodySized.k173 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s173 D1BodySized.S173 =
      some (D1BodySized.s174, D1BodySized.S174) := congrFun D1BodySized.checked173 bs

end Host.Load.Run.Tpl
end

section -- SB50
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment50 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s173 D1BodySized.S173 =
      some (D1BodySized.s174, D1BodySized.S174) := D1BodySized.k173 bs

kernel_rfl D1BodySized.accepted50 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s173 D1BodySized.S173) = fun _ => true
kernel_rfl D1BodySized.oracle50 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S173.oracle = true
kernel_rfl D1BodySized.fuelA51 : nth? D1BodySized.ks 174 = some 1
kernel_rfl D1BodySized.fuelB51 : nth? D1BodySized.ks 175 = some 3
kernel_rfl D1BodySized.stepA51 : interpS (step D1BodySized.F D1BodySized.s174).run D1BodySized.S174 =
  some (D1BodySized.s175, D1BodySized.S175)
kernel_rfl D1BodySized.patchB51 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s175).run D1BodySized.S175 =
  some (D1BodySized.s176, D1BodySized.S176)
kernel_rfl D1BodySized.acceptedP51 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s174 D1BodySized.S174) = fun _ => true
kernel_rfl D1BodySized.haltP51 : isHalt D1BodySized.s174.ctl = false
kernel_rfl D1BodySized.topA51 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s175 = true
kernel_rfl D1BodySized.inactive51 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s175.ffi).active = false
/-- Bridge 51's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys51 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s175 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs51 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s175 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA51 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s175 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys51, D1BodySized.sizeArgs51)
kernel_rfl D1BodySized.sizeArgsA51 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s175 = true
kernel_rfl D1BodySized.sizeSymA51 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA51 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA51 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA51 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec51 := interpS (decodeArgs D1BodySized.F D1BodySized.s175 D1BodySized.sizeTys51 D1BodySized.sizeArgs51).run D1BodySized.S175
noncomputable def D1BodySized.sizeAs51 : List Arg := match D1BodySized.sizeDec51 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS051 : SSrv := match D1BodySized.sizeDec51 with | some (_, S) => S | none => D1BodySized.S175
kernel_rfl D1BodySized.sizeDecA51 : interpS (decodeArgs D1BodySized.F D1BodySized.s175 D1BodySized.sizeTys51 D1BodySized.sizeArgs51).run D1BodySized.S175 =
  some (some D1BodySized.sizeAs51, D1BodySized.sizeS051)
kernel_rfl D1BodySized.sizePreA51 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS051 D1BodySized.s175.ffi D1BodySized.sizeAs51 = true

end Host.Load.Run.Tpl
end

section -- SN176
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel176 : nth? D1BodySized.ks 176 = some 10000
kernel_rfl D1BodySized.checked176 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s176 D1BodySized.S176) =
    fun _ => some (D1BodySized.s177, D1BodySized.S177)

theorem D1BodySized.k176 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s176 D1BodySized.S176 =
      some (D1BodySized.s177, D1BodySized.S177) := congrFun D1BodySized.checked176 bs

end Host.Load.Run.Tpl
end

section -- SN177
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel177 : nth? D1BodySized.ks 177 = some 2570
kernel_rfl D1BodySized.checked177 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s177 D1BodySized.S177) =
    fun _ => some (D1BodySized.s178, D1BodySized.S178)

theorem D1BodySized.k177 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s177 D1BodySized.S177 =
      some (D1BodySized.s178, D1BodySized.S178) := congrFun D1BodySized.checked177 bs

end Host.Load.Run.Tpl
end

section -- SB51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment51 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s176 D1BodySized.S176 =
      some (D1BodySized.s178, D1BodySized.S178) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s176 D1BodySized.s177 D1BodySized.s178 D1BodySized.S176 D1BodySized.S177 D1BodySized.S178 (D1BodySized.k176 bs) (D1BodySized.k177 bs)

kernel_rfl D1BodySized.accepted51 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s176 D1BodySized.S176) = fun _ => true
kernel_rfl D1BodySized.oracle51 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S176.oracle = true
kernel_rfl D1BodySized.fuelA52 : nth? D1BodySized.ks 178 = some 1
kernel_rfl D1BodySized.fuelB52 : nth? D1BodySized.ks 179 = some 3
kernel_rfl D1BodySized.stepA52 : interpS (step D1BodySized.F D1BodySized.s178).run D1BodySized.S178 =
  some (D1BodySized.s179, D1BodySized.S179)
kernel_rfl D1BodySized.patchB52 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s179).run D1BodySized.S179 =
  some (D1BodySized.s180, D1BodySized.S180)
kernel_rfl D1BodySized.acceptedP52 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s178 D1BodySized.S178) = fun _ => true
kernel_rfl D1BodySized.haltP52 : isHalt D1BodySized.s178.ctl = false
kernel_rfl D1BodySized.topA52 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s179 = true
kernel_rfl D1BodySized.inactive52 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s179.ffi).active = false
/-- Bridge 52's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys52 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s179 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs52 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s179 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA52 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s179 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys52, D1BodySized.sizeArgs52)
kernel_rfl D1BodySized.sizeArgsA52 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s179 = true
kernel_rfl D1BodySized.sizeSymA52 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA52 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA52 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA52 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec52 := interpS (decodeArgs D1BodySized.F D1BodySized.s179 D1BodySized.sizeTys52 D1BodySized.sizeArgs52).run D1BodySized.S179
noncomputable def D1BodySized.sizeAs52 : List Arg := match D1BodySized.sizeDec52 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS052 : SSrv := match D1BodySized.sizeDec52 with | some (_, S) => S | none => D1BodySized.S179
kernel_rfl D1BodySized.sizeDecA52 : interpS (decodeArgs D1BodySized.F D1BodySized.s179 D1BodySized.sizeTys52 D1BodySized.sizeArgs52).run D1BodySized.S179 =
  some (some D1BodySized.sizeAs52, D1BodySized.sizeS052)
kernel_rfl D1BodySized.sizePreA52 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS052 D1BodySized.s179.ffi D1BodySized.sizeAs52 = true

end Host.Load.Run.Tpl
end

section -- SN180
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel180 : nth? D1BodySized.ks 180 = some 2542
kernel_rfl D1BodySized.checked180 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s180 D1BodySized.S180) =
    fun _ => some (D1BodySized.s181, D1BodySized.S181)

theorem D1BodySized.k180 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s180 D1BodySized.S180 =
      some (D1BodySized.s181, D1BodySized.S181) := congrFun D1BodySized.checked180 bs

end Host.Load.Run.Tpl
end

section -- SB52
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment52 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s180 D1BodySized.S180 =
      some (D1BodySized.s181, D1BodySized.S181) := D1BodySized.k180 bs

kernel_rfl D1BodySized.accepted52 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s180 D1BodySized.S180) = fun _ => true
kernel_rfl D1BodySized.oracle52 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S180.oracle = true
kernel_rfl D1BodySized.fuelA53 : nth? D1BodySized.ks 181 = some 1
kernel_rfl D1BodySized.fuelB53 : nth? D1BodySized.ks 182 = some 3
kernel_rfl D1BodySized.stepA53 : interpS (step D1BodySized.F D1BodySized.s181).run D1BodySized.S181 =
  some (D1BodySized.s182, D1BodySized.S182)
kernel_rfl D1BodySized.patchB53 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s182).run D1BodySized.S182 =
  some (D1BodySized.s183, D1BodySized.S183)
kernel_rfl D1BodySized.acceptedP53 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s181 D1BodySized.S181) = fun _ => true
kernel_rfl D1BodySized.haltP53 : isHalt D1BodySized.s181.ctl = false
kernel_rfl D1BodySized.topA53 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s182 = true
kernel_rfl D1BodySized.inactive53 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s182.ffi).active = false
/-- Bridge 53's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys53 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s182 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs53 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s182 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA53 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s182 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys53, D1BodySized.sizeArgs53)
kernel_rfl D1BodySized.sizeArgsA53 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s182 = true
kernel_rfl D1BodySized.sizeSymA53 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA53 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA53 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA53 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec53 := interpS (decodeArgs D1BodySized.F D1BodySized.s182 D1BodySized.sizeTys53 D1BodySized.sizeArgs53).run D1BodySized.S182
noncomputable def D1BodySized.sizeAs53 : List Arg := match D1BodySized.sizeDec53 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS053 : SSrv := match D1BodySized.sizeDec53 with | some (_, S) => S | none => D1BodySized.S182
kernel_rfl D1BodySized.sizeDecA53 : interpS (decodeArgs D1BodySized.F D1BodySized.s182 D1BodySized.sizeTys53 D1BodySized.sizeArgs53).run D1BodySized.S182 =
  some (some D1BodySized.sizeAs53, D1BodySized.sizeS053)
kernel_rfl D1BodySized.sizePreA53 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS053 D1BodySized.s182.ffi D1BodySized.sizeAs53 = true

end Host.Load.Run.Tpl
end

section -- SN183
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel183 : nth? D1BodySized.ks 183 = some 7762
kernel_rfl D1BodySized.checked183 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s183 D1BodySized.S183) =
    fun _ => some (D1BodySized.s184, D1BodySized.S184)

theorem D1BodySized.k183 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s183 D1BodySized.S183 =
      some (D1BodySized.s184, D1BodySized.S184) := congrFun D1BodySized.checked183 bs

end Host.Load.Run.Tpl
end

section -- SB53
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment53 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s183 D1BodySized.S183 =
      some (D1BodySized.s184, D1BodySized.S184) := D1BodySized.k183 bs

kernel_rfl D1BodySized.accepted53 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s183 D1BodySized.S183) = fun _ => true
kernel_rfl D1BodySized.oracle53 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S183.oracle = true
kernel_rfl D1BodySized.fuelA54 : nth? D1BodySized.ks 184 = some 1
kernel_rfl D1BodySized.fuelB54 : nth? D1BodySized.ks 185 = some 3
kernel_rfl D1BodySized.stepA54 : interpS (step D1BodySized.F D1BodySized.s184).run D1BodySized.S184 =
  some (D1BodySized.s185, D1BodySized.S185)
kernel_rfl D1BodySized.patchB54 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s185).run D1BodySized.S185 =
  some (D1BodySized.s186, D1BodySized.S186)
kernel_rfl D1BodySized.acceptedP54 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s184 D1BodySized.S184) = fun _ => true
kernel_rfl D1BodySized.haltP54 : isHalt D1BodySized.s184.ctl = false
kernel_rfl D1BodySized.topA54 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s185 = true
kernel_rfl D1BodySized.inactive54 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s185.ffi).active = false
/-- Bridge 54's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys54 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s185 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs54 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s185 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA54 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s185 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys54, D1BodySized.sizeArgs54)
kernel_rfl D1BodySized.sizeArgsA54 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s185 = true
kernel_rfl D1BodySized.sizeSymA54 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA54 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA54 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA54 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec54 := interpS (decodeArgs D1BodySized.F D1BodySized.s185 D1BodySized.sizeTys54 D1BodySized.sizeArgs54).run D1BodySized.S185
noncomputable def D1BodySized.sizeAs54 : List Arg := match D1BodySized.sizeDec54 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS054 : SSrv := match D1BodySized.sizeDec54 with | some (_, S) => S | none => D1BodySized.S185
kernel_rfl D1BodySized.sizeDecA54 : interpS (decodeArgs D1BodySized.F D1BodySized.s185 D1BodySized.sizeTys54 D1BodySized.sizeArgs54).run D1BodySized.S185 =
  some (some D1BodySized.sizeAs54, D1BodySized.sizeS054)
kernel_rfl D1BodySized.sizePreA54 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS054 D1BodySized.s185.ffi D1BodySized.sizeAs54 = true

end Host.Load.Run.Tpl
end

section -- SN186
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel186 : nth? D1BodySized.ks 186 = some 1936
kernel_rfl D1BodySized.checked186 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s186 D1BodySized.S186) =
    fun _ => some (D1BodySized.s187, D1BodySized.S187)

theorem D1BodySized.k186 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s186 D1BodySized.S186 =
      some (D1BodySized.s187, D1BodySized.S187) := congrFun D1BodySized.checked186 bs

end Host.Load.Run.Tpl
end

section -- SB54
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment54 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s186 D1BodySized.S186 =
      some (D1BodySized.s187, D1BodySized.S187) := D1BodySized.k186 bs

kernel_rfl D1BodySized.accepted54 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s186 D1BodySized.S186) = fun _ => true
kernel_rfl D1BodySized.oracle54 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S186.oracle = true
kernel_rfl D1BodySized.fuelA55 : nth? D1BodySized.ks 187 = some 1
kernel_rfl D1BodySized.fuelB55 : nth? D1BodySized.ks 188 = some 3
kernel_rfl D1BodySized.stepA55 : interpS (step D1BodySized.F D1BodySized.s187).run D1BodySized.S187 =
  some (D1BodySized.s188, D1BodySized.S188)
kernel_rfl D1BodySized.patchB55 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s188).run D1BodySized.S188 =
  some (D1BodySized.s189, D1BodySized.S189)
kernel_rfl D1BodySized.acceptedP55 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s187 D1BodySized.S187) = fun _ => true
kernel_rfl D1BodySized.haltP55 : isHalt D1BodySized.s187.ctl = false
kernel_rfl D1BodySized.topA55 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s188 = true
kernel_rfl D1BodySized.inactive55 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s188.ffi).active = false
/-- Bridge 55's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys55 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s188 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs55 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s188 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA55 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s188 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys55, D1BodySized.sizeArgs55)
kernel_rfl D1BodySized.sizeArgsA55 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s188 = true
kernel_rfl D1BodySized.sizeSymA55 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA55 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA55 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA55 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec55 := interpS (decodeArgs D1BodySized.F D1BodySized.s188 D1BodySized.sizeTys55 D1BodySized.sizeArgs55).run D1BodySized.S188
noncomputable def D1BodySized.sizeAs55 : List Arg := match D1BodySized.sizeDec55 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS055 : SSrv := match D1BodySized.sizeDec55 with | some (_, S) => S | none => D1BodySized.S188
kernel_rfl D1BodySized.sizeDecA55 : interpS (decodeArgs D1BodySized.F D1BodySized.s188 D1BodySized.sizeTys55 D1BodySized.sizeArgs55).run D1BodySized.S188 =
  some (some D1BodySized.sizeAs55, D1BodySized.sizeS055)
kernel_rfl D1BodySized.sizePreA55 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS055 D1BodySized.s188.ffi D1BodySized.sizeAs55 = true

end Host.Load.Run.Tpl
end

section -- SN189
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel189 : nth? D1BodySized.ks 189 = some 10000
kernel_rfl D1BodySized.checked189 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s189 D1BodySized.S189) =
    fun _ => some (D1BodySized.s190, D1BodySized.S190)

theorem D1BodySized.k189 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s189 D1BodySized.S189 =
      some (D1BodySized.s190, D1BodySized.S190) := congrFun D1BodySized.checked189 bs

end Host.Load.Run.Tpl
end

section -- SN190
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel190 : nth? D1BodySized.ks 190 = some 2570
kernel_rfl D1BodySized.checked190 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s190 D1BodySized.S190) =
    fun _ => some (D1BodySized.s191, D1BodySized.S191)

theorem D1BodySized.k190 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s190 D1BodySized.S190 =
      some (D1BodySized.s191, D1BodySized.S191) := congrFun D1BodySized.checked190 bs

end Host.Load.Run.Tpl
end

section -- SB55
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment55 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s189 D1BodySized.S189 =
      some (D1BodySized.s191, D1BodySized.S191) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s189 D1BodySized.s190 D1BodySized.s191 D1BodySized.S189 D1BodySized.S190 D1BodySized.S191 (D1BodySized.k189 bs) (D1BodySized.k190 bs)

kernel_rfl D1BodySized.accepted55 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s189 D1BodySized.S189) = fun _ => true
kernel_rfl D1BodySized.oracle55 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S189.oracle = true
kernel_rfl D1BodySized.fuelA56 : nth? D1BodySized.ks 191 = some 1
kernel_rfl D1BodySized.fuelB56 : nth? D1BodySized.ks 192 = some 3
kernel_rfl D1BodySized.stepA56 : interpS (step D1BodySized.F D1BodySized.s191).run D1BodySized.S191 =
  some (D1BodySized.s192, D1BodySized.S192)
kernel_rfl D1BodySized.patchB56 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s192).run D1BodySized.S192 =
  some (D1BodySized.s193, D1BodySized.S193)
kernel_rfl D1BodySized.acceptedP56 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s191 D1BodySized.S191) = fun _ => true
kernel_rfl D1BodySized.haltP56 : isHalt D1BodySized.s191.ctl = false
kernel_rfl D1BodySized.topA56 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s192 = true
kernel_rfl D1BodySized.inactive56 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s192.ffi).active = false
/-- Bridge 56's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys56 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s192 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs56 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s192 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA56 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s192 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys56, D1BodySized.sizeArgs56)
kernel_rfl D1BodySized.sizeArgsA56 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s192 = true
kernel_rfl D1BodySized.sizeSymA56 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA56 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA56 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA56 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec56 := interpS (decodeArgs D1BodySized.F D1BodySized.s192 D1BodySized.sizeTys56 D1BodySized.sizeArgs56).run D1BodySized.S192
noncomputable def D1BodySized.sizeAs56 : List Arg := match D1BodySized.sizeDec56 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS056 : SSrv := match D1BodySized.sizeDec56 with | some (_, S) => S | none => D1BodySized.S192
kernel_rfl D1BodySized.sizeDecA56 : interpS (decodeArgs D1BodySized.F D1BodySized.s192 D1BodySized.sizeTys56 D1BodySized.sizeArgs56).run D1BodySized.S192 =
  some (some D1BodySized.sizeAs56, D1BodySized.sizeS056)
kernel_rfl D1BodySized.sizePreA56 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS056 D1BodySized.s192.ffi D1BodySized.sizeAs56 = true

end Host.Load.Run.Tpl
end

section -- SN193
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel193 : nth? D1BodySized.ks 193 = some 2542
kernel_rfl D1BodySized.checked193 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s193 D1BodySized.S193) =
    fun _ => some (D1BodySized.s194, D1BodySized.S194)

theorem D1BodySized.k193 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s193 D1BodySized.S193 =
      some (D1BodySized.s194, D1BodySized.S194) := congrFun D1BodySized.checked193 bs

end Host.Load.Run.Tpl
end

section -- SB56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment56 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s193 D1BodySized.S193 =
      some (D1BodySized.s194, D1BodySized.S194) := D1BodySized.k193 bs

kernel_rfl D1BodySized.accepted56 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s193 D1BodySized.S193) = fun _ => true
kernel_rfl D1BodySized.oracle56 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S193.oracle = true
kernel_rfl D1BodySized.fuelA57 : nth? D1BodySized.ks 194 = some 1
kernel_rfl D1BodySized.fuelB57 : nth? D1BodySized.ks 195 = some 3
kernel_rfl D1BodySized.stepA57 : interpS (step D1BodySized.F D1BodySized.s194).run D1BodySized.S194 =
  some (D1BodySized.s195, D1BodySized.S195)
kernel_rfl D1BodySized.patchB57 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s195).run D1BodySized.S195 =
  some (D1BodySized.s196, D1BodySized.S196)
kernel_rfl D1BodySized.acceptedP57 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s194 D1BodySized.S194) = fun _ => true
kernel_rfl D1BodySized.haltP57 : isHalt D1BodySized.s194.ctl = false
kernel_rfl D1BodySized.topA57 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s195 = true
kernel_rfl D1BodySized.inactive57 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s195.ffi).active = false
/-- Bridge 57's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys57 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s195 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs57 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s195 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA57 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s195 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys57, D1BodySized.sizeArgs57)
kernel_rfl D1BodySized.sizeArgsA57 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s195 = true
kernel_rfl D1BodySized.sizeSymA57 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA57 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA57 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA57 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec57 := interpS (decodeArgs D1BodySized.F D1BodySized.s195 D1BodySized.sizeTys57 D1BodySized.sizeArgs57).run D1BodySized.S195
noncomputable def D1BodySized.sizeAs57 : List Arg := match D1BodySized.sizeDec57 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS057 : SSrv := match D1BodySized.sizeDec57 with | some (_, S) => S | none => D1BodySized.S195
kernel_rfl D1BodySized.sizeDecA57 : interpS (decodeArgs D1BodySized.F D1BodySized.s195 D1BodySized.sizeTys57 D1BodySized.sizeArgs57).run D1BodySized.S195 =
  some (some D1BodySized.sizeAs57, D1BodySized.sizeS057)
kernel_rfl D1BodySized.sizePreA57 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS057 D1BodySized.s195.ffi D1BodySized.sizeAs57 = true

end Host.Load.Run.Tpl
end

section -- SN196
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel196 : nth? D1BodySized.ks 196 = some 10000
kernel_rfl D1BodySized.checked196 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s196 D1BodySized.S196) =
    fun _ => some (D1BodySized.s197, D1BodySized.S197)

theorem D1BodySized.k196 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s196 D1BodySized.S196 =
      some (D1BodySized.s197, D1BodySized.S197) := congrFun D1BodySized.checked196 bs

end Host.Load.Run.Tpl
end

section -- SN197
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel197 : nth? D1BodySized.ks 197 = some 10000
kernel_rfl D1BodySized.checked197 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s197 D1BodySized.S197) =
    fun _ => some (D1BodySized.s198, D1BodySized.S198)

theorem D1BodySized.k197 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s197 D1BodySized.S197 =
      some (D1BodySized.s198, D1BodySized.S198) := congrFun D1BodySized.checked197 bs

end Host.Load.Run.Tpl
end

section -- SN198
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel198 : nth? D1BodySized.ks 198 = some 2333
kernel_rfl D1BodySized.checked198 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2333 D1BodySized.s198 D1BodySized.S198) =
    fun _ => some (D1BodySized.s199, D1BodySized.S199)

theorem D1BodySized.k198 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2333 D1BodySized.s198 D1BodySized.S198 =
      some (D1BodySized.s199, D1BodySized.S199) := congrFun D1BodySized.checked198 bs

end Host.Load.Run.Tpl
end

section -- SB57
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment57 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22333 D1BodySized.s196 D1BodySized.S196 =
      some (D1BodySized.s199, D1BodySized.S199) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2333 D1BodySized.s196 D1BodySized.s198 D1BodySized.s199 D1BodySized.S196 D1BodySized.S198 D1BodySized.S199 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s196 D1BodySized.s197 D1BodySized.s198 D1BodySized.S196 D1BodySized.S197 D1BodySized.S198 (D1BodySized.k196 bs) (D1BodySized.k197 bs)) (D1BodySized.k198 bs)

kernel_rfl D1BodySized.accepted57 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s196 D1BodySized.S196) = fun _ => true
kernel_rfl D1BodySized.oracle57 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S196.oracle = true
kernel_rfl D1BodySized.fuelA58 : nth? D1BodySized.ks 199 = some 1
kernel_rfl D1BodySized.fuelB58 : nth? D1BodySized.ks 200 = some 3
kernel_rfl D1BodySized.stepA58 : interpS (step D1BodySized.F D1BodySized.s199).run D1BodySized.S199 =
  some (D1BodySized.s200, D1BodySized.S200)
kernel_rfl D1BodySized.patchB58 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s200).run D1BodySized.S200 =
  some (D1BodySized.s201, D1BodySized.S201)
kernel_rfl D1BodySized.acceptedP58 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s199 D1BodySized.S199) = fun _ => true
kernel_rfl D1BodySized.haltP58 : isHalt D1BodySized.s199.ctl = false
kernel_rfl D1BodySized.topA58 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s200 = true
kernel_rfl D1BodySized.inactive58 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s200.ffi).active = false
/-- Bridge 58's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys58 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s200 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs58 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s200 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA58 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s200 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys58, D1BodySized.sizeArgs58)
kernel_rfl D1BodySized.sizeArgsA58 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s200 = true
kernel_rfl D1BodySized.sizeSymA58 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA58 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA58 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA58 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec58 := interpS (decodeArgs D1BodySized.F D1BodySized.s200 D1BodySized.sizeTys58 D1BodySized.sizeArgs58).run D1BodySized.S200
noncomputable def D1BodySized.sizeAs58 : List Arg := match D1BodySized.sizeDec58 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS058 : SSrv := match D1BodySized.sizeDec58 with | some (_, S) => S | none => D1BodySized.S200
kernel_rfl D1BodySized.sizeDecA58 : interpS (decodeArgs D1BodySized.F D1BodySized.s200 D1BodySized.sizeTys58 D1BodySized.sizeArgs58).run D1BodySized.S200 =
  some (some D1BodySized.sizeAs58, D1BodySized.sizeS058)
kernel_rfl D1BodySized.sizePreA58 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS058 D1BodySized.s200.ffi D1BodySized.sizeAs58 = true

end Host.Load.Run.Tpl
end

section -- SN201
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel201 : nth? D1BodySized.ks 201 = some 7934
kernel_rfl D1BodySized.checked201 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s201 D1BodySized.S201) =
    fun _ => some (D1BodySized.s202, D1BodySized.S202)

theorem D1BodySized.k201 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s201 D1BodySized.S201 =
      some (D1BodySized.s202, D1BodySized.S202) := congrFun D1BodySized.checked201 bs

end Host.Load.Run.Tpl
end

section -- SB58
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment58 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7934 D1BodySized.s201 D1BodySized.S201 =
      some (D1BodySized.s202, D1BodySized.S202) := D1BodySized.k201 bs

kernel_rfl D1BodySized.accepted58 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s201 D1BodySized.S201) = fun _ => true
kernel_rfl D1BodySized.oracle58 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S201.oracle = true
kernel_rfl D1BodySized.fuelA59 : nth? D1BodySized.ks 202 = some 1
kernel_rfl D1BodySized.fuelB59 : nth? D1BodySized.ks 203 = some 3
kernel_rfl D1BodySized.stepA59 : interpS (step D1BodySized.F D1BodySized.s202).run D1BodySized.S202 =
  some (D1BodySized.s203, D1BodySized.S203)
kernel_rfl D1BodySized.patchB59 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s203).run D1BodySized.S203 =
  some (D1BodySized.s204, D1BodySized.S204)
kernel_rfl D1BodySized.acceptedP59 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s202 D1BodySized.S202) = fun _ => true
kernel_rfl D1BodySized.haltP59 : isHalt D1BodySized.s202.ctl = false
kernel_rfl D1BodySized.topA59 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s203 = true
kernel_rfl D1BodySized.inactive59 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s203.ffi).active = false
/-- Bridge 59's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys59 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s203 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs59 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s203 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA59 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s203 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys59, D1BodySized.sizeArgs59)
kernel_rfl D1BodySized.sizeArgsA59 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s203 = true
kernel_rfl D1BodySized.sizeSymA59 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA59 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA59 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA59 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec59 := interpS (decodeArgs D1BodySized.F D1BodySized.s203 D1BodySized.sizeTys59 D1BodySized.sizeArgs59).run D1BodySized.S203
noncomputable def D1BodySized.sizeAs59 : List Arg := match D1BodySized.sizeDec59 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS059 : SSrv := match D1BodySized.sizeDec59 with | some (_, S) => S | none => D1BodySized.S203
kernel_rfl D1BodySized.sizeDecA59 : interpS (decodeArgs D1BodySized.F D1BodySized.s203 D1BodySized.sizeTys59 D1BodySized.sizeArgs59).run D1BodySized.S203 =
  some (some D1BodySized.sizeAs59, D1BodySized.sizeS059)
kernel_rfl D1BodySized.sizePreA59 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS059 D1BodySized.s203.ffi D1BodySized.sizeAs59 = true

end Host.Load.Run.Tpl
end

section -- SN204
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel204 : nth? D1BodySized.ks 204 = some 1936
kernel_rfl D1BodySized.checked204 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s204 D1BodySized.S204) =
    fun _ => some (D1BodySized.s205, D1BodySized.S205)

theorem D1BodySized.k204 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s204 D1BodySized.S204 =
      some (D1BodySized.s205, D1BodySized.S205) := congrFun D1BodySized.checked204 bs

end Host.Load.Run.Tpl
end

section -- SB59
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment59 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s204 D1BodySized.S204 =
      some (D1BodySized.s205, D1BodySized.S205) := D1BodySized.k204 bs

kernel_rfl D1BodySized.accepted59 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s204 D1BodySized.S204) = fun _ => true
kernel_rfl D1BodySized.oracle59 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S204.oracle = true
kernel_rfl D1BodySized.fuelA60 : nth? D1BodySized.ks 205 = some 1
kernel_rfl D1BodySized.fuelB60 : nth? D1BodySized.ks 206 = some 3
kernel_rfl D1BodySized.stepA60 : interpS (step D1BodySized.F D1BodySized.s205).run D1BodySized.S205 =
  some (D1BodySized.s206, D1BodySized.S206)
kernel_rfl D1BodySized.patchB60 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s206).run D1BodySized.S206 =
  some (D1BodySized.s207, D1BodySized.S207)
kernel_rfl D1BodySized.acceptedP60 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s205 D1BodySized.S205) = fun _ => true
kernel_rfl D1BodySized.haltP60 : isHalt D1BodySized.s205.ctl = false
kernel_rfl D1BodySized.topA60 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s206 = true
kernel_rfl D1BodySized.inactive60 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s206.ffi).active = false
/-- Bridge 60's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys60 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s206 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs60 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s206 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA60 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s206 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys60, D1BodySized.sizeArgs60)
kernel_rfl D1BodySized.sizeArgsA60 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s206 = true
kernel_rfl D1BodySized.sizeSymA60 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA60 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA60 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA60 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec60 := interpS (decodeArgs D1BodySized.F D1BodySized.s206 D1BodySized.sizeTys60 D1BodySized.sizeArgs60).run D1BodySized.S206
noncomputable def D1BodySized.sizeAs60 : List Arg := match D1BodySized.sizeDec60 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS060 : SSrv := match D1BodySized.sizeDec60 with | some (_, S) => S | none => D1BodySized.S206
kernel_rfl D1BodySized.sizeDecA60 : interpS (decodeArgs D1BodySized.F D1BodySized.s206 D1BodySized.sizeTys60 D1BodySized.sizeArgs60).run D1BodySized.S206 =
  some (some D1BodySized.sizeAs60, D1BodySized.sizeS060)
kernel_rfl D1BodySized.sizePreA60 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS060 D1BodySized.s206.ffi D1BodySized.sizeAs60 = true

end Host.Load.Run.Tpl
end

section -- SN207
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel207 : nth? D1BodySized.ks 207 = some 10000
kernel_rfl D1BodySized.checked207 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s207 D1BodySized.S207) =
    fun _ => some (D1BodySized.s208, D1BodySized.S208)

theorem D1BodySized.k207 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s207 D1BodySized.S207 =
      some (D1BodySized.s208, D1BodySized.S208) := congrFun D1BodySized.checked207 bs

end Host.Load.Run.Tpl
end

section -- SN208
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel208 : nth? D1BodySized.ks 208 = some 2570
kernel_rfl D1BodySized.checked208 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s208 D1BodySized.S208) =
    fun _ => some (D1BodySized.s209, D1BodySized.S209)

theorem D1BodySized.k208 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s208 D1BodySized.S208 =
      some (D1BodySized.s209, D1BodySized.S209) := congrFun D1BodySized.checked208 bs

end Host.Load.Run.Tpl
end

section -- SB60
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment60 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s207 D1BodySized.S207 =
      some (D1BodySized.s209, D1BodySized.S209) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s207 D1BodySized.s208 D1BodySized.s209 D1BodySized.S207 D1BodySized.S208 D1BodySized.S209 (D1BodySized.k207 bs) (D1BodySized.k208 bs)

kernel_rfl D1BodySized.accepted60 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s207 D1BodySized.S207) = fun _ => true
kernel_rfl D1BodySized.oracle60 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S207.oracle = true
kernel_rfl D1BodySized.fuelA61 : nth? D1BodySized.ks 209 = some 1
kernel_rfl D1BodySized.fuelB61 : nth? D1BodySized.ks 210 = some 3
kernel_rfl D1BodySized.stepA61 : interpS (step D1BodySized.F D1BodySized.s209).run D1BodySized.S209 =
  some (D1BodySized.s210, D1BodySized.S210)
kernel_rfl D1BodySized.patchB61 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s210).run D1BodySized.S210 =
  some (D1BodySized.s211, D1BodySized.S211)
kernel_rfl D1BodySized.acceptedP61 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s209 D1BodySized.S209) = fun _ => true
kernel_rfl D1BodySized.haltP61 : isHalt D1BodySized.s209.ctl = false
kernel_rfl D1BodySized.topA61 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s210 = true
kernel_rfl D1BodySized.inactive61 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s210.ffi).active = false
/-- Bridge 61's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys61 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s210 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs61 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s210 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA61 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s210 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys61, D1BodySized.sizeArgs61)
kernel_rfl D1BodySized.sizeArgsA61 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s210 = true
kernel_rfl D1BodySized.sizeSymA61 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA61 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA61 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA61 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec61 := interpS (decodeArgs D1BodySized.F D1BodySized.s210 D1BodySized.sizeTys61 D1BodySized.sizeArgs61).run D1BodySized.S210
noncomputable def D1BodySized.sizeAs61 : List Arg := match D1BodySized.sizeDec61 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS061 : SSrv := match D1BodySized.sizeDec61 with | some (_, S) => S | none => D1BodySized.S210
kernel_rfl D1BodySized.sizeDecA61 : interpS (decodeArgs D1BodySized.F D1BodySized.s210 D1BodySized.sizeTys61 D1BodySized.sizeArgs61).run D1BodySized.S210 =
  some (some D1BodySized.sizeAs61, D1BodySized.sizeS061)
kernel_rfl D1BodySized.sizePreA61 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS061 D1BodySized.s210.ffi D1BodySized.sizeAs61 = true

end Host.Load.Run.Tpl
end

section -- SN211
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel211 : nth? D1BodySized.ks 211 = some 2542
kernel_rfl D1BodySized.checked211 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s211 D1BodySized.S211) =
    fun _ => some (D1BodySized.s212, D1BodySized.S212)

theorem D1BodySized.k211 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s211 D1BodySized.S211 =
      some (D1BodySized.s212, D1BodySized.S212) := congrFun D1BodySized.checked211 bs

end Host.Load.Run.Tpl
end

section -- SB61
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment61 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s211 D1BodySized.S211 =
      some (D1BodySized.s212, D1BodySized.S212) := D1BodySized.k211 bs

kernel_rfl D1BodySized.accepted61 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s211 D1BodySized.S211) = fun _ => true
kernel_rfl D1BodySized.oracle61 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S211.oracle = true
kernel_rfl D1BodySized.fuelA62 : nth? D1BodySized.ks 212 = some 1
kernel_rfl D1BodySized.fuelB62 : nth? D1BodySized.ks 213 = some 3
kernel_rfl D1BodySized.stepA62 : interpS (step D1BodySized.F D1BodySized.s212).run D1BodySized.S212 =
  some (D1BodySized.s213, D1BodySized.S213)
kernel_rfl D1BodySized.patchB62 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s213).run D1BodySized.S213 =
  some (D1BodySized.s214, D1BodySized.S214)
kernel_rfl D1BodySized.acceptedP62 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s212 D1BodySized.S212) = fun _ => true
kernel_rfl D1BodySized.haltP62 : isHalt D1BodySized.s212.ctl = false
kernel_rfl D1BodySized.topA62 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s213 = true
kernel_rfl D1BodySized.inactive62 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s213.ffi).active = false
/-- Bridge 62's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys62 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s213 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs62 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s213 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA62 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s213 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys62, D1BodySized.sizeArgs62)
kernel_rfl D1BodySized.sizeArgsA62 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s213 = true
kernel_rfl D1BodySized.sizeSymA62 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA62 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA62 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA62 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec62 := interpS (decodeArgs D1BodySized.F D1BodySized.s213 D1BodySized.sizeTys62 D1BodySized.sizeArgs62).run D1BodySized.S213
noncomputable def D1BodySized.sizeAs62 : List Arg := match D1BodySized.sizeDec62 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS062 : SSrv := match D1BodySized.sizeDec62 with | some (_, S) => S | none => D1BodySized.S213
kernel_rfl D1BodySized.sizeDecA62 : interpS (decodeArgs D1BodySized.F D1BodySized.s213 D1BodySized.sizeTys62 D1BodySized.sizeArgs62).run D1BodySized.S213 =
  some (some D1BodySized.sizeAs62, D1BodySized.sizeS062)
kernel_rfl D1BodySized.sizePreA62 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS062 D1BodySized.s213.ffi D1BodySized.sizeAs62 = true

end Host.Load.Run.Tpl
end

section -- SN214
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel214 : nth? D1BodySized.ks 214 = some 7716
kernel_rfl D1BodySized.checked214 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s214 D1BodySized.S214) =
    fun _ => some (D1BodySized.s215, D1BodySized.S215)

theorem D1BodySized.k214 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s214 D1BodySized.S214 =
      some (D1BodySized.s215, D1BodySized.S215) := congrFun D1BodySized.checked214 bs

end Host.Load.Run.Tpl
end

section -- SB62
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment62 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s214 D1BodySized.S214 =
      some (D1BodySized.s215, D1BodySized.S215) := D1BodySized.k214 bs

kernel_rfl D1BodySized.accepted62 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s214 D1BodySized.S214) = fun _ => true
kernel_rfl D1BodySized.oracle62 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S214.oracle = true
kernel_rfl D1BodySized.fuelA63 : nth? D1BodySized.ks 215 = some 1
kernel_rfl D1BodySized.fuelB63 : nth? D1BodySized.ks 216 = some 3
kernel_rfl D1BodySized.stepA63 : interpS (step D1BodySized.F D1BodySized.s215).run D1BodySized.S215 =
  some (D1BodySized.s216, D1BodySized.S216)
kernel_rfl D1BodySized.patchB63 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s216).run D1BodySized.S216 =
  some (D1BodySized.s217, D1BodySized.S217)
kernel_rfl D1BodySized.acceptedP63 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s215 D1BodySized.S215) = fun _ => true
kernel_rfl D1BodySized.haltP63 : isHalt D1BodySized.s215.ctl = false
kernel_rfl D1BodySized.topA63 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s216 = true
kernel_rfl D1BodySized.inactive63 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s216.ffi).active = false
/-- Bridge 63's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys63 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s216 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs63 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s216 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA63 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s216 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys63, D1BodySized.sizeArgs63)
kernel_rfl D1BodySized.sizeArgsA63 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s216 = true
kernel_rfl D1BodySized.sizeSymA63 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA63 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA63 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA63 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec63 := interpS (decodeArgs D1BodySized.F D1BodySized.s216 D1BodySized.sizeTys63 D1BodySized.sizeArgs63).run D1BodySized.S216
noncomputable def D1BodySized.sizeAs63 : List Arg := match D1BodySized.sizeDec63 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS063 : SSrv := match D1BodySized.sizeDec63 with | some (_, S) => S | none => D1BodySized.S216
kernel_rfl D1BodySized.sizeDecA63 : interpS (decodeArgs D1BodySized.F D1BodySized.s216 D1BodySized.sizeTys63 D1BodySized.sizeArgs63).run D1BodySized.S216 =
  some (some D1BodySized.sizeAs63, D1BodySized.sizeS063)
kernel_rfl D1BodySized.sizePreA63 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS063 D1BodySized.s216.ffi D1BodySized.sizeAs63 = true

end Host.Load.Run.Tpl
end

section -- SN217
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel217 : nth? D1BodySized.ks 217 = some 1936
kernel_rfl D1BodySized.checked217 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s217 D1BodySized.S217) =
    fun _ => some (D1BodySized.s218, D1BodySized.S218)

theorem D1BodySized.k217 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s217 D1BodySized.S217 =
      some (D1BodySized.s218, D1BodySized.S218) := congrFun D1BodySized.checked217 bs

end Host.Load.Run.Tpl
end

section -- SB63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment63 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s217 D1BodySized.S217 =
      some (D1BodySized.s218, D1BodySized.S218) := D1BodySized.k217 bs

kernel_rfl D1BodySized.accepted63 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s217 D1BodySized.S217) = fun _ => true
kernel_rfl D1BodySized.oracle63 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S217.oracle = true
kernel_rfl D1BodySized.fuelA64 : nth? D1BodySized.ks 218 = some 1
kernel_rfl D1BodySized.fuelB64 : nth? D1BodySized.ks 219 = some 3
kernel_rfl D1BodySized.stepA64 : interpS (step D1BodySized.F D1BodySized.s218).run D1BodySized.S218 =
  some (D1BodySized.s219, D1BodySized.S219)
kernel_rfl D1BodySized.patchB64 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s219).run D1BodySized.S219 =
  some (D1BodySized.s220, D1BodySized.S220)
kernel_rfl D1BodySized.acceptedP64 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s218 D1BodySized.S218) = fun _ => true
kernel_rfl D1BodySized.haltP64 : isHalt D1BodySized.s218.ctl = false
kernel_rfl D1BodySized.topA64 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s219 = true
kernel_rfl D1BodySized.inactive64 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s219.ffi).active = false
/-- Bridge 64's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys64 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s219 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs64 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s219 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA64 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s219 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys64, D1BodySized.sizeArgs64)
kernel_rfl D1BodySized.sizeArgsA64 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s219 = true
kernel_rfl D1BodySized.sizeSymA64 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA64 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA64 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA64 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec64 := interpS (decodeArgs D1BodySized.F D1BodySized.s219 D1BodySized.sizeTys64 D1BodySized.sizeArgs64).run D1BodySized.S219
noncomputable def D1BodySized.sizeAs64 : List Arg := match D1BodySized.sizeDec64 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS064 : SSrv := match D1BodySized.sizeDec64 with | some (_, S) => S | none => D1BodySized.S219
kernel_rfl D1BodySized.sizeDecA64 : interpS (decodeArgs D1BodySized.F D1BodySized.s219 D1BodySized.sizeTys64 D1BodySized.sizeArgs64).run D1BodySized.S219 =
  some (some D1BodySized.sizeAs64, D1BodySized.sizeS064)
kernel_rfl D1BodySized.sizePreA64 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS064 D1BodySized.s219.ffi D1BodySized.sizeAs64 = true

end Host.Load.Run.Tpl
end

section -- SN220
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel220 : nth? D1BodySized.ks 220 = some 10000
kernel_rfl D1BodySized.checked220 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s220 D1BodySized.S220) =
    fun _ => some (D1BodySized.s221, D1BodySized.S221)

theorem D1BodySized.k220 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s220 D1BodySized.S220 =
      some (D1BodySized.s221, D1BodySized.S221) := congrFun D1BodySized.checked220 bs

end Host.Load.Run.Tpl
end

section -- SN221
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel221 : nth? D1BodySized.ks 221 = some 2570
kernel_rfl D1BodySized.checked221 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s221 D1BodySized.S221) =
    fun _ => some (D1BodySized.s222, D1BodySized.S222)

theorem D1BodySized.k221 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s221 D1BodySized.S221 =
      some (D1BodySized.s222, D1BodySized.S222) := congrFun D1BodySized.checked221 bs

end Host.Load.Run.Tpl
end

section -- SB64
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment64 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s220 D1BodySized.S220 =
      some (D1BodySized.s222, D1BodySized.S222) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s220 D1BodySized.s221 D1BodySized.s222 D1BodySized.S220 D1BodySized.S221 D1BodySized.S222 (D1BodySized.k220 bs) (D1BodySized.k221 bs)

kernel_rfl D1BodySized.accepted64 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s220 D1BodySized.S220) = fun _ => true
kernel_rfl D1BodySized.oracle64 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S220.oracle = true
kernel_rfl D1BodySized.fuelA65 : nth? D1BodySized.ks 222 = some 1
kernel_rfl D1BodySized.fuelB65 : nth? D1BodySized.ks 223 = some 3
kernel_rfl D1BodySized.stepA65 : interpS (step D1BodySized.F D1BodySized.s222).run D1BodySized.S222 =
  some (D1BodySized.s223, D1BodySized.S223)
kernel_rfl D1BodySized.patchB65 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s223).run D1BodySized.S223 =
  some (D1BodySized.s224, D1BodySized.S224)
kernel_rfl D1BodySized.acceptedP65 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s222 D1BodySized.S222) = fun _ => true
kernel_rfl D1BodySized.haltP65 : isHalt D1BodySized.s222.ctl = false
kernel_rfl D1BodySized.topA65 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s223 = true
kernel_rfl D1BodySized.inactive65 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s223.ffi).active = false
/-- Bridge 65's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys65 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s223 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs65 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s223 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA65 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s223 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys65, D1BodySized.sizeArgs65)
kernel_rfl D1BodySized.sizeArgsA65 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s223 = true
kernel_rfl D1BodySized.sizeSymA65 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA65 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA65 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA65 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec65 := interpS (decodeArgs D1BodySized.F D1BodySized.s223 D1BodySized.sizeTys65 D1BodySized.sizeArgs65).run D1BodySized.S223
noncomputable def D1BodySized.sizeAs65 : List Arg := match D1BodySized.sizeDec65 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS065 : SSrv := match D1BodySized.sizeDec65 with | some (_, S) => S | none => D1BodySized.S223
kernel_rfl D1BodySized.sizeDecA65 : interpS (decodeArgs D1BodySized.F D1BodySized.s223 D1BodySized.sizeTys65 D1BodySized.sizeArgs65).run D1BodySized.S223 =
  some (some D1BodySized.sizeAs65, D1BodySized.sizeS065)
kernel_rfl D1BodySized.sizePreA65 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS065 D1BodySized.s223.ffi D1BodySized.sizeAs65 = true

end Host.Load.Run.Tpl
end

section -- SN224
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel224 : nth? D1BodySized.ks 224 = some 2542
kernel_rfl D1BodySized.checked224 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s224 D1BodySized.S224) =
    fun _ => some (D1BodySized.s225, D1BodySized.S225)

theorem D1BodySized.k224 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s224 D1BodySized.S224 =
      some (D1BodySized.s225, D1BodySized.S225) := congrFun D1BodySized.checked224 bs

end Host.Load.Run.Tpl
end

section -- SB65
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment65 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s224 D1BodySized.S224 =
      some (D1BodySized.s225, D1BodySized.S225) := D1BodySized.k224 bs

kernel_rfl D1BodySized.accepted65 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s224 D1BodySized.S224) = fun _ => true
kernel_rfl D1BodySized.oracle65 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S224.oracle = true
kernel_rfl D1BodySized.fuelA66 : nth? D1BodySized.ks 225 = some 1
kernel_rfl D1BodySized.fuelB66 : nth? D1BodySized.ks 226 = some 3
kernel_rfl D1BodySized.stepA66 : interpS (step D1BodySized.F D1BodySized.s225).run D1BodySized.S225 =
  some (D1BodySized.s226, D1BodySized.S226)
kernel_rfl D1BodySized.patchB66 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s226).run D1BodySized.S226 =
  some (D1BodySized.s227, D1BodySized.S227)
kernel_rfl D1BodySized.acceptedP66 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s225 D1BodySized.S225) = fun _ => true
kernel_rfl D1BodySized.haltP66 : isHalt D1BodySized.s225.ctl = false
kernel_rfl D1BodySized.topA66 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s226 = true
kernel_rfl D1BodySized.inactive66 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s226.ffi).active = false
/-- Bridge 66's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys66 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s226 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs66 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s226 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA66 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s226 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys66, D1BodySized.sizeArgs66)
kernel_rfl D1BodySized.sizeArgsA66 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s226 = true
kernel_rfl D1BodySized.sizeSymA66 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA66 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA66 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA66 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec66 := interpS (decodeArgs D1BodySized.F D1BodySized.s226 D1BodySized.sizeTys66 D1BodySized.sizeArgs66).run D1BodySized.S226
noncomputable def D1BodySized.sizeAs66 : List Arg := match D1BodySized.sizeDec66 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS066 : SSrv := match D1BodySized.sizeDec66 with | some (_, S) => S | none => D1BodySized.S226
kernel_rfl D1BodySized.sizeDecA66 : interpS (decodeArgs D1BodySized.F D1BodySized.s226 D1BodySized.sizeTys66 D1BodySized.sizeArgs66).run D1BodySized.S226 =
  some (some D1BodySized.sizeAs66, D1BodySized.sizeS066)
kernel_rfl D1BodySized.sizePreA66 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS066 D1BodySized.s226.ffi D1BodySized.sizeAs66 = true

end Host.Load.Run.Tpl
end

section -- SN227
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel227 : nth? D1BodySized.ks 227 = some 7721
kernel_rfl D1BodySized.checked227 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7721 D1BodySized.s227 D1BodySized.S227) =
    fun _ => some (D1BodySized.s228, D1BodySized.S228)

theorem D1BodySized.k227 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7721 D1BodySized.s227 D1BodySized.S227 =
      some (D1BodySized.s228, D1BodySized.S228) := congrFun D1BodySized.checked227 bs

end Host.Load.Run.Tpl
end

section -- SB66
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment66 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7721 D1BodySized.s227 D1BodySized.S227 =
      some (D1BodySized.s228, D1BodySized.S228) := D1BodySized.k227 bs

kernel_rfl D1BodySized.accepted66 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s227 D1BodySized.S227) = fun _ => true
kernel_rfl D1BodySized.oracle66 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S227.oracle = true
kernel_rfl D1BodySized.fuelA67 : nth? D1BodySized.ks 228 = some 1
kernel_rfl D1BodySized.fuelB67 : nth? D1BodySized.ks 229 = some 3
kernel_rfl D1BodySized.stepA67 : interpS (step D1BodySized.F D1BodySized.s228).run D1BodySized.S228 =
  some (D1BodySized.s229, D1BodySized.S229)
kernel_rfl D1BodySized.patchB67 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s229).run D1BodySized.S229 =
  some (D1BodySized.s230, D1BodySized.S230)
kernel_rfl D1BodySized.acceptedP67 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s228 D1BodySized.S228) = fun _ => true
kernel_rfl D1BodySized.haltP67 : isHalt D1BodySized.s228.ctl = false
kernel_rfl D1BodySized.topA67 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s229 = true
kernel_rfl D1BodySized.inactive67 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s229.ffi).active = false
/-- Bridge 67's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys67 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s229 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs67 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s229 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA67 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s229 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys67, D1BodySized.sizeArgs67)
kernel_rfl D1BodySized.sizeArgsA67 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s229 = true
kernel_rfl D1BodySized.sizeSymA67 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA67 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA67 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA67 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec67 := interpS (decodeArgs D1BodySized.F D1BodySized.s229 D1BodySized.sizeTys67 D1BodySized.sizeArgs67).run D1BodySized.S229
noncomputable def D1BodySized.sizeAs67 : List Arg := match D1BodySized.sizeDec67 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS067 : SSrv := match D1BodySized.sizeDec67 with | some (_, S) => S | none => D1BodySized.S229
kernel_rfl D1BodySized.sizeDecA67 : interpS (decodeArgs D1BodySized.F D1BodySized.s229 D1BodySized.sizeTys67 D1BodySized.sizeArgs67).run D1BodySized.S229 =
  some (some D1BodySized.sizeAs67, D1BodySized.sizeS067)
kernel_rfl D1BodySized.sizePreA67 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS067 D1BodySized.s229.ffi D1BodySized.sizeAs67 = true

end Host.Load.Run.Tpl
end
