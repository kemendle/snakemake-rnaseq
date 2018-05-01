import pandas as pd

configfile: 'config.yaml'


################################################################################
# Globals                                                                      #
################################################################################

samples = pd.read_csv('test/samples.tsv', sep='\t')
is_paired = "fastq2" in samples.columns


################################################################################
# Functions                                                                    #
################################################################################

def get_samples():
    """Returns list of all samples."""
    return list(samples["sample"].unique())


def get_samples_with_replicate():
    """Returns list of all combined replicate/sample identifiers."""
    return list((samples["sample"] + "." + samples["replicate"]).unique())


def get_sample_replicates(sample):
    """Returns replicates for given sample."""
    subset = samples.loc[samples["sample"] == sample]
    return list(subset["replicate"].unique())


################################################################################
# Rules                                                                        #
################################################################################

rule all:
    input:
        "counts/merged.log2.txt",
        "qc/multiqc_report.html"

include: "rules/input.smk"
include: "rules/fastq.smk"
include: "rules/alignment.smk"
include: "rules/counts.smk"
include: "rules/qc.smk"
