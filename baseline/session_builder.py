from pyspark.sql import SparkSession


def get_spark_session() -> SparkSession:
    print("[baseline] Building SparkSession")

    return (
        SparkSession.builder.appName("simplified-pyspark-baseline")
        .master("local[*]")
        .config("spark.sql.shuffle.partitions", "4")
        .config("spark.pyspark.python", "python3")
        .config("spark.pyspark.driver.python", "python3")
        .getOrCreate()
    )
