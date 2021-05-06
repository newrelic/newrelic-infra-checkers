SEMGREP_GO_REPO="https://github.com/dgryski/semgrep-go"
SEMGREP_GO_FOLDER="semgrep-go"
YQ_VERSION=v4.7.1
OS=$(uname | tr 'A-Z' 'a-z')
[[ $(uname -m) = "x86_64" ]] && ARC="amd64" || ARC="i386"

semgrep_get_policies() {
  PHOLDER_QUOTES="#placeholder-quotes#"
  PHOLDER_SLASH="#placeholder-slash#"

  mkdir -p bin
  wget --no-check-certificate https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_${OS}_${ARC}.tar.gz -O - |\
    tar xz && mv yq_${OS}_${ARC} ./bin/yq

  if [ -d "$SEMGREP_GO_FOLDER" ]; then rm -Rf $SEMGREP_GO_FOLDER; fi
  git clone $SEMGREP_GO_REPO;

  echo "r"
  # substitute \ and \" symbols by placeholder so yq doesn't strip them
  OUT=$(sed 's/\\"/'"$PHOLDER_QUOTES"'/g' .semgrep.yml | sed 's/\\/'"$PHOLDER_SLASH"'/g')
  echo "$OUT" > .semgrep.yml
echo "r2"
  if [[ -f "$BCK_SEMGREP_FILE" ]]
  then
    echo "r4"
    # substitute \ and \" symbols by placeholder so yq doesn't strip them
    OUT=$(sed 's/\\"/'"$PHOLDER_QUOTES"'/g' "$BCK_SEMGREP_FILE" | sed 's/\\/'"$PHOLDER_SLASH"'/g')
    OUT=$(./bin/yq eval-all 'select(fileIndex == 0).rules + select(fileIndex == 1).rules' $BCK_SEMGREP_FILE .semgrep.yml |\
          ./bin/yq eval '{"rules": .}' -)
    echo "$OUT" > .semgrep.yml
    rm $BCK_SEMGREP_FILE
  fi
echo "r5"
  for entry in "$SEMGREP_GO_FOLDER"/*
  do
    if [ "${entry: -4}" == ".yml" ]
    then
        # substitute \ and \" symbols by placeholder so yq doesn't strip them
        OUTPUT=$(sed 's/\\"/'"$PHOLDER_QUOTES"'/g' $entry | sed 's/\\/'"$PHOLDER_SLASH"'/g')
        echo "$OUTPUT" > "$entry"
echo "r6"
        OUTPUT=$(./bin/yq eval-all 'select(fileIndex == 0).rules + select(fileIndex == 1).rules' $entry .semgrep.yml |\
          ./bin/yq eval '{"rules": .}' -)
        echo "$OUTPUT" > .semgrep.yml
    fi
  done
echo "r7"
  # restore \ and \" symbols from placeholder
  OUTPUT=$(sed 's/'"$PHOLDER_QUOTES"'/\\"/g' .semgrep.yml | sed 's/'"$PHOLDER_SLASH"'/\\\\/g')
  echo "$OUTPUT" > .semgrep.yml
echo "r8"
  rm -rf semgrep-go
}
