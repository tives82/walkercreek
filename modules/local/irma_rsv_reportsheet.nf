process IRMA_RSV_REPORTSHEET {
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    val combined_data

    output:
    path("typing_report.tsv"), emit: typing_report_tsv

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    echo -e "$combined_data" > typing_report.tsv
    """
}