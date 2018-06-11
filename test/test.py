import os.path
import subprocess


def test_pipeline():
    os.chdir(os.path.dirname(os.getcwd()))
    subprocess.check_call(["snakemake", "-n"])
