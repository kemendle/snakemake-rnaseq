from os import path


def multiqc_inputs(wildcards):
    """Returns inputs for multiqc, which vary depending on whether the
    data is paired."""

    inputs = [
        expand("qc/fastqc/{sample_replicate}.{pair}_fastqc.html",
               sample_replicate=get_samples_with_replicate(),
               pair=["R1", "R2"] if is_paired else ["R1"]),
        expand("qc/cutadapt/{sample_replicate}.txt",
               sample_replicate=get_samples_with_replicate()),
        expand("qc/samtools_stats/{sample}.txt", sample=get_samples())
    ]

    if config["options"]["pdx"]:
        inputs += [expand("qc/disambiguate/{sample}.txt", sample=get_samples())]

    return [input_ for sub_inputs in inputs for input_ in sub_inputs]


rule multiqc:
    input:
        multiqc_inputs
    output:
        "qc/multiqc_report.html"
    params:
        config["multiqc"]["extra"]
    log:
        "logs/multiqc.log"
    conda:
        path.join(workflow.basedir, "envs/multiqc.yaml")
    wrapper:
        "0.17.0/bio/multiqc"


rule fastqc:
    input:
        "fastq/trimmed/{sample}.{replicate}.{pair}.fastq.gz"
    output:
        html="qc/fastqc/{sample}.{replicate}.{pair}_fastqc.html",
        zip="qc/fastqc/{sample}.{replicate}.{pair}_fastqc.zip"
    params:
        config["fastqc"]["extra"]
    wrapper:
        "0.17.0/bio/fastqc"


rule samtools_stats:
    input:
        "bam/final/{sample}.bam"
    output:
        "qc/samtools_stats/{sample}.txt"
    wrapper:
        "0.17.0/bio/samtools/stats"
