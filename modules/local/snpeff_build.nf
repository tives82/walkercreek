process SNPEFF_BUILD {
    tag "$fasta"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::snpeff=5.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/snpeff:5.0--hdfd78af_1' :
        'quay.io/biocontainers/snpeff:5.0--hdfd78af_1' }"

    input:
    path irma_flu_reference
    path irma_flu_gff

    output:
    path 'snpeff_db'   , emit: snpeff_db
    path '*.config'    , emit: snpeff_config
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def basename = irma_flu_reference.baseName

    def avail_mem = 4
    if (!task.memory) {
        log.info '[snpEff] Available memory not known - defaulting to 4GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = task.memory.giga
    }
    """
    mkdir -p snpeff_db/genomes/
    cd snpeff_db/genomes/
    ln -sf ../../$irma_flu_reference ${basename}.fa

    cd ../../
    mkdir -p snpeff_db/${basename}/
    cd snpeff_db/${basename}/
    ln -sf ../../$irma_flu_gff genes.gff

    cd ../../
    echo "${basename}.genome : ${basename}" > snpeff.config

    snpEff \\
        -Xmx${avail_mem}g \\
        build \\
        -config snpeff.config \\
        -dataDir ./snpeff_db \\
        -gff3 \\
        -v \\
        -nolog \\
        ${basename}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snpeff: \$(echo \$(snpEff -version 2>&1) | cut -f 2 -d ' ')
    END_VERSIONS
    """
}
