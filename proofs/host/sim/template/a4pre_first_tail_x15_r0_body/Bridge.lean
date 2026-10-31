import host.sim.template.a4pre_first_tail_x15_r0_body.H52
import host.sim.template.Bridges
import host.sim.LoopFinal
import host.sim.full.SizeSim
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The bridge points of `PRE_first_tail_x15_r0_body` (seg.json): at each bridge state, the facts its bridge lemma needs. -/

/-- Bridge 1's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys1 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s2 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs1 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s2 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA1 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s2 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys1, PRE_first_tail_x15_r0_body.sizeArgs1)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA1 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s2 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA1 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA1 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA1 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA1 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec1 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s2 PRE_first_tail_x15_r0_body.sizeTys1 PRE_first_tail_x15_r0_body.sizeArgs1).run PRE_first_tail_x15_r0_body.S2
noncomputable def PRE_first_tail_x15_r0_body.sizeAs1 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec1 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS01 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec1 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S2
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA1 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s2 PRE_first_tail_x15_r0_body.sizeTys1 PRE_first_tail_x15_r0_body.sizeArgs1).run PRE_first_tail_x15_r0_body.S2 =
  some (some PRE_first_tail_x15_r0_body.sizeAs1, PRE_first_tail_x15_r0_body.sizeS01)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA1 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS01 PRE_first_tail_x15_r0_body.s2.ffi PRE_first_tail_x15_r0_body.sizeAs1 = true
/-- Bridge 2's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys2 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s5 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs2 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s5 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA2 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s5 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys2, PRE_first_tail_x15_r0_body.sizeArgs2)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA2 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s5 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA2 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA2 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA2 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA2 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec2 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s5 PRE_first_tail_x15_r0_body.sizeTys2 PRE_first_tail_x15_r0_body.sizeArgs2).run PRE_first_tail_x15_r0_body.S5
noncomputable def PRE_first_tail_x15_r0_body.sizeAs2 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec2 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS02 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec2 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S5
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA2 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s5 PRE_first_tail_x15_r0_body.sizeTys2 PRE_first_tail_x15_r0_body.sizeArgs2).run PRE_first_tail_x15_r0_body.S5 =
  some (some PRE_first_tail_x15_r0_body.sizeAs2, PRE_first_tail_x15_r0_body.sizeS02)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA2 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS02 PRE_first_tail_x15_r0_body.s5.ffi PRE_first_tail_x15_r0_body.sizeAs2 = true
/-- Bridge 3's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys3 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s8 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs3 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s8 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA3 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s8 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys3, PRE_first_tail_x15_r0_body.sizeArgs3)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA3 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s8 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA3 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA3 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA3 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA3 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec3 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s8 PRE_first_tail_x15_r0_body.sizeTys3 PRE_first_tail_x15_r0_body.sizeArgs3).run PRE_first_tail_x15_r0_body.S8
noncomputable def PRE_first_tail_x15_r0_body.sizeAs3 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec3 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS03 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec3 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S8
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA3 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s8 PRE_first_tail_x15_r0_body.sizeTys3 PRE_first_tail_x15_r0_body.sizeArgs3).run PRE_first_tail_x15_r0_body.S8 =
  some (some PRE_first_tail_x15_r0_body.sizeAs3, PRE_first_tail_x15_r0_body.sizeS03)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA3 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS03 PRE_first_tail_x15_r0_body.s8.ffi PRE_first_tail_x15_r0_body.sizeAs3 = true
/-- Bridge 4's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys4 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s11 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs4 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s11 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA4 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s11 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys4, PRE_first_tail_x15_r0_body.sizeArgs4)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA4 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s11 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA4 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA4 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA4 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA4 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec4 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s11 PRE_first_tail_x15_r0_body.sizeTys4 PRE_first_tail_x15_r0_body.sizeArgs4).run PRE_first_tail_x15_r0_body.S11
noncomputable def PRE_first_tail_x15_r0_body.sizeAs4 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec4 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS04 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec4 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S11
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA4 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s11 PRE_first_tail_x15_r0_body.sizeTys4 PRE_first_tail_x15_r0_body.sizeArgs4).run PRE_first_tail_x15_r0_body.S11 =
  some (some PRE_first_tail_x15_r0_body.sizeAs4, PRE_first_tail_x15_r0_body.sizeS04)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA4 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS04 PRE_first_tail_x15_r0_body.s11.ffi PRE_first_tail_x15_r0_body.sizeAs4 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA5 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s14 "recurWindow" none = true
/-- Bridge 6's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys6 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s18 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs6 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s18 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA6 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s18 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys6, PRE_first_tail_x15_r0_body.sizeArgs6)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA6 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s18 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA6 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA6 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA6 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA6 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec6 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s18 PRE_first_tail_x15_r0_body.sizeTys6 PRE_first_tail_x15_r0_body.sizeArgs6).run PRE_first_tail_x15_r0_body.S18
noncomputable def PRE_first_tail_x15_r0_body.sizeAs6 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec6 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS06 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec6 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S18
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA6 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s18 PRE_first_tail_x15_r0_body.sizeTys6 PRE_first_tail_x15_r0_body.sizeArgs6).run PRE_first_tail_x15_r0_body.S18 =
  some (some PRE_first_tail_x15_r0_body.sizeAs6, PRE_first_tail_x15_r0_body.sizeS06)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA6 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS06 PRE_first_tail_x15_r0_body.s18.ffi PRE_first_tail_x15_r0_body.sizeAs6 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA7 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s21 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA8 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s25 "plan" none = true
/-- Bridge 9's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys9 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s29 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs9 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s29 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA9 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s29 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys9, PRE_first_tail_x15_r0_body.sizeArgs9)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA9 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s29 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA9 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA9 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA9 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA9 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec9 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s29 PRE_first_tail_x15_r0_body.sizeTys9 PRE_first_tail_x15_r0_body.sizeArgs9).run PRE_first_tail_x15_r0_body.S29
noncomputable def PRE_first_tail_x15_r0_body.sizeAs9 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec9 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS09 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec9 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S29
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA9 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s29 PRE_first_tail_x15_r0_body.sizeTys9 PRE_first_tail_x15_r0_body.sizeArgs9).run PRE_first_tail_x15_r0_body.S29 =
  some (some PRE_first_tail_x15_r0_body.sizeAs9, PRE_first_tail_x15_r0_body.sizeS09)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA9 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS09 PRE_first_tail_x15_r0_body.s29.ffi PRE_first_tail_x15_r0_body.sizeAs9 = true
/-- Bridge 10's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys10 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s32 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs10 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s32 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA10 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s32 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys10, PRE_first_tail_x15_r0_body.sizeArgs10)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA10 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s32 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA10 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA10 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA10 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA10 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec10 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s32 PRE_first_tail_x15_r0_body.sizeTys10 PRE_first_tail_x15_r0_body.sizeArgs10).run PRE_first_tail_x15_r0_body.S32
noncomputable def PRE_first_tail_x15_r0_body.sizeAs10 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec10 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS010 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec10 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S32
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA10 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s32 PRE_first_tail_x15_r0_body.sizeTys10 PRE_first_tail_x15_r0_body.sizeArgs10).run PRE_first_tail_x15_r0_body.S32 =
  some (some PRE_first_tail_x15_r0_body.sizeAs10, PRE_first_tail_x15_r0_body.sizeS010)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA10 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS010 PRE_first_tail_x15_r0_body.s32.ffi PRE_first_tail_x15_r0_body.sizeAs10 = true
/-- Bridge 11's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys11 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s35 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs11 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s35 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA11 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s35 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys11, PRE_first_tail_x15_r0_body.sizeArgs11)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA11 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s35 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA11 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA11 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA11 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA11 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec11 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s35 PRE_first_tail_x15_r0_body.sizeTys11 PRE_first_tail_x15_r0_body.sizeArgs11).run PRE_first_tail_x15_r0_body.S35
noncomputable def PRE_first_tail_x15_r0_body.sizeAs11 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec11 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS011 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec11 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S35
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA11 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s35 PRE_first_tail_x15_r0_body.sizeTys11 PRE_first_tail_x15_r0_body.sizeArgs11).run PRE_first_tail_x15_r0_body.S35 =
  some (some PRE_first_tail_x15_r0_body.sizeAs11, PRE_first_tail_x15_r0_body.sizeS011)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA11 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS011 PRE_first_tail_x15_r0_body.s35.ffi PRE_first_tail_x15_r0_body.sizeAs11 = true
/-- Bridge 12's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys12 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s38 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs12 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s38 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA12 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s38 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys12, PRE_first_tail_x15_r0_body.sizeArgs12)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA12 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s38 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA12 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA12 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA12 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA12 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec12 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s38 PRE_first_tail_x15_r0_body.sizeTys12 PRE_first_tail_x15_r0_body.sizeArgs12).run PRE_first_tail_x15_r0_body.S38
noncomputable def PRE_first_tail_x15_r0_body.sizeAs12 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec12 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS012 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec12 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S38
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA12 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s38 PRE_first_tail_x15_r0_body.sizeTys12 PRE_first_tail_x15_r0_body.sizeArgs12).run PRE_first_tail_x15_r0_body.S38 =
  some (some PRE_first_tail_x15_r0_body.sizeAs12, PRE_first_tail_x15_r0_body.sizeS012)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA12 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS012 PRE_first_tail_x15_r0_body.s38.ffi PRE_first_tail_x15_r0_body.sizeAs12 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA13 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s41 "recurWindow" none = true
/-- Bridge 14's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys14 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s45 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs14 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s45 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA14 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s45 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys14, PRE_first_tail_x15_r0_body.sizeArgs14)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA14 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s45 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA14 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA14 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA14 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA14 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec14 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s45 PRE_first_tail_x15_r0_body.sizeTys14 PRE_first_tail_x15_r0_body.sizeArgs14).run PRE_first_tail_x15_r0_body.S45
noncomputable def PRE_first_tail_x15_r0_body.sizeAs14 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec14 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS014 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec14 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S45
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA14 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s45 PRE_first_tail_x15_r0_body.sizeTys14 PRE_first_tail_x15_r0_body.sizeArgs14).run PRE_first_tail_x15_r0_body.S45 =
  some (some PRE_first_tail_x15_r0_body.sizeAs14, PRE_first_tail_x15_r0_body.sizeS014)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA14 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS014 PRE_first_tail_x15_r0_body.s45.ffi PRE_first_tail_x15_r0_body.sizeAs14 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA15 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s48 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA16 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s52 "plan" none = true
/-- Bridge 17's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys17 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s56 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs17 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s56 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA17 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s56 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys17, PRE_first_tail_x15_r0_body.sizeArgs17)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA17 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s56 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA17 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA17 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA17 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA17 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec17 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s56 PRE_first_tail_x15_r0_body.sizeTys17 PRE_first_tail_x15_r0_body.sizeArgs17).run PRE_first_tail_x15_r0_body.S56
noncomputable def PRE_first_tail_x15_r0_body.sizeAs17 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec17 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS017 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec17 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S56
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA17 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s56 PRE_first_tail_x15_r0_body.sizeTys17 PRE_first_tail_x15_r0_body.sizeArgs17).run PRE_first_tail_x15_r0_body.S56 =
  some (some PRE_first_tail_x15_r0_body.sizeAs17, PRE_first_tail_x15_r0_body.sizeS017)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA17 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS017 PRE_first_tail_x15_r0_body.s56.ffi PRE_first_tail_x15_r0_body.sizeAs17 = true
/-- Bridge 18's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys18 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s59 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs18 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s59 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA18 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s59 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys18, PRE_first_tail_x15_r0_body.sizeArgs18)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA18 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s59 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA18 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA18 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA18 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA18 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec18 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s59 PRE_first_tail_x15_r0_body.sizeTys18 PRE_first_tail_x15_r0_body.sizeArgs18).run PRE_first_tail_x15_r0_body.S59
noncomputable def PRE_first_tail_x15_r0_body.sizeAs18 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec18 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS018 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec18 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S59
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA18 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s59 PRE_first_tail_x15_r0_body.sizeTys18 PRE_first_tail_x15_r0_body.sizeArgs18).run PRE_first_tail_x15_r0_body.S59 =
  some (some PRE_first_tail_x15_r0_body.sizeAs18, PRE_first_tail_x15_r0_body.sizeS018)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA18 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS018 PRE_first_tail_x15_r0_body.s59.ffi PRE_first_tail_x15_r0_body.sizeAs18 = true
/-- Bridge 19's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys19 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s62 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs19 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s62 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA19 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s62 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys19, PRE_first_tail_x15_r0_body.sizeArgs19)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA19 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s62 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA19 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA19 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA19 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA19 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec19 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s62 PRE_first_tail_x15_r0_body.sizeTys19 PRE_first_tail_x15_r0_body.sizeArgs19).run PRE_first_tail_x15_r0_body.S62
noncomputable def PRE_first_tail_x15_r0_body.sizeAs19 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec19 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS019 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec19 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S62
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA19 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s62 PRE_first_tail_x15_r0_body.sizeTys19 PRE_first_tail_x15_r0_body.sizeArgs19).run PRE_first_tail_x15_r0_body.S62 =
  some (some PRE_first_tail_x15_r0_body.sizeAs19, PRE_first_tail_x15_r0_body.sizeS019)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA19 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS019 PRE_first_tail_x15_r0_body.s62.ffi PRE_first_tail_x15_r0_body.sizeAs19 = true
/-- Bridge 20's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys20 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s65 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs20 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s65 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA20 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s65 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys20, PRE_first_tail_x15_r0_body.sizeArgs20)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA20 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s65 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA20 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA20 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA20 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA20 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec20 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s65 PRE_first_tail_x15_r0_body.sizeTys20 PRE_first_tail_x15_r0_body.sizeArgs20).run PRE_first_tail_x15_r0_body.S65
noncomputable def PRE_first_tail_x15_r0_body.sizeAs20 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec20 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS020 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec20 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S65
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA20 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s65 PRE_first_tail_x15_r0_body.sizeTys20 PRE_first_tail_x15_r0_body.sizeArgs20).run PRE_first_tail_x15_r0_body.S65 =
  some (some PRE_first_tail_x15_r0_body.sizeAs20, PRE_first_tail_x15_r0_body.sizeS020)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA20 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS020 PRE_first_tail_x15_r0_body.s65.ffi PRE_first_tail_x15_r0_body.sizeAs20 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA21 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s68 "recurWindow" none = true
/-- Bridge 22's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys22 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s72 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs22 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s72 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA22 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s72 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys22, PRE_first_tail_x15_r0_body.sizeArgs22)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA22 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s72 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA22 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA22 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA22 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA22 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec22 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s72 PRE_first_tail_x15_r0_body.sizeTys22 PRE_first_tail_x15_r0_body.sizeArgs22).run PRE_first_tail_x15_r0_body.S72
noncomputable def PRE_first_tail_x15_r0_body.sizeAs22 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec22 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS022 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec22 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S72
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA22 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s72 PRE_first_tail_x15_r0_body.sizeTys22 PRE_first_tail_x15_r0_body.sizeArgs22).run PRE_first_tail_x15_r0_body.S72 =
  some (some PRE_first_tail_x15_r0_body.sizeAs22, PRE_first_tail_x15_r0_body.sizeS022)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA22 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS022 PRE_first_tail_x15_r0_body.s72.ffi PRE_first_tail_x15_r0_body.sizeAs22 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA23 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s75 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA24 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s79 "plan" none = true
/-- Bridge 25's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys25 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s83 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs25 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s83 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA25 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s83 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys25, PRE_first_tail_x15_r0_body.sizeArgs25)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA25 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s83 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA25 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA25 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA25 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA25 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec25 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s83 PRE_first_tail_x15_r0_body.sizeTys25 PRE_first_tail_x15_r0_body.sizeArgs25).run PRE_first_tail_x15_r0_body.S83
noncomputable def PRE_first_tail_x15_r0_body.sizeAs25 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec25 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS025 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec25 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S83
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA25 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s83 PRE_first_tail_x15_r0_body.sizeTys25 PRE_first_tail_x15_r0_body.sizeArgs25).run PRE_first_tail_x15_r0_body.S83 =
  some (some PRE_first_tail_x15_r0_body.sizeAs25, PRE_first_tail_x15_r0_body.sizeS025)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA25 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS025 PRE_first_tail_x15_r0_body.s83.ffi PRE_first_tail_x15_r0_body.sizeAs25 = true
/-- Bridge 26's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys26 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s86 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs26 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s86 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA26 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s86 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys26, PRE_first_tail_x15_r0_body.sizeArgs26)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA26 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s86 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA26 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA26 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA26 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA26 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec26 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s86 PRE_first_tail_x15_r0_body.sizeTys26 PRE_first_tail_x15_r0_body.sizeArgs26).run PRE_first_tail_x15_r0_body.S86
noncomputable def PRE_first_tail_x15_r0_body.sizeAs26 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec26 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS026 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec26 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S86
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA26 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s86 PRE_first_tail_x15_r0_body.sizeTys26 PRE_first_tail_x15_r0_body.sizeArgs26).run PRE_first_tail_x15_r0_body.S86 =
  some (some PRE_first_tail_x15_r0_body.sizeAs26, PRE_first_tail_x15_r0_body.sizeS026)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA26 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS026 PRE_first_tail_x15_r0_body.s86.ffi PRE_first_tail_x15_r0_body.sizeAs26 = true
/-- Bridge 27's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys27 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s89 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs27 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s89 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA27 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s89 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys27, PRE_first_tail_x15_r0_body.sizeArgs27)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA27 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s89 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA27 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA27 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA27 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA27 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec27 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s89 PRE_first_tail_x15_r0_body.sizeTys27 PRE_first_tail_x15_r0_body.sizeArgs27).run PRE_first_tail_x15_r0_body.S89
noncomputable def PRE_first_tail_x15_r0_body.sizeAs27 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec27 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS027 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec27 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S89
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA27 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s89 PRE_first_tail_x15_r0_body.sizeTys27 PRE_first_tail_x15_r0_body.sizeArgs27).run PRE_first_tail_x15_r0_body.S89 =
  some (some PRE_first_tail_x15_r0_body.sizeAs27, PRE_first_tail_x15_r0_body.sizeS027)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA27 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS027 PRE_first_tail_x15_r0_body.s89.ffi PRE_first_tail_x15_r0_body.sizeAs27 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA28 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s92 "appendWindow" none = true
/-- Bridge 29's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys29 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s96 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs29 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s96 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA29 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s96 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys29, PRE_first_tail_x15_r0_body.sizeArgs29)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA29 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s96 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA29 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA29 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA29 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA29 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec29 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s96 PRE_first_tail_x15_r0_body.sizeTys29 PRE_first_tail_x15_r0_body.sizeArgs29).run PRE_first_tail_x15_r0_body.S96
noncomputable def PRE_first_tail_x15_r0_body.sizeAs29 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec29 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS029 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec29 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S96
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA29 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s96 PRE_first_tail_x15_r0_body.sizeTys29 PRE_first_tail_x15_r0_body.sizeArgs29).run PRE_first_tail_x15_r0_body.S96 =
  some (some PRE_first_tail_x15_r0_body.sizeAs29, PRE_first_tail_x15_r0_body.sizeS029)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA29 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS029 PRE_first_tail_x15_r0_body.s96.ffi PRE_first_tail_x15_r0_body.sizeAs29 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA30 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s99 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA31 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s103 "plan" none = true
/-- Bridge 32's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys32 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s107 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs32 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s107 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA32 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s107 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys32, PRE_first_tail_x15_r0_body.sizeArgs32)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA32 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s107 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA32 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA32 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA32 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA32 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec32 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s107 PRE_first_tail_x15_r0_body.sizeTys32 PRE_first_tail_x15_r0_body.sizeArgs32).run PRE_first_tail_x15_r0_body.S107
noncomputable def PRE_first_tail_x15_r0_body.sizeAs32 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec32 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS032 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec32 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S107
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA32 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s107 PRE_first_tail_x15_r0_body.sizeTys32 PRE_first_tail_x15_r0_body.sizeArgs32).run PRE_first_tail_x15_r0_body.S107 =
  some (some PRE_first_tail_x15_r0_body.sizeAs32, PRE_first_tail_x15_r0_body.sizeS032)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA32 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS032 PRE_first_tail_x15_r0_body.s107.ffi PRE_first_tail_x15_r0_body.sizeAs32 = true
/-- Bridge 33's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys33 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s110 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs33 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s110 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA33 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s110 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys33, PRE_first_tail_x15_r0_body.sizeArgs33)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA33 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s110 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA33 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA33 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA33 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA33 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec33 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s110 PRE_first_tail_x15_r0_body.sizeTys33 PRE_first_tail_x15_r0_body.sizeArgs33).run PRE_first_tail_x15_r0_body.S110
noncomputable def PRE_first_tail_x15_r0_body.sizeAs33 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec33 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS033 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec33 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S110
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA33 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s110 PRE_first_tail_x15_r0_body.sizeTys33 PRE_first_tail_x15_r0_body.sizeArgs33).run PRE_first_tail_x15_r0_body.S110 =
  some (some PRE_first_tail_x15_r0_body.sizeAs33, PRE_first_tail_x15_r0_body.sizeS033)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA33 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS033 PRE_first_tail_x15_r0_body.s110.ffi PRE_first_tail_x15_r0_body.sizeAs33 = true
/-- Bridge 34's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys34 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s113 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs34 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s113 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA34 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s113 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys34, PRE_first_tail_x15_r0_body.sizeArgs34)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA34 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s113 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA34 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA34 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA34 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA34 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec34 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s113 PRE_first_tail_x15_r0_body.sizeTys34 PRE_first_tail_x15_r0_body.sizeArgs34).run PRE_first_tail_x15_r0_body.S113
noncomputable def PRE_first_tail_x15_r0_body.sizeAs34 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec34 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS034 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec34 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S113
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA34 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s113 PRE_first_tail_x15_r0_body.sizeTys34 PRE_first_tail_x15_r0_body.sizeArgs34).run PRE_first_tail_x15_r0_body.S113 =
  some (some PRE_first_tail_x15_r0_body.sizeAs34, PRE_first_tail_x15_r0_body.sizeS034)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA34 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS034 PRE_first_tail_x15_r0_body.s113.ffi PRE_first_tail_x15_r0_body.sizeAs34 = true
/-- Bridge 35's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys35 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s116 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs35 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s116 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA35 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s116 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys35, PRE_first_tail_x15_r0_body.sizeArgs35)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA35 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s116 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA35 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA35 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA35 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA35 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec35 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s116 PRE_first_tail_x15_r0_body.sizeTys35 PRE_first_tail_x15_r0_body.sizeArgs35).run PRE_first_tail_x15_r0_body.S116
noncomputable def PRE_first_tail_x15_r0_body.sizeAs35 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec35 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS035 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec35 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S116
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA35 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s116 PRE_first_tail_x15_r0_body.sizeTys35 PRE_first_tail_x15_r0_body.sizeArgs35).run PRE_first_tail_x15_r0_body.S116 =
  some (some PRE_first_tail_x15_r0_body.sizeAs35, PRE_first_tail_x15_r0_body.sizeS035)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA35 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS035 PRE_first_tail_x15_r0_body.s116.ffi PRE_first_tail_x15_r0_body.sizeAs35 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA36 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s119 "recurWindow" none = true
/-- Bridge 37's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys37 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s123 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs37 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s123 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA37 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s123 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys37, PRE_first_tail_x15_r0_body.sizeArgs37)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA37 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s123 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA37 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA37 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA37 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA37 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec37 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s123 PRE_first_tail_x15_r0_body.sizeTys37 PRE_first_tail_x15_r0_body.sizeArgs37).run PRE_first_tail_x15_r0_body.S123
noncomputable def PRE_first_tail_x15_r0_body.sizeAs37 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec37 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS037 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec37 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S123
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA37 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s123 PRE_first_tail_x15_r0_body.sizeTys37 PRE_first_tail_x15_r0_body.sizeArgs37).run PRE_first_tail_x15_r0_body.S123 =
  some (some PRE_first_tail_x15_r0_body.sizeAs37, PRE_first_tail_x15_r0_body.sizeS037)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA37 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS037 PRE_first_tail_x15_r0_body.s123.ffi PRE_first_tail_x15_r0_body.sizeAs37 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA38 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s126 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA39 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s130 "plan" none = true
/-- Bridge 40's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys40 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s134 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs40 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s134 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA40 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s134 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys40, PRE_first_tail_x15_r0_body.sizeArgs40)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA40 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s134 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA40 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA40 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA40 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA40 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec40 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s134 PRE_first_tail_x15_r0_body.sizeTys40 PRE_first_tail_x15_r0_body.sizeArgs40).run PRE_first_tail_x15_r0_body.S134
noncomputable def PRE_first_tail_x15_r0_body.sizeAs40 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec40 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS040 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec40 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S134
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA40 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s134 PRE_first_tail_x15_r0_body.sizeTys40 PRE_first_tail_x15_r0_body.sizeArgs40).run PRE_first_tail_x15_r0_body.S134 =
  some (some PRE_first_tail_x15_r0_body.sizeAs40, PRE_first_tail_x15_r0_body.sizeS040)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA40 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS040 PRE_first_tail_x15_r0_body.s134.ffi PRE_first_tail_x15_r0_body.sizeAs40 = true
/-- Bridge 41's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys41 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s137 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs41 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s137 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA41 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s137 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys41, PRE_first_tail_x15_r0_body.sizeArgs41)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA41 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s137 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA41 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA41 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA41 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA41 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec41 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s137 PRE_first_tail_x15_r0_body.sizeTys41 PRE_first_tail_x15_r0_body.sizeArgs41).run PRE_first_tail_x15_r0_body.S137
noncomputable def PRE_first_tail_x15_r0_body.sizeAs41 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec41 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS041 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec41 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S137
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA41 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s137 PRE_first_tail_x15_r0_body.sizeTys41 PRE_first_tail_x15_r0_body.sizeArgs41).run PRE_first_tail_x15_r0_body.S137 =
  some (some PRE_first_tail_x15_r0_body.sizeAs41, PRE_first_tail_x15_r0_body.sizeS041)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA41 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS041 PRE_first_tail_x15_r0_body.s137.ffi PRE_first_tail_x15_r0_body.sizeAs41 = true
/-- Bridge 42's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys42 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s140 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs42 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s140 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA42 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s140 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys42, PRE_first_tail_x15_r0_body.sizeArgs42)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA42 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s140 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA42 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA42 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA42 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA42 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec42 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s140 PRE_first_tail_x15_r0_body.sizeTys42 PRE_first_tail_x15_r0_body.sizeArgs42).run PRE_first_tail_x15_r0_body.S140
noncomputable def PRE_first_tail_x15_r0_body.sizeAs42 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec42 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS042 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec42 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S140
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA42 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s140 PRE_first_tail_x15_r0_body.sizeTys42 PRE_first_tail_x15_r0_body.sizeArgs42).run PRE_first_tail_x15_r0_body.S140 =
  some (some PRE_first_tail_x15_r0_body.sizeAs42, PRE_first_tail_x15_r0_body.sizeS042)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA42 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS042 PRE_first_tail_x15_r0_body.s140.ffi PRE_first_tail_x15_r0_body.sizeAs42 = true
/-- Bridge 43's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys43 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s143 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs43 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s143 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA43 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s143 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys43, PRE_first_tail_x15_r0_body.sizeArgs43)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA43 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s143 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA43 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA43 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA43 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA43 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec43 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s143 PRE_first_tail_x15_r0_body.sizeTys43 PRE_first_tail_x15_r0_body.sizeArgs43).run PRE_first_tail_x15_r0_body.S143
noncomputable def PRE_first_tail_x15_r0_body.sizeAs43 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec43 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS043 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec43 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S143
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA43 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s143 PRE_first_tail_x15_r0_body.sizeTys43 PRE_first_tail_x15_r0_body.sizeArgs43).run PRE_first_tail_x15_r0_body.S143 =
  some (some PRE_first_tail_x15_r0_body.sizeAs43, PRE_first_tail_x15_r0_body.sizeS043)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA43 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS043 PRE_first_tail_x15_r0_body.s143.ffi PRE_first_tail_x15_r0_body.sizeAs43 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA44 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s146 "recurWindow" none = true
/-- Bridge 45's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys45 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s150 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs45 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s150 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA45 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s150 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys45, PRE_first_tail_x15_r0_body.sizeArgs45)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA45 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s150 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA45 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA45 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA45 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA45 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec45 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s150 PRE_first_tail_x15_r0_body.sizeTys45 PRE_first_tail_x15_r0_body.sizeArgs45).run PRE_first_tail_x15_r0_body.S150
noncomputable def PRE_first_tail_x15_r0_body.sizeAs45 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec45 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS045 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec45 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S150
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA45 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s150 PRE_first_tail_x15_r0_body.sizeTys45 PRE_first_tail_x15_r0_body.sizeArgs45).run PRE_first_tail_x15_r0_body.S150 =
  some (some PRE_first_tail_x15_r0_body.sizeAs45, PRE_first_tail_x15_r0_body.sizeS045)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA45 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS045 PRE_first_tail_x15_r0_body.s150.ffi PRE_first_tail_x15_r0_body.sizeAs45 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA46 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s153 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA47 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s157 "plan" none = true
/-- Bridge 48's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys48 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s161 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs48 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s161 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA48 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s161 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys48, PRE_first_tail_x15_r0_body.sizeArgs48)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA48 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s161 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA48 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA48 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA48 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA48 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec48 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s161 PRE_first_tail_x15_r0_body.sizeTys48 PRE_first_tail_x15_r0_body.sizeArgs48).run PRE_first_tail_x15_r0_body.S161
noncomputable def PRE_first_tail_x15_r0_body.sizeAs48 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec48 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS048 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec48 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S161
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA48 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s161 PRE_first_tail_x15_r0_body.sizeTys48 PRE_first_tail_x15_r0_body.sizeArgs48).run PRE_first_tail_x15_r0_body.S161 =
  some (some PRE_first_tail_x15_r0_body.sizeAs48, PRE_first_tail_x15_r0_body.sizeS048)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA48 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS048 PRE_first_tail_x15_r0_body.s161.ffi PRE_first_tail_x15_r0_body.sizeAs48 = true
/-- Bridge 49's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys49 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s164 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs49 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s164 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA49 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s164 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys49, PRE_first_tail_x15_r0_body.sizeArgs49)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA49 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s164 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA49 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA49 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA49 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA49 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec49 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s164 PRE_first_tail_x15_r0_body.sizeTys49 PRE_first_tail_x15_r0_body.sizeArgs49).run PRE_first_tail_x15_r0_body.S164
noncomputable def PRE_first_tail_x15_r0_body.sizeAs49 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec49 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS049 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec49 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S164
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA49 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s164 PRE_first_tail_x15_r0_body.sizeTys49 PRE_first_tail_x15_r0_body.sizeArgs49).run PRE_first_tail_x15_r0_body.S164 =
  some (some PRE_first_tail_x15_r0_body.sizeAs49, PRE_first_tail_x15_r0_body.sizeS049)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA49 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS049 PRE_first_tail_x15_r0_body.s164.ffi PRE_first_tail_x15_r0_body.sizeAs49 = true
/-- Bridge 50's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys50 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s167 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs50 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s167 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA50 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s167 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys50, PRE_first_tail_x15_r0_body.sizeArgs50)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA50 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s167 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA50 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA50 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA50 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA50 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec50 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s167 PRE_first_tail_x15_r0_body.sizeTys50 PRE_first_tail_x15_r0_body.sizeArgs50).run PRE_first_tail_x15_r0_body.S167
noncomputable def PRE_first_tail_x15_r0_body.sizeAs50 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec50 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS050 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec50 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S167
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA50 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s167 PRE_first_tail_x15_r0_body.sizeTys50 PRE_first_tail_x15_r0_body.sizeArgs50).run PRE_first_tail_x15_r0_body.S167 =
  some (some PRE_first_tail_x15_r0_body.sizeAs50, PRE_first_tail_x15_r0_body.sizeS050)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA50 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS050 PRE_first_tail_x15_r0_body.s167.ffi PRE_first_tail_x15_r0_body.sizeAs50 = true
/-- Bridge 51's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys51 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s170 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs51 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s170 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA51 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s170 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys51, PRE_first_tail_x15_r0_body.sizeArgs51)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA51 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s170 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA51 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA51 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA51 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA51 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec51 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s170 PRE_first_tail_x15_r0_body.sizeTys51 PRE_first_tail_x15_r0_body.sizeArgs51).run PRE_first_tail_x15_r0_body.S170
noncomputable def PRE_first_tail_x15_r0_body.sizeAs51 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec51 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS051 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec51 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S170
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA51 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s170 PRE_first_tail_x15_r0_body.sizeTys51 PRE_first_tail_x15_r0_body.sizeArgs51).run PRE_first_tail_x15_r0_body.S170 =
  some (some PRE_first_tail_x15_r0_body.sizeAs51, PRE_first_tail_x15_r0_body.sizeS051)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA51 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS051 PRE_first_tail_x15_r0_body.s170.ffi PRE_first_tail_x15_r0_body.sizeAs51 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA52 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s173 "recurWindow" none = true
/-- Bridge 53's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys53 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s177 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs53 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s177 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA53 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s177 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys53, PRE_first_tail_x15_r0_body.sizeArgs53)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA53 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s177 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA53 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA53 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA53 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA53 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec53 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s177 PRE_first_tail_x15_r0_body.sizeTys53 PRE_first_tail_x15_r0_body.sizeArgs53).run PRE_first_tail_x15_r0_body.S177
noncomputable def PRE_first_tail_x15_r0_body.sizeAs53 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec53 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS053 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec53 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S177
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA53 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s177 PRE_first_tail_x15_r0_body.sizeTys53 PRE_first_tail_x15_r0_body.sizeArgs53).run PRE_first_tail_x15_r0_body.S177 =
  some (some PRE_first_tail_x15_r0_body.sizeAs53, PRE_first_tail_x15_r0_body.sizeS053)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA53 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS053 PRE_first_tail_x15_r0_body.s177.ffi PRE_first_tail_x15_r0_body.sizeAs53 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA54 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s180 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA55 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s184 "plan" none = true
/-- Bridge 56's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys56 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s188 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs56 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s188 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA56 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s188 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys56, PRE_first_tail_x15_r0_body.sizeArgs56)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA56 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s188 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA56 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA56 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA56 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA56 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec56 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s188 PRE_first_tail_x15_r0_body.sizeTys56 PRE_first_tail_x15_r0_body.sizeArgs56).run PRE_first_tail_x15_r0_body.S188
noncomputable def PRE_first_tail_x15_r0_body.sizeAs56 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec56 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS056 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec56 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S188
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA56 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s188 PRE_first_tail_x15_r0_body.sizeTys56 PRE_first_tail_x15_r0_body.sizeArgs56).run PRE_first_tail_x15_r0_body.S188 =
  some (some PRE_first_tail_x15_r0_body.sizeAs56, PRE_first_tail_x15_r0_body.sizeS056)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA56 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS056 PRE_first_tail_x15_r0_body.s188.ffi PRE_first_tail_x15_r0_body.sizeAs56 = true
/-- Bridge 57's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys57 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s191 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs57 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s191 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA57 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s191 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys57, PRE_first_tail_x15_r0_body.sizeArgs57)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA57 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s191 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA57 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA57 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA57 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA57 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec57 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s191 PRE_first_tail_x15_r0_body.sizeTys57 PRE_first_tail_x15_r0_body.sizeArgs57).run PRE_first_tail_x15_r0_body.S191
noncomputable def PRE_first_tail_x15_r0_body.sizeAs57 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec57 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS057 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec57 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S191
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA57 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s191 PRE_first_tail_x15_r0_body.sizeTys57 PRE_first_tail_x15_r0_body.sizeArgs57).run PRE_first_tail_x15_r0_body.S191 =
  some (some PRE_first_tail_x15_r0_body.sizeAs57, PRE_first_tail_x15_r0_body.sizeS057)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA57 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS057 PRE_first_tail_x15_r0_body.s191.ffi PRE_first_tail_x15_r0_body.sizeAs57 = true
/-- Bridge 58's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys58 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s194 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs58 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s194 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA58 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s194 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys58, PRE_first_tail_x15_r0_body.sizeArgs58)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA58 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s194 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA58 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA58 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA58 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA58 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec58 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s194 PRE_first_tail_x15_r0_body.sizeTys58 PRE_first_tail_x15_r0_body.sizeArgs58).run PRE_first_tail_x15_r0_body.S194
noncomputable def PRE_first_tail_x15_r0_body.sizeAs58 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec58 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS058 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec58 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S194
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA58 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s194 PRE_first_tail_x15_r0_body.sizeTys58 PRE_first_tail_x15_r0_body.sizeArgs58).run PRE_first_tail_x15_r0_body.S194 =
  some (some PRE_first_tail_x15_r0_body.sizeAs58, PRE_first_tail_x15_r0_body.sizeS058)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA58 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS058 PRE_first_tail_x15_r0_body.s194.ffi PRE_first_tail_x15_r0_body.sizeAs58 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA59 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s197 "appendWindow" none = true
/-- Bridge 60's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys60 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s201 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs60 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s201 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA60 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s201 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys60, PRE_first_tail_x15_r0_body.sizeArgs60)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA60 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s201 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA60 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA60 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA60 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA60 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec60 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s201 PRE_first_tail_x15_r0_body.sizeTys60 PRE_first_tail_x15_r0_body.sizeArgs60).run PRE_first_tail_x15_r0_body.S201
noncomputable def PRE_first_tail_x15_r0_body.sizeAs60 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec60 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS060 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec60 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S201
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA60 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s201 PRE_first_tail_x15_r0_body.sizeTys60 PRE_first_tail_x15_r0_body.sizeArgs60).run PRE_first_tail_x15_r0_body.S201 =
  some (some PRE_first_tail_x15_r0_body.sizeAs60, PRE_first_tail_x15_r0_body.sizeS060)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA60 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS060 PRE_first_tail_x15_r0_body.s201.ffi PRE_first_tail_x15_r0_body.sizeAs60 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA61 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s204 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA62 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s208 "plan" none = true
/-- Bridge 63's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys63 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s212 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs63 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s212 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA63 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s212 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys63, PRE_first_tail_x15_r0_body.sizeArgs63)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA63 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s212 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA63 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA63 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA63 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA63 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec63 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s212 PRE_first_tail_x15_r0_body.sizeTys63 PRE_first_tail_x15_r0_body.sizeArgs63).run PRE_first_tail_x15_r0_body.S212
noncomputable def PRE_first_tail_x15_r0_body.sizeAs63 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec63 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS063 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec63 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S212
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA63 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s212 PRE_first_tail_x15_r0_body.sizeTys63 PRE_first_tail_x15_r0_body.sizeArgs63).run PRE_first_tail_x15_r0_body.S212 =
  some (some PRE_first_tail_x15_r0_body.sizeAs63, PRE_first_tail_x15_r0_body.sizeS063)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA63 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS063 PRE_first_tail_x15_r0_body.s212.ffi PRE_first_tail_x15_r0_body.sizeAs63 = true
/-- Bridge 64's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys64 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s215 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs64 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s215 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA64 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s215 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys64, PRE_first_tail_x15_r0_body.sizeArgs64)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA64 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s215 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA64 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA64 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA64 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA64 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec64 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s215 PRE_first_tail_x15_r0_body.sizeTys64 PRE_first_tail_x15_r0_body.sizeArgs64).run PRE_first_tail_x15_r0_body.S215
noncomputable def PRE_first_tail_x15_r0_body.sizeAs64 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec64 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS064 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec64 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S215
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA64 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s215 PRE_first_tail_x15_r0_body.sizeTys64 PRE_first_tail_x15_r0_body.sizeArgs64).run PRE_first_tail_x15_r0_body.S215 =
  some (some PRE_first_tail_x15_r0_body.sizeAs64, PRE_first_tail_x15_r0_body.sizeS064)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA64 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS064 PRE_first_tail_x15_r0_body.s215.ffi PRE_first_tail_x15_r0_body.sizeAs64 = true
/-- Bridge 65's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys65 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s218 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs65 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s218 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA65 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s218 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys65, PRE_first_tail_x15_r0_body.sizeArgs65)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA65 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s218 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA65 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA65 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA65 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA65 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec65 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s218 PRE_first_tail_x15_r0_body.sizeTys65 PRE_first_tail_x15_r0_body.sizeArgs65).run PRE_first_tail_x15_r0_body.S218
noncomputable def PRE_first_tail_x15_r0_body.sizeAs65 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec65 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS065 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec65 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S218
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA65 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s218 PRE_first_tail_x15_r0_body.sizeTys65 PRE_first_tail_x15_r0_body.sizeArgs65).run PRE_first_tail_x15_r0_body.S218 =
  some (some PRE_first_tail_x15_r0_body.sizeAs65, PRE_first_tail_x15_r0_body.sizeS065)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA65 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS065 PRE_first_tail_x15_r0_body.s218.ffi PRE_first_tail_x15_r0_body.sizeAs65 = true
/-- Bridge 66's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys66 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s221 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs66 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s221 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA66 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s221 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys66, PRE_first_tail_x15_r0_body.sizeArgs66)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA66 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s221 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA66 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA66 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA66 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA66 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec66 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s221 PRE_first_tail_x15_r0_body.sizeTys66 PRE_first_tail_x15_r0_body.sizeArgs66).run PRE_first_tail_x15_r0_body.S221
noncomputable def PRE_first_tail_x15_r0_body.sizeAs66 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec66 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS066 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec66 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S221
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA66 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s221 PRE_first_tail_x15_r0_body.sizeTys66 PRE_first_tail_x15_r0_body.sizeArgs66).run PRE_first_tail_x15_r0_body.S221 =
  some (some PRE_first_tail_x15_r0_body.sizeAs66, PRE_first_tail_x15_r0_body.sizeS066)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA66 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS066 PRE_first_tail_x15_r0_body.s221.ffi PRE_first_tail_x15_r0_body.sizeAs66 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA67 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s224 "recurWindow" none = true
/-- Bridge 68's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys68 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s228 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs68 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s228 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA68 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s228 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys68, PRE_first_tail_x15_r0_body.sizeArgs68)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA68 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s228 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA68 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA68 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA68 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA68 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec68 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s228 PRE_first_tail_x15_r0_body.sizeTys68 PRE_first_tail_x15_r0_body.sizeArgs68).run PRE_first_tail_x15_r0_body.S228
noncomputable def PRE_first_tail_x15_r0_body.sizeAs68 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec68 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS068 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec68 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S228
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA68 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s228 PRE_first_tail_x15_r0_body.sizeTys68 PRE_first_tail_x15_r0_body.sizeArgs68).run PRE_first_tail_x15_r0_body.S228 =
  some (some PRE_first_tail_x15_r0_body.sizeAs68, PRE_first_tail_x15_r0_body.sizeS068)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA68 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS068 PRE_first_tail_x15_r0_body.s228.ffi PRE_first_tail_x15_r0_body.sizeAs68 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA69 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s231 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA70 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s235 "plan" none = true
/-- Bridge 71's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys71 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s239 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs71 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s239 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA71 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s239 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys71, PRE_first_tail_x15_r0_body.sizeArgs71)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA71 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s239 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA71 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA71 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA71 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA71 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec71 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s239 PRE_first_tail_x15_r0_body.sizeTys71 PRE_first_tail_x15_r0_body.sizeArgs71).run PRE_first_tail_x15_r0_body.S239
noncomputable def PRE_first_tail_x15_r0_body.sizeAs71 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec71 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS071 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec71 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S239
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA71 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s239 PRE_first_tail_x15_r0_body.sizeTys71 PRE_first_tail_x15_r0_body.sizeArgs71).run PRE_first_tail_x15_r0_body.S239 =
  some (some PRE_first_tail_x15_r0_body.sizeAs71, PRE_first_tail_x15_r0_body.sizeS071)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA71 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS071 PRE_first_tail_x15_r0_body.s239.ffi PRE_first_tail_x15_r0_body.sizeAs71 = true
/-- Bridge 72's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys72 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s242 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs72 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s242 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA72 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s242 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys72, PRE_first_tail_x15_r0_body.sizeArgs72)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA72 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s242 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA72 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA72 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA72 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA72 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec72 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s242 PRE_first_tail_x15_r0_body.sizeTys72 PRE_first_tail_x15_r0_body.sizeArgs72).run PRE_first_tail_x15_r0_body.S242
noncomputable def PRE_first_tail_x15_r0_body.sizeAs72 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec72 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS072 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec72 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S242
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA72 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s242 PRE_first_tail_x15_r0_body.sizeTys72 PRE_first_tail_x15_r0_body.sizeArgs72).run PRE_first_tail_x15_r0_body.S242 =
  some (some PRE_first_tail_x15_r0_body.sizeAs72, PRE_first_tail_x15_r0_body.sizeS072)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA72 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS072 PRE_first_tail_x15_r0_body.s242.ffi PRE_first_tail_x15_r0_body.sizeAs72 = true
/-- Bridge 73's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys73 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s245 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs73 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s245 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA73 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s245 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys73, PRE_first_tail_x15_r0_body.sizeArgs73)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA73 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s245 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA73 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA73 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA73 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA73 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec73 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s245 PRE_first_tail_x15_r0_body.sizeTys73 PRE_first_tail_x15_r0_body.sizeArgs73).run PRE_first_tail_x15_r0_body.S245
noncomputable def PRE_first_tail_x15_r0_body.sizeAs73 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec73 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS073 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec73 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S245
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA73 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s245 PRE_first_tail_x15_r0_body.sizeTys73 PRE_first_tail_x15_r0_body.sizeArgs73).run PRE_first_tail_x15_r0_body.S245 =
  some (some PRE_first_tail_x15_r0_body.sizeAs73, PRE_first_tail_x15_r0_body.sizeS073)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA73 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS073 PRE_first_tail_x15_r0_body.s245.ffi PRE_first_tail_x15_r0_body.sizeAs73 = true
/-- Bridge 74's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys74 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s248 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs74 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s248 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA74 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s248 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys74, PRE_first_tail_x15_r0_body.sizeArgs74)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA74 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s248 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA74 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA74 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA74 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA74 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec74 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s248 PRE_first_tail_x15_r0_body.sizeTys74 PRE_first_tail_x15_r0_body.sizeArgs74).run PRE_first_tail_x15_r0_body.S248
noncomputable def PRE_first_tail_x15_r0_body.sizeAs74 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec74 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS074 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec74 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S248
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA74 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s248 PRE_first_tail_x15_r0_body.sizeTys74 PRE_first_tail_x15_r0_body.sizeArgs74).run PRE_first_tail_x15_r0_body.S248 =
  some (some PRE_first_tail_x15_r0_body.sizeAs74, PRE_first_tail_x15_r0_body.sizeS074)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA74 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS074 PRE_first_tail_x15_r0_body.s248.ffi PRE_first_tail_x15_r0_body.sizeAs74 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA75 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s251 "recurWindow" none = true
/-- Bridge 76's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys76 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s255 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs76 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s255 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA76 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s255 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys76, PRE_first_tail_x15_r0_body.sizeArgs76)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA76 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s255 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA76 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA76 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA76 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA76 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec76 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s255 PRE_first_tail_x15_r0_body.sizeTys76 PRE_first_tail_x15_r0_body.sizeArgs76).run PRE_first_tail_x15_r0_body.S255
noncomputable def PRE_first_tail_x15_r0_body.sizeAs76 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec76 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS076 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec76 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S255
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA76 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s255 PRE_first_tail_x15_r0_body.sizeTys76 PRE_first_tail_x15_r0_body.sizeArgs76).run PRE_first_tail_x15_r0_body.S255 =
  some (some PRE_first_tail_x15_r0_body.sizeAs76, PRE_first_tail_x15_r0_body.sizeS076)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA76 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS076 PRE_first_tail_x15_r0_body.s255.ffi PRE_first_tail_x15_r0_body.sizeAs76 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA77 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s258 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA78 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s262 "plan" none = true
/-- Bridge 79's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys79 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s266 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs79 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s266 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA79 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s266 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys79, PRE_first_tail_x15_r0_body.sizeArgs79)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA79 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s266 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA79 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA79 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA79 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA79 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec79 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s266 PRE_first_tail_x15_r0_body.sizeTys79 PRE_first_tail_x15_r0_body.sizeArgs79).run PRE_first_tail_x15_r0_body.S266
noncomputable def PRE_first_tail_x15_r0_body.sizeAs79 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec79 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS079 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec79 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S266
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA79 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s266 PRE_first_tail_x15_r0_body.sizeTys79 PRE_first_tail_x15_r0_body.sizeArgs79).run PRE_first_tail_x15_r0_body.S266 =
  some (some PRE_first_tail_x15_r0_body.sizeAs79, PRE_first_tail_x15_r0_body.sizeS079)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA79 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS079 PRE_first_tail_x15_r0_body.s266.ffi PRE_first_tail_x15_r0_body.sizeAs79 = true
/-- Bridge 80's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys80 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s269 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs80 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s269 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA80 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s269 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys80, PRE_first_tail_x15_r0_body.sizeArgs80)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA80 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s269 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA80 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA80 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA80 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA80 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec80 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s269 PRE_first_tail_x15_r0_body.sizeTys80 PRE_first_tail_x15_r0_body.sizeArgs80).run PRE_first_tail_x15_r0_body.S269
noncomputable def PRE_first_tail_x15_r0_body.sizeAs80 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec80 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS080 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec80 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S269
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA80 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s269 PRE_first_tail_x15_r0_body.sizeTys80 PRE_first_tail_x15_r0_body.sizeArgs80).run PRE_first_tail_x15_r0_body.S269 =
  some (some PRE_first_tail_x15_r0_body.sizeAs80, PRE_first_tail_x15_r0_body.sizeS080)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA80 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS080 PRE_first_tail_x15_r0_body.s269.ffi PRE_first_tail_x15_r0_body.sizeAs80 = true
/-- Bridge 81's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys81 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s272 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs81 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s272 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA81 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s272 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys81, PRE_first_tail_x15_r0_body.sizeArgs81)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA81 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s272 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA81 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA81 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA81 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA81 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec81 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s272 PRE_first_tail_x15_r0_body.sizeTys81 PRE_first_tail_x15_r0_body.sizeArgs81).run PRE_first_tail_x15_r0_body.S272
noncomputable def PRE_first_tail_x15_r0_body.sizeAs81 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec81 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS081 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec81 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S272
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA81 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s272 PRE_first_tail_x15_r0_body.sizeTys81 PRE_first_tail_x15_r0_body.sizeArgs81).run PRE_first_tail_x15_r0_body.S272 =
  some (some PRE_first_tail_x15_r0_body.sizeAs81, PRE_first_tail_x15_r0_body.sizeS081)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA81 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS081 PRE_first_tail_x15_r0_body.s272.ffi PRE_first_tail_x15_r0_body.sizeAs81 = true
/-- Bridge 82's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys82 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s275 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs82 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s275 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA82 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s275 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys82, PRE_first_tail_x15_r0_body.sizeArgs82)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA82 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s275 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA82 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA82 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA82 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA82 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec82 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s275 PRE_first_tail_x15_r0_body.sizeTys82 PRE_first_tail_x15_r0_body.sizeArgs82).run PRE_first_tail_x15_r0_body.S275
noncomputable def PRE_first_tail_x15_r0_body.sizeAs82 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec82 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS082 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec82 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S275
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA82 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s275 PRE_first_tail_x15_r0_body.sizeTys82 PRE_first_tail_x15_r0_body.sizeArgs82).run PRE_first_tail_x15_r0_body.S275 =
  some (some PRE_first_tail_x15_r0_body.sizeAs82, PRE_first_tail_x15_r0_body.sizeS082)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA82 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS082 PRE_first_tail_x15_r0_body.s275.ffi PRE_first_tail_x15_r0_body.sizeAs82 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA83 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s278 "recurWindow" none = true
/-- Bridge 84's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys84 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s282 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs84 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s282 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA84 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s282 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys84, PRE_first_tail_x15_r0_body.sizeArgs84)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA84 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s282 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA84 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA84 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA84 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA84 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec84 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s282 PRE_first_tail_x15_r0_body.sizeTys84 PRE_first_tail_x15_r0_body.sizeArgs84).run PRE_first_tail_x15_r0_body.S282
noncomputable def PRE_first_tail_x15_r0_body.sizeAs84 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec84 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS084 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec84 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S282
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA84 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s282 PRE_first_tail_x15_r0_body.sizeTys84 PRE_first_tail_x15_r0_body.sizeArgs84).run PRE_first_tail_x15_r0_body.S282 =
  some (some PRE_first_tail_x15_r0_body.sizeAs84, PRE_first_tail_x15_r0_body.sizeS084)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA84 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS084 PRE_first_tail_x15_r0_body.s282.ffi PRE_first_tail_x15_r0_body.sizeAs84 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA85 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s285 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA86 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s289 "plan" none = true
/-- Bridge 87's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys87 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s293 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs87 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s293 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA87 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s293 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys87, PRE_first_tail_x15_r0_body.sizeArgs87)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA87 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s293 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA87 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA87 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA87 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA87 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec87 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s293 PRE_first_tail_x15_r0_body.sizeTys87 PRE_first_tail_x15_r0_body.sizeArgs87).run PRE_first_tail_x15_r0_body.S293
noncomputable def PRE_first_tail_x15_r0_body.sizeAs87 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec87 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS087 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec87 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S293
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA87 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s293 PRE_first_tail_x15_r0_body.sizeTys87 PRE_first_tail_x15_r0_body.sizeArgs87).run PRE_first_tail_x15_r0_body.S293 =
  some (some PRE_first_tail_x15_r0_body.sizeAs87, PRE_first_tail_x15_r0_body.sizeS087)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA87 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS087 PRE_first_tail_x15_r0_body.s293.ffi PRE_first_tail_x15_r0_body.sizeAs87 = true
/-- Bridge 88's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys88 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s296 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs88 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s296 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA88 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s296 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys88, PRE_first_tail_x15_r0_body.sizeArgs88)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA88 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s296 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA88 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA88 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA88 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA88 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec88 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s296 PRE_first_tail_x15_r0_body.sizeTys88 PRE_first_tail_x15_r0_body.sizeArgs88).run PRE_first_tail_x15_r0_body.S296
noncomputable def PRE_first_tail_x15_r0_body.sizeAs88 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec88 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS088 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec88 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S296
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA88 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s296 PRE_first_tail_x15_r0_body.sizeTys88 PRE_first_tail_x15_r0_body.sizeArgs88).run PRE_first_tail_x15_r0_body.S296 =
  some (some PRE_first_tail_x15_r0_body.sizeAs88, PRE_first_tail_x15_r0_body.sizeS088)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA88 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS088 PRE_first_tail_x15_r0_body.s296.ffi PRE_first_tail_x15_r0_body.sizeAs88 = true
/-- Bridge 89's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys89 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s299 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs89 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s299 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA89 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s299 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys89, PRE_first_tail_x15_r0_body.sizeArgs89)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA89 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s299 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA89 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA89 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA89 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA89 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec89 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s299 PRE_first_tail_x15_r0_body.sizeTys89 PRE_first_tail_x15_r0_body.sizeArgs89).run PRE_first_tail_x15_r0_body.S299
noncomputable def PRE_first_tail_x15_r0_body.sizeAs89 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec89 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS089 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec89 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S299
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA89 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s299 PRE_first_tail_x15_r0_body.sizeTys89 PRE_first_tail_x15_r0_body.sizeArgs89).run PRE_first_tail_x15_r0_body.S299 =
  some (some PRE_first_tail_x15_r0_body.sizeAs89, PRE_first_tail_x15_r0_body.sizeS089)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA89 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS089 PRE_first_tail_x15_r0_body.s299.ffi PRE_first_tail_x15_r0_body.sizeAs89 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA90 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s302 "appendWindow" none = true
/-- Bridge 91's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys91 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s306 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs91 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s306 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA91 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s306 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys91, PRE_first_tail_x15_r0_body.sizeArgs91)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA91 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s306 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA91 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA91 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA91 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA91 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec91 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s306 PRE_first_tail_x15_r0_body.sizeTys91 PRE_first_tail_x15_r0_body.sizeArgs91).run PRE_first_tail_x15_r0_body.S306
noncomputable def PRE_first_tail_x15_r0_body.sizeAs91 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec91 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS091 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec91 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S306
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA91 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s306 PRE_first_tail_x15_r0_body.sizeTys91 PRE_first_tail_x15_r0_body.sizeArgs91).run PRE_first_tail_x15_r0_body.S306 =
  some (some PRE_first_tail_x15_r0_body.sizeAs91, PRE_first_tail_x15_r0_body.sizeS091)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA91 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS091 PRE_first_tail_x15_r0_body.s306.ffi PRE_first_tail_x15_r0_body.sizeAs91 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA92 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s309 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA93 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s313 "plan" none = true
/-- Bridge 94's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys94 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s317 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs94 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s317 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA94 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s317 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys94, PRE_first_tail_x15_r0_body.sizeArgs94)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA94 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s317 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA94 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA94 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA94 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA94 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec94 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s317 PRE_first_tail_x15_r0_body.sizeTys94 PRE_first_tail_x15_r0_body.sizeArgs94).run PRE_first_tail_x15_r0_body.S317
noncomputable def PRE_first_tail_x15_r0_body.sizeAs94 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec94 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS094 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec94 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S317
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA94 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s317 PRE_first_tail_x15_r0_body.sizeTys94 PRE_first_tail_x15_r0_body.sizeArgs94).run PRE_first_tail_x15_r0_body.S317 =
  some (some PRE_first_tail_x15_r0_body.sizeAs94, PRE_first_tail_x15_r0_body.sizeS094)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA94 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS094 PRE_first_tail_x15_r0_body.s317.ffi PRE_first_tail_x15_r0_body.sizeAs94 = true
/-- Bridge 95's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys95 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s320 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs95 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s320 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA95 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s320 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys95, PRE_first_tail_x15_r0_body.sizeArgs95)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA95 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s320 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA95 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA95 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA95 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA95 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec95 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s320 PRE_first_tail_x15_r0_body.sizeTys95 PRE_first_tail_x15_r0_body.sizeArgs95).run PRE_first_tail_x15_r0_body.S320
noncomputable def PRE_first_tail_x15_r0_body.sizeAs95 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec95 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS095 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec95 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S320
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA95 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s320 PRE_first_tail_x15_r0_body.sizeTys95 PRE_first_tail_x15_r0_body.sizeArgs95).run PRE_first_tail_x15_r0_body.S320 =
  some (some PRE_first_tail_x15_r0_body.sizeAs95, PRE_first_tail_x15_r0_body.sizeS095)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA95 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS095 PRE_first_tail_x15_r0_body.s320.ffi PRE_first_tail_x15_r0_body.sizeAs95 = true
/-- Bridge 96's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys96 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s323 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs96 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s323 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA96 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s323 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys96, PRE_first_tail_x15_r0_body.sizeArgs96)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA96 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s323 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA96 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA96 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA96 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA96 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec96 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s323 PRE_first_tail_x15_r0_body.sizeTys96 PRE_first_tail_x15_r0_body.sizeArgs96).run PRE_first_tail_x15_r0_body.S323
noncomputable def PRE_first_tail_x15_r0_body.sizeAs96 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec96 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS096 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec96 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S323
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA96 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s323 PRE_first_tail_x15_r0_body.sizeTys96 PRE_first_tail_x15_r0_body.sizeArgs96).run PRE_first_tail_x15_r0_body.S323 =
  some (some PRE_first_tail_x15_r0_body.sizeAs96, PRE_first_tail_x15_r0_body.sizeS096)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA96 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS096 PRE_first_tail_x15_r0_body.s323.ffi PRE_first_tail_x15_r0_body.sizeAs96 = true
/-- Bridge 97's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys97 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s326 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs97 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s326 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA97 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s326 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys97, PRE_first_tail_x15_r0_body.sizeArgs97)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA97 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s326 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA97 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA97 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA97 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA97 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec97 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s326 PRE_first_tail_x15_r0_body.sizeTys97 PRE_first_tail_x15_r0_body.sizeArgs97).run PRE_first_tail_x15_r0_body.S326
noncomputable def PRE_first_tail_x15_r0_body.sizeAs97 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec97 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS097 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec97 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S326
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA97 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s326 PRE_first_tail_x15_r0_body.sizeTys97 PRE_first_tail_x15_r0_body.sizeArgs97).run PRE_first_tail_x15_r0_body.S326 =
  some (some PRE_first_tail_x15_r0_body.sizeAs97, PRE_first_tail_x15_r0_body.sizeS097)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA97 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS097 PRE_first_tail_x15_r0_body.s326.ffi PRE_first_tail_x15_r0_body.sizeAs97 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA98 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s329 "recurWindow" none = true
/-- Bridge 99's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys99 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s333 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs99 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s333 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA99 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s333 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys99, PRE_first_tail_x15_r0_body.sizeArgs99)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA99 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s333 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA99 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA99 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA99 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA99 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec99 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s333 PRE_first_tail_x15_r0_body.sizeTys99 PRE_first_tail_x15_r0_body.sizeArgs99).run PRE_first_tail_x15_r0_body.S333
noncomputable def PRE_first_tail_x15_r0_body.sizeAs99 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec99 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS099 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec99 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S333
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA99 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s333 PRE_first_tail_x15_r0_body.sizeTys99 PRE_first_tail_x15_r0_body.sizeArgs99).run PRE_first_tail_x15_r0_body.S333 =
  some (some PRE_first_tail_x15_r0_body.sizeAs99, PRE_first_tail_x15_r0_body.sizeS099)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA99 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS099 PRE_first_tail_x15_r0_body.s333.ffi PRE_first_tail_x15_r0_body.sizeAs99 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA100 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s336 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA101 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s340 "plan" none = true
/-- Bridge 102's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys102 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s344 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs102 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s344 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA102 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s344 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys102, PRE_first_tail_x15_r0_body.sizeArgs102)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA102 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s344 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA102 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA102 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA102 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA102 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec102 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s344 PRE_first_tail_x15_r0_body.sizeTys102 PRE_first_tail_x15_r0_body.sizeArgs102).run PRE_first_tail_x15_r0_body.S344
noncomputable def PRE_first_tail_x15_r0_body.sizeAs102 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec102 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0102 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec102 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S344
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA102 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s344 PRE_first_tail_x15_r0_body.sizeTys102 PRE_first_tail_x15_r0_body.sizeArgs102).run PRE_first_tail_x15_r0_body.S344 =
  some (some PRE_first_tail_x15_r0_body.sizeAs102, PRE_first_tail_x15_r0_body.sizeS0102)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA102 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0102 PRE_first_tail_x15_r0_body.s344.ffi PRE_first_tail_x15_r0_body.sizeAs102 = true
/-- Bridge 103's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys103 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s347 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs103 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s347 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA103 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s347 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys103, PRE_first_tail_x15_r0_body.sizeArgs103)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA103 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s347 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA103 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA103 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA103 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA103 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec103 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s347 PRE_first_tail_x15_r0_body.sizeTys103 PRE_first_tail_x15_r0_body.sizeArgs103).run PRE_first_tail_x15_r0_body.S347
noncomputable def PRE_first_tail_x15_r0_body.sizeAs103 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec103 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0103 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec103 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S347
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA103 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s347 PRE_first_tail_x15_r0_body.sizeTys103 PRE_first_tail_x15_r0_body.sizeArgs103).run PRE_first_tail_x15_r0_body.S347 =
  some (some PRE_first_tail_x15_r0_body.sizeAs103, PRE_first_tail_x15_r0_body.sizeS0103)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA103 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0103 PRE_first_tail_x15_r0_body.s347.ffi PRE_first_tail_x15_r0_body.sizeAs103 = true
/-- Bridge 104's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys104 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s350 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs104 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s350 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA104 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s350 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys104, PRE_first_tail_x15_r0_body.sizeArgs104)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA104 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s350 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA104 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA104 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA104 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA104 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec104 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s350 PRE_first_tail_x15_r0_body.sizeTys104 PRE_first_tail_x15_r0_body.sizeArgs104).run PRE_first_tail_x15_r0_body.S350
noncomputable def PRE_first_tail_x15_r0_body.sizeAs104 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec104 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0104 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec104 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S350
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA104 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s350 PRE_first_tail_x15_r0_body.sizeTys104 PRE_first_tail_x15_r0_body.sizeArgs104).run PRE_first_tail_x15_r0_body.S350 =
  some (some PRE_first_tail_x15_r0_body.sizeAs104, PRE_first_tail_x15_r0_body.sizeS0104)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA104 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0104 PRE_first_tail_x15_r0_body.s350.ffi PRE_first_tail_x15_r0_body.sizeAs104 = true
/-- Bridge 105's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys105 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s353 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs105 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s353 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA105 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s353 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys105, PRE_first_tail_x15_r0_body.sizeArgs105)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA105 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s353 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA105 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA105 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA105 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA105 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec105 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s353 PRE_first_tail_x15_r0_body.sizeTys105 PRE_first_tail_x15_r0_body.sizeArgs105).run PRE_first_tail_x15_r0_body.S353
noncomputable def PRE_first_tail_x15_r0_body.sizeAs105 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec105 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0105 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec105 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S353
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA105 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s353 PRE_first_tail_x15_r0_body.sizeTys105 PRE_first_tail_x15_r0_body.sizeArgs105).run PRE_first_tail_x15_r0_body.S353 =
  some (some PRE_first_tail_x15_r0_body.sizeAs105, PRE_first_tail_x15_r0_body.sizeS0105)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA105 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0105 PRE_first_tail_x15_r0_body.s353.ffi PRE_first_tail_x15_r0_body.sizeAs105 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA106 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s356 "recurWindow" none = true
/-- Bridge 107's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys107 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s360 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs107 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s360 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA107 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s360 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys107, PRE_first_tail_x15_r0_body.sizeArgs107)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA107 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s360 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA107 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA107 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA107 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA107 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec107 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s360 PRE_first_tail_x15_r0_body.sizeTys107 PRE_first_tail_x15_r0_body.sizeArgs107).run PRE_first_tail_x15_r0_body.S360
noncomputable def PRE_first_tail_x15_r0_body.sizeAs107 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec107 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0107 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec107 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S360
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA107 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s360 PRE_first_tail_x15_r0_body.sizeTys107 PRE_first_tail_x15_r0_body.sizeArgs107).run PRE_first_tail_x15_r0_body.S360 =
  some (some PRE_first_tail_x15_r0_body.sizeAs107, PRE_first_tail_x15_r0_body.sizeS0107)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA107 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0107 PRE_first_tail_x15_r0_body.s360.ffi PRE_first_tail_x15_r0_body.sizeAs107 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA108 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s363 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA109 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s367 "plan" none = true
/-- Bridge 110's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys110 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s371 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs110 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s371 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA110 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s371 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys110, PRE_first_tail_x15_r0_body.sizeArgs110)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA110 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s371 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA110 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA110 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA110 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA110 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec110 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s371 PRE_first_tail_x15_r0_body.sizeTys110 PRE_first_tail_x15_r0_body.sizeArgs110).run PRE_first_tail_x15_r0_body.S371
noncomputable def PRE_first_tail_x15_r0_body.sizeAs110 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec110 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0110 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec110 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S371
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA110 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s371 PRE_first_tail_x15_r0_body.sizeTys110 PRE_first_tail_x15_r0_body.sizeArgs110).run PRE_first_tail_x15_r0_body.S371 =
  some (some PRE_first_tail_x15_r0_body.sizeAs110, PRE_first_tail_x15_r0_body.sizeS0110)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA110 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0110 PRE_first_tail_x15_r0_body.s371.ffi PRE_first_tail_x15_r0_body.sizeAs110 = true
/-- Bridge 111's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys111 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s374 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs111 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s374 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA111 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s374 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys111, PRE_first_tail_x15_r0_body.sizeArgs111)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA111 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s374 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA111 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA111 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA111 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA111 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec111 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s374 PRE_first_tail_x15_r0_body.sizeTys111 PRE_first_tail_x15_r0_body.sizeArgs111).run PRE_first_tail_x15_r0_body.S374
noncomputable def PRE_first_tail_x15_r0_body.sizeAs111 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec111 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0111 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec111 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S374
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA111 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s374 PRE_first_tail_x15_r0_body.sizeTys111 PRE_first_tail_x15_r0_body.sizeArgs111).run PRE_first_tail_x15_r0_body.S374 =
  some (some PRE_first_tail_x15_r0_body.sizeAs111, PRE_first_tail_x15_r0_body.sizeS0111)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA111 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0111 PRE_first_tail_x15_r0_body.s374.ffi PRE_first_tail_x15_r0_body.sizeAs111 = true
/-- Bridge 112's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys112 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s377 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs112 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s377 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA112 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s377 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys112, PRE_first_tail_x15_r0_body.sizeArgs112)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA112 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s377 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA112 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA112 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA112 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA112 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec112 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s377 PRE_first_tail_x15_r0_body.sizeTys112 PRE_first_tail_x15_r0_body.sizeArgs112).run PRE_first_tail_x15_r0_body.S377
noncomputable def PRE_first_tail_x15_r0_body.sizeAs112 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec112 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0112 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec112 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S377
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA112 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s377 PRE_first_tail_x15_r0_body.sizeTys112 PRE_first_tail_x15_r0_body.sizeArgs112).run PRE_first_tail_x15_r0_body.S377 =
  some (some PRE_first_tail_x15_r0_body.sizeAs112, PRE_first_tail_x15_r0_body.sizeS0112)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA112 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0112 PRE_first_tail_x15_r0_body.s377.ffi PRE_first_tail_x15_r0_body.sizeAs112 = true
/-- Bridge 113's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys113 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s380 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs113 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s380 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA113 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s380 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys113, PRE_first_tail_x15_r0_body.sizeArgs113)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA113 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s380 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA113 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA113 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA113 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA113 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec113 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s380 PRE_first_tail_x15_r0_body.sizeTys113 PRE_first_tail_x15_r0_body.sizeArgs113).run PRE_first_tail_x15_r0_body.S380
noncomputable def PRE_first_tail_x15_r0_body.sizeAs113 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec113 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0113 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec113 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S380
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA113 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s380 PRE_first_tail_x15_r0_body.sizeTys113 PRE_first_tail_x15_r0_body.sizeArgs113).run PRE_first_tail_x15_r0_body.S380 =
  some (some PRE_first_tail_x15_r0_body.sizeAs113, PRE_first_tail_x15_r0_body.sizeS0113)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA113 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0113 PRE_first_tail_x15_r0_body.s380.ffi PRE_first_tail_x15_r0_body.sizeAs113 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA114 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s383 "recurWindow" none = true
/-- Bridge 115's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys115 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s387 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs115 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s387 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA115 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s387 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys115, PRE_first_tail_x15_r0_body.sizeArgs115)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA115 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s387 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA115 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA115 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA115 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA115 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec115 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s387 PRE_first_tail_x15_r0_body.sizeTys115 PRE_first_tail_x15_r0_body.sizeArgs115).run PRE_first_tail_x15_r0_body.S387
noncomputable def PRE_first_tail_x15_r0_body.sizeAs115 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec115 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0115 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec115 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S387
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA115 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s387 PRE_first_tail_x15_r0_body.sizeTys115 PRE_first_tail_x15_r0_body.sizeArgs115).run PRE_first_tail_x15_r0_body.S387 =
  some (some PRE_first_tail_x15_r0_body.sizeAs115, PRE_first_tail_x15_r0_body.sizeS0115)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA115 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0115 PRE_first_tail_x15_r0_body.s387.ffi PRE_first_tail_x15_r0_body.sizeAs115 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA116 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s390 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA117 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s394 "plan" none = true
/-- Bridge 118's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys118 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s398 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs118 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s398 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA118 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s398 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys118, PRE_first_tail_x15_r0_body.sizeArgs118)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA118 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s398 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA118 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA118 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA118 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA118 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec118 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s398 PRE_first_tail_x15_r0_body.sizeTys118 PRE_first_tail_x15_r0_body.sizeArgs118).run PRE_first_tail_x15_r0_body.S398
noncomputable def PRE_first_tail_x15_r0_body.sizeAs118 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec118 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0118 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec118 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S398
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA118 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s398 PRE_first_tail_x15_r0_body.sizeTys118 PRE_first_tail_x15_r0_body.sizeArgs118).run PRE_first_tail_x15_r0_body.S398 =
  some (some PRE_first_tail_x15_r0_body.sizeAs118, PRE_first_tail_x15_r0_body.sizeS0118)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA118 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0118 PRE_first_tail_x15_r0_body.s398.ffi PRE_first_tail_x15_r0_body.sizeAs118 = true
/-- Bridge 119's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys119 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s401 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs119 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s401 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA119 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s401 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys119, PRE_first_tail_x15_r0_body.sizeArgs119)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA119 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s401 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA119 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA119 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA119 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA119 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec119 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s401 PRE_first_tail_x15_r0_body.sizeTys119 PRE_first_tail_x15_r0_body.sizeArgs119).run PRE_first_tail_x15_r0_body.S401
noncomputable def PRE_first_tail_x15_r0_body.sizeAs119 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec119 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0119 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec119 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S401
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA119 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s401 PRE_first_tail_x15_r0_body.sizeTys119 PRE_first_tail_x15_r0_body.sizeArgs119).run PRE_first_tail_x15_r0_body.S401 =
  some (some PRE_first_tail_x15_r0_body.sizeAs119, PRE_first_tail_x15_r0_body.sizeS0119)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA119 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0119 PRE_first_tail_x15_r0_body.s401.ffi PRE_first_tail_x15_r0_body.sizeAs119 = true
/-- Bridge 120's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys120 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s404 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs120 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s404 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA120 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s404 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys120, PRE_first_tail_x15_r0_body.sizeArgs120)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA120 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s404 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA120 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA120 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA120 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA120 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec120 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.sizeTys120 PRE_first_tail_x15_r0_body.sizeArgs120).run PRE_first_tail_x15_r0_body.S404
noncomputable def PRE_first_tail_x15_r0_body.sizeAs120 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec120 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0120 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec120 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S404
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA120 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.sizeTys120 PRE_first_tail_x15_r0_body.sizeArgs120).run PRE_first_tail_x15_r0_body.S404 =
  some (some PRE_first_tail_x15_r0_body.sizeAs120, PRE_first_tail_x15_r0_body.sizeS0120)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA120 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0120 PRE_first_tail_x15_r0_body.s404.ffi PRE_first_tail_x15_r0_body.sizeAs120 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA121 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s407 "appendWindow" none = true
/-- Bridge 122's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys122 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s411 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs122 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s411 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA122 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s411 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys122, PRE_first_tail_x15_r0_body.sizeArgs122)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA122 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s411 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA122 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA122 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA122 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA122 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec122 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s411 PRE_first_tail_x15_r0_body.sizeTys122 PRE_first_tail_x15_r0_body.sizeArgs122).run PRE_first_tail_x15_r0_body.S411
noncomputable def PRE_first_tail_x15_r0_body.sizeAs122 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec122 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0122 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec122 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S411
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA122 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s411 PRE_first_tail_x15_r0_body.sizeTys122 PRE_first_tail_x15_r0_body.sizeArgs122).run PRE_first_tail_x15_r0_body.S411 =
  some (some PRE_first_tail_x15_r0_body.sizeAs122, PRE_first_tail_x15_r0_body.sizeS0122)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA122 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0122 PRE_first_tail_x15_r0_body.s411.ffi PRE_first_tail_x15_r0_body.sizeAs122 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA123 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s414 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA124 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s418 "plan" none = true
/-- Bridge 125's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys125 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s422 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs125 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s422 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA125 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s422 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys125, PRE_first_tail_x15_r0_body.sizeArgs125)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA125 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s422 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA125 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA125 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA125 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA125 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec125 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s422 PRE_first_tail_x15_r0_body.sizeTys125 PRE_first_tail_x15_r0_body.sizeArgs125).run PRE_first_tail_x15_r0_body.S422
noncomputable def PRE_first_tail_x15_r0_body.sizeAs125 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec125 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0125 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec125 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S422
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA125 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s422 PRE_first_tail_x15_r0_body.sizeTys125 PRE_first_tail_x15_r0_body.sizeArgs125).run PRE_first_tail_x15_r0_body.S422 =
  some (some PRE_first_tail_x15_r0_body.sizeAs125, PRE_first_tail_x15_r0_body.sizeS0125)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA125 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0125 PRE_first_tail_x15_r0_body.s422.ffi PRE_first_tail_x15_r0_body.sizeAs125 = true
/-- Bridge 126's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys126 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s425 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs126 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s425 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA126 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s425 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys126, PRE_first_tail_x15_r0_body.sizeArgs126)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA126 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s425 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA126 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA126 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA126 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA126 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec126 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s425 PRE_first_tail_x15_r0_body.sizeTys126 PRE_first_tail_x15_r0_body.sizeArgs126).run PRE_first_tail_x15_r0_body.S425
noncomputable def PRE_first_tail_x15_r0_body.sizeAs126 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec126 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0126 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec126 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S425
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA126 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s425 PRE_first_tail_x15_r0_body.sizeTys126 PRE_first_tail_x15_r0_body.sizeArgs126).run PRE_first_tail_x15_r0_body.S425 =
  some (some PRE_first_tail_x15_r0_body.sizeAs126, PRE_first_tail_x15_r0_body.sizeS0126)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA126 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0126 PRE_first_tail_x15_r0_body.s425.ffi PRE_first_tail_x15_r0_body.sizeAs126 = true
/-- Bridge 127's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys127 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s428 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs127 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s428 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA127 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s428 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys127, PRE_first_tail_x15_r0_body.sizeArgs127)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA127 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s428 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA127 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA127 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA127 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA127 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec127 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s428 PRE_first_tail_x15_r0_body.sizeTys127 PRE_first_tail_x15_r0_body.sizeArgs127).run PRE_first_tail_x15_r0_body.S428
noncomputable def PRE_first_tail_x15_r0_body.sizeAs127 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec127 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0127 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec127 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S428
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA127 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s428 PRE_first_tail_x15_r0_body.sizeTys127 PRE_first_tail_x15_r0_body.sizeArgs127).run PRE_first_tail_x15_r0_body.S428 =
  some (some PRE_first_tail_x15_r0_body.sizeAs127, PRE_first_tail_x15_r0_body.sizeS0127)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA127 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0127 PRE_first_tail_x15_r0_body.s428.ffi PRE_first_tail_x15_r0_body.sizeAs127 = true
/-- Bridge 128's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys128 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s431 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs128 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s431 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA128 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s431 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys128, PRE_first_tail_x15_r0_body.sizeArgs128)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA128 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s431 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA128 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA128 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA128 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA128 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec128 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.sizeTys128 PRE_first_tail_x15_r0_body.sizeArgs128).run PRE_first_tail_x15_r0_body.S431
noncomputable def PRE_first_tail_x15_r0_body.sizeAs128 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec128 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0128 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec128 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S431
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA128 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.sizeTys128 PRE_first_tail_x15_r0_body.sizeArgs128).run PRE_first_tail_x15_r0_body.S431 =
  some (some PRE_first_tail_x15_r0_body.sizeAs128, PRE_first_tail_x15_r0_body.sizeS0128)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA128 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0128 PRE_first_tail_x15_r0_body.s431.ffi PRE_first_tail_x15_r0_body.sizeAs128 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA129 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s434 "recurWindow" none = true
/-- Bridge 130's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys130 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s438 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs130 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s438 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA130 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s438 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys130, PRE_first_tail_x15_r0_body.sizeArgs130)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA130 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s438 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA130 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA130 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA130 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA130 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec130 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s438 PRE_first_tail_x15_r0_body.sizeTys130 PRE_first_tail_x15_r0_body.sizeArgs130).run PRE_first_tail_x15_r0_body.S438
noncomputable def PRE_first_tail_x15_r0_body.sizeAs130 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec130 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0130 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec130 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S438
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA130 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s438 PRE_first_tail_x15_r0_body.sizeTys130 PRE_first_tail_x15_r0_body.sizeArgs130).run PRE_first_tail_x15_r0_body.S438 =
  some (some PRE_first_tail_x15_r0_body.sizeAs130, PRE_first_tail_x15_r0_body.sizeS0130)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA130 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0130 PRE_first_tail_x15_r0_body.s438.ffi PRE_first_tail_x15_r0_body.sizeAs130 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA131 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s441 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA132 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s445 "plan" none = true
/-- Bridge 133's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys133 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s449 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs133 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s449 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA133 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s449 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys133, PRE_first_tail_x15_r0_body.sizeArgs133)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA133 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s449 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA133 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA133 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA133 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA133 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec133 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.sizeTys133 PRE_first_tail_x15_r0_body.sizeArgs133).run PRE_first_tail_x15_r0_body.S449
noncomputable def PRE_first_tail_x15_r0_body.sizeAs133 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec133 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0133 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec133 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S449
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA133 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.sizeTys133 PRE_first_tail_x15_r0_body.sizeArgs133).run PRE_first_tail_x15_r0_body.S449 =
  some (some PRE_first_tail_x15_r0_body.sizeAs133, PRE_first_tail_x15_r0_body.sizeS0133)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA133 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0133 PRE_first_tail_x15_r0_body.s449.ffi PRE_first_tail_x15_r0_body.sizeAs133 = true
/-- Bridge 134's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys134 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s452 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs134 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s452 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA134 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s452 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys134, PRE_first_tail_x15_r0_body.sizeArgs134)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA134 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s452 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA134 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA134 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA134 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA134 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec134 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s452 PRE_first_tail_x15_r0_body.sizeTys134 PRE_first_tail_x15_r0_body.sizeArgs134).run PRE_first_tail_x15_r0_body.S452
noncomputable def PRE_first_tail_x15_r0_body.sizeAs134 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec134 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0134 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec134 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S452
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA134 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s452 PRE_first_tail_x15_r0_body.sizeTys134 PRE_first_tail_x15_r0_body.sizeArgs134).run PRE_first_tail_x15_r0_body.S452 =
  some (some PRE_first_tail_x15_r0_body.sizeAs134, PRE_first_tail_x15_r0_body.sizeS0134)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA134 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0134 PRE_first_tail_x15_r0_body.s452.ffi PRE_first_tail_x15_r0_body.sizeAs134 = true
/-- Bridge 135's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys135 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s455 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs135 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s455 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA135 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s455 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys135, PRE_first_tail_x15_r0_body.sizeArgs135)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA135 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s455 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA135 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA135 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA135 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA135 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec135 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.sizeTys135 PRE_first_tail_x15_r0_body.sizeArgs135).run PRE_first_tail_x15_r0_body.S455
noncomputable def PRE_first_tail_x15_r0_body.sizeAs135 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec135 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0135 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec135 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S455
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA135 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.sizeTys135 PRE_first_tail_x15_r0_body.sizeArgs135).run PRE_first_tail_x15_r0_body.S455 =
  some (some PRE_first_tail_x15_r0_body.sizeAs135, PRE_first_tail_x15_r0_body.sizeS0135)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA135 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0135 PRE_first_tail_x15_r0_body.s455.ffi PRE_first_tail_x15_r0_body.sizeAs135 = true
/-- Bridge 136's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys136 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s458 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs136 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s458 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA136 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s458 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys136, PRE_first_tail_x15_r0_body.sizeArgs136)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA136 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s458 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA136 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA136 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA136 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA136 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec136 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s458 PRE_first_tail_x15_r0_body.sizeTys136 PRE_first_tail_x15_r0_body.sizeArgs136).run PRE_first_tail_x15_r0_body.S458
noncomputable def PRE_first_tail_x15_r0_body.sizeAs136 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec136 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0136 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec136 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S458
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA136 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s458 PRE_first_tail_x15_r0_body.sizeTys136 PRE_first_tail_x15_r0_body.sizeArgs136).run PRE_first_tail_x15_r0_body.S458 =
  some (some PRE_first_tail_x15_r0_body.sizeAs136, PRE_first_tail_x15_r0_body.sizeS0136)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA136 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0136 PRE_first_tail_x15_r0_body.s458.ffi PRE_first_tail_x15_r0_body.sizeAs136 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA137 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s461 "recurWindow" none = true
/-- Bridge 138's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys138 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s465 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs138 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s465 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA138 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s465 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys138, PRE_first_tail_x15_r0_body.sizeArgs138)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA138 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s465 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA138 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA138 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA138 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA138 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec138 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s465 PRE_first_tail_x15_r0_body.sizeTys138 PRE_first_tail_x15_r0_body.sizeArgs138).run PRE_first_tail_x15_r0_body.S465
noncomputable def PRE_first_tail_x15_r0_body.sizeAs138 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec138 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0138 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec138 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S465
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA138 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s465 PRE_first_tail_x15_r0_body.sizeTys138 PRE_first_tail_x15_r0_body.sizeArgs138).run PRE_first_tail_x15_r0_body.S465 =
  some (some PRE_first_tail_x15_r0_body.sizeAs138, PRE_first_tail_x15_r0_body.sizeS0138)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA138 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0138 PRE_first_tail_x15_r0_body.s465.ffi PRE_first_tail_x15_r0_body.sizeAs138 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA139 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s468 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA140 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s472 "plan" none = true
/-- Bridge 141's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys141 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s476 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs141 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s476 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA141 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s476 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys141, PRE_first_tail_x15_r0_body.sizeArgs141)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA141 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s476 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA141 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA141 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA141 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA141 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec141 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.sizeTys141 PRE_first_tail_x15_r0_body.sizeArgs141).run PRE_first_tail_x15_r0_body.S476
noncomputable def PRE_first_tail_x15_r0_body.sizeAs141 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec141 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0141 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec141 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S476
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA141 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.sizeTys141 PRE_first_tail_x15_r0_body.sizeArgs141).run PRE_first_tail_x15_r0_body.S476 =
  some (some PRE_first_tail_x15_r0_body.sizeAs141, PRE_first_tail_x15_r0_body.sizeS0141)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA141 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0141 PRE_first_tail_x15_r0_body.s476.ffi PRE_first_tail_x15_r0_body.sizeAs141 = true
/-- Bridge 142's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys142 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s479 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs142 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s479 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA142 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s479 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys142, PRE_first_tail_x15_r0_body.sizeArgs142)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA142 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s479 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA142 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA142 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA142 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA142 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec142 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s479 PRE_first_tail_x15_r0_body.sizeTys142 PRE_first_tail_x15_r0_body.sizeArgs142).run PRE_first_tail_x15_r0_body.S479
noncomputable def PRE_first_tail_x15_r0_body.sizeAs142 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec142 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0142 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec142 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S479
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA142 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s479 PRE_first_tail_x15_r0_body.sizeTys142 PRE_first_tail_x15_r0_body.sizeArgs142).run PRE_first_tail_x15_r0_body.S479 =
  some (some PRE_first_tail_x15_r0_body.sizeAs142, PRE_first_tail_x15_r0_body.sizeS0142)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA142 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0142 PRE_first_tail_x15_r0_body.s479.ffi PRE_first_tail_x15_r0_body.sizeAs142 = true
/-- Bridge 143's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys143 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s482 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs143 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s482 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA143 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s482 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys143, PRE_first_tail_x15_r0_body.sizeArgs143)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA143 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s482 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA143 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA143 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA143 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA143 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec143 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s482 PRE_first_tail_x15_r0_body.sizeTys143 PRE_first_tail_x15_r0_body.sizeArgs143).run PRE_first_tail_x15_r0_body.S482
noncomputable def PRE_first_tail_x15_r0_body.sizeAs143 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec143 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0143 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec143 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S482
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA143 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s482 PRE_first_tail_x15_r0_body.sizeTys143 PRE_first_tail_x15_r0_body.sizeArgs143).run PRE_first_tail_x15_r0_body.S482 =
  some (some PRE_first_tail_x15_r0_body.sizeAs143, PRE_first_tail_x15_r0_body.sizeS0143)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA143 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0143 PRE_first_tail_x15_r0_body.s482.ffi PRE_first_tail_x15_r0_body.sizeAs143 = true
/-- Bridge 144's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys144 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s485 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs144 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s485 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA144 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s485 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys144, PRE_first_tail_x15_r0_body.sizeArgs144)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA144 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s485 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA144 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA144 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA144 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA144 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec144 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s485 PRE_first_tail_x15_r0_body.sizeTys144 PRE_first_tail_x15_r0_body.sizeArgs144).run PRE_first_tail_x15_r0_body.S485
noncomputable def PRE_first_tail_x15_r0_body.sizeAs144 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec144 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0144 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec144 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S485
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA144 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s485 PRE_first_tail_x15_r0_body.sizeTys144 PRE_first_tail_x15_r0_body.sizeArgs144).run PRE_first_tail_x15_r0_body.S485 =
  some (some PRE_first_tail_x15_r0_body.sizeAs144, PRE_first_tail_x15_r0_body.sizeS0144)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA144 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0144 PRE_first_tail_x15_r0_body.s485.ffi PRE_first_tail_x15_r0_body.sizeAs144 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA145 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s488 "recurWindow" none = true
/-- Bridge 146's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys146 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s492 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs146 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s492 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA146 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s492 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys146, PRE_first_tail_x15_r0_body.sizeArgs146)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA146 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s492 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA146 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA146 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA146 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA146 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec146 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s492 PRE_first_tail_x15_r0_body.sizeTys146 PRE_first_tail_x15_r0_body.sizeArgs146).run PRE_first_tail_x15_r0_body.S492
noncomputable def PRE_first_tail_x15_r0_body.sizeAs146 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec146 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0146 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec146 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S492
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA146 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s492 PRE_first_tail_x15_r0_body.sizeTys146 PRE_first_tail_x15_r0_body.sizeArgs146).run PRE_first_tail_x15_r0_body.S492 =
  some (some PRE_first_tail_x15_r0_body.sizeAs146, PRE_first_tail_x15_r0_body.sizeS0146)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA146 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0146 PRE_first_tail_x15_r0_body.s492.ffi PRE_first_tail_x15_r0_body.sizeAs146 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA147 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s495 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA148 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s499 "plan" none = true
/-- Bridge 149's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys149 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s503 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs149 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s503 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA149 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s503 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys149, PRE_first_tail_x15_r0_body.sizeArgs149)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA149 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s503 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA149 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA149 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA149 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA149 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec149 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s503 PRE_first_tail_x15_r0_body.sizeTys149 PRE_first_tail_x15_r0_body.sizeArgs149).run PRE_first_tail_x15_r0_body.S503
noncomputable def PRE_first_tail_x15_r0_body.sizeAs149 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec149 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0149 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec149 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S503
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA149 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s503 PRE_first_tail_x15_r0_body.sizeTys149 PRE_first_tail_x15_r0_body.sizeArgs149).run PRE_first_tail_x15_r0_body.S503 =
  some (some PRE_first_tail_x15_r0_body.sizeAs149, PRE_first_tail_x15_r0_body.sizeS0149)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA149 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0149 PRE_first_tail_x15_r0_body.s503.ffi PRE_first_tail_x15_r0_body.sizeAs149 = true
/-- Bridge 150's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys150 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s506 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs150 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s506 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA150 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s506 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys150, PRE_first_tail_x15_r0_body.sizeArgs150)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA150 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s506 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA150 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA150 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA150 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA150 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec150 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s506 PRE_first_tail_x15_r0_body.sizeTys150 PRE_first_tail_x15_r0_body.sizeArgs150).run PRE_first_tail_x15_r0_body.S506
noncomputable def PRE_first_tail_x15_r0_body.sizeAs150 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec150 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0150 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec150 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S506
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA150 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s506 PRE_first_tail_x15_r0_body.sizeTys150 PRE_first_tail_x15_r0_body.sizeArgs150).run PRE_first_tail_x15_r0_body.S506 =
  some (some PRE_first_tail_x15_r0_body.sizeAs150, PRE_first_tail_x15_r0_body.sizeS0150)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA150 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0150 PRE_first_tail_x15_r0_body.s506.ffi PRE_first_tail_x15_r0_body.sizeAs150 = true
/-- Bridge 151's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys151 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s509 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs151 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s509 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA151 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s509 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys151, PRE_first_tail_x15_r0_body.sizeArgs151)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA151 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s509 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA151 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA151 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA151 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA151 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec151 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s509 PRE_first_tail_x15_r0_body.sizeTys151 PRE_first_tail_x15_r0_body.sizeArgs151).run PRE_first_tail_x15_r0_body.S509
noncomputable def PRE_first_tail_x15_r0_body.sizeAs151 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec151 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0151 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec151 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S509
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA151 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s509 PRE_first_tail_x15_r0_body.sizeTys151 PRE_first_tail_x15_r0_body.sizeArgs151).run PRE_first_tail_x15_r0_body.S509 =
  some (some PRE_first_tail_x15_r0_body.sizeAs151, PRE_first_tail_x15_r0_body.sizeS0151)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA151 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0151 PRE_first_tail_x15_r0_body.s509.ffi PRE_first_tail_x15_r0_body.sizeAs151 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA152 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s512 "appendWindow" none = true
/-- Bridge 153's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys153 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s516 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs153 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s516 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA153 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s516 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys153, PRE_first_tail_x15_r0_body.sizeArgs153)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA153 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s516 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA153 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA153 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA153 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA153 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec153 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s516 PRE_first_tail_x15_r0_body.sizeTys153 PRE_first_tail_x15_r0_body.sizeArgs153).run PRE_first_tail_x15_r0_body.S516
noncomputable def PRE_first_tail_x15_r0_body.sizeAs153 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec153 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0153 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec153 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S516
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA153 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s516 PRE_first_tail_x15_r0_body.sizeTys153 PRE_first_tail_x15_r0_body.sizeArgs153).run PRE_first_tail_x15_r0_body.S516 =
  some (some PRE_first_tail_x15_r0_body.sizeAs153, PRE_first_tail_x15_r0_body.sizeS0153)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA153 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0153 PRE_first_tail_x15_r0_body.s516.ffi PRE_first_tail_x15_r0_body.sizeAs153 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA154 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s519 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA155 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s523 "plan" none = true
/-- Bridge 156's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys156 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s527 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs156 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s527 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA156 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s527 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys156, PRE_first_tail_x15_r0_body.sizeArgs156)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA156 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s527 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA156 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA156 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA156 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA156 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec156 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s527 PRE_first_tail_x15_r0_body.sizeTys156 PRE_first_tail_x15_r0_body.sizeArgs156).run PRE_first_tail_x15_r0_body.S527
noncomputable def PRE_first_tail_x15_r0_body.sizeAs156 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec156 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0156 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec156 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S527
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA156 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s527 PRE_first_tail_x15_r0_body.sizeTys156 PRE_first_tail_x15_r0_body.sizeArgs156).run PRE_first_tail_x15_r0_body.S527 =
  some (some PRE_first_tail_x15_r0_body.sizeAs156, PRE_first_tail_x15_r0_body.sizeS0156)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA156 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0156 PRE_first_tail_x15_r0_body.s527.ffi PRE_first_tail_x15_r0_body.sizeAs156 = true
/-- Bridge 157's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys157 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s530 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs157 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s530 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA157 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s530 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys157, PRE_first_tail_x15_r0_body.sizeArgs157)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA157 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s530 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA157 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA157 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA157 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA157 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec157 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s530 PRE_first_tail_x15_r0_body.sizeTys157 PRE_first_tail_x15_r0_body.sizeArgs157).run PRE_first_tail_x15_r0_body.S530
noncomputable def PRE_first_tail_x15_r0_body.sizeAs157 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec157 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0157 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec157 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S530
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA157 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s530 PRE_first_tail_x15_r0_body.sizeTys157 PRE_first_tail_x15_r0_body.sizeArgs157).run PRE_first_tail_x15_r0_body.S530 =
  some (some PRE_first_tail_x15_r0_body.sizeAs157, PRE_first_tail_x15_r0_body.sizeS0157)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA157 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0157 PRE_first_tail_x15_r0_body.s530.ffi PRE_first_tail_x15_r0_body.sizeAs157 = true
/-- Bridge 158's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys158 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s533 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs158 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s533 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA158 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s533 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys158, PRE_first_tail_x15_r0_body.sizeArgs158)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA158 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s533 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA158 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA158 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA158 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA158 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec158 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s533 PRE_first_tail_x15_r0_body.sizeTys158 PRE_first_tail_x15_r0_body.sizeArgs158).run PRE_first_tail_x15_r0_body.S533
noncomputable def PRE_first_tail_x15_r0_body.sizeAs158 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec158 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0158 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec158 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S533
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA158 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s533 PRE_first_tail_x15_r0_body.sizeTys158 PRE_first_tail_x15_r0_body.sizeArgs158).run PRE_first_tail_x15_r0_body.S533 =
  some (some PRE_first_tail_x15_r0_body.sizeAs158, PRE_first_tail_x15_r0_body.sizeS0158)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA158 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0158 PRE_first_tail_x15_r0_body.s533.ffi PRE_first_tail_x15_r0_body.sizeAs158 = true
/-- Bridge 159's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys159 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s536 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs159 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s536 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA159 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s536 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys159, PRE_first_tail_x15_r0_body.sizeArgs159)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA159 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s536 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA159 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA159 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA159 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA159 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec159 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.sizeTys159 PRE_first_tail_x15_r0_body.sizeArgs159).run PRE_first_tail_x15_r0_body.S536
noncomputable def PRE_first_tail_x15_r0_body.sizeAs159 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec159 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0159 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec159 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S536
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA159 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.sizeTys159 PRE_first_tail_x15_r0_body.sizeArgs159).run PRE_first_tail_x15_r0_body.S536 =
  some (some PRE_first_tail_x15_r0_body.sizeAs159, PRE_first_tail_x15_r0_body.sizeS0159)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA159 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0159 PRE_first_tail_x15_r0_body.s536.ffi PRE_first_tail_x15_r0_body.sizeAs159 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA160 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s539 "recurWindow" none = true
/-- Bridge 161's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys161 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s543 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs161 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s543 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA161 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s543 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys161, PRE_first_tail_x15_r0_body.sizeArgs161)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA161 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s543 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA161 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA161 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA161 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA161 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec161 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s543 PRE_first_tail_x15_r0_body.sizeTys161 PRE_first_tail_x15_r0_body.sizeArgs161).run PRE_first_tail_x15_r0_body.S543
noncomputable def PRE_first_tail_x15_r0_body.sizeAs161 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec161 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0161 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec161 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S543
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA161 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s543 PRE_first_tail_x15_r0_body.sizeTys161 PRE_first_tail_x15_r0_body.sizeArgs161).run PRE_first_tail_x15_r0_body.S543 =
  some (some PRE_first_tail_x15_r0_body.sizeAs161, PRE_first_tail_x15_r0_body.sizeS0161)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA161 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0161 PRE_first_tail_x15_r0_body.s543.ffi PRE_first_tail_x15_r0_body.sizeAs161 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA162 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s546 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA163 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s550 "plan" none = true
/-- Bridge 164's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys164 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s554 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs164 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s554 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA164 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s554 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys164, PRE_first_tail_x15_r0_body.sizeArgs164)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA164 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s554 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA164 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA164 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA164 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA164 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec164 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s554 PRE_first_tail_x15_r0_body.sizeTys164 PRE_first_tail_x15_r0_body.sizeArgs164).run PRE_first_tail_x15_r0_body.S554
noncomputable def PRE_first_tail_x15_r0_body.sizeAs164 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec164 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0164 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec164 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S554
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA164 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s554 PRE_first_tail_x15_r0_body.sizeTys164 PRE_first_tail_x15_r0_body.sizeArgs164).run PRE_first_tail_x15_r0_body.S554 =
  some (some PRE_first_tail_x15_r0_body.sizeAs164, PRE_first_tail_x15_r0_body.sizeS0164)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA164 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0164 PRE_first_tail_x15_r0_body.s554.ffi PRE_first_tail_x15_r0_body.sizeAs164 = true
/-- Bridge 165's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys165 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s557 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs165 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s557 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA165 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s557 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys165, PRE_first_tail_x15_r0_body.sizeArgs165)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA165 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s557 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA165 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA165 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA165 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA165 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec165 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s557 PRE_first_tail_x15_r0_body.sizeTys165 PRE_first_tail_x15_r0_body.sizeArgs165).run PRE_first_tail_x15_r0_body.S557
noncomputable def PRE_first_tail_x15_r0_body.sizeAs165 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec165 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0165 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec165 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S557
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA165 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s557 PRE_first_tail_x15_r0_body.sizeTys165 PRE_first_tail_x15_r0_body.sizeArgs165).run PRE_first_tail_x15_r0_body.S557 =
  some (some PRE_first_tail_x15_r0_body.sizeAs165, PRE_first_tail_x15_r0_body.sizeS0165)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA165 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0165 PRE_first_tail_x15_r0_body.s557.ffi PRE_first_tail_x15_r0_body.sizeAs165 = true
/-- Bridge 166's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys166 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s560 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs166 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s560 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA166 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s560 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys166, PRE_first_tail_x15_r0_body.sizeArgs166)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA166 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s560 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA166 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA166 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA166 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA166 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec166 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s560 PRE_first_tail_x15_r0_body.sizeTys166 PRE_first_tail_x15_r0_body.sizeArgs166).run PRE_first_tail_x15_r0_body.S560
noncomputable def PRE_first_tail_x15_r0_body.sizeAs166 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec166 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0166 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec166 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S560
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA166 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s560 PRE_first_tail_x15_r0_body.sizeTys166 PRE_first_tail_x15_r0_body.sizeArgs166).run PRE_first_tail_x15_r0_body.S560 =
  some (some PRE_first_tail_x15_r0_body.sizeAs166, PRE_first_tail_x15_r0_body.sizeS0166)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA166 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0166 PRE_first_tail_x15_r0_body.s560.ffi PRE_first_tail_x15_r0_body.sizeAs166 = true
/-- Bridge 167's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys167 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s563 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs167 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s563 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA167 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s563 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys167, PRE_first_tail_x15_r0_body.sizeArgs167)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA167 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s563 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA167 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA167 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA167 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA167 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec167 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s563 PRE_first_tail_x15_r0_body.sizeTys167 PRE_first_tail_x15_r0_body.sizeArgs167).run PRE_first_tail_x15_r0_body.S563
noncomputable def PRE_first_tail_x15_r0_body.sizeAs167 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec167 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0167 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec167 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S563
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA167 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s563 PRE_first_tail_x15_r0_body.sizeTys167 PRE_first_tail_x15_r0_body.sizeArgs167).run PRE_first_tail_x15_r0_body.S563 =
  some (some PRE_first_tail_x15_r0_body.sizeAs167, PRE_first_tail_x15_r0_body.sizeS0167)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA167 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0167 PRE_first_tail_x15_r0_body.s563.ffi PRE_first_tail_x15_r0_body.sizeAs167 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA168 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s566 "recurWindow" none = true
/-- Bridge 169's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys169 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s570 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs169 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s570 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA169 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s570 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys169, PRE_first_tail_x15_r0_body.sizeArgs169)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA169 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s570 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA169 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA169 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA169 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA169 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec169 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s570 PRE_first_tail_x15_r0_body.sizeTys169 PRE_first_tail_x15_r0_body.sizeArgs169).run PRE_first_tail_x15_r0_body.S570
noncomputable def PRE_first_tail_x15_r0_body.sizeAs169 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec169 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0169 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec169 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S570
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA169 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s570 PRE_first_tail_x15_r0_body.sizeTys169 PRE_first_tail_x15_r0_body.sizeArgs169).run PRE_first_tail_x15_r0_body.S570 =
  some (some PRE_first_tail_x15_r0_body.sizeAs169, PRE_first_tail_x15_r0_body.sizeS0169)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA169 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0169 PRE_first_tail_x15_r0_body.s570.ffi PRE_first_tail_x15_r0_body.sizeAs169 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA170 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s573 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA171 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s577 "plan" none = true
/-- Bridge 172's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys172 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s581 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs172 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s581 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA172 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s581 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys172, PRE_first_tail_x15_r0_body.sizeArgs172)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA172 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s581 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA172 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA172 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA172 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA172 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec172 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s581 PRE_first_tail_x15_r0_body.sizeTys172 PRE_first_tail_x15_r0_body.sizeArgs172).run PRE_first_tail_x15_r0_body.S581
noncomputable def PRE_first_tail_x15_r0_body.sizeAs172 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec172 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0172 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec172 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S581
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA172 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s581 PRE_first_tail_x15_r0_body.sizeTys172 PRE_first_tail_x15_r0_body.sizeArgs172).run PRE_first_tail_x15_r0_body.S581 =
  some (some PRE_first_tail_x15_r0_body.sizeAs172, PRE_first_tail_x15_r0_body.sizeS0172)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA172 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0172 PRE_first_tail_x15_r0_body.s581.ffi PRE_first_tail_x15_r0_body.sizeAs172 = true
/-- Bridge 173's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys173 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s584 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs173 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s584 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA173 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s584 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys173, PRE_first_tail_x15_r0_body.sizeArgs173)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA173 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s584 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA173 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA173 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA173 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA173 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec173 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s584 PRE_first_tail_x15_r0_body.sizeTys173 PRE_first_tail_x15_r0_body.sizeArgs173).run PRE_first_tail_x15_r0_body.S584
noncomputable def PRE_first_tail_x15_r0_body.sizeAs173 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec173 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0173 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec173 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S584
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA173 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s584 PRE_first_tail_x15_r0_body.sizeTys173 PRE_first_tail_x15_r0_body.sizeArgs173).run PRE_first_tail_x15_r0_body.S584 =
  some (some PRE_first_tail_x15_r0_body.sizeAs173, PRE_first_tail_x15_r0_body.sizeS0173)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA173 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0173 PRE_first_tail_x15_r0_body.s584.ffi PRE_first_tail_x15_r0_body.sizeAs173 = true
/-- Bridge 174's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys174 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s587 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs174 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s587 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA174 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s587 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys174, PRE_first_tail_x15_r0_body.sizeArgs174)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA174 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s587 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA174 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA174 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA174 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA174 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec174 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s587 PRE_first_tail_x15_r0_body.sizeTys174 PRE_first_tail_x15_r0_body.sizeArgs174).run PRE_first_tail_x15_r0_body.S587
noncomputable def PRE_first_tail_x15_r0_body.sizeAs174 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec174 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0174 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec174 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S587
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA174 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s587 PRE_first_tail_x15_r0_body.sizeTys174 PRE_first_tail_x15_r0_body.sizeArgs174).run PRE_first_tail_x15_r0_body.S587 =
  some (some PRE_first_tail_x15_r0_body.sizeAs174, PRE_first_tail_x15_r0_body.sizeS0174)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA174 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0174 PRE_first_tail_x15_r0_body.s587.ffi PRE_first_tail_x15_r0_body.sizeAs174 = true
/-- Bridge 175's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys175 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s590 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs175 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s590 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA175 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s590 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys175, PRE_first_tail_x15_r0_body.sizeArgs175)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA175 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s590 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA175 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA175 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA175 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA175 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec175 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s590 PRE_first_tail_x15_r0_body.sizeTys175 PRE_first_tail_x15_r0_body.sizeArgs175).run PRE_first_tail_x15_r0_body.S590
noncomputable def PRE_first_tail_x15_r0_body.sizeAs175 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec175 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0175 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec175 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S590
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA175 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s590 PRE_first_tail_x15_r0_body.sizeTys175 PRE_first_tail_x15_r0_body.sizeArgs175).run PRE_first_tail_x15_r0_body.S590 =
  some (some PRE_first_tail_x15_r0_body.sizeAs175, PRE_first_tail_x15_r0_body.sizeS0175)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA175 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0175 PRE_first_tail_x15_r0_body.s590.ffi PRE_first_tail_x15_r0_body.sizeAs175 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA176 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s593 "recurWindow" none = true
/-- Bridge 177's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys177 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s597 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs177 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s597 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA177 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s597 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys177, PRE_first_tail_x15_r0_body.sizeArgs177)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA177 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s597 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA177 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA177 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA177 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA177 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec177 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s597 PRE_first_tail_x15_r0_body.sizeTys177 PRE_first_tail_x15_r0_body.sizeArgs177).run PRE_first_tail_x15_r0_body.S597
noncomputable def PRE_first_tail_x15_r0_body.sizeAs177 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec177 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0177 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec177 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S597
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA177 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s597 PRE_first_tail_x15_r0_body.sizeTys177 PRE_first_tail_x15_r0_body.sizeArgs177).run PRE_first_tail_x15_r0_body.S597 =
  some (some PRE_first_tail_x15_r0_body.sizeAs177, PRE_first_tail_x15_r0_body.sizeS0177)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA177 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0177 PRE_first_tail_x15_r0_body.s597.ffi PRE_first_tail_x15_r0_body.sizeAs177 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA178 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s600 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA179 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s604 "plan" none = true
/-- Bridge 180's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys180 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s608 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs180 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s608 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA180 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s608 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys180, PRE_first_tail_x15_r0_body.sizeArgs180)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA180 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s608 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA180 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA180 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA180 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA180 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec180 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s608 PRE_first_tail_x15_r0_body.sizeTys180 PRE_first_tail_x15_r0_body.sizeArgs180).run PRE_first_tail_x15_r0_body.S608
noncomputable def PRE_first_tail_x15_r0_body.sizeAs180 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec180 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0180 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec180 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S608
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA180 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s608 PRE_first_tail_x15_r0_body.sizeTys180 PRE_first_tail_x15_r0_body.sizeArgs180).run PRE_first_tail_x15_r0_body.S608 =
  some (some PRE_first_tail_x15_r0_body.sizeAs180, PRE_first_tail_x15_r0_body.sizeS0180)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA180 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0180 PRE_first_tail_x15_r0_body.s608.ffi PRE_first_tail_x15_r0_body.sizeAs180 = true
/-- Bridge 181's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys181 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s611 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs181 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s611 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA181 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s611 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys181, PRE_first_tail_x15_r0_body.sizeArgs181)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA181 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s611 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA181 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA181 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA181 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA181 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec181 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s611 PRE_first_tail_x15_r0_body.sizeTys181 PRE_first_tail_x15_r0_body.sizeArgs181).run PRE_first_tail_x15_r0_body.S611
noncomputable def PRE_first_tail_x15_r0_body.sizeAs181 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec181 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0181 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec181 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S611
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA181 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s611 PRE_first_tail_x15_r0_body.sizeTys181 PRE_first_tail_x15_r0_body.sizeArgs181).run PRE_first_tail_x15_r0_body.S611 =
  some (some PRE_first_tail_x15_r0_body.sizeAs181, PRE_first_tail_x15_r0_body.sizeS0181)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA181 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0181 PRE_first_tail_x15_r0_body.s611.ffi PRE_first_tail_x15_r0_body.sizeAs181 = true
/-- Bridge 182's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys182 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s614 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs182 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s614 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA182 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s614 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys182, PRE_first_tail_x15_r0_body.sizeArgs182)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA182 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s614 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA182 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA182 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA182 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA182 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec182 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s614 PRE_first_tail_x15_r0_body.sizeTys182 PRE_first_tail_x15_r0_body.sizeArgs182).run PRE_first_tail_x15_r0_body.S614
noncomputable def PRE_first_tail_x15_r0_body.sizeAs182 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec182 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0182 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec182 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S614
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA182 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s614 PRE_first_tail_x15_r0_body.sizeTys182 PRE_first_tail_x15_r0_body.sizeArgs182).run PRE_first_tail_x15_r0_body.S614 =
  some (some PRE_first_tail_x15_r0_body.sizeAs182, PRE_first_tail_x15_r0_body.sizeS0182)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA182 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0182 PRE_first_tail_x15_r0_body.s614.ffi PRE_first_tail_x15_r0_body.sizeAs182 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA183 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s617 "appendWindow" none = true
/-- Bridge 184's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys184 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s621 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs184 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s621 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA184 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s621 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys184, PRE_first_tail_x15_r0_body.sizeArgs184)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA184 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s621 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA184 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA184 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA184 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA184 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec184 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s621 PRE_first_tail_x15_r0_body.sizeTys184 PRE_first_tail_x15_r0_body.sizeArgs184).run PRE_first_tail_x15_r0_body.S621
noncomputable def PRE_first_tail_x15_r0_body.sizeAs184 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec184 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0184 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec184 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S621
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA184 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s621 PRE_first_tail_x15_r0_body.sizeTys184 PRE_first_tail_x15_r0_body.sizeArgs184).run PRE_first_tail_x15_r0_body.S621 =
  some (some PRE_first_tail_x15_r0_body.sizeAs184, PRE_first_tail_x15_r0_body.sizeS0184)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA184 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0184 PRE_first_tail_x15_r0_body.s621.ffi PRE_first_tail_x15_r0_body.sizeAs184 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA185 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s624 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA186 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s628 "plan" none = true
/-- Bridge 187's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys187 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s632 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs187 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s632 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA187 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s632 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys187, PRE_first_tail_x15_r0_body.sizeArgs187)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA187 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s632 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA187 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA187 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA187 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA187 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec187 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s632 PRE_first_tail_x15_r0_body.sizeTys187 PRE_first_tail_x15_r0_body.sizeArgs187).run PRE_first_tail_x15_r0_body.S632
noncomputable def PRE_first_tail_x15_r0_body.sizeAs187 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec187 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0187 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec187 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S632
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA187 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s632 PRE_first_tail_x15_r0_body.sizeTys187 PRE_first_tail_x15_r0_body.sizeArgs187).run PRE_first_tail_x15_r0_body.S632 =
  some (some PRE_first_tail_x15_r0_body.sizeAs187, PRE_first_tail_x15_r0_body.sizeS0187)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA187 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0187 PRE_first_tail_x15_r0_body.s632.ffi PRE_first_tail_x15_r0_body.sizeAs187 = true
/-- Bridge 188's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys188 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s635 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs188 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s635 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA188 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s635 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys188, PRE_first_tail_x15_r0_body.sizeArgs188)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA188 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s635 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA188 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA188 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA188 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA188 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec188 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s635 PRE_first_tail_x15_r0_body.sizeTys188 PRE_first_tail_x15_r0_body.sizeArgs188).run PRE_first_tail_x15_r0_body.S635
noncomputable def PRE_first_tail_x15_r0_body.sizeAs188 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec188 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0188 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec188 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S635
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA188 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s635 PRE_first_tail_x15_r0_body.sizeTys188 PRE_first_tail_x15_r0_body.sizeArgs188).run PRE_first_tail_x15_r0_body.S635 =
  some (some PRE_first_tail_x15_r0_body.sizeAs188, PRE_first_tail_x15_r0_body.sizeS0188)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA188 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0188 PRE_first_tail_x15_r0_body.s635.ffi PRE_first_tail_x15_r0_body.sizeAs188 = true
/-- Bridge 189's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys189 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s638 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs189 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s638 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA189 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s638 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys189, PRE_first_tail_x15_r0_body.sizeArgs189)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA189 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s638 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA189 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA189 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA189 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA189 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec189 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s638 PRE_first_tail_x15_r0_body.sizeTys189 PRE_first_tail_x15_r0_body.sizeArgs189).run PRE_first_tail_x15_r0_body.S638
noncomputable def PRE_first_tail_x15_r0_body.sizeAs189 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec189 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0189 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec189 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S638
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA189 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s638 PRE_first_tail_x15_r0_body.sizeTys189 PRE_first_tail_x15_r0_body.sizeArgs189).run PRE_first_tail_x15_r0_body.S638 =
  some (some PRE_first_tail_x15_r0_body.sizeAs189, PRE_first_tail_x15_r0_body.sizeS0189)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA189 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0189 PRE_first_tail_x15_r0_body.s638.ffi PRE_first_tail_x15_r0_body.sizeAs189 = true
/-- Bridge 190's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys190 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s641 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs190 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s641 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA190 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s641 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys190, PRE_first_tail_x15_r0_body.sizeArgs190)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA190 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s641 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA190 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA190 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA190 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA190 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec190 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s641 PRE_first_tail_x15_r0_body.sizeTys190 PRE_first_tail_x15_r0_body.sizeArgs190).run PRE_first_tail_x15_r0_body.S641
noncomputable def PRE_first_tail_x15_r0_body.sizeAs190 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec190 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0190 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec190 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S641
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA190 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s641 PRE_first_tail_x15_r0_body.sizeTys190 PRE_first_tail_x15_r0_body.sizeArgs190).run PRE_first_tail_x15_r0_body.S641 =
  some (some PRE_first_tail_x15_r0_body.sizeAs190, PRE_first_tail_x15_r0_body.sizeS0190)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA190 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0190 PRE_first_tail_x15_r0_body.s641.ffi PRE_first_tail_x15_r0_body.sizeAs190 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA191 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s644 "recurWindow" none = true
/-- Bridge 192's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys192 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s648 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs192 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s648 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA192 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s648 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys192, PRE_first_tail_x15_r0_body.sizeArgs192)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA192 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s648 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA192 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA192 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA192 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA192 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec192 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s648 PRE_first_tail_x15_r0_body.sizeTys192 PRE_first_tail_x15_r0_body.sizeArgs192).run PRE_first_tail_x15_r0_body.S648
noncomputable def PRE_first_tail_x15_r0_body.sizeAs192 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec192 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0192 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec192 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S648
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA192 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s648 PRE_first_tail_x15_r0_body.sizeTys192 PRE_first_tail_x15_r0_body.sizeArgs192).run PRE_first_tail_x15_r0_body.S648 =
  some (some PRE_first_tail_x15_r0_body.sizeAs192, PRE_first_tail_x15_r0_body.sizeS0192)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA192 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0192 PRE_first_tail_x15_r0_body.s648.ffi PRE_first_tail_x15_r0_body.sizeAs192 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA193 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s651 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA194 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s655 "plan" none = true
/-- Bridge 195's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys195 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s659 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs195 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s659 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA195 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s659 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys195, PRE_first_tail_x15_r0_body.sizeArgs195)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA195 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s659 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA195 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA195 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA195 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA195 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec195 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.sizeTys195 PRE_first_tail_x15_r0_body.sizeArgs195).run PRE_first_tail_x15_r0_body.S659
noncomputable def PRE_first_tail_x15_r0_body.sizeAs195 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec195 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0195 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec195 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S659
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA195 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.sizeTys195 PRE_first_tail_x15_r0_body.sizeArgs195).run PRE_first_tail_x15_r0_body.S659 =
  some (some PRE_first_tail_x15_r0_body.sizeAs195, PRE_first_tail_x15_r0_body.sizeS0195)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA195 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0195 PRE_first_tail_x15_r0_body.s659.ffi PRE_first_tail_x15_r0_body.sizeAs195 = true
/-- Bridge 196's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys196 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s662 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs196 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s662 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA196 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s662 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys196, PRE_first_tail_x15_r0_body.sizeArgs196)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA196 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s662 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA196 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA196 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA196 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA196 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec196 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s662 PRE_first_tail_x15_r0_body.sizeTys196 PRE_first_tail_x15_r0_body.sizeArgs196).run PRE_first_tail_x15_r0_body.S662
noncomputable def PRE_first_tail_x15_r0_body.sizeAs196 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec196 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0196 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec196 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S662
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA196 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s662 PRE_first_tail_x15_r0_body.sizeTys196 PRE_first_tail_x15_r0_body.sizeArgs196).run PRE_first_tail_x15_r0_body.S662 =
  some (some PRE_first_tail_x15_r0_body.sizeAs196, PRE_first_tail_x15_r0_body.sizeS0196)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA196 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0196 PRE_first_tail_x15_r0_body.s662.ffi PRE_first_tail_x15_r0_body.sizeAs196 = true
/-- Bridge 197's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys197 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s665 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs197 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s665 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA197 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s665 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys197, PRE_first_tail_x15_r0_body.sizeArgs197)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA197 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s665 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA197 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA197 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA197 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA197 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec197 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s665 PRE_first_tail_x15_r0_body.sizeTys197 PRE_first_tail_x15_r0_body.sizeArgs197).run PRE_first_tail_x15_r0_body.S665
noncomputable def PRE_first_tail_x15_r0_body.sizeAs197 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec197 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0197 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec197 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S665
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA197 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s665 PRE_first_tail_x15_r0_body.sizeTys197 PRE_first_tail_x15_r0_body.sizeArgs197).run PRE_first_tail_x15_r0_body.S665 =
  some (some PRE_first_tail_x15_r0_body.sizeAs197, PRE_first_tail_x15_r0_body.sizeS0197)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA197 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0197 PRE_first_tail_x15_r0_body.s665.ffi PRE_first_tail_x15_r0_body.sizeAs197 = true
/-- Bridge 198's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys198 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s668 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs198 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s668 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA198 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s668 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys198, PRE_first_tail_x15_r0_body.sizeArgs198)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA198 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s668 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA198 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA198 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA198 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA198 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec198 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s668 PRE_first_tail_x15_r0_body.sizeTys198 PRE_first_tail_x15_r0_body.sizeArgs198).run PRE_first_tail_x15_r0_body.S668
noncomputable def PRE_first_tail_x15_r0_body.sizeAs198 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec198 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0198 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec198 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S668
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA198 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s668 PRE_first_tail_x15_r0_body.sizeTys198 PRE_first_tail_x15_r0_body.sizeArgs198).run PRE_first_tail_x15_r0_body.S668 =
  some (some PRE_first_tail_x15_r0_body.sizeAs198, PRE_first_tail_x15_r0_body.sizeS0198)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA198 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0198 PRE_first_tail_x15_r0_body.s668.ffi PRE_first_tail_x15_r0_body.sizeAs198 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA199 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s671 "recurWindow" none = true
/-- Bridge 200's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys200 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s675 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs200 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s675 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA200 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s675 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys200, PRE_first_tail_x15_r0_body.sizeArgs200)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA200 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s675 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA200 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA200 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA200 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA200 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec200 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s675 PRE_first_tail_x15_r0_body.sizeTys200 PRE_first_tail_x15_r0_body.sizeArgs200).run PRE_first_tail_x15_r0_body.S675
noncomputable def PRE_first_tail_x15_r0_body.sizeAs200 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec200 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0200 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec200 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S675
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA200 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s675 PRE_first_tail_x15_r0_body.sizeTys200 PRE_first_tail_x15_r0_body.sizeArgs200).run PRE_first_tail_x15_r0_body.S675 =
  some (some PRE_first_tail_x15_r0_body.sizeAs200, PRE_first_tail_x15_r0_body.sizeS0200)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA200 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0200 PRE_first_tail_x15_r0_body.s675.ffi PRE_first_tail_x15_r0_body.sizeAs200 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA201 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s678 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA202 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s682 "plan" none = true
/-- Bridge 203's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys203 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s686 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs203 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s686 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA203 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s686 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys203, PRE_first_tail_x15_r0_body.sizeArgs203)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA203 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s686 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA203 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA203 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA203 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA203 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec203 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s686 PRE_first_tail_x15_r0_body.sizeTys203 PRE_first_tail_x15_r0_body.sizeArgs203).run PRE_first_tail_x15_r0_body.S686
noncomputable def PRE_first_tail_x15_r0_body.sizeAs203 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec203 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0203 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec203 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S686
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA203 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s686 PRE_first_tail_x15_r0_body.sizeTys203 PRE_first_tail_x15_r0_body.sizeArgs203).run PRE_first_tail_x15_r0_body.S686 =
  some (some PRE_first_tail_x15_r0_body.sizeAs203, PRE_first_tail_x15_r0_body.sizeS0203)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA203 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0203 PRE_first_tail_x15_r0_body.s686.ffi PRE_first_tail_x15_r0_body.sizeAs203 = true
/-- Bridge 204's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys204 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s689 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs204 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s689 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA204 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s689 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys204, PRE_first_tail_x15_r0_body.sizeArgs204)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA204 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s689 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA204 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA204 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA204 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA204 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec204 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s689 PRE_first_tail_x15_r0_body.sizeTys204 PRE_first_tail_x15_r0_body.sizeArgs204).run PRE_first_tail_x15_r0_body.S689
noncomputable def PRE_first_tail_x15_r0_body.sizeAs204 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec204 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0204 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec204 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S689
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA204 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s689 PRE_first_tail_x15_r0_body.sizeTys204 PRE_first_tail_x15_r0_body.sizeArgs204).run PRE_first_tail_x15_r0_body.S689 =
  some (some PRE_first_tail_x15_r0_body.sizeAs204, PRE_first_tail_x15_r0_body.sizeS0204)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA204 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0204 PRE_first_tail_x15_r0_body.s689.ffi PRE_first_tail_x15_r0_body.sizeAs204 = true
/-- Bridge 205's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys205 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s692 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs205 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s692 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA205 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s692 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys205, PRE_first_tail_x15_r0_body.sizeArgs205)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA205 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s692 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA205 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA205 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA205 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA205 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec205 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s692 PRE_first_tail_x15_r0_body.sizeTys205 PRE_first_tail_x15_r0_body.sizeArgs205).run PRE_first_tail_x15_r0_body.S692
noncomputable def PRE_first_tail_x15_r0_body.sizeAs205 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec205 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0205 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec205 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S692
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA205 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s692 PRE_first_tail_x15_r0_body.sizeTys205 PRE_first_tail_x15_r0_body.sizeArgs205).run PRE_first_tail_x15_r0_body.S692 =
  some (some PRE_first_tail_x15_r0_body.sizeAs205, PRE_first_tail_x15_r0_body.sizeS0205)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA205 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0205 PRE_first_tail_x15_r0_body.s692.ffi PRE_first_tail_x15_r0_body.sizeAs205 = true
/-- Bridge 206's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys206 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s695 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs206 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s695 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA206 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s695 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys206, PRE_first_tail_x15_r0_body.sizeArgs206)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA206 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s695 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA206 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA206 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA206 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA206 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec206 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s695 PRE_first_tail_x15_r0_body.sizeTys206 PRE_first_tail_x15_r0_body.sizeArgs206).run PRE_first_tail_x15_r0_body.S695
noncomputable def PRE_first_tail_x15_r0_body.sizeAs206 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec206 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0206 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec206 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S695
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA206 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s695 PRE_first_tail_x15_r0_body.sizeTys206 PRE_first_tail_x15_r0_body.sizeArgs206).run PRE_first_tail_x15_r0_body.S695 =
  some (some PRE_first_tail_x15_r0_body.sizeAs206, PRE_first_tail_x15_r0_body.sizeS0206)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA206 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0206 PRE_first_tail_x15_r0_body.s695.ffi PRE_first_tail_x15_r0_body.sizeAs206 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA207 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s698 "recurWindow" none = true
/-- Bridge 208's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys208 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s702 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs208 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s702 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA208 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s702 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys208, PRE_first_tail_x15_r0_body.sizeArgs208)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA208 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s702 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA208 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA208 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA208 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA208 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec208 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s702 PRE_first_tail_x15_r0_body.sizeTys208 PRE_first_tail_x15_r0_body.sizeArgs208).run PRE_first_tail_x15_r0_body.S702
noncomputable def PRE_first_tail_x15_r0_body.sizeAs208 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec208 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0208 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec208 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S702
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA208 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s702 PRE_first_tail_x15_r0_body.sizeTys208 PRE_first_tail_x15_r0_body.sizeArgs208).run PRE_first_tail_x15_r0_body.S702 =
  some (some PRE_first_tail_x15_r0_body.sizeAs208, PRE_first_tail_x15_r0_body.sizeS0208)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA208 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0208 PRE_first_tail_x15_r0_body.s702.ffi PRE_first_tail_x15_r0_body.sizeAs208 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA209 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s705 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA210 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s709 "plan" none = true
/-- Bridge 211's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys211 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s713 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs211 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s713 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA211 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s713 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys211, PRE_first_tail_x15_r0_body.sizeArgs211)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA211 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s713 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA211 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA211 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA211 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA211 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec211 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s713 PRE_first_tail_x15_r0_body.sizeTys211 PRE_first_tail_x15_r0_body.sizeArgs211).run PRE_first_tail_x15_r0_body.S713
noncomputable def PRE_first_tail_x15_r0_body.sizeAs211 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec211 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0211 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec211 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S713
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA211 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s713 PRE_first_tail_x15_r0_body.sizeTys211 PRE_first_tail_x15_r0_body.sizeArgs211).run PRE_first_tail_x15_r0_body.S713 =
  some (some PRE_first_tail_x15_r0_body.sizeAs211, PRE_first_tail_x15_r0_body.sizeS0211)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA211 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0211 PRE_first_tail_x15_r0_body.s713.ffi PRE_first_tail_x15_r0_body.sizeAs211 = true
/-- Bridge 212's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys212 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s716 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs212 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s716 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA212 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s716 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys212, PRE_first_tail_x15_r0_body.sizeArgs212)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA212 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s716 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA212 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA212 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA212 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA212 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec212 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.sizeTys212 PRE_first_tail_x15_r0_body.sizeArgs212).run PRE_first_tail_x15_r0_body.S716
noncomputable def PRE_first_tail_x15_r0_body.sizeAs212 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec212 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0212 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec212 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S716
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA212 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.sizeTys212 PRE_first_tail_x15_r0_body.sizeArgs212).run PRE_first_tail_x15_r0_body.S716 =
  some (some PRE_first_tail_x15_r0_body.sizeAs212, PRE_first_tail_x15_r0_body.sizeS0212)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA212 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0212 PRE_first_tail_x15_r0_body.s716.ffi PRE_first_tail_x15_r0_body.sizeAs212 = true
/-- Bridge 213's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys213 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s719 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs213 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s719 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA213 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s719 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys213, PRE_first_tail_x15_r0_body.sizeArgs213)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA213 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s719 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA213 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA213 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA213 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA213 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec213 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s719 PRE_first_tail_x15_r0_body.sizeTys213 PRE_first_tail_x15_r0_body.sizeArgs213).run PRE_first_tail_x15_r0_body.S719
noncomputable def PRE_first_tail_x15_r0_body.sizeAs213 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec213 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0213 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec213 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S719
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA213 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s719 PRE_first_tail_x15_r0_body.sizeTys213 PRE_first_tail_x15_r0_body.sizeArgs213).run PRE_first_tail_x15_r0_body.S719 =
  some (some PRE_first_tail_x15_r0_body.sizeAs213, PRE_first_tail_x15_r0_body.sizeS0213)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA213 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0213 PRE_first_tail_x15_r0_body.s719.ffi PRE_first_tail_x15_r0_body.sizeAs213 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA214 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s722 "appendWindow" none = true
/-- Bridge 215's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys215 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s726 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs215 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s726 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA215 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s726 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys215, PRE_first_tail_x15_r0_body.sizeArgs215)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA215 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s726 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA215 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA215 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA215 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA215 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec215 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s726 PRE_first_tail_x15_r0_body.sizeTys215 PRE_first_tail_x15_r0_body.sizeArgs215).run PRE_first_tail_x15_r0_body.S726
noncomputable def PRE_first_tail_x15_r0_body.sizeAs215 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec215 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0215 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec215 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S726
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA215 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s726 PRE_first_tail_x15_r0_body.sizeTys215 PRE_first_tail_x15_r0_body.sizeArgs215).run PRE_first_tail_x15_r0_body.S726 =
  some (some PRE_first_tail_x15_r0_body.sizeAs215, PRE_first_tail_x15_r0_body.sizeS0215)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA215 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0215 PRE_first_tail_x15_r0_body.s726.ffi PRE_first_tail_x15_r0_body.sizeAs215 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA216 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s729 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA217 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s733 "plan" none = true
/-- Bridge 218's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys218 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s737 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs218 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s737 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA218 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s737 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys218, PRE_first_tail_x15_r0_body.sizeArgs218)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA218 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s737 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA218 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA218 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA218 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA218 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec218 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.sizeTys218 PRE_first_tail_x15_r0_body.sizeArgs218).run PRE_first_tail_x15_r0_body.S737
noncomputable def PRE_first_tail_x15_r0_body.sizeAs218 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec218 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0218 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec218 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S737
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA218 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.sizeTys218 PRE_first_tail_x15_r0_body.sizeArgs218).run PRE_first_tail_x15_r0_body.S737 =
  some (some PRE_first_tail_x15_r0_body.sizeAs218, PRE_first_tail_x15_r0_body.sizeS0218)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA218 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0218 PRE_first_tail_x15_r0_body.s737.ffi PRE_first_tail_x15_r0_body.sizeAs218 = true
/-- Bridge 219's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys219 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s740 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs219 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s740 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA219 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s740 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys219, PRE_first_tail_x15_r0_body.sizeArgs219)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA219 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s740 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA219 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA219 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA219 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA219 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec219 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s740 PRE_first_tail_x15_r0_body.sizeTys219 PRE_first_tail_x15_r0_body.sizeArgs219).run PRE_first_tail_x15_r0_body.S740
noncomputable def PRE_first_tail_x15_r0_body.sizeAs219 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec219 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0219 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec219 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S740
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA219 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s740 PRE_first_tail_x15_r0_body.sizeTys219 PRE_first_tail_x15_r0_body.sizeArgs219).run PRE_first_tail_x15_r0_body.S740 =
  some (some PRE_first_tail_x15_r0_body.sizeAs219, PRE_first_tail_x15_r0_body.sizeS0219)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA219 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0219 PRE_first_tail_x15_r0_body.s740.ffi PRE_first_tail_x15_r0_body.sizeAs219 = true
/-- Bridge 220's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys220 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s743 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs220 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s743 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA220 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s743 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys220, PRE_first_tail_x15_r0_body.sizeArgs220)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA220 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s743 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA220 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA220 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA220 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA220 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec220 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s743 PRE_first_tail_x15_r0_body.sizeTys220 PRE_first_tail_x15_r0_body.sizeArgs220).run PRE_first_tail_x15_r0_body.S743
noncomputable def PRE_first_tail_x15_r0_body.sizeAs220 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec220 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0220 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec220 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S743
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA220 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s743 PRE_first_tail_x15_r0_body.sizeTys220 PRE_first_tail_x15_r0_body.sizeArgs220).run PRE_first_tail_x15_r0_body.S743 =
  some (some PRE_first_tail_x15_r0_body.sizeAs220, PRE_first_tail_x15_r0_body.sizeS0220)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA220 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0220 PRE_first_tail_x15_r0_body.s743.ffi PRE_first_tail_x15_r0_body.sizeAs220 = true
/-- Bridge 221's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys221 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s746 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs221 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s746 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA221 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s746 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys221, PRE_first_tail_x15_r0_body.sizeArgs221)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA221 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s746 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA221 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA221 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA221 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA221 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec221 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s746 PRE_first_tail_x15_r0_body.sizeTys221 PRE_first_tail_x15_r0_body.sizeArgs221).run PRE_first_tail_x15_r0_body.S746
noncomputable def PRE_first_tail_x15_r0_body.sizeAs221 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec221 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0221 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec221 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S746
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA221 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s746 PRE_first_tail_x15_r0_body.sizeTys221 PRE_first_tail_x15_r0_body.sizeArgs221).run PRE_first_tail_x15_r0_body.S746 =
  some (some PRE_first_tail_x15_r0_body.sizeAs221, PRE_first_tail_x15_r0_body.sizeS0221)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA221 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0221 PRE_first_tail_x15_r0_body.s746.ffi PRE_first_tail_x15_r0_body.sizeAs221 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA222 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s749 "recurWindow" none = true
/-- Bridge 223's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys223 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s753 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs223 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s753 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA223 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s753 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys223, PRE_first_tail_x15_r0_body.sizeArgs223)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA223 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s753 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA223 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA223 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA223 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA223 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec223 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s753 PRE_first_tail_x15_r0_body.sizeTys223 PRE_first_tail_x15_r0_body.sizeArgs223).run PRE_first_tail_x15_r0_body.S753
noncomputable def PRE_first_tail_x15_r0_body.sizeAs223 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec223 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0223 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec223 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S753
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA223 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s753 PRE_first_tail_x15_r0_body.sizeTys223 PRE_first_tail_x15_r0_body.sizeArgs223).run PRE_first_tail_x15_r0_body.S753 =
  some (some PRE_first_tail_x15_r0_body.sizeAs223, PRE_first_tail_x15_r0_body.sizeS0223)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA223 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0223 PRE_first_tail_x15_r0_body.s753.ffi PRE_first_tail_x15_r0_body.sizeAs223 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA224 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s756 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA225 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s760 "plan" none = true
/-- Bridge 226's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys226 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s764 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs226 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s764 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA226 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s764 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys226, PRE_first_tail_x15_r0_body.sizeArgs226)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA226 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s764 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA226 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA226 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA226 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA226 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec226 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s764 PRE_first_tail_x15_r0_body.sizeTys226 PRE_first_tail_x15_r0_body.sizeArgs226).run PRE_first_tail_x15_r0_body.S764
noncomputable def PRE_first_tail_x15_r0_body.sizeAs226 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec226 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0226 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec226 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S764
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA226 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s764 PRE_first_tail_x15_r0_body.sizeTys226 PRE_first_tail_x15_r0_body.sizeArgs226).run PRE_first_tail_x15_r0_body.S764 =
  some (some PRE_first_tail_x15_r0_body.sizeAs226, PRE_first_tail_x15_r0_body.sizeS0226)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA226 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0226 PRE_first_tail_x15_r0_body.s764.ffi PRE_first_tail_x15_r0_body.sizeAs226 = true
/-- Bridge 227's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys227 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s767 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs227 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s767 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA227 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s767 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys227, PRE_first_tail_x15_r0_body.sizeArgs227)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA227 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s767 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA227 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA227 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA227 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA227 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec227 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s767 PRE_first_tail_x15_r0_body.sizeTys227 PRE_first_tail_x15_r0_body.sizeArgs227).run PRE_first_tail_x15_r0_body.S767
noncomputable def PRE_first_tail_x15_r0_body.sizeAs227 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec227 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0227 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec227 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S767
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA227 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s767 PRE_first_tail_x15_r0_body.sizeTys227 PRE_first_tail_x15_r0_body.sizeArgs227).run PRE_first_tail_x15_r0_body.S767 =
  some (some PRE_first_tail_x15_r0_body.sizeAs227, PRE_first_tail_x15_r0_body.sizeS0227)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA227 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0227 PRE_first_tail_x15_r0_body.s767.ffi PRE_first_tail_x15_r0_body.sizeAs227 = true
/-- Bridge 228's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys228 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s770 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs228 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s770 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA228 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s770 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys228, PRE_first_tail_x15_r0_body.sizeArgs228)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA228 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s770 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA228 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA228 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA228 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA228 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec228 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s770 PRE_first_tail_x15_r0_body.sizeTys228 PRE_first_tail_x15_r0_body.sizeArgs228).run PRE_first_tail_x15_r0_body.S770
noncomputable def PRE_first_tail_x15_r0_body.sizeAs228 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec228 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0228 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec228 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S770
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA228 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s770 PRE_first_tail_x15_r0_body.sizeTys228 PRE_first_tail_x15_r0_body.sizeArgs228).run PRE_first_tail_x15_r0_body.S770 =
  some (some PRE_first_tail_x15_r0_body.sizeAs228, PRE_first_tail_x15_r0_body.sizeS0228)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA228 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0228 PRE_first_tail_x15_r0_body.s770.ffi PRE_first_tail_x15_r0_body.sizeAs228 = true
/-- Bridge 229's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys229 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s773 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs229 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s773 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA229 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s773 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys229, PRE_first_tail_x15_r0_body.sizeArgs229)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA229 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s773 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA229 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA229 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA229 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA229 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec229 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s773 PRE_first_tail_x15_r0_body.sizeTys229 PRE_first_tail_x15_r0_body.sizeArgs229).run PRE_first_tail_x15_r0_body.S773
noncomputable def PRE_first_tail_x15_r0_body.sizeAs229 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec229 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0229 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec229 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S773
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA229 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s773 PRE_first_tail_x15_r0_body.sizeTys229 PRE_first_tail_x15_r0_body.sizeArgs229).run PRE_first_tail_x15_r0_body.S773 =
  some (some PRE_first_tail_x15_r0_body.sizeAs229, PRE_first_tail_x15_r0_body.sizeS0229)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA229 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0229 PRE_first_tail_x15_r0_body.s773.ffi PRE_first_tail_x15_r0_body.sizeAs229 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA230 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s776 "recurWindow" none = true
/-- Bridge 231's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys231 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s780 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs231 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s780 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA231 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s780 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys231, PRE_first_tail_x15_r0_body.sizeArgs231)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA231 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s780 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA231 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA231 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA231 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA231 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec231 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s780 PRE_first_tail_x15_r0_body.sizeTys231 PRE_first_tail_x15_r0_body.sizeArgs231).run PRE_first_tail_x15_r0_body.S780
noncomputable def PRE_first_tail_x15_r0_body.sizeAs231 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec231 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0231 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec231 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S780
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA231 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s780 PRE_first_tail_x15_r0_body.sizeTys231 PRE_first_tail_x15_r0_body.sizeArgs231).run PRE_first_tail_x15_r0_body.S780 =
  some (some PRE_first_tail_x15_r0_body.sizeAs231, PRE_first_tail_x15_r0_body.sizeS0231)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA231 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0231 PRE_first_tail_x15_r0_body.s780.ffi PRE_first_tail_x15_r0_body.sizeAs231 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA232 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s783 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA233 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s787 "plan" none = true
/-- Bridge 234's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys234 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s791 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs234 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s791 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA234 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s791 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys234, PRE_first_tail_x15_r0_body.sizeArgs234)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA234 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s791 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA234 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA234 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA234 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA234 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec234 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s791 PRE_first_tail_x15_r0_body.sizeTys234 PRE_first_tail_x15_r0_body.sizeArgs234).run PRE_first_tail_x15_r0_body.S791
noncomputable def PRE_first_tail_x15_r0_body.sizeAs234 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec234 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0234 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec234 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S791
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA234 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s791 PRE_first_tail_x15_r0_body.sizeTys234 PRE_first_tail_x15_r0_body.sizeArgs234).run PRE_first_tail_x15_r0_body.S791 =
  some (some PRE_first_tail_x15_r0_body.sizeAs234, PRE_first_tail_x15_r0_body.sizeS0234)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA234 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0234 PRE_first_tail_x15_r0_body.s791.ffi PRE_first_tail_x15_r0_body.sizeAs234 = true
/-- Bridge 235's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys235 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s794 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs235 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s794 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA235 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s794 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys235, PRE_first_tail_x15_r0_body.sizeArgs235)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA235 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s794 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA235 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA235 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA235 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA235 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec235 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s794 PRE_first_tail_x15_r0_body.sizeTys235 PRE_first_tail_x15_r0_body.sizeArgs235).run PRE_first_tail_x15_r0_body.S794
noncomputable def PRE_first_tail_x15_r0_body.sizeAs235 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec235 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0235 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec235 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S794
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA235 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s794 PRE_first_tail_x15_r0_body.sizeTys235 PRE_first_tail_x15_r0_body.sizeArgs235).run PRE_first_tail_x15_r0_body.S794 =
  some (some PRE_first_tail_x15_r0_body.sizeAs235, PRE_first_tail_x15_r0_body.sizeS0235)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA235 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0235 PRE_first_tail_x15_r0_body.s794.ffi PRE_first_tail_x15_r0_body.sizeAs235 = true
/-- Bridge 236's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys236 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s797 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs236 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s797 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA236 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s797 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys236, PRE_first_tail_x15_r0_body.sizeArgs236)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA236 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s797 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA236 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA236 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA236 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA236 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec236 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s797 PRE_first_tail_x15_r0_body.sizeTys236 PRE_first_tail_x15_r0_body.sizeArgs236).run PRE_first_tail_x15_r0_body.S797
noncomputable def PRE_first_tail_x15_r0_body.sizeAs236 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec236 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0236 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec236 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S797
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA236 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s797 PRE_first_tail_x15_r0_body.sizeTys236 PRE_first_tail_x15_r0_body.sizeArgs236).run PRE_first_tail_x15_r0_body.S797 =
  some (some PRE_first_tail_x15_r0_body.sizeAs236, PRE_first_tail_x15_r0_body.sizeS0236)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA236 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0236 PRE_first_tail_x15_r0_body.s797.ffi PRE_first_tail_x15_r0_body.sizeAs236 = true
/-- Bridge 237's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys237 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s800 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs237 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s800 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA237 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s800 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys237, PRE_first_tail_x15_r0_body.sizeArgs237)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA237 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s800 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA237 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA237 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA237 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA237 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec237 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s800 PRE_first_tail_x15_r0_body.sizeTys237 PRE_first_tail_x15_r0_body.sizeArgs237).run PRE_first_tail_x15_r0_body.S800
noncomputable def PRE_first_tail_x15_r0_body.sizeAs237 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec237 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0237 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec237 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S800
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA237 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s800 PRE_first_tail_x15_r0_body.sizeTys237 PRE_first_tail_x15_r0_body.sizeArgs237).run PRE_first_tail_x15_r0_body.S800 =
  some (some PRE_first_tail_x15_r0_body.sizeAs237, PRE_first_tail_x15_r0_body.sizeS0237)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA237 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0237 PRE_first_tail_x15_r0_body.s800.ffi PRE_first_tail_x15_r0_body.sizeAs237 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA238 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s803 "recurWindow" none = true
/-- Bridge 239's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys239 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s807 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs239 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s807 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA239 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s807 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys239, PRE_first_tail_x15_r0_body.sizeArgs239)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA239 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s807 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA239 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA239 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA239 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA239 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec239 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s807 PRE_first_tail_x15_r0_body.sizeTys239 PRE_first_tail_x15_r0_body.sizeArgs239).run PRE_first_tail_x15_r0_body.S807
noncomputable def PRE_first_tail_x15_r0_body.sizeAs239 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec239 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0239 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec239 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S807
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA239 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s807 PRE_first_tail_x15_r0_body.sizeTys239 PRE_first_tail_x15_r0_body.sizeArgs239).run PRE_first_tail_x15_r0_body.S807 =
  some (some PRE_first_tail_x15_r0_body.sizeAs239, PRE_first_tail_x15_r0_body.sizeS0239)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA239 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0239 PRE_first_tail_x15_r0_body.s807.ffi PRE_first_tail_x15_r0_body.sizeAs239 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA240 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s810 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA241 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s814 "plan" none = true
/-- Bridge 242's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys242 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s818 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs242 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s818 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA242 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s818 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys242, PRE_first_tail_x15_r0_body.sizeArgs242)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA242 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s818 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA242 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA242 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA242 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA242 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec242 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s818 PRE_first_tail_x15_r0_body.sizeTys242 PRE_first_tail_x15_r0_body.sizeArgs242).run PRE_first_tail_x15_r0_body.S818
noncomputable def PRE_first_tail_x15_r0_body.sizeAs242 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec242 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0242 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec242 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S818
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA242 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s818 PRE_first_tail_x15_r0_body.sizeTys242 PRE_first_tail_x15_r0_body.sizeArgs242).run PRE_first_tail_x15_r0_body.S818 =
  some (some PRE_first_tail_x15_r0_body.sizeAs242, PRE_first_tail_x15_r0_body.sizeS0242)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA242 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0242 PRE_first_tail_x15_r0_body.s818.ffi PRE_first_tail_x15_r0_body.sizeAs242 = true
/-- Bridge 243's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys243 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s821 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs243 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s821 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA243 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s821 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys243, PRE_first_tail_x15_r0_body.sizeArgs243)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA243 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s821 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA243 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA243 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA243 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA243 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec243 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s821 PRE_first_tail_x15_r0_body.sizeTys243 PRE_first_tail_x15_r0_body.sizeArgs243).run PRE_first_tail_x15_r0_body.S821
noncomputable def PRE_first_tail_x15_r0_body.sizeAs243 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec243 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0243 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec243 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S821
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA243 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s821 PRE_first_tail_x15_r0_body.sizeTys243 PRE_first_tail_x15_r0_body.sizeArgs243).run PRE_first_tail_x15_r0_body.S821 =
  some (some PRE_first_tail_x15_r0_body.sizeAs243, PRE_first_tail_x15_r0_body.sizeS0243)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA243 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0243 PRE_first_tail_x15_r0_body.s821.ffi PRE_first_tail_x15_r0_body.sizeAs243 = true
/-- Bridge 244's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys244 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s824 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs244 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s824 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA244 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s824 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys244, PRE_first_tail_x15_r0_body.sizeArgs244)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA244 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s824 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA244 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA244 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA244 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA244 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec244 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s824 PRE_first_tail_x15_r0_body.sizeTys244 PRE_first_tail_x15_r0_body.sizeArgs244).run PRE_first_tail_x15_r0_body.S824
noncomputable def PRE_first_tail_x15_r0_body.sizeAs244 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec244 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0244 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec244 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S824
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA244 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s824 PRE_first_tail_x15_r0_body.sizeTys244 PRE_first_tail_x15_r0_body.sizeArgs244).run PRE_first_tail_x15_r0_body.S824 =
  some (some PRE_first_tail_x15_r0_body.sizeAs244, PRE_first_tail_x15_r0_body.sizeS0244)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA244 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0244 PRE_first_tail_x15_r0_body.s824.ffi PRE_first_tail_x15_r0_body.sizeAs244 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA245 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s827 "appendWindow" none = true
/-- Bridge 246's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys246 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s831 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs246 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s831 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA246 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s831 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys246, PRE_first_tail_x15_r0_body.sizeArgs246)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA246 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s831 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA246 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA246 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA246 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA246 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec246 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s831 PRE_first_tail_x15_r0_body.sizeTys246 PRE_first_tail_x15_r0_body.sizeArgs246).run PRE_first_tail_x15_r0_body.S831
noncomputable def PRE_first_tail_x15_r0_body.sizeAs246 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec246 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0246 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec246 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S831
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA246 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s831 PRE_first_tail_x15_r0_body.sizeTys246 PRE_first_tail_x15_r0_body.sizeArgs246).run PRE_first_tail_x15_r0_body.S831 =
  some (some PRE_first_tail_x15_r0_body.sizeAs246, PRE_first_tail_x15_r0_body.sizeS0246)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA246 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0246 PRE_first_tail_x15_r0_body.s831.ffi PRE_first_tail_x15_r0_body.sizeAs246 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA247 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s834 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA248 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s838 "plan" none = true
/-- Bridge 249's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys249 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s842 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs249 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s842 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA249 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s842 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys249, PRE_first_tail_x15_r0_body.sizeArgs249)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA249 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s842 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA249 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA249 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA249 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA249 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec249 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s842 PRE_first_tail_x15_r0_body.sizeTys249 PRE_first_tail_x15_r0_body.sizeArgs249).run PRE_first_tail_x15_r0_body.S842
noncomputable def PRE_first_tail_x15_r0_body.sizeAs249 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec249 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0249 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec249 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S842
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA249 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s842 PRE_first_tail_x15_r0_body.sizeTys249 PRE_first_tail_x15_r0_body.sizeArgs249).run PRE_first_tail_x15_r0_body.S842 =
  some (some PRE_first_tail_x15_r0_body.sizeAs249, PRE_first_tail_x15_r0_body.sizeS0249)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA249 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0249 PRE_first_tail_x15_r0_body.s842.ffi PRE_first_tail_x15_r0_body.sizeAs249 = true
/-- Bridge 250's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys250 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s845 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs250 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s845 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA250 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s845 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys250, PRE_first_tail_x15_r0_body.sizeArgs250)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA250 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s845 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA250 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA250 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA250 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA250 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec250 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s845 PRE_first_tail_x15_r0_body.sizeTys250 PRE_first_tail_x15_r0_body.sizeArgs250).run PRE_first_tail_x15_r0_body.S845
noncomputable def PRE_first_tail_x15_r0_body.sizeAs250 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec250 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0250 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec250 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S845
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA250 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s845 PRE_first_tail_x15_r0_body.sizeTys250 PRE_first_tail_x15_r0_body.sizeArgs250).run PRE_first_tail_x15_r0_body.S845 =
  some (some PRE_first_tail_x15_r0_body.sizeAs250, PRE_first_tail_x15_r0_body.sizeS0250)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA250 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0250 PRE_first_tail_x15_r0_body.s845.ffi PRE_first_tail_x15_r0_body.sizeAs250 = true
/-- Bridge 251's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys251 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s848 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs251 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s848 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA251 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s848 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys251, PRE_first_tail_x15_r0_body.sizeArgs251)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA251 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s848 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA251 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA251 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA251 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA251 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec251 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s848 PRE_first_tail_x15_r0_body.sizeTys251 PRE_first_tail_x15_r0_body.sizeArgs251).run PRE_first_tail_x15_r0_body.S848
noncomputable def PRE_first_tail_x15_r0_body.sizeAs251 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec251 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0251 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec251 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S848
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA251 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s848 PRE_first_tail_x15_r0_body.sizeTys251 PRE_first_tail_x15_r0_body.sizeArgs251).run PRE_first_tail_x15_r0_body.S848 =
  some (some PRE_first_tail_x15_r0_body.sizeAs251, PRE_first_tail_x15_r0_body.sizeS0251)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA251 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0251 PRE_first_tail_x15_r0_body.s848.ffi PRE_first_tail_x15_r0_body.sizeAs251 = true
/-- Bridge 252's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys252 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s851 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs252 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s851 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA252 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s851 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys252, PRE_first_tail_x15_r0_body.sizeArgs252)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA252 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s851 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA252 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA252 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA252 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA252 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec252 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s851 PRE_first_tail_x15_r0_body.sizeTys252 PRE_first_tail_x15_r0_body.sizeArgs252).run PRE_first_tail_x15_r0_body.S851
noncomputable def PRE_first_tail_x15_r0_body.sizeAs252 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec252 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0252 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec252 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S851
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA252 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s851 PRE_first_tail_x15_r0_body.sizeTys252 PRE_first_tail_x15_r0_body.sizeArgs252).run PRE_first_tail_x15_r0_body.S851 =
  some (some PRE_first_tail_x15_r0_body.sizeAs252, PRE_first_tail_x15_r0_body.sizeS0252)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA252 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0252 PRE_first_tail_x15_r0_body.s851.ffi PRE_first_tail_x15_r0_body.sizeAs252 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA253 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s854 "recurWindow" none = true
/-- Bridge 254's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys254 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s858 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs254 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s858 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA254 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s858 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys254, PRE_first_tail_x15_r0_body.sizeArgs254)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA254 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s858 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA254 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA254 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA254 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA254 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec254 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s858 PRE_first_tail_x15_r0_body.sizeTys254 PRE_first_tail_x15_r0_body.sizeArgs254).run PRE_first_tail_x15_r0_body.S858
noncomputable def PRE_first_tail_x15_r0_body.sizeAs254 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec254 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0254 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec254 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S858
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA254 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s858 PRE_first_tail_x15_r0_body.sizeTys254 PRE_first_tail_x15_r0_body.sizeArgs254).run PRE_first_tail_x15_r0_body.S858 =
  some (some PRE_first_tail_x15_r0_body.sizeAs254, PRE_first_tail_x15_r0_body.sizeS0254)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA254 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0254 PRE_first_tail_x15_r0_body.s858.ffi PRE_first_tail_x15_r0_body.sizeAs254 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA255 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s861 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA256 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s865 "plan" none = true
/-- Bridge 257's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys257 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s869 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs257 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s869 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA257 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s869 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys257, PRE_first_tail_x15_r0_body.sizeArgs257)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA257 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s869 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA257 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA257 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA257 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA257 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec257 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s869 PRE_first_tail_x15_r0_body.sizeTys257 PRE_first_tail_x15_r0_body.sizeArgs257).run PRE_first_tail_x15_r0_body.S869
noncomputable def PRE_first_tail_x15_r0_body.sizeAs257 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec257 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0257 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec257 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S869
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA257 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s869 PRE_first_tail_x15_r0_body.sizeTys257 PRE_first_tail_x15_r0_body.sizeArgs257).run PRE_first_tail_x15_r0_body.S869 =
  some (some PRE_first_tail_x15_r0_body.sizeAs257, PRE_first_tail_x15_r0_body.sizeS0257)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA257 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0257 PRE_first_tail_x15_r0_body.s869.ffi PRE_first_tail_x15_r0_body.sizeAs257 = true
/-- Bridge 258's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys258 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s872 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs258 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s872 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA258 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s872 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys258, PRE_first_tail_x15_r0_body.sizeArgs258)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA258 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s872 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA258 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA258 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA258 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA258 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec258 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s872 PRE_first_tail_x15_r0_body.sizeTys258 PRE_first_tail_x15_r0_body.sizeArgs258).run PRE_first_tail_x15_r0_body.S872
noncomputable def PRE_first_tail_x15_r0_body.sizeAs258 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec258 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0258 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec258 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S872
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA258 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s872 PRE_first_tail_x15_r0_body.sizeTys258 PRE_first_tail_x15_r0_body.sizeArgs258).run PRE_first_tail_x15_r0_body.S872 =
  some (some PRE_first_tail_x15_r0_body.sizeAs258, PRE_first_tail_x15_r0_body.sizeS0258)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA258 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0258 PRE_first_tail_x15_r0_body.s872.ffi PRE_first_tail_x15_r0_body.sizeAs258 = true
/-- Bridge 259's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys259 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s875 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs259 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s875 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA259 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s875 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys259, PRE_first_tail_x15_r0_body.sizeArgs259)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA259 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s875 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA259 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA259 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA259 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA259 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec259 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s875 PRE_first_tail_x15_r0_body.sizeTys259 PRE_first_tail_x15_r0_body.sizeArgs259).run PRE_first_tail_x15_r0_body.S875
noncomputable def PRE_first_tail_x15_r0_body.sizeAs259 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec259 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0259 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec259 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S875
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA259 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s875 PRE_first_tail_x15_r0_body.sizeTys259 PRE_first_tail_x15_r0_body.sizeArgs259).run PRE_first_tail_x15_r0_body.S875 =
  some (some PRE_first_tail_x15_r0_body.sizeAs259, PRE_first_tail_x15_r0_body.sizeS0259)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA259 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0259 PRE_first_tail_x15_r0_body.s875.ffi PRE_first_tail_x15_r0_body.sizeAs259 = true
/-- Bridge 260's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys260 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s878 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs260 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s878 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA260 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s878 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys260, PRE_first_tail_x15_r0_body.sizeArgs260)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA260 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s878 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA260 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA260 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA260 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA260 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec260 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s878 PRE_first_tail_x15_r0_body.sizeTys260 PRE_first_tail_x15_r0_body.sizeArgs260).run PRE_first_tail_x15_r0_body.S878
noncomputable def PRE_first_tail_x15_r0_body.sizeAs260 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec260 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0260 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec260 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S878
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA260 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s878 PRE_first_tail_x15_r0_body.sizeTys260 PRE_first_tail_x15_r0_body.sizeArgs260).run PRE_first_tail_x15_r0_body.S878 =
  some (some PRE_first_tail_x15_r0_body.sizeAs260, PRE_first_tail_x15_r0_body.sizeS0260)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA260 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0260 PRE_first_tail_x15_r0_body.s878.ffi PRE_first_tail_x15_r0_body.sizeAs260 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA261 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s881 "recurWindow" none = true
/-- Bridge 262's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys262 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s885 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs262 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s885 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA262 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s885 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys262, PRE_first_tail_x15_r0_body.sizeArgs262)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA262 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s885 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA262 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA262 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA262 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA262 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec262 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s885 PRE_first_tail_x15_r0_body.sizeTys262 PRE_first_tail_x15_r0_body.sizeArgs262).run PRE_first_tail_x15_r0_body.S885
noncomputable def PRE_first_tail_x15_r0_body.sizeAs262 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec262 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0262 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec262 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S885
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA262 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s885 PRE_first_tail_x15_r0_body.sizeTys262 PRE_first_tail_x15_r0_body.sizeArgs262).run PRE_first_tail_x15_r0_body.S885 =
  some (some PRE_first_tail_x15_r0_body.sizeAs262, PRE_first_tail_x15_r0_body.sizeS0262)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA262 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0262 PRE_first_tail_x15_r0_body.s885.ffi PRE_first_tail_x15_r0_body.sizeAs262 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA263 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s888 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA264 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s892 "plan" none = true
/-- Bridge 265's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys265 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s896 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs265 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s896 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA265 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s896 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys265, PRE_first_tail_x15_r0_body.sizeArgs265)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA265 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s896 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA265 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA265 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA265 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA265 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec265 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s896 PRE_first_tail_x15_r0_body.sizeTys265 PRE_first_tail_x15_r0_body.sizeArgs265).run PRE_first_tail_x15_r0_body.S896
noncomputable def PRE_first_tail_x15_r0_body.sizeAs265 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec265 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0265 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec265 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S896
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA265 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s896 PRE_first_tail_x15_r0_body.sizeTys265 PRE_first_tail_x15_r0_body.sizeArgs265).run PRE_first_tail_x15_r0_body.S896 =
  some (some PRE_first_tail_x15_r0_body.sizeAs265, PRE_first_tail_x15_r0_body.sizeS0265)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA265 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0265 PRE_first_tail_x15_r0_body.s896.ffi PRE_first_tail_x15_r0_body.sizeAs265 = true
/-- Bridge 266's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys266 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s899 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs266 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s899 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA266 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s899 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys266, PRE_first_tail_x15_r0_body.sizeArgs266)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA266 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s899 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA266 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA266 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA266 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA266 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec266 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s899 PRE_first_tail_x15_r0_body.sizeTys266 PRE_first_tail_x15_r0_body.sizeArgs266).run PRE_first_tail_x15_r0_body.S899
noncomputable def PRE_first_tail_x15_r0_body.sizeAs266 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec266 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0266 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec266 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S899
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA266 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s899 PRE_first_tail_x15_r0_body.sizeTys266 PRE_first_tail_x15_r0_body.sizeArgs266).run PRE_first_tail_x15_r0_body.S899 =
  some (some PRE_first_tail_x15_r0_body.sizeAs266, PRE_first_tail_x15_r0_body.sizeS0266)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA266 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0266 PRE_first_tail_x15_r0_body.s899.ffi PRE_first_tail_x15_r0_body.sizeAs266 = true
/-- Bridge 267's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys267 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s902 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs267 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s902 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA267 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s902 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys267, PRE_first_tail_x15_r0_body.sizeArgs267)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA267 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s902 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA267 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA267 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA267 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA267 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec267 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s902 PRE_first_tail_x15_r0_body.sizeTys267 PRE_first_tail_x15_r0_body.sizeArgs267).run PRE_first_tail_x15_r0_body.S902
noncomputable def PRE_first_tail_x15_r0_body.sizeAs267 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec267 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0267 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec267 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S902
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA267 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s902 PRE_first_tail_x15_r0_body.sizeTys267 PRE_first_tail_x15_r0_body.sizeArgs267).run PRE_first_tail_x15_r0_body.S902 =
  some (some PRE_first_tail_x15_r0_body.sizeAs267, PRE_first_tail_x15_r0_body.sizeS0267)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA267 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0267 PRE_first_tail_x15_r0_body.s902.ffi PRE_first_tail_x15_r0_body.sizeAs267 = true
/-- Bridge 268's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys268 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s905 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs268 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s905 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA268 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s905 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys268, PRE_first_tail_x15_r0_body.sizeArgs268)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA268 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s905 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA268 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA268 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA268 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA268 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec268 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s905 PRE_first_tail_x15_r0_body.sizeTys268 PRE_first_tail_x15_r0_body.sizeArgs268).run PRE_first_tail_x15_r0_body.S905
noncomputable def PRE_first_tail_x15_r0_body.sizeAs268 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec268 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0268 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec268 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S905
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA268 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s905 PRE_first_tail_x15_r0_body.sizeTys268 PRE_first_tail_x15_r0_body.sizeArgs268).run PRE_first_tail_x15_r0_body.S905 =
  some (some PRE_first_tail_x15_r0_body.sizeAs268, PRE_first_tail_x15_r0_body.sizeS0268)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA268 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0268 PRE_first_tail_x15_r0_body.s905.ffi PRE_first_tail_x15_r0_body.sizeAs268 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA269 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s908 "recurWindow" none = true
/-- Bridge 270's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys270 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s912 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs270 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s912 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA270 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s912 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys270, PRE_first_tail_x15_r0_body.sizeArgs270)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA270 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s912 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA270 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA270 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA270 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA270 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec270 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s912 PRE_first_tail_x15_r0_body.sizeTys270 PRE_first_tail_x15_r0_body.sizeArgs270).run PRE_first_tail_x15_r0_body.S912
noncomputable def PRE_first_tail_x15_r0_body.sizeAs270 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec270 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0270 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec270 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S912
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA270 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s912 PRE_first_tail_x15_r0_body.sizeTys270 PRE_first_tail_x15_r0_body.sizeArgs270).run PRE_first_tail_x15_r0_body.S912 =
  some (some PRE_first_tail_x15_r0_body.sizeAs270, PRE_first_tail_x15_r0_body.sizeS0270)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA270 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0270 PRE_first_tail_x15_r0_body.s912.ffi PRE_first_tail_x15_r0_body.sizeAs270 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA271 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s915 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA272 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s919 "plan" none = true
/-- Bridge 273's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys273 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s923 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs273 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s923 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA273 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s923 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys273, PRE_first_tail_x15_r0_body.sizeArgs273)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA273 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s923 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA273 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA273 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA273 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA273 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec273 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s923 PRE_first_tail_x15_r0_body.sizeTys273 PRE_first_tail_x15_r0_body.sizeArgs273).run PRE_first_tail_x15_r0_body.S923
noncomputable def PRE_first_tail_x15_r0_body.sizeAs273 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec273 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0273 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec273 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S923
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA273 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s923 PRE_first_tail_x15_r0_body.sizeTys273 PRE_first_tail_x15_r0_body.sizeArgs273).run PRE_first_tail_x15_r0_body.S923 =
  some (some PRE_first_tail_x15_r0_body.sizeAs273, PRE_first_tail_x15_r0_body.sizeS0273)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA273 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0273 PRE_first_tail_x15_r0_body.s923.ffi PRE_first_tail_x15_r0_body.sizeAs273 = true
/-- Bridge 274's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys274 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s926 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs274 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s926 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA274 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s926 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys274, PRE_first_tail_x15_r0_body.sizeArgs274)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA274 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s926 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA274 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA274 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA274 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA274 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec274 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s926 PRE_first_tail_x15_r0_body.sizeTys274 PRE_first_tail_x15_r0_body.sizeArgs274).run PRE_first_tail_x15_r0_body.S926
noncomputable def PRE_first_tail_x15_r0_body.sizeAs274 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec274 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0274 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec274 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S926
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA274 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s926 PRE_first_tail_x15_r0_body.sizeTys274 PRE_first_tail_x15_r0_body.sizeArgs274).run PRE_first_tail_x15_r0_body.S926 =
  some (some PRE_first_tail_x15_r0_body.sizeAs274, PRE_first_tail_x15_r0_body.sizeS0274)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA274 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0274 PRE_first_tail_x15_r0_body.s926.ffi PRE_first_tail_x15_r0_body.sizeAs274 = true
/-- Bridge 275's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys275 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s929 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs275 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s929 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA275 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s929 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys275, PRE_first_tail_x15_r0_body.sizeArgs275)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA275 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s929 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA275 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA275 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA275 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA275 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec275 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s929 PRE_first_tail_x15_r0_body.sizeTys275 PRE_first_tail_x15_r0_body.sizeArgs275).run PRE_first_tail_x15_r0_body.S929
noncomputable def PRE_first_tail_x15_r0_body.sizeAs275 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec275 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0275 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec275 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S929
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA275 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s929 PRE_first_tail_x15_r0_body.sizeTys275 PRE_first_tail_x15_r0_body.sizeArgs275).run PRE_first_tail_x15_r0_body.S929 =
  some (some PRE_first_tail_x15_r0_body.sizeAs275, PRE_first_tail_x15_r0_body.sizeS0275)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA275 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0275 PRE_first_tail_x15_r0_body.s929.ffi PRE_first_tail_x15_r0_body.sizeAs275 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA276 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s932 "appendWindow" none = true
/-- Bridge 277's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys277 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s936 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs277 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s936 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA277 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s936 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys277, PRE_first_tail_x15_r0_body.sizeArgs277)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA277 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s936 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA277 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA277 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA277 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA277 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec277 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s936 PRE_first_tail_x15_r0_body.sizeTys277 PRE_first_tail_x15_r0_body.sizeArgs277).run PRE_first_tail_x15_r0_body.S936
noncomputable def PRE_first_tail_x15_r0_body.sizeAs277 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec277 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0277 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec277 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S936
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA277 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s936 PRE_first_tail_x15_r0_body.sizeTys277 PRE_first_tail_x15_r0_body.sizeArgs277).run PRE_first_tail_x15_r0_body.S936 =
  some (some PRE_first_tail_x15_r0_body.sizeAs277, PRE_first_tail_x15_r0_body.sizeS0277)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA277 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0277 PRE_first_tail_x15_r0_body.s936.ffi PRE_first_tail_x15_r0_body.sizeAs277 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA278 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s939 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA279 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s943 "plan" none = true
/-- Bridge 280's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys280 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s947 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs280 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s947 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA280 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s947 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys280, PRE_first_tail_x15_r0_body.sizeArgs280)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA280 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s947 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA280 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA280 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA280 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA280 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec280 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s947 PRE_first_tail_x15_r0_body.sizeTys280 PRE_first_tail_x15_r0_body.sizeArgs280).run PRE_first_tail_x15_r0_body.S947
noncomputable def PRE_first_tail_x15_r0_body.sizeAs280 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec280 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0280 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec280 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S947
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA280 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s947 PRE_first_tail_x15_r0_body.sizeTys280 PRE_first_tail_x15_r0_body.sizeArgs280).run PRE_first_tail_x15_r0_body.S947 =
  some (some PRE_first_tail_x15_r0_body.sizeAs280, PRE_first_tail_x15_r0_body.sizeS0280)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA280 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0280 PRE_first_tail_x15_r0_body.s947.ffi PRE_first_tail_x15_r0_body.sizeAs280 = true
/-- Bridge 281's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys281 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s950 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs281 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s950 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA281 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s950 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys281, PRE_first_tail_x15_r0_body.sizeArgs281)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA281 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s950 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA281 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA281 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA281 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA281 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec281 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s950 PRE_first_tail_x15_r0_body.sizeTys281 PRE_first_tail_x15_r0_body.sizeArgs281).run PRE_first_tail_x15_r0_body.S950
noncomputable def PRE_first_tail_x15_r0_body.sizeAs281 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec281 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0281 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec281 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S950
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA281 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s950 PRE_first_tail_x15_r0_body.sizeTys281 PRE_first_tail_x15_r0_body.sizeArgs281).run PRE_first_tail_x15_r0_body.S950 =
  some (some PRE_first_tail_x15_r0_body.sizeAs281, PRE_first_tail_x15_r0_body.sizeS0281)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA281 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0281 PRE_first_tail_x15_r0_body.s950.ffi PRE_first_tail_x15_r0_body.sizeAs281 = true
/-- Bridge 282's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys282 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s953 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs282 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s953 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA282 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s953 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys282, PRE_first_tail_x15_r0_body.sizeArgs282)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA282 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s953 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA282 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA282 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA282 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA282 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec282 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s953 PRE_first_tail_x15_r0_body.sizeTys282 PRE_first_tail_x15_r0_body.sizeArgs282).run PRE_first_tail_x15_r0_body.S953
noncomputable def PRE_first_tail_x15_r0_body.sizeAs282 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec282 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0282 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec282 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S953
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA282 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s953 PRE_first_tail_x15_r0_body.sizeTys282 PRE_first_tail_x15_r0_body.sizeArgs282).run PRE_first_tail_x15_r0_body.S953 =
  some (some PRE_first_tail_x15_r0_body.sizeAs282, PRE_first_tail_x15_r0_body.sizeS0282)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA282 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0282 PRE_first_tail_x15_r0_body.s953.ffi PRE_first_tail_x15_r0_body.sizeAs282 = true
/-- Bridge 283's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys283 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s956 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs283 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s956 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA283 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s956 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys283, PRE_first_tail_x15_r0_body.sizeArgs283)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA283 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s956 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA283 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA283 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA283 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA283 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec283 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s956 PRE_first_tail_x15_r0_body.sizeTys283 PRE_first_tail_x15_r0_body.sizeArgs283).run PRE_first_tail_x15_r0_body.S956
noncomputable def PRE_first_tail_x15_r0_body.sizeAs283 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec283 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0283 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec283 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S956
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA283 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s956 PRE_first_tail_x15_r0_body.sizeTys283 PRE_first_tail_x15_r0_body.sizeArgs283).run PRE_first_tail_x15_r0_body.S956 =
  some (some PRE_first_tail_x15_r0_body.sizeAs283, PRE_first_tail_x15_r0_body.sizeS0283)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA283 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0283 PRE_first_tail_x15_r0_body.s956.ffi PRE_first_tail_x15_r0_body.sizeAs283 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA284 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s959 "recurWindow" none = true
/-- Bridge 285's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys285 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s963 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs285 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s963 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA285 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s963 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys285, PRE_first_tail_x15_r0_body.sizeArgs285)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA285 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s963 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA285 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA285 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA285 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA285 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec285 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s963 PRE_first_tail_x15_r0_body.sizeTys285 PRE_first_tail_x15_r0_body.sizeArgs285).run PRE_first_tail_x15_r0_body.S963
noncomputable def PRE_first_tail_x15_r0_body.sizeAs285 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec285 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0285 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec285 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S963
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA285 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s963 PRE_first_tail_x15_r0_body.sizeTys285 PRE_first_tail_x15_r0_body.sizeArgs285).run PRE_first_tail_x15_r0_body.S963 =
  some (some PRE_first_tail_x15_r0_body.sizeAs285, PRE_first_tail_x15_r0_body.sizeS0285)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA285 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0285 PRE_first_tail_x15_r0_body.s963.ffi PRE_first_tail_x15_r0_body.sizeAs285 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA286 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s966 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA287 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s970 "plan" none = true
/-- Bridge 288's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys288 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s974 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs288 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s974 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA288 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s974 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys288, PRE_first_tail_x15_r0_body.sizeArgs288)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA288 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s974 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA288 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA288 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA288 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA288 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec288 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s974 PRE_first_tail_x15_r0_body.sizeTys288 PRE_first_tail_x15_r0_body.sizeArgs288).run PRE_first_tail_x15_r0_body.S974
noncomputable def PRE_first_tail_x15_r0_body.sizeAs288 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec288 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0288 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec288 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S974
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA288 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s974 PRE_first_tail_x15_r0_body.sizeTys288 PRE_first_tail_x15_r0_body.sizeArgs288).run PRE_first_tail_x15_r0_body.S974 =
  some (some PRE_first_tail_x15_r0_body.sizeAs288, PRE_first_tail_x15_r0_body.sizeS0288)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA288 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0288 PRE_first_tail_x15_r0_body.s974.ffi PRE_first_tail_x15_r0_body.sizeAs288 = true
/-- Bridge 289's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys289 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s977 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs289 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s977 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA289 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s977 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys289, PRE_first_tail_x15_r0_body.sizeArgs289)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA289 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s977 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA289 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA289 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA289 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA289 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec289 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s977 PRE_first_tail_x15_r0_body.sizeTys289 PRE_first_tail_x15_r0_body.sizeArgs289).run PRE_first_tail_x15_r0_body.S977
noncomputable def PRE_first_tail_x15_r0_body.sizeAs289 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec289 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0289 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec289 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S977
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA289 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s977 PRE_first_tail_x15_r0_body.sizeTys289 PRE_first_tail_x15_r0_body.sizeArgs289).run PRE_first_tail_x15_r0_body.S977 =
  some (some PRE_first_tail_x15_r0_body.sizeAs289, PRE_first_tail_x15_r0_body.sizeS0289)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA289 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0289 PRE_first_tail_x15_r0_body.s977.ffi PRE_first_tail_x15_r0_body.sizeAs289 = true
/-- Bridge 290's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys290 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s980 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs290 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s980 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA290 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s980 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys290, PRE_first_tail_x15_r0_body.sizeArgs290)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA290 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s980 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA290 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA290 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA290 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA290 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec290 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s980 PRE_first_tail_x15_r0_body.sizeTys290 PRE_first_tail_x15_r0_body.sizeArgs290).run PRE_first_tail_x15_r0_body.S980
noncomputable def PRE_first_tail_x15_r0_body.sizeAs290 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec290 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0290 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec290 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S980
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA290 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s980 PRE_first_tail_x15_r0_body.sizeTys290 PRE_first_tail_x15_r0_body.sizeArgs290).run PRE_first_tail_x15_r0_body.S980 =
  some (some PRE_first_tail_x15_r0_body.sizeAs290, PRE_first_tail_x15_r0_body.sizeS0290)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA290 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0290 PRE_first_tail_x15_r0_body.s980.ffi PRE_first_tail_x15_r0_body.sizeAs290 = true
/-- Bridge 291's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys291 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s983 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs291 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s983 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA291 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s983 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys291, PRE_first_tail_x15_r0_body.sizeArgs291)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA291 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s983 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA291 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA291 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA291 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA291 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec291 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s983 PRE_first_tail_x15_r0_body.sizeTys291 PRE_first_tail_x15_r0_body.sizeArgs291).run PRE_first_tail_x15_r0_body.S983
noncomputable def PRE_first_tail_x15_r0_body.sizeAs291 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec291 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0291 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec291 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S983
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA291 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s983 PRE_first_tail_x15_r0_body.sizeTys291 PRE_first_tail_x15_r0_body.sizeArgs291).run PRE_first_tail_x15_r0_body.S983 =
  some (some PRE_first_tail_x15_r0_body.sizeAs291, PRE_first_tail_x15_r0_body.sizeS0291)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA291 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0291 PRE_first_tail_x15_r0_body.s983.ffi PRE_first_tail_x15_r0_body.sizeAs291 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA292 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s986 "recurWindow" none = true
/-- Bridge 293's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys293 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s990 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs293 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s990 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA293 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s990 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys293, PRE_first_tail_x15_r0_body.sizeArgs293)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA293 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s990 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA293 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA293 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA293 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA293 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec293 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s990 PRE_first_tail_x15_r0_body.sizeTys293 PRE_first_tail_x15_r0_body.sizeArgs293).run PRE_first_tail_x15_r0_body.S990
noncomputable def PRE_first_tail_x15_r0_body.sizeAs293 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec293 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0293 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec293 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S990
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA293 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s990 PRE_first_tail_x15_r0_body.sizeTys293 PRE_first_tail_x15_r0_body.sizeArgs293).run PRE_first_tail_x15_r0_body.S990 =
  some (some PRE_first_tail_x15_r0_body.sizeAs293, PRE_first_tail_x15_r0_body.sizeS0293)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA293 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0293 PRE_first_tail_x15_r0_body.s990.ffi PRE_first_tail_x15_r0_body.sizeAs293 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA294 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s993 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA295 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s997 "plan" none = true
/-- Bridge 296's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys296 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1001 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs296 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1001 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA296 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1001 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys296, PRE_first_tail_x15_r0_body.sizeArgs296)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA296 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1001 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA296 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA296 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA296 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA296 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec296 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1001 PRE_first_tail_x15_r0_body.sizeTys296 PRE_first_tail_x15_r0_body.sizeArgs296).run PRE_first_tail_x15_r0_body.S1001
noncomputable def PRE_first_tail_x15_r0_body.sizeAs296 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec296 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0296 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec296 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1001
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA296 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1001 PRE_first_tail_x15_r0_body.sizeTys296 PRE_first_tail_x15_r0_body.sizeArgs296).run PRE_first_tail_x15_r0_body.S1001 =
  some (some PRE_first_tail_x15_r0_body.sizeAs296, PRE_first_tail_x15_r0_body.sizeS0296)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA296 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0296 PRE_first_tail_x15_r0_body.s1001.ffi PRE_first_tail_x15_r0_body.sizeAs296 = true
/-- Bridge 297's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys297 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1004 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs297 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1004 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA297 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1004 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys297, PRE_first_tail_x15_r0_body.sizeArgs297)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA297 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1004 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA297 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA297 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA297 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA297 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec297 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.sizeTys297 PRE_first_tail_x15_r0_body.sizeArgs297).run PRE_first_tail_x15_r0_body.S1004
noncomputable def PRE_first_tail_x15_r0_body.sizeAs297 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec297 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0297 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec297 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1004
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA297 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.sizeTys297 PRE_first_tail_x15_r0_body.sizeArgs297).run PRE_first_tail_x15_r0_body.S1004 =
  some (some PRE_first_tail_x15_r0_body.sizeAs297, PRE_first_tail_x15_r0_body.sizeS0297)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA297 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0297 PRE_first_tail_x15_r0_body.s1004.ffi PRE_first_tail_x15_r0_body.sizeAs297 = true
/-- Bridge 298's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys298 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1007 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs298 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1007 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA298 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1007 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys298, PRE_first_tail_x15_r0_body.sizeArgs298)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA298 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1007 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA298 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA298 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA298 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA298 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec298 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1007 PRE_first_tail_x15_r0_body.sizeTys298 PRE_first_tail_x15_r0_body.sizeArgs298).run PRE_first_tail_x15_r0_body.S1007
noncomputable def PRE_first_tail_x15_r0_body.sizeAs298 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec298 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0298 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec298 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1007
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA298 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1007 PRE_first_tail_x15_r0_body.sizeTys298 PRE_first_tail_x15_r0_body.sizeArgs298).run PRE_first_tail_x15_r0_body.S1007 =
  some (some PRE_first_tail_x15_r0_body.sizeAs298, PRE_first_tail_x15_r0_body.sizeS0298)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA298 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0298 PRE_first_tail_x15_r0_body.s1007.ffi PRE_first_tail_x15_r0_body.sizeAs298 = true
/-- Bridge 299's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys299 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1010 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs299 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1010 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA299 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1010 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys299, PRE_first_tail_x15_r0_body.sizeArgs299)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA299 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1010 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA299 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA299 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA299 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA299 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec299 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1010 PRE_first_tail_x15_r0_body.sizeTys299 PRE_first_tail_x15_r0_body.sizeArgs299).run PRE_first_tail_x15_r0_body.S1010
noncomputable def PRE_first_tail_x15_r0_body.sizeAs299 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec299 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0299 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec299 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1010
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA299 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1010 PRE_first_tail_x15_r0_body.sizeTys299 PRE_first_tail_x15_r0_body.sizeArgs299).run PRE_first_tail_x15_r0_body.S1010 =
  some (some PRE_first_tail_x15_r0_body.sizeAs299, PRE_first_tail_x15_r0_body.sizeS0299)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA299 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0299 PRE_first_tail_x15_r0_body.s1010.ffi PRE_first_tail_x15_r0_body.sizeAs299 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA300 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1013 "recurWindow" none = true
/-- Bridge 301's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys301 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1017 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs301 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1017 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA301 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1017 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys301, PRE_first_tail_x15_r0_body.sizeArgs301)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA301 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1017 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA301 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA301 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA301 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA301 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec301 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1017 PRE_first_tail_x15_r0_body.sizeTys301 PRE_first_tail_x15_r0_body.sizeArgs301).run PRE_first_tail_x15_r0_body.S1017
noncomputable def PRE_first_tail_x15_r0_body.sizeAs301 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec301 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0301 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec301 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1017
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA301 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1017 PRE_first_tail_x15_r0_body.sizeTys301 PRE_first_tail_x15_r0_body.sizeArgs301).run PRE_first_tail_x15_r0_body.S1017 =
  some (some PRE_first_tail_x15_r0_body.sizeAs301, PRE_first_tail_x15_r0_body.sizeS0301)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA301 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0301 PRE_first_tail_x15_r0_body.s1017.ffi PRE_first_tail_x15_r0_body.sizeAs301 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA302 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1020 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA303 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1024 "plan" none = true
/-- Bridge 304's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys304 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1028 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs304 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1028 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA304 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1028 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys304, PRE_first_tail_x15_r0_body.sizeArgs304)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA304 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1028 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA304 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA304 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA304 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA304 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec304 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1028 PRE_first_tail_x15_r0_body.sizeTys304 PRE_first_tail_x15_r0_body.sizeArgs304).run PRE_first_tail_x15_r0_body.S1028
noncomputable def PRE_first_tail_x15_r0_body.sizeAs304 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec304 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0304 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec304 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1028
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA304 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1028 PRE_first_tail_x15_r0_body.sizeTys304 PRE_first_tail_x15_r0_body.sizeArgs304).run PRE_first_tail_x15_r0_body.S1028 =
  some (some PRE_first_tail_x15_r0_body.sizeAs304, PRE_first_tail_x15_r0_body.sizeS0304)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA304 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0304 PRE_first_tail_x15_r0_body.s1028.ffi PRE_first_tail_x15_r0_body.sizeAs304 = true
/-- Bridge 305's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys305 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1031 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs305 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1031 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA305 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1031 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys305, PRE_first_tail_x15_r0_body.sizeArgs305)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA305 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1031 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA305 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA305 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA305 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA305 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec305 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1031 PRE_first_tail_x15_r0_body.sizeTys305 PRE_first_tail_x15_r0_body.sizeArgs305).run PRE_first_tail_x15_r0_body.S1031
noncomputable def PRE_first_tail_x15_r0_body.sizeAs305 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec305 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0305 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec305 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1031
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA305 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1031 PRE_first_tail_x15_r0_body.sizeTys305 PRE_first_tail_x15_r0_body.sizeArgs305).run PRE_first_tail_x15_r0_body.S1031 =
  some (some PRE_first_tail_x15_r0_body.sizeAs305, PRE_first_tail_x15_r0_body.sizeS0305)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA305 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0305 PRE_first_tail_x15_r0_body.s1031.ffi PRE_first_tail_x15_r0_body.sizeAs305 = true
/-- Bridge 306's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys306 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1034 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs306 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1034 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA306 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1034 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys306, PRE_first_tail_x15_r0_body.sizeArgs306)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA306 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1034 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA306 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA306 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA306 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA306 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec306 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1034 PRE_first_tail_x15_r0_body.sizeTys306 PRE_first_tail_x15_r0_body.sizeArgs306).run PRE_first_tail_x15_r0_body.S1034
noncomputable def PRE_first_tail_x15_r0_body.sizeAs306 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec306 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0306 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec306 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1034
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA306 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1034 PRE_first_tail_x15_r0_body.sizeTys306 PRE_first_tail_x15_r0_body.sizeArgs306).run PRE_first_tail_x15_r0_body.S1034 =
  some (some PRE_first_tail_x15_r0_body.sizeAs306, PRE_first_tail_x15_r0_body.sizeS0306)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA306 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0306 PRE_first_tail_x15_r0_body.s1034.ffi PRE_first_tail_x15_r0_body.sizeAs306 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA307 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1037 "appendWindow" none = true
/-- Bridge 308's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys308 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1041 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs308 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1041 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA308 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1041 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys308, PRE_first_tail_x15_r0_body.sizeArgs308)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA308 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1041 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA308 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA308 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA308 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA308 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec308 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1041 PRE_first_tail_x15_r0_body.sizeTys308 PRE_first_tail_x15_r0_body.sizeArgs308).run PRE_first_tail_x15_r0_body.S1041
noncomputable def PRE_first_tail_x15_r0_body.sizeAs308 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec308 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0308 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec308 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1041
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA308 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1041 PRE_first_tail_x15_r0_body.sizeTys308 PRE_first_tail_x15_r0_body.sizeArgs308).run PRE_first_tail_x15_r0_body.S1041 =
  some (some PRE_first_tail_x15_r0_body.sizeAs308, PRE_first_tail_x15_r0_body.sizeS0308)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA308 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0308 PRE_first_tail_x15_r0_body.s1041.ffi PRE_first_tail_x15_r0_body.sizeAs308 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA309 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1044 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA310 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1048 "plan" none = true
/-- Bridge 311's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys311 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1052 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs311 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1052 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA311 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1052 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys311, PRE_first_tail_x15_r0_body.sizeArgs311)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA311 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1052 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA311 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA311 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA311 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA311 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec311 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1052 PRE_first_tail_x15_r0_body.sizeTys311 PRE_first_tail_x15_r0_body.sizeArgs311).run PRE_first_tail_x15_r0_body.S1052
noncomputable def PRE_first_tail_x15_r0_body.sizeAs311 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec311 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0311 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec311 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1052
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA311 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1052 PRE_first_tail_x15_r0_body.sizeTys311 PRE_first_tail_x15_r0_body.sizeArgs311).run PRE_first_tail_x15_r0_body.S1052 =
  some (some PRE_first_tail_x15_r0_body.sizeAs311, PRE_first_tail_x15_r0_body.sizeS0311)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA311 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0311 PRE_first_tail_x15_r0_body.s1052.ffi PRE_first_tail_x15_r0_body.sizeAs311 = true
/-- Bridge 312's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys312 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1055 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs312 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1055 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA312 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1055 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys312, PRE_first_tail_x15_r0_body.sizeArgs312)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA312 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1055 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA312 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA312 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA312 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA312 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec312 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1055 PRE_first_tail_x15_r0_body.sizeTys312 PRE_first_tail_x15_r0_body.sizeArgs312).run PRE_first_tail_x15_r0_body.S1055
noncomputable def PRE_first_tail_x15_r0_body.sizeAs312 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec312 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0312 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec312 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1055
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA312 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1055 PRE_first_tail_x15_r0_body.sizeTys312 PRE_first_tail_x15_r0_body.sizeArgs312).run PRE_first_tail_x15_r0_body.S1055 =
  some (some PRE_first_tail_x15_r0_body.sizeAs312, PRE_first_tail_x15_r0_body.sizeS0312)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA312 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0312 PRE_first_tail_x15_r0_body.s1055.ffi PRE_first_tail_x15_r0_body.sizeAs312 = true
/-- Bridge 313's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys313 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1058 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs313 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1058 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA313 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1058 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys313, PRE_first_tail_x15_r0_body.sizeArgs313)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA313 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1058 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA313 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA313 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA313 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA313 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec313 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1058 PRE_first_tail_x15_r0_body.sizeTys313 PRE_first_tail_x15_r0_body.sizeArgs313).run PRE_first_tail_x15_r0_body.S1058
noncomputable def PRE_first_tail_x15_r0_body.sizeAs313 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec313 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0313 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec313 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1058
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA313 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1058 PRE_first_tail_x15_r0_body.sizeTys313 PRE_first_tail_x15_r0_body.sizeArgs313).run PRE_first_tail_x15_r0_body.S1058 =
  some (some PRE_first_tail_x15_r0_body.sizeAs313, PRE_first_tail_x15_r0_body.sizeS0313)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA313 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0313 PRE_first_tail_x15_r0_body.s1058.ffi PRE_first_tail_x15_r0_body.sizeAs313 = true
/-- Bridge 314's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys314 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1061 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs314 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1061 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA314 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1061 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys314, PRE_first_tail_x15_r0_body.sizeArgs314)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA314 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1061 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA314 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA314 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA314 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA314 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec314 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.sizeTys314 PRE_first_tail_x15_r0_body.sizeArgs314).run PRE_first_tail_x15_r0_body.S1061
noncomputable def PRE_first_tail_x15_r0_body.sizeAs314 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec314 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0314 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec314 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1061
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA314 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.sizeTys314 PRE_first_tail_x15_r0_body.sizeArgs314).run PRE_first_tail_x15_r0_body.S1061 =
  some (some PRE_first_tail_x15_r0_body.sizeAs314, PRE_first_tail_x15_r0_body.sizeS0314)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA314 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0314 PRE_first_tail_x15_r0_body.s1061.ffi PRE_first_tail_x15_r0_body.sizeAs314 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA315 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1064 "recurWindow" none = true
/-- Bridge 316's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys316 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1068 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs316 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1068 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA316 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1068 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys316, PRE_first_tail_x15_r0_body.sizeArgs316)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA316 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1068 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA316 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA316 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA316 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA316 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec316 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1068 PRE_first_tail_x15_r0_body.sizeTys316 PRE_first_tail_x15_r0_body.sizeArgs316).run PRE_first_tail_x15_r0_body.S1068
noncomputable def PRE_first_tail_x15_r0_body.sizeAs316 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec316 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0316 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec316 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1068
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA316 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1068 PRE_first_tail_x15_r0_body.sizeTys316 PRE_first_tail_x15_r0_body.sizeArgs316).run PRE_first_tail_x15_r0_body.S1068 =
  some (some PRE_first_tail_x15_r0_body.sizeAs316, PRE_first_tail_x15_r0_body.sizeS0316)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA316 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0316 PRE_first_tail_x15_r0_body.s1068.ffi PRE_first_tail_x15_r0_body.sizeAs316 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA317 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1071 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA318 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1075 "plan" none = true
/-- Bridge 319's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys319 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1079 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs319 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1079 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA319 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1079 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys319, PRE_first_tail_x15_r0_body.sizeArgs319)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA319 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1079 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA319 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA319 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA319 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA319 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec319 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1079 PRE_first_tail_x15_r0_body.sizeTys319 PRE_first_tail_x15_r0_body.sizeArgs319).run PRE_first_tail_x15_r0_body.S1079
noncomputable def PRE_first_tail_x15_r0_body.sizeAs319 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec319 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0319 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec319 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1079
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA319 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1079 PRE_first_tail_x15_r0_body.sizeTys319 PRE_first_tail_x15_r0_body.sizeArgs319).run PRE_first_tail_x15_r0_body.S1079 =
  some (some PRE_first_tail_x15_r0_body.sizeAs319, PRE_first_tail_x15_r0_body.sizeS0319)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA319 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0319 PRE_first_tail_x15_r0_body.s1079.ffi PRE_first_tail_x15_r0_body.sizeAs319 = true
/-- Bridge 320's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys320 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1082 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs320 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1082 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA320 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1082 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys320, PRE_first_tail_x15_r0_body.sizeArgs320)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA320 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1082 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA320 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA320 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA320 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA320 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec320 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1082 PRE_first_tail_x15_r0_body.sizeTys320 PRE_first_tail_x15_r0_body.sizeArgs320).run PRE_first_tail_x15_r0_body.S1082
noncomputable def PRE_first_tail_x15_r0_body.sizeAs320 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec320 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0320 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec320 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1082
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA320 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1082 PRE_first_tail_x15_r0_body.sizeTys320 PRE_first_tail_x15_r0_body.sizeArgs320).run PRE_first_tail_x15_r0_body.S1082 =
  some (some PRE_first_tail_x15_r0_body.sizeAs320, PRE_first_tail_x15_r0_body.sizeS0320)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA320 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0320 PRE_first_tail_x15_r0_body.s1082.ffi PRE_first_tail_x15_r0_body.sizeAs320 = true
/-- Bridge 321's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys321 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1085 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs321 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1085 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA321 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1085 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys321, PRE_first_tail_x15_r0_body.sizeArgs321)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA321 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1085 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA321 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA321 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA321 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA321 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec321 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1085 PRE_first_tail_x15_r0_body.sizeTys321 PRE_first_tail_x15_r0_body.sizeArgs321).run PRE_first_tail_x15_r0_body.S1085
noncomputable def PRE_first_tail_x15_r0_body.sizeAs321 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec321 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0321 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec321 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1085
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA321 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1085 PRE_first_tail_x15_r0_body.sizeTys321 PRE_first_tail_x15_r0_body.sizeArgs321).run PRE_first_tail_x15_r0_body.S1085 =
  some (some PRE_first_tail_x15_r0_body.sizeAs321, PRE_first_tail_x15_r0_body.sizeS0321)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA321 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0321 PRE_first_tail_x15_r0_body.s1085.ffi PRE_first_tail_x15_r0_body.sizeAs321 = true
/-- Bridge 322's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys322 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1088 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs322 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1088 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA322 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1088 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys322, PRE_first_tail_x15_r0_body.sizeArgs322)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA322 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1088 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA322 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA322 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA322 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA322 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec322 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1088 PRE_first_tail_x15_r0_body.sizeTys322 PRE_first_tail_x15_r0_body.sizeArgs322).run PRE_first_tail_x15_r0_body.S1088
noncomputable def PRE_first_tail_x15_r0_body.sizeAs322 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec322 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0322 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec322 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1088
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA322 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1088 PRE_first_tail_x15_r0_body.sizeTys322 PRE_first_tail_x15_r0_body.sizeArgs322).run PRE_first_tail_x15_r0_body.S1088 =
  some (some PRE_first_tail_x15_r0_body.sizeAs322, PRE_first_tail_x15_r0_body.sizeS0322)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA322 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0322 PRE_first_tail_x15_r0_body.s1088.ffi PRE_first_tail_x15_r0_body.sizeAs322 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA323 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1091 "recurWindow" none = true
/-- Bridge 324's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys324 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1095 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs324 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1095 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA324 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1095 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys324, PRE_first_tail_x15_r0_body.sizeArgs324)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA324 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1095 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA324 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA324 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA324 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA324 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec324 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1095 PRE_first_tail_x15_r0_body.sizeTys324 PRE_first_tail_x15_r0_body.sizeArgs324).run PRE_first_tail_x15_r0_body.S1095
noncomputable def PRE_first_tail_x15_r0_body.sizeAs324 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec324 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0324 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec324 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1095
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA324 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1095 PRE_first_tail_x15_r0_body.sizeTys324 PRE_first_tail_x15_r0_body.sizeArgs324).run PRE_first_tail_x15_r0_body.S1095 =
  some (some PRE_first_tail_x15_r0_body.sizeAs324, PRE_first_tail_x15_r0_body.sizeS0324)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA324 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0324 PRE_first_tail_x15_r0_body.s1095.ffi PRE_first_tail_x15_r0_body.sizeAs324 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA325 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1098 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA326 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1102 "plan" none = true
/-- Bridge 327's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys327 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1106 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs327 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1106 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA327 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1106 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys327, PRE_first_tail_x15_r0_body.sizeArgs327)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA327 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1106 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA327 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA327 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA327 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA327 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec327 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1106 PRE_first_tail_x15_r0_body.sizeTys327 PRE_first_tail_x15_r0_body.sizeArgs327).run PRE_first_tail_x15_r0_body.S1106
noncomputable def PRE_first_tail_x15_r0_body.sizeAs327 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec327 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0327 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec327 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1106
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA327 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1106 PRE_first_tail_x15_r0_body.sizeTys327 PRE_first_tail_x15_r0_body.sizeArgs327).run PRE_first_tail_x15_r0_body.S1106 =
  some (some PRE_first_tail_x15_r0_body.sizeAs327, PRE_first_tail_x15_r0_body.sizeS0327)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA327 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0327 PRE_first_tail_x15_r0_body.s1106.ffi PRE_first_tail_x15_r0_body.sizeAs327 = true
/-- Bridge 328's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys328 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1109 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs328 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1109 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA328 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1109 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys328, PRE_first_tail_x15_r0_body.sizeArgs328)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA328 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1109 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA328 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA328 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA328 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA328 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec328 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1109 PRE_first_tail_x15_r0_body.sizeTys328 PRE_first_tail_x15_r0_body.sizeArgs328).run PRE_first_tail_x15_r0_body.S1109
noncomputable def PRE_first_tail_x15_r0_body.sizeAs328 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec328 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0328 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec328 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1109
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA328 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1109 PRE_first_tail_x15_r0_body.sizeTys328 PRE_first_tail_x15_r0_body.sizeArgs328).run PRE_first_tail_x15_r0_body.S1109 =
  some (some PRE_first_tail_x15_r0_body.sizeAs328, PRE_first_tail_x15_r0_body.sizeS0328)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA328 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0328 PRE_first_tail_x15_r0_body.s1109.ffi PRE_first_tail_x15_r0_body.sizeAs328 = true
/-- Bridge 329's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys329 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1112 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs329 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1112 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA329 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1112 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys329, PRE_first_tail_x15_r0_body.sizeArgs329)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA329 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1112 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA329 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA329 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA329 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA329 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec329 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1112 PRE_first_tail_x15_r0_body.sizeTys329 PRE_first_tail_x15_r0_body.sizeArgs329).run PRE_first_tail_x15_r0_body.S1112
noncomputable def PRE_first_tail_x15_r0_body.sizeAs329 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec329 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0329 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec329 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1112
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA329 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1112 PRE_first_tail_x15_r0_body.sizeTys329 PRE_first_tail_x15_r0_body.sizeArgs329).run PRE_first_tail_x15_r0_body.S1112 =
  some (some PRE_first_tail_x15_r0_body.sizeAs329, PRE_first_tail_x15_r0_body.sizeS0329)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA329 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0329 PRE_first_tail_x15_r0_body.s1112.ffi PRE_first_tail_x15_r0_body.sizeAs329 = true
/-- Bridge 330's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys330 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1115 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs330 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1115 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA330 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1115 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys330, PRE_first_tail_x15_r0_body.sizeArgs330)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA330 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1115 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA330 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA330 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA330 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA330 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec330 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1115 PRE_first_tail_x15_r0_body.sizeTys330 PRE_first_tail_x15_r0_body.sizeArgs330).run PRE_first_tail_x15_r0_body.S1115
noncomputable def PRE_first_tail_x15_r0_body.sizeAs330 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec330 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0330 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec330 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1115
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA330 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1115 PRE_first_tail_x15_r0_body.sizeTys330 PRE_first_tail_x15_r0_body.sizeArgs330).run PRE_first_tail_x15_r0_body.S1115 =
  some (some PRE_first_tail_x15_r0_body.sizeAs330, PRE_first_tail_x15_r0_body.sizeS0330)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA330 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0330 PRE_first_tail_x15_r0_body.s1115.ffi PRE_first_tail_x15_r0_body.sizeAs330 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA331 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1118 "recurWindow" none = true
/-- Bridge 332's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys332 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1122 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs332 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1122 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA332 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1122 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys332, PRE_first_tail_x15_r0_body.sizeArgs332)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA332 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1122 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA332 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA332 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA332 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA332 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec332 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1122 PRE_first_tail_x15_r0_body.sizeTys332 PRE_first_tail_x15_r0_body.sizeArgs332).run PRE_first_tail_x15_r0_body.S1122
noncomputable def PRE_first_tail_x15_r0_body.sizeAs332 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec332 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0332 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec332 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1122
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA332 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1122 PRE_first_tail_x15_r0_body.sizeTys332 PRE_first_tail_x15_r0_body.sizeArgs332).run PRE_first_tail_x15_r0_body.S1122 =
  some (some PRE_first_tail_x15_r0_body.sizeAs332, PRE_first_tail_x15_r0_body.sizeS0332)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA332 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0332 PRE_first_tail_x15_r0_body.s1122.ffi PRE_first_tail_x15_r0_body.sizeAs332 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA333 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1125 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA334 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1129 "plan" none = true
/-- Bridge 335's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys335 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1133 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs335 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1133 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA335 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1133 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys335, PRE_first_tail_x15_r0_body.sizeArgs335)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA335 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1133 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA335 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA335 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA335 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA335 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec335 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1133 PRE_first_tail_x15_r0_body.sizeTys335 PRE_first_tail_x15_r0_body.sizeArgs335).run PRE_first_tail_x15_r0_body.S1133
noncomputable def PRE_first_tail_x15_r0_body.sizeAs335 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec335 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0335 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec335 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1133
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA335 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1133 PRE_first_tail_x15_r0_body.sizeTys335 PRE_first_tail_x15_r0_body.sizeArgs335).run PRE_first_tail_x15_r0_body.S1133 =
  some (some PRE_first_tail_x15_r0_body.sizeAs335, PRE_first_tail_x15_r0_body.sizeS0335)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA335 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0335 PRE_first_tail_x15_r0_body.s1133.ffi PRE_first_tail_x15_r0_body.sizeAs335 = true
/-- Bridge 336's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys336 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1136 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs336 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1136 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA336 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1136 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys336, PRE_first_tail_x15_r0_body.sizeArgs336)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA336 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1136 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA336 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA336 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA336 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA336 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec336 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1136 PRE_first_tail_x15_r0_body.sizeTys336 PRE_first_tail_x15_r0_body.sizeArgs336).run PRE_first_tail_x15_r0_body.S1136
noncomputable def PRE_first_tail_x15_r0_body.sizeAs336 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec336 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0336 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec336 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1136
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA336 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1136 PRE_first_tail_x15_r0_body.sizeTys336 PRE_first_tail_x15_r0_body.sizeArgs336).run PRE_first_tail_x15_r0_body.S1136 =
  some (some PRE_first_tail_x15_r0_body.sizeAs336, PRE_first_tail_x15_r0_body.sizeS0336)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA336 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0336 PRE_first_tail_x15_r0_body.s1136.ffi PRE_first_tail_x15_r0_body.sizeAs336 = true
/-- Bridge 337's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys337 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1139 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs337 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1139 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA337 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1139 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys337, PRE_first_tail_x15_r0_body.sizeArgs337)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA337 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1139 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA337 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA337 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA337 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA337 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec337 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1139 PRE_first_tail_x15_r0_body.sizeTys337 PRE_first_tail_x15_r0_body.sizeArgs337).run PRE_first_tail_x15_r0_body.S1139
noncomputable def PRE_first_tail_x15_r0_body.sizeAs337 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec337 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0337 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec337 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1139
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA337 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1139 PRE_first_tail_x15_r0_body.sizeTys337 PRE_first_tail_x15_r0_body.sizeArgs337).run PRE_first_tail_x15_r0_body.S1139 =
  some (some PRE_first_tail_x15_r0_body.sizeAs337, PRE_first_tail_x15_r0_body.sizeS0337)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA337 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0337 PRE_first_tail_x15_r0_body.s1139.ffi PRE_first_tail_x15_r0_body.sizeAs337 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA338 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1142 "appendWindow" none = true
/-- Bridge 339's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys339 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1146 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs339 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1146 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA339 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1146 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys339, PRE_first_tail_x15_r0_body.sizeArgs339)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA339 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1146 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA339 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA339 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA339 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA339 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec339 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1146 PRE_first_tail_x15_r0_body.sizeTys339 PRE_first_tail_x15_r0_body.sizeArgs339).run PRE_first_tail_x15_r0_body.S1146
noncomputable def PRE_first_tail_x15_r0_body.sizeAs339 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec339 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0339 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec339 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1146
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA339 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1146 PRE_first_tail_x15_r0_body.sizeTys339 PRE_first_tail_x15_r0_body.sizeArgs339).run PRE_first_tail_x15_r0_body.S1146 =
  some (some PRE_first_tail_x15_r0_body.sizeAs339, PRE_first_tail_x15_r0_body.sizeS0339)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA339 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0339 PRE_first_tail_x15_r0_body.s1146.ffi PRE_first_tail_x15_r0_body.sizeAs339 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA340 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1149 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA341 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1153 "plan" none = true
/-- Bridge 342's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys342 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1157 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs342 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1157 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA342 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1157 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys342, PRE_first_tail_x15_r0_body.sizeArgs342)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA342 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1157 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA342 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA342 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA342 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA342 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec342 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1157 PRE_first_tail_x15_r0_body.sizeTys342 PRE_first_tail_x15_r0_body.sizeArgs342).run PRE_first_tail_x15_r0_body.S1157
noncomputable def PRE_first_tail_x15_r0_body.sizeAs342 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec342 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0342 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec342 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1157
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA342 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1157 PRE_first_tail_x15_r0_body.sizeTys342 PRE_first_tail_x15_r0_body.sizeArgs342).run PRE_first_tail_x15_r0_body.S1157 =
  some (some PRE_first_tail_x15_r0_body.sizeAs342, PRE_first_tail_x15_r0_body.sizeS0342)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA342 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0342 PRE_first_tail_x15_r0_body.s1157.ffi PRE_first_tail_x15_r0_body.sizeAs342 = true
/-- Bridge 343's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys343 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1160 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs343 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1160 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA343 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1160 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys343, PRE_first_tail_x15_r0_body.sizeArgs343)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA343 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1160 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA343 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA343 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA343 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA343 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec343 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1160 PRE_first_tail_x15_r0_body.sizeTys343 PRE_first_tail_x15_r0_body.sizeArgs343).run PRE_first_tail_x15_r0_body.S1160
noncomputable def PRE_first_tail_x15_r0_body.sizeAs343 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec343 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0343 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec343 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1160
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA343 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1160 PRE_first_tail_x15_r0_body.sizeTys343 PRE_first_tail_x15_r0_body.sizeArgs343).run PRE_first_tail_x15_r0_body.S1160 =
  some (some PRE_first_tail_x15_r0_body.sizeAs343, PRE_first_tail_x15_r0_body.sizeS0343)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA343 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0343 PRE_first_tail_x15_r0_body.s1160.ffi PRE_first_tail_x15_r0_body.sizeAs343 = true
/-- Bridge 344's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys344 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1163 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs344 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1163 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA344 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1163 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys344, PRE_first_tail_x15_r0_body.sizeArgs344)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA344 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1163 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA344 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA344 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA344 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA344 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec344 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1163 PRE_first_tail_x15_r0_body.sizeTys344 PRE_first_tail_x15_r0_body.sizeArgs344).run PRE_first_tail_x15_r0_body.S1163
noncomputable def PRE_first_tail_x15_r0_body.sizeAs344 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec344 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0344 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec344 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1163
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA344 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1163 PRE_first_tail_x15_r0_body.sizeTys344 PRE_first_tail_x15_r0_body.sizeArgs344).run PRE_first_tail_x15_r0_body.S1163 =
  some (some PRE_first_tail_x15_r0_body.sizeAs344, PRE_first_tail_x15_r0_body.sizeS0344)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA344 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0344 PRE_first_tail_x15_r0_body.s1163.ffi PRE_first_tail_x15_r0_body.sizeAs344 = true
/-- Bridge 345's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys345 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1166 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs345 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1166 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA345 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1166 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys345, PRE_first_tail_x15_r0_body.sizeArgs345)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA345 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1166 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA345 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA345 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA345 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA345 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec345 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1166 PRE_first_tail_x15_r0_body.sizeTys345 PRE_first_tail_x15_r0_body.sizeArgs345).run PRE_first_tail_x15_r0_body.S1166
noncomputable def PRE_first_tail_x15_r0_body.sizeAs345 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec345 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0345 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec345 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1166
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA345 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1166 PRE_first_tail_x15_r0_body.sizeTys345 PRE_first_tail_x15_r0_body.sizeArgs345).run PRE_first_tail_x15_r0_body.S1166 =
  some (some PRE_first_tail_x15_r0_body.sizeAs345, PRE_first_tail_x15_r0_body.sizeS0345)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA345 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0345 PRE_first_tail_x15_r0_body.s1166.ffi PRE_first_tail_x15_r0_body.sizeAs345 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA346 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1169 "recurWindow" none = true
/-- Bridge 347's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys347 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1173 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs347 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1173 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA347 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1173 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys347, PRE_first_tail_x15_r0_body.sizeArgs347)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA347 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1173 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA347 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA347 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA347 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA347 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec347 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1173 PRE_first_tail_x15_r0_body.sizeTys347 PRE_first_tail_x15_r0_body.sizeArgs347).run PRE_first_tail_x15_r0_body.S1173
noncomputable def PRE_first_tail_x15_r0_body.sizeAs347 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec347 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0347 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec347 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1173
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA347 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1173 PRE_first_tail_x15_r0_body.sizeTys347 PRE_first_tail_x15_r0_body.sizeArgs347).run PRE_first_tail_x15_r0_body.S1173 =
  some (some PRE_first_tail_x15_r0_body.sizeAs347, PRE_first_tail_x15_r0_body.sizeS0347)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA347 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0347 PRE_first_tail_x15_r0_body.s1173.ffi PRE_first_tail_x15_r0_body.sizeAs347 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA348 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1176 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA349 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1180 "plan" none = true
/-- Bridge 350's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys350 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1184 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs350 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1184 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA350 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1184 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys350, PRE_first_tail_x15_r0_body.sizeArgs350)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA350 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1184 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA350 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA350 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA350 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA350 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec350 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1184 PRE_first_tail_x15_r0_body.sizeTys350 PRE_first_tail_x15_r0_body.sizeArgs350).run PRE_first_tail_x15_r0_body.S1184
noncomputable def PRE_first_tail_x15_r0_body.sizeAs350 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec350 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0350 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec350 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1184
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA350 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1184 PRE_first_tail_x15_r0_body.sizeTys350 PRE_first_tail_x15_r0_body.sizeArgs350).run PRE_first_tail_x15_r0_body.S1184 =
  some (some PRE_first_tail_x15_r0_body.sizeAs350, PRE_first_tail_x15_r0_body.sizeS0350)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA350 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0350 PRE_first_tail_x15_r0_body.s1184.ffi PRE_first_tail_x15_r0_body.sizeAs350 = true
/-- Bridge 351's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys351 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1187 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs351 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1187 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA351 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1187 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys351, PRE_first_tail_x15_r0_body.sizeArgs351)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA351 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1187 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA351 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA351 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA351 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA351 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec351 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1187 PRE_first_tail_x15_r0_body.sizeTys351 PRE_first_tail_x15_r0_body.sizeArgs351).run PRE_first_tail_x15_r0_body.S1187
noncomputable def PRE_first_tail_x15_r0_body.sizeAs351 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec351 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0351 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec351 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1187
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA351 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1187 PRE_first_tail_x15_r0_body.sizeTys351 PRE_first_tail_x15_r0_body.sizeArgs351).run PRE_first_tail_x15_r0_body.S1187 =
  some (some PRE_first_tail_x15_r0_body.sizeAs351, PRE_first_tail_x15_r0_body.sizeS0351)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA351 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0351 PRE_first_tail_x15_r0_body.s1187.ffi PRE_first_tail_x15_r0_body.sizeAs351 = true
/-- Bridge 352's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys352 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1190 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs352 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1190 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA352 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1190 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys352, PRE_first_tail_x15_r0_body.sizeArgs352)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA352 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1190 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA352 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA352 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA352 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA352 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec352 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1190 PRE_first_tail_x15_r0_body.sizeTys352 PRE_first_tail_x15_r0_body.sizeArgs352).run PRE_first_tail_x15_r0_body.S1190
noncomputable def PRE_first_tail_x15_r0_body.sizeAs352 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec352 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0352 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec352 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1190
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA352 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1190 PRE_first_tail_x15_r0_body.sizeTys352 PRE_first_tail_x15_r0_body.sizeArgs352).run PRE_first_tail_x15_r0_body.S1190 =
  some (some PRE_first_tail_x15_r0_body.sizeAs352, PRE_first_tail_x15_r0_body.sizeS0352)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA352 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0352 PRE_first_tail_x15_r0_body.s1190.ffi PRE_first_tail_x15_r0_body.sizeAs352 = true
/-- Bridge 353's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys353 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1193 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs353 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1193 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA353 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1193 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys353, PRE_first_tail_x15_r0_body.sizeArgs353)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA353 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1193 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA353 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA353 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA353 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA353 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec353 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1193 PRE_first_tail_x15_r0_body.sizeTys353 PRE_first_tail_x15_r0_body.sizeArgs353).run PRE_first_tail_x15_r0_body.S1193
noncomputable def PRE_first_tail_x15_r0_body.sizeAs353 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec353 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0353 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec353 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1193
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA353 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1193 PRE_first_tail_x15_r0_body.sizeTys353 PRE_first_tail_x15_r0_body.sizeArgs353).run PRE_first_tail_x15_r0_body.S1193 =
  some (some PRE_first_tail_x15_r0_body.sizeAs353, PRE_first_tail_x15_r0_body.sizeS0353)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA353 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0353 PRE_first_tail_x15_r0_body.s1193.ffi PRE_first_tail_x15_r0_body.sizeAs353 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA354 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1196 "recurWindow" none = true
/-- Bridge 355's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys355 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1200 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs355 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1200 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA355 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1200 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys355, PRE_first_tail_x15_r0_body.sizeArgs355)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA355 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1200 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA355 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA355 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA355 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA355 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec355 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1200 PRE_first_tail_x15_r0_body.sizeTys355 PRE_first_tail_x15_r0_body.sizeArgs355).run PRE_first_tail_x15_r0_body.S1200
noncomputable def PRE_first_tail_x15_r0_body.sizeAs355 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec355 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0355 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec355 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1200
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA355 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1200 PRE_first_tail_x15_r0_body.sizeTys355 PRE_first_tail_x15_r0_body.sizeArgs355).run PRE_first_tail_x15_r0_body.S1200 =
  some (some PRE_first_tail_x15_r0_body.sizeAs355, PRE_first_tail_x15_r0_body.sizeS0355)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA355 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0355 PRE_first_tail_x15_r0_body.s1200.ffi PRE_first_tail_x15_r0_body.sizeAs355 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA356 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1203 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA357 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1207 "plan" none = true
/-- Bridge 358's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys358 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1211 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs358 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1211 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA358 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1211 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys358, PRE_first_tail_x15_r0_body.sizeArgs358)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA358 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1211 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA358 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA358 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA358 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA358 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec358 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1211 PRE_first_tail_x15_r0_body.sizeTys358 PRE_first_tail_x15_r0_body.sizeArgs358).run PRE_first_tail_x15_r0_body.S1211
noncomputable def PRE_first_tail_x15_r0_body.sizeAs358 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec358 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0358 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec358 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1211
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA358 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1211 PRE_first_tail_x15_r0_body.sizeTys358 PRE_first_tail_x15_r0_body.sizeArgs358).run PRE_first_tail_x15_r0_body.S1211 =
  some (some PRE_first_tail_x15_r0_body.sizeAs358, PRE_first_tail_x15_r0_body.sizeS0358)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA358 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0358 PRE_first_tail_x15_r0_body.s1211.ffi PRE_first_tail_x15_r0_body.sizeAs358 = true
/-- Bridge 359's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys359 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1214 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs359 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1214 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA359 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1214 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys359, PRE_first_tail_x15_r0_body.sizeArgs359)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA359 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1214 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA359 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA359 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA359 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA359 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec359 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1214 PRE_first_tail_x15_r0_body.sizeTys359 PRE_first_tail_x15_r0_body.sizeArgs359).run PRE_first_tail_x15_r0_body.S1214
noncomputable def PRE_first_tail_x15_r0_body.sizeAs359 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec359 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0359 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec359 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1214
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA359 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1214 PRE_first_tail_x15_r0_body.sizeTys359 PRE_first_tail_x15_r0_body.sizeArgs359).run PRE_first_tail_x15_r0_body.S1214 =
  some (some PRE_first_tail_x15_r0_body.sizeAs359, PRE_first_tail_x15_r0_body.sizeS0359)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA359 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0359 PRE_first_tail_x15_r0_body.s1214.ffi PRE_first_tail_x15_r0_body.sizeAs359 = true
/-- Bridge 360's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys360 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1217 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs360 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1217 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA360 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1217 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys360, PRE_first_tail_x15_r0_body.sizeArgs360)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA360 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1217 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA360 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA360 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA360 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA360 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec360 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1217 PRE_first_tail_x15_r0_body.sizeTys360 PRE_first_tail_x15_r0_body.sizeArgs360).run PRE_first_tail_x15_r0_body.S1217
noncomputable def PRE_first_tail_x15_r0_body.sizeAs360 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec360 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0360 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec360 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1217
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA360 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1217 PRE_first_tail_x15_r0_body.sizeTys360 PRE_first_tail_x15_r0_body.sizeArgs360).run PRE_first_tail_x15_r0_body.S1217 =
  some (some PRE_first_tail_x15_r0_body.sizeAs360, PRE_first_tail_x15_r0_body.sizeS0360)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA360 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0360 PRE_first_tail_x15_r0_body.s1217.ffi PRE_first_tail_x15_r0_body.sizeAs360 = true
/-- Bridge 361's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys361 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1220 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs361 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1220 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA361 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1220 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys361, PRE_first_tail_x15_r0_body.sizeArgs361)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA361 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1220 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA361 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA361 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA361 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA361 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec361 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1220 PRE_first_tail_x15_r0_body.sizeTys361 PRE_first_tail_x15_r0_body.sizeArgs361).run PRE_first_tail_x15_r0_body.S1220
noncomputable def PRE_first_tail_x15_r0_body.sizeAs361 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec361 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0361 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec361 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1220
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA361 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1220 PRE_first_tail_x15_r0_body.sizeTys361 PRE_first_tail_x15_r0_body.sizeArgs361).run PRE_first_tail_x15_r0_body.S1220 =
  some (some PRE_first_tail_x15_r0_body.sizeAs361, PRE_first_tail_x15_r0_body.sizeS0361)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA361 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0361 PRE_first_tail_x15_r0_body.s1220.ffi PRE_first_tail_x15_r0_body.sizeAs361 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA362 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1223 "recurWindow" none = true
/-- Bridge 363's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys363 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1227 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs363 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1227 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA363 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1227 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys363, PRE_first_tail_x15_r0_body.sizeArgs363)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA363 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1227 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA363 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA363 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA363 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA363 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec363 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1227 PRE_first_tail_x15_r0_body.sizeTys363 PRE_first_tail_x15_r0_body.sizeArgs363).run PRE_first_tail_x15_r0_body.S1227
noncomputable def PRE_first_tail_x15_r0_body.sizeAs363 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec363 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0363 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec363 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1227
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA363 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1227 PRE_first_tail_x15_r0_body.sizeTys363 PRE_first_tail_x15_r0_body.sizeArgs363).run PRE_first_tail_x15_r0_body.S1227 =
  some (some PRE_first_tail_x15_r0_body.sizeAs363, PRE_first_tail_x15_r0_body.sizeS0363)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA363 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0363 PRE_first_tail_x15_r0_body.s1227.ffi PRE_first_tail_x15_r0_body.sizeAs363 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA364 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1230 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA365 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1234 "plan" none = true
/-- Bridge 366's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys366 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1238 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs366 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1238 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA366 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1238 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys366, PRE_first_tail_x15_r0_body.sizeArgs366)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA366 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1238 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA366 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA366 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA366 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA366 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec366 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.sizeTys366 PRE_first_tail_x15_r0_body.sizeArgs366).run PRE_first_tail_x15_r0_body.S1238
noncomputable def PRE_first_tail_x15_r0_body.sizeAs366 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec366 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0366 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec366 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1238
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA366 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.sizeTys366 PRE_first_tail_x15_r0_body.sizeArgs366).run PRE_first_tail_x15_r0_body.S1238 =
  some (some PRE_first_tail_x15_r0_body.sizeAs366, PRE_first_tail_x15_r0_body.sizeS0366)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA366 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0366 PRE_first_tail_x15_r0_body.s1238.ffi PRE_first_tail_x15_r0_body.sizeAs366 = true
/-- Bridge 367's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys367 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1241 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs367 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1241 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA367 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1241 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys367, PRE_first_tail_x15_r0_body.sizeArgs367)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA367 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1241 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA367 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA367 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA367 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA367 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec367 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1241 PRE_first_tail_x15_r0_body.sizeTys367 PRE_first_tail_x15_r0_body.sizeArgs367).run PRE_first_tail_x15_r0_body.S1241
noncomputable def PRE_first_tail_x15_r0_body.sizeAs367 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec367 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0367 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec367 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1241
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA367 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1241 PRE_first_tail_x15_r0_body.sizeTys367 PRE_first_tail_x15_r0_body.sizeArgs367).run PRE_first_tail_x15_r0_body.S1241 =
  some (some PRE_first_tail_x15_r0_body.sizeAs367, PRE_first_tail_x15_r0_body.sizeS0367)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA367 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0367 PRE_first_tail_x15_r0_body.s1241.ffi PRE_first_tail_x15_r0_body.sizeAs367 = true
/-- Bridge 368's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys368 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1244 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs368 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1244 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA368 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1244 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys368, PRE_first_tail_x15_r0_body.sizeArgs368)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA368 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1244 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA368 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA368 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA368 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA368 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec368 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1244 PRE_first_tail_x15_r0_body.sizeTys368 PRE_first_tail_x15_r0_body.sizeArgs368).run PRE_first_tail_x15_r0_body.S1244
noncomputable def PRE_first_tail_x15_r0_body.sizeAs368 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec368 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0368 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec368 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1244
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA368 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1244 PRE_first_tail_x15_r0_body.sizeTys368 PRE_first_tail_x15_r0_body.sizeArgs368).run PRE_first_tail_x15_r0_body.S1244 =
  some (some PRE_first_tail_x15_r0_body.sizeAs368, PRE_first_tail_x15_r0_body.sizeS0368)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA368 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0368 PRE_first_tail_x15_r0_body.s1244.ffi PRE_first_tail_x15_r0_body.sizeAs368 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA369 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1247 "appendWindow" none = true
/-- Bridge 370's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys370 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1251 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs370 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1251 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA370 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1251 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys370, PRE_first_tail_x15_r0_body.sizeArgs370)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA370 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1251 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA370 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA370 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA370 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA370 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec370 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1251 PRE_first_tail_x15_r0_body.sizeTys370 PRE_first_tail_x15_r0_body.sizeArgs370).run PRE_first_tail_x15_r0_body.S1251
noncomputable def PRE_first_tail_x15_r0_body.sizeAs370 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec370 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0370 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec370 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1251
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA370 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1251 PRE_first_tail_x15_r0_body.sizeTys370 PRE_first_tail_x15_r0_body.sizeArgs370).run PRE_first_tail_x15_r0_body.S1251 =
  some (some PRE_first_tail_x15_r0_body.sizeAs370, PRE_first_tail_x15_r0_body.sizeS0370)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA370 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0370 PRE_first_tail_x15_r0_body.s1251.ffi PRE_first_tail_x15_r0_body.sizeAs370 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA371 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1254 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA372 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1258 "plan" none = true
/-- Bridge 373's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys373 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1262 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs373 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1262 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA373 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1262 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys373, PRE_first_tail_x15_r0_body.sizeArgs373)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA373 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1262 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA373 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA373 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA373 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA373 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec373 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.sizeTys373 PRE_first_tail_x15_r0_body.sizeArgs373).run PRE_first_tail_x15_r0_body.S1262
noncomputable def PRE_first_tail_x15_r0_body.sizeAs373 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec373 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0373 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec373 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1262
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA373 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.sizeTys373 PRE_first_tail_x15_r0_body.sizeArgs373).run PRE_first_tail_x15_r0_body.S1262 =
  some (some PRE_first_tail_x15_r0_body.sizeAs373, PRE_first_tail_x15_r0_body.sizeS0373)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA373 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0373 PRE_first_tail_x15_r0_body.s1262.ffi PRE_first_tail_x15_r0_body.sizeAs373 = true
/-- Bridge 374's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys374 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1265 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs374 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1265 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA374 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1265 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys374, PRE_first_tail_x15_r0_body.sizeArgs374)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA374 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1265 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA374 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA374 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA374 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA374 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec374 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1265 PRE_first_tail_x15_r0_body.sizeTys374 PRE_first_tail_x15_r0_body.sizeArgs374).run PRE_first_tail_x15_r0_body.S1265
noncomputable def PRE_first_tail_x15_r0_body.sizeAs374 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec374 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0374 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec374 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1265
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA374 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1265 PRE_first_tail_x15_r0_body.sizeTys374 PRE_first_tail_x15_r0_body.sizeArgs374).run PRE_first_tail_x15_r0_body.S1265 =
  some (some PRE_first_tail_x15_r0_body.sizeAs374, PRE_first_tail_x15_r0_body.sizeS0374)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA374 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0374 PRE_first_tail_x15_r0_body.s1265.ffi PRE_first_tail_x15_r0_body.sizeAs374 = true
/-- Bridge 375's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys375 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1268 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs375 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1268 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA375 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1268 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys375, PRE_first_tail_x15_r0_body.sizeArgs375)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA375 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1268 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA375 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA375 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA375 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA375 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec375 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1268 PRE_first_tail_x15_r0_body.sizeTys375 PRE_first_tail_x15_r0_body.sizeArgs375).run PRE_first_tail_x15_r0_body.S1268
noncomputable def PRE_first_tail_x15_r0_body.sizeAs375 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec375 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0375 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec375 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1268
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA375 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1268 PRE_first_tail_x15_r0_body.sizeTys375 PRE_first_tail_x15_r0_body.sizeArgs375).run PRE_first_tail_x15_r0_body.S1268 =
  some (some PRE_first_tail_x15_r0_body.sizeAs375, PRE_first_tail_x15_r0_body.sizeS0375)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA375 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0375 PRE_first_tail_x15_r0_body.s1268.ffi PRE_first_tail_x15_r0_body.sizeAs375 = true
/-- Bridge 376's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys376 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1271 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs376 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1271 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA376 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1271 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys376, PRE_first_tail_x15_r0_body.sizeArgs376)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA376 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1271 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA376 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA376 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA376 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA376 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec376 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1271 PRE_first_tail_x15_r0_body.sizeTys376 PRE_first_tail_x15_r0_body.sizeArgs376).run PRE_first_tail_x15_r0_body.S1271
noncomputable def PRE_first_tail_x15_r0_body.sizeAs376 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec376 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0376 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec376 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1271
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA376 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1271 PRE_first_tail_x15_r0_body.sizeTys376 PRE_first_tail_x15_r0_body.sizeArgs376).run PRE_first_tail_x15_r0_body.S1271 =
  some (some PRE_first_tail_x15_r0_body.sizeAs376, PRE_first_tail_x15_r0_body.sizeS0376)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA376 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0376 PRE_first_tail_x15_r0_body.s1271.ffi PRE_first_tail_x15_r0_body.sizeAs376 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA377 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1274 "recurWindow" none = true
/-- Bridge 378's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys378 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1278 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs378 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1278 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA378 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1278 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys378, PRE_first_tail_x15_r0_body.sizeArgs378)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA378 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1278 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA378 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA378 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA378 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA378 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec378 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1278 PRE_first_tail_x15_r0_body.sizeTys378 PRE_first_tail_x15_r0_body.sizeArgs378).run PRE_first_tail_x15_r0_body.S1278
noncomputable def PRE_first_tail_x15_r0_body.sizeAs378 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec378 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0378 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec378 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1278
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA378 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1278 PRE_first_tail_x15_r0_body.sizeTys378 PRE_first_tail_x15_r0_body.sizeArgs378).run PRE_first_tail_x15_r0_body.S1278 =
  some (some PRE_first_tail_x15_r0_body.sizeAs378, PRE_first_tail_x15_r0_body.sizeS0378)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA378 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0378 PRE_first_tail_x15_r0_body.s1278.ffi PRE_first_tail_x15_r0_body.sizeAs378 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA379 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1281 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA380 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1285 "plan" none = true
/-- Bridge 381's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys381 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1289 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs381 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1289 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA381 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1289 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys381, PRE_first_tail_x15_r0_body.sizeArgs381)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA381 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1289 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA381 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA381 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA381 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA381 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec381 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1289 PRE_first_tail_x15_r0_body.sizeTys381 PRE_first_tail_x15_r0_body.sizeArgs381).run PRE_first_tail_x15_r0_body.S1289
noncomputable def PRE_first_tail_x15_r0_body.sizeAs381 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec381 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0381 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec381 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1289
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA381 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1289 PRE_first_tail_x15_r0_body.sizeTys381 PRE_first_tail_x15_r0_body.sizeArgs381).run PRE_first_tail_x15_r0_body.S1289 =
  some (some PRE_first_tail_x15_r0_body.sizeAs381, PRE_first_tail_x15_r0_body.sizeS0381)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA381 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0381 PRE_first_tail_x15_r0_body.s1289.ffi PRE_first_tail_x15_r0_body.sizeAs381 = true
/-- Bridge 382's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys382 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1292 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs382 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1292 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA382 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1292 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys382, PRE_first_tail_x15_r0_body.sizeArgs382)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA382 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1292 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA382 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA382 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA382 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA382 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec382 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1292 PRE_first_tail_x15_r0_body.sizeTys382 PRE_first_tail_x15_r0_body.sizeArgs382).run PRE_first_tail_x15_r0_body.S1292
noncomputable def PRE_first_tail_x15_r0_body.sizeAs382 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec382 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0382 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec382 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1292
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA382 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1292 PRE_first_tail_x15_r0_body.sizeTys382 PRE_first_tail_x15_r0_body.sizeArgs382).run PRE_first_tail_x15_r0_body.S1292 =
  some (some PRE_first_tail_x15_r0_body.sizeAs382, PRE_first_tail_x15_r0_body.sizeS0382)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA382 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0382 PRE_first_tail_x15_r0_body.s1292.ffi PRE_first_tail_x15_r0_body.sizeAs382 = true
/-- Bridge 383's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys383 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1295 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs383 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1295 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA383 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1295 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys383, PRE_first_tail_x15_r0_body.sizeArgs383)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA383 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1295 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA383 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA383 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA383 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA383 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec383 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.sizeTys383 PRE_first_tail_x15_r0_body.sizeArgs383).run PRE_first_tail_x15_r0_body.S1295
noncomputable def PRE_first_tail_x15_r0_body.sizeAs383 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec383 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0383 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec383 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1295
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA383 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.sizeTys383 PRE_first_tail_x15_r0_body.sizeArgs383).run PRE_first_tail_x15_r0_body.S1295 =
  some (some PRE_first_tail_x15_r0_body.sizeAs383, PRE_first_tail_x15_r0_body.sizeS0383)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA383 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0383 PRE_first_tail_x15_r0_body.s1295.ffi PRE_first_tail_x15_r0_body.sizeAs383 = true
/-- Bridge 384's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys384 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1298 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs384 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1298 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA384 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1298 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys384, PRE_first_tail_x15_r0_body.sizeArgs384)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA384 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1298 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA384 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA384 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA384 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA384 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec384 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1298 PRE_first_tail_x15_r0_body.sizeTys384 PRE_first_tail_x15_r0_body.sizeArgs384).run PRE_first_tail_x15_r0_body.S1298
noncomputable def PRE_first_tail_x15_r0_body.sizeAs384 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec384 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0384 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec384 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1298
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA384 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1298 PRE_first_tail_x15_r0_body.sizeTys384 PRE_first_tail_x15_r0_body.sizeArgs384).run PRE_first_tail_x15_r0_body.S1298 =
  some (some PRE_first_tail_x15_r0_body.sizeAs384, PRE_first_tail_x15_r0_body.sizeS0384)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA384 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0384 PRE_first_tail_x15_r0_body.s1298.ffi PRE_first_tail_x15_r0_body.sizeAs384 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA385 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1301 "recurWindow" none = true
/-- Bridge 386's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys386 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1305 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs386 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1305 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA386 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1305 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys386, PRE_first_tail_x15_r0_body.sizeArgs386)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA386 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1305 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA386 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA386 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA386 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA386 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec386 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1305 PRE_first_tail_x15_r0_body.sizeTys386 PRE_first_tail_x15_r0_body.sizeArgs386).run PRE_first_tail_x15_r0_body.S1305
noncomputable def PRE_first_tail_x15_r0_body.sizeAs386 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec386 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0386 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec386 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1305
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA386 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1305 PRE_first_tail_x15_r0_body.sizeTys386 PRE_first_tail_x15_r0_body.sizeArgs386).run PRE_first_tail_x15_r0_body.S1305 =
  some (some PRE_first_tail_x15_r0_body.sizeAs386, PRE_first_tail_x15_r0_body.sizeS0386)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA386 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0386 PRE_first_tail_x15_r0_body.s1305.ffi PRE_first_tail_x15_r0_body.sizeAs386 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA387 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1308 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA388 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1312 "plan" none = true
/-- Bridge 389's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys389 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1316 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs389 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1316 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA389 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1316 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys389, PRE_first_tail_x15_r0_body.sizeArgs389)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA389 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1316 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA389 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA389 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA389 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA389 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec389 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1316 PRE_first_tail_x15_r0_body.sizeTys389 PRE_first_tail_x15_r0_body.sizeArgs389).run PRE_first_tail_x15_r0_body.S1316
noncomputable def PRE_first_tail_x15_r0_body.sizeAs389 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec389 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0389 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec389 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1316
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA389 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1316 PRE_first_tail_x15_r0_body.sizeTys389 PRE_first_tail_x15_r0_body.sizeArgs389).run PRE_first_tail_x15_r0_body.S1316 =
  some (some PRE_first_tail_x15_r0_body.sizeAs389, PRE_first_tail_x15_r0_body.sizeS0389)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA389 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0389 PRE_first_tail_x15_r0_body.s1316.ffi PRE_first_tail_x15_r0_body.sizeAs389 = true
/-- Bridge 390's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys390 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1319 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs390 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1319 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA390 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1319 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys390, PRE_first_tail_x15_r0_body.sizeArgs390)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA390 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1319 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA390 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA390 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA390 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA390 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec390 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1319 PRE_first_tail_x15_r0_body.sizeTys390 PRE_first_tail_x15_r0_body.sizeArgs390).run PRE_first_tail_x15_r0_body.S1319
noncomputable def PRE_first_tail_x15_r0_body.sizeAs390 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec390 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0390 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec390 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1319
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA390 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1319 PRE_first_tail_x15_r0_body.sizeTys390 PRE_first_tail_x15_r0_body.sizeArgs390).run PRE_first_tail_x15_r0_body.S1319 =
  some (some PRE_first_tail_x15_r0_body.sizeAs390, PRE_first_tail_x15_r0_body.sizeS0390)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA390 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0390 PRE_first_tail_x15_r0_body.s1319.ffi PRE_first_tail_x15_r0_body.sizeAs390 = true
/-- Bridge 391's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys391 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1322 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs391 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1322 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA391 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1322 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys391, PRE_first_tail_x15_r0_body.sizeArgs391)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA391 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1322 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA391 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA391 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA391 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA391 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec391 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1322 PRE_first_tail_x15_r0_body.sizeTys391 PRE_first_tail_x15_r0_body.sizeArgs391).run PRE_first_tail_x15_r0_body.S1322
noncomputable def PRE_first_tail_x15_r0_body.sizeAs391 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec391 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0391 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec391 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1322
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA391 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1322 PRE_first_tail_x15_r0_body.sizeTys391 PRE_first_tail_x15_r0_body.sizeArgs391).run PRE_first_tail_x15_r0_body.S1322 =
  some (some PRE_first_tail_x15_r0_body.sizeAs391, PRE_first_tail_x15_r0_body.sizeS0391)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA391 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0391 PRE_first_tail_x15_r0_body.s1322.ffi PRE_first_tail_x15_r0_body.sizeAs391 = true
/-- Bridge 392's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys392 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1325 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs392 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1325 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA392 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1325 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys392, PRE_first_tail_x15_r0_body.sizeArgs392)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA392 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1325 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA392 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA392 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA392 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA392 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec392 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1325 PRE_first_tail_x15_r0_body.sizeTys392 PRE_first_tail_x15_r0_body.sizeArgs392).run PRE_first_tail_x15_r0_body.S1325
noncomputable def PRE_first_tail_x15_r0_body.sizeAs392 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec392 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0392 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec392 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1325
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA392 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1325 PRE_first_tail_x15_r0_body.sizeTys392 PRE_first_tail_x15_r0_body.sizeArgs392).run PRE_first_tail_x15_r0_body.S1325 =
  some (some PRE_first_tail_x15_r0_body.sizeAs392, PRE_first_tail_x15_r0_body.sizeS0392)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA392 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0392 PRE_first_tail_x15_r0_body.s1325.ffi PRE_first_tail_x15_r0_body.sizeAs392 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA393 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1328 "recurWindow" none = true
/-- Bridge 394's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys394 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1332 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs394 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1332 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA394 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1332 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys394, PRE_first_tail_x15_r0_body.sizeArgs394)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA394 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1332 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA394 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA394 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA394 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA394 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec394 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1332 PRE_first_tail_x15_r0_body.sizeTys394 PRE_first_tail_x15_r0_body.sizeArgs394).run PRE_first_tail_x15_r0_body.S1332
noncomputable def PRE_first_tail_x15_r0_body.sizeAs394 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec394 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0394 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec394 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1332
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA394 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1332 PRE_first_tail_x15_r0_body.sizeTys394 PRE_first_tail_x15_r0_body.sizeArgs394).run PRE_first_tail_x15_r0_body.S1332 =
  some (some PRE_first_tail_x15_r0_body.sizeAs394, PRE_first_tail_x15_r0_body.sizeS0394)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA394 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0394 PRE_first_tail_x15_r0_body.s1332.ffi PRE_first_tail_x15_r0_body.sizeAs394 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA395 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1335 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA396 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1339 "plan" none = true
/-- Bridge 397's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys397 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1343 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs397 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1343 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA397 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1343 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys397, PRE_first_tail_x15_r0_body.sizeArgs397)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA397 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1343 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA397 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA397 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA397 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA397 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec397 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1343 PRE_first_tail_x15_r0_body.sizeTys397 PRE_first_tail_x15_r0_body.sizeArgs397).run PRE_first_tail_x15_r0_body.S1343
noncomputable def PRE_first_tail_x15_r0_body.sizeAs397 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec397 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0397 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec397 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1343
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA397 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1343 PRE_first_tail_x15_r0_body.sizeTys397 PRE_first_tail_x15_r0_body.sizeArgs397).run PRE_first_tail_x15_r0_body.S1343 =
  some (some PRE_first_tail_x15_r0_body.sizeAs397, PRE_first_tail_x15_r0_body.sizeS0397)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA397 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0397 PRE_first_tail_x15_r0_body.s1343.ffi PRE_first_tail_x15_r0_body.sizeAs397 = true
/-- Bridge 398's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys398 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1346 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs398 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1346 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA398 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1346 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys398, PRE_first_tail_x15_r0_body.sizeArgs398)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA398 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1346 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA398 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA398 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA398 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA398 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec398 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1346 PRE_first_tail_x15_r0_body.sizeTys398 PRE_first_tail_x15_r0_body.sizeArgs398).run PRE_first_tail_x15_r0_body.S1346
noncomputable def PRE_first_tail_x15_r0_body.sizeAs398 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec398 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0398 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec398 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1346
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA398 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1346 PRE_first_tail_x15_r0_body.sizeTys398 PRE_first_tail_x15_r0_body.sizeArgs398).run PRE_first_tail_x15_r0_body.S1346 =
  some (some PRE_first_tail_x15_r0_body.sizeAs398, PRE_first_tail_x15_r0_body.sizeS0398)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA398 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0398 PRE_first_tail_x15_r0_body.s1346.ffi PRE_first_tail_x15_r0_body.sizeAs398 = true
/-- Bridge 399's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys399 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1349 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs399 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1349 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA399 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1349 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys399, PRE_first_tail_x15_r0_body.sizeArgs399)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA399 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1349 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA399 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA399 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA399 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA399 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec399 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.sizeTys399 PRE_first_tail_x15_r0_body.sizeArgs399).run PRE_first_tail_x15_r0_body.S1349
noncomputable def PRE_first_tail_x15_r0_body.sizeAs399 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec399 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0399 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec399 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1349
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA399 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.sizeTys399 PRE_first_tail_x15_r0_body.sizeArgs399).run PRE_first_tail_x15_r0_body.S1349 =
  some (some PRE_first_tail_x15_r0_body.sizeAs399, PRE_first_tail_x15_r0_body.sizeS0399)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA399 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0399 PRE_first_tail_x15_r0_body.s1349.ffi PRE_first_tail_x15_r0_body.sizeAs399 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA400 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1352 "appendWindow" none = true
/-- Bridge 401's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys401 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1356 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs401 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1356 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA401 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1356 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys401, PRE_first_tail_x15_r0_body.sizeArgs401)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA401 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1356 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA401 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA401 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA401 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA401 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec401 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1356 PRE_first_tail_x15_r0_body.sizeTys401 PRE_first_tail_x15_r0_body.sizeArgs401).run PRE_first_tail_x15_r0_body.S1356
noncomputable def PRE_first_tail_x15_r0_body.sizeAs401 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec401 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0401 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec401 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1356
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA401 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1356 PRE_first_tail_x15_r0_body.sizeTys401 PRE_first_tail_x15_r0_body.sizeArgs401).run PRE_first_tail_x15_r0_body.S1356 =
  some (some PRE_first_tail_x15_r0_body.sizeAs401, PRE_first_tail_x15_r0_body.sizeS0401)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA401 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0401 PRE_first_tail_x15_r0_body.s1356.ffi PRE_first_tail_x15_r0_body.sizeAs401 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA402 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1359 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA403 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1363 "plan" none = true
/-- Bridge 404's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys404 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1367 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs404 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1367 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA404 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1367 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys404, PRE_first_tail_x15_r0_body.sizeArgs404)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA404 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1367 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA404 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA404 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA404 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA404 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec404 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1367 PRE_first_tail_x15_r0_body.sizeTys404 PRE_first_tail_x15_r0_body.sizeArgs404).run PRE_first_tail_x15_r0_body.S1367
noncomputable def PRE_first_tail_x15_r0_body.sizeAs404 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec404 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0404 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec404 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1367
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA404 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1367 PRE_first_tail_x15_r0_body.sizeTys404 PRE_first_tail_x15_r0_body.sizeArgs404).run PRE_first_tail_x15_r0_body.S1367 =
  some (some PRE_first_tail_x15_r0_body.sizeAs404, PRE_first_tail_x15_r0_body.sizeS0404)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA404 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0404 PRE_first_tail_x15_r0_body.s1367.ffi PRE_first_tail_x15_r0_body.sizeAs404 = true
/-- Bridge 405's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys405 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1370 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs405 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1370 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA405 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1370 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys405, PRE_first_tail_x15_r0_body.sizeArgs405)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA405 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1370 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA405 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA405 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA405 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA405 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec405 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1370 PRE_first_tail_x15_r0_body.sizeTys405 PRE_first_tail_x15_r0_body.sizeArgs405).run PRE_first_tail_x15_r0_body.S1370
noncomputable def PRE_first_tail_x15_r0_body.sizeAs405 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec405 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0405 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec405 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1370
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA405 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1370 PRE_first_tail_x15_r0_body.sizeTys405 PRE_first_tail_x15_r0_body.sizeArgs405).run PRE_first_tail_x15_r0_body.S1370 =
  some (some PRE_first_tail_x15_r0_body.sizeAs405, PRE_first_tail_x15_r0_body.sizeS0405)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA405 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0405 PRE_first_tail_x15_r0_body.s1370.ffi PRE_first_tail_x15_r0_body.sizeAs405 = true
/-- Bridge 406's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys406 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1373 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs406 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1373 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA406 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1373 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys406, PRE_first_tail_x15_r0_body.sizeArgs406)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA406 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1373 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA406 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA406 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA406 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA406 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec406 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1373 PRE_first_tail_x15_r0_body.sizeTys406 PRE_first_tail_x15_r0_body.sizeArgs406).run PRE_first_tail_x15_r0_body.S1373
noncomputable def PRE_first_tail_x15_r0_body.sizeAs406 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec406 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0406 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec406 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1373
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA406 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1373 PRE_first_tail_x15_r0_body.sizeTys406 PRE_first_tail_x15_r0_body.sizeArgs406).run PRE_first_tail_x15_r0_body.S1373 =
  some (some PRE_first_tail_x15_r0_body.sizeAs406, PRE_first_tail_x15_r0_body.sizeS0406)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA406 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0406 PRE_first_tail_x15_r0_body.s1373.ffi PRE_first_tail_x15_r0_body.sizeAs406 = true
/-- Bridge 407's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys407 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1376 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs407 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1376 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA407 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1376 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys407, PRE_first_tail_x15_r0_body.sizeArgs407)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA407 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1376 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA407 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA407 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA407 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA407 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec407 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1376 PRE_first_tail_x15_r0_body.sizeTys407 PRE_first_tail_x15_r0_body.sizeArgs407).run PRE_first_tail_x15_r0_body.S1376
noncomputable def PRE_first_tail_x15_r0_body.sizeAs407 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec407 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0407 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec407 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1376
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA407 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1376 PRE_first_tail_x15_r0_body.sizeTys407 PRE_first_tail_x15_r0_body.sizeArgs407).run PRE_first_tail_x15_r0_body.S1376 =
  some (some PRE_first_tail_x15_r0_body.sizeAs407, PRE_first_tail_x15_r0_body.sizeS0407)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA407 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0407 PRE_first_tail_x15_r0_body.s1376.ffi PRE_first_tail_x15_r0_body.sizeAs407 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA408 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1379 "recurWindow" none = true
/-- Bridge 409's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys409 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1383 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs409 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1383 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA409 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1383 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys409, PRE_first_tail_x15_r0_body.sizeArgs409)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA409 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1383 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA409 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA409 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA409 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA409 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec409 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1383 PRE_first_tail_x15_r0_body.sizeTys409 PRE_first_tail_x15_r0_body.sizeArgs409).run PRE_first_tail_x15_r0_body.S1383
noncomputable def PRE_first_tail_x15_r0_body.sizeAs409 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec409 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0409 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec409 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1383
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA409 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1383 PRE_first_tail_x15_r0_body.sizeTys409 PRE_first_tail_x15_r0_body.sizeArgs409).run PRE_first_tail_x15_r0_body.S1383 =
  some (some PRE_first_tail_x15_r0_body.sizeAs409, PRE_first_tail_x15_r0_body.sizeS0409)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA409 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0409 PRE_first_tail_x15_r0_body.s1383.ffi PRE_first_tail_x15_r0_body.sizeAs409 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA410 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1386 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA411 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1390 "plan" none = true
/-- Bridge 412's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys412 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1394 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs412 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1394 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA412 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1394 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys412, PRE_first_tail_x15_r0_body.sizeArgs412)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA412 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1394 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA412 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA412 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA412 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA412 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec412 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1394 PRE_first_tail_x15_r0_body.sizeTys412 PRE_first_tail_x15_r0_body.sizeArgs412).run PRE_first_tail_x15_r0_body.S1394
noncomputable def PRE_first_tail_x15_r0_body.sizeAs412 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec412 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0412 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec412 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1394
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA412 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1394 PRE_first_tail_x15_r0_body.sizeTys412 PRE_first_tail_x15_r0_body.sizeArgs412).run PRE_first_tail_x15_r0_body.S1394 =
  some (some PRE_first_tail_x15_r0_body.sizeAs412, PRE_first_tail_x15_r0_body.sizeS0412)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA412 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0412 PRE_first_tail_x15_r0_body.s1394.ffi PRE_first_tail_x15_r0_body.sizeAs412 = true
/-- Bridge 413's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys413 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1397 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs413 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1397 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA413 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1397 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys413, PRE_first_tail_x15_r0_body.sizeArgs413)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA413 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1397 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA413 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA413 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA413 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA413 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec413 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1397 PRE_first_tail_x15_r0_body.sizeTys413 PRE_first_tail_x15_r0_body.sizeArgs413).run PRE_first_tail_x15_r0_body.S1397
noncomputable def PRE_first_tail_x15_r0_body.sizeAs413 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec413 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0413 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec413 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1397
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA413 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1397 PRE_first_tail_x15_r0_body.sizeTys413 PRE_first_tail_x15_r0_body.sizeArgs413).run PRE_first_tail_x15_r0_body.S1397 =
  some (some PRE_first_tail_x15_r0_body.sizeAs413, PRE_first_tail_x15_r0_body.sizeS0413)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA413 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0413 PRE_first_tail_x15_r0_body.s1397.ffi PRE_first_tail_x15_r0_body.sizeAs413 = true
/-- Bridge 414's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys414 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1400 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs414 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1400 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA414 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1400 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys414, PRE_first_tail_x15_r0_body.sizeArgs414)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA414 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1400 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA414 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA414 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA414 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA414 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec414 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1400 PRE_first_tail_x15_r0_body.sizeTys414 PRE_first_tail_x15_r0_body.sizeArgs414).run PRE_first_tail_x15_r0_body.S1400
noncomputable def PRE_first_tail_x15_r0_body.sizeAs414 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec414 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0414 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec414 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1400
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA414 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1400 PRE_first_tail_x15_r0_body.sizeTys414 PRE_first_tail_x15_r0_body.sizeArgs414).run PRE_first_tail_x15_r0_body.S1400 =
  some (some PRE_first_tail_x15_r0_body.sizeAs414, PRE_first_tail_x15_r0_body.sizeS0414)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA414 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0414 PRE_first_tail_x15_r0_body.s1400.ffi PRE_first_tail_x15_r0_body.sizeAs414 = true
/-- Bridge 415's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys415 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1403 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs415 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1403 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA415 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1403 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys415, PRE_first_tail_x15_r0_body.sizeArgs415)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA415 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1403 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA415 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA415 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA415 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA415 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec415 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1403 PRE_first_tail_x15_r0_body.sizeTys415 PRE_first_tail_x15_r0_body.sizeArgs415).run PRE_first_tail_x15_r0_body.S1403
noncomputable def PRE_first_tail_x15_r0_body.sizeAs415 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec415 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0415 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec415 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1403
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA415 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1403 PRE_first_tail_x15_r0_body.sizeTys415 PRE_first_tail_x15_r0_body.sizeArgs415).run PRE_first_tail_x15_r0_body.S1403 =
  some (some PRE_first_tail_x15_r0_body.sizeAs415, PRE_first_tail_x15_r0_body.sizeS0415)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA415 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0415 PRE_first_tail_x15_r0_body.s1403.ffi PRE_first_tail_x15_r0_body.sizeAs415 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA416 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1406 "recurWindow" none = true
/-- Bridge 417's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys417 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1410 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs417 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1410 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA417 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1410 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys417, PRE_first_tail_x15_r0_body.sizeArgs417)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA417 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1410 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA417 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA417 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA417 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA417 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec417 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1410 PRE_first_tail_x15_r0_body.sizeTys417 PRE_first_tail_x15_r0_body.sizeArgs417).run PRE_first_tail_x15_r0_body.S1410
noncomputable def PRE_first_tail_x15_r0_body.sizeAs417 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec417 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0417 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec417 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1410
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA417 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1410 PRE_first_tail_x15_r0_body.sizeTys417 PRE_first_tail_x15_r0_body.sizeArgs417).run PRE_first_tail_x15_r0_body.S1410 =
  some (some PRE_first_tail_x15_r0_body.sizeAs417, PRE_first_tail_x15_r0_body.sizeS0417)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA417 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0417 PRE_first_tail_x15_r0_body.s1410.ffi PRE_first_tail_x15_r0_body.sizeAs417 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA418 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1413 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA419 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1417 "plan" none = true
/-- Bridge 420's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys420 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1421 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs420 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1421 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA420 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1421 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys420, PRE_first_tail_x15_r0_body.sizeArgs420)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA420 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1421 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA420 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA420 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA420 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA420 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec420 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1421 PRE_first_tail_x15_r0_body.sizeTys420 PRE_first_tail_x15_r0_body.sizeArgs420).run PRE_first_tail_x15_r0_body.S1421
noncomputable def PRE_first_tail_x15_r0_body.sizeAs420 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec420 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0420 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec420 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1421
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA420 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1421 PRE_first_tail_x15_r0_body.sizeTys420 PRE_first_tail_x15_r0_body.sizeArgs420).run PRE_first_tail_x15_r0_body.S1421 =
  some (some PRE_first_tail_x15_r0_body.sizeAs420, PRE_first_tail_x15_r0_body.sizeS0420)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA420 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0420 PRE_first_tail_x15_r0_body.s1421.ffi PRE_first_tail_x15_r0_body.sizeAs420 = true
/-- Bridge 421's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys421 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1424 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs421 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1424 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA421 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1424 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys421, PRE_first_tail_x15_r0_body.sizeArgs421)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA421 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1424 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA421 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA421 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA421 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA421 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec421 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1424 PRE_first_tail_x15_r0_body.sizeTys421 PRE_first_tail_x15_r0_body.sizeArgs421).run PRE_first_tail_x15_r0_body.S1424
noncomputable def PRE_first_tail_x15_r0_body.sizeAs421 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec421 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0421 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec421 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1424
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA421 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1424 PRE_first_tail_x15_r0_body.sizeTys421 PRE_first_tail_x15_r0_body.sizeArgs421).run PRE_first_tail_x15_r0_body.S1424 =
  some (some PRE_first_tail_x15_r0_body.sizeAs421, PRE_first_tail_x15_r0_body.sizeS0421)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA421 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0421 PRE_first_tail_x15_r0_body.s1424.ffi PRE_first_tail_x15_r0_body.sizeAs421 = true
/-- Bridge 422's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys422 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1427 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs422 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1427 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA422 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1427 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys422, PRE_first_tail_x15_r0_body.sizeArgs422)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA422 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1427 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA422 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA422 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA422 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA422 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec422 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1427 PRE_first_tail_x15_r0_body.sizeTys422 PRE_first_tail_x15_r0_body.sizeArgs422).run PRE_first_tail_x15_r0_body.S1427
noncomputable def PRE_first_tail_x15_r0_body.sizeAs422 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec422 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0422 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec422 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1427
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA422 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1427 PRE_first_tail_x15_r0_body.sizeTys422 PRE_first_tail_x15_r0_body.sizeArgs422).run PRE_first_tail_x15_r0_body.S1427 =
  some (some PRE_first_tail_x15_r0_body.sizeAs422, PRE_first_tail_x15_r0_body.sizeS0422)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA422 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0422 PRE_first_tail_x15_r0_body.s1427.ffi PRE_first_tail_x15_r0_body.sizeAs422 = true
/-- Bridge 423's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys423 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1430 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs423 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1430 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA423 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1430 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys423, PRE_first_tail_x15_r0_body.sizeArgs423)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA423 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1430 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA423 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA423 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA423 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA423 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec423 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1430 PRE_first_tail_x15_r0_body.sizeTys423 PRE_first_tail_x15_r0_body.sizeArgs423).run PRE_first_tail_x15_r0_body.S1430
noncomputable def PRE_first_tail_x15_r0_body.sizeAs423 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec423 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0423 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec423 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1430
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA423 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1430 PRE_first_tail_x15_r0_body.sizeTys423 PRE_first_tail_x15_r0_body.sizeArgs423).run PRE_first_tail_x15_r0_body.S1430 =
  some (some PRE_first_tail_x15_r0_body.sizeAs423, PRE_first_tail_x15_r0_body.sizeS0423)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA423 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0423 PRE_first_tail_x15_r0_body.s1430.ffi PRE_first_tail_x15_r0_body.sizeAs423 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA424 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1433 "recurWindow" none = true
/-- Bridge 425's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys425 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1437 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs425 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1437 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA425 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1437 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys425, PRE_first_tail_x15_r0_body.sizeArgs425)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA425 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1437 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA425 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA425 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA425 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA425 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec425 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1437 PRE_first_tail_x15_r0_body.sizeTys425 PRE_first_tail_x15_r0_body.sizeArgs425).run PRE_first_tail_x15_r0_body.S1437
noncomputable def PRE_first_tail_x15_r0_body.sizeAs425 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec425 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0425 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec425 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1437
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA425 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1437 PRE_first_tail_x15_r0_body.sizeTys425 PRE_first_tail_x15_r0_body.sizeArgs425).run PRE_first_tail_x15_r0_body.S1437 =
  some (some PRE_first_tail_x15_r0_body.sizeAs425, PRE_first_tail_x15_r0_body.sizeS0425)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA425 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0425 PRE_first_tail_x15_r0_body.s1437.ffi PRE_first_tail_x15_r0_body.sizeAs425 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA426 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1440 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA427 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1444 "plan" none = true
/-- Bridge 428's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys428 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1448 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs428 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1448 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA428 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1448 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys428, PRE_first_tail_x15_r0_body.sizeArgs428)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA428 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1448 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA428 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA428 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA428 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA428 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec428 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1448 PRE_first_tail_x15_r0_body.sizeTys428 PRE_first_tail_x15_r0_body.sizeArgs428).run PRE_first_tail_x15_r0_body.S1448
noncomputable def PRE_first_tail_x15_r0_body.sizeAs428 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec428 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0428 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec428 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1448
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA428 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1448 PRE_first_tail_x15_r0_body.sizeTys428 PRE_first_tail_x15_r0_body.sizeArgs428).run PRE_first_tail_x15_r0_body.S1448 =
  some (some PRE_first_tail_x15_r0_body.sizeAs428, PRE_first_tail_x15_r0_body.sizeS0428)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA428 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0428 PRE_first_tail_x15_r0_body.s1448.ffi PRE_first_tail_x15_r0_body.sizeAs428 = true
/-- Bridge 429's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys429 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1451 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs429 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1451 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA429 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1451 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys429, PRE_first_tail_x15_r0_body.sizeArgs429)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA429 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1451 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA429 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA429 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA429 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA429 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec429 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1451 PRE_first_tail_x15_r0_body.sizeTys429 PRE_first_tail_x15_r0_body.sizeArgs429).run PRE_first_tail_x15_r0_body.S1451
noncomputable def PRE_first_tail_x15_r0_body.sizeAs429 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec429 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0429 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec429 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1451
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA429 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1451 PRE_first_tail_x15_r0_body.sizeTys429 PRE_first_tail_x15_r0_body.sizeArgs429).run PRE_first_tail_x15_r0_body.S1451 =
  some (some PRE_first_tail_x15_r0_body.sizeAs429, PRE_first_tail_x15_r0_body.sizeS0429)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA429 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0429 PRE_first_tail_x15_r0_body.s1451.ffi PRE_first_tail_x15_r0_body.sizeAs429 = true
/-- Bridge 430's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys430 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1454 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs430 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1454 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA430 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1454 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys430, PRE_first_tail_x15_r0_body.sizeArgs430)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA430 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1454 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA430 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA430 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA430 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA430 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec430 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1454 PRE_first_tail_x15_r0_body.sizeTys430 PRE_first_tail_x15_r0_body.sizeArgs430).run PRE_first_tail_x15_r0_body.S1454
noncomputable def PRE_first_tail_x15_r0_body.sizeAs430 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec430 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0430 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec430 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1454
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA430 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1454 PRE_first_tail_x15_r0_body.sizeTys430 PRE_first_tail_x15_r0_body.sizeArgs430).run PRE_first_tail_x15_r0_body.S1454 =
  some (some PRE_first_tail_x15_r0_body.sizeAs430, PRE_first_tail_x15_r0_body.sizeS0430)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA430 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0430 PRE_first_tail_x15_r0_body.s1454.ffi PRE_first_tail_x15_r0_body.sizeAs430 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA431 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1457 "appendWindow" none = true
/-- Bridge 432's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys432 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1461 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs432 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1461 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA432 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1461 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys432, PRE_first_tail_x15_r0_body.sizeArgs432)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA432 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1461 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA432 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA432 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA432 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA432 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec432 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1461 PRE_first_tail_x15_r0_body.sizeTys432 PRE_first_tail_x15_r0_body.sizeArgs432).run PRE_first_tail_x15_r0_body.S1461
noncomputable def PRE_first_tail_x15_r0_body.sizeAs432 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec432 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0432 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec432 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1461
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA432 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1461 PRE_first_tail_x15_r0_body.sizeTys432 PRE_first_tail_x15_r0_body.sizeArgs432).run PRE_first_tail_x15_r0_body.S1461 =
  some (some PRE_first_tail_x15_r0_body.sizeAs432, PRE_first_tail_x15_r0_body.sizeS0432)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA432 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0432 PRE_first_tail_x15_r0_body.s1461.ffi PRE_first_tail_x15_r0_body.sizeAs432 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA433 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1464 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA434 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1468 "plan" none = true
/-- Bridge 435's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys435 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1472 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs435 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1472 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA435 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1472 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys435, PRE_first_tail_x15_r0_body.sizeArgs435)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA435 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1472 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA435 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA435 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA435 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA435 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec435 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1472 PRE_first_tail_x15_r0_body.sizeTys435 PRE_first_tail_x15_r0_body.sizeArgs435).run PRE_first_tail_x15_r0_body.S1472
noncomputable def PRE_first_tail_x15_r0_body.sizeAs435 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec435 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0435 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec435 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1472
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA435 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1472 PRE_first_tail_x15_r0_body.sizeTys435 PRE_first_tail_x15_r0_body.sizeArgs435).run PRE_first_tail_x15_r0_body.S1472 =
  some (some PRE_first_tail_x15_r0_body.sizeAs435, PRE_first_tail_x15_r0_body.sizeS0435)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA435 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0435 PRE_first_tail_x15_r0_body.s1472.ffi PRE_first_tail_x15_r0_body.sizeAs435 = true
/-- Bridge 436's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys436 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1475 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs436 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1475 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA436 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1475 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys436, PRE_first_tail_x15_r0_body.sizeArgs436)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA436 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1475 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA436 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA436 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA436 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA436 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec436 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1475 PRE_first_tail_x15_r0_body.sizeTys436 PRE_first_tail_x15_r0_body.sizeArgs436).run PRE_first_tail_x15_r0_body.S1475
noncomputable def PRE_first_tail_x15_r0_body.sizeAs436 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec436 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0436 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec436 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1475
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA436 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1475 PRE_first_tail_x15_r0_body.sizeTys436 PRE_first_tail_x15_r0_body.sizeArgs436).run PRE_first_tail_x15_r0_body.S1475 =
  some (some PRE_first_tail_x15_r0_body.sizeAs436, PRE_first_tail_x15_r0_body.sizeS0436)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA436 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0436 PRE_first_tail_x15_r0_body.s1475.ffi PRE_first_tail_x15_r0_body.sizeAs436 = true
/-- Bridge 437's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys437 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1478 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs437 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1478 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA437 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1478 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys437, PRE_first_tail_x15_r0_body.sizeArgs437)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA437 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1478 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA437 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA437 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA437 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA437 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec437 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1478 PRE_first_tail_x15_r0_body.sizeTys437 PRE_first_tail_x15_r0_body.sizeArgs437).run PRE_first_tail_x15_r0_body.S1478
noncomputable def PRE_first_tail_x15_r0_body.sizeAs437 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec437 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0437 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec437 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1478
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA437 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1478 PRE_first_tail_x15_r0_body.sizeTys437 PRE_first_tail_x15_r0_body.sizeArgs437).run PRE_first_tail_x15_r0_body.S1478 =
  some (some PRE_first_tail_x15_r0_body.sizeAs437, PRE_first_tail_x15_r0_body.sizeS0437)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA437 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0437 PRE_first_tail_x15_r0_body.s1478.ffi PRE_first_tail_x15_r0_body.sizeAs437 = true
/-- Bridge 438's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys438 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1481 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs438 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1481 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA438 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1481 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys438, PRE_first_tail_x15_r0_body.sizeArgs438)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA438 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1481 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA438 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA438 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA438 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA438 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec438 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1481 PRE_first_tail_x15_r0_body.sizeTys438 PRE_first_tail_x15_r0_body.sizeArgs438).run PRE_first_tail_x15_r0_body.S1481
noncomputable def PRE_first_tail_x15_r0_body.sizeAs438 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec438 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0438 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec438 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1481
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA438 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1481 PRE_first_tail_x15_r0_body.sizeTys438 PRE_first_tail_x15_r0_body.sizeArgs438).run PRE_first_tail_x15_r0_body.S1481 =
  some (some PRE_first_tail_x15_r0_body.sizeAs438, PRE_first_tail_x15_r0_body.sizeS0438)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA438 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0438 PRE_first_tail_x15_r0_body.s1481.ffi PRE_first_tail_x15_r0_body.sizeAs438 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA439 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1484 "recurWindow" none = true
/-- Bridge 440's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys440 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1488 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs440 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1488 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA440 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1488 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys440, PRE_first_tail_x15_r0_body.sizeArgs440)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA440 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1488 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA440 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA440 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA440 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA440 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec440 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1488 PRE_first_tail_x15_r0_body.sizeTys440 PRE_first_tail_x15_r0_body.sizeArgs440).run PRE_first_tail_x15_r0_body.S1488
noncomputable def PRE_first_tail_x15_r0_body.sizeAs440 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec440 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0440 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec440 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1488
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA440 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1488 PRE_first_tail_x15_r0_body.sizeTys440 PRE_first_tail_x15_r0_body.sizeArgs440).run PRE_first_tail_x15_r0_body.S1488 =
  some (some PRE_first_tail_x15_r0_body.sizeAs440, PRE_first_tail_x15_r0_body.sizeS0440)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA440 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0440 PRE_first_tail_x15_r0_body.s1488.ffi PRE_first_tail_x15_r0_body.sizeAs440 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA441 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1491 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA442 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1495 "plan" none = true
/-- Bridge 443's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys443 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1499 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs443 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1499 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA443 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1499 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys443, PRE_first_tail_x15_r0_body.sizeArgs443)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA443 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1499 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA443 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA443 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA443 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA443 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec443 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1499 PRE_first_tail_x15_r0_body.sizeTys443 PRE_first_tail_x15_r0_body.sizeArgs443).run PRE_first_tail_x15_r0_body.S1499
noncomputable def PRE_first_tail_x15_r0_body.sizeAs443 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec443 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0443 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec443 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1499
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA443 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1499 PRE_first_tail_x15_r0_body.sizeTys443 PRE_first_tail_x15_r0_body.sizeArgs443).run PRE_first_tail_x15_r0_body.S1499 =
  some (some PRE_first_tail_x15_r0_body.sizeAs443, PRE_first_tail_x15_r0_body.sizeS0443)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA443 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0443 PRE_first_tail_x15_r0_body.s1499.ffi PRE_first_tail_x15_r0_body.sizeAs443 = true
/-- Bridge 444's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys444 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1502 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs444 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1502 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA444 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1502 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys444, PRE_first_tail_x15_r0_body.sizeArgs444)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA444 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1502 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA444 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA444 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA444 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA444 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec444 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1502 PRE_first_tail_x15_r0_body.sizeTys444 PRE_first_tail_x15_r0_body.sizeArgs444).run PRE_first_tail_x15_r0_body.S1502
noncomputable def PRE_first_tail_x15_r0_body.sizeAs444 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec444 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0444 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec444 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1502
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA444 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1502 PRE_first_tail_x15_r0_body.sizeTys444 PRE_first_tail_x15_r0_body.sizeArgs444).run PRE_first_tail_x15_r0_body.S1502 =
  some (some PRE_first_tail_x15_r0_body.sizeAs444, PRE_first_tail_x15_r0_body.sizeS0444)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA444 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0444 PRE_first_tail_x15_r0_body.s1502.ffi PRE_first_tail_x15_r0_body.sizeAs444 = true
/-- Bridge 445's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys445 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1505 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs445 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1505 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA445 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1505 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys445, PRE_first_tail_x15_r0_body.sizeArgs445)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA445 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1505 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA445 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA445 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA445 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA445 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec445 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1505 PRE_first_tail_x15_r0_body.sizeTys445 PRE_first_tail_x15_r0_body.sizeArgs445).run PRE_first_tail_x15_r0_body.S1505
noncomputable def PRE_first_tail_x15_r0_body.sizeAs445 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec445 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0445 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec445 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1505
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA445 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1505 PRE_first_tail_x15_r0_body.sizeTys445 PRE_first_tail_x15_r0_body.sizeArgs445).run PRE_first_tail_x15_r0_body.S1505 =
  some (some PRE_first_tail_x15_r0_body.sizeAs445, PRE_first_tail_x15_r0_body.sizeS0445)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA445 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0445 PRE_first_tail_x15_r0_body.s1505.ffi PRE_first_tail_x15_r0_body.sizeAs445 = true
/-- Bridge 446's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys446 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1508 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs446 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1508 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA446 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1508 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys446, PRE_first_tail_x15_r0_body.sizeArgs446)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA446 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1508 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA446 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA446 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA446 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA446 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec446 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1508 PRE_first_tail_x15_r0_body.sizeTys446 PRE_first_tail_x15_r0_body.sizeArgs446).run PRE_first_tail_x15_r0_body.S1508
noncomputable def PRE_first_tail_x15_r0_body.sizeAs446 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec446 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0446 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec446 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1508
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA446 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1508 PRE_first_tail_x15_r0_body.sizeTys446 PRE_first_tail_x15_r0_body.sizeArgs446).run PRE_first_tail_x15_r0_body.S1508 =
  some (some PRE_first_tail_x15_r0_body.sizeAs446, PRE_first_tail_x15_r0_body.sizeS0446)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA446 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0446 PRE_first_tail_x15_r0_body.s1508.ffi PRE_first_tail_x15_r0_body.sizeAs446 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA447 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1511 "recurWindow" none = true
/-- Bridge 448's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys448 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1515 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs448 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1515 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA448 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1515 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys448, PRE_first_tail_x15_r0_body.sizeArgs448)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA448 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1515 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA448 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA448 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA448 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA448 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec448 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1515 PRE_first_tail_x15_r0_body.sizeTys448 PRE_first_tail_x15_r0_body.sizeArgs448).run PRE_first_tail_x15_r0_body.S1515
noncomputable def PRE_first_tail_x15_r0_body.sizeAs448 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec448 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0448 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec448 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1515
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA448 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1515 PRE_first_tail_x15_r0_body.sizeTys448 PRE_first_tail_x15_r0_body.sizeArgs448).run PRE_first_tail_x15_r0_body.S1515 =
  some (some PRE_first_tail_x15_r0_body.sizeAs448, PRE_first_tail_x15_r0_body.sizeS0448)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA448 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0448 PRE_first_tail_x15_r0_body.s1515.ffi PRE_first_tail_x15_r0_body.sizeAs448 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA449 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1518 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA450 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1522 "plan" none = true
/-- Bridge 451's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys451 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1526 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs451 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1526 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA451 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1526 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys451, PRE_first_tail_x15_r0_body.sizeArgs451)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA451 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1526 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA451 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA451 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA451 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA451 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec451 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1526 PRE_first_tail_x15_r0_body.sizeTys451 PRE_first_tail_x15_r0_body.sizeArgs451).run PRE_first_tail_x15_r0_body.S1526
noncomputable def PRE_first_tail_x15_r0_body.sizeAs451 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec451 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0451 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec451 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1526
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA451 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1526 PRE_first_tail_x15_r0_body.sizeTys451 PRE_first_tail_x15_r0_body.sizeArgs451).run PRE_first_tail_x15_r0_body.S1526 =
  some (some PRE_first_tail_x15_r0_body.sizeAs451, PRE_first_tail_x15_r0_body.sizeS0451)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA451 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0451 PRE_first_tail_x15_r0_body.s1526.ffi PRE_first_tail_x15_r0_body.sizeAs451 = true
/-- Bridge 452's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys452 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1529 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs452 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1529 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA452 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1529 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys452, PRE_first_tail_x15_r0_body.sizeArgs452)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA452 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1529 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA452 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA452 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA452 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA452 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec452 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1529 PRE_first_tail_x15_r0_body.sizeTys452 PRE_first_tail_x15_r0_body.sizeArgs452).run PRE_first_tail_x15_r0_body.S1529
noncomputable def PRE_first_tail_x15_r0_body.sizeAs452 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec452 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0452 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec452 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1529
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA452 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1529 PRE_first_tail_x15_r0_body.sizeTys452 PRE_first_tail_x15_r0_body.sizeArgs452).run PRE_first_tail_x15_r0_body.S1529 =
  some (some PRE_first_tail_x15_r0_body.sizeAs452, PRE_first_tail_x15_r0_body.sizeS0452)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA452 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0452 PRE_first_tail_x15_r0_body.s1529.ffi PRE_first_tail_x15_r0_body.sizeAs452 = true
/-- Bridge 453's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys453 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1532 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs453 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1532 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA453 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1532 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys453, PRE_first_tail_x15_r0_body.sizeArgs453)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA453 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1532 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA453 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA453 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA453 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA453 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec453 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1532 PRE_first_tail_x15_r0_body.sizeTys453 PRE_first_tail_x15_r0_body.sizeArgs453).run PRE_first_tail_x15_r0_body.S1532
noncomputable def PRE_first_tail_x15_r0_body.sizeAs453 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec453 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0453 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec453 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1532
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA453 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1532 PRE_first_tail_x15_r0_body.sizeTys453 PRE_first_tail_x15_r0_body.sizeArgs453).run PRE_first_tail_x15_r0_body.S1532 =
  some (some PRE_first_tail_x15_r0_body.sizeAs453, PRE_first_tail_x15_r0_body.sizeS0453)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA453 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0453 PRE_first_tail_x15_r0_body.s1532.ffi PRE_first_tail_x15_r0_body.sizeAs453 = true
/-- Bridge 454's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys454 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1535 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs454 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1535 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA454 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1535 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys454, PRE_first_tail_x15_r0_body.sizeArgs454)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA454 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1535 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA454 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA454 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA454 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA454 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec454 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1535 PRE_first_tail_x15_r0_body.sizeTys454 PRE_first_tail_x15_r0_body.sizeArgs454).run PRE_first_tail_x15_r0_body.S1535
noncomputable def PRE_first_tail_x15_r0_body.sizeAs454 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec454 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0454 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec454 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1535
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA454 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1535 PRE_first_tail_x15_r0_body.sizeTys454 PRE_first_tail_x15_r0_body.sizeArgs454).run PRE_first_tail_x15_r0_body.S1535 =
  some (some PRE_first_tail_x15_r0_body.sizeAs454, PRE_first_tail_x15_r0_body.sizeS0454)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA454 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0454 PRE_first_tail_x15_r0_body.s1535.ffi PRE_first_tail_x15_r0_body.sizeAs454 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA455 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1538 "recurWindow" none = true
/-- Bridge 456's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys456 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1542 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs456 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1542 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA456 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1542 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys456, PRE_first_tail_x15_r0_body.sizeArgs456)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA456 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1542 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA456 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA456 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA456 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA456 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec456 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1542 PRE_first_tail_x15_r0_body.sizeTys456 PRE_first_tail_x15_r0_body.sizeArgs456).run PRE_first_tail_x15_r0_body.S1542
noncomputable def PRE_first_tail_x15_r0_body.sizeAs456 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec456 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0456 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec456 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1542
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA456 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1542 PRE_first_tail_x15_r0_body.sizeTys456 PRE_first_tail_x15_r0_body.sizeArgs456).run PRE_first_tail_x15_r0_body.S1542 =
  some (some PRE_first_tail_x15_r0_body.sizeAs456, PRE_first_tail_x15_r0_body.sizeS0456)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA456 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0456 PRE_first_tail_x15_r0_body.s1542.ffi PRE_first_tail_x15_r0_body.sizeAs456 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA457 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1545 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA458 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1549 "plan" none = true
/-- Bridge 459's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys459 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1553 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs459 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1553 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA459 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1553 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys459, PRE_first_tail_x15_r0_body.sizeArgs459)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA459 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1553 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA459 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA459 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA459 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA459 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec459 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1553 PRE_first_tail_x15_r0_body.sizeTys459 PRE_first_tail_x15_r0_body.sizeArgs459).run PRE_first_tail_x15_r0_body.S1553
noncomputable def PRE_first_tail_x15_r0_body.sizeAs459 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec459 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0459 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec459 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1553
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA459 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1553 PRE_first_tail_x15_r0_body.sizeTys459 PRE_first_tail_x15_r0_body.sizeArgs459).run PRE_first_tail_x15_r0_body.S1553 =
  some (some PRE_first_tail_x15_r0_body.sizeAs459, PRE_first_tail_x15_r0_body.sizeS0459)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA459 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0459 PRE_first_tail_x15_r0_body.s1553.ffi PRE_first_tail_x15_r0_body.sizeAs459 = true
/-- Bridge 460's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys460 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1556 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs460 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1556 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA460 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1556 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys460, PRE_first_tail_x15_r0_body.sizeArgs460)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA460 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1556 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA460 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA460 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA460 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA460 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec460 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1556 PRE_first_tail_x15_r0_body.sizeTys460 PRE_first_tail_x15_r0_body.sizeArgs460).run PRE_first_tail_x15_r0_body.S1556
noncomputable def PRE_first_tail_x15_r0_body.sizeAs460 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec460 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0460 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec460 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1556
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA460 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1556 PRE_first_tail_x15_r0_body.sizeTys460 PRE_first_tail_x15_r0_body.sizeArgs460).run PRE_first_tail_x15_r0_body.S1556 =
  some (some PRE_first_tail_x15_r0_body.sizeAs460, PRE_first_tail_x15_r0_body.sizeS0460)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA460 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0460 PRE_first_tail_x15_r0_body.s1556.ffi PRE_first_tail_x15_r0_body.sizeAs460 = true
/-- Bridge 461's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys461 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1559 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs461 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1559 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA461 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1559 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys461, PRE_first_tail_x15_r0_body.sizeArgs461)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA461 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1559 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA461 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA461 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA461 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA461 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec461 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1559 PRE_first_tail_x15_r0_body.sizeTys461 PRE_first_tail_x15_r0_body.sizeArgs461).run PRE_first_tail_x15_r0_body.S1559
noncomputable def PRE_first_tail_x15_r0_body.sizeAs461 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec461 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0461 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec461 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1559
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA461 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1559 PRE_first_tail_x15_r0_body.sizeTys461 PRE_first_tail_x15_r0_body.sizeArgs461).run PRE_first_tail_x15_r0_body.S1559 =
  some (some PRE_first_tail_x15_r0_body.sizeAs461, PRE_first_tail_x15_r0_body.sizeS0461)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA461 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0461 PRE_first_tail_x15_r0_body.s1559.ffi PRE_first_tail_x15_r0_body.sizeAs461 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA462 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1562 "appendWindow" none = true
/-- Bridge 463's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys463 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1566 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs463 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1566 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA463 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1566 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys463, PRE_first_tail_x15_r0_body.sizeArgs463)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA463 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1566 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA463 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA463 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA463 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA463 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec463 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1566 PRE_first_tail_x15_r0_body.sizeTys463 PRE_first_tail_x15_r0_body.sizeArgs463).run PRE_first_tail_x15_r0_body.S1566
noncomputable def PRE_first_tail_x15_r0_body.sizeAs463 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec463 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0463 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec463 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1566
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA463 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1566 PRE_first_tail_x15_r0_body.sizeTys463 PRE_first_tail_x15_r0_body.sizeArgs463).run PRE_first_tail_x15_r0_body.S1566 =
  some (some PRE_first_tail_x15_r0_body.sizeAs463, PRE_first_tail_x15_r0_body.sizeS0463)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA463 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0463 PRE_first_tail_x15_r0_body.s1566.ffi PRE_first_tail_x15_r0_body.sizeAs463 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA464 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1569 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA465 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1573 "plan" none = true
/-- Bridge 466's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys466 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1577 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs466 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1577 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA466 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1577 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys466, PRE_first_tail_x15_r0_body.sizeArgs466)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA466 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1577 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA466 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA466 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA466 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA466 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec466 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1577 PRE_first_tail_x15_r0_body.sizeTys466 PRE_first_tail_x15_r0_body.sizeArgs466).run PRE_first_tail_x15_r0_body.S1577
noncomputable def PRE_first_tail_x15_r0_body.sizeAs466 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec466 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0466 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec466 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1577
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA466 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1577 PRE_first_tail_x15_r0_body.sizeTys466 PRE_first_tail_x15_r0_body.sizeArgs466).run PRE_first_tail_x15_r0_body.S1577 =
  some (some PRE_first_tail_x15_r0_body.sizeAs466, PRE_first_tail_x15_r0_body.sizeS0466)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA466 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0466 PRE_first_tail_x15_r0_body.s1577.ffi PRE_first_tail_x15_r0_body.sizeAs466 = true
/-- Bridge 467's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys467 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1580 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs467 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1580 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA467 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1580 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys467, PRE_first_tail_x15_r0_body.sizeArgs467)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA467 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1580 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA467 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA467 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA467 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA467 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec467 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1580 PRE_first_tail_x15_r0_body.sizeTys467 PRE_first_tail_x15_r0_body.sizeArgs467).run PRE_first_tail_x15_r0_body.S1580
noncomputable def PRE_first_tail_x15_r0_body.sizeAs467 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec467 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0467 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec467 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1580
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA467 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1580 PRE_first_tail_x15_r0_body.sizeTys467 PRE_first_tail_x15_r0_body.sizeArgs467).run PRE_first_tail_x15_r0_body.S1580 =
  some (some PRE_first_tail_x15_r0_body.sizeAs467, PRE_first_tail_x15_r0_body.sizeS0467)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA467 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0467 PRE_first_tail_x15_r0_body.s1580.ffi PRE_first_tail_x15_r0_body.sizeAs467 = true
/-- Bridge 468's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys468 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1583 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs468 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1583 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA468 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1583 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys468, PRE_first_tail_x15_r0_body.sizeArgs468)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA468 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1583 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA468 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA468 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA468 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA468 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec468 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.sizeTys468 PRE_first_tail_x15_r0_body.sizeArgs468).run PRE_first_tail_x15_r0_body.S1583
noncomputable def PRE_first_tail_x15_r0_body.sizeAs468 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec468 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0468 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec468 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1583
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA468 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.sizeTys468 PRE_first_tail_x15_r0_body.sizeArgs468).run PRE_first_tail_x15_r0_body.S1583 =
  some (some PRE_first_tail_x15_r0_body.sizeAs468, PRE_first_tail_x15_r0_body.sizeS0468)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA468 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0468 PRE_first_tail_x15_r0_body.s1583.ffi PRE_first_tail_x15_r0_body.sizeAs468 = true
/-- Bridge 469's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys469 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1586 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs469 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1586 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA469 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1586 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys469, PRE_first_tail_x15_r0_body.sizeArgs469)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA469 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1586 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA469 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA469 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA469 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA469 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec469 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1586 PRE_first_tail_x15_r0_body.sizeTys469 PRE_first_tail_x15_r0_body.sizeArgs469).run PRE_first_tail_x15_r0_body.S1586
noncomputable def PRE_first_tail_x15_r0_body.sizeAs469 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec469 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0469 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec469 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1586
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA469 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1586 PRE_first_tail_x15_r0_body.sizeTys469 PRE_first_tail_x15_r0_body.sizeArgs469).run PRE_first_tail_x15_r0_body.S1586 =
  some (some PRE_first_tail_x15_r0_body.sizeAs469, PRE_first_tail_x15_r0_body.sizeS0469)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA469 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0469 PRE_first_tail_x15_r0_body.s1586.ffi PRE_first_tail_x15_r0_body.sizeAs469 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA470 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1589 "recurWindow" none = true
/-- Bridge 471's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys471 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1593 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs471 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1593 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA471 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1593 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys471, PRE_first_tail_x15_r0_body.sizeArgs471)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA471 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1593 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA471 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA471 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA471 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA471 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec471 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1593 PRE_first_tail_x15_r0_body.sizeTys471 PRE_first_tail_x15_r0_body.sizeArgs471).run PRE_first_tail_x15_r0_body.S1593
noncomputable def PRE_first_tail_x15_r0_body.sizeAs471 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec471 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0471 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec471 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1593
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA471 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1593 PRE_first_tail_x15_r0_body.sizeTys471 PRE_first_tail_x15_r0_body.sizeArgs471).run PRE_first_tail_x15_r0_body.S1593 =
  some (some PRE_first_tail_x15_r0_body.sizeAs471, PRE_first_tail_x15_r0_body.sizeS0471)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA471 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0471 PRE_first_tail_x15_r0_body.s1593.ffi PRE_first_tail_x15_r0_body.sizeAs471 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA472 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1596 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA473 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1600 "plan" none = true
/-- Bridge 474's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys474 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1604 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs474 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1604 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA474 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1604 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys474, PRE_first_tail_x15_r0_body.sizeArgs474)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA474 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1604 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA474 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA474 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA474 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA474 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec474 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1604 PRE_first_tail_x15_r0_body.sizeTys474 PRE_first_tail_x15_r0_body.sizeArgs474).run PRE_first_tail_x15_r0_body.S1604
noncomputable def PRE_first_tail_x15_r0_body.sizeAs474 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec474 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0474 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec474 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1604
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA474 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1604 PRE_first_tail_x15_r0_body.sizeTys474 PRE_first_tail_x15_r0_body.sizeArgs474).run PRE_first_tail_x15_r0_body.S1604 =
  some (some PRE_first_tail_x15_r0_body.sizeAs474, PRE_first_tail_x15_r0_body.sizeS0474)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA474 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0474 PRE_first_tail_x15_r0_body.s1604.ffi PRE_first_tail_x15_r0_body.sizeAs474 = true
/-- Bridge 475's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys475 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1607 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs475 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1607 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA475 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1607 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys475, PRE_first_tail_x15_r0_body.sizeArgs475)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA475 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1607 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA475 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA475 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA475 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA475 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec475 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1607 PRE_first_tail_x15_r0_body.sizeTys475 PRE_first_tail_x15_r0_body.sizeArgs475).run PRE_first_tail_x15_r0_body.S1607
noncomputable def PRE_first_tail_x15_r0_body.sizeAs475 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec475 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0475 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec475 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1607
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA475 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1607 PRE_first_tail_x15_r0_body.sizeTys475 PRE_first_tail_x15_r0_body.sizeArgs475).run PRE_first_tail_x15_r0_body.S1607 =
  some (some PRE_first_tail_x15_r0_body.sizeAs475, PRE_first_tail_x15_r0_body.sizeS0475)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA475 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0475 PRE_first_tail_x15_r0_body.s1607.ffi PRE_first_tail_x15_r0_body.sizeAs475 = true
/-- Bridge 476's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys476 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1610 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs476 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1610 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA476 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1610 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys476, PRE_first_tail_x15_r0_body.sizeArgs476)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA476 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1610 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA476 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA476 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA476 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA476 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec476 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1610 PRE_first_tail_x15_r0_body.sizeTys476 PRE_first_tail_x15_r0_body.sizeArgs476).run PRE_first_tail_x15_r0_body.S1610
noncomputable def PRE_first_tail_x15_r0_body.sizeAs476 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec476 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0476 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec476 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1610
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA476 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1610 PRE_first_tail_x15_r0_body.sizeTys476 PRE_first_tail_x15_r0_body.sizeArgs476).run PRE_first_tail_x15_r0_body.S1610 =
  some (some PRE_first_tail_x15_r0_body.sizeAs476, PRE_first_tail_x15_r0_body.sizeS0476)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA476 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0476 PRE_first_tail_x15_r0_body.s1610.ffi PRE_first_tail_x15_r0_body.sizeAs476 = true
/-- Bridge 477's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys477 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1613 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs477 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1613 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA477 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1613 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys477, PRE_first_tail_x15_r0_body.sizeArgs477)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA477 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1613 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA477 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA477 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA477 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA477 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec477 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1613 PRE_first_tail_x15_r0_body.sizeTys477 PRE_first_tail_x15_r0_body.sizeArgs477).run PRE_first_tail_x15_r0_body.S1613
noncomputable def PRE_first_tail_x15_r0_body.sizeAs477 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec477 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0477 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec477 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1613
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA477 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1613 PRE_first_tail_x15_r0_body.sizeTys477 PRE_first_tail_x15_r0_body.sizeArgs477).run PRE_first_tail_x15_r0_body.S1613 =
  some (some PRE_first_tail_x15_r0_body.sizeAs477, PRE_first_tail_x15_r0_body.sizeS0477)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA477 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0477 PRE_first_tail_x15_r0_body.s1613.ffi PRE_first_tail_x15_r0_body.sizeAs477 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA478 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1616 "recurWindow" none = true
/-- Bridge 479's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys479 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1620 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs479 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1620 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA479 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1620 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys479, PRE_first_tail_x15_r0_body.sizeArgs479)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA479 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1620 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA479 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA479 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA479 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA479 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec479 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1620 PRE_first_tail_x15_r0_body.sizeTys479 PRE_first_tail_x15_r0_body.sizeArgs479).run PRE_first_tail_x15_r0_body.S1620
noncomputable def PRE_first_tail_x15_r0_body.sizeAs479 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec479 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0479 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec479 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1620
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA479 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1620 PRE_first_tail_x15_r0_body.sizeTys479 PRE_first_tail_x15_r0_body.sizeArgs479).run PRE_first_tail_x15_r0_body.S1620 =
  some (some PRE_first_tail_x15_r0_body.sizeAs479, PRE_first_tail_x15_r0_body.sizeS0479)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA479 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0479 PRE_first_tail_x15_r0_body.s1620.ffi PRE_first_tail_x15_r0_body.sizeAs479 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA480 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1623 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA481 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1627 "plan" none = true
/-- Bridge 482's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys482 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1631 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs482 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1631 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA482 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1631 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys482, PRE_first_tail_x15_r0_body.sizeArgs482)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA482 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1631 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA482 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA482 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA482 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA482 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec482 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1631 PRE_first_tail_x15_r0_body.sizeTys482 PRE_first_tail_x15_r0_body.sizeArgs482).run PRE_first_tail_x15_r0_body.S1631
noncomputable def PRE_first_tail_x15_r0_body.sizeAs482 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec482 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0482 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec482 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1631
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA482 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1631 PRE_first_tail_x15_r0_body.sizeTys482 PRE_first_tail_x15_r0_body.sizeArgs482).run PRE_first_tail_x15_r0_body.S1631 =
  some (some PRE_first_tail_x15_r0_body.sizeAs482, PRE_first_tail_x15_r0_body.sizeS0482)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA482 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0482 PRE_first_tail_x15_r0_body.s1631.ffi PRE_first_tail_x15_r0_body.sizeAs482 = true
/-- Bridge 483's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys483 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1634 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs483 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1634 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA483 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1634 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys483, PRE_first_tail_x15_r0_body.sizeArgs483)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA483 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1634 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA483 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA483 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA483 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA483 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec483 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1634 PRE_first_tail_x15_r0_body.sizeTys483 PRE_first_tail_x15_r0_body.sizeArgs483).run PRE_first_tail_x15_r0_body.S1634
noncomputable def PRE_first_tail_x15_r0_body.sizeAs483 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec483 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0483 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec483 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1634
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA483 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1634 PRE_first_tail_x15_r0_body.sizeTys483 PRE_first_tail_x15_r0_body.sizeArgs483).run PRE_first_tail_x15_r0_body.S1634 =
  some (some PRE_first_tail_x15_r0_body.sizeAs483, PRE_first_tail_x15_r0_body.sizeS0483)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA483 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0483 PRE_first_tail_x15_r0_body.s1634.ffi PRE_first_tail_x15_r0_body.sizeAs483 = true
/-- Bridge 484's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys484 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1637 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs484 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1637 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA484 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1637 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys484, PRE_first_tail_x15_r0_body.sizeArgs484)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA484 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1637 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA484 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA484 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA484 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA484 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec484 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1637 PRE_first_tail_x15_r0_body.sizeTys484 PRE_first_tail_x15_r0_body.sizeArgs484).run PRE_first_tail_x15_r0_body.S1637
noncomputable def PRE_first_tail_x15_r0_body.sizeAs484 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec484 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0484 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec484 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1637
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA484 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1637 PRE_first_tail_x15_r0_body.sizeTys484 PRE_first_tail_x15_r0_body.sizeArgs484).run PRE_first_tail_x15_r0_body.S1637 =
  some (some PRE_first_tail_x15_r0_body.sizeAs484, PRE_first_tail_x15_r0_body.sizeS0484)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA484 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0484 PRE_first_tail_x15_r0_body.s1637.ffi PRE_first_tail_x15_r0_body.sizeAs484 = true
/-- Bridge 485's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys485 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1640 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs485 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1640 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA485 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1640 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys485, PRE_first_tail_x15_r0_body.sizeArgs485)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA485 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1640 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA485 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA485 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA485 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA485 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec485 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1640 PRE_first_tail_x15_r0_body.sizeTys485 PRE_first_tail_x15_r0_body.sizeArgs485).run PRE_first_tail_x15_r0_body.S1640
noncomputable def PRE_first_tail_x15_r0_body.sizeAs485 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec485 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0485 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec485 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1640
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA485 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1640 PRE_first_tail_x15_r0_body.sizeTys485 PRE_first_tail_x15_r0_body.sizeArgs485).run PRE_first_tail_x15_r0_body.S1640 =
  some (some PRE_first_tail_x15_r0_body.sizeAs485, PRE_first_tail_x15_r0_body.sizeS0485)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA485 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0485 PRE_first_tail_x15_r0_body.s1640.ffi PRE_first_tail_x15_r0_body.sizeAs485 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA486 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1643 "recurWindow" none = true
/-- Bridge 487's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys487 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1647 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs487 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1647 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA487 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1647 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys487, PRE_first_tail_x15_r0_body.sizeArgs487)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA487 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1647 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA487 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA487 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA487 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA487 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec487 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1647 PRE_first_tail_x15_r0_body.sizeTys487 PRE_first_tail_x15_r0_body.sizeArgs487).run PRE_first_tail_x15_r0_body.S1647
noncomputable def PRE_first_tail_x15_r0_body.sizeAs487 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec487 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0487 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec487 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1647
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA487 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1647 PRE_first_tail_x15_r0_body.sizeTys487 PRE_first_tail_x15_r0_body.sizeArgs487).run PRE_first_tail_x15_r0_body.S1647 =
  some (some PRE_first_tail_x15_r0_body.sizeAs487, PRE_first_tail_x15_r0_body.sizeS0487)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA487 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0487 PRE_first_tail_x15_r0_body.s1647.ffi PRE_first_tail_x15_r0_body.sizeAs487 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA488 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1650 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA489 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1654 "plan" none = true
/-- Bridge 490's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys490 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1658 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs490 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1658 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA490 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1658 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys490, PRE_first_tail_x15_r0_body.sizeArgs490)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA490 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1658 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA490 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA490 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA490 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA490 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec490 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1658 PRE_first_tail_x15_r0_body.sizeTys490 PRE_first_tail_x15_r0_body.sizeArgs490).run PRE_first_tail_x15_r0_body.S1658
noncomputable def PRE_first_tail_x15_r0_body.sizeAs490 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec490 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0490 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec490 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1658
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA490 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1658 PRE_first_tail_x15_r0_body.sizeTys490 PRE_first_tail_x15_r0_body.sizeArgs490).run PRE_first_tail_x15_r0_body.S1658 =
  some (some PRE_first_tail_x15_r0_body.sizeAs490, PRE_first_tail_x15_r0_body.sizeS0490)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA490 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0490 PRE_first_tail_x15_r0_body.s1658.ffi PRE_first_tail_x15_r0_body.sizeAs490 = true
/-- Bridge 491's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys491 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1661 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs491 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1661 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA491 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1661 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys491, PRE_first_tail_x15_r0_body.sizeArgs491)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA491 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1661 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA491 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA491 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA491 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA491 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec491 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1661 PRE_first_tail_x15_r0_body.sizeTys491 PRE_first_tail_x15_r0_body.sizeArgs491).run PRE_first_tail_x15_r0_body.S1661
noncomputable def PRE_first_tail_x15_r0_body.sizeAs491 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec491 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0491 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec491 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1661
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA491 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1661 PRE_first_tail_x15_r0_body.sizeTys491 PRE_first_tail_x15_r0_body.sizeArgs491).run PRE_first_tail_x15_r0_body.S1661 =
  some (some PRE_first_tail_x15_r0_body.sizeAs491, PRE_first_tail_x15_r0_body.sizeS0491)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA491 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0491 PRE_first_tail_x15_r0_body.s1661.ffi PRE_first_tail_x15_r0_body.sizeAs491 = true
/-- Bridge 492's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys492 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1664 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs492 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1664 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA492 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1664 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys492, PRE_first_tail_x15_r0_body.sizeArgs492)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA492 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1664 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA492 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA492 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA492 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA492 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec492 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1664 PRE_first_tail_x15_r0_body.sizeTys492 PRE_first_tail_x15_r0_body.sizeArgs492).run PRE_first_tail_x15_r0_body.S1664
noncomputable def PRE_first_tail_x15_r0_body.sizeAs492 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec492 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0492 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec492 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1664
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA492 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1664 PRE_first_tail_x15_r0_body.sizeTys492 PRE_first_tail_x15_r0_body.sizeArgs492).run PRE_first_tail_x15_r0_body.S1664 =
  some (some PRE_first_tail_x15_r0_body.sizeAs492, PRE_first_tail_x15_r0_body.sizeS0492)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA492 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0492 PRE_first_tail_x15_r0_body.s1664.ffi PRE_first_tail_x15_r0_body.sizeAs492 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA493 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1667 "appendWindow" none = true
/-- Bridge 494's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeTys494 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1671 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def PRE_first_tail_x15_r0_body.sizeArgs494 : List Val := match Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1671 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl PRE_first_tail_x15_r0_body.sizeA494 : Host.Ts.Sim.Disp.sizeParts PRE_first_tail_x15_r0_body.s1671 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", PRE_first_tail_x15_r0_body.sizeTys494, PRE_first_tail_x15_r0_body.sizeArgs494)
kernel_rfl PRE_first_tail_x15_r0_body.sizeArgsA494 : Host.Ts.Sim.Disp.sizeArgsOk PRE_first_tail_x15_r0_body.s1671 = true
kernel_rfl PRE_first_tail_x15_r0_body.sizeSymA494 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl PRE_first_tail_x15_r0_body.sizeMlxA494 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl PRE_first_tail_x15_r0_body.sizePayA494 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl PRE_first_tail_x15_r0_body.sizeTaA494 : [2665, 2673467, 2673472, 2673473].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def PRE_first_tail_x15_r0_body.sizeDec494 := interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1671 PRE_first_tail_x15_r0_body.sizeTys494 PRE_first_tail_x15_r0_body.sizeArgs494).run PRE_first_tail_x15_r0_body.S1671
noncomputable def PRE_first_tail_x15_r0_body.sizeAs494 : List Arg := match PRE_first_tail_x15_r0_body.sizeDec494 with | some (some xs, _) => xs | _ => []
noncomputable def PRE_first_tail_x15_r0_body.sizeS0494 : SSrv := match PRE_first_tail_x15_r0_body.sizeDec494 with | some (_, S) => S | none => PRE_first_tail_x15_r0_body.S1671
kernel_rfl PRE_first_tail_x15_r0_body.sizeDecA494 : interpS (decodeArgs PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1671 PRE_first_tail_x15_r0_body.sizeTys494 PRE_first_tail_x15_r0_body.sizeArgs494).run PRE_first_tail_x15_r0_body.S1671 =
  some (some PRE_first_tail_x15_r0_body.sizeAs494, PRE_first_tail_x15_r0_body.sizeS0494)
kernel_rfl PRE_first_tail_x15_r0_body.sizePreA494 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB PRE_first_tail_x15_r0_body.sizeS0494 PRE_first_tail_x15_r0_body.s1671.ffi PRE_first_tail_x15_r0_body.sizeAs494 = true
kernel_rfl PRE_first_tail_x15_r0_body.callA495 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1674 "rowBlocks" none = true
kernel_rfl PRE_first_tail_x15_r0_body.callA496 : Host.Ts.Sim.Template.isCallOf PRE_first_tail_x15_r0_body.s1678 "plan" none = true
end Host.Load.Run.Tpl
