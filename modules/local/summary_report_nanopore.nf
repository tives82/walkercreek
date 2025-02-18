process SUMMARY_REPORT_NANOPORE {
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:1.1.5' :
        'quay.io/biocontainers/pandas:1.1.5' }"

    input:
    path (merged_nano_raw_filt_reportsheet)      // from merge_nano_raw_filt.nf
    path (typing_report_tsv)                     // from irma_abricate_reportsheet.nf
    path (irma_consensus_qc_tsv)                 // from irma_consensus_qc_reportsheet.nf
    path (nextclade_report_tsv)                  // from nextclade_report_ha.nf

    output:
    path ("summary_report.tsv") , emit: summary_report_tsv

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    python $projectDir/bin/merge_reports.py $merged_nano_raw_filt_reportsheet $typing_report_tsv $nextclade_report_tsv $irma_consensus_qc_tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}