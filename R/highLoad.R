# memo 並列処理をする



#' @title run high load computing and psuh to GitHub
#' @importFrom usethis use_git_config
#' @importFrom gitcreds gitcreds_set
#' @param git_name set user name of GitHub
#' @param git_email set e-mail of GitHub
#' @param slack_token set slack API token
#' @param slack_channel set channel name of slack
#' @param slack_username set user name of slack
#' @param slack_token2 set 2nd slack API token
#' @param slack_channel2 set 2nd channel name of slack
#' @param slack_username2 set 2nd user name of slack
#' @export
setGitSlack <- function(git_name,
                      git_email,
                      slack_token = "FALSE",
                      slack_channel = "#general",
                      slack_username = "R",
                      slack_token2 = "FALSE",
                      slack_channel2 = "#general",
                      slack_username2 = "R"){
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
    Sys.setenv(SLACK_USERNAME=slack_username)
  }
  if (slack_token2 != "FALSE"){
    Sys.setenv(SLACK_TOKEN2 = slack_token2)
    Sys.setenv(SLACK_CHANNEL2 = slack_channel2)
    Sys.setenv(SLACK_USERNAME2 = slack_username2)
  }
  # set GitHub PAT
  gitcreds::gitcreds_set()
}

#' @title run high load computing and psuh to GitHub
#' @importFrom gert git_add
#' @importFrom gert git_commit_all
#' @importFrom gert git_push
#' @importFrom gert git_info
#' @importFrom gert git_status
#' @importFrom httr POST
#' @param r_file set r file to run
#' @export
runHighLoad <- function(r_file) {
  # check argument
  if (Sys.getenv("SLACK_TOKEN") == "") {
    stop("Please set slack_token with set_slack")
  }
  if (Sys.getenv("SLACK_CHANNEL") == "") {
    stop("Please set slack_channel with set_slack")
  }
  if (Sys.getenv("SLACK_USERNAME") == "") {
    stop("Please set slack_username with set_slack")
  }
  # run r file
  source(r_file)
  # send message to slack
  httr::POST(url="https://slack.com/api/chat.postMessage",
             body = list(token = Sys.getenv("SLACK_TOKEN"),
                         channel = Sys.getenv("SLACK_CHANNEL"),
                         username = Sys.getenv("SLACK_USERNAME"),
                         text = paste(format(as.POSIXlt(Sys.time(), tz = "Asia/Tokyo"),"%Y/%m/%d %H:%M")," \u8ca0\u8377\u306e\u9ad8\u3044\u8a08\u7b97\u304c\u7d42\u4e86\u3057\u307e\u3057\u305f\u3002\u95a2\u9023\u3059\u308b\u30d5\u30a1\u30a4\u30eb\u3092\u30b3\u30df\u30c3\u30c8\u3057\u3066\u30d7\u30c3\u30b7\u30e5\u3057\u307e\u3057\u305f\u3002")))
  # send message to 2nd slack
  if (Sys.getenv("SLACK_TOKEN") != "") {
  httr::POST(url="https://slack.com/api/chat.postMessage",
             body = list(token = Sys.getenv("SLACK_TOKEN"),
                         channel = Sys.getenv("SLACK_CHANNEL"),
                         username = Sys.getenv("SLACK_USERNAME"),
                         text = paste(format(as.POSIXlt(Sys.time(), tz = "Asia/Tokyo"),"%Y/%m/%d %H:%M")," \u8ca0\u8377\u306e\u9ad8\u3044\u8a08\u7b97\u304c\u7d42\u4e86\u3057\u307e\u3057\u305f\u3002\u95a2\u9023\u3059\u308b\u30d5\u30a1\u30a4\u30eb\u3092\u30b3\u30df\u30c3\u30c8\u3057\u3066\u30d7\u30c3\u30b7\u30e5\u3057\u307e\u3057\u305f\u3002")))
  }
  # add & commit & push
  git_add(git_status()$file)
  git_commit_all("\u8ca0\u8377\u306e\u9ad8\u3044\u8a08\u7b97\u304c\u7d42\u4e86\u3057\u307e\u3057\u305f\u3002\u95a2\u9023\u3059\u308b\u30d5\u30a1\u30a4\u30eb\u3092\u30b3\u30df\u30c3\u30c8\u3057\u3066\u30d7\u30c3\u30b7\u30e5\u3057\u307e\u3057\u305f\u3002")
  git_push()
}
