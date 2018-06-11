import subprocess


def test_pipeline():
    subprocess.call("cd ..")
    subprocess.check_call(["snakemake", "-n"])
