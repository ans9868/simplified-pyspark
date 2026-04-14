# simplified-pyspark

Minimal standalone PySpark portability example for:

- Docker
- Singularity/Apptainer
- HPC-style environments with remapped runtime UIDs

This repo is intentionally small and comes with a longer writeup in [ARTICLE_DRAFT.md](https://github.com/ans9868/simplified-pyspark/blob/main/ARTICLE_DRAFT.md).

## Variants

- `baseline/`: intentionally minimal starting point that reproduces failure modes
- `fixed/`: portability-oriented version with runtime user repair, writable runtime paths, and safer Spark defaults

If you want one version to actually reuse, start with `fixed`.

## Quickstart

Build and run with `make`:

```bash
make build-baseline
make build-fixed

make run-baseline
make run-fixed
```

Local Singularity targets:

```bash
make build-singularity-baseline
make build-singularity-fixed

make run-singularity-baseline
make run-singularity-fixed
```

Useful extra targets:

```bash
make run-baseline-random-uid
make run-fixed-random-uid
make run-baseline-udf
make run-fixed-udf
make run-baseline-udtf
make run-fixed-udtf
```

## Without Make

Docker:

```bash
docker build -f baseline/Dockerfile -t simplified-pyspark:baseline .
docker build -f fixed/Dockerfile -t simplified-pyspark:fixed .

docker run --rm simplified-pyspark:baseline
docker run --rm simplified-pyspark:fixed
```

Local Singularity from local Docker images:

```bash
mkdir -p images

singularity build images/simplified-pyspark-baseline.sif \
  docker-daemon://simplified-pyspark:baseline

singularity build images/simplified-pyspark-fixed.sif \
  docker-daemon://simplified-pyspark:fixed
```

Run with the local/basic flags used in this repo:

```bash
singularity run --no-mount tmp --cleanenv --writable-tmpfs \
  images/simplified-pyspark-baseline.sif

singularity run --no-mount tmp --cleanenv --writable-tmpfs \
  --env HADOOP_CONF_DIR=/tmp \
  --env HADOOP_HOME=/tmp \
  --env "JAVA_TOOL_OPTIONS=-Djava.security.auth.login.config= -Dhadoop.security.authentication=simple -Dhadoop.security.authorization=false" \
  --bind /etc/passwd:/etc/passwd:ro \
  --bind /etc/group:/etc/group:ro \
  images/simplified-pyspark-fixed.sif
```

If the multi-arch images have been published, you can also build from the registry instead of `docker-daemon://...`.

## HPC Note

HPC Singularity commands are intentionally not wrapped in `make`.

In practice they usually depend on site-specific details such as:

- account
- partition
- walltime
- `srun` vs `sbatch`
- cache and temp directory policy

The usual pattern is:

- use `srun ... --pty bash` for an interactive compute-node shell
- use `sbatch` for a batch job
- keep `APPTAINER_CACHEDIR` on shared storage such as `$SCRATCH`
- keep `APPTAINER_TMPDIR` on node-local storage such as `$SLURM_TMPDIR`

Example:

```bash
export APPTAINER_CACHEDIR=/scratch/$USER/.apptainer/cache
export APPTAINER_TMPDIR=${SLURM_TMPDIR:-/tmp/$USER-apptainer}
export TMPDIR=$APPTAINER_TMPDIR
```

For the full debugging story, exact failure messages, and the rationale behind `baseline` vs `fixed`, see [ARTICLE_DRAFT.md](https://github.com/ans9868/simplified-pyspark/blob/main/ARTICLE_DRAFT.md).
