import host.sim.template.a4pre_first_tail_x15_r0_body.H56
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 186 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1801` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa186` into the merged state
`PRE_first_tail_x15_r0_body.s1800`. -/

def PRE_first_tail_x15_r0_body.pl186 : List Nat := [2822359, 2821534, 2822365, 2822361, 2821536, 2822367]
def PRE_first_tail_x15_r0_body.nr186 : List Nat := [8066, 8065, 8041, 8049, 8054, 8059, 8064, 8038, 8039, 8040, 8047, 8048, 8036, 8043, 8044, 8045, 8046, 8042]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd186 : RData :=
  ⟨2821253, 2822402, Stage.setAll PTrie.nil [(2821247, 2822359), (2821248, 2821534), (2821249, 2822365), (2821250, 2822361), (2821251, 2821536), (2821252, 2822367)], Stage.setAll PTrie.nil [(21870, 21896), (21871, 21874), (21872, 21897)],
   21873, 21898, 18986, 18986, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(8036, .ref 8066), (8037, .ref 8065), (8038, .ref 8041), (8039, .ref 8049), (8040, .ref 8054), (8041, .ref 8059), (8042, .ref 8064), (8043, .ref 8038), (8044, .ref 8039), (8045, .ref 8040), (8046, .ref 8047), (8047, .ref 8048), (8048, .ref 8036), (8049, .ref 8043), (8050, .ref 8044), (8051, .ref 8045), (8052, .ref 8046), (8053, .ref 8042)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa186 : Map :=
  Conv.Map.compact 2821247 2822402 8036 PRE_first_tail_x15_r0_body.pl186 (PRE_first_tail_x15_r0_body.nr186.map NumV.ref) PRE_first_tail_x15_r0_body.kd186.big
    PRE_first_tail_x15_r0_body.kd186.region PRE_first_tail_x15_r0_body.kd186.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws186 : List Nat := [4178, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189, 4190, 4191, 4192, 4193, 4194, 4195]
noncomputable def PRE_first_tail_x15_r0_body.crs186 : List SymE := PRE_first_tail_x15_r0_body.nr186.map fun r => (nth? PRE_first_tail_x15_r0_body.S1800.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta186 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws186 PRE_first_tail_x15_r0_body.crs186
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB186 : List Nat := [2665, 2672775, 2673467, 2820421, 2820966, 2821222]

kernel_rfl PRE_first_tail_x15_r0_body.ctab186 : PRE_first_tail_x15_r0_body.S1801.tab = PRE_first_tail_x15_r0_body.S1799.tab ++ PRE_first_tail_x15_r0_body.cws186.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace186 : PRE_first_tail_x15_r0_body.s1801.trace = PRE_first_tail_x15_r0_body.s1799.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext186 : PRE_first_tail_x15_r0_body.s1801.next = 2821253
kernel_rfl PRE_first_tail_x15_r0_body.ccounters186 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.nnext) = (21873, 18986)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue186 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1800.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa186.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp186 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.tokens.all (bSN 8054) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean186 : Conv.cleanListB 21873 131072 (fun r => Nat.ble 87492 r) PRE_first_tail_x15_r0_body.s1801
    (PRE_first_tail_x15_r0_body.wrB186 ++ (List.range 6).map (2821247 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs186 : bigsOutB 21873 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx = true

end Host.Load.Run.Tpl
