version development

import "extract_run.wdl" as extractor

struct AlignedRun {
    String run
    File sorted
    File to_transcriptome
    File summary
    File log
    File progress
    File reads_per_gene
    File junctions
}

struct QuantifiedRun {
    String run
    File run_folder
    File quant_folder
    File quant
    File lib
    File genes
    File tx2gene
    Map[String, String] metadata
}



workflow star_align_run {
    input {
        String run
        String layout
        File transcripts
        Directory index_dir
        String folder
        File tx2gene
        Map[String, String] metadata = {"run": run, "layout": layout}

        String key = "0a1d74f32382b8a154acacc3a024bdce3709"
        Int extract_threads = 4
        Int salmon_threads = 4
        Int bootstraps = 128
        Boolean copy_cleaned = false
        String prefix = ""
        Boolean aspera_download = true
    }

    call extractor.extract_run as extract_run{
        input:
            layout = layout,
            run =  run,
            folder = folder,
            copy_cleaned = copy_cleaned,
            extract_threads = extract_threads,
            aspera_download = aspera_download
    }


    call star_align {
      input:
        run = run,
        reads = extract_run.out.cleaned_reads,
        index_dir = index_dir
    }

    call extractor.copy as copy_quant{
        input:
            destination = extract_run.out.folder,
            files = [star_align.out.sorted, star_align.out.to_transcriptome,
                star_align.out.summary, star_align.out.log, star_align.out.progress,
                star_align.out.reads_per_gene, star_align.out.junctions
       ]
    }


    call salmon_aligned {
        input:
            aligned_to_transcriptome = star_align.out.to_transcriptome,
            transcripts = transcripts,
            threads = salmon_threads,
            bootstraps = bootstraps,
            name = prefix + run
    }

    call tximport {
        input:
            tx2gene =  tx2gene,
            samples = salmon_aligned.quant,
            name =  prefix + run
    }

       File quant_folder = copy_quant.out[0]
        File quant = quant_folder + "/" + "quant.sf"
        File quant_lib = quant_folder + "/" + "lib_format_counts.json"
        File genes = copy_quant.out[2]

      QuantifiedRun quantified = object {
                run: extract_run.out.run,
                run_folder:extract_run.out.folder,
                quant_folder: quant_folder,
                quant: quant,
                lib: quant_lib,
                genes: genes,
                metadata: metadata,
                tx2gene: tx2gene
                }

        call write_quant{
            input: quantified_run = quantified, destination = extract_run.out.folder
        }


        output {
            AlignedRun out = star_align.out
            QuantifiedRun quantified_run = quantified
            File quantified_run_json = write_quant.out
        }

}

task star_align {
    input {
        String run
        Array[File] reads
        Directory index_dir
        Float threshold  = 0.2
        Int threads = 4
        Float minOverLread = 0.2
    }


  command {
    /usr/local/bin/STAR \
        --runThreadN ~{threads} \
        --genomeDir ~{index_dir} \
        --outSAMtype BAM SortedByCoordinate \
        --quantMode TranscriptomeSAM GeneCounts \
        --readFilesCommand gunzip -c \
        --outFilterMatchNminOverLread ~{threshold} \
        --outFilterScoreMinOverLread ~{minOverLread} \
        --readFilesIn ~{sep=" " reads}
  }

  runtime {
    docker: "quay.io/biocontainers/star@sha256:f9b0406354ff2e5ccfadaef6fde6367c7bcb4bdc7e67920f0f827a6ff6bf4fb5" #2.7.2b--0
  }

  output {
    AlignedRun out= object {
      run: run,
      sorted: "Aligned.sortedByCoord.out.bam",
      to_transcriptome: "Aligned.toTranscriptome.out.bam",
      summary: "Log.final.out",
      log: "Log.out",
      progress: "Log.progress.out",
      reads_per_gene: "ReadsPerGene.out.tab",
      junctions: "SJ.out.tab"
    }
  }

}

task salmon_aligned {
  input {
    File transcripts
    File aligned_to_transcriptome
    Int threads
    Int bootstraps = 128
    String name
  }


  command {
    salmon --no-version-check quant  --numBootstraps ~{bootstraps} --threads ~{threads} -l A --seqBias --gcBias --writeUnmappedNames -o quant_~{name} \
    -a ~{aligned_to_transcriptome} -t ~{transcripts}
  }
  # --validateMappings --rangeFactorizationBins ~{rangeFactorizationBins}

  runtime {
    docker: "combinelab/salmon:0.14.1"
    maxRetries: 3
  }

  output {
    File out = "quant_" + name
    File lib = out + "/" + "lib_format_counts.json"
    File quant = out + "/" + "quant.sf"
  }
}


task tximport {
    input {
        File tx2gene
        File samples
        String name
    }

    command {
        /home/rstudio/convert.R --samples ~{samples} --transcripts2genes ~{tx2gene} --name ~{name} --folder expressions
    }

    runtime {
        docker: "quay.io/comp-bio-aging/diff-express:latest"
    }

    output {
        File transcripts = "expressions/transcripts/" + name + "_transcripts_abundance.tsv"

        File genes_length = "expressions/genes/" + name + "_genes_length.tsv"
        File genes_counts = "expressions/genes/" + name + "_genes_counts.tsv"
        File genes = "expressions/genes/" + name + "_genes_abundance.tsv"
    }

}

task write_quant {
    input {
        QuantifiedRun quantified_run
        File destination
    }

    String where = sub(destination, ";", "_")

    command {
        cp -L -R -u ~{write_json(quantified_run)} ~{where}/~{quantified_run.run}.json
    }

    output {
        File out = where + "/" + quantified_run.run + ".json"
    }
}
