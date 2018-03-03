workflow quality {

  File reads_1
  File reads_2


  call report as initial_report_1 {
      input:
          sampleName = basename(reads_1, ".fastq.gz"),
          file = reads_1
  }

  call report as initial_report_2 {
      input:
          sampleName = basename(reads_2, ".fastq.gz"),
          file = reads_2
  }

  call trimming_sickle_pe {
      input:
        reads_1 = reads_1,
        reads_2 = reads_2,
        q = 20,
        len = 36
  }

  call report as trimming_report_sickle_1 {
      input:
          sampleName = basename(trimming_sickle_pe.out1, ".fastq"),
          file = trimming_sickle_pe.out1
          }

  call report as trimming_report_sickle_2 {
      input:
        sampleName = basename(trimming_sickle_pe.out2, ".fastq"),
        file = trimming_sickle_pe.out2
        }

  call trimming_adapter_removal {
      input:
        reads_1 = reads_1,
        reads_2 = reads_2,
        q = 20,
        threads = 8
  }

  call report as trimming_report_adapter_removal_1 {
      input:
          sampleName = basename(trimming_adapter_removal.out1, ".fastq"),
          file = trimming_adapter_removal.out1
          }

  call report as trimming_report_adapter_removal_2 {
      input:
        sampleName = basename(trimming_adapter_removal.out2, ".fastq"),
        file = trimming_adapter_removal.out2
        }

  call trimming_skewer {
      input:
        reads_1 = reads_1,
        reads_2 = reads_2,
        q = 20,
        len = 36
  }

  call report as trimming_report_skewer_1 {
      input:
          sampleName = basename(trimming_skewer.out1, ".fastq"),
          file = trimming_skewer.out1
          }

  call report as trimming_report_skewer_2 {
      input:
        sampleName = basename(trimming_skewer.out2, ".fastq"),
        file = trimming_skewer.out2
        }



      call trimming_sickle_pe {
          input:
            reads_1 = reads_1,
            reads_2 = reads_2,
            q = 20,
            len = 36
      }

      call report as trimming_report_sickle_1 {
          input:
              sampleName = basename(trimming_sickle_pe.out1, ".fastq"),
              file = trimming_sickle_pe.out1
              }

      call report as trimming_report_sickle_2 {
          input:
            sampleName = basename(trimming_sickle_pe.out2, ".fastq"),
            file = trimming_sickle_pe.out2
            }


  call atropos_illumina_pe {
      input:
        reads_1 = reads_1,
        reads_2 = reads_2,
        threads = 8
  }

  call report as report_atropos_illumina_pe_1 {
      input:
          sampleName = basename(atropos_illumina_pe.out1, ".fastq.gz"),
          file = atropos_illumina_pe.out1
          }

  call report as report_atropos_illumina_pe_2 {
      input:
        sampleName = basename(atropos_illumina_pe.out2, ".fastq.gz"),
        file = atropos_illumina_pe.out2
        }


      call trimming_UrQt_pe as trimming_atropos_UrQt_pe {
          input:
            reads_1 = reads_1,
            reads_2 = reads_2,
            len = 36,
            q = 20
      }

      call report as report_trimming_atropos_illumina_pe_1 {
          input:
              sampleName = basename(trimming_atropos_UrQt_pe.out1, ".fastq.gz"),
              file = trimming_atropos_UrQt_pe.out1
              }

      call report as report_trimming_atropos_illumina_pe_2 {
          input:
            sampleName = basename(trimming_atropos_UrQt_pe.out2, ".fastq.gz"),
            file = trimming_atropos_UrQt_pe.out2
            }


  #call trimming_seqpurge {
  #    input:
  #      reads_1 = reads_1,
  #      reads_2 = reads_2,
  #      threads = 8,
  #      min_len = 36
  #}


  #call trimming_afterQC {
  #    input:
  #      reads_1 = reads_1,
  #      reads_2 = reads_2
  # }

  #call report as trimming_afterQC_report_1 {
  #     input:
  #       sampleName = basename(trimming_afterQC.out1, ".fq"),
  #       file = trimming_afterQC.out1
  #}

  #call report as trimming_afterQC_report_2 {
  #    input:
  #       sampleName = basename(trimming_afterQC.out2, ".fq"),
  #       file = trimming_afterQC.out2
  #}


    #call report as report_trimming_seqpurge_1 {
    #    input:
    #        sampleName = basename(trimming_seqpurge.out1, ".fastq.gz"),
    #        file = trimming_seqpurge.out1
    #        }

    #call report as report_trimming_seqpurge_2 {
    #    input:
    #      sampleName = basename(trimming_seqpurge.out2, ".fastq.gz"),
    #      file = trimming_seqpurge.out2
    #      }


  #call report as report_trimming_seqpurge_1 {
  #    input:
  #        sampleName = basename(trimming_seqpurge.out1, ".fastq.gz"),
  #        file = trimming_seqpurge.out1
  #        }

  #call report as report_trimming_seqpurge_2 {
  #    input:
  #      sampleName = basename(trimming_seqpurge.out2, ".fastq.gz"),
  #      file = trimming_seqpurge.out2
  #      }

  #call trimming_UrQt_pe {
  #    input:
  #      reads_1 = trimming_seqpurge.out1,
  #      reads_2 = trimming_seqpurge.out2,
  #      len = 36,
  #      q = 24,
  #      threads = 8
  #}

  #      call trimming_sickle_pe {
  #              input:
  #                reads_1 = reads_1,
  #                reads_2 = reads_2,
  #                q = 20,
  #                len = 36
  #          }



  #    call report as trimming_report_sickle_1 {
  #        input:
  #            sampleName = basename(trimming_sickle_pe.out1, ".fastq"),
  #            file = trimming_sickle_pe.out1
  #            }

  #    call report as trimming_report_sickle_2 {
  #        input:
  #          sampleName = basename(trimming_sickle_pe.out2, ".fastq"),
  #          file = trimming_sickle_pe.out2
  #         }

  #    call trimming_sickle_pe as trimming_sickle_pe_cleaned {
  #        input:
  #          reads_1 = trimming_seqpurge.out1,
  #          reads_2 = trimming_seqpurge.out2,
  #          q = 20,
  #          len = 36
  #    }


  #  call report as trimming_report_sickle_cleaned_1 {
  #      input:
  #          sampleName = basename(trimming_sickle_pe_cleaned.out1, ".fastq"),
  #          file = trimming_sickle_pe_cleaned.out1
  #          }

  #  call report as trimming_report_sickle_cleaned_2 {
  #      input:
  #        sampleName = basename(trimming_sickle_pe_cleaned.out2, ".fastq"),
  #        file = trimming_sickle_pe_cleaned.out2
  #        }

  #call atropos_illumina_pe {
  #    input:
  #      reads_1 = reads_1,
  #      reads_2 = reads_2,
  #      threads = 8
  #}

  #call report as report_atropos_illumina_pe_1 {
  #    input:
  #        sampleName = basename(atropos_illumina_pe.out1, ".fastq.gz"),
  #        file = atropos_illumina_pe.out1
  #        }

  #call report as report_atropos_illumina_pe_2 {
  #    input:
  #      sampleName = basename(atropos_illumina_pe.out2, ".fastq.gz"),
  #      file = atropos_illumina_pe.out2
  #      }


}


task report {

  String sampleName
  File file
  Int threads = 4

  command {
    /opt/FastQC/fastqc -t ${threads} ${file} -o .
  }

  runtime {
    docker: "quay.io/ucsc_cgl/fastqc@sha256:86d82e95a8e1bff48d95daf94ad1190d9c38283c8c5ad848b4a498f19ca94bfa"
  }

  output {
    File out = sampleName+"_fastqc.zip"
  }
}


task trimming_sickle_pe {

  File reads_1
  File reads_2
  Int len
  Int q

  command {
    sickle pe \
            -f ${reads_1} \
            -r ${reads_2} \
            -t sanger \
            -o ${basename(reads_1, ".fastq.gz")}_trimmed.fastq \
            -p ${basename(reads_2, ".fastq.gz")}_trimmed.fastq \
            -s unpaired.fastq \
            -q ${q} -l ${len}
  }

  runtime {
    docker: "asidorovj/sickle@sha256:933e4a880c58804248179c3819bb179c45ba86c85086d8435d8ab6cf82bca63c"
  }

  output {
    File out1 = basename(reads_1, ".fastq.gz") + "_trimmed.fastq"
    File out2 = basename(reads_2, ".fastq.gz") + "_trimmed.fastq"
  }
}



task atropos_illumina_pe {
  File reads_1
  File reads_2
  Int threads

  command {
    atropos trim \
      --aligner insert \
      -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTG \
      -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT \
      -pe1 ${reads_1} \
      -pe2 ${reads_2} \
      -o ${basename(reads_1, ".fastq.gz")}_trimmed.fastq.gz \
      -p ${basename(reads_2, ".fastq.gz")}_trimmed.fastq.gz \
      --threads ${threads} \
      --correct-mismatches liberal
    }

    runtime {
        docker: "jdidion/atropos@sha256:a10547e2f6a05ca40819279f696b1afe9e7935dd4415b3f2a844190c2f38c820"
    }

  output {
    File out1 = basename(reads_1, ".fastq.gz") + "_trimmed.fastq.gz"
    File out2 = basename(reads_2, ".fastq.gz") + "_trimmed.fastq.gz"
  }
}

task trimming_UrQt_pe {

  File reads_1
  File reads_2
  Int len
  Int q

  command {
    UrQt \
        --in ${reads_1} \
        --inpair ${reads_2} \
        --out ${basename(reads_1, ".fastq.gz")}_trimmed.fastq \
        --outpair ${basename(reads_2, ".fastq.gz")}_trimmed.fastq \
        --t ${q} --min_read_size ${len}
  }

  runtime {
    docker: "quay.io/comp-bio-aging/urqt@sha256:0c5ceb7757c5f2f6751d12861aaa08299e300012757d36c7e80551cfac3e7ba8"
  }

  output {
    File out1 = basename(reads_1, ".fastq.gz") + "_trimmed.fastq.gz"
    File out2 = basename(reads_2, ".fastq.gz") + "_trimmed.fastq.gz"
  }
}


task sort_me_rna {

 #NOT FINISHED!

 command {
   sortmerna
  }

    runtime {
        docker: "quay.io/biocontainers/sortmerna@sha256:7dee9a1a33f2e64058d56d1aae0c2404d0299f50f345b30300f560bf55dae31a"
    }

}


task trimming_adapter_removal {

  File reads_1
  File reads_2
  Int q
  Int threads

  command {
    AdapterRemoval \
        --file1 ${reads_1} \
        --file2 ${reads_2} \
        --output1 ${basename(reads_1, ".fastq.gz")}_trimmed.fastq \
        --output2 ${basename(reads_2, ".fastq.gz")}_trimmed.fastq \
        --threads ${threads} --trimwindows ${q} \
        --trimns --trimqualities --collapse
  }

  runtime {
    docker: "quay.io/comp-bio-aging/adapter-removal:latest"
  }

  output {
    File out1 = basename(reads_1, ".fastq.gz") + "_trimmed.fastq"
    File out2 = basename(reads_2, ".fastq.gz") + "_trimmed.fastq"
  }
}

task trimming_skewer {

  File reads_1
  File reads_2
  Int len
  Int q

  command {
    skewer \
        -m pe -q ${q}  -n -u -l ${len} \
            ${reads_1} ${reads_2}
  }

  runtime {
    docker: "quay.io/biocontainers/skewer@sha256:047a72bb4dc61d9896318beb67f90e71bf2557c54bdd1142cea8820e516607a1"
  }

  output {
    File out1 = basename(reads_1, ".fastq.gz") + ".trimmed.fastq"
    File out2 = basename(reads_2, ".fastq.gz") + ".trimmed.fastq"
  }
}


task trimming_seqpurge {
  File reads_1
  File reads_2
  Int threads
  Int min_len

  command {
    SeqPurge \
      -in1 ${reads_1} \
      -in2 ${reads_2} \
      -out1 ${basename(reads_1, ".fastq.gz")}_trimmed.fastq.gz \
      -out2 ${basename(reads_2, ".fastq.gz")}_trimmed.fastq.gz \
      --threads ${threads} \
      -min_len  ${min_len} \
      -ec
    }

    runtime {
        docker: "quay.io/comp-bio-aging/seqpurge:latest"
    }

  output {
    File out1 = basename(reads_1, ".fastq.gz") + "_trimmed.fastq.gz"
    File out2 = basename(reads_2, ".fastq.gz") + "_trimmed.fastq.gz"
  }
}