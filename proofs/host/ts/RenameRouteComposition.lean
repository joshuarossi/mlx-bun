import host.ts.RenameRouteDriverStructural
import host.ts.Chunk
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

theorem runC_join (F : Ffi) {m n : Nat} {a b c : St F.S} {C D E : CSrv}
    (h₁ : runC F m a C = some (b,D)) (h₂ : runC F n b D = some (c,E)) :
    runC F (m+n) a C = some (c,E) := by
  unfold runC at *
  rw [runWith_add,h₁]
  exact h₂
end Host.Ts.Owned.Parametric
