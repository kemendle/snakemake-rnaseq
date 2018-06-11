import subprocess


def test_pipeline():
    subprocess.check_call(["snakemake -s ../Snakefile", "-n"])
