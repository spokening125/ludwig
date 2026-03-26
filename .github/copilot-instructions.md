This repo: Ludwig (lattice Boltzmann simulations in ANSI C, MPI + optional GPU/threads)

Quick context for an AI code assistant (concise, actionable):

- Big picture
  - Core code in `src/` (physics, timestepping, I/O). The driver is `src/main.c` which calls `ludwig_run()` and expects an `input` file in the current working directory.
  - Parallelization: MPI is used throughout (`MPI_Init_thread` in `src/main.c`, many headers include `<mpi.h>`). TargetDP provides an abstraction for threaded/GPU kernels (look for `target/` and `util/` code).
  - Build targets live in `Makefile` (top-level) and `Makefile.mk` under `mycode/ludwig/`. Platform-specific compiler settings are in `config/*.mk` (e.g. `unix-gcc-default.mk`, `unix-mpicc-default.mk`, CUDA/HIP variants).

- What to edit/where to be careful
  - When changing core numeric kernels prefer `src/` and `target/` implementations. GPU/Host variants are often separated; changing one file may require touching corresponding TargetDP wrappers.
  - I/O formats and test inputs are under `test/` (look at `test/input` and `test/back/` for examples of restart/config files). Tests and examples expect the input file to be named exactly `input`.
  - Build behaviour is configured by copying a `config/*.mk` to `config.mk` at repository root (see README). Many CI and platform builds rely on these files.

- Build / test / debug workflows (concrete commands)
  - Local serial build (recommended for quick edits):
    - cp config/unix-gcc-default.mk config.mk
    - make serial
    - make
    - make test
  - MPI build:
    - cp config/unix-mpicc-default.mk config.mk
    - make
    - make test
  - To run the compiled binary in MPI: use your system's mpirun/mpiexec. The binary reads `input` from CWD.
    - Example: mpirun -np 4 ./ludwig
  - Documentation build: cd docs && make (generates PDF from LaTeX sources)

- Coding patterns & conventions (repo-specific)
  - ANSI C style and plain make. Keep code compatible with strict C compilers; watch types and header includes.
  - Testing uses `assert()`; tests expect assertions enabled. For production builds, `-DNDEBUG` is added in `config.mk`.
  - Minimal command-line interface: `main` no longer accepts arbitrary args; input file must be `input`.
  - TargetDP abstractions: search for `target` or `targetdp` when implementing new parallel kernels to ensure both CPU and GPU paths.

- Key files and where to find examples
  - Driver: `src/main.c` (MPI init, PetscOptional init, calls `ludwig_run()`)
  - Build: `Makefile`, `Makefile.mk`, `config/*.mk`
  - Parallel/accelerator layer: `target/` (and `util/` for helpers)
  - Tests & sample inputs: `test/` (see `test/input`, `test/back/` subfolders)
  - PETSc facades: `util_petsc.*` (PETSc is optional and can be stubbed if not present)

- Integration points / external deps
  - MPI: required for parallel builds. Many files include `<mpi.h>` and expect MPI runtime.
  - PETSc: optional; initialized in `main.c` via `PetscInitialize()`; code includes `util_petsc.*` wrappers.
  - cJSON: vendored under `src/` (MIT) for JSON parsing where used.

- Fast checks an AI might run before editing
  - Confirm build config: check `config.mk` presence and which `config/*.mk` was copied.
  - Run `make` and `make test` locally (or in CI) to ensure changes don't break tests.
  - Search for `MPI_Comm_rank`/`MPI_Init` when modifying code paths that must be rank-aware.

- Examples to reference in PRs / commits
  - "Follow src/main.c pattern when adding init/finalize code (MPI + Petsc)."
  - "When adding a kernel, implement both host and targetDP wrappers under `target/` and update `target/Makefile` if necessary."

If anything here is unclear or you want more examples (e.g. specific source-function mappings, common macros, or a short list of tests to run for PR validation), tell me which area to expand and I'll iterate.