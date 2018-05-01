def star_inputs(wildcards):
    """Returns fastq inputs for star."""

    base_path = "fastq/trimmed/{sample}.{replicate}.{{pair}}.fastq.gz".format(
        sample=wildcards.sample, replicate=wildcards.replicate)
    pairs = ["R1", "R2"] if is_paired else ["R1"]

    return expand(base_path, pair=pairs)


def star_extra(star_config):
    """Returns extra arguments for STAR based on config."""

    extra = star_config.get("extra", "")

    # Add readgroup information.
    extra_args = "--outSAMattrRGline " + star_config["readgroup"]

    # Add NM SAM attribute (required for PDX pipeline).
    if "--outSamAttributes" not in extra:
        extra_args += " --outSAMattributes NH HI AS nM NM"

    # Add any extra args passed by user.
    if extra:
        extra_args += " " + extra

    return extra_args


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


def merge_inputs(wildcards):
    replicates = get_sample_replicates(wildcards.sample)

    file_paths = ["bam/sorted/{}.{}.bam".format(
                    wildcards.sample, replicate)
                for replicate in replicates]

    return file_paths


rule samtools_merge:
    input:
        merge_inputs
    output:
        "bam/final/{sample}.bam"
    params:
        config["samtools_merge"]["extra"]
    threads:
        config["samtools_merge"]["threads"]
    wrapper:
        "0.17.0/bio/samtools/merge"


rule samtools_index:
    input:
        "bam/final/{sample}.bam"
    output:
        "bam/final/{sample}.bam.bai"
    wrapper:
        "0.17.0/bio/samtools/index"
