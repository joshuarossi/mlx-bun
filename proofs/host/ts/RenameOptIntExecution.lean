import host.ts.ast.mlx.Ffi
import host.ts.RenameIntegerPacking
import host.ts.RenameRouteComposition

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.F64

theorem uint32_ofNat (n : Nat) (bound : n < 2^32) : toUint32 (ofNat n) = n := by
  have small : n < 2^53 := by omega
  have trunc : truncInt (ofNat n) = some (Int.ofNat n) := by
    rw [ofNat_exact53 n small]
    cases n <;> simp [natExact,truncInt]
  simp only [toUint32,trunc,modNat,Int.ofNat_eq_natCast]
  rw [Int.emod_eq_of_lt (by omega) (by omega)]
  rfl

theorem ushr_zero_ofNat (n : Nat) (bound : n < 2^32) :
    bin .ushr (ofNat n) (.zero false) = ofNat n := by
  change ofNat (toUint32 (ofNat n) >>> 0) = ofNat n
  rw [uint32_ofNat n bound,Nat.shiftRight_zero]

end Host.Ts.F64
namespace Host.Ts.Owned.Annotated

noncomputable def optIntFunction : Func := Sources.Mlx.Ffi.ast_n33
noncomputable def optIntStatements : List Stmt := [Sources.Mlx.Ffi.ast_n31,Sources.Mlx.Ffi.ast_n32]

theorem optInt_function_source : optIntFunction = .mk (some chars!"optInt") [.id chars!"value"] none
    (.block optIntStatements) false false [] := rfl

/-- All non-null optional-int body transitions are the pinned source AST.
The heap/caller/counter are arbitrary and are unchanged by these transitions. -/
theorem run_optInt_body (F : Ffi) (s : St F.S) (C : CSrv) (env : Env)
    (parameter bigintFn : Nat) (global builtin : Obj) (data : List Val) (w e : Bool) (n : Nat) (bound : n < 2^32)
    (parameterLookup : lookupEnv chars!"value" env = some parameter)
    (bigintLookup : lookupEnv chars!"BigInt" env = none)
    (parameterRead : s.heap.get parameter = some (.cell (some (.num (.lit (F64.ofNat n))))))
    (globalRead : s.heap.get aGlobal = some (.obj global))
    (globalKind : global.kind = .ordinary)
    (globalProperty : findProp (.str chars!"BigInt") global.props = some (.data (.obj bigintFn) w e))
    (builtinRead : s.heap.get bigintFn = some (.obj builtin))
    (builtinKind : builtin.kind = .fn (.native (.num .bigint) data)) :
    runC F 36 (enterBlock (s.push (.k (.fn .call))) optIntStatements env) C =
      some (s.ret (.big (Int.ofNat (packedOptInt n))),C) := by
  have zero : F64.ofLit chars!"0" = some (.zero false) := rfl
  have mask : F64.parseIntLit chars!"0xffffffff" = some (2^32-1) := rfl
  have one : F64.parseIntLit chars!"1" = some 1 := rfl
  have thirtyTwo : F64.parseIntLit chars!"32" = some 32 := rfl
  have flag : ((1:Nat):Int) * ((2^32:Nat):Int) = Int.ofNat (2^32) := rfl
  have shifted := F64.ushr_zero_ofNat n bound
  have decoded := F64.toInt_ofNat53 n (by omega)
  simp only [runC,runWith_succ,runWith_zero,Bool.cond_false,Bool.false_and,List.nil_append,List.append_nil,List.reverse_cons,List.reverse_nil,Host.Ts.arg,nthD,optIntStatements,Sources.Mlx.Ffi.ast_n30,Sources.Mlx.Ffi.ast_n31,Sources.Mlx.Ffi.ast_n32,enterBlock,hoist,blockNames,stmtNames,St.push,St.go,St.ret,isHalt,step,stepRet,stepAbr,evStep,exStep,retStep,retSt,retE,retC,abrStep,abrSt,abrK,boundaryAbr,readVar,parameterLookup,bigintLookup,St.cell?,parameterRead,getChain,ownGet,readProp,St.obj?,globalRead,globalKind,globalProperty,builtinRead,builtinKind,callStep,evCall,argsNext,isNullish,callNative,numN,evLit,binOp,strictEq,arith,bigOp,bigNat2,toNum,numOp?,numBin,truthy,zero,mask,one,thirtyTwo,shifted,decoded,flag,packedOptInt,retS,M.run,M.bind,M.pure,interpC_pure,St.rebuild_eq]
  rfl

/-- The null branch returns before reading the BigInt global. -/
theorem run_optInt_null_body (F : Ffi) (s : St F.S) (C : CSrv) (env : Env) (parameter : Nat)
    (parameterLookup : lookupEnv chars!"value" env = some parameter)
    (parameterRead : s.heap.get parameter = some (.cell (some .null))) :
    runC F 14 (enterBlock (s.push (.k (.fn .call))) optIntStatements env) C = some (s.ret (.big 0),C) := by
  have zero : F64.parseIntLit chars!"0" = some 0 := rfl
  simp only [runC,runWith_succ,runWith_zero,Bool.cond_false,Bool.cond_true,optIntStatements,Sources.Mlx.Ffi.ast_n30,Sources.Mlx.Ffi.ast_n31,Sources.Mlx.Ffi.ast_n32,enterBlock,hoist,blockNames,stmtNames,List.nil_append,St.push,St.go,St.ret,isHalt,step,stepRet,stepAbr,evStep,exStep,retStep,retSt,retE,abrStep,abrSt,abrK,boundaryAbr,readVar,parameterLookup,St.cell?,parameterRead,evLit,binOp,strictEq,truthy,zero,retS,M.run,M.bind,M.pure,interpC_pure,St.rebuild_eq]
  rfl

end Host.Ts.Owned.Annotated
