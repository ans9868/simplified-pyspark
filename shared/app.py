import argparse

from jobs import run_dataframe_job, run_udf_job, run_udtf_job
from session_builder import get_spark_session


def main() -> None:
    parser = argparse.ArgumentParser(description="Minimal PySpark portability demo")
    parser.add_argument(
        "--job",
        choices=["all", "dataframe", "udf", "udtf"],
        default="all",
        help="Which demo job to run",
    )
    args = parser.parse_args()

    spark = get_spark_session()
    print(f"[APP] Spark version: {spark.version}")
    print(f"[APP] Spark master: {spark.sparkContext.master}")

    try:
        if args.job in ("all", "dataframe"):
            run_dataframe_job(spark)
        if args.job in ("all", "udf"):
            run_udf_job(spark)
        if args.job in ("all", "udtf"):
            run_udtf_job(spark)
    finally:
        print("[APP] Stopping Spark session")
        spark.stop()


if __name__ == "__main__":
    main()
