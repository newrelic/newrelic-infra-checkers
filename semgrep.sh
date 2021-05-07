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

  # substitute \ and \" symbols by placeholder so yq doesn't strip them
  sed 's/\\"/'"$PHOLDER_QUOTES"'/g' .semgrep.yml | sed 's/\\/'"$PHOLDER_SLASH"'/g' > .semgrep.yml.fixed
  mv .semgrep.yml{.fixed,}

  if [[ -f .semgrep.yml.bak ]]
  then
    # substitute \ and \" symbols by placeholder so yq doesn't strip them
    sed 's/\\"/'"$PHOLDER_QUOTES"'/g' .semgrep.yml.bak | sed 's/\\/'"$PHOLDER_SLASH"'/g' > .semgrep.yml.fixed
    ./bin/yq eval-all 'select(fileIndex == 0).rules + select(fileIndex == 1).rules' .semgrep.yml.bak .semgrep.yml |\
          ./bin/yq eval '{"rules": .}' - > .semgrep.yml.fixed
    mv .semgrep.yml{.fixed,}
    rm .semgrep.yml.bak
  fi

  for entry in "$SEMGREP_GO_FOLDER"/*
  do
    if [ "${entry: -4}" == ".yml" ]
    then
        # substitute \ and \" symbols by placeholder so yq doesn't strip them
        cat .semgrep.yml | sed 's/\\"/'"$PHOLDER_QUOTES"'/g' | sed 's/\\/'"$PHOLDER_SLASH"'/g' > .semgrep.yml.fixed
        mv .semgrep.yml{.fixed,}


        ./bin/yq eval-all 'select(fileIndex == 0).rules + select(fileIndex == 1).rules' $entry .semgrep.yml |\
          ./bin/yq eval '{"rules": .}' - > .semgrep.yml.fixed
        mv .semgrep.yml{.fixed,}
    fi
  done

  # restore \ and \" symbols from placeholder
  cat .semgrep.yml | sed 's/'"$PHOLDER_QUOTES"'/\\"/g' | sed 's/'"$PHOLDER_SLASH"'/\\\\/g' > .semgrep.yml.fixed
  mv .semgrep.yml{.fixed,}

  rm -rf semgrep-go
}
