from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.functions import udtf
from pyspark.sql.types import IntegerType, StringType, StructField, StructType


def run_dataframe_job(spark: SparkSession) -> None:
    print("[JOB:dataframe] Running DataFrame demo")

    rows = [
        ("alpha", "x", 1),
        ("alpha", "y", 2),
        ("beta", "x", 3),
        ("beta", "y", 4),
    ]
    schema = StructType(
        [
            StructField("group_id", StringType(), False),
            StructField("feature", StringType(), False),
            StructField("value", IntegerType(), False),
        ]
    )

    df = spark.createDataFrame(rows, schema=schema)
    transposed = (
        df.groupBy("group_id")
        .pivot("feature", ["x", "y"])
        .agg(F.first("value"))
        .orderBy("group_id")
    )

    transposed.show()
    print("[JOB:dataframe] Completed")


def run_udf_job(spark: SparkSession) -> None:
    print("[JOB:udf] Running UDF demo")

    @F.udf(returnType=StringType())
    def annotate(name: str) -> str:
        return f"{name}-checked"

    df = spark.createDataFrame([("spark",), ("container",)], ["name"])
    annotated = df.withColumn("tag", annotate(F.col("name")))
    annotated.show()
    print("[JOB:udf] Completed")


@udtf(returnType="n: int, square: int")
class SquareRange:
    def eval(self, start: int, end: int):
        for value in range(start, end + 1):
            yield value, value * value


def run_udtf_job(spark: SparkSession) -> None:
    print("[JOB:udtf] Running UDTF demo")

    spark.udtf.register("square_range", SquareRange)
    result = spark.sql("SELECT * FROM square_range(1, 4)")
    result.show()
    print("[JOB:udtf] Completed")
