import host.ts.Source
namespace Host.Ts.Sources.Inference.Runtime.RowOperations
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/runtime/row-operations.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"type RowTable<Operation> = Readonly<Partial<Record<number, Operation>> & { readonly default?: Operation }>;
type RowOperations<Operation> = RowTable<Operation> |
  readonly { readonly from: number; readonly to: number; readonly operation: Operation }[];

/** Index authored exact rows, an explicit default, or authored contiguous ranges. */
export function rowOperationFor<Operation>(operations: readonly {readonly from:number;readonly to:number;readonly operation:Operation}[], rows:number):Operation;
export function rowOperationFor<Operation>(operations: RowTable<Operation>, rows:number):Operation;
export function rowOperationFor<Operation>(operations: RowOperations<Operation>, rows:number):Operation;
export function rowOperationFor<Operation>(operations: RowOperations<Operation>, rows: number): Operation {
  let operation: Operation | undefined;
  if (Number.isSafeInteger(rows) && rows > 0) {
    operation = Array.isArray(operations)
      ? operations.find(range => rows >= range.from && rows <= range.to)?.operation
      : (Object.hasOwn(operations, rows) ? (operations as RowTable<Operation>)[rows] : undefined)
        ?? (Object.hasOwn(operations, "default") ? (operations as RowTable<Operation>).default : undefined);
  }
  if (operation === undefined) throw new Error(`no declared operation for ${rows} rows`);
  return operation;
}

/** Compatibility data helper. Its default is an ordinary inspectable own property. */
export function rowTableWithDefault<Operation>(entries: RowTable<Operation>, defaultOperation: Operation): RowTable<Operation> {
  return Object.freeze({ ...entries, default: defaultOperation });
}

/** Map only authored entries, ranges and an explicitly present default. */
export function mapOperations<Input,Output>(operations: readonly {readonly from:number;readonly to:number;readonly operation:Input}[], bind:(operation:Input)=>Output): readonly {readonly from:number;readonly to:number;readonly operation:Output}[];
export function mapOperations<Input,Output>(operations: RowTable<Input>, bind:(operation:Input)=>Output):RowTable<Output>;
export function mapOperations<Input,Output>(operations: RowOperations<Input>, bind:(operation:Input)=>Output):RowOperations<Output>;
export function mapOperations<Input, Output>(operations: RowOperations<Input>,
  bind: (operation: Input) => Output): RowOperations<Output> {
  if (Array.isArray(operations))
    return Object.freeze(operations.map(range => Object.freeze({ from: range.from, to: range.to, operation: bind(range.operation) })));
  const source = operations as RowTable<Input>, entries: Partial<Record<number, Output>> & { default?: Output } = {};
  for (const [key, operation] of Object.entries(source)) {
    if (operation === undefined) continue;
    const rows = Number(key);
    if (key === "default") entries.default = bind(operation);
    else if (Number.isSafeInteger(rows) && rows > 0 && String(rows) === key) entries[rows] = bind(operation);
  }
  return Object.freeze(entries);
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Runtime.RowOperations
