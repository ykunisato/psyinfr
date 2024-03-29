#' @title run r files using parallel
#' @importFrom parallel detectCores
#' @importFrom parallel makeCluster
#' @importFrom parallel parLapply
#' @importFrom parallel stopCluster
#' @param r_files set vector of r files
#' @export
runParallelR <- function(r_files){
  numCores <- parallel::detectCores()
  clusters <- parallel::makeCluster(numCores)
  result <- parallel::parLapply(clusters, r_files, source)
  parallel::stopCluster(clusters)
  return(result)
}

#' @title run high load computing and psuh to GitHub
#' @importFrom usethis use_git_config
#' @importFrom gitcreds gitcreds_set
#' @param git_name set user name of GitHub
#' @param git_email set e-mail of GitHub
#' @param slack_token set slack API token
#' @param slack_channel set channel name of slack
#' @examples # setGitSlack(user_name_github, email_github, slack_token, slack_channel, slack_username)
#' @export
setGitSlack <- function(git_name,
                      git_email,
                      slack_token = "FALSE",
                      slack_channel = "#general"){
  if(missing(git_name)){
    stop("Please set git_name.")
  }else if(missing(git_email)){
    stop("Please set git_email.")
  }else if(missing(slack_token)){
    stop("Please set slack_token.")
  }
  # set git user name and e-mail
  usethis::use_git_config(user.name = git_name, user.email = git_email)
  # set slack
  if (slack_token != "FALSE"){
    Sys.setenv(SLACK_TOKEN=slack_token)
    Sys.setenv(SLACK_CHANNEL=slack_channel)
  }
}

#' @title run high load computing and psuh to GitHub
#' @importFrom gert git_add
#' @importFrom gert git_commit_all
#' @importFrom gert git_push
#' @importFrom gert git_info
#' @importFrom gert git_status
#' @importFrom httr POST
#' @param r_file set r file to run
#' @examples # runHighLoad(r_file)
#' @export
runHighLoad <- function(r_file) {
  # check argument
  if (Sys.getenv("SLACK_TOKEN") == "") {
    stop("Please set slack_token with set_slack")
  }
  if (Sys.getenv("SLACK_CHANNEL") == "") {
    stop("Please set slack_channel with set_slack")
  }
  # run r file
  if(length(r_file)==1){
    source(r_file)
  }else if(length(r_file)>1){
    psyinfr::runParallelR(r_file)
  }
  # send message to slack
  httr::POST(url="https://slack.com/api/chat.postMessage",
             body = list(token = Sys.getenv("SLACK_TOKEN"),
                         channel = Sys.getenv("SLACK_CHANNEL"),
                         text = paste(format(as.POSIXlt(Sys.time(), tz = "Asia/Tokyo"),"%Y/%m/%d %H:%M")," \u8ca0\u8377\u306e\u9ad8\u3044\u8a08\u7b97\u304c\u7d42\u4e86\u3057\u307e\u3057\u305f\u3002\u95a2\u9023\u3059\u308b\u30d5\u30a1\u30a4\u30eb\u3092\u30b3\u30df\u30c3\u30c8\u3057\u3066\u30d7\u30c3\u30b7\u30e5\u3057\u307e\u3057\u305f\u3002")))
  # add & commit & push
  git_add(git_status()$file)
  git_commit_all("\u8ca0\u8377\u306e\u9ad8\u3044\u8a08\u7b97\u304c\u7d42\u4e86\u3057\u307e\u3057\u305f\u3002\u95a2\u9023\u3059\u308b\u30d5\u30a1\u30a4\u30eb\u3092\u30b3\u30df\u30c3\u30c8\u3057\u3066\u30d7\u30c3\u30b7\u30e5\u3057\u307e\u3057\u305f\u3002")
  git_push()
}
