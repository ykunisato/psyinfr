#' @title render function for Japanese e-labnotebook in PDF
#' @importFrom rmarkdown render
#' @importFrom rmarkdown pdf_document
#' @importFrom stringr str_replace
#' @param Rmd_file file name of R Markdown file
#' @export
render_elnjp_pdf <- function(Rmd_file) {
  template_tex_file <- system.file("rmarkdown/templates/eln_jp/resources/eln_jp.tex",
                                   package = "psyinfr")
  format_pdf <- pdf_document(
    latex_engine = "xelatex",
    template = template_tex_file,
    highlight = "tango")
  format_pdf$inherits <- "pdf_document"
  render(Rmd_file, format_pdf)
}

#' @title start research with new Japanese e-labnotebook
#' @importFrom stringr str_detect
#' @importFrom stringr str_replace
#' @importFrom rstudioapi navigateToFile
#' @param rc If you are using Research Compendium of senshuRmd,
#' you can create a e-labnotebook file in the "labnote" directory from the current directory.
#' In that case, please set rc to TURE.
#' @examples # researchIn()
#' @export
researchIn <- function(rc = TRUE) {
  # Pull repogitory
  system("git pull origin main")
  # set file name
  tmp_wd <- getwd()
  date_name <- strsplit(paste0(as.POSIXlt(Sys.time(), format="%Y-%m-%d %H:%M:%S", tz="Japan")), " +")[[1]][1]
  file_name <- paste0(date_name, ".Rmd")
  # set Rmd template file
  path_skeleton <- system.file("rmarkdown/templates/eln_jp/skeleton/skeleton.Rmd",package = "psyinfr")
  text_skeleton <- readLines(path_skeleton, warn = F)
  # set render function
  if(rc == TRUE){
    save_name <- paste0("labnote/",file_name)
  }else{
    save_name <- file_name
  }
  tmp_rmd <- file(save_name, "w")
  for (i in 1:length(text_skeleton)) {
    st <- text_skeleton[i]
    st <- stringr::str_replace(st, pattern = "output: md_document",
                      replacement = paste0("output: psyinfr::render_elnjp_pdf(Rmd_file = '",file_name,"')"))
    st <- stringr::str_replace(st, pattern = "# date_research",
                      replacement = paste0("date_research <- '",date_name, "'"))
    st <- stringr::str_replace(st, pattern = "# date_write",
                      replacement = paste0("date_write <- '",date_name, "'"))
    writeLines(st, tmp_rmd)
  }
  close(tmp_rmd)
  rstudioapi::navigateToFile(paste0(tmp_wd,"/", save_name))
}

#' @title upload Japanese e-labnotebook to GitHub
#' @importFrom stringr str_replace
#' @param rc If you are using Research Compendium of senshuRmd,
#' you can create a e-labnotebook file in the "labnote" directory from the current directory.
#' In that case, please set rc to TURE.
#' @examples # researchOut()
#' @export
researchOut  <- function(rc = TRUE) {
  # make pdf firectory
  tmp_wd <- getwd()
  if(rc == TRUE){
    tmp_wd = paste0(tmp_wd, "/labnote")
  }
  date_name <- strsplit(paste0(as.POSIXlt(Sys.time(), format="%Y-%m-%d %H:%M:%S", tz="Japan")), " +")[[1]][1]
  labnote_today <- paste0(tmp_wd,"/",date_name,".Rmd")
  psyinfr::render_elnjp_pdf(Rmd_file = labnote_today)
  if(!dir.exists(file.path(tmp_wd, "pdf"))){
    dir.create(file.path(tmp_wd, "pdf"), showWarnings = FALSE)
  }
  # copy PDF
  file.copy(paste0(tmp_wd,"/",date_name,".pdf"),
            paste0(tmp_wd,"/pdf/",date_name,".pdf"), overwrite = TRUE)
  # add & commit & push
  system("git add .")
  system("git add -A")
  commit_message <- paste0("git commit -a -m '", date_name,"\u306e\u30e9\u30dc\u30ce\u30fc\u30c8\u3092\u4f5c\u6210\u3057\u307e\u3057\u305f\u3002\u95a2\u9023\u3059\u308b\u30d5\u30a1\u30a4\u30eb\u3082\u30b3\u30df\u30c3\u30c8\u3057\u307e\u3059'")
  system(commit_message)
  system("git push -u origin main")
}

#' @title upload Japanese e-labnotebook to OSF
#' @importFrom osfr osf_retrieve_node
#' @importFrom osfr osf_upload
#' @importFrom stringr str_replace
#' @param eln_osf URL of pdf directory in OSF
#' @param rc_osf If you are using Research Compendium of senshuRmd,
#' you can create a e-labnotebook file in the "labnote" directory from the current directory.
#' In that case, please set rc to TURE.
#' @export
up2osf  <- function(eln_osf = TRUE, rc_osf = TRUE){
  # check argument
  if(missing(eln_osf) & missing(rc_osf)){
    stop("eln_osf\u304brc_osf\u306b\u5165\u529b\u3092\u3057\u3066\u304f\u3060\u3055\u3044\u3002")
  }
  # set path
  tmp_wd <- getwd()
  if(rc_osf != FALSE){
    tmp_wd = paste0(tmp_wd, "/labnote")
  }
  # set file name
  date_name <- strsplit(paste0(as.POSIXlt(Sys.time(), format="%Y-%m-%d %H:%M:%S", tz="Japan")), " +")[[1]][1]
  # set file name
  pdf_file_name <- paste0(date_name, ".pdf")
  # upload labnote
  if(eln_osf != FALSE){
    labnote_pdf <- osf_retrieve_node(eln_osf)
    osf_upload(labnote_pdf, path = paste0(tmp_wd,"/",pdf_file_name), conflicts = "overwrite")
  }
  # upload backup
  if(rc_osf != FALSE){
    rc_component <- osf_retrieve_node(rc_osf)
    osf_upload(rc_component, path = paste0(getwd(), "/"), recurse = TRUE, conflicts = "overwrite")
  }
}
