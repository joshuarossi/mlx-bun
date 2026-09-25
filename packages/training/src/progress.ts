/** Training-owned progress. App jobs may map these observations to their own
 * persistence or wire events; the training library never owns a job lifecycle. */
export type TrainingProgress =
  | {
      type: "stage";
      stage: string;
      progress?: number;
      message?: string;
      adapter_path?: string;
      applied_ranks?: Record<string, number>;
    }
  | {
      type: "metric";
      kind: "train" | "val";
      step: number;
      loss: number;
      learning_rate?: number;
      tokens_per_sec?: number;
      progress?: number;
      message?: string;
      grad_norm?: number;
      accuracy?: number;
      margin?: number;
      n_correct?: number;
      n_total?: number;
      val_rows_used?: number;
      val_rows_skipped?: number;
      peak_gb?: number;
      active_gb?: number;
      pinned?: number;
    };

/** Called synchronously on the training thread. Observers must not throw. */
export type TrainingProgressCallback = (progress: TrainingProgress) => void;
