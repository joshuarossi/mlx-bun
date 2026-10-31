import host.sim.template.a4pre_first_tail_x15_r0.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 1 of chain `PRE_first_tail_x15_r0` (boundaries 6 to 17): the native bookkeeping's step. -/

def PRE_first_tail_x15_r0.gh1 : List Nat := []
def PRE_first_tail_x15_r0.gn1 : List Nat := []
def PRE_first_tail_x15_r0.gi1 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0.gkA1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx.arrs (PRE_first_tail_x15_r0.gh1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gkO1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx.objs (PRE_first_tail_x15_r0.gh1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gkN1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx.nodes (PRE_first_tail_x15_r0.gn1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gkI1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx.items (PRE_first_tail_x15_r0.gi1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gbd1 : (PRE_first_tail_x15_r0.gh1 ++ PRE_first_tail_x15_r0.gn1 ++ PRE_first_tail_x15_r0.gi1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.gle1 : Conv.Cnt.leB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0.gck1 : Conv.ncleanListB (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx PRE_first_tail_x15_r0.gh1 PRE_first_tail_x15_r0.gn1 PRE_first_tail_x15_r0.gi1 = true
theorem PRE_first_tail_x15_r0.gncl1 (h : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx) : Conv.NClean (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0.gle1 PRE_first_tail_x15_r0.gkA1 PRE_first_tail_x15_r0.gkO1 PRE_first_tail_x15_r0.gkN1 PRE_first_tail_x15_r0.gkI1 PRE_first_tail_x15_r0.gbd1 PRE_first_tail_x15_r0.gck1

-- the JS bookkeeping's step
def PRE_first_tail_x15_r0.gjh1 : List Nat := [2673294, 2673295, 2673296, 2673297, 2673298, 2673299, 2673300, 2673301, 2673302, 2673303, 2673304, 2673305, 2673306, 2673307, 2673308, 2673309, 2673310, 2673311, 2673312, 2673313, 2673314, 2673315, 2673316, 2673317, 2673318, 2673319, 2673320, 2673321, 2673322, 2673323, 2673324, 2673325, 2673326, 2673327, 2673328, 2673329, 2673330, 2673331, 2673332, 2673333, 2673334, 2673335, 2673336, 2673337, 2673338, 2673339, 2673340, 2673341, 2673342, 2673343, 2673344, 2673345, 2673346, 2673347, 2673348, 2673349, 2673350, 2673351, 2673352, 2673353, 2673354, 2673355, 2673356, 2673357, 2673358, 2673359, 2673360, 2673361, 2673362, 2673363, 2673364, 2673365, 2673366, 2673367, 2673368, 2673369, 2673370, 2673371, 2673372, 2673373, 2673374, 2673375, 2673376, 2673377, 2673378, 2673379, 2673380, 2673381, 2673382, 2673383, 2673384, 2673385, 2673386, 2673387, 2673388, 2673389, 2673390, 2673391, 2673392, 2673393, 2673394, 2673395, 2673396, 2673397, 2673398, 2673399, 2673400, 2673401, 2673402, 2673403, 2673404, 2673405, 2673406, 2673407, 2673408, 2673409, 2673410, 2673411, 2673412, 2673413, 2673414, 2673415, 2673416, 2673417, 2673418, 2673419, 2673420, 2673421, 2673422, 2673423, 2673424, 2673425, 2673426, 2673427, 2673428, 2673429, 2673430, 2673431, 2673432, 2673433, 2673434, 2673435, 2673436, 2673437, 2673438, 2673439, 2673440, 2673441, 2673442, 2673443, 2673444, 2673445, 2673446, 2673447, 2673448, 2673449, 2673450, 2673451, 2673452, 2673453, 2673454, 2673455, 2673456]
kernel_rfl PRE_first_tail_x15_r0.gjk1 : PRE_first_tail_x15_r0.s17.heap = Stage.setAll PRE_first_tail_x15_r0.s6.heap (PRE_first_tail_x15_r0.gjh1.filterMap fun a => (PRE_first_tail_x15_r0.s17.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0.gjbd1 : PRE_first_tail_x15_r0.gjh1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.gjc1 : Conv.jcleanListB (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s17 PRE_first_tail_x15_r0.gjh1 = true
theorem PRE_first_tail_x15_r0.gjcl1 (h : Conv.JClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s6) : Conv.JClean (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s17 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0.gle1)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0.gjk1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0.gjbd1 a ha)) PRE_first_tail_x15_r0.gjc1

end Host.Load.Run.Tpl
