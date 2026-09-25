// Bun resolves process.execPath lazily. The CLI imports this module before
// dispatch so a later installer symlink swap cannot redirect child processes
// into a different release. Source execution captures the Bun runtime instead.
// Job and isolation workers must share this startup identity.
export const executablePath = process.execPath;
