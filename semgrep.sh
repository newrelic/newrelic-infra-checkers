SEMGREP_GO_REPO="https://github.com/dgryski/semgrep-go"
SEMGREP_GO_FOLDER="semgrep-go"
YQ_VERSION=v4.7.1
OS=$(uname | tr 'A-Z' 'a-z')
[[ $(uname -m) = "x86_64" ]] && ARC="amd64" || ARC="i386"

semgrep_get_policies() {
  mkdir -p bin
  wget --no-check-certificate https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_${OS}_${ARC}.tar.gz -O - |\
    tar xz && mv yq_${OS}_${ARC} ./bin/yq

  if [ -d "$SEMGREP_GO_FOLDER" ]; then rm -Rf $SEMGREP_GO_FOLDER; fi
  git clone $SEMGREP_GO_REPO;

  # substitute \ and \" symbols by placeholder so yq doesn't strip them
  OUTPUT=$(sed 's/\\"/#placeholder-quotes#/g' .semgrep.yml | sed 's/\\/#placeholder-slash#/g')
  echo "$OUTPUT" > .semgrep.yml

  for entry in "$SEMGREP_GO_FOLDER"/*
  do
    if [ "${entry: -4}" == ".yml" ]
    then
        # substitute \ and \" symbols by placeholder so yq doesn't strip them
        OUTPUT=$(sed 's/\\"/#placeholder-quotes#/g' $entry | sed 's/\\/#placeholder-slash#/g')
        echo "$OUTPUT" > "$entry"

        OUTPUT=$(./bin/yq eval-all 'select(fileIndex == 0).rules + select(fileIndex == 1).rules' $entry .semgrep.yml |\
          ./bin/yq eval '{"rules": .}' -)
        echo "$OUTPUT" > .semgrep.yml
    fi
  done

  # restore \ and \" symbols from placeholder
  OUTPUT=$(sed 's/#placeholder-quotes#/\\"/g' .semgrep.yml | sed 's/#placeholder-slash#/\\\\/g')
  echo "$OUTPUT" > .semgrep.yml

  rm -rf semgrep-go
}