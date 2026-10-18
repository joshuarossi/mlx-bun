import host.ts.RenameRouteDriverStructural
namespace Host.Ts.Owned.Parametric

theorem ControlR.isHalt_eq {NR : NumV → NumV → Prop} {R : Ren}
    {c c' : Ctl} (h : ControlR NR R c c') : isHalt c' = isHalt c := by
  have ht := h.tag_eq
  cases c <;> cases c' <;> simp_all [Encode.ctl,treeTag,isHalt]

theorem runC_cons (F : Ffi) (n : Nat) (s t u : St F.S) (C D E : CSrv)
    (hh : isHalt s.ctl = false)
    (hs : interpC (step F s).run C = some (t,D))
    (ht : runC F n t D = some (u,E)) : runC F (n+1) s C = some (u,E) := by
  change runWith F interpC (n+1) s C = _
  rw [runWith_succ,hh,Bool.cond_false,hs]
  dsimp only
  rw [St.rebuild_eq]
  exact ht

end Host.Ts.Owned.Parametric
