import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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

/-! The compaction after the merge at call site 90 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s881` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa90` into the merged state
`PRE_first_tail_x15_r0_body.s880`. -/

def PRE_first_tail_x15_r0_body.pl90 : List Nat := [2746999, 2746174, 2747005, 2747001, 2746176, 2747007]
def PRE_first_tail_x15_r0_body.nr90 : List Nat := [3962, 3961, 3937, 3945, 3950, 3955, 3960, 3934, 3935, 3936, 3943, 3944, 3932, 3939, 3940, 3941, 3942, 3938]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd90 : RData :=
  ⟨2745893, 2747042, Stage.setAll PTrie.nil [(2745887, 2746999), (2745888, 2746174), (2745889, 2747005), (2745890, 2747001), (2745891, 2746176), (2745892, 2747007)], Stage.setAll PTrie.nil [(19982, 20008), (19983, 19986), (19984, 20009)],
   19985, 20010, 17090, 17090, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3932, .ref 3962), (3933, .ref 3961), (3934, .ref 3937), (3935, .ref 3945), (3936, .ref 3950), (3937, .ref 3955), (3938, .ref 3960), (3939, .ref 3934), (3940, .ref 3935), (3941, .ref 3936), (3942, .ref 3943), (3943, .ref 3944), (3944, .ref 3932), (3945, .ref 3939), (3946, .ref 3940), (3947, .ref 3941), (3948, .ref 3942), (3949, .ref 3938)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa90 : Map :=
  Conv.Map.compact 2745887 2747042 3932 PRE_first_tail_x15_r0_body.pl90 (PRE_first_tail_x15_r0_body.nr90.map NumV.ref) PRE_first_tail_x15_r0_body.kd90.big
    PRE_first_tail_x15_r0_body.kd90.region PRE_first_tail_x15_r0_body.kd90.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws90 : List Nat := [2538, 2539, 2540, 2541, 2542, 2543, 2544, 2545, 2546, 2547, 2548, 2549, 2550, 2551, 2552, 2553, 2554, 2555]
noncomputable def PRE_first_tail_x15_r0_body.crs90 : List SymE := PRE_first_tail_x15_r0_body.nr90.map fun r => (nth? PRE_first_tail_x15_r0_body.S880.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta90 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws90 PRE_first_tail_x15_r0_body.crs90
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB90 : List Nat := [2665, 2672527, 2673467, 2745061, 2745606, 2745862]

kernel_rfl PRE_first_tail_x15_r0_body.ctab90 : PRE_first_tail_x15_r0_body.S881.tab = PRE_first_tail_x15_r0_body.S879.tab ++ PRE_first_tail_x15_r0_body.cws90.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace90 : PRE_first_tail_x15_r0_body.s881.trace = PRE_first_tail_x15_r0_body.s879.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext90 : PRE_first_tail_x15_r0_body.s881.next = 2745893
kernel_rfl PRE_first_tail_x15_r0_body.ccounters90 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nnext) = (19985, 17090)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue90 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s880.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa90.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp90 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.tokens.all (bSN 3950) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean90 : Conv.cleanListB 19985 131072 (fun r => Nat.ble 79940 r) PRE_first_tail_x15_r0_body.s881
    (PRE_first_tail_x15_r0_body.wrB90 ++ (List.range 6).map (2745887 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs90 : bigsOutB 19985 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx = true

end Host.Load.Run.Tpl
