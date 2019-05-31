version development

struct ExtractedRun {
    String run
    String folder
    Boolean is_paired
    Array[File] cleaned_reads
    Array[File] report
}

workflow extract_run{
    input {
        String layout
        String run
        String folder
        Boolean copy_cleaned = false
        Int extract_threads = 4
        Boolean aspera_download = true
    }
    Boolean is_paired = (layout != "SINGLE")

    call download { input: sra = run, aspera_download = aspera_download }
    call extract {input: sra = download.out, is_paired = is_paired, threads = extract_threads}
    call fastp { input: reads = extract.out, is_paired = is_paired }
    call copy as copy_report {
     input:
        destination = folder + "/report",
        files = [fastp.report_json, fastp.report_html]
    }
    if(copy_cleaned)
    {
        call copy as copy_cleaned_reads {
         input:
            destination = folder + "/reads",
            files = fastp.reads_cleaned
        }
    }

    output {
        ExtractedRun out = object {run: run, folder: folder, is_paired: is_paired, cleaned_reads: fastp.reads_cleaned, report: copy_report.out}
    }
}


task download {
    input {
        String sra
        Boolean aspera_download
    }
    #prefetch --ascp-path "/root/.aspera/connect/bin/ascp|/root/.aspera/connect/etc/asperaweb_id_dsa.openssh" --force yes -O results ~{sra}
    command {
        ~{if(aspera_download) then "download_sra_aspera.sh " else "prefetch --force yes -O results -t http "} ~{sra}
    }

    #https://github.com/antonkulaga/biocontainers/tree/master/downloaders/sra

    runtime {
        docker: "quay.io/comp-bio-aging/download_sra:master"
        maxRetries: 1
    }

    output {
        File out = "results" + "/" + sra + ".sra"
     }
}

task extract {
    input {
        File sra
        Boolean is_paired
        Int threads
    }

    String name = basename(sra, ".sra")
    String folder = "extracted"
    String prefix = folder + "/" + name
    String prefix_sra = prefix + ".sra"

    #see https://github.com/ncbi/sra-tools/wiki/HowTo:-fasterq-dump for docs

    command {
        fasterq-dump --outdir ~{folder} --threads ~{threads} --progress --split-files --skip-technical ~{sra}
        ~{if(is_paired) then "mv" + " " + prefix_sra + "_1.fastq" + " " + prefix + "_1.fastq"  else "mv" + " " + prefix_sra + ".fastq" + " " + prefix + ".fastq"}
        ~{if(is_paired) then "mv" + " " + prefix_sra + "_2.fastq" + " " + prefix + "_2.fastq"  else ""}
    }

    runtime {
        docker: "quay.io/biocontainers/sra-tools@sha256:b03fd02fefc3e435cd36eef802cc43decba5d13612142e9bc9610f2727364f4f" #2.9.1_1--h470a237_0
        #maxRetries: 3
    }

    output {
        Array[File] out = if(is_paired) then [prefix + "_1.fastq",  prefix + "_2.fastq"] else [prefix + ".fastq"]
     }
}


task fastp {
    input {
        Array[File] reads
        Boolean is_paired
    }

    command {
        fastp --cut_by_quality5 --cut_by_quality3 --trim_poly_g --overrepresentation_analysis \
            -i ~{reads[0]} -o ~{basename(reads[0], ".fastq.gz")}_cleaned.fastq.gz \
            ~{if( is_paired ) then "--detect_adapter_for_pe " + "--correction -I "+reads[1]+" -O " + basename(reads[1], ".fastq.gz") +"_cleaned.fastq.gz" else ""}
    }

    runtime {
        docker: "quay.io/biocontainers/fastp@sha256:ac9027b8a8667e80cc1661899fb7e233143b6d1727d783541d6e0efffbb9594e" #0.20.0--hdbcaa40_0
    }

    output {
        File report_json = "fastp.json"
        File report_html = "fastp.html"
        Array[File] reads_cleaned = if( is_paired )
            then [basename(reads[0], ".fastq.gz") + "_cleaned.fastq.gz", basename(reads[1], ".fastq.gz") + "_cleaned.fastq.gz"]
            else [basename(reads[0], ".fastq.gz") + "_cleaned.fastq.gz"]
    }
}


task copy {
    input {
        Array[File] files
        String destination
    }

    String where = sub(destination, ";", "_")

    command {
        mkdir -p ~{where}
        cp -L -R -u ~{sep=' ' files} ~{where}
        declare -a files=(~{sep=' ' files})
        for i in ~{"$"+"{files[@]}"};
          do
              value=$(basename ~{"$"}i)
              echo ~{where}/~{"$"}value
          done
    }

    output {
        Array[File] out = read_lines(stdout())
    }
}