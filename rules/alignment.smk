def hisat2_inputs(wildcards):
    """Returns fastq inputs for hisat2."""

    base_path = "fastq/trimmed/{sample}.{replicate}.{{pair}}.fastq.gz".format(
        sample=wildcards.sample, replicate=wildcards.replicate)
    pairs = ["R1", "R2"] if is_paired else ["R1"]

    return expand(base_path, pair=pairs)


def hisat2_extra(hisat2_config):
    """Returns extra arguments for hisat2 based on config."""

    extra = hisat2_config.get("extra", "")

    # Add any extra args passed by user.
    if extra:
        extra_args += " " + extra
    else:
        extra_args = extra

    return extra_args


rule hisat2_align:
    input:
        reads=hisat2_inputs,
    output:
        temp("bam/hisat2/{sample}.{replicate}/Aligned.out.bam")
    log:
        "logs/hisat2/{sample}.{replicate}.log"
    params:
        idx=config["hisat2"]["index"],
        extra=hisat2_extra(config["hisat2"])
    resources:
        memory=30
    threads:
        config["hisat2"]["threads"]
    wrapper:
        "0.17.0/bio/hisat2"


rule sambamba_sort:
    input:
        "bam/hisat2/{sample}.{replicate}/Aligned.out.bam"
    output:
        "bam/sorted/{sample}.{replicate}.bam"
    params:
        config["sambamba_sort"]["extra"]
    threads:
        config["sambamba_sort"]["threads"]
    wrapper:
        "0.17.0/bio/sambamba/sort"


rule samtools_index:
    input:
        "bam/sorted/{sample}.{replicate}.bam"
    output:
        "bam/sorted/{sample}.{replicate}.bam.bai"
    wrapper:
        "0.17.0/bio/samtools/index"
