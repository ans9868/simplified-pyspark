import os

from pyspark.sql import SparkSession


def _detect_java_user(hadoop_user: str) -> str:
    current_uid = os.getuid()
    current_user = os.getenv("USER")

    if current_user and current_user != "unknown":
        return current_user
    if current_uid == 0:
        return "root"
    if current_uid == 1001:
        return "spark"
    return os.getenv("LOGNAME") or os.getenv("USERNAME") or hadoop_user


def get_spark_session() -> SparkSession:
    hadoop_user = os.getenv("HADOOP_USER_NAME", "spark")
    java_user = _detect_java_user(hadoop_user)
    ivy_dir = os.getenv("SIMPLIFIED_IVY_DIR", "/tmp/.ivy2")
    warehouse_dir = os.getenv("SIMPLIFIED_WAREHOUSE_DIR", "/tmp/spark-warehouse")
    local_dir = os.getenv("SIMPLIFIED_LOCAL_DIR", "/tmp/spark-local")
    home_dir = os.getenv("HOME", "/tmp")

    print("[fixed] Building SparkSession")
    print(f"[fixed] Runtime users: hadoop={hadoop_user} java={java_user}")
    print(f"[fixed] Runtime dirs: ivy={ivy_dir} warehouse={warehouse_dir} local={local_dir} home={home_dir}")

    return (
        SparkSession.builder.appName("simplified-pyspark-fixed")
        .master("local[*]")
        .config("spark.sql.shuffle.partitions", "4")
        .config("spark.pyspark.python", "python3")
        .config("spark.pyspark.driver.python", "python3")
        .config("spark.sql.warehouse.dir", f"file://{warehouse_dir}")
        .config("spark.sql.hive.metastore.warehouse.dir", f"file://{warehouse_dir}")
        .config("spark.local.dir", local_dir)
        .config("spark.hadoop.fs.defaultFS", "file:///")
        .config("spark.hadoop.hadoop.security.authentication", "simple")
        .config("spark.hadoop.hadoop.security.authorization", "false")
        .config(
            "spark.driver.extraJavaOptions",
            " ".join(
                [
                    "-Djava.security.auth.login.config=",
                    "-Dhadoop.security.authentication=simple",
                    "-Dhadoop.security.authorization=false",
                    f"-DHADOOP_USER_NAME={hadoop_user}",
                    "-Dhadoop.home.dir=/tmp",
                    f"-Duser.name={java_user}",
                ]
            ),
        )
        .config(
            "spark.executor.extraJavaOptions",
            " ".join(
                [
                    "-Djava.security.auth.login.config=",
                    "-Dhadoop.security.authentication=simple",
                    "-Dhadoop.security.authorization=false",
                    f"-DHADOOP_USER_NAME={hadoop_user}",
                    "-Dhadoop.home.dir=/tmp",
                    f"-Duser.name={java_user}",
                ]
            ),
        )
        .config("spark.executorEnv.HADOOP_USER_NAME", hadoop_user)
        .config("spark.executorEnv.USER", java_user)
        .config("spark.executorEnv.LOGNAME", java_user)
        .config("spark.executorEnv.USERNAME", java_user)
        .config("spark.executorEnv.HADOOP_HOME", "/tmp")
        .config("spark.executorEnv.HADOOP_CONF_DIR", "/tmp")
        .config("spark.executorEnv.HOME", home_dir)
        .config("spark.executorEnv.SPARK_LOCAL_DIRS", local_dir)
        .config("spark.executorEnv.PYSPARK_PYTHON", "python3")
        .config("spark.executorEnv.PYSPARK_DRIVER_PYTHON", "python3")
        .config("spark.executorEnv.PYTHONPATH", "/app")
        .config("spark.jars.ivy", ivy_dir)
        .getOrCreate()
    )
