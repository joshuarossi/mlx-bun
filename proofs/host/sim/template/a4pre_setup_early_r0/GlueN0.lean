import host.sim.template.a4pre_setup_early_r0.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 0 of chain `PRE_setup_early_r0` (boundaries 0 to 4): the native bookkeeping's step. -/

def PRE_setup_early_r0.gh0 : List Nat := [18151, 18152, 18153, 18154]
def PRE_setup_early_r0.gn0 : List Nat := []
def PRE_setup_early_r0.gi0 : List Nat := []
kernel_rfl PRE_setup_early_r0.gkA0 : (Host.Load.Layers.toLoad PRE_setup_early_r0.s4.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.arrs (PRE_setup_early_r0.gh0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_early_r0.s4.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_setup_early_r0.gkO0 : (Host.Load.Layers.toLoad PRE_setup_early_r0.s4.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.objs (PRE_setup_early_r0.gh0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_early_r0.s4.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_setup_early_r0.gkN0 : (Host.Load.Layers.toLoad PRE_setup_early_r0.s4.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.nodes (PRE_setup_early_r0.gn0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_early_r0.s4.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_setup_early_r0.gkI0 : (Host.Load.Layers.toLoad PRE_setup_early_r0.s4.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.items (PRE_setup_early_r0.gi0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_early_r0.s4.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_setup_early_r0.gbd0 : (PRE_setup_early_r0.gh0 ++ PRE_setup_early_r0.gn0 ++ PRE_setup_early_r0.gi0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_setup_early_r0.gle0 : Conv.Cnt.leB (⟨18151, 15235, 2673202, 9⟩ : Conv.Cnt) (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) = true
kernel_rfl PRE_setup_early_r0.gck0 : Conv.ncleanListB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s4.ffi).mlx PRE_setup_early_r0.gh0 PRE_setup_early_r0.gn0 PRE_setup_early_r0.gi0 = true
theorem PRE_setup_early_r0.gncl0 (h : Conv.NClean (⟨18151, 15235, 2673202, 9⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx) : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s4.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_setup_early_r0.gle0 PRE_setup_early_r0.gkA0 PRE_setup_early_r0.gkO0 PRE_setup_early_r0.gkN0 PRE_setup_early_r0.gkI0 PRE_setup_early_r0.gbd0 PRE_setup_early_r0.gck0

-- the JS bookkeeping's step
def PRE_setup_early_r0.gjh0 : List Nat := [899, 900, 2589, 2673202, 2673203, 2673204, 2673205, 2673206, 2673207, 2673208, 2673209, 2673210, 2673211, 2673212, 2673213, 2673214, 2673215, 2673216, 2673217, 2673218, 2673219, 2673220, 2673221, 2673222, 2673223, 2673224, 2673225, 2673226, 2673227, 2673228, 2673229, 2673230, 2673231, 2673232, 2673233, 2673234, 2673235, 2673236, 2673237, 2673238, 2673239, 2673240, 2673241, 2673242, 2673243, 2673244, 2673245, 2673246, 2673247, 2673248, 2673249, 2673250, 2673251, 2673252, 2673253, 2673254, 2673255, 2673256, 2673257, 2673258, 2673259, 2673260, 2673261, 2673262, 2673263, 2673264, 2673265, 2673266, 2673267, 2673268, 2673269, 2673270, 2673271, 2673272, 2673273, 2673274, 2673275, 2673276, 2673277, 2673278, 2673279, 2673280, 2673281, 2673282, 2673283, 2673284, 2673285, 2673286, 2673287, 2673288, 2673289, 2673290, 2673291, 2673292, 2673293, 2673294, 2673295, 2673296, 2673297, 2673298, 2673299, 2673300, 2673301, 2673302, 2673303, 2673304, 2673305, 2673306, 2673307, 2673308, 2673309, 2673310, 2673311, 2673312, 2673313, 2673314, 2673315, 2673316, 2673317, 2673318, 2673319, 2673320, 2673321, 2673322, 2673323, 2673324, 2673325, 2673326, 2673327, 2673328, 2673329, 2673330, 2673331, 2673332, 2673333, 2673334, 2673335]
kernel_rfl PRE_setup_early_r0.gjk0 : PRE_setup_early_r0.s4.heap = Stage.setAll PRE_setup_early_r0.s0.heap (PRE_setup_early_r0.gjh0.filterMap fun a => (PRE_setup_early_r0.s4.heap.get a).map (a, ·))
kernel_rfl PRE_setup_early_r0.gjbd0 : PRE_setup_early_r0.gjh0.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_setup_early_r0.gjc0 : Conv.jcleanListB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_early_r0.s4 PRE_setup_early_r0.gjh0 = true
theorem PRE_setup_early_r0.gjcl0 (h : Conv.JClean (⟨18151, 15235, 2673202, 9⟩ : Conv.Cnt) PRE_setup_early_r0.s0) : Conv.JClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_early_r0.s4 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_setup_early_r0.gle0)
    (Conv.heap_off_setAll PRE_setup_early_r0.gjk0 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_setup_early_r0.gjbd0 a ha)) PRE_setup_early_r0.gjc0

end Host.Load.Run.Tpl
