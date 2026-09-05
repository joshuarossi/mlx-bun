/** A single owner. Borrowing does not extend lifetime; transfer invalidates
 * the old owner. close is idempotent, including when release throws. */
export interface ResourceOwner<T> {
  borrow(): T;
  transfer(): T;
  close(): void;
}

/** State views may own temporary handles or borrow live state. Consumers
 * always close the lease; only the provider knows which handles to release. */
export interface StateView<T> {
  borrow(): readonly T[];
  close(): void;
}

export interface DisposableResource {
  dispose(): void;
}
