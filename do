#!/usr/bin/env bash
set -euo pipefail

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_kubeconform="Run helm kubeconform"
kubeconform() {
    check-helm

    install-plugin kubeconform https://github.com/jtyr/kubeconform-helm

    for chart_dir in ./helm/*/; do
        if [[ -f "$chart_dir/Chart.yaml" ]]; then
            if [[ "$chart_dir" == *"common"* ]]; then
                continue
            fi

            echo "Validating chart: $chart_dir"
            helm kubeconform --ignore-missing-schema --verbose --summary --strict "$@" \
                --schema-location default \
                --schema-location https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json \
                "$chart_dir" || exit 1
        fi
    done
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_package_chart="Package a Helm chart"
package-chart() {
    check-helm

    chart_dir="${1:-.}"
    arg="${2:-}"
    if [ -n "${arg}" ]; then
        shift 2
    else
        shift
    fi

    echo 'Updating dependencies'
    helm dependency update "${chart_dir}"

    mkdir -p target

    echo "Packaging Helm chart"
    case ${arg} in
    "sign")
        echo 'Signing Helm chart'
        # shellcheck disable=SC2086
        helm package --sign --key "${KEY:-<eng-on-prem@circleci.com>}" --keyring ${KEYRING:-~/.gnupg/secring.gpg} \
          --destination ./target "${chart_dir}" "$@"
        echo 'Verifying Helm chart signature'
        helm verify ./target/"$(basename "${chart_dir}")"*.tgz
        ;;
    *)
        helm package --destination ./target "${chart_dir}"
        ;;
    esac
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_package_all_charts="Package all Helm charts"
package-all-charts() {
    charts_dir="${1:-./helm}"

    if [ ! -d "${charts_dir}" ]; then
        echo "Charts directory '${charts_dir}' not found"
        return 1
    fi

    stdin_data=$([ -t 0 ] || cat)

    for chart_path in "${charts_dir}"/*; do
        if [ -d "${chart_path}" ]; then
            if [[ "${chart_path}" == *"common"* ]]; then
                continue
            fi

            echo "Processing chart: $(basename "${chart_path}")"
            echo "${stdin_data}" | ./do package-chart "${chart_path}" "${@:2}"
            echo
        fi
    done
}

check-helm() {
    if ! [ -x "$(command -v helm)" ]; then
        echo 'Helm is required. See: https://helm.sh/docs/intro/install/'
        exit 1
    fi
}

install-plugin() {
    name="${1}"
    repo="${2}"

    if ! helm plugin list | grep ${name} >/dev/null; then
        echo "Installing helm ${name}"
        helm plugin install "${repo}"
    fi
}

help-text-intro() {
    echo "
DO

A set of simple repetitive tasks that adds minimally
to standard tools used to build and test the service.
(e.g. go and docker)
"
}

### START FRAMEWORK ###
# Do Version 0.0.4
# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_self_update="Update the framework from a file.

Usage: $0 self-update FILENAME
"
self-update() {
    local source selfpath pattern
    source="$1"
    selfpath="${BASH_SOURCE[0]}"
    cp "$selfpath" "$selfpath.bak"
    pattern='/### START FRAMEWORK/,/END FRAMEWORK ###$/'
    (
        sed "${pattern}d" "$selfpath"
        sed -n "${pattern}p" "$source"
    ) \
        >"$selfpath.new"
    mv "$selfpath.new" "$selfpath"
    chmod --reference="$selfpath.bak" "$selfpath"
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_completion="Print shell completion function for this script.

Usage: $0 completion SHELL"
completion() {
    local shell
    shell="${1-}"

    if [ -z "$shell" ]; then
        echo "Usage: $0 completion SHELL" 1>&2
        exit 1
    fi

    case "$shell" in
    bash)
        (
            echo
            echo '_dotslashdo_completions() { '
            # shellcheck disable=SC2016
            echo '  COMPREPLY=($(compgen -W "$('"$0"' list)" "${COMP_WORDS[1]}"))'
            echo '}'
            echo 'complete -F _dotslashdo_completions '"$0"
        )
        ;;
    zsh)
        cat <<EOF
_dotslashdo_completions() {
  local -a subcmds
  subcmds=()
  DO_HELP_SKIP_INTRO=1 $0 help | while read line; do
EOF
        cat <<'EOF'
    cmd=$(cut -f1  <<< $line)
    cmd=$(awk '{$1=$1};1' <<< $cmd)

    desc=$(cut -f2- <<< $line)
    desc=$(awk '{$1=$1};1' <<< $desc)

    subcmds+=("$cmd:$desc")
  done
  _describe 'do' subcmds
}

compdef _dotslashdo_completions do
EOF
        ;;
    fish)
        cat <<EOF
complete -e -c do
complete -f -c do
for line in (string split \n (DO_HELP_SKIP_INTRO=1 $0 help))
EOF
        cat <<'EOF'
  set cmd (string split \t $line)
  complete -c do  -a $cmd[1] -d $cmd[2]
end
EOF
        ;;
    esac
}

list() {
    declare -F | awk '{print $3}'
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_help="Print help text, or detailed help for a task."
help() {
    local item
    item="${1-}"
    if [ -n "${item}" ]; then
        local help_name
        help_name="help_${item//-/_}"
        echo "${!help_name-}"
        return
    fi

    if [ -z "${DO_HELP_SKIP_INTRO-}" ]; then
        type -t help-text-intro >/dev/null && help-text-intro
    fi
    for item in $(list); do
        local help_name text
        help_name="help_${item//-/_}"
        text="${!help_name-}"
        [ -n "$text" ] && printf "%-30s\t%s\n" "$item" "$(echo "$text" | head -1)"
    done
}

case "${1-}" in
list) list ;;
"" | "help") help "${2-}" ;;
*)
    if ! declare -F "${1}" >/dev/null; then
        printf "Unknown target: %s\n\n" "${1}"
        help
        exit 1
    else
        "$@"
    fi
    ;;
esac
### END FRAMEWORK ###
