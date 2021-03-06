workflow StarAligner {

  File index_dir
  Int threads
  File reads_1
  File reads_2
  String results_folder #will be created if needed
  Float threshold


  call star_align {
      input:
        reads_1 = reads_1,
        reads_2 = reads_2,
        index_dir = index_dir,
        threads = threads,
        threshold = threshold
    }

  call copy as copy_results {
    input:
        files = [star_align.log, star_align.out, star_align.junctions],
        destination = results_folder
  }

  output {
    Array[File] results = copy_results.out
  }

}

task star_align {

  File reads_1
  File reads_2
  File index_dir
  Int  threads
  Float threshold


  command {
    /usr/local/bin/STAR \
        --runThreadN ${threads} \
        --genomeDir ${index_dir} \
        --readFilesCommand gunzip -c \
        --outFilterMatchNminOverLread ${threshold} \
        --readFilesIn ${reads_1} ${reads_2}
  } # --outSAMtype BAM SortedByCoordinate

  runtime {
    docker: "quay.io/biocontainers/star@sha256:6556f4d3a9f767f93cd8841ef0ac0f15d29d2c69b6a6f1f9b6ccc3e1da40207b" #2.7.1a--0
  }

  output {
    File out = "Aligned.out.sam" #"Aligned.sortedByCoord.out.bam"
    File log = "Log.final.out"
    File junctions = "SJ.out.tab"
  }

}

task copy {
    Array[File] files
    String destination

    command {
        mkdir -p ${destination}
        cp -L -R -u ${sep=' ' files} ${destination}
    }

    output {
        Array[File] out = files
    }
}
