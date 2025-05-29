export CLICOLOR=1
export BASH_SILENCE_DEPRECATION_WARNING=1
export EDITOR="code -w"
export DOCKER_HOST=unix://$HOME/.docker/run/docker.sock
export AWS_DEFAULT_REGION=us-west-2
export AWS_REGION=$AWS_DEFAULT_REGION
export JIRA_HOST="foo"

parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \w\[\033[32m\]\$(parse_git_branch)\[\033[00m\]$ "

alias cdg='cd $(git rev-parse --show-toplevel)'
alias tfplan='terraform plan -out plan.tfplan'
alias tfplano='tempfile="$(mktemp)" && tfplan -no-color | tee "${tempfile}" && echo "Saved to ${tempfile}" && code ${tempfile}'
alias tfapply='terraform apply plan.tfplan'

alias aws_tr_secrets='pbpaste | sed "s/export //g" | tr -d \" | pbcopy'

alias lock_poetry='find $(git rev-parse --show-toplevel) -name "poetry.lock" -exec dirname {} \; | xargs -I {} bash -c "cd {}; echo "{}"; poetry lock --no-update; echo ------"'
alias aws_tail='aws logs describe-log-groups --output json | jq -r ".logGroups[].logGroupName" | fzf-tmux -p80%,60% --height=50% --sync --exit-0 | xargs -I {} aws logs tail {} --follow'
alias aws_sqs='aws sqs list-queues --output json | jq -r ".QueueUrls[]" | fzf --sync --exit-0 | xargs -I {} aws sqs get-queue-attributes --queue-url {} --attribute-names All --output json | jq'
alias aws_secretsmanager='aws secretsmanager list-secrets --output json | jq -r ".SecretList[].Name" | fzf --sync --exit-0 | xargs -I {} aws secretsmanager get-secret-value --secret-id {} --output json | jq'
alias aws_ecr='aws ecr describe-repositories --output json | jq -r ".repositories[].repositoryName" | fzf --sync --exit-0 | xargs -I {} aws ecr describe-images --repository-name {} --output json | jq'

[ -f /usr/local/etc/bash_completion ] && source /usr/local/etc/bash_completion
source <(kubectl completion bash)

# allow locally installed npm binaries to be executed;
# added by `npm i -g add-local-binaries-to-path`
export PATH="$PATH:./node_modules/.bin:$HOME/.local/scripts"

alias git_pr='gh pr create --reviewer a --reviewer b --fill-first --assignee @me'
alias g='git'

function git_pr_checkout() {
  gh pr list | fzf --sync --exit-0 | awk '{ print $1 }' | xargs -I {} gh pr checkout {}
}

# tmux
export PATH="$PATH:$HOME/.local/scripts"
bind '"\C-f":"tmux-sessionizer\n"'
pwd_tmux_session="$(pwd | sed 's|\.|_|g')"
[ ! "$TERM_PROGRAM" = "tmux" ] && { tmux attach -t "$pwd_tmux_session" || exec tmux new-session -s "$pwd_tmux_session"; }

eval "$(thefuck --alias)"
eval "$(fzf --bash)"
source $HOME/custom-bash/fzf-git.sh/fzf-git.sh
source $HOME/custom-bash/fzf-docker/docker-fzf

export FZF_TMUX=1
export FZF_TMUX_OPTS='-p80%,60% --height=50%'
export BAT_THEME="tokyonight_night"

function fzf_aws_profile {
  cat ~/.aws/config | grep profile | awk '{ print $2 }' | sed 's|.$||' | fzf
}

function aws_sso_default_profile {
  aws sts get-caller-identity || aws sso login --profile "$AWS_DEFAULT_PROFILE"
}

alias aws_profile='export AWS_DEFAULT_PROFILE="$(fzf_aws_profile)" && aws_sso_default_profile'

export TODAYS_JIRA_PATH="$HOME/.jira-$(date '+%Y-%m-%d').json"
function jira_remove_cache {
  find $HOME -maxdepth 1 -name ".jira*" | xargs -I {} rm {}
}

function get_active_jira_tickets {
  find $HOME -maxdepth 1 -name ".jira*" ! -path "$TODAYS_JIRA_PATH" | xargs -I {} rm {}
  [ ! -f "$TODAYS_JIRA_PATH" ] && curl -X GET -u "$JIRA_AUTH" "$JIRA_HOST/rest/api/2/search?jql=assignee=currentUser()+and+updatedDate>=-15d+and+sprint+in+openSprints()" > "$TODAYS_JIRA_PATH"
  jq -r '.issues[] | "\(.key)|\(.fields.summary)"' "$TODAYS_JIRA_PATH" | fzf | awk -F '|' '{ printf $1 }' | pbcopy
}

alias jira='get_active_jira_tickets'
