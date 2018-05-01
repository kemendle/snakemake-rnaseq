def star_inputs(wildcards):
    """Returns fastq inputs for star."""

    base_path = "fastq/trimmed/{sample}.{lane}.{{pair}}.fastq.gz".format(
        sample=wildcards.sample, lane=wildcards.lane)
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


