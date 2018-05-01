if is_paired:
    rule cutadapt:
        input:
            ["fastq/raw/{sample}.{replicate}.R1.fastq.gz",
             "fastq/raw/{sample}.{replicate}.R2.fastq.gz"]
        output:
            fastq1=temp("fastq/trimmed/{sample}.{replicate}.R1.fastq.gz"),
            fastq2=temp("fastq/trimmed/{sample}.{replicate}.R2.fastq.gz"),
            qc="qc/cutadapt/{sample}.{replicate}.txt"
        params:
            config["cutadapt_pe"]["extra"]
        log:
            "logs/cutadapt/{sample}.{replicate}.log"
        wrapper:
            "0.17.0/bio/cutadapt/pe"
else:
    rule cutadapt:
        input:
            "fastq/raw/{sample}.{replicate}.R1.fastq.gz"
        output:
            fastq=temp("fastq/trimmed/{sample}.{replicate}.R1.fastq.gz"),
            qc="qc/cutadapt/{sample}.{replicate}.txt"
        params:
            config["cutadapt_se"]["extra"]
        log:
            "logs/cutadapt/{sample}.{replicate}.log"
        wrapper:
            "0.17.0/bio/cutadapt/se"
