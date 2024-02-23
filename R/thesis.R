#' @title R Markdown output formats Template for thesis at Department of Psychology, Senshu University
#' @importFrom rmarkdown render
#' @importFrom rmarkdown pdf_document
#' @importFrom jpaRmd jpa_cite
#' @param Rmd_file file name of R Markdown file
#' @param Bib_file file name of Bib file
#' @export
senshu_thesis  <- function(Rmd_file, Bib_file) {
  jpa_cite(Rmd_file, Bib_file)
  tmp_rmd <- paste0("tmp_", Rmd_file)
  template_tex_file <- system.file("rmarkdown/templates/thesis_senshu/resources/senshu.tex",
                                   package = 'psyinfr')
  format_pdf <- pdf_document(
    latex_engine = "xelatex",
    template = template_tex_file,
    keep_tex = TRUE,
    toc = TRUE,
    toc_depth = 3,
    highlight = "tango"
  )
  format_pdf$inherits <- "pdf_document"
  output_file <- strsplit(Rmd_file, ".Rmd")[[1]]
  render(tmp_rmd, format_pdf, output_file)
}


#' @title Research Compendium of Department of Psychology, Senshu University
#' @importFrom rstudioapi navigateToFile
#' @examples # set_rc()
#' @export
set_rc <- function (){
  path = getwd()
  # make README
  if(!file.exists(file.path(path, "README.md"))){
    file.create(file.path(path, "README.md"), showWarnings = FALSE)
    writeLines("# Research Compendium\r\nResearch Compendium\u5185\u306e\u5404\u30d5\u30a9\u30eb\u30c0\u306e\u6a5f\u80fd\u3092\u7406\u89e3\u3057\u305f\u4e0a\u3067\u30d5\u30a1\u30a4\u30eb\u3092\u4fdd\u5b58\u3057\u3066\u304f\u3060\u3055\u3044\u3002\r\n- paper:\u5352\u8ad6\u30fb\u4fee\u8ad6\u7528\u306eRmd\u30d5\u30a1\u30a4\u30eb\u304c\u7528\u610f\u3055\u308c\u3066\u3044\u307e\u3059\r\n- analysis\uff1a\u89e3\u6790\u7528\u30d5\u30a1\u30a4\u30eb\u3092\u5165\u308c\u308b\u7528\u306e\u30d5\u30a9\u30eb\u30c0\u3067\u3059\r\n- (analysis\u5185) data\uff1a\u89e3\u6790\u7528\u30c7\u30fc\u30bf\u3092\u5165\u308c\u308b\u30d5\u30a9\u30eb\u30c0\u3067\u3059\r\n- (analysis\u5185) function\uff1a\u89e3\u6790\u7528R\u306e\u95a2\u6570\u3092\u5165\u308c\u308b\u30d5\u30a9\u30eb\u30c0\u3067\u3059\r\n- (analysis\u5185) high_load\uff1a\u9ad8\u8ca0\u8377\u306a\u89e3\u6790\u3067\u4f7f\u3046\u95a2\u6570\u3092\u5165\u308c\u308b\u30d5\u30a9\u30eb\u30c0\u3067\u3059\r\n- materials\uff1a\u7814\u7a76\u3067\u4f7f\u3063\u305f\u6750\u6599\u3092\u5165\u308c\u308b\u30d5\u30a9\u30eb\u30c0\u3067\u3059\r\n- exercises\uff1a\u30bc\u30df\u3067\u884c\u3046\u6f14\u7fd2\u8ab2\u984c\u7528\u306e\u30d5\u30a9\u30eb\u30c0\u3067\u3059\r\n- labnote\uff1a\u30e9\u30dc\u30ce\u30fc\u30c8\u3092\u4fdd\u7ba1\u3059\u308b\u30d5\u30a9\u30eb\u30c0\u3067\u3059\r\n\r\n# \u65e5\u3005\u306e\u7814\u7a76\u6d3b\u52d5\u3067\u4f7f\u3046R\u30b3\u30de\u30f3\u30c9\r\n## jsPsych\u8ab2\u984c\u4f5c\u6210\u30c6\u30f3\u30d7\u30ec\u30fc\u30c8\u306e\u6e96\u5099\r\n\u4ee5\u4e0b\u306e\u3088\u3046\u306b\uff0cset_cbat(\"\u8a8d\u77e5\u8ab2\u984c\u540d\uff08\u82f1\u8a9e\uff09\",\"jsPsych\u306e\u30d0\u30fc\u30b8\u30e7\u30f3\")\u3092\u5b9f\u884c\u3059\u308b\u3068\uff0cexercise\u30d5\u30a9\u30eb\u30c0\u5185\u306b\u6307\u5b9a\u3057\u305f\u8a8d\u77e5\u8ab2\u984c\u540d\u306e\u30d5\u30a9\u30eb\u30c0\u3092\u4f5c\u6210\u3057\uff0c\u5fc5\u8981\u306ajsPsych\u95a2\u9023\u30d5\u30a1\u30a4\u30eb\u304c\u30c0\u30a6\u30f3\u30ed\u30fc\u30c9\u3055\u308c\u307e\u3059\u3002\r\n``` r\r\npsyinfr::set_cbat(\"stroop\",\"7.1.1\")\r\n```\r\n## \u7814\u7a76\u958b\u59cb\r\n\u305d\u306e\u65e5\u306e\u7814\u7a76\u306e\u958b\u59cb\u6642\u306b\u4ee5\u4e0b\u306e\u95a2\u6570\u3092\u5b9f\u884c\u3059\u308b\u3068\uff0cGitHub\u306e\u30ea\u30dd\u30b8\u30c8\u30ea\u304b\u3089\u30d7\u30eb\u3092\u884c\u3063\u305f\u4e0a\u3067\uff0c\u30e9\u30dc\u30ce\u30fc\u30c8\u3092\u4f5c\u6210\u3057\u307e\u3059\u3002\u30e9\u30dc\u30ce\u30fc\u30c8\u306f\u81ea\u52d5\u3067\u958b\u304d\u307e\u3059\u306e\u3067\uff0c\u9069\u5b9c\u30e1\u30e2\u3092\u3068\u308a\u306a\u304c\u3089\u7814\u7a76\u3092\u5b9f\u65bd\u3057\u3066\uff0c\u9069\u5b9cknit\u3092\u3057\u3066\u304f\u3060\u3055\u3044\u3002\r\n\r\n``` r\r\npsyinfr::researchIn()\r\n``` \r\n## \u7814\u7a76\u7d42\u4e86\r\n\r\n\u305d\u306e\u65e5\u306e\u7814\u7a76\u306e\u7d42\u4e86\u6642\u306b\u4ee5\u4e0b\u306e\u95a2\u6570\u3092\u5b9f\u884c\u3059\u308b\u3068\uff0c\u30e9\u30dc\u30ce\u30fc\u30c8\u3092\u4fdd\u5b58\u3057\u305f\u4e0a\u3067\uff0c\u5909\u66f4\u52a0\u3048\u305f\u30d5\u30a1\u30a4\u30eb\u306b\u30b3\u30df\u30c3\u30c8\u3092\u52a0\u3048\u305f\u4e0a\u3067\uff0cGitHub\u306b\u81ea\u52d5\u7684\u306b\u30d7\u30c3\u30b7\u30e5\u3057\u307e\u3059\u3002\r\n\r\n``` r\r\npsyinfr::researchOut()\r\n```", "README.md")
    navigateToFile(file.path(path, "README.md"))
  }

  # make paper.Rmd
  if(!file.exists(file.path(path, "paper/paper.Rmd"))){
    rmarkdown::draft(paste0("paper.Rmd"), template = "thesis_senshu", package = "psyinfr", edit = FALSE)
    navigateToFile(file.path(path, "paper/paper.Rmd"))
  }

  # add senshuQmdWord
  if(!dir.exists(file.path(path, "paper_word"))){
    dir.create(file.path(path, "paper_word"), showWarnings = FALSE)
    if(!file.exists(file.path(path, "paper_word/apa.csl"))){
    download.file("https://raw.githubusercontent.com/ykunisato/senshuQmdWord/main/apa.csl",paste0(path,"/paper_word/apa.csl"))
    }
    if(!file.exists(file.path(path, "paper_word/fig1.png"))){
      download.file("https://raw.githubusercontent.com/ykunisato/senshuQmdWord/main/fig1.png",paste0(path,"/paper_word/fig1.png"))
    }
    if(!file.exists(file.path(path, "paper_word/apa.csl"))){
      download.file("https://raw.githubusercontent.com/ykunisato/senshuQmdWord/main/apa.csl",paste0(path,"/paper_word/apa.csl"))
    }
    if(!file.exists(file.path(path, "paper_word/paper_word.qmd"))){
      download.file("https://raw.githubusercontent.com/ykunisato/senshuQmdWord/main/apa.csl",paste0(path,"/paper_word/paper_word.qmd"))
    }
    if(!file.exists(file.path(path, "paper_word/references.bib"))){
      download.file("https://raw.githubusercontent.com/ykunisato/senshuQmdWord/main/apa.csl",paste0(path,"/paper_word/references.bib"))
    }
    navigateToFile(file.path(path, "paper_word/paper_word.qmd"))
  }

  if(!dir.exists(file.path(path, "paper_word/word_template"))){
    dir.create(file.path(path, "paper_word/word_template"), showWarnings = FALSE)
    if(!file.exists(file.path(path, "paper_word/word_template/senshu.docx"))){
      download.file("https://raw.githubusercontent.com/ykunisato/senshuQmdWord/main/word_template/senshu.docx",paste0(path,"/paper_word/word_template/senshu.docx"))
    }
  }


  # make analysis directory
  if(!dir.exists(file.path(path, "analysis"))){
    dir.create(file.path(path, "analysis"), showWarnings = FALSE)
    file.create(file.path(path, "analysis/README_analysis.md"), showWarnings = FALSE)
    writeLines("README(analysis)\r\n\r\n\u89e3\u6790\u306b\u4f7f\u3046R\u3084Rmd\u30d5\u30a1\u30a4\u30eb\u3092\u3053\u3053\u306b\u7f6e\u304d\u307e\u3059\u3002\r\nAnalysis01.Rmd,Analysis02.Rmd\u306e\u3088\u3046\u306b\uff0c\u30d5\u30a1\u30a4\u30eb\u540d\u306f\u89e3\u6790\u306e\u9806\u756a\u304c\u308f\u304b\u308b\u3088\u3046\u306b\u3064\u3051\u3066\u304f\u3060\u3055\u3044\u3002\r\nRmd\u30d5\u30a1\u30a4\u30eb\u306f\u89e3\u6790\u3068\u305d\u306e\u8aac\u660e\u3092\u307e\u3068\u3081\u3084\u3059\u3044\u306e\u3067\uff0c\u3067\u304d\u308b\u3060\u3051Rmd\u30d5\u30a1\u30a4\u30eb\u3092\u4f7f\u3046\u3088\u3046\u306b\u3057\u3066\u304f\u3060\u3055\u3044\u3002", "analysis/README_analysis.md")
    file_path <- paste0(path,"/analysis/Analysis01.Rmd")
    path_skeleton <- system.file("rmarkdown/templates/analysis/skeleton/skeleton.Rmd",package = "psyinfr")
    text_skeleton <- readLines(path_skeleton, warn = F)
    tmp_rmd <- file(file_path, "w")
    for (i in 1:length(text_skeleton)) {
      st <- text_skeleton[i]
      st <- str_replace(st, pattern = "title: 'title'",
                        replacement = paste0("title: ", "'Analysis01'"))
      writeLines(st, tmp_rmd)
    }
    close(tmp_rmd)
    navigateToFile(file_path)
  }

  # make data directory
  if(!dir.exists(file.path(path, "analysis/data"))){
    dir.create(file.path(path, "analysis/data"), showWarnings = FALSE)
    file.create(file.path(path, "analysis/data/README_data.md"), showWarnings = FALSE)
    writeLines("README(data)\n\n\u3053\u3061\u3089\u306b\u89e3\u6790\u3067\u4f7f\u3046\u30c7\u30fc\u30bf\u3092\u7f6e\u304d\u307e\u3059\u3002OSF\u3084GitHub\u306b\u304a\u3044\u3066\u3082\u5927\u4e08\u592b\u306a\u30c7\u30fc\u30bf\u5316\u3069\u3046\u304b\u306f\u6307\u5c0e\u6559\u54e1\u306b\u76f8\u8ac7\u3092\u3057\u3066\u304f\u3060\u3055\u3044\u3002", "analysis/data/README_data.md")
  }

  # make function directory
  if(!dir.exists(file.path(path, "analysis/function"))){
    dir.create(file.path(path, "analysis/function"), showWarnings = FALSE)
    file.create(file.path(path, "analysis/function/README_function.md"), showWarnings = FALSE)
    writeLines("README(function)\n\n\u3053\u3061\u3089\u306b\u89e3\u6790\u3067\u4f7f\u3046R\u95a2\u6570\u3092\u7f6e\u304d\u307e\u3059\u3002\u95a2\u6570\u5316\u3057\u305f\u3082\u306e\u306f\u5225\u306b\u307e\u3068\u3081\u3066\u304a\u3044\u305f\u307b\u3046\u304c\u4fbf\u5229\u306a\u306e\u3067\uff0c\u3053\u3061\u3089\u3092\u5229\u7528\u304f\u3060\u3055\u3044\u3002", "analysis/function/README_function.md")
  }

  # make high load directory
  if(!dir.exists(file.path(path, "analysis/high_load"))){
    dir.create(file.path(path, "analysis/high_load"), showWarnings = FALSE)
    file.create(file.path(path, "analysis/high_load/README_high_load.md"), showWarnings = FALSE)
    writeLines("README(high load)\n\n\u3053\u3061\u3089\u306b\u306f\uff0c\u9ad8\u8ca0\u8377\u306a\u89e3\u6790\uff08\u6570\u5206\u3067\u7d42\u308f\u3089\u306a\u3044\u89e3\u6790\u306e\u3053\u3068\u3067\u3059\uff09\u3067\u4f7f\u3046R\u95a2\u6570\u306a\u3069\u3092\u7f6e\u304d\u307e\u3059\u3002", "analysis/high_load/README_high_load.md")
  }

  # make materials directory
  if(!dir.exists(file.path(path, "material"))){
    dir.create(file.path(path, "material"), showWarnings = FALSE)
    file.create(file.path(path, "material/README_materials.md"), showWarnings = FALSE)
    writeLines("README(materials)\n\n\u7814\u7a76\u3067\u4f7f\u7528\u3057\u305f\u6750\u6599\uff08\u5b9f\u9a13\u8ab2\u984c\uff0c\u8cea\u554f\u7d19\uff0c\u5b9f\u9a13\u30fb\u8abf\u67fb\u30d7\u30ed\u30c8\u30b3\u30eb\uff0c\u502b\u7406\u7533\u8acb\u66f8\uff09\u306a\u3069\u3092\u3053\u3061\u3089\u306b\u4fdd\u7ba1\u3057\u3066\u304f\u3060\u3055\u3044\u3002", "material/README_materials.md")
  }

  # make exercises directory
  if(!dir.exists(file.path(path, "exercise"))){
    dir.create(file.path(path, "exercise"), showWarnings = FALSE)
    file.create(file.path(path, "exercise/README_exercise.r"), showWarnings = FALSE)
    writeLines("# README(exercise)\r\n\r\n# \u6f14\u7fd2\u8ab2\u984c\u306f\uff0c\u3053\u3061\u3089\u306b\u4fdd\u5b58\u3057\u3066\u304f\u3060\u3055\u3044\u3002\r\n# \u4ee5\u4e0b\u306e\u3088\u3046\u306b\uff0cset_cbat(\"\u8a8d\u77e5\u8ab2\u984c\u540d\uff08\u82f1\u8a9e\uff09\",\"jsPsych\u306e\u30d0\u30fc\u30b8\u30e7\u30f3\")\u3092\u5b9f\u884c\u3059\u308b\u3068\uff0cexercise\u30d5\u30a9\u30eb\u30c0\u5185\u306b\u6307\u5b9a\u3057\u305f\u8a8d\u77e5\u8ab2\u984c\u540d\u306e\u30d5\u30a9\u30eb\u30c0\u3092\u4f5c\u6210\u3057\uff0c\u5fc5\u8981\u306ajsPsych\u95a2\u9023\u30d5\u30a1\u30a4\u30eb\u304c\u30c0\u30a6\u30f3\u30ed\u30fc\u30c9\u3055\u308c\u307e\u3059\u3002\u7279\u306b\u8a2d\u5b9a\u3092\u3057\u306a\u304f\u3066\u3082\uff0c\u305d\u306e\u4e2d\u306b\u3042\u308btask.js\u30d5\u30a1\u30a4\u30eb\u306b\u66f8\u304d\u8fbc\u3080\u3060\u3051\u3067jsPsych\u8ab2\u984c\u304c\u4f5c\u6210\u3067\u304d\u307e\u3059\u3002\npsyinfr::set_cbat('stroop','7.2.1')", "exercise/README_exercise.r")
  }

  # make labnote directory
  if(!dir.exists(file.path(path, "labnote"))){
    dir.create(file.path(path, "labnote"), showWarnings = FALSE)
    file.create(file.path(path, "labnote/README_labnote.r"), showWarnings = FALSE)
    writeLines("# README(labnote)\r\n\r\n# \u96fb\u5b50\u30e9\u30dc\u30ce\u30fc\u30c8\u306f\u3053\u3061\u3089\u306b\u4fdd\u5b58\u3055\u308c\u307e\u3059\u3002\u4ee5\u4e0b\u3092\u5b9f\u884c\u3059\u308b\u3068\u30e9\u30dc\u30ce\u30fc\u30c8\u304c\u4f5c\u6210\u3055\u308c\u307e\u3059\u3002\r\n\r\n psyinfr::researchIn()\n# \u4ee5\u4e0b\u3092\u5b9f\u884c\u3059\u308b\u3068\uff0c\u30e9\u30dc\u30ce\u30fc\u30c8\u304c\u30b3\u30df\u30c3\u30c8\u3055\u308c\u3066GitHub\u306b\u30d7\u30c3\u30b7\u30e5\u3055\u308c\u307e\u3059\u3002\n psyinfr::researchOut()", "labnote/README_labnote.r")
  }
}
