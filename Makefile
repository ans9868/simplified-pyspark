BASELINE_IMAGE=simplified-pyspark:baseline
FIXED_IMAGE=simplified-pyspark:fixed
RANDOM_UID?=23456
SINGULARITY?=singularity
SIF_DIR?=images
BASELINE_SIF=$(SIF_DIR)/simplified-pyspark-baseline.sif
FIXED_SIF=$(SIF_DIR)/simplified-pyspark-fixed.sif

# These Singularity targets are intentionally local/basic only.
# HPC Singularity execution usually depends on site-specific scheduler details
# such as account, partition, walltime, cache paths, temp paths, and whether
# you are using srun, sbatch, or a direct interactive shell. Those parameters
# do not fit cleanly into one generic Make target, so this Makefile stops at
# local Singularity build/run and leaves HPC job submission to per-environment
# commands or scripts.

build-baseline:
	docker build -f baseline/Dockerfile -t $(BASELINE_IMAGE) .

build-fixed:
	docker build -f fixed/Dockerfile -t $(FIXED_IMAGE) .

build-all: build-baseline build-fixed

build-singularity-baseline: build-baseline
	mkdir -p $(SIF_DIR)
	$(SINGULARITY) build $(BASELINE_SIF) docker-daemon://$(BASELINE_IMAGE)

build-singularity-fixed: build-fixed
	mkdir -p $(SIF_DIR)
	$(SINGULARITY) build $(FIXED_SIF) docker-daemon://$(FIXED_IMAGE)

build-singularity-all: build-singularity-baseline build-singularity-fixed

run-baseline:
	docker run --rm $(BASELINE_IMAGE)

run-fixed:
	docker run --rm $(FIXED_IMAGE)

run-singularity-baseline:
	$(SINGULARITY) run --no-mount tmp --cleanenv --writable-tmpfs $(BASELINE_SIF)

run-singularity-fixed:
	$(SINGULARITY) run --no-mount tmp --cleanenv --writable-tmpfs --env HADOOP_CONF_DIR=/tmp --env HADOOP_HOME=/tmp --env "JAVA_TOOL_OPTIONS=-Djava.security.auth.login.config= -Dhadoop.security.authentication=simple -Dhadoop.security.authorization=false" --bind /etc/passwd:/etc/passwd:ro --bind /etc/group:/etc/group:ro $(FIXED_SIF)

run-baseline-udf:
	docker run --rm $(BASELINE_IMAGE) spark-submit /app/app.py --job udf

run-fixed-udf:
	docker run --rm $(FIXED_IMAGE) spark-submit /app/app.py --job udf

run-baseline-udtf:
	docker run --rm $(BASELINE_IMAGE) spark-submit /app/app.py --job udtf

run-fixed-udtf:
	docker run --rm $(FIXED_IMAGE) spark-submit /app/app.py --job udtf

run-baseline-random-uid:
	docker run --rm --user $(RANDOM_UID):$(RANDOM_UID) $(BASELINE_IMAGE)

run-fixed-random-uid:
	docker run --rm --user $(RANDOM_UID):$(RANDOM_UID) $(FIXED_IMAGE)
